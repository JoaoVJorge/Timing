import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/friend_entity.dart";
import "package:timing/core/domain/entities/friends_social_entity.dart";

void main() {
  group("FriendEntity toMap/fromMap", () {
    test("round-trips every field", () {
      final entity = FriendEntity(
        id: "friend-1",
        friendshipId: "fs-1",
        name: "Amigo",
        handle: "@amigo",
        colorValue: 0xFF112233,
        avatarIconIndex: 3,
        profilePhotoBase64: "abc123",
        isOnline: true,
        lastSeenAt: DateTime.utc(2026, 9, 20, 12),
      );

      final decoded = FriendEntity.fromMap(entity.toMap());

      expect(decoded, entity);
    });

    test("round-trips with null optional fields", () {
      const entity = FriendEntity(
        id: "friend-1",
        friendshipId: "fs-1",
        name: "Amigo",
        handle: "@amigo",
        colorValue: 0xFF112233,
      );

      final decoded = FriendEntity.fromMap(entity.toMap());

      expect(decoded, entity);
    });
  });

  group("FriendsSocialEntity toMap/fromMap", () {
    test("round-trips nested friend lists", () {
      const requester = FriendEntity(
        id: "u1",
        friendshipId: "fs-1",
        name: "A",
        handle: "@a",
        colorValue: 1,
      );
      const sent = FriendEntity(
        id: "u2",
        friendshipId: "fs-2",
        name: "B",
        handle: "@b",
        colorValue: 2,
      );
      const friend = FriendEntity(
        id: "u3",
        friendshipId: "fs-3",
        name: "C",
        handle: "@c",
        colorValue: 3,
      );
      const entity = FriendsSocialEntity(
        inviteCode: "CODE123",
        requests: [requester],
        sentRequests: [sent],
        friends: [friend],
      );

      final decoded = FriendsSocialEntity.fromMap(entity.toMap());

      expect(decoded, entity);
    });

    test("round-trips the empty factory", () {
      const entity = FriendsSocialEntity.empty();

      final decoded = FriendsSocialEntity.fromMap(entity.toMap());

      expect(decoded, entity);
    });
  });
}
