import "package:equatable/equatable.dart";

enum GroupInviteStatus {
  available,
  invited,
  member;

  static GroupInviteStatus byName(String value) => switch (value) {
    "invited" => GroupInviteStatus.invited,
    "member" => GroupInviteStatus.member,
    _ => GroupInviteStatus.available,
  };
}

class GroupInviteOptionEntity extends Equatable {
  const GroupInviteOptionEntity({
    required this.friendId,
    required this.friendName,
    required this.accentColorValue,
    required this.status,
    this.invitationId,
  });

  factory GroupInviteOptionEntity.fromMap(Map<String, dynamic> map) =>
      GroupInviteOptionEntity(
        friendId: map["friend_id"] as String? ?? "",
        friendName: map["friend_name"] as String? ?? "HelpOut User",
        accentColorValue:
            (map["accent_color_value"] as num?)?.toInt() ?? 4294940679,
        status: GroupInviteStatus.byName(map["status"] as String? ?? ""),
        invitationId: map["invitation_id"] as String?,
      );

  final String friendId;
  final String friendName;
  final int accentColorValue;
  final GroupInviteStatus status;
  final String? invitationId;

  bool get isInvited => status == GroupInviteStatus.invited;
  bool get isMember => status == GroupInviteStatus.member;

  @override
  List<Object?> get props => [
    friendId,
    friendName,
    accentColorValue,
    status,
    invitationId,
  ];
}
