import "dart:convert";

import "package:equatable/equatable.dart";

class ScheduleEntryEntity extends Equatable {
  const ScheduleEntryEntity({
    required this.id,
    required this.title,
    required this.weekday,
    required this.startMinutes,
    required this.endMinutes,
    required this.colorValue,
  });

  factory ScheduleEntryEntity.fromJson(String source) =>
      ScheduleEntryEntity.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory ScheduleEntryEntity.fromMap(Map<String, dynamic> map) =>
      ScheduleEntryEntity(
        id: map["id"] as String,
        title: map["title"] as String,
        weekday: map["weekday"] as int? ?? DateTime.monday,
        startMinutes: map["startMinutes"] as int,
        endMinutes: map["endMinutes"] as int?,
        colorValue: map["colorValue"] as int,
      );

  final String id;
  final String title;
  final int weekday;
  final int startMinutes;
  final int? endMinutes;
  final int colorValue;

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "weekday": weekday,
    "startMinutes": startMinutes,
    "endMinutes": endMinutes,
    "colorValue": colorValue,
  };

  String toJson() => jsonEncode(toMap());

  @override
  List<Object?> get props => [
    id,
    title,
    weekday,
    startMinutes,
    endMinutes,
    colorValue,
  ];
}
