import "dart:convert";

import "package:equatable/equatable.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";

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
    required this.wallpaperIndex,
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
    restMinutes: map["restMinutes"] as int? ?? defaultRestMinutes,
    wallpaperIndex: map["wallpaperIndex"] as int? ?? 0,
  );

  static const int defaultRestMinutes = 5;

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
  final int wallpaperIndex;

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
    "wallpaperIndex": wallpaperIndex,
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
    int? wallpaperIndex,
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
    wallpaperIndex: wallpaperIndex ?? this.wallpaperIndex,
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
    wallpaperIndex,
  ];
}
