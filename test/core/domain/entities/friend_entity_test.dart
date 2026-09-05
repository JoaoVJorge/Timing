import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/friend_entity.dart";

void main() {
  const FriendEntity baseFriend = FriendEntity(
    id: "friend-id",
    friendshipId: "friendship-id",
    name: "Friend",
    handle: "@friend",
    colorValue: 0xFF112233,
  );

  test("online presence requires both the flag and a recent heartbeat", () {
    final DateTime now = DateTime.utc(2026, 9, 5, 12);

    expect(
      baseFriend
          .copyWith(
            isOnline: true,
            lastSeenAt: now.subtract(const Duration(seconds: 45)),
          )
          .isOnlineAt(now),
      isTrue,
    );
    expect(
      baseFriend
          .copyWith(
            isOnline: false,
            lastSeenAt: now.subtract(const Duration(seconds: 10)),
          )
          .isOnlineAt(now),
      isFalse,
    );
    expect(
      baseFriend
          .copyWith(
            isOnline: true,
            lastSeenAt: now.subtract(const Duration(minutes: 2)),
          )
          .isOnlineAt(now),
      isFalse,
    );
  });
}
