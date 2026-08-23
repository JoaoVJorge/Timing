import "package:equatable/equatable.dart";

/// One member's completion of a group activity, as returned by the
/// `group_activity_progress` RPC. [reached] is the "atingiu a meta" flag the
/// group tab shows; [progress]/[target] back a progress label.
class GroupActivityProgressEntity extends Equatable {
  const GroupActivityProgressEntity({
    required this.activityId,
    required this.kind,
    required this.name,
    required this.memberId,
    required this.progress,
    required this.target,
    required this.reached,
    this.focusSeconds = 0,
    this.restMinutes = 60,
    this.focusSessionCount = 1,
  });

  factory GroupActivityProgressEntity.fromMap(Map<String, dynamic> map) =>
      GroupActivityProgressEntity(
        activityId: map["activity_id"] as String? ?? "",
        kind: map["kind"] as String? ?? "subject",
        name: map["name"] as String? ?? "",
        memberId: map["member_id"] as String? ?? "",
        progress: (map["progress"] as num?)?.toInt() ?? 0,
        target: (map["target"] as num?)?.toInt() ?? 0,
        reached: map["reached"] as bool? ?? false,
        focusSeconds:
            (map["focus_seconds"] as num?)?.toInt() ??
            (map["focusSeconds"] as num?)?.toInt() ??
            0,
        restMinutes:
            (map["rest_minutes"] as num?)?.toInt() ??
            (map["restMinutes"] as num?)?.toInt() ??
            60,
        focusSessionCount:
            (map["focus_session_count"] as num?)?.toInt() ??
            (map["focusSessionCount"] as num?)?.toInt() ??
            1,
      );

  final String activityId;
  final String kind;
  final String name;
  final String memberId;
  final int progress;
  final int target;
  final bool reached;
  final int focusSeconds;
  final int restMinutes;
  final int focusSessionCount;

  bool get isGoal => kind == "goal";

  @override
  List<Object?> get props => [
    activityId,
    kind,
    name,
    memberId,
    progress,
    target,
    reached,
    focusSeconds,
    restMinutes,
    focusSessionCount,
  ];
}
