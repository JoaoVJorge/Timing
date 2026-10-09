import "dart:async";
import "dart:convert";
import "dart:math" as math;

import "package:dartz/dartz.dart";
import "package:flutter/foundation.dart";
import "package:timing/core/data/data_sources/subjects_data_source.dart";
import "package:timing/core/data/errors/backend_error.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

/// The user's activities. The list on the device is what the app reads and
/// writes; the backend is brought in line after every save, a save that could
/// not reach it marks the dataset pending for [flushPendingSync], and
/// [reconcileWithRemote] pulls in what other phones did.
class SubjectsRepository {
  SubjectsRepository({
    required this._subjectsDataSource,
    required this._localStorageService,
    required this._logger,
    required this._pendingSyncStore,
  });

  final SubjectsDataSource _subjectsDataSource;
  final AppLocalStorageService _localStorageService;
  final AppLoggerService _logger;
  final PendingSyncStore _pendingSyncStore;
  Future<void> _mutationTail = Future<void>.value();

  /// Runs a complete read-modify-write transaction after every previously
  /// started subject mutation. Without this queue, a timer autosave can read
  /// an old subject and overwrite configuration changes saved milliseconds
  /// earlier by the edit screen.
  Future<T> runSerializedMutation<T>(Future<T> Function() mutation) {
    final Completer<T> completer = Completer<T>();
    final Future<void> scheduled = _mutationTail.then((_) async {
      try {
        completer.complete(await mutation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    _mutationTail = scheduled.catchError((Object _) {});
    return completer.future;
  }

  Future<Either<AppError, List<SubjectEntity>>> getSubjects() async {
    try {
      final String? savedSubjects = await _localStorageService.read<String?>(
        LocalStorageKeys.subjects,
      );

      if (savedSubjects == null) {
        final List<SubjectEntity> remoteSubjects = await _getRemoteSubjects();
        if (remoteSubjects.isNotEmpty) {
          await _saveLocalSubjects(remoteSubjects);
        }
        return Right(remoteSubjects);
      }

      final List<SubjectEntity> subjects = _decodeLocal(savedSubjects);
      return Right(subjects);
    } catch (error, stackTrace) {
      return Left(LocalDataError(cause: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> saveSubjects(
    List<SubjectEntity> subjects,
  ) async {
    try {
      final Set<String> nextIds = subjects.map((subject) => subject.id).toSet();
      // A subject that disappeared from the list is one the user removed, and
      // only those are deleted remotely. Deleting "everything not in my list"
      // also wiped subjects another phone had created and this one never saw.
      await _recordDeletions(
        removed: (await _localSubjectIds()).difference(nextIds),
        kept: nextIds,
      );
      await _saveLocalSubjects(subjects);
      await _syncRemoteSubjects(subjects);
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(toAppError(error, stackTrace));
    }
  }

  /// Pulls what other phones signed in to this account did to their
  /// activities into the local list, which is otherwise only ever read (the
  /// remote copy is fetched only when nothing is stored). Returns whether the
  /// local list changed.
  ///
  /// Only the local merge is serialized with the other subject mutations (it
  /// reads the stored list and writes the merged one back); the network read
  /// stays outside so a slow connection never delays saving the timer.
  Future<bool> reconcileWithRemote() async {
    final List<SubjectEntity>? remote = await _fetchRemoteForReconcile();
    if (remote == null) {
      return false;
    }
    return runSerializedMutation(() => _applyRemoteSubjects(remote));
  }

  /// The network half of [reconcileWithRemote].
  ///
  /// `null` when there is nothing to reconcile (signed out, or a sync is
  /// pending) or the backend cannot be read. While a sync is pending the local
  /// edits must reach the backend first, or they would be merged against a copy
  /// that does not have them.
  Future<List<SubjectEntity>?> _fetchRemoteForReconcile() async {
    final String? userId = _subjectsDataSource.currentUserId;
    if (userId == null ||
        _pendingSyncStore.contains(PendingSyncDataset.subjects)) {
      return null;
    }
    try {
      return await _subjectsDataSource.fetchSubjects(userId);
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to reconcile user_subjects",
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// The local half of [reconcileWithRemote]: merges [remote] into the stored
  /// list. Read-modify-write, so it belongs inside the serialized mutations.
  Future<bool> _applyRemoteSubjects(List<SubjectEntity> remote) async {
    if (_pendingSyncStore.contains(PendingSyncDataset.subjects)) {
      return false;
    }
    final String? saved = await _localStorageService.read<String?>(
      LocalStorageKeys.subjects,
    );
    final List<SubjectEntity> local = saved == null
        ? const []
        : _decodeLocal(saved);
    final List<SubjectEntity> merged = mergeSubjects(
      local: local,
      remote: remote,
      deletions: await _readIdSet(LocalStorageKeys.pendingSubjectDeletions),
      syncedIds: await _readIdSet(LocalStorageKeys.syncedSubjectIds),
    );
    await _writeIdSet(LocalStorageKeys.syncedSubjectIds, {
      ...remote.map((subject) => subject.id),
    });
    if (listEquals(merged, local)) {
      return false;
    }
    await _saveLocalSubjects(merged);
    return true;
  }

  /// Re-attempts a previously failed remote sync using the current local
  /// state. No-op when nothing is pending for this dataset.
  Future<void> flushPendingSync() async {
    if (!_pendingSyncStore.contains(PendingSyncDataset.subjects)) {
      return;
    }
    final Either<AppError, List<SubjectEntity>> local = await getSubjects();
    await local.fold((_) async {}, _syncRemoteSubjects);
  }

  Future<void> _saveLocalSubjects(List<SubjectEntity> subjects) async {
    final String encoded = jsonEncode(
      subjects.map((subject) => subject.toMap()).toList(),
    );
    await _localStorageService.write(LocalStorageKeys.subjects, encoded);
  }

  /// What the backend holds, or nothing when signed out or unreachable: a
  /// device with no saved list then simply starts empty.
  Future<List<SubjectEntity>> _getRemoteSubjects() async {
    final String? userId = _subjectsDataSource.currentUserId;
    if (userId == null) {
      return const [];
    }

    try {
      return await _subjectsDataSource.fetchSubjects(userId);
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to fetch remote user_subjects",
        error: error,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  Future<void> _syncRemoteSubjects(List<SubjectEntity> subjects) async {
    final String? userId = _subjectsDataSource.currentUserId;
    if (userId == null) {
      return;
    }

    try {
      await _subjectsDataSource.upsertSubjects(
        userId: userId,
        subjects: subjects,
      );

      final Set<String> deletions = await _readIdSet(
        LocalStorageKeys.pendingSubjectDeletions,
      );
      if (deletions.isNotEmpty) {
        await _subjectsDataSource.deleteSubjects(
          userId: userId,
          ids: deletions.toList(),
        );
        await _writeIdSet(LocalStorageKeys.pendingSubjectDeletions, {});
      }
      final Set<String> synced = await _readIdSet(
        LocalStorageKeys.syncedSubjectIds,
      );
      await _writeIdSet(LocalStorageKeys.syncedSubjectIds, {
        ...synced.difference(deletions),
        ...subjects.map((subject) => subject.id),
      });
      await _pendingSyncStore.clear(PendingSyncDataset.subjects);
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to sync remote user_subjects",
        error: error,
        stackTrace: stackTrace,
      );
      await _pendingSyncStore.markPending(PendingSyncDataset.subjects);
    }
  }

  /// Local and remote views of one account's activities, merged:
  ///  * an activity only the backend has (created on another phone, or a group
  ///    activity materialized for this user) is added;
  ///  * one this device holds that the backend once had but no longer does was
  ///    deleted elsewhere, and is dropped; one the backend never had is new
  ///    here and kept;
  ///  * for the rest the larger total and page count win, since both only
  ///    grow, and a group activity takes its definition from the backend so the
  ///    owner's edits reach every member. A personal activity keeps its local
  ///    definition.
  @visibleForTesting
  static List<SubjectEntity> mergeSubjects({
    required List<SubjectEntity> local,
    required List<SubjectEntity> remote,
    required Set<String> deletions,
    required Set<String> syncedIds,
  }) {
    // An empty answer is as likely to be an unauthenticated or filtered read as
    // a genuinely empty account, and acting on it would drop every activity
    // this device holds. Deleting everything on another phone is rare and only
    // costs a stale list here; the reverse would lose data.
    if (remote.isEmpty) {
      return List.of(local);
    }
    final Map<String, SubjectEntity> remoteById = {
      for (final SubjectEntity subject in remote) subject.id: subject,
    };
    final List<SubjectEntity> merged = [];
    for (final SubjectEntity subject in local) {
      final SubjectEntity? counterpart = remoteById[subject.id];
      if (counterpart == null) {
        if (!syncedIds.contains(subject.id)) {
          merged.add(subject);
        }
        continue;
      }
      merged.add(_mergeOne(subject, counterpart));
    }
    final Set<String> localIds = local.map((subject) => subject.id).toSet();
    for (final SubjectEntity subject in remote) {
      if (!localIds.contains(subject.id) && !deletions.contains(subject.id)) {
        merged.add(subject);
      }
    }
    return merged;
  }

  static SubjectEntity _mergeOne(SubjectEntity local, SubjectEntity remote) {
    final SubjectEntity grown = local.copyWith(
      totalSeconds: math.max(local.totalSeconds, remote.totalSeconds),
      currentPages: math.max(local.currentPages, remote.currentPages),
    );
    if (!(remote.groupActivityId?.isNotEmpty ?? false)) {
      return grown.copyWith(clearGroupLink: true);
    }
    return grown.copyWith(
      name: remote.name,
      colorValue: remote.colorValue,
      goalSeconds: remote.goalSeconds,
      goalPages: remote.goalPages,
      iconName: remote.iconName,
      restMinutes: remote.restMinutes,
      focusSessionCount: remote.focusSessionCount,
      wallpaperIndex: remote.wallpaperIndex,
      activityType: remote.activityType,
      groupId: remote.groupId,
      groupActivityId: remote.groupActivityId,
    );
  }

  List<SubjectEntity> _decodeLocal(String saved) {
    final List<dynamic> decoded = jsonDecode(saved) as List<dynamic>;
    final List<SubjectEntity> subjects = [];
    for (final dynamic item in decoded) {
      final Map<String, dynamic> map = item as Map<String, dynamic>;
      // Skips entries from removed categories (e.g. the old "working" one).
      if (TimeCategoryType.tryByName(map["category"] as String? ?? "") ==
          null) {
        continue;
      }
      subjects.add(SubjectEntity.fromMap(map));
    }
    return subjects;
  }

  Future<Set<String>> _localSubjectIds() async {
    final String? saved = await _localStorageService.read<String?>(
      LocalStorageKeys.subjects,
    );
    if (saved == null) {
      return {};
    }
    try {
      return (jsonDecode(saved) as List<dynamic>)
          .map((item) => (item as Map<String, dynamic>)["id"] as String)
          .toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> _recordDeletions({
    required Set<String> removed,
    required Set<String> kept,
  }) async {
    final Set<String> current = await _readIdSet(
      LocalStorageKeys.pendingSubjectDeletions,
    );
    final Set<String> next = {...current, ...removed}.difference(kept);
    if (next.length != current.length || !next.containsAll(current)) {
      await _writeIdSet(LocalStorageKeys.pendingSubjectDeletions, next);
    }
  }

  Future<Set<String>> _readIdSet(LocalStorageKeys key) async {
    final String? saved = await _localStorageService.read<String?>(key);
    if (saved == null) {
      return {};
    }
    try {
      return (jsonDecode(saved) as List<dynamic>).cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeIdSet(LocalStorageKeys key, Set<String> ids) =>
      _localStorageService.write(key, jsonEncode(ids.toList()));
}
