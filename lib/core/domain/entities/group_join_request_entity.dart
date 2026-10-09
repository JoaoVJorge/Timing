import "package:equatable/equatable.dart";

/// Someone waiting for the group's leader to let them in: they used the
/// group's link, or accepted an invitation from a member who is not the
/// leader. [invitedByName] is null when they came through the link.
class GroupJoinRequestEntity extends Equatable {
  const GroupJoinRequestEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.accentColorValue,
    this.avatar = "",
    this.avatarIconIndex,
    this.invitedById,
    this.invitedByName,
    this.createdAt,
  });

  factory GroupJoinRequestEntity.fromMap(Map<String, dynamic> map) =>
      GroupJoinRequestEntity(
        id: map["id"] as String? ?? "",
        userId: map["user_id"] as String? ?? "",
        userName: map["user_name"] as String? ?? "Timing User",
        accentColorValue:
            (map["accent_color_value"] as num?)?.toInt() ?? 4294940679,
        avatar: map["profile_photo_base64"] as String? ?? "",
        avatarIconIndex: (map["avatar_icon_index"] as num?)?.toInt(),
        invitedById: map["invited_by"] as String?,
        invitedByName:
            (map["invited_by_name"] as String?)?.trim().isEmpty ?? true
            ? null
            : (map["invited_by_name"] as String?)?.trim(),
        createdAt: DateTime.tryParse(map["created_at"] as String? ?? ""),
      );

  final String id;
  final String userId;
  final String userName;
  final int accentColorValue;
  final String avatar;
  final int? avatarIconIndex;
  final String? invitedById;
  final String? invitedByName;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    accentColorValue,
    avatar,
    avatarIconIndex,
    invitedById,
    invitedByName,
    createdAt,
  ];
}
