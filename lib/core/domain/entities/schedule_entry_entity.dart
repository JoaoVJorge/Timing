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
    required this.activeFrom,
    this.activeUntil,
  });

  factory ScheduleEntryEntity.fromJson(String source) =>
      ScheduleEntryEntity.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory ScheduleEntryEntity.fromMap(Map<String, dynamic> map) =>
      ScheduleEntryEntity(
        id: map["id"] as String,
        title: map["title"] as String,
        weekday: map["weekday"] as int? ?? DateTime.monday,
        startMinutes: map["startMinutes"] as int?,
        endMinutes: map["endMinutes"] as int?,
        colorValue: map["colorValue"] as int,
        activeFrom:
            DateTime.tryParse(map["activeFrom"] as String? ?? "") ??
            _todayDate(),
        activeUntil: DateTime.tryParse(map["activeUntil"] as String? ?? ""),
      );

  final String id;
  final String title;
  final int weekday;
  final int? startMinutes;
  final int? endMinutes;
  final int colorValue;
  final DateTime activeFrom;
  final DateTime? activeUntil;

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "weekday": weekday,
    "startMinutes": startMinutes,
    "endMinutes": endMinutes,
    "colorValue": colorValue,
    "activeFrom": _dateOnly(activeFrom).toIso8601String(),
    "activeUntil": activeUntil == null
        ? null
        : _dateOnly(activeUntil!).toIso8601String(),
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
    activeFrom,
    activeUntil,
  ];

  static DateTime _todayDate() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
