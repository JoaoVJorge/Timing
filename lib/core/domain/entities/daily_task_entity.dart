import "package:equatable/equatable.dart";

class DailyTaskEntity extends Equatable {
  const DailyTaskEntity({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.targetDays,
    required this.completedDates,
  });

  factory DailyTaskEntity.fromMap(Map<String, dynamic> map) => DailyTaskEntity(
    id: map["id"] as String,
    name: map["name"] as String,
    colorValue: map["colorValue"] as int,
    targetDays: map["targetDays"] as int,
    completedDates: (map["completedDates"] as List<dynamic>? ?? [])
        .cast<String>(),
  );

  final String id;
  final String name;
  final int colorValue;
  final int targetDays;
  final List<String> completedDates;

  static String dateKey(DateTime date) =>
      "${date.year.toString().padLeft(4, "0")}-"
      "${date.month.toString().padLeft(2, "0")}-"
      "${date.day.toString().padLeft(2, "0")}";

  bool get isCheckedToday => completedDates.contains(dateKey(DateTime.now()));

  int get completedDays => completedDates.length;

  bool get isCompleted => completedDays >= targetDays;

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "colorValue": colorValue,
    "targetDays": targetDays,
    "completedDates": completedDates,
  };

  DailyTaskEntity copyWith({
    String? name,
    int? colorValue,
    int? targetDays,
    List<String>? completedDates,
  }) => DailyTaskEntity(
    id: id,
    name: name ?? this.name,
    colorValue: colorValue ?? this.colorValue,
    targetDays: targetDays ?? this.targetDays,
    completedDates: completedDates ?? this.completedDates,
  );

  @override
  List<Object?> get props => [id, name, colorValue, targetDays, completedDates];
}
