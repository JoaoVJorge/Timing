import "dart:convert";
import "dart:math" as math;

import "package:dartz/dartz.dart";
import "package:flutter/foundation.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

class SubjectsDataSource {
  SubjectsDataSource({
    required this._localStorageService,
    required this._supabaseService,
    required this._logger,
    required this._pendingSyncStore,
  });

  final AppLocalStorageService _localStorageService;
  final SupabaseService _supabaseService;
  final AppLoggerService _logger;
  final PendingSyncStore _pendingSyncStore;
  // A remote call must fail fast on a "connected but no real internet"
  // network so its try/catch can mark the dataset pending for retry, instead
  // of hanging on the platform's own (much longer) socket timeout.
  static const Duration _remoteCallTimeout = Duration(seconds: 10);

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
      return Left(SerializationAppError(error: error, stackTrace: stackTrace));
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
      final String encoded = jsonEncode(
        subjects.map((subject) => subject.toMap()).toList(),
      );
      await _localStorageService.write(LocalStorageKeys.subjects, encoded);
      await _syncRemoteSubjects(subjects);
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<void> _saveLocalSubjects(List<SubjectEntity> subjects) async {
    final String encoded = jsonEncode(
      subjects.map((subject) => subject.toMap()).toList(),
    );
    await _localStorageService.write(LocalStorageKeys.subjects, encoded);
  }

  Future<List<SubjectEntity>> _getRemoteSubjects() async {
    final String? userId = _supabaseService.currentUserId;
    if (userId == null) {
      return const [];
    }

    try {
      return await _fetchRemoteSubjects(userId);
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to fetch remote user_subjects",
        error: error,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  Future<List<SubjectEntity>> _fetchRemoteSubjects(String userId) async {
    final List<dynamic> rows = await _supabaseService.requireClient
        .from("user_subjects")
        .select()
        .eq("user_id", userId)
        .order("created_at")
        .timeout(_remoteCallTimeout);
    _logger.logResponse("select public.user_subjects", rows);

    return rows
        .map((row) => _subjectFromRow(row as Map<String, dynamic>))
        .where(
          (subject) =>
              TimeCategoryType.tryByName(subject.category.name) != null,
        )
        .toList();
  }

  Future<void> _syncRemoteSubjects(List<SubjectEntity> subjects) async {
    final String? userId = _supabaseService.currentUserId;
    if (userId == null) {
      return;
    }

    try {
      final client = _supabaseService.requireClient;
      final List<Map<String, dynamic>> rows = subjects
          .map((subject) => _subjectToRow(subject, userId))
          .toList();

      if (rows.isNotEmpty) {
        await client
            .from("user_subjects")
            .upsert(rows, onConflict: "user_id,id")
            .timeout(_remoteCallTimeout);
      }

      final Set<String> deletions = await _readIdSet(
        LocalStorageKeys.pendingSubjectDeletions,
      );
      if (deletions.isNotEmpty) {
        await client
            .from("user_subjects")
            .delete()
            .eq("user_id", userId)
            .inFilter("id", deletions.toList())
            .timeout(_remoteCallTimeout);
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
      return;
    }
  }

  /// Pulls what other phones signed in to this account did to their
  /// activities into the local list, which is otherwise only ever read (the
  /// remote copy is fetched only when nothing is stored). Returns whether the
  /// local list changed.
  Future<bool> reconcileWithRemote() async {
    final List<SubjectEntity>? remote = await fetchRemoteForReconcile();
    return remote == null ? false : applyRemoteSubjects(remote);
  }

  /// The network half of [reconcileWithRemote], kept apart so a caller can run
  /// it outside the queue that serializes local subject writes: waiting on a
  /// slow connection there would hold up saving the timer's progress.
  ///
  /// `null` when there is nothing to reconcile (signed out, or a sync is
  /// pending) or the backend cannot be read. While a sync is pending the local
  /// edits must reach the backend first, or they would be merged against a copy
  /// that does not have them.
  Future<List<SubjectEntity>?> fetchRemoteForReconcile() async {
    final String? userId = _supabaseService.currentUserId;
    if (userId == null ||
        _pendingSyncStore.contains(PendingSyncDataset.subjects)) {
      return null;
    }
    try {
      return await _fetchRemoteSubjects(userId);
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
  Future<bool> applyRemoteSubjects(List<SubjectEntity> remote) async {
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
      return grown;
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

  /// Re-attempts a previously failed remote sync using the current local
  /// state. No-op when nothing is pending for this dataset.
  Future<void> flushPendingSync() async {
    if (!_pendingSyncStore.contains(PendingSyncDataset.subjects)) {
      return;
    }
    final Either<AppError, List<SubjectEntity>> local = await getSubjects();
    await local.fold((_) async {}, _syncRemoteSubjects);
  }

  SubjectEntity _subjectFromRow(Map<String, dynamic> row) =>
      SubjectEntity.fromMap({
        "id": row["id"],
        "name": row["name"],
        "category": row["category"],
        "colorValue": (row["color_value"] as num?)?.toInt() ?? 0,
        "totalSeconds": (row["total_seconds"] as num?)?.toInt() ?? 0,
        "goalSeconds": (row["goal_seconds"] as num?)?.toInt() ?? 0,
        "currentPages": (row["current_pages"] as num?)?.toInt() ?? 0,
        "goalPages": (row["goal_pages"] as num?)?.toInt() ?? 0,
        "notes": row["notes"],
        "iconName": row["icon_name"],
        "restMinutes": (row["rest_minutes"] as num?)?.toInt(),
        "focusSessionCount": (row["focus_session_count"] as num?)?.toInt(),
        "wallpaperIndex": (row["wallpaper_index"] as num?)?.toInt(),
        "activityType": row["activity_type"],
        "createdAt": row["created_at"],
        "groupId": row["group_id"],
        "groupActivityId": row["group_activity_id"],
      });

  Map<String, dynamic> _subjectToRow(SubjectEntity subject, String userId) {
    final Map<String, dynamic> row = {
      "id": subject.id,
      "user_id": userId,
      "name": subject.name,
      "category": subject.category.name,
      "color_value": subject.colorValue,
      "total_seconds": subject.totalSeconds,
      "goal_seconds": subject.goalSeconds,
      "current_pages": subject.currentPages,
      "goal_pages": subject.goalPages,
      "notes": subject.notes,
      "icon_name": subject.iconName,
      "rest_minutes": subject.restMinutes,
      "focus_session_count": subject.focusSessionCount,
      "wallpaper_index": subject.wallpaperIndex,
      "activity_type": subject.activityType.name,
      "group_id": subject.groupId,
      "group_activity_id": subject.groupActivityId,
      "updated_at": DateTime.now().toUtc().toIso8601String(),
    };
    final DateTime? createdAt = subject.createdAt;
    if (createdAt != null) {
      row["created_at"] = createdAt.toUtc().toIso8601String();
    }
    return row;
  }
}
