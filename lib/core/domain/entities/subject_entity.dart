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
  });

  factory SubjectEntity.fromJson(String source) => SubjectEntity.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory SubjectEntity.fromMap(Map<String, dynamic> map) => SubjectEntity(
    id: map["id"] as String,
    name: map["name"] as String,
    category: TimeCategoryType.values.byName(map["category"] as String),
    colorValue: map["colorValue"] as int,
    totalSeconds: map["totalSeconds"] as int,
    goalSeconds: map["goalSeconds"] as int? ?? 0,
    currentPages: map["currentPages"] as int? ?? 0,
    goalPages: map["goalPages"] as int? ?? 0,
  );

  final String id;
  final String name;
  final TimeCategoryType category;
  final int colorValue;
  final int totalSeconds;
  final int goalSeconds;
  final int currentPages;
  final int goalPages;

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "category": category.name,
    "colorValue": colorValue,
    "totalSeconds": totalSeconds,
    "goalSeconds": goalSeconds,
    "currentPages": currentPages,
    "goalPages": goalPages,
  };

  String toJson() => jsonEncode(toMap());

  SubjectEntity copyWith({
    String? name,
    int? colorValue,
    int? totalSeconds,
    int? goalSeconds,
    int? currentPages,
    int? goalPages,
  }) => SubjectEntity(
    id: id,
    name: name ?? this.name,
    category: category,
    colorValue: colorValue ?? this.colorValue,
    totalSeconds: totalSeconds ?? this.totalSeconds,
    goalSeconds: goalSeconds ?? this.goalSeconds,
    currentPages: currentPages ?? this.currentPages,
    goalPages: goalPages ?? this.goalPages,
  );

  @override
  List<Object?> get props => [id, name, category, colorValue, totalSeconds, goalSeconds, currentPages, goalPages];
}
