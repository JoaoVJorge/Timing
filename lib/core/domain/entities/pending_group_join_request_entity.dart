import "package:equatable/equatable.dart";
import "package:timing/core/domain/entities/group_invitation_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";

/// A request the current user has already sent to a group's leader.
///
/// Unlike [GroupInvitationEntity], this is only a receipt: the user has
/// already answered or followed a link, so there is nothing left to accept.
class PendingGroupJoinRequestEntity extends Equatable {
  const PendingGroupJoinRequestEntity({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.theme,
    this.createdAt,
  });

  factory PendingGroupJoinRequestEntity.fromMap(Map<String, dynamic> map) =>
      PendingGroupJoinRequestEntity(
        id: map["id"] as String? ?? "",
        groupId: map["group_id"] as String? ?? "",
        groupName: map["group_name"] as String? ?? "",
        theme: GroupThemeType.byName(map["group_theme"] as String?),
        createdAt: DateTime.tryParse(map["created_at"] as String? ?? ""),
      );

  final String id;
  final String groupId;
  final String groupName;
  final GroupThemeType theme;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, groupId, groupName, theme, createdAt];
}
