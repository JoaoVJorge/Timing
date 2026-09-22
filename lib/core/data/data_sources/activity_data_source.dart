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
import "package:timing/core/utils/id_generator.dart";

class ActivityDataSource {
  ActivityDataSource({
    required this._supabaseService,
    required this._localStorageService,
    required this._pendingSyncStore,
    required this._logger,
    this._activityChangeBus,
  });

  final ActivityChangeBus? _activityChangeBus;

  final SupabaseService _supabaseService;
  final AppLocalStorageService _localStorageService;
  final PendingSyncStore _pendingSyncStore;
  final AppLoggerService _logger;

  /// Inserts one focus-session row. Unlike subjects/schedule/dailyTasks this
  /// is an append-only log, not a "resync current state" entity, so a failed
  /// upload is queued individually (not replaced by the next write) and
  /// retried later via [flushPendingSync]. The row's `id` is generated on the
  /// client (same [generateEntityId] used for subjects/schedule/dailyTasks)
  /// so a retry can safely `upsert` instead of risking a duplicate `insert`.
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
      "id": generateEntityId(),
      "user_id": userId,
      "category": category.name,
      "subject_id": subjectId,
      "subject_name": subjectName,
      "seconds": seconds,
      "pages": pages,
      "completed_tasks": completedTasks,
    };
    try {
      await _supabaseService.requireClient
          .from("activity_entries")
          .upsert(row, onConflict: "id");
      return const Right(null);
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to sync activity_entries row, queueing for retry",
        error: error,
        stackTrace: stackTrace,
      );
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
          .upsert(queue, onConflict: "id");
      await _writeQueue(const []);
      await _pendingSyncStore.clear(PendingSyncDataset.activityEntries);
      _activityChangeBus?.notifyGroupActivityChanged();
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to flush queued activity_entries",
        error: error,
        stackTrace: stackTrace,
      );
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
          .order("occurred_at");

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
