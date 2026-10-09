import "dart:async";

import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/friends_repository.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/friend_entity.dart";
import "package:timing/core/domain/entities/friends_social_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/social/social_store.dart";
import "package:timing/presentation/friends/friends_controller.dart";

class _AppController extends Fake implements AppController {}

class _GroupsRepository extends Fake implements GroupsRepository {}

class _Navigator extends Fake implements AppNavigator {
  int errors = 0;
  @override
  void showErrorSnackBar([String? text]) {
    errors++;
  }
}

class _Friends extends Fake implements FriendsRepository {
  final social = Completer<Either<AppError, FriendsSocialEntity>>();
  int acceptCalls = 0;
  int socialCalls = 0;
  Either<AppError, void> acceptResult = const Right(null);

  @override
  Future<Either<AppError, void>> acceptRequest(String id) async {
    expect(id, "request-1");
    acceptCalls++;
    return acceptResult;
  }

  @override
  Future<Either<AppError, FriendsSocialEntity>> getSocial() {
    socialCalls++;
    return social.future;
  }
}

const placeholder = FriendEntity(
  id: "friend-1",
  friendshipId: "request-1",
  name: "Timing User",
  handle: "@friend",
  colorValue: 0,
);
const hydrated = FriendEntity(
  id: "friend-1",
  friendshipId: "request-1",
  name: "Ana",
  handle: "@ana",
  colorValue: 123,
  avatarIconIndex: 2,
  profilePhotoBase64: "photo",
);
const failure = UnexpectedError(cause: "offline", stackTrace: StackTrace.empty);

void main() {
  late _Friends friends;
  late _Navigator navigator;
  late FriendsController controller;
  setUp(() {
    friends = _Friends();
    navigator = _Navigator();
    controller = FriendsController(
      socialStore: SocialStore(friendsRepository: friends),
      friendsRepository: friends,
      groupsRepository: _GroupsRepository(),
      appController: _AppController(),
      appNavigator: navigator,
    );
    controller.requests.add(placeholder);
  });

  test(
    "acceptance hydrates the profile before showing the new friend",
    () async {
      final pending = controller.acceptRequest(placeholder);
      await Future<void>.delayed(Duration.zero);
      expect(friends.acceptCalls, 1);
      expect(friends.socialCalls, 1);
      expect(controller.friends, isEmpty);
      expect(controller.acceptingFriendRequestIds, contains(placeholder.id));
      await controller.acceptRequest(placeholder);
      expect(friends.acceptCalls, 1);
      friends.social.complete(
        const Right(
          FriendsSocialEntity(
            inviteCode: "",
            requests: [],
            sentRequests: [],
            friends: [hydrated],
          ),
        ),
      );
      await pending;
      expect(controller.friends, [hydrated]);
      expect(controller.requests, isEmpty);
      expect(controller.acceptingFriendRequestIds, isEmpty);
    },
  );

  test("failed profile refresh preserves successful acceptance", () async {
    friends.social.complete(const Left(failure));
    await controller.acceptRequest(placeholder);
    expect(controller.friends, [placeholder]);
    expect(controller.requests, isEmpty);
    expect(navigator.errors, 0);
    expect(controller.acceptingFriendRequestIds, isEmpty);
  });

  test(
    "offline snapshot without the new friend preserves acceptance",
    () async {
      friends.social.complete(const Right(FriendsSocialEntity.empty()));
      await controller.acceptRequest(placeholder);
      expect(controller.friends, [placeholder]);
      expect(controller.requests, isEmpty);
    },
  );

  test(
    "rejected acceptance keeps the request and does not fetch profiles",
    () async {
      friends.acceptResult = const Left(failure);
      await controller.acceptRequest(placeholder);
      expect(controller.requests, [placeholder]);
      expect(controller.friends, isEmpty);
      expect(friends.socialCalls, 0);
      expect(navigator.errors, 1);
      expect(controller.acceptingFriendRequestIds, isEmpty);
    },
  );
}
