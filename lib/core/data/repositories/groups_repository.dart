import "dart:async";
import "dart:convert";

import "package:dartz/dartz.dart";
import "package:timing/core/data/data_sources/groups_data_source.dart";
import "package:timing/core/data/errors/backend_error.dart";
import "package:timing/core/domain/entities/friend_option.dart";
import "package:timing/core/domain/entities/group_activity_draft.dart";
import "package:timing/core/domain/entities/group_activity_link_options.dart";
import "package:timing/core/domain/entities/group_activity_progress_entity.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_image_message_entity.dart";
import "package:timing/core/domain/entities/group_image_messages_page.dart";
import "package:timing/core/domain/entities/group_invitation_entity.dart";
import "package:timing/core/domain/entities/group_invite_option_entity.dart";
import "package:timing/core/domain/entities/group_join_outcome_entity.dart";
import "package:timing/core/domain/entities/group_join_request_entity.dart";
import "package:timing/core/domain/entities/sent_group_invitation_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/core/services/sync/offline_action_queue.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";
import "package:timing/core/services/sync/sync_error_classifier.dart";

/// Groups, their members, ranking, invitations and images. Owns what happens
/// when the backend cannot be reached: the group list falls back to the copy
/// saved on the device, and the writes only this client needs to know about
/// (leaving a group, editing its settings) are applied to that copy and queued
/// for replay. Everything else needs a connection and reports the failure.
class GroupsRepository {
  GroupsRepository({
    required this._groupsDataSource,
    required this._localStorageService,
    required this._logger,
    required PendingSyncStore pendingSyncStore,
    this._activityChangeBus,
    this._isBackendReachable,
  }) : _pendingActions = OfflineActionQueue(
         localStorageService: _localStorageService,
         pendingSyncStore: pendingSyncStore,
         logger: _logger,
         storageKey: LocalStorageKeys.pendingGroupActions,
         dataset: PendingSyncDataset.groups,
         label: "group action",
       );

  final GroupsDataSource _groupsDataSource;
  final AppLocalStorageService _localStorageService;
  final AppLoggerService _logger;
  final ActivityChangeBus? _activityChangeBus;
  final OfflineActionQueue _pendingActions;

  /// The app's connectivity flag: the offline fallbacks below only apply when
  /// it says offline or the failure is not a definitive server rejection.
  final bool Function()? _isBackendReachable;

  /// Must stay comfortably above [GroupsDataSource.activityScoresTimeout]: the
  /// fetch it wraps runs several sequential queries and only then awaits the
  /// leaderboard RPC, which has its own budget. Equal values let this timeout
  /// win the race before the RPC's own ever fires, silently serving stale
  /// cached groups after every real activity update instead of the fresh
  /// ranking.
  static const Duration _offlineFallbackTimeout = Duration(seconds: 15);

  bool _lastGroupsFetchServedCache = false;

  /// Whether the most recent [getGroups] could not reach the backend and
  /// returned the cached list instead. While the app believes it is online
  /// that means the data on screen is stale and the user should be told.
  bool get lastGroupsFetchServedCache => _lastGroupsFetchServedCache;

