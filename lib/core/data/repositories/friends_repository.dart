import "dart:async";
import "dart:convert";

import "package:dartz/dartz.dart";
import "package:timing/core/data/data_sources/friends_data_source.dart";
import "package:timing/core/data/errors/backend_error.dart";
import "package:timing/core/domain/entities/friend_entity.dart";
import "package:timing/core/domain/entities/friend_presence_entity.dart";
import "package:timing/core/domain/entities/friend_suggestion_entity.dart";
import "package:timing/core/domain/entities/friends_social_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/offline_action_queue.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";
import "package:timing/core/services/sync/sync_error_classifier.dart";

/// Friends, friend requests and presence. Owns what happens when the backend
/// cannot be reached: reads fall back to the last snapshot saved on the
/// device, and writes are applied to that snapshot and queued for replay.
class FriendsRepository {
  FriendsRepository({
    required this._friendsDataSource,
    required this._localStorageService,
    required this._logger,
    required PendingSyncStore pendingSyncStore,
    this._isBackendReachable,
  }) : _pendingActions = OfflineActionQueue(
         localStorageService: _localStorageService,
         pendingSyncStore: pendingSyncStore,
         logger: _logger,
         storageKey: LocalStorageKeys.pendingFriendActions,
         dataset: PendingSyncDataset.friends,
         label: "friend action",
       );

  final FriendsDataSource _friendsDataSource;
  final AppLocalStorageService _localStorageService;
  final AppLoggerService _logger;
  final OfflineActionQueue _pendingActions;

  /// The app's connectivity flag: the offline fallbacks below only apply when
  /// it says offline or the failure is not a definitive server rejection.
  final bool Function()? _isBackendReachable;

  static const Duration _offlineFallbackTimeout = Duration(seconds: 8);

  Future<Either<AppError, List<FriendPresenceEntity>>> getPresences(
    List<String> friendIds,
  ) async {
    if (friendIds.isEmpty) {
      return const Right([]);
    }
    return guardBackendCall(() => _friendsDataSource.fetchPresences(friendIds));
  }

  /// Like [GroupsRepository.getGroups], this is remote-authoritative shared
  /// state: try the backend first, only falling back to the last cached
  /// snapshot if that fails, with an inner timeout so an offline device sees
  /// it quickly instead of after a long OS timeout.
  Future<Either<AppError, FriendsSocialEntity>> getSocial() async {
    final String? userId = _friendsDataSource.currentUserId;
    if (userId == null) {
      return const Right(FriendsSocialEntity.empty());
    }

    try {
      final FriendsSocialEntity social = await _friendsDataSource
          .fetchSocial(userId)
          .timeout(_offlineFallbackTimeout);
      await _cacheSocial(social);
      return Right(social);
    } catch (error, stackTrace) {
      if (!_canUseOfflineFallback(error)) {
        return Left(toAppError(error, stackTrace));
      }
      final FriendsSocialEntity? cached = await _readCachedSocial();
      if (cached != null) {
        return Right(cached);
      }
      return Left(toAppError(error, stackTrace));
    }
  }

  Future<Either<AppError, void>> sendFriendRequest(String addresseeId) async {
    final String? userId = _friendsDataSource.currentUserId;
    if (userId == null) {
      return const Left(SignedOutError(operation: "send a friend request"));
    }
    return _sendOrQueue(
      failureLog: "Failed to send friend request",
      send: () => _friendsDataSource.sendFriendRequest(
        userId: userId,
        addresseeId: addresseeId,
      ),
      queuedAction: {"type": "sendFriendRequest", "addresseeId": addresseeId},
    );
  }

  Future<Either<AppError, void>> acceptRequest(String friendshipId) {
    FriendsSocialEntity acceptInCache(FriendsSocialEntity social) {
      final FriendEntity? match = _findByFriendshipId(
        social.requests,
        friendshipId,
      );
      if (match == null) {
        return social;
      }
      return FriendsSocialEntity(
        inviteCode: social.inviteCode,
        requests: social.requests
            .where((item) => item.friendshipId != friendshipId)
            .toList(),
        sentRequests: social.sentRequests,
        friends: [
          ...social.friends.where((item) => item.id != match.id),
          match,
        ],
      );
    }

    return _sendOrQueue(
      failureLog: "Failed to accept friend request",
      send: () => _friendsDataSource.acceptRequest(friendshipId),
      applyToCache: acceptInCache,
      queuedAction: {"type": "acceptRequest", "friendshipId": friendshipId},
    );
  }

  Future<Either<AppError, void>> declineRequest(String friendshipId) =>
      _sendOrQueue(
        failureLog: "Failed to decline friend request",
        send: () => _friendsDataSource.declineRequest(friendshipId),
        applyToCache: (social) => FriendsSocialEntity(
          inviteCode: social.inviteCode,
          requests: social.requests
              .where((item) => item.friendshipId != friendshipId)
              .toList(),
          sentRequests: social.sentRequests,
          friends: social.friends,
        ),
        queuedAction: {"type": "declineRequest", "friendshipId": friendshipId},
      );

