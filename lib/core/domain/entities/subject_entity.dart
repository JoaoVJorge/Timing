import "dart:convert";

import "package:equatable/equatable.dart";
import "package:timing/core/domain/enums/time_category_type.dart";

enum SubjectActivityType {
  daily,
  permanent;

  factory SubjectActivityType.fromName(String? name) =>
      SubjectActivityType.values.firstWhere(
        (type) => type.name == name,
        orElse: () => SubjectActivityType.daily,
      );
}

class SubjectEntity extends Equatable {
  const SubjectEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.colorValue,
    required this.totalSeconds,
    required this.goalSeconds,
    required this.currentPages,
    required this.goalPages,
    required this.notes,
    required this.iconName,
    required this.restMinutes,
    required this.focusSessionCount,
    required this.wallpaperIndex,
    this.activityType = SubjectActivityType.daily,
    this.createdAt,
    this.groupId,
  });

  factory SubjectEntity.fromJson(String source) =>
      SubjectEntity.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory SubjectEntity.fromMap(Map<String, dynamic> map) => SubjectEntity(
    id: map["id"] as String,
    name: map["name"] as String,
    category: TimeCategoryType.values.byName(map["category"] as String),
    colorValue: map["colorValue"] as int,
    totalSeconds: map["totalSeconds"] as int,
    goalSeconds: map["goalSeconds"] as int? ?? 0,
    currentPages: map["currentPages"] as int? ?? 0,
    goalPages: map["goalPages"] as int? ?? 0,
    notes: map["notes"] as String? ?? "",
    iconName: map["iconName"] as String? ?? "",
    restMinutes: map["restMinutes"] as int? ?? defaultRestSeconds,
    focusSessionCount: map["focusSessionCount"] as int? ?? 1,
    wallpaperIndex: map["wallpaperIndex"] as int? ?? 0,
    activityType: SubjectActivityType.fromName(map["activityType"] as String?),
    createdAt: DateTime.tryParse(map["createdAt"] as String? ?? ""),
    groupId: (map["groupId"] as String?)?.isEmpty ?? true
        ? null
        : map["groupId"] as String?,
  );

  static const int defaultRestSeconds = 60;
  static const int defaultRestMinutes = defaultRestSeconds;

  final String id;
  final String name;
  final TimeCategoryType category;
  final int colorValue;
  final int totalSeconds;
  final int goalSeconds;
  final int currentPages;
  final int goalPages;
  final String notes;
  final String iconName;
  final int restMinutes;
  final int focusSessionCount;
  final int wallpaperIndex;
  final SubjectActivityType activityType;
  final DateTime? createdAt;

  /// Non-null when this subject is a copy handed out by a group. Such copies
  /// cannot be deleted while the user is still a member (enforced by the
  /// backend delete policy) and are removed on leaving the group.
  final String? groupId;

  /// Whether this subject belongs to a group and is therefore protected from
  /// manual deletion.
  bool get isFromGroup => groupId != null && groupId!.isNotEmpty;

  /// Number of focus sessions, never below one.
  int get sessionCount => focusSessionCount > 0 ? focusSessionCount : 1;

  /// The day's total study goal: each session runs [goalSeconds], so a "2x30"
  /// subject targets 60 minutes, not 30.
  int get totalGoalSeconds => goalSeconds * sessionCount;

  /// Legacy data stored break duration in minutes in this field. New subjects
  /// store seconds, so small saved values are upgraded at read/use time.
  int get restSeconds => restMinutes <= 20 ? restMinutes * 60 : restMinutes;

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "category": category.name,
    "colorValue": colorValue,
    "totalSeconds": totalSeconds,
    "goalSeconds": goalSeconds,
    "currentPages": currentPages,
    "goalPages": goalPages,
    "notes": notes,
    "iconName": iconName,
    "restMinutes": restMinutes,
    "focusSessionCount": focusSessionCount,
    "wallpaperIndex": wallpaperIndex,
    "activityType": activityType.name,
    "createdAt": createdAt?.toIso8601String(),
    "groupId": groupId,
  };

  String toJson() => jsonEncode(toMap());

  SubjectEntity copyWith({
    String? name,
    int? colorValue,
    int? totalSeconds,
    int? goalSeconds,
    int? currentPages,
    int? goalPages,
    String? notes,
    String? iconName,
    int? restMinutes,
    int? focusSessionCount,
    int? wallpaperIndex,
    SubjectActivityType? activityType,
    DateTime? createdAt,
    String? groupId,
  }) => SubjectEntity(
    id: id,
    name: name ?? this.name,
    category: category,
    colorValue: colorValue ?? this.colorValue,
    totalSeconds: totalSeconds ?? this.totalSeconds,
    goalSeconds: goalSeconds ?? this.goalSeconds,
    currentPages: currentPages ?? this.currentPages,
    goalPages: goalPages ?? this.goalPages,
    notes: notes ?? this.notes,
    iconName: iconName ?? this.iconName,
    restMinutes: restMinutes ?? this.restMinutes,
    focusSessionCount: focusSessionCount ?? this.focusSessionCount,
    wallpaperIndex: wallpaperIndex ?? this.wallpaperIndex,
    activityType: activityType ?? this.activityType,
    createdAt: createdAt ?? this.createdAt,
    groupId: groupId ?? this.groupId,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    colorValue,
    totalSeconds,
    goalSeconds,
    currentPages,
    goalPages,
    notes,
    iconName,
    restMinutes,
    focusSessionCount,
    wallpaperIndex,
    activityType,
    createdAt,
    groupId,
  ];
}