  /// Groups are remote-authoritative shared state (other members change
  /// them), unlike subjects, so reads stay remote-first: this tries the
  /// backend first and only falls back to the last locally cached list if
  /// that fails (offline, timeout, etc). An inner timeout keeps that fallback
  /// fast, otherwise an offline user would wait out a long OS-level
  /// connection timeout before ever seeing the cache.
  Future<Either<AppError, List<GroupEntity>>> getGroups() async {
    final String? userId = _groupsDataSource.currentUserId;
    if (userId == null) {
      return const Right([]);
    }

    try {
      final List<GroupEntity> groups = await _groupsDataSource
          .fetchGroups(userId)
          .timeout(_offlineFallbackTimeout);
      await _cacheGroups(groups);
      _lastGroupsFetchServedCache = false;
      return Right(groups);
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to refresh groups",
        error: error,
        stackTrace: stackTrace,
      );
      if (!_canUseOfflineFallback(error)) {
        return Left(toAppError(error, stackTrace));
      }
      final List<GroupEntity>? cached = await _readCachedGroups();
      if (cached != null) {
        _lastGroupsFetchServedCache = true;
        return Right(cached);
      }
      return Left(toAppError(error, stackTrace));
    }
  }

  /// Last successfully fetched groups, without touching the network. Used to
  /// keep the groups screen usable while the backend is unreachable.
  Future<Either<AppError, List<GroupEntity>>> getCachedGroups() async =>
      Right(await _readCachedGroups() ?? const []);

  /// Re-reads only the leaderboard and applies it to [groups], saving the
  /// result for the offline view. A failure is reported, not turned into
  /// zeros, so the caller can fall back to the full reload.
  Future<Either<AppError, List<GroupEntity>>> refreshGroupScores(
    List<GroupEntity> groups,
  ) async {
    if (groups.isEmpty) {
      return Right(groups);
    }
    return _guard("refresh group scores", () async {
      final List<GroupEntity> updated = await _groupsDataSource
          .fetchGroupScores(groups);
      await _cacheGroups(updated);
      return updated;
    });
  }

  Future<Either<AppError, List<GroupActivityProgressEntity>>>
  getGroupActivityProgress(String groupId, {String? localDate}) => _guard(
    "rpc public.group_activity_progress",
    () => _groupsDataSource.fetchGroupActivityProgress(
      groupId,
      localDate: localDate,
    ),
  );

  Future<Either<AppError, List<GroupActivityLinkOptions>>>
  getActivityLinkOptions(String groupId) => _guard(
    "rpc public.group_activity_link_options",
    () => _groupsDataSource.fetchActivityLinkOptions(groupId),
  );

  Future<Either<AppError, void>> setActivityLinks({
    required String activityId,
    required List<String> sourceIds,
    bool createNew = false,
  }) => _guard("rpc public.set_group_activity_links", () async {
    await _groupsDataSource.setActivityLinks(
      activityId: activityId,
      sourceIds: sourceIds,
      createNew: createNew,
    );
    _activityChangeBus?.notifyGroupActivityChanged();
  });

  Future<Either<AppError, GroupEntity>> createGroup({
    required String name,
    required GroupThemeType theme,
    required List<FriendOption> invitedFriends,
    String description = "",
    GroupActivityDraft? activity,
  }) async {
    final String? userId = _groupsDataSource.currentUserId;
    if (userId == null) {
      return const Left(SignedOutError(operation: "create a group"));
    }
    return _guard(
      "rpc public.create_group_with_members",
      () => _groupsDataSource.createGroup(
        userId: userId,
        name: name,
        theme: theme,
        invitedFriends: invitedFriends,
        description: description,
        activity: activity,
      ),
    );
  }

  /// Updates the caller's own group settings. Queued and applied
  /// optimistically to the cache when the backend cannot be reached, since
  /// the client already knows everything it changes (name, description,
  /// activity) and nothing server-generated is needed.
  Future<Either<AppError, GroupEntity>> updateGroup({
    required GroupEntity group,
    required String name,
    required String description,
    required Map<String, dynamic> activityPayload,
  }) async {
    const String operation = "rpc public.update_group_with_activity";
    try {
      final GroupEntity updated = await _groupsDataSource.updateGroup(
        groupId: group.id,
        name: name,
        description: description,
        activityPayload: activityPayload,
        fallbackGroup: group,
      );
      await _updateCachedGroup(updated);
      return Right(updated);
    } catch (error, stackTrace) {
      _logFailure(operation, error, stackTrace);
      if (!_canUseOfflineFallback(error)) {
        return Left(toAppError(error, stackTrace, operation: operation));
      }
      final GroupEntity optimistic = GroupEntity(
        id: group.id,
        name: name,
        theme: group.theme,
        members: group.members,
        description: description,
        ownerId: group.ownerId,
        createdAt: group.createdAt,
        inviteCode: group.inviteCode,
        privacy: group.privacy,
        createdActivityId: group.createdActivityId,
        colorValue:
            (activityPayload["color_value"] as num?)?.toInt() ??
            group.colorValue,
      );
      await _updateCachedGroup(optimistic);
      await _pendingActions.enqueue({
        "type": "updateGroup",
        "groupId": group.id,
        "name": name,
        "description": description,
        "activityPayload": activityPayload,
      });
      return Right(optimistic);
    }
  }

  /// Leaves the caller's own membership. Safe to retry (see
  /// [GroupsDataSource.leaveGroup]), so a failure while offline is queued
  /// instead of surfaced as an error. A definitive server rejection while
  /// online is still reported.
  Future<Either<AppError, void>> leaveGroup(String groupId) async {
    final String? userId = _groupsDataSource.currentUserId;
    if (userId == null) {
      return const Left(SignedOutError(operation: "leave a group"));
    }

    try {
      await _groupsDataSource.leaveGroup(groupId: groupId, userId: userId);
      await _removeCachedGroup(groupId);
      return const Right(null);
    } catch (error, stackTrace) {
      _logger.logError(
        "Failed to leave group $groupId",
        error: error,
        stackTrace: stackTrace,
      );
      if (!_canUseOfflineFallback(error)) {
        return Left(toAppError(error, stackTrace));
      }
      await _removeCachedGroup(groupId);
      await _pendingActions.enqueue({"type": "leaveGroup", "groupId": groupId});
      return const Right(null);
    }
  }

  Future<Either<AppError, void>> removeMember({
    required String groupId,
    required String memberId,
  }) => _guard(
    "remove group member",
    () => _groupsDataSource.removeMember(groupId: groupId, memberId: memberId),
  );

  Future<Either<AppError, void>> transferLeadership({
    required String groupId,
    required String nextLeaderId,
  }) => _guard(
    "rpc public.transfer_group_ownership",
    () => _groupsDataSource.transferLeadership(
      groupId: groupId,
      nextLeaderId: nextLeaderId,
    ),
  );

  Future<Either<AppError, void>> resetGroupProgress(String groupId) => _guard(
    "rpc public.reset_group_progress",
    () => _groupsDataSource.resetGroupProgress(groupId),
  );

  Future<Either<AppError, List<FriendOption>>> getInvitableFriends() async {
    final String? userId = _groupsDataSource.currentUserId;
    if (userId == null) {
      return const Right([]);
    }
    return _guard(
      "load invitable friends",
      () => _groupsDataSource.fetchInvitableFriends(userId),
    );
  }

  Future<Either<AppError, List<GroupInviteOptionEntity>>> getGroupInviteOptions(
    String groupId,
  ) => _guard(
    "rpc public.group_invite_options",
    () => _groupsDataSource.fetchGroupInviteOptions(groupId),
  );

  Future<Either<AppError, void>> inviteFriendToGroup({
    required String groupId,
    required String friendId,
  }) => _guard(
    "rpc public.invite_friend_to_group",
    () => _groupsDataSource.inviteFriendToGroup(
      groupId: groupId,
      friendId: friendId,
    ),
  );

  Future<Either<AppError, void>> cancelGroupInvitation({
    required String groupId,
    required String friendId,
  }) => _guard(
    "rpc public.cancel_group_invitation",
    () => _groupsDataSource.cancelGroupInvitation(
      groupId: groupId,
      friendId: friendId,
    ),
  );

  Future<Either<AppError, List<GroupInvitationEntity>>>
  getPendingInvitations() async {
    if (_groupsDataSource.currentUserId == null) {
      return const Right([]);
    }
    return _guard(
      "rpc public.pending_group_invitations",
      _groupsDataSource.fetchPendingInvitations,
    );
  }

  Future<Either<AppError, List<SentGroupInvitationEntity>>>
  getSentInvitations() async {
    final String? userId = _groupsDataSource.currentUserId;
    if (userId == null) {
      return const Right([]);
    }
    return _guard(
      "load sent group invitations",
      () => _groupsDataSource.fetchSentInvitations(userId),
    );
  }

  Future<Either<AppError, GroupJoinOutcomeEntity>> acceptInvitation(
    String invitationId,
  ) => _joinGroup(
    "rpc public.accept_group_invitation",
    () => _groupsDataSource.acceptInvitation(invitationId),
  );

  Future<Either<AppError, void>> declineInvitation(String invitationId) =>
      _guard(
        "rpc public.decline_group_invitation",
        () => _groupsDataSource.declineInvitation(invitationId),
      );

  Future<Either<AppError, GroupJoinOutcomeEntity>> joinGroupByInviteCode(
    String inviteCode,
  ) => _joinGroup(
    "rpc public.join_group_by_invite_code",
    () => _groupsDataSource.joinGroupByInviteCode(inviteCode),
  );

  /// The people waiting for the leader of [groupId] to let them in. Asking as
  /// anyone else answers with an empty list, which is what the UI shows.
  Future<Either<AppError, List<GroupJoinRequestEntity>>> getJoinRequests(
    String groupId,
  ) async {
    if (_groupsDataSource.currentUserId == null) {
      return const Right([]);
    }
    return _guard(
      "rpc public.group_join_requests",
      () => _groupsDataSource.fetchJoinRequests(groupId),
    );
  }

  Future<Either<AppError, void>> answerJoinRequest({
    required String requestId,
    required bool approve,
  }) => _guard(
    approve
        ? "rpc public.approve_group_join_request"
        : "rpc public.decline_group_join_request",
    () => _groupsDataSource.answerJoinRequest(
      requestId: requestId,
      approve: approve,
    ),
  );

  Future<Either<AppError, GroupImageMessagesPage>> getImageMessages(
    String groupId, {
    GroupImageMessageEntity? before,
  }) async {
    if (_groupsDataSource.currentUserId == null) {
      return const Right(GroupImageMessagesPage(messages: [], hasMore: false));
    }
    return _guard(
      "load group images",
      () => _groupsDataSource.fetchImageMessages(groupId, before: before),
    );
  }

  Future<Either<AppError, GroupImageMessageEntity>> sendImageMessage({
    required String groupId,
    required String imageBase64,
  }) async {
    final String? userId = _groupsDataSource.currentUserId;
    if (userId == null) {
      return const Left(SignedOutError(operation: "send a group image"));
    }
    return _guard(
      "insert public.group_image_messages",
      () => _groupsDataSource.sendImageMessage(
        userId: userId,
        groupId: groupId,
        imageBase64: imageBase64,
      ),
    );
  }

  /// Re-attempts group actions that failed to reach the backend earlier, in
  /// the order they were queued.
  Future<void> flushPendingSync() async {
    final int processed = await _pendingActions.flush(_replay);
    if (processed > 0) {
      _activityChangeBus?.notifyGroupActivityChanged();
    }
  }

  Future<void> _replay(Map<String, dynamic> action) async {
    switch (action["type"] as String?) {
      case "updateGroup":
        final String groupId = action["groupId"] as String;
        final List<GroupEntity> cached = await _readCachedGroups() ?? const [];
        final GroupEntity fallback = cached.firstWhere(
          (item) => item.id == groupId,
          orElse: () => GroupEntity(
            id: groupId,
            name: action["name"] as String? ?? "",
            theme: GroupThemeType.byName(null),
            members: const [],
          ),
        );
        final GroupEntity updated = await _groupsDataSource.updateGroup(
          groupId: groupId,
          name: action["name"] as String,
          description: action["description"] as String,
          activityPayload: Map<String, dynamic>.from(
            action["activityPayload"] as Map? ?? const {},
          ),
          fallbackGroup: fallback,
        );
        await _updateCachedGroup(updated);
      case "leaveGroup":
        final String groupId = action["groupId"] as String;
        final String? userId = _groupsDataSource.currentUserId;
        if (userId == null) {
          throw StateError("User must be signed in to leave a group.");
        }
        await _groupsDataSource.leaveGroup(groupId: groupId, userId: userId);
        await _removeCachedGroup(groupId);
    }
  }

  /// Runs a membership change that answers with the id of the group joined,
  /// then reads that group back with its members and ranking.
  Future<Either<AppError, GroupJoinOutcomeEntity>> _joinGroup(
    String operation,
    Future<GroupJoinResponse> Function() join,
  ) async {
    final Either<AppError, GroupJoinResponse> joined = await _guard(
      operation,
      join,
    );
    return joined.fold((error) async => Left(error), (response) async {
      // Nothing to load while the leader has not answered: the user is not a
      // member yet, so the group is not theirs to read.
      if (response.pendingApproval) {
        return Right(
          GroupJoinOutcomeEntity.pendingApproval(response.groupName),
        );
      }
      final Either<AppError, List<GroupEntity>> groups = await getGroups();
      return groups.fold(Left.new, (loaded) {
        for (final GroupEntity group in loaded) {
          if (group.id == response.groupId) {
            return Right(GroupJoinOutcomeEntity.joined(group));
          }
        }
        return Left(
          UnexpectedError(
            operation: operation,
            cause:
                "Joined group ${response.groupId} was not returned by "
                "getGroups.",
          ),
        );
      });
    });
  }

  Future<Either<AppError, T>> _guard<T>(
    String operation,
    Future<T> Function() call,
  ) => guardBackendCall(
    call,
    operation: operation,
    onError: (error, stackTrace) => _logFailure(operation, error, stackTrace),
  );

  void _logFailure(String operation, Object error, StackTrace stackTrace) {
    _logger.logError(
      "Supabase $operation failed",
      error: describeBackendError(error),
      stackTrace: stackTrace,
    );
  }

  bool _canUseOfflineFallback(Object error) =>
      shouldUseOfflineFallback(error, isBackendReachable: _isBackendReachable);

  Future<void> _cacheGroups(List<GroupEntity> groups) async {
    await _localStorageService.write(
      LocalStorageKeys.cachedGroups,
      jsonEncode(groups.map((group) => group.toMap()).toList()),
    );
  }

  Future<List<GroupEntity>?> _readCachedGroups() async {
    final String? saved = await _localStorageService.read<String?>(
      LocalStorageKeys.cachedGroups,
    );
    if (saved == null) {
      return null;
    }
    try {
      final List<dynamic> decoded = jsonDecode(saved) as List<dynamic>;
      return decoded
          .map((item) => GroupEntity.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateCachedGroup(GroupEntity group) async {
    final List<GroupEntity> cached = await _readCachedGroups() ?? [];
    final int index = cached.indexWhere((item) => item.id == group.id);
    if (index >= 0) {
      cached[index] = group;
    } else {
      cached.add(group);
    }
    await _cacheGroups(cached);
  }

  Future<void> _removeCachedGroup(String groupId) async {
    final List<GroupEntity> cached = await _readCachedGroups() ?? [];
    cached.removeWhere((item) => item.id == groupId);
    await _cacheGroups(cached);
  }
}
