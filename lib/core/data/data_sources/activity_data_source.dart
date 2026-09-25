import "dart:async";
import "dart:convert";

import "package:dartz/dartz.dart";
import "package:flutter/foundation.dart";
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
      await _uploadRow(row);
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

  /// Wipes everything logged for [subjectId], which is what "delete data" on an
  /// activity needs so its history (and, for a group activity, the user's share
  /// of the ranking) really goes.
  ///
  /// Sessions still waiting to upload are dropped at once. The delete on the
  /// backend runs in the background: it is remembered first, with the moment it
  /// was asked for, and retried by [flushPendingSync] until it goes through, so
  /// a bad connection never holds the screen up. It only removes rows up to
  /// that moment, so a session logged afterwards survives.
  Future<Either<AppError, void>> clearSubjectEntries(String subjectId) async {
    try {
      await _dropQueuedEntriesFor(subjectId);
      if (_supabaseService.currentUserId == null) {
        return const Right(null);
      }
      await _enqueueClear(subjectId, DateTime.now().toUtc());
      unawaited(flushPendingSync());
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  /// Re-attempts any focus sessions that failed to reach the backend
  /// earlier, after the deletes waiting to reach it. No-op when nothing is
  /// pending.
  Future<void> flushPendingSync() async {
    if (!_pendingSyncStore.contains(PendingSyncDataset.activityEntries)) {
      return;
    }
    if (!await _flushPendingClears()) {
      return;
    }
    List<Map<String, dynamic>> queue = await _readQueue();
    if (queue.isEmpty) {
      await _pendingSyncStore.clear(PendingSyncDataset.activityEntries);
      return;
    }
    // Saved before uploading so a retry reuses the repaired ids.
    final ({List<Map<String, dynamic>> rows, bool changed}) repaired =
        repairLegacyActivityRows(queue);
    if (repaired.changed) {
      queue = repaired.rows;
      await _writeQueue(queue);
    }
    try {
      for (final Map<String, dynamic> row in queue) {
        await _uploadRow(row);
      }
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

  static final RegExp _uuidPattern = RegExp(
    r"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-"
    r"[0-9a-fA-F]{12}$",
  );
  static final RegExp _legacyIdTimestamp = RegExp(r"^(\d{16})-");

  /// Builds already queued with the old `<microseconds>-<random>` id were
  /// rejected by the uuid column (`22P02`), which that build treated as
  /// "offline" and queued, and the whole batch then failed on them forever.
  /// The id is only an idempotency key and those rows never reached the
  /// backend, so they get a fresh UUID. The old id embedded the moment of the
  /// session, which is kept as `occurred_at` so the group rankings still date
  /// the session correctly.
  @visibleForTesting
  static ({List<Map<String, dynamic>> rows, bool changed})
  repairLegacyActivityRows(List<Map<String, dynamic>> rows) {
    bool changed = false;
    final List<Map<String, dynamic>> repaired = [];
    for (final Map<String, dynamic> row in rows) {
      if (_uuidPattern.hasMatch(row["id"]?.toString() ?? "")) {
        repaired.add(row);
      } else {
        repaired.add(_repairedRow(row));
        changed = true;
      }
    }
    return (rows: repaired, changed: changed);
  }

  static Map<String, dynamic> _repairedRow(Map<String, dynamic> row) {
    final Map<String, dynamic> fixed = Map<String, dynamic>.of(row)
      ..["id"] = generateUuidV4();
    if (fixed["occurred_at"] == null) {
      final DateTime? sessionTime = _timeFromLegacyId(row["id"]?.toString());
      if (sessionTime != null) {
        fixed["occurred_at"] = sessionTime.toIso8601String();
      }
    }
    return fixed;
  }

  static DateTime? _timeFromLegacyId(String? legacyId) {
    final String? micros = _legacyIdTimestamp
        .firstMatch(legacyId ?? "")
        ?.group(1);
    if (micros == null) {
      return null;
    }
    final DateTime time = DateTime.fromMicrosecondsSinceEpoch(
      int.parse(micros),
      isUtc: true,
    );
    final DateTime now = DateTime.now().toUtc();
    final bool plausible =
        time.year >= 2020 && time.isBefore(now.add(const Duration(days: 1)));
    return plausible ? time : null;
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
          await _uploadRow(row);
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

  Future<void> _dropQueuedEntriesFor(String subjectId) async {
    final List<Map<String, dynamic>> queue = await _readQueue();
    final List<Map<String, dynamic>> kept = [
      for (final Map<String, dynamic> row in queue)
        if (row["subject_id"] != subjectId) row,
    ];
    if (kept.length != queue.length) {
      await _writeQueue(kept);
    }
  }

  Future<Map<String, String>> _readClears() async {
    final String? saved = await _localStorageService.read<String?>(
      LocalStorageKeys.pendingActivityClears,
    );
    if (saved == null) {
      return {};
    }
    try {
      return (jsonDecode(saved) as Map<String, dynamic>).cast<String, String>();
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeClears(Map<String, String> clears) => _localStorageService
      .write(LocalStorageKeys.pendingActivityClears, jsonEncode(clears));

  Future<void> _enqueueClear(String subjectId, DateTime clearedAt) async {
    final Map<String, String> clears = await _readClears();
    final DateTime? previous = DateTime.tryParse(clears[subjectId] ?? "");
    if (previous == null || previous.isBefore(clearedAt)) {
      clears[subjectId] = clearedAt.toIso8601String();
    }
    await _writeClears(clears);
    await _pendingSyncStore.markPending(PendingSyncDataset.activityEntries);
  }

  /// Sends the deletes that are waiting. Returns whether none are left, so the
  /// caller knows it can go on to the sessions queued after them; a transient
  /// failure leaves the rest for the next attempt.
  Future<bool> _flushPendingClears() async {
    final Map<String, String> clears = await _readClears();
    final String? userId = _supabaseService.currentUserId;
    if (clears.isEmpty) {
      return true;
    }
    if (userId == null) {
      return false;
    }

    bool deletedAny = false;
    for (final MapEntry<String, String> clear in Map.of(clears).entries) {
      try {
        await _supabaseService.requireClient
            .from("activity_entries")
            .delete()
            .eq("user_id", userId)
            .eq("subject_id", clear.key)
            .lte("occurred_at", clear.value)
            .timeout(_remoteCallTimeout);
        clears.remove(clear.key);
        deletedAny = true;
      } catch (error, stackTrace) {
        _logger.logError(
          "Failed to delete activity_entries of ${clear.key}",
          error: error,
          stackTrace: stackTrace,
        );
        if (isPermanentSyncFailure(error)) {
          // Retrying a delete the server refuses would block every session
          // queued behind it.
          clears.remove(clear.key);
        } else {
          await _writeClears(clears);
          return false;
        }
      }
    }
    await _writeClears(clears);
    if (deletedAny) {
      _activityChangeBus?.notifyGroupActivityChanged();
    }
    return true;
  }

  Future<void> _enqueuePending(Map<String, dynamic> row) async {
    final List<Map<String, dynamic>> queue = await _readQueue();
    queue.add(row);
    await _writeQueue(queue);
    await _pendingSyncStore.markPending(PendingSyncDataset.activityEntries);
  }

  Future<void> _uploadRow(Map<String, dynamic> row) => _supabaseService
      .requireClient
      .rpc(
        "record_activity_entry",
        params: {
          "entry_id": row["id"],
          "entry_category": row["category"],
          "entry_subject_id": row["subject_id"],
          "entry_subject_name": row["subject_name"],
          "entry_seconds": row["seconds"],
          "entry_pages": row["pages"],
          "entry_completed_tasks": row["completed_tasks"],
          "entry_occurred_at": row["occurred_at"],
        },
      )
      .timeout(_remoteCallTimeout);

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

  /// The server caps a response at 1000 rows and the timer logs a row every
  /// autosave, so a few hours of focus already exceed one page. Reading only
  /// the first page (ordered oldest first) silently dropped the most recent
  /// days, so the history is read page by page until a short page.
  static const int _entriesPageSize = 1000;
  static const int _maxEntryPages = 60;

  Future<Either<AppError, List<ActivityEntryEntity>>> getActivityEntries({
    int retentionDays = 400,
  }) async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      final String cutoff = DateTime.now()
          .toUtc()
          .subtract(Duration(days: retentionDays))
          .toIso8601String();
      final List<ActivityEntryEntity> entries = [];
      for (int page = 0; page < _maxEntryPages; page++) {
        final int from = page * _entriesPageSize;
        final List<dynamic> rows = await _supabaseService.requireClient
            .from("activity_entries")
            .select(
              "id, category, subject_id, subject_name, occurred_at, "
              "seconds, pages, completed_tasks",
            )
            .eq("user_id", userId)
            .gte("occurred_at", cutoff)
            // id breaks ties so rows sharing a timestamp are never skipped or
            // repeated across page boundaries.
            .order("occurred_at")
            .order("id")
            .range(from, from + _entriesPageSize - 1)
            .timeout(_remoteCallTimeout);
        entries.addAll(
          rows
              .map((row) => _entryFromRow(row as Map<String, dynamic>))
              .where(
                (entry) =>
                    entry.seconds > 0 ||
                    entry.pages > 0 ||
                    entry.completedTasks > 0,
              ),
        );
        if (rows.length < _entriesPageSize) {
          break;
        }
      }
      return Right(entries);
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