  Future<Either<AppError, void>> cancelSentRequest({
    required String addresseeId,
    String friendshipId = "",
  }) async {
    final String? userId = _friendsDataSource.currentUserId;
    if (friendshipId.isEmpty && userId == null) {
      return const Left(SignedOutError(operation: "cancel a friend request"));
    }
    return _sendOrQueue(
      failureLog: "Failed to cancel friend request",
      send: () => _friendsDataSource.cancelSentRequest(
        userId: userId,
        addresseeId: addresseeId,
        friendshipId: friendshipId,
      ),
      applyToCache: (social) => FriendsSocialEntity(
        inviteCode: social.inviteCode,
        requests: social.requests,
        sentRequests: social.sentRequests
            .where(
              (item) =>
                  item.friendshipId != friendshipId && item.id != addresseeId,
            )
            .toList(),
        friends: social.friends,
      ),
      queuedAction: {
        "type": "cancelSentRequest",
        "addresseeId": addresseeId,
        "friendshipId": friendshipId,
      },
    );
  }

  Future<Either<AppError, void>> removeFriend({
    required String friendId,
    String friendshipId = "",
  }) async {
    final String? userId = _friendsDataSource.currentUserId;
    if (friendshipId.isEmpty && userId == null) {
      return const Left(SignedOutError(operation: "remove a friend"));
    }
    return _sendOrQueue(
      failureLog: "Failed to remove friend",
      send: () => _friendsDataSource.removeFriend(
        userId: userId,
        friendId: friendId,
        friendshipId: friendshipId,
      ),
      applyToCache: (social) => FriendsSocialEntity(
        inviteCode: social.inviteCode,
        requests: social.requests,
        sentRequests: social.sentRequests,
        friends: social.friends
            .where(
              (item) =>
                  item.friendshipId != friendshipId && item.id != friendId,
            )
            .toList(),
      ),
      queuedAction: {
        "type": "removeFriend",
        "friendId": friendId,
        "friendshipId": friendshipId,
      },
    );
  }

  Future<Either<AppError, FriendSuggestionEntity?>> findByCode(String code) =>
      guardBackendCall(() => _friendsDataSource.findByCode(code));

  /// Re-attempts friend actions that failed to reach the backend earlier, in
  /// the order they were queued (e.g. a cancel never runs ahead of the send it
  /// follows).
  Future<void> flushPendingSync() async {
    await _pendingActions.flush(_replay);
  }

  Future<void> _replay(Map<String, dynamic> action) async {
    final String? userId = _friendsDataSource.currentUserId;
    switch (action["type"] as String?) {
      case "sendFriendRequest":
        if (userId == null) {
          throw StateError("User must be signed in to send a friend request.");
        }
        await _friendsDataSource.sendFriendRequest(
          userId: userId,
          addresseeId: action["addresseeId"] as String,
        );
      case "acceptRequest":
        await _friendsDataSource.acceptRequest(
          action["friendshipId"] as String,
        );
      case "declineRequest":
        await _friendsDataSource.declineRequest(
          action["friendshipId"] as String,
        );
      case "cancelSentRequest":
        await _friendsDataSource.cancelSentRequest(
          userId: userId,
          addresseeId: action["addresseeId"] as String,
          friendshipId: action["friendshipId"] as String? ?? "",
        );
      case "removeFriend":
        await _friendsDataSource.removeFriend(
          userId: userId,
          friendId: action["friendId"] as String,
          friendshipId: action["friendshipId"] as String? ?? "",
        );
    }
  }

  /// Sends a write to the backend. When the backend cannot be reached the
  /// change is applied to the cached snapshot and queued instead, and the
  /// caller is told it went through; a definitive rejection is reported.
  Future<Either<AppError, void>> _sendOrQueue({
    required String failureLog,
    required Future<void> Function() send,
    required Map<String, dynamic> queuedAction,
    FriendsSocialEntity Function(FriendsSocialEntity current)? applyToCache,
  }) async {
    Future<void> updateCache() async {
      if (applyToCache != null) {
        await _updateCachedSocial(applyToCache);
      }
    }

    try {
      await send();
      await updateCache();
      return const Right(null);
    } catch (error, stackTrace) {
      _logger.logError(failureLog, error: error, stackTrace: stackTrace);
      if (!_canUseOfflineFallback(error)) {
        return Left(toAppError(error, stackTrace));
      }
      await updateCache();
      await _pendingActions.enqueue(queuedAction);
      return const Right(null);
    }
  }

  bool _canUseOfflineFallback(Object error) =>
      shouldUseOfflineFallback(error, isBackendReachable: _isBackendReachable);

  FriendEntity? _findByFriendshipId(
    List<FriendEntity> entries,
    String friendshipId,
  ) {
    for (final FriendEntity entry in entries) {
      if (entry.friendshipId == friendshipId) {
        return entry;
      }
    }
    return null;
  }

  Future<void> _cacheSocial(FriendsSocialEntity social) async {
    await _localStorageService.write(
      LocalStorageKeys.cachedFriendsSocial,
      jsonEncode(social.toMap()),
    );
  }

  Future<FriendsSocialEntity?> _readCachedSocial() async {
    final String? saved = await _localStorageService.read<String?>(
      LocalStorageKeys.cachedFriendsSocial,
    );
    if (saved == null) {
      return null;
    }
    try {
      return FriendsSocialEntity.fromMap(
        jsonDecode(saved) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateCachedSocial(
    FriendsSocialEntity Function(FriendsSocialEntity current) transform,
  ) async {
    final FriendsSocialEntity current =
        await _readCachedSocial() ?? const FriendsSocialEntity.empty();
    await _cacheSocial(transform(current));
  }
}
