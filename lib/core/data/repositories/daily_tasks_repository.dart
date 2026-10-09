import "dart:async";
import "dart:convert";

import "package:dartz/dartz.dart";
import "package:flutter/foundation.dart";
import "package:timing/core/data/data_sources/daily_tasks_data_source.dart";
import "package:timing/core/data/errors/backend_error.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

/// The user's daily goals. The list on the device is what the app reads and
/// writes; a save returns as soon as it is stored and is uploaded behind it,
/// the account's copy is merged in when it has not been read recently, and a
/// save that could not reach the backend stays pending for
/// [flushPendingSync].
class DailyTasksRepository {
  DailyTasksRepository({
    required this._dailyTasksDataSource,
    required this._localStorageService,
    required this._logger,
    required this._pendingSyncStore,
    this._activityChangeBus,
    this._isBackendReachable,
  });

  /// Lets reads skip the remote refresh when the app already knows the backend
  /// is unreachable, instead of waiting out the request's timeout on every
  /// screen that reloads the daily tasks.
  final bool Function()? _isBackendReachable;

  final ActivityChangeBus? _activityChangeBus;

  final DailyTasksDataSource _dailyTasksDataSource;
  final AppLocalStorageService _localStorageService;
  final AppLoggerService _logger;
  final PendingSyncStore _pendingSyncStore;
  Future<void> _mutationTail = Future<void>.value();
  Future<void> _remoteSyncTail = Future<void>.value();
  int _latestRemoteSyncRevision = 0;
  String? _hydratedRemoteUserId;

  /// Ids the backend is known to hold for the current user: those read from it,
  /// plus those this device uploaded. Only these are ever deleted remotely, so
  /// a goal another phone created after this one last read the account is
  /// never mistaken for one the user removed.
  Set<String> _remoteKnownIds = {};
  DateTime? _lastRemoteReadAt;

  /// Each screen that lists the goals asks for them again, and a read that
  /// happened moments ago (or this device's own upload) makes another one
  /// redundant. Cross-device changes reach the app at start-up and resume
  /// anyway, so a short window only delays them slightly.
  static const Duration _remoteReadFreshness = Duration(seconds: 45);

  final StreamController<List<DailyTaskEntity>> _localTasksChanges =
      StreamController<List<DailyTaskEntity>>.broadcast();

  /// The goals as they were just written to this device, whether by a user
  /// action or by merging in the account's copy. Goal reminders follow it so
  /// they are rescheduled from wherever the goals change.
  Stream<List<DailyTaskEntity>> get onLocalTasksChanged =>
      _localTasksChanges.stream;

  bool get hasHydratedCurrentUserFromRemote {
    final String? userId = _dailyTasksDataSource.currentUserId;
    return userId == null || _hydratedRemoteUserId == userId;
  }

  @visibleForTesting
  bool canDeleteRemoteTasks(String userId) => _hydratedRemoteUserId == userId;

  bool get _hasFreshRemoteRead {
    final DateTime? last = _lastRemoteReadAt;
    return last != null &&
        DateTime.now().difference(last) < _remoteReadFreshness &&
        _hydratedRemoteUserId == _dailyTasksDataSource.currentUserId;
  }

  /// Serializes complete read-modify-write operations so two UI actions cannot
  /// persist competing snapshots of the daily-goals collection.
  ///
  /// Mutations passed here must not call another serialized mutation on this
  /// repository: a nested call would wait for its own outer operation.
  Future<T> runSerializedMutation<T>(Future<T> Function() mutation) {
    final Future<T> scheduled = _mutationTail.then((_) => mutation());
    _mutationTail = scheduled.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return scheduled;
  }

  /// Reads the account's copy again the next time, whatever was read moments
  /// ago: linking a group activity changes the goals on the backend.
  Future<void> refreshAfterGroupLinkChange() async {
    _lastRemoteReadAt = null;
    await _readTasks();
  }

  /// The goals, with the account's copy merged in when it has not been read
  /// recently. Waits for any mutation in progress.
  Future<Either<AppError, List<DailyTaskEntity>>> getTasks() =>
      runSerializedMutation(_readTasks);

