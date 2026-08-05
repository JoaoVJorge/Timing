import "package:equatable/equatable.dart";

enum DailyTaskGoalType {
  daily,
  total;

  factory DailyTaskGoalType.fromName(String? name) =>
      DailyTaskGoalType.values.firstWhere(
        (type) => type.name == name,
        orElse: () => DailyTaskGoalType.total,
      );
}

class DailyTaskEntity extends Equatable {
  const DailyTaskEntity({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.targetDays,
    required this.completedDates,
    this.goalType = DailyTaskGoalType.total,
  });

  factory DailyTaskEntity.fromMap(Map<String, dynamic> map) => DailyTaskEntity(
    id: map["id"] as String,
    name: map["name"] as String,
    colorValue: map["colorValue"] as int,
    targetDays: map["targetDays"] as int,
    completedDates: (map["completedDates"] as List<dynamic>? ?? [])
        .cast<String>(),
    goalType: DailyTaskGoalType.fromName(map["goalType"] as String?),
  );

  final String id;
  final String name;
  final int colorValue;
  final int targetDays;
  final List<String> completedDates;
  final DailyTaskGoalType goalType;

  static String dateKey(DateTime date) =>
      "${date.year.toString().padLeft(4, "0")}-"
      "${date.month.toString().padLeft(2, "0")}-"
      "${date.day.toString().padLeft(2, "0")}";

  bool get isCheckedToday => completedDates.contains(dateKey(DateTime.now()));

  int get completedDays => completedDates.length;

  int get currentProgress => switch (goalType) {
    DailyTaskGoalType.daily => isCheckedToday ? 1 : 0,
    DailyTaskGoalType.total => completedDays,
  };

  int get currentTarget => switch (goalType) {
    DailyTaskGoalType.daily => 1,
    DailyTaskGoalType.total => targetDays,
  };

  bool get isCompleted => currentTarget > 0 && currentProgress >= currentTarget;

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "colorValue": colorValue,
    "targetDays": targetDays,
    "completedDates": completedDates,
    "goalType": goalType.name,
  };

  DailyTaskEntity copyWith({
    String? name,
    int? colorValue,
    int? targetDays,
    List<String>? completedDates,
    DailyTaskGoalType? goalType,
  }) => DailyTaskEntity(
    id: id,
    name: name ?? this.name,
    colorValue: colorValue ?? this.colorValue,
    targetDays: targetDays ?? this.targetDays,
    completedDates: completedDates ?? this.completedDates,
    goalType: goalType ?? this.goalType,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    colorValue,
    targetDays,
    completedDates,
    goalType,
  ];
}
