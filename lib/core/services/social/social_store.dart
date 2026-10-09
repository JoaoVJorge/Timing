import "dart:async";

import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:timing/core/data/repositories/friends_repository.dart";
import "package:timing/core/domain/entities/friend_entity.dart";
import "package:timing/core/domain/entities/friend_presence_entity.dart";
import "package:timing/core/domain/entities/friends_social_entity.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

/// The signed-in user's friends and friend requests, held once for every
/// screen that shows them. The friends screens and a group's member list read
/// and change the same lists, so a request sent or answered on one is on the
/// other without a reload, and neither has to reach into the other's
/// controller.
class SocialStore {
  SocialStore({required this._friendsRepository});

  final FriendsRepository _friendsRepository;

  final RxList<FriendEntity> friends = <FriendEntity>[].obs;
  final RxList<FriendEntity> incomingRequests = <FriendEntity>[].obs;
  final RxList<FriendEntity> sentRequests = <FriendEntity>[].obs;

  /// The code other people use to find this user.
  final RxString inviteCode = "".obs;

  final StreamController<GroupEntity> _joinedGroups =
      StreamController<GroupEntity>.broadcast();
  bool _isRefreshingPresences = false;

  /// Groups this user has just joined from a social screen (an accepted
  /// invitation, an invite code), for whoever keeps the list of groups.
  Stream<GroupEntity> get joinedGroups => _joinedGroups.stream;

  void announceJoinedGroup(GroupEntity group) {
    if (!_joinedGroups.isClosed) {
      _joinedGroups.add(group);
    }
  }

  bool isFriend(String profileId) => friendWith(profileId) != null;

  FriendEntity? friendWith(String profileId) =>
      friends.firstWhereOrNull((friend) => friend.id == profileId);

  FriendEntity? incomingRequestFrom(String profileId) =>
      incomingRequests.firstWhereOrNull((request) => request.id == profileId);

  FriendEntity? sentRequestTo(String profileId) =>
      sentRequests.firstWhereOrNull((request) => request.id == profileId);

  /// Reads friends and requests again. Also works offline: the repository
  /// falls back to its saved snapshot. A failure leaves the lists as they are.
  Future<Either<AppError, FriendsSocialEntity>> load() async {
    final Either<AppError, FriendsSocialEntity> result =
        await _friendsRepository.getSocial();
    result.fold((_) {}, (social) {
      inviteCode.value = social.inviteCode;
      friends.assignAll(social.friends);
      incomingRequests.assignAll(social.requests);
      sentRequests.assignAll(social.sentRequests);
    });
    return result;
  }

  /// Updates who is online among [friends]. A failed read keeps what is shown.
  Future<void> refreshPresences() async {
    if (_isRefreshingPresences || friends.isEmpty) {
      return;
    }
    _isRefreshingPresences = true;
    try {
      final Either<AppError, List<FriendPresenceEntity>> result =
          await _friendsRepository.getPresences(
            friends.map((friend) => friend.id).toList(),
          );
      result.fold(
        (_) {},
        (presences) => friends.assignAll(withPresences(friends, presences)),
      );
    } finally {
      _isRefreshingPresences = false;
    }
  }

  /// Asks [profile] to be a friend. [profile] is what the caller knows about
  /// that person, kept as the sent request until the next [load].
  Future<Either<AppError, void>> sendRequest(FriendEntity profile) async {
    final Either<AppError, void> result = await _friendsRepository
        .sendFriendRequest(profile.id);
    if (result.isRight() && sentRequestTo(profile.id) == null) {
      sentRequests.add(profile);
    }
    return result;
  }

  Future<Either<AppError, void>> acceptRequest(FriendEntity request) async {
    final Either<AppError, void> result = await _friendsRepository
        .acceptRequest(request.friendshipId);
    if (result.isLeft()) {
      return result;
    }
    // Pending requests may have no visible profile under RLS. Acceptance
    // grants access, so hydrate the friend before reusing the placeholder.
    final Either<AppError, FriendsSocialEntity> social =
        await _friendsRepository.getSocial();
    final FriendEntity accepted = social.fold(
      (_) => request,
      (loaded) => loaded.friends.firstWhere(
        (friend) => friend.id == request.id,
        orElse: () => request,
      ),
    );
    incomingRequests.removeWhere((item) => item.id == request.id);
    final int existingIndex = friends.indexWhere(
      (friend) => friend.id == request.id,
    );
    if (existingIndex < 0) {
      friends.insert(0, accepted);
    } else {
      friends[existingIndex] = accepted;
    }
    return result;
  }

  Future<Either<AppError, void>> declineRequest(FriendEntity request) async {
    final Either<AppError, void> result = await _friendsRepository
        .declineRequest(request.friendshipId);
    if (result.isRight()) {
      incomingRequests.removeWhere((item) => item.id == request.id);
    }
    return result;
  }

  Future<Either<AppError, void>> cancelSentRequest(FriendEntity request) async {
    final Either<AppError, void> result = await _friendsRepository
        .cancelSentRequest(
          addresseeId: request.id,
          friendshipId: request.friendshipId,
        );
    if (result.isRight()) {
      sentRequests.removeWhere((item) => item.id == request.id);
    }
    return result;
  }

  Future<Either<AppError, void>> removeFriend(FriendEntity friend) async {
    final Either<AppError, void> result = await _friendsRepository.removeFriend(
      friendId: friend.id,
      friendshipId: friend.friendshipId,
    );
    if (result.isRight()) {
      friends.removeWhere((item) => item.id == friend.id);
    }
    return result;
  }

  /// [current] with each friend's online state replaced by the matching entry
  /// of [presences]; a friend without one is left as it was.
  static List<FriendEntity> withPresences(
    Iterable<FriendEntity> current,
    Iterable<FriendPresenceEntity> presences,
  ) {
    final Map<String, FriendPresenceEntity> byId = {
      for (final FriendPresenceEntity presence in presences)
        presence.id: presence,
    };
    return current
        .map((friend) {
          final FriendPresenceEntity? presence = byId[friend.id];
          return presence == null
              ? friend
              : friend.copyWith(
                  isOnline: presence.isOnline,
                  lastSeenAt: presence.lastSeenAt,
                );
        })
        .toList(growable: false);
  }
}