  Future<Either<AppError, List<DailyTaskEntity>>> getLocalTasks() async {
    try {
      final String? savedTasks = await _localStorageService.read<String?>(
        LocalStorageKeys.dailyTasks,
      );
      if (savedTasks == null) {
        return const Right([]);
      }
      return Right(_decodeTasks(savedTasks));
    } catch (error, stackTrace) {
      return Left(LocalDataError(cause: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, List<DailyTaskEntity>>> _readTasks() async {
    try {
      final String? savedTasks = await _localStorageService.read<String?>(
        LocalStorageKeys.dailyTasks,
      );

      if (savedTasks == null) {
        final List<DailyTaskEntity> remoteTasks = await _getRemoteTasks();
        if (remoteTasks.isNotEmpty) {
          await _saveLocalTasks(remoteTasks);
          await _writeSyncedIds({
            for (final DailyTaskEntity task in remoteTasks) task.id,
          });
        }
        return Right(remoteTasks);
      }

      final List<DailyTaskEntity> localTasks = _decodeTasks(savedTasks);
      if (!_pendingSyncStore.contains(PendingSyncDataset.dailyTasks) &&
          !_hasFreshRemoteRead) {
        final List<DailyTaskEntity> remoteTasks = await _getRemoteTasks();
        if (remoteTasks.isNotEmpty) {
          final List<DailyTaskEntity> mergedTasks = await _mergeRemoteRead(
            localTasks: localTasks,
            remoteTasks: remoteTasks,
          );
          await _saveLocalTasks(mergedTasks);
          return Right(mergedTasks);
        }
      }

      return Right(localTasks);
    } catch (error, stackTrace) {
      return Left(LocalDataError(cause: error, stackTrace: stackTrace));
    }
  }

  /// Ensures a full remote snapshot was observed before a read-modify-write.
  /// If the network is unavailable, callers may still update the local cache,
  /// but [_syncRemoteTasks] will refuse to issue remote deletes.
  ///
  /// Must be called from inside [runSerializedMutation].
  Future<Either<AppError, List<DailyTaskEntity>>> getTasksForMutation() async {
    if (hasHydratedCurrentUserFromRemote) {
      return getLocalTasks();
    }

    try {
      final String? savedTasks = await _localStorageService.read<String?>(
        LocalStorageKeys.dailyTasks,
      );
      final List<DailyTaskEntity> localTasks = savedTasks == null
          ? const []
          : _decodeTasks(savedTasks);
      final List<DailyTaskEntity> remoteTasks = await _getRemoteTasks();
      if (!hasHydratedCurrentUserFromRemote) {
        return Right(localTasks);
      }
      final List<DailyTaskEntity> mergedTasks = await _mergeRemoteRead(
        localTasks: localTasks,
        remoteTasks: remoteTasks,
      );
      await _saveLocalTasks(mergedTasks);
      return Right(mergedTasks);
    } catch (error, stackTrace) {
      return Left(LocalDataError(cause: error, stackTrace: stackTrace));
    }
  }

  /// Merges a read of the account into the list on this device, and records
  /// which goals the backend held: one of those missing from a later read was
  /// deleted elsewhere.
  Future<List<DailyTaskEntity>> _mergeRemoteRead({
    required List<DailyTaskEntity> localTasks,
    required List<DailyTaskEntity> remoteTasks,
  }) async {
    final List<DailyTaskEntity> mergedTasks = mergeTasks(
      localTasks: localTasks,
      remoteTasks: remoteTasks,
      syncedIds: await _readSyncedIds(),
    );
    if (remoteTasks.isNotEmpty) {
      await _writeSyncedIds({
        for (final DailyTaskEntity task in remoteTasks) task.id,
      });
    }
    return mergedTasks;
  }

  Future<Set<String>> _readSyncedIds() async {
    final String? saved = await _localStorageService.read<String?>(
      LocalStorageKeys.syncedDailyTaskIds,
    );
    if (saved == null) {
      return {};
    }
    try {
      return (jsonDecode(saved) as List<dynamic>).cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeSyncedIds(Set<String> ids) => _localStorageService.write(
    LocalStorageKeys.syncedDailyTaskIds,
    jsonEncode(ids.toList()),
  );

  Future<Either<AppError, void>> saveTasks(List<DailyTaskEntity> tasks) async {
    try {
      final bool shouldSync = _dailyTasksDataSource.currentUserId != null;
      if (shouldSync) {
        await _pendingSyncStore.markPending(PendingSyncDataset.dailyTasks);
      }
      final String encoded = jsonEncode(
        tasks.map((task) => task.toMap()).toList(),
      );
      await _localStorageService.write(LocalStorageKeys.dailyTasks, encoded);
      _localTasksChanges.add(List.unmodifiable(tasks));
      if (shouldSync) {
        unawaited(_enqueueRemoteSync(tasks));
      }
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(toAppError(error, stackTrace));
    }
  }

  Future<void> _saveLocalTasks(List<DailyTaskEntity> tasks) async {
    final String encoded = jsonEncode(
      tasks.map((task) => task.toMap()).toList(),
    );
    await _localStorageService.write(LocalStorageKeys.dailyTasks, encoded);
    _localTasksChanges.add(List.unmodifiable(tasks));
  }

  List<DailyTaskEntity> _decodeTasks(String encoded) {
    final List<dynamic> decoded = jsonDecode(encoded) as List<dynamic>;
    return decoded
        .map((item) => DailyTaskEntity.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _enqueueRemoteSync(List<DailyTaskEntity> tasks) {
    final List<DailyTaskEntity> snapshot = List.of(tasks);
    final int revision = ++_latestRemoteSyncRevision;
    final Future<void> scheduled = _remoteSyncTail.then(
      (_) => _syncRemoteTasks(snapshot, revision: revision),
    );
    _remoteSyncTail = scheduled.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return scheduled;
  }

  /// Local and remote views of one account's goals, merged:
  ///  * a goal only the backend has (created on another phone) is added;
  ///  * one this device holds that the backend once had but no longer does was
  ///    deleted elsewhere, and is dropped, as is a leftover group-owned copy
  ///    the backend does not hold: those only ever came from the backend, and
  ///    it rejects the upload of one. A goal the backend never had is new here
  ///    and kept;
  ///  * for the rest the more recently changed copy wins.
  @visibleForTesting
  List<DailyTaskEntity> mergeTasks({
    required List<DailyTaskEntity> localTasks,
    required List<DailyTaskEntity> remoteTasks,
    Set<String> syncedIds = const {},
  }) {
    // An empty answer is as likely to be an unauthenticated or filtered read as
    // a genuinely empty account, and acting on it would drop every goal this
    // device holds.
    if (remoteTasks.isEmpty) {
      return List.of(localTasks);
    }
    final Set<String> remoteIds = {
      for (final DailyTaskEntity remote in remoteTasks) remote.id,
    };
    final Map<String, DailyTaskEntity> byId = <String, DailyTaskEntity>{};
    for (final DailyTaskEntity local in localTasks) {
      final DailyTaskEntity? linkedRemote = _linkedRemoteCopyOf(
        local,
        remoteTasks,
      );
      if (linkedRemote == null) {
        final bool wasDeletedElsewhere =
            !remoteIds.contains(local.id) &&
            (syncedIds.contains(local.id) || local.isFromGroup);
        if (!wasDeletedElsewhere) {
          byId[local.id] = local;
        }
        continue;
      }
      byId[linkedRemote.id] = _mergeGroupTaskCopy(local, linkedRemote);
    }
    for (final DailyTaskEntity remote in remoteTasks) {
      final DailyTaskEntity? local = byId[remote.id];
      // Last-write-wins: keep the more recently mutated copy so a local change
      // that hasn't finished syncing is not clobbered by a stale remote read.
      if (local == null || _isNewer(remote, local)) {
        byId[remote.id] = remote;
      } else if (local.isFromGroup && !remote.isFromGroup) {
        byId[remote.id] = local.copyWith(clearGroupLink: true);
      }
    }
    return byId.values.toList();
  }

  DailyTaskEntity? _linkedRemoteCopyOf(
    DailyTaskEntity local,
    List<DailyTaskEntity> remoteTasks,
  ) {
    for (final DailyTaskEntity remote in remoteTasks) {
      if (_isLinkedRemoteCopyOf(local, remote)) {
        return remote;
      }
    }
    return null;
  }

  bool _isLinkedRemoteCopyOf(DailyTaskEntity local, DailyTaskEntity remote) =>
      local.id != remote.id &&
      local.isFromGroup &&
      local.groupActivityId == null &&
      remote.groupId == local.groupId &&
      remote.groupActivityId != null &&
      remote.name.trim().toLowerCase() == local.name.trim().toLowerCase() &&
      remote.targetDays == local.targetDays &&
      remote.sequenceType == local.sequenceType &&
      remote.goalType == local.goalType;

  DailyTaskEntity _mergeGroupTaskCopy(
    DailyTaskEntity local,
    DailyTaskEntity linkedRemote,
  ) {
    final Set<String> completedDates = <String>{
      ...linkedRemote.completedDates,
      ...local.completedDates,
    };
    return linkedRemote.copyWith(
      completedDates: completedDates.toList()..sort(),
      updatedAt: _newerDate(linkedRemote.updatedAt, local.updatedAt),
    );
  }

  DateTime? _newerDate(DateTime? a, DateTime? b) {
    if (a == null) {
      return b;
    }
    if (b == null) {
      return a;
    }
    return a.isAfter(b) ? a : b;
  }

  bool _isNewer(DailyTaskEntity candidate, DailyTaskEntity current) {
    final DateTime? candidateAt = candidate.updatedAt;
    final DateTime? currentAt = current.updatedAt;
    if (candidateAt == null) {
      return false;
    }
    if (currentAt == null) {
      return true;
    }
    return candidateAt.isAfter(currentAt);
  }

  Future<List<DailyTaskEntity>> _getRemoteTasks() async {
    final String? userId = _dailyTasksDataSource.currentUserId;
    if (userId == null || !(_isBackendReachable?.call() ?? true)) {
      return const [];
    }

    try {
      final List<DailyTaskEntity> tasks = await _dailyTasksDataSource
          .fetchTasks(userId);
      _hydratedRemoteUserId = userId;
      _lastRemoteReadAt = DateTime.now();
      _remoteKnownIds = {for (final DailyTaskEntity task in tasks) task.id};
      return tasks;
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to fetch remote daily_goals",
        error: error,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  Future<void> _syncRemoteTasks(
    List<DailyTaskEntity> tasks, {
    required int revision,
  }) async {
    final String? userId = _dailyTasksDataSource.currentUserId;
    if (userId == null) {
      return;
    }

    try {
      if (tasks.isNotEmpty) {
        await _dailyTasksDataSource.upsertTasks(userId: userId, tasks: tasks);
        _remoteKnownIds.addAll(tasks.map((task) => task.id));
        await _writeSyncedIds({
          ...await _readSyncedIds(),
          ...tasks.map((task) => task.id),
        });
        // What was just uploaded is what the backend holds, so it also counts
        // as a fresh read for the screens that reload the goals next.
        _lastRemoteReadAt = DateTime.now();
        // Local saves return before this upload completes. Refresh shared
        // rankings only after the server has received the completed days.
        _activityChangeBus?.notifyGroupActivityChanged();
      }

      if (!canDeleteRemoteTasks(userId)) {
        _logger.logInfo(
          "Skipping remote daily_goals deletion before a complete read",
        );
        return;
      }

      final Set<String> localIds = tasks.map((task) => task.id).toSet();
      final List<String> removed = _remoteKnownIds
          .difference(localIds)
          .toList();
      if (removed.isNotEmpty) {
        await _dailyTasksDataSource.deleteTasks(userId: userId, ids: removed);
        _remoteKnownIds.removeAll(removed);
        await _writeSyncedIds(
          (await _readSyncedIds()).difference(removed.toSet()),
        );
        _activityChangeBus?.notifyGroupActivityChanged();
      }
      // A newer local snapshot may already be waiting behind this request.
      // Only the latest successful upload makes the dataset fully synced.
      if (revision == _latestRemoteSyncRevision) {
        await _pendingSyncStore.clear(PendingSyncDataset.dailyTasks);
      }
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to sync remote daily_goals",
        error: error,
        stackTrace: stackTrace,
      );
      await _pendingSyncStore.markPending(PendingSyncDataset.dailyTasks);
      return;
    }
  }

  /// Re-attempts a previously failed remote sync using the current local
  /// state. No-op when nothing is pending for this dataset.
  Future<void> flushPendingSync() async {
    if (!_pendingSyncStore.contains(PendingSyncDataset.dailyTasks)) {
      return;
    }
    final Either<AppError, List<DailyTaskEntity>> hydrated =
        await getTasksForMutation();
    await hydrated.fold((_) async {}, _enqueueRemoteSync);
  }
}
