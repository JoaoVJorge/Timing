import "dart:convert";

import "package:equatable/equatable.dart";
import "package:timing/core/domain/entities/group_member_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";

class GroupEntity extends Equatable {
  const GroupEntity({
    required this.id,
    required this.name,
    required this.theme,
    required this.members,
    this.description = "",
    this.ownerId = "",
    this.createdAt,
    this.inviteCode = "",
    this.privacy = "inviteOnly",
    this.createdActivityId,
    this.colorValue,
  });

  factory GroupEntity.fromJson(String source) =>
      GroupEntity.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory GroupEntity.fromMap(Map<String, dynamic> map) => GroupEntity(
    id: map["id"] as String,
    name: map["name"] as String,
    theme: GroupThemeType.byName(map["theme"] as String?),
    members: (map["members"] as List<dynamic>)
        .map((item) => GroupMemberEntity.fromMap(item as Map<String, dynamic>))
        .toList(),
    description: map["description"] as String? ?? "",
    ownerId: map["ownerId"] as String? ?? "",
    createdAt: DateTime.tryParse(map["createdAt"] as String? ?? ""),
    inviteCode: map["inviteCode"] as String? ?? "",
    privacy: map["privacy"] as String? ?? "inviteOnly",
    createdActivityId: map["createdActivityId"] as String?,
    colorValue: (map["colorValue"] as num?)?.toInt(),
  );

  final String id;
  final String name;
  final GroupThemeType theme;
  final List<GroupMemberEntity> members;
  final String description;
  final String ownerId;
  final DateTime? createdAt;
  final String inviteCode;
  final String privacy;
  final String? createdActivityId;
  final int? colorValue;

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "theme": theme.name,
    "members": members.map((member) => member.toMap()).toList(),
    "description": description,
    "ownerId": ownerId,
    "createdAt": createdAt?.toIso8601String(),
    "inviteCode": inviteCode,
    "privacy": privacy,
    "createdActivityId": createdActivityId,
    "colorValue": colorValue,
  };

  GroupEntity copyWithMembers(List<GroupMemberEntity> members) => GroupEntity(
    id: id,
    name: name,
    theme: theme,
    members: members,
    description: description,
    ownerId: ownerId,
    createdAt: createdAt,
    inviteCode: inviteCode,
    privacy: privacy,
    createdActivityId: createdActivityId,
    colorValue: colorValue,
  );

  String toJson() => jsonEncode(toMap());

  @override
  List<Object?> get props => [
    id,
    name,
    theme,
    members,
    description,
    ownerId,
    createdAt,
    inviteCode,
    privacy,
    createdActivityId,
    colorValue,
  ];
}
