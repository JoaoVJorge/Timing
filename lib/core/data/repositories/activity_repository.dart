import "dart:async";
import "dart:convert";

import "package:dartz/dartz.dart";
import "package:flutter/foundation.dart";
import "package:timing/core/data/data_sources/activity_data_source.dart";
import "package:timing/core/data/errors/backend_error.dart";
import "package:timing/core/domain/entities/activity_entry_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/core/services/sync/offline_action_queue.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";
import "package:timing/core/services/sync/sync_error_classifier.dart";
import "package:timing/core/utils/id_generator.dart";

/// The log of focus sessions, pages and completed tasks. Owns what happens
/// when the backend cannot be reached: sessions, deletes and removed time are
/// remembered on the device and sent by [flushPendingSync], in that order.
class ActivityRepository {
  ActivityRepository({
    required this._activityDataSource,
    required this._localStorageService,
    required this._pendingSyncStore,
    required this._logger,
    this._activityChangeBus,
    this._isBackendReachable,
  }) : _pendingEntries = OfflineActionQueue(
         localStorageService: _localStorageService,
         pendingSyncStore: _pendingSyncStore,
         logger: _logger,
         storageKey: LocalStorageKeys.pendingActivityEntries,
         dataset: PendingSyncDataset.activityEntries,
         label: "activity_entries row",
       ),
       _pendingRemovals = OfflineActionQueue(
         localStorageService: _localStorageService,
         pendingSyncStore: _pendingSyncStore,
         logger: _logger,
         storageKey: LocalStorageKeys.pendingActivityRemovals,
         dataset: PendingSyncDataset.activityEntries,
         label: "removed-time request",
       );

  final ActivityDataSource _activityDataSource;
  final AppLocalStorageService _localStorageService;
  final PendingSyncStore _pendingSyncStore;
  final AppLoggerService _logger;
  final ActivityChangeBus? _activityChangeBus;

  /// The app's connectivity flag: a failed upload is only queued when it says
  /// offline or the failure is not a definitive server rejection.
  final bool Function()? _isBackendReachable;

  /// Sessions waiting to upload, and the time taken back off by hand. Both
  /// share the dataset's pending mark with the deletes, so this repository
  /// decides when the dataset is clean again.
  final OfflineActionQueue _pendingEntries;
  final OfflineActionQueue _pendingRemovals;

