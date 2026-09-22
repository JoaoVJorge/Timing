import "dart:async";
import "dart:convert";

import "package:dartz/dartz.dart";
import "package:flutter/foundation.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";

class DailyTasksDataSource {
  DailyTasksDataSource({
    required this._localStorageService,
    required this._supabaseService,
    required this._logger,
    required this._pendingSyncStore,
    this._activityChangeBus,
  });

  final ActivityChangeBus? _activityChangeBus;

  final AppLocalStorageService _localStorageService;
  final SupabaseService _supabaseService;
  final AppLoggerService _logger;
  final PendingSyncStore _pendingSyncStore;
  Future<void> _remoteSyncTail = Future<void>.value();
  int _latestRemoteSyncRevision = 0;
  String? _hydratedRemoteUserId;

  bool get hasHydratedCurrentUserFromRemote {
    final String? userId = _supabaseService.currentUserId;
    return userId == null || _hydratedRemoteUserId == userId;
  }

  @visibleForTesting
  bool canDeleteRemoteTasks(String userId) => _hydratedRemoteUserId == userId;

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
      return Left(SerializationAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, List<DailyTaskEntity>>> getTasks() async {
    try {
      final String? savedTasks = await _localStorageService.read<String?>(
        LocalStorageKeys.dailyTasks,
      );

      if (savedTasks == null) {
        final List<DailyTaskEntity> remoteTasks = await _getRemoteTasks();
        if (remoteTasks.isNotEmpty) {
          await _saveLocalTasks(remoteTasks);
        }
        return Right(remoteTasks);
      }

      final List<DailyTaskEntity> localTasks = _decodeTasks(savedTasks);
      if (!_pendingSyncStore.contains(PendingSyncDataset.dailyTasks)) {
        final List<DailyTaskEntity> remoteTasks = await _getRemoteTasks();
        if (remoteTasks.isNotEmpty) {
          final List<DailyTaskEntity> mergedTasks = mergeTasks(
            localTasks: localTasks,
            remoteTasks: remoteTasks,
          );
          await _saveLocalTasks(mergedTasks);
          return Right(mergedTasks);
        }
      }

      return Right(localTasks);
    } catch (error, stackTrace) {
      return Left(SerializationAppError(error: error, stackTrace: stackTrace));
    }
  }

  /// Ensures a full remote snapshot was observed before a read-modify-write.
  /// If the network is unavailable, callers may still update the local cache,
  /// but [_syncRemoteTasks] will refuse to issue remote deletes.
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
      final List<DailyTaskEntity> mergedTasks = mergeTasks(
        localTasks: localTasks,
        remoteTasks: remoteTasks,
      );
      await _saveLocalTasks(mergedTasks);
      return Right(mergedTasks);
    } catch (error, stackTrace) {
      return Left(SerializationAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> saveTasks(List<DailyTaskEntity> tasks) async {
    try {
      final bool shouldSync = _supabaseService.currentUserId != null;
      if (shouldSync) {
        await _pendingSyncStore.markPending(PendingSyncDataset.dailyTasks);
      }
      final String encoded = jsonEncode(
        tasks.map((task) => task.toMap()).toList(),
      );
      await _localStorageService.write(LocalStorageKeys.dailyTasks, encoded);
      if (shouldSync) {
        unawaited(_enqueueRemoteSync(tasks));
      }
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<void> _saveLocalTasks(List<DailyTaskEntity> tasks) async {
    final String encoded = jsonEncode(
      tasks.map((task) => task.toMap()).toList(),
    );
    await _localStorageService.write(LocalStorageKeys.dailyTasks, encoded);
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

  @visibleForTesting
  List<DailyTaskEntity> mergeTasks({
    required List<DailyTaskEntity> localTasks,
    required List<DailyTaskEntity> remoteTasks,
  }) {
    final Map<String, DailyTaskEntity> byId = <String, DailyTaskEntity>{};
    for (final DailyTaskEntity local in localTasks) {
      final DailyTaskEntity? linkedRemote = _linkedRemoteCopyOf(
        local,
        remoteTasks,
      );
      if (linkedRemote == null) {
        byId[local.id] = local;
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
    final String? userId = _supabaseService.currentUserId;
    if (userId == null) {
      return const [];
    }

    try {
      final List<dynamic> rows = await _supabaseService.requireClient
          .from("daily_goals")
          .select()
          .eq("user_id", userId)
          .order("created_at");
      _logger.logResponse("select public.daily_goals", rows);
      _hydratedRemoteUserId = userId;

      return rows
          .map((row) => _taskFromRow(row as Map<String, dynamic>))
          .toList();
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
    final String? userId = _supabaseService.currentUserId;
    if (userId == null) {
      return;
    }

    try {
      final client = _supabaseService.requireClient;
      final List<Map<String, dynamic>> rows = tasks
          .map((task) => _taskToRow(task, userId))
          .toList();

      if (rows.isNotEmpty) {
        await client.from("daily_goals").upsert(rows, onConflict: "user_id,id");
        // Local saves return before this upload completes. Refresh shared
        // rankings only after the server has received the completed days.
        if (tasks.any((task) => task.isFromGroup)) {
          _activityChangeBus?.notifyGroupActivityChanged();
        }
      }

      if (!canDeleteRemoteTasks(userId)) {
        _logger.logInfo(
          "Skipping remote daily_goals deletion before a complete read",
        );
        return;
      }

      final List<String> ids = tasks.map((task) => task.id).toList();
      var delete = client.from("daily_goals").delete().eq("user_id", userId);
      if (ids.isNotEmpty) {
        delete = delete.not("id", "in", "(${ids.join(",")})");
      }
      await delete;
      _activityChangeBus?.notifyGroupActivityChanged();
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

  DailyTaskEntity _taskFromRow(Map<String, dynamic> row) =>
      DailyTaskEntity.fromMap({
        "id": row["id"],
        "name": row["name"],
        "colorValue": (row["color_value"] as num?)?.toInt() ?? 0,
        "targetDays": (row["target_days"] as num?)?.toInt() ?? 0,
        "completedDates": row["completed_dates"] as List<dynamic>? ?? [],
        "sequenceType": row["sequence_type"] ?? row["goal_type"],
        "lastResolvedMissedDate": row["last_resolved_missed_date"],
        "goalType": row["goal_type"],
        "updatedAt": row["updated_at"],
        "groupId": row["group_id"],
        "groupActivityId": row["group_activity_id"],
      });

  Map<String, dynamic> _taskToRow(DailyTaskEntity task, String userId) => {
    "id": task.id,
    "user_id": userId,
    "name": task.name,
    "color_value": task.colorValue,
    "target_days": task.targetDays,
    "completed_dates": task.completedDates,
    "sequence_type": task.sequenceType.name,
    "last_resolved_missed_date": task.lastResolvedMissedDate,
    "goal_type": task.goalType.name,
    "group_id": task.groupId,
    "group_activity_id": task.groupActivityId,
    "updated_at": (task.updatedAt ?? DateTime.now().toUtc())
        .toUtc()
        .toIso8601String(),
  };
}
