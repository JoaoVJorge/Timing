import "package:equatable/equatable.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";

class SentGroupInvitationEntity extends Equatable {
  const SentGroupInvitationEntity({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.theme,
    required this.inviteeId,
    required this.inviteeName,
    required this.inviteeColorValue,
    this.createdAt,
  });

  final String id;
  final String groupId;
  final String groupName;
  final GroupThemeType theme;
  final String inviteeId;
  final String inviteeName;
  final int inviteeColorValue;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    groupId,
    groupName,
    theme,
    inviteeId,
    inviteeName,
    inviteeColorValue,
    createdAt,
  ];
}
