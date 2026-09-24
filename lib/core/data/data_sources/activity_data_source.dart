import "dart:convert";

import "package:dartz/dartz.dart";
import "package:timing/core/domain/entities/activity_entry_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/core/services/sync/sync_error_classifier.dart";
import "package:timing/core/utils/id_generator.dart";

class ActivityDataSource {
  ActivityDataSource({
    required this._supabaseService,
    required this._localStorageService,
    required this._pendingSyncStore,
    required this._logger,
    this._activityChangeBus,
    this._isBackendReachable,
  });

  final ActivityChangeBus? _activityChangeBus;

  /// The app's connectivity flag: a failed upload is only queued when it says
  /// offline or the failure is not a definitive server rejection.
  final bool Function()? _isBackendReachable;

  final SupabaseService _supabaseService;
  final AppLocalStorageService _localStorageService;
  final PendingSyncStore _pendingSyncStore;
  final AppLoggerService _logger;
  // A remote call must fail fast on a "connected but no real internet"
  // network so its try/catch can queue the entry for retry, instead of
  // hanging on the platform's own (much longer) socket timeout.
  static const Duration _remoteCallTimeout = Duration(seconds: 10);

  /// Inserts one focus-session row. Unlike subjects/schedule/dailyTasks this
  /// is an append-only log, not a "resync current state" entity, so a failed
  /// upload is queued individually (not replaced by the next write) and
  /// retried later via [flushPendingSync]. The row's `id` is generated on the
  /// client so a retry can safely `upsert` instead of risking a duplicate
  /// `insert`. `activity_entries.id` is a Postgres `uuid` column (unlike the
  /// text ids subjects/schedule/dailyTasks use), so it needs [generateUuidV4]
  /// rather than [generateEntityId].
  Future<Either<AppError, void>> logActivity({
    required TimeCategoryType category,
    required String subjectId,
    required String subjectName,
    int seconds = 0,
    int pages = 0,
    int completedTasks = 0,
  }) async {
    final String? userId = _supabaseService.currentUserId;
    if (userId == null || seconds <= 0 && pages <= 0 && completedTasks <= 0) {
      return const Right(null);
    }

    final Map<String, dynamic> row = {
      "id": generateUuidV4(),
      "user_id": userId,
      "category": category.name,
      "subject_id": subjectId,
      "subject_name": subjectName,
      "seconds": seconds,
      "pages": pages,
      "completed_tasks": completedTasks,
      // The column defaults to the insert time, so a session queued while
      // offline would otherwise be dated at upload: shifting the group
      // leaderboards' day/week/month buckets and passing their reset cutoff.
      "occurred_at": DateTime.now().toUtc().toIso8601String(),
    };
    try {
      await _supabaseService.requireClient
          .from("activity_entries")
          .upsert(row, onConflict: "id")
          .timeout(_remoteCallTimeout);
      return const Right(null);
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to sync activity_entries row",
        error: error,
        stackTrace: stackTrace,
      );
      if (!shouldUseOfflineFallback(
        error,
        isBackendReachable: _isBackendReachable,
      )) {
        // The server rejected the row for good; queueing it would only get it
        // dropped later, so report the failure instead.
        return Left(GenericAppError(error: error, stackTrace: stackTrace));
      }
      await _enqueuePending(row);
      // The session is durably queued locally, so callers that only care
      // about their own on-device stats (which are recorded separately and
      // unconditionally) can treat this as success.
      return const Right(null);
    }
  }

  /// Re-attempts any focus sessions that failed to reach the backend
  /// earlier. No-op when nothing is pending.
  Future<void> flushPendingSync() async {
    if (!_pendingSyncStore.contains(PendingSyncDataset.activityEntries)) {
      return;
    }
    final List<Map<String, dynamic>> queue = await _readQueue();
    if (queue.isEmpty) {
      await _pendingSyncStore.clear(PendingSyncDataset.activityEntries);
      return;
    }
    try {
      await _supabaseService.requireClient
          .from("activity_entries")
          .upsert(queue, onConflict: "id")
          .timeout(_remoteCallTimeout);
      await _writeQueue(const []);
      await _pendingSyncStore.clear(PendingSyncDataset.activityEntries);
      _activityChangeBus?.notifyGroupActivityChanged();
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to flush queued activity_entries",
        error: error,
        stackTrace: stackTrace,
      );
      if (isPermanentSyncFailure(error)) {
        await _flushRowByRow(queue);
      }
    }
  }

  /// A single batch upsert fails as a whole, so one row the server rejects for
  /// good would block every other queued session forever. Retrying row by row
  /// isolates and drops the rejected ones while transient failures stay queued.
  Future<void> _flushRowByRow(List<Map<String, dynamic>> queue) async {
    int processed = 0;
    int uploaded = 0;
    try {
      for (final Map<String, dynamic> row in queue) {
        try {
          await _supabaseService.requireClient
              .from("activity_entries")
              .upsert(row, onConflict: "id")
              .timeout(_remoteCallTimeout);
          uploaded++;
        } catch (error, stackTrace) {
          if (!isPermanentSyncFailure(error)) {
            rethrow;
          }
          _logger.logError(
            "Dropping a queued activity_entries row the server rejected",
            error: error,
            stackTrace: stackTrace,
          );
        }
        processed++;
      }
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to flush a queued activity_entries row",
        error: error,
        stackTrace: stackTrace,
      );
    }
    final List<Map<String, dynamic>> remaining = queue.sublist(processed);
    await _writeQueue(remaining);
    if (uploaded > 0) {
      _activityChangeBus?.notifyGroupActivityChanged();
    }
    if (remaining.isEmpty) {
      await _pendingSyncStore.clear(PendingSyncDataset.activityEntries);
    }
  }

  Future<void> _enqueuePending(Map<String, dynamic> row) async {
    final List<Map<String, dynamic>> queue = await _readQueue();
    queue.add(row);
    await _writeQueue(queue);
    await _pendingSyncStore.markPending(PendingSyncDataset.activityEntries);
  }

  Future<List<Map<String, dynamic>>> _readQueue() async {
    final String? saved = await _localStorageService.read<String?>(
      LocalStorageKeys.pendingActivityEntries,
    );
    if (saved == null) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(saved) as List<dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeQueue(List<Map<String, dynamic>> queue) async {
    await _localStorageService.write(
      LocalStorageKeys.pendingActivityEntries,
      jsonEncode(queue),
    );
  }

  Future<Either<AppError, List<ActivityEntryEntity>>> getActivityEntries({
    int retentionDays = 400,
  }) async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      final DateTime cutoff = DateTime.now().toUtc().subtract(
        Duration(days: retentionDays),
      );
      final List<dynamic> rows = await _supabaseService.requireClient
          .from("activity_entries")
          .select()
          .eq("user_id", userId)
          .gte("occurred_at", cutoff.toIso8601String())
          .order("occurred_at")
          .timeout(_remoteCallTimeout);

      return Right(
        rows
            .map((row) => _entryFromRow(row as Map<String, dynamic>))
            .where(
              (entry) =>
                  entry.seconds > 0 ||
                  entry.pages > 0 ||
                  entry.completedTasks > 0,
            )
            .toList(),
      );
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  ActivityEntryEntity _entryFromRow(Map<String, dynamic> row) =>
      ActivityEntryEntity(
        id: row["id"] as String,
        category:
            TimeCategoryType.tryByName(row["category"] as String? ?? "") ??
            TimeCategoryType.studying,
        subjectId: row["subject_id"] as String? ?? "",
        subjectName: row["subject_name"] as String? ?? "",
        timestamp: DateTime.parse(row["occurred_at"] as String).toLocal(),
        seconds: (row["seconds"] as num?)?.toInt() ?? 0,
        pages: (row["pages"] as num?)?.toInt() ?? 0,
        completedTasks: (row["completed_tasks"] as num?)?.toInt() ?? 0,
      );
}
