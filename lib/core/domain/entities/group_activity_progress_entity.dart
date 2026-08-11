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
      );

  final String activityId;
  final String kind;
  final String name;
  final String memberId;
  final int progress;
  final int target;
  final bool reached;

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
  ];
}
