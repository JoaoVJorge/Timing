import "dart:convert";

import "package:equatable/equatable.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";

class GroupEntity extends Equatable {
  const GroupEntity({
    required this.id,
    required this.name,
    required this.theme,
    required this.members,
  });

  factory GroupEntity.fromJson(String source) => GroupEntity.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory GroupEntity.fromMap(Map<String, dynamic> map) => GroupEntity(
    id: map["id"] as String,
    name: map["name"] as String,
    theme: GroupThemeType.byName(map["theme"] as String?),
    members: (map["members"] as List<dynamic>)
        .map((item) => GroupMemberEntity.fromMap(item as Map<String, dynamic>))
        .toList(),
  );

  final String id;
  final String name;
  final GroupThemeType theme;
  final List<GroupMemberEntity> members;

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "theme": theme.name,
    "members": members.map((member) => member.toMap()).toList(),
  };

  String toJson() => jsonEncode(toMap());

  @override
  List<Object?> get props => [id, name, theme, members];
}