  /// Records one focus-session row. Unlike subjects/schedule/dailyTasks this
  /// is an append-only log, not a "resync current state" entity, so a failed
  /// upload is queued individually (not replaced by the next write) and
  /// retried later via [flushPendingSync]. The row's `id` is generated on the
  /// client so a retry cannot duplicate it. `activity_entries.id` is a
  /// Postgres `uuid` column (unlike the text ids subjects/schedule/dailyTasks
  /// use), so it needs [generateUuidV4] rather than [generateEntityId].
  Future<Either<AppError, void>> logActivity({
    required TimeCategoryType category,
    required String subjectId,
    required String subjectName,
    int seconds = 0,
    int pages = 0,
    int completedTasks = 0,
  }) async {
    final String? userId = _activityDataSource.currentUserId;
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
      await _activityDataSource.uploadEntry(row);
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
        return Left(toAppError(error, stackTrace));
      }
      await _pendingEntries.enqueue(row);
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
      if (_activityDataSource.currentUserId == null) {
        return const Right(null);
      }
      await _enqueueClear(subjectId, DateTime.now().toUtc());
      unawaited(flushPendingSync());
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(LocalDataError(cause: error, stackTrace: stackTrace));
    }
  }

  /// Takes [seconds] back off the newest sessions logged for [subjectId], so
  /// the group rankings and the user's other devices stop counting time that
  /// was removed by hand.
  ///
  /// Like a delete, the request is remembered first and sent by
  /// [flushPendingSync], after every session still waiting to upload: the
  /// backend can only shorten sessions it has. It carries an id, so a request
  /// repeated after a lost answer is applied once, and the moment it was made,
  /// so a session logged afterwards is left alone.
  Future<Either<AppError, void>> removeSubjectSeconds({
    required String subjectId,
    required int seconds,
  }) async {
    try {
      if (_activityDataSource.currentUserId == null || seconds <= 0) {
        return const Right(null);
      }
      await _pendingRemovals.enqueue({
        "id": generateUuidV4(),
        "subject_id": subjectId,
        "seconds": seconds,
        "removed_at": DateTime.now().toUtc().toIso8601String(),
      });
      unawaited(flushPendingSync());
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(LocalDataError(cause: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, List<ActivityEntryEntity>>> getActivityEntries({
    int retentionDays = 400,
  }) async {
    final String? userId = _activityDataSource.currentUserId;
    if (userId == null) {
      return const Right([]);
    }
    return guardBackendCall(
      () => _activityDataSource.fetchEntries(
        userId: userId,
        retentionDays: retentionDays,
      ),
    );
  }

  /// Re-attempts any focus sessions that failed to reach the backend
  /// earlier, after the deletes waiting to reach it, and then the time removed
  /// by hand. No-op when nothing is pending.
  Future<void> flushPendingSync() async {
    if (!_pendingSyncStore.contains(PendingSyncDataset.activityEntries)) {
      return;
    }
    if (!await _flushPendingClears()) {
      return;
    }
    List<Map<String, dynamic>> queue = await _pendingEntries.read();
    if (queue.isEmpty) {
      await _flushRemovalsAndFinish();
      return;
    }
    // Saved before uploading so a retry reuses the repaired ids.
    final ({List<Map<String, dynamic>> rows, bool changed}) repaired =
        repairLegacyActivityRows(queue);
    if (repaired.changed) {
      queue = repaired.rows;
      await _pendingEntries.write(queue);
    }

    final OfflineReplayResult result = await _pendingEntries.replay(
      queue,
      _activityDataSource.uploadEntry,
    );
    final List<Map<String, dynamic>> remaining = queue.sublist(
      result.processed,
    );
    await _pendingEntries.write(remaining);
    if (result.applied > 0) {
      _activityChangeBus?.notifyGroupActivityChanged();
    }
    if (remaining.isEmpty) {
      await _flushRemovalsAndFinish();
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

  /// The last step of a flush, once every queued session is on the backend.
  /// Nothing is left waiting only when the removed time went through too.
  Future<void> _flushRemovalsAndFinish() async {
    if (await _flushPendingRemovals()) {
      await _pendingSyncStore.clear(PendingSyncDataset.activityEntries);
    }
  }

  /// Sends the removed time that is waiting, oldest request first. Returns
  /// whether none is left; a transient failure keeps the rest for the next
  /// attempt.
  Future<bool> _flushPendingRemovals() async {
    final List<Map<String, dynamic>> removals = await _pendingRemovals.read();
    if (removals.isEmpty) {
      return true;
    }

    final OfflineReplayResult result = await _pendingRemovals.replay(
      removals,
      _activityDataSource.removeSeconds,
    );
    final Set<String> handled = {
      for (final Map<String, dynamic> removal in removals.take(
        result.processed,
      ))
        removal["id"] as String,
    };

    // Read again rather than writing back what was read: a removal asked for
    // while these were being sent must not be lost.
    final List<Map<String, dynamic>> remaining = [
      for (final Map<String, dynamic> removal in await _pendingRemovals.read())
        if (!handled.contains(removal["id"])) removal,
    ];
    await _pendingRemovals.write(remaining);
    if (handled.isNotEmpty) {
      _activityChangeBus?.notifyGroupActivityChanged();
    }
    return remaining.isEmpty;
  }

  Future<void> _dropQueuedEntriesFor(String subjectId) async {
    final List<Map<String, dynamic>> queue = await _pendingEntries.read();
    final List<Map<String, dynamic>> kept = [
      for (final Map<String, dynamic> row in queue)
        if (row["subject_id"] != subjectId) row,
    ];
    if (kept.length != queue.length) {
      await _pendingEntries.write(kept);
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
    final String? userId = _activityDataSource.currentUserId;
    if (clears.isEmpty) {
      return true;
    }
    if (userId == null) {
      return false;
    }

    bool deletedAny = false;
    for (final MapEntry<String, String> clear in Map.of(clears).entries) {
      try {
        await _activityDataSource.deleteSubjectEntries(
          userId: userId,
          subjectId: clear.key,
          until: clear.value,
        );
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
}
