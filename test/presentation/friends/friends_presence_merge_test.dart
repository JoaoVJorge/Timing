import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/friend_entity.dart";
import "package:timing/core/domain/entities/friend_presence_entity.dart";
import "package:timing/presentation/friends/friends_controller.dart";

void main() {
  test("presence merge is materialized before replacing the source RxList", () {
    final RxList<FriendEntity> friends = <FriendEntity>[
      const FriendEntity(
        id: "one",
        friendshipId: "friendship-one",
        name: "One",
        handle: "@one",
        colorValue: 0xFF112233,
      ),
      const FriendEntity(
        id: "two",
        friendshipId: "friendship-two",
        name: "Two",
        handle: "@two",
        colorValue: 0xFF445566,
      ),
    ].obs;
    final DateTime seenAt = DateTime.utc(2026, 9, 5, 12);

    final List<FriendEntity> updated = mergeFriendPresences(friends, [
      FriendPresenceEntity(id: "one", isOnline: true, lastSeenAt: seenAt),
    ]);
    friends.assignAll(updated);

    expect(friends.map((friend) => friend.id), ["one", "two"]);
    expect(friends.first.isOnline, isTrue);
    expect(friends.first.lastSeenAt, seenAt);
  });
}
