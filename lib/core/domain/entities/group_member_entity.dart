import "dart:convert";

import "package:equatable/equatable.dart";
import "package:timing/core/domain/enums/leaderboard_period_type.dart";

class GroupMemberEntity extends Equatable {
  const GroupMemberEntity({
    required this.id,
    required this.name,
    required this.avatarColorValue,
    required this.todaySeconds,
    required this.weekSeconds,
    required this.monthSeconds,
    int? totalSeconds,
    this.avatar = "",
    this.avatarIconIndex,
    this.role = "member",
    this.joinedAt,
  }) : totalSeconds = totalSeconds ?? monthSeconds;

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
    totalSeconds: map["totalSeconds"] as int? ?? map["totalScore"] as int?,
    avatar: map["avatar"] as String? ?? "",
    avatarIconIndex: map["avatarIconIndex"] as int?,
    role: map["role"] as String? ?? "member",
    joinedAt: DateTime.tryParse(map["joinedAt"] as String? ?? ""),
  );

  final String id;
  final String name;
  final int avatarColorValue;
  final int todaySeconds;
  final int weekSeconds;
  final int monthSeconds;
  final int totalSeconds;
  final String avatar;
  final int? avatarIconIndex;
  final String role;
  final DateTime? joinedAt;

  GroupMemberEntity withScores({
    required int today,
    required int week,
    required int month,
    required int total,
  }) => GroupMemberEntity(
    id: id,
    name: name,
    avatarColorValue: avatarColorValue,
    todaySeconds: today,
    weekSeconds: week,
    monthSeconds: month,
    totalSeconds: total,
    avatar: avatar,
    avatarIconIndex: avatarIconIndex,
    role: role,
    joinedAt: joinedAt,
  );

  int get todayScore => todaySeconds;

  int get weekScore => weekSeconds;

  int get monthScore => monthSeconds;

  int get totalScore => totalSeconds;

  int secondsFor(LeaderboardPeriodType period) => switch (period) {
    LeaderboardPeriodType.today => todaySeconds,
    LeaderboardPeriodType.thisWeek => weekSeconds,
    LeaderboardPeriodType.thisMonth => monthSeconds,
    LeaderboardPeriodType.total => totalSeconds,
  };

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "avatarColorValue": avatarColorValue,
    "todaySeconds": todaySeconds,
    "weekSeconds": weekSeconds,
    "monthSeconds": monthSeconds,
    "totalSeconds": totalSeconds,
    "avatar": avatar,
    "avatarIconIndex": avatarIconIndex,
    "role": role,
    "joinedAt": joinedAt?.toIso8601String(),
    "todayScore": todayScore,
    "weekScore": weekScore,
    "monthScore": monthScore,
    "totalScore": totalScore,
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
    totalSeconds,
    avatar,
    avatarIconIndex,
    role,
    joinedAt,
  ];
}
