import "package:equatable/equatable.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";

/// A pending invitation for the current user to join a group, shown in the
/// Friends area next to friend requests.
class GroupInvitationEntity extends Equatable {
  const GroupInvitationEntity({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.theme,
    required this.inviterId,
    required this.inviterName,
    this.createdAt,
  });

  factory GroupInvitationEntity.fromMap(Map<String, dynamic> map) =>
      GroupInvitationEntity(
        id: map["id"] as String,
        groupId: map["group_id"] as String,
        groupName: map["group_name"] as String? ?? "",
        theme: GroupThemeType.byName(map["group_theme"] as String?),
        inviterId: map["inviter_id"] as String? ?? "",
        inviterName: map["inviter_name"] as String? ?? "Timing",
        createdAt: DateTime.tryParse(map["created_at"] as String? ?? ""),
      );

  final String id;
  final String groupId;
  final String groupName;
  final GroupThemeType theme;
  final String inviterId;
  final String inviterName;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    groupId,
    groupName,
    theme,
    inviterId,
    inviterName,
    createdAt,
  ];
}
