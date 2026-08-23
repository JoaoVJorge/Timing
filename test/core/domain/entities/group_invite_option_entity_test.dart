import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/group_invite_option_entity.dart";

void main() {
  test("copyWith changes the invite state without losing friend data", () {
    const GroupInviteOptionEntity available = GroupInviteOptionEntity(
      friendId: "friend-1",
      friendName: "Amanda",
      accentColorValue: 123,
      status: GroupInviteStatus.available,
    );

    final GroupInviteOptionEntity invited = available.copyWith(
      status: GroupInviteStatus.invited,
      invitationId: "invite-1",
    );

    expect(invited.friendId, available.friendId);
    expect(invited.friendName, available.friendName);
    expect(invited.accentColorValue, available.accentColorValue);
    expect(invited.status, GroupInviteStatus.invited);
    expect(invited.invitationId, "invite-1");
  });

  test("copyWith can clear a canceled invitation id", () {
    const GroupInviteOptionEntity invited = GroupInviteOptionEntity(
      friendId: "friend-1",
      friendName: "Amanda",
      accentColorValue: 123,
      status: GroupInviteStatus.invited,
      invitationId: "invite-1",
    );

    final GroupInviteOptionEntity available = invited.copyWith(
      status: GroupInviteStatus.available,
      clearInvitationId: true,
    );

    expect(available.status, GroupInviteStatus.available);
    expect(available.invitationId, isNull);
  });
}
