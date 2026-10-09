import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/repositories/friends_repository.dart";
import "package:timing/core/domain/entities/friend_entity.dart";
import "package:timing/core/domain/entities/friend_presence_entity.dart";
import "package:timing/core/domain/entities/friends_social_entity.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/social/social_store.dart";

const _offline = OfflineError();

FriendEntity _person(String id, {String friendshipId = ""}) => FriendEntity(
  id: id,
  friendshipId: friendshipId,
  name: id,
  handle: "@$id",
  colorValue: 0,
);

class _Friends extends Fake implements FriendsRepository {
  FriendsSocialEntity social = const FriendsSocialEntity.empty();
  Either<AppError, void> writes = const Right(null);
  bool socialFails = false;
  List<FriendPresenceEntity> presences = const [];
  final List<String> calls = [];

  @override
  Future<Either<AppError, FriendsSocialEntity>> getSocial() async {
    calls.add("getSocial");
    return socialFails ? const Left(_offline) : Right(social);
  }

  @override
  Future<Either<AppError, List<FriendPresenceEntity>>> getPresences(
    List<String> friendIds,
  ) async {
    calls.add("getPresences:${friendIds.join(",")}");
    return Right(presences);
  }

  @override
  Future<Either<AppError, void>> sendFriendRequest(String addresseeId) async {
    calls.add("send:$addresseeId");
    return writes;
  }

  @override
  Future<Either<AppError, void>> acceptRequest(String friendshipId) async {
    calls.add("accept:$friendshipId");
    return writes;
  }

  @override
  Future<Either<AppError, void>> declineRequest(String friendshipId) async {
    calls.add("decline:$friendshipId");
    return writes;
  }

  @override
  Future<Either<AppError, void>> cancelSentRequest({
    required String addresseeId,
    String friendshipId = "",
  }) async {
    calls.add("cancel:$addresseeId:$friendshipId");
    return writes;
  }

  @override
  Future<Either<AppError, void>> removeFriend({
    required String friendId,
    String friendshipId = "",
  }) async {
    calls.add("remove:$friendId:$friendshipId");
    return writes;
  }
}

void main() {
  late _Friends repository;
  late SocialStore store;

  setUp(() {
    repository = _Friends();
    store = SocialStore(friendsRepository: repository);
  });

  group("load", () {
    test("fills friends, both kinds of request and the invite code", () async {
      repository.social = FriendsSocialEntity(
        inviteCode: "ABC123",
        friends: [_person("ana")],
        requests: [_person("bia")],
        sentRequests: [_person("caio")],
      );

      await store.load();

      expect(store.inviteCode.value, "ABC123");
      expect(store.isFriend("ana"), isTrue);
      expect(store.incomingRequestFrom("bia"), isNotNull);
      expect(store.sentRequestTo("caio"), isNotNull);
      expect(store.isFriend("bia"), isFalse);
    });

    test("a failed read reports it and keeps what was there", () async {
      store.friends.add(_person("ana"));
      repository.socialFails = true;

      final result = await store.load();

      expect(result.isLeft(), isTrue);
      expect(store.friends, hasLength(1));
    });
  });

  group("sending a request", () {
    test("shows it as sent at once", () async {
      await store.sendRequest(_person("dani"));

      expect(repository.calls, ["send:dani"]);
      expect(store.sentRequestTo("dani"), isNotNull);
    });

    test("a refused request is not shown as sent", () async {
      repository.writes = const Left(RejectedError(code: "23505"));

      final result = await store.sendRequest(_person("dani"));

      expect(result.isLeft(), isTrue);
      expect(store.sentRequests, isEmpty);
    });
  });

  test("cancelling a sent request takes it off the list", () async {
    store.sentRequests.add(_person("dani", friendshipId: "f1"));

    await store.cancelSentRequest(store.sentRequestTo("dani")!);

    expect(repository.calls, ["cancel:dani:f1"]);
    expect(store.sentRequests, isEmpty);
  });

  test("declining a request takes it off the list", () async {
    store.incomingRequests.add(_person("bia", friendshipId: "f2"));

    await store.declineRequest(store.incomingRequestFrom("bia")!);

    expect(repository.calls, ["decline:f2"]);
    expect(store.incomingRequests, isEmpty);
  });

  test("removing a friend takes them off the list", () async {
    store.friends.add(_person("ana", friendshipId: "f3"));

    await store.removeFriend(store.friendWith("ana")!);

    expect(repository.calls, ["remove:ana:f3"]);
    expect(store.friends, isEmpty);
  });

  test("a write that fails leaves every list as it was", () async {
    store.friends.add(_person("ana", friendshipId: "f3"));
    store.incomingRequests.add(_person("bia", friendshipId: "f2"));
    store.sentRequests.add(_person("caio", friendshipId: "f1"));
    repository.writes = const Left(_offline);

    await store.removeFriend(store.friends.single);
    await store.declineRequest(store.incomingRequests.single);
    await store.acceptRequest(store.incomingRequests.single);
    await store.cancelSentRequest(store.sentRequests.single);

    expect(store.friends, hasLength(1));
    expect(store.incomingRequests, hasLength(1));
    expect(store.sentRequests, hasLength(1));
    // A refused acceptance must not go on to read the profiles.
    expect(repository.calls, isNot(contains("getSocial")));
  });

  test("an accepted request becomes a friend, with the profile the backend "
      "now lets this user see", () async {
    final FriendEntity request = _person("bia", friendshipId: "f2");
    store.incomingRequests.add(request);
    repository.social = FriendsSocialEntity(
      inviteCode: "",
      friends: [request.copyWith(isOnline: true)],
      requests: const [],
      sentRequests: const [],
    );

    await store.acceptRequest(request);

    expect(repository.calls, ["accept:f2", "getSocial"]);
    expect(store.incomingRequests, isEmpty);
    expect(store.friends.single.isOnline, isTrue);
  });

  test("presence is refreshed for the friends on the list", () async {
    store.friends.addAll([_person("ana"), _person("bia")]);
    repository.presences = [
      const FriendPresenceEntity(id: "bia", isOnline: true, lastSeenAt: null),
    ];

    await store.refreshPresences();

    expect(repository.calls, ["getPresences:ana,bia"]);
    expect(store.friendWith("ana")!.isOnline, isFalse);
    expect(store.friendWith("bia")!.isOnline, isTrue);
  });

  test("with no friends, presence is not asked for", () async {
    await store.refreshPresences();

    expect(repository.calls, isEmpty);
  });

  test(
    "a group joined from one screen reaches whoever lists the groups",
    () async {
      const GroupEntity group = GroupEntity(
        id: "g1",
        name: "Study",
        theme: GroupThemeType.studying,
        members: [],
      );
      final Future<GroupEntity> heard = store.joinedGroups.first;

      store.announceJoinedGroup(group);

      expect(await heard, same(group));
    },
  );
}
