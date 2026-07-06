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
  });

  factory GroupMemberEntity.fromJson(String source) => GroupMemberEntity.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory GroupMemberEntity.fromMap(Map<String, dynamic> map) => GroupMemberEntity(
    id: map["id"] as String,
    name: map["name"] as String,
    avatarColorValue: map["avatarColorValue"] as int,
    todaySeconds: map["todaySeconds"] as int,
    weekSeconds: map["weekSeconds"] as int,
    monthSeconds: map["monthSeconds"] as int,
  );

  final String id;
  final String name;
  final int avatarColorValue;
  final int todaySeconds;
  final int weekSeconds;
  final int monthSeconds;

  String get avatarUrl => "https://i.pravatar.cc/150?u=$id";

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
  };

  String toJson() => jsonEncode(toMap());

  @override
  List<Object?> get props => [id, name, avatarColorValue, todaySeconds, weekSeconds, monthSeconds];
}
