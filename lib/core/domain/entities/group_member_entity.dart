import "dart:convert";

import "package:equatable/equatable.dart";
import "package:help_out/core/domain/enums/leaderboard_period_type.dart";

class GroupMemberEntity extends Equatable {
  const GroupMemberEntity({
    required this.id,
    required this.name,
    required this.avatarColorValue,
    required this.todaySeconds,
    required this.weekSeconds,
    required this.monthSeconds,
    this.avatar = "",
    this.role = "member",
    this.joinedAt,
  });

  factory GroupMemberEntity.fromJson(String source) =>
      GroupMemberEntity.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory GroupMemberEntity.fromMap(
    Map<String, dynamic> map,
  ) => GroupMemberEntity(
    id: map["id"] as String,
    name: map["name"] as String,
    avatarColorValue: map["avatarColorValue"] as int,
    todaySeconds: map["todaySeconds"] as int? ?? map["todayScore"] as int? ?? 0,
    weekSeconds: map["weekSeconds"] as int? ?? map["weekScore"] as int? ?? 0,
    monthSeconds: map["monthSeconds"] as int? ?? map["monthScore"] as int? ?? 0,
    avatar: map["avatar"] as String? ?? "",
    role: map["role"] as String? ?? "member",
    joinedAt: DateTime.tryParse(map["joinedAt"] as String? ?? ""),
  );

  final String id;
  final String name;
  final int avatarColorValue;
  final int todaySeconds;
  final int weekSeconds;
  final int monthSeconds;
  final String avatar;
  final String role;
  final DateTime? joinedAt;

  int get todayScore => todaySeconds;

  int get weekScore => weekSeconds;

  int get monthScore => monthSeconds;

  int secondsFor(LeaderboardPeriodType period) => switch (period) {
    LeaderboardPeriodType.today => todaySeconds,
    LeaderboardPeriodType.thisWeek => weekSeconds,
    LeaderboardPeriodType.thisMonth => monthSeconds,
  };

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "avatarColorValue": avatarColorValue,
    "todaySeconds": todaySeconds,
    "weekSeconds": weekSeconds,
    "monthSeconds": monthSeconds,
    "avatar": avatar,
    "role": role,
    "joinedAt": joinedAt?.toIso8601String(),
    "todayScore": todayScore,
    "weekScore": weekScore,
    "monthScore": monthScore,
  };

  String toJson() => jsonEncode(toMap());

  @override
  List<Object?> get props => [
    id,
    name,
    avatarColorValue,
    todaySeconds,
    weekSeconds,
    monthSeconds,
    avatar,
    role,
    joinedAt,
  ];
}
