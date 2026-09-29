import "dart:convert";

import "package:equatable/equatable.dart";
import "package:timing/core/utils/extensions/date_time_extensions.dart";

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
            DateTime.now().dateOnly,
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

  /// Whether two rows are occurrences created from the same schedule form.
  ///
  /// Schedule entries are stored one row per weekday. Older persisted data has
  /// no explicit series id, so all values except [id] and [weekday] make up the
  /// series identity.
  bool belongsToSameSeriesAs(ScheduleEntryEntity other) =>
      title == other.title &&
      startMinutes == other.startMinutes &&
      endMinutes == other.endMinutes &&
      colorValue == other.colorValue &&
      activeFrom.isSameDay(other.activeFrom) &&
      _isSameNullableDate(activeUntil, other.activeUntil);

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "weekday": weekday,
    "startMinutes": startMinutes,
    "endMinutes": endMinutes,
    "colorValue": colorValue,
    "activeFrom": activeFrom.dateOnly.toIso8601String(),
    "activeUntil": activeUntil?.dateOnly.toIso8601String(),
  };

  String toJson() => jsonEncode(toMap());

  ScheduleEntryEntity copyWith({
    String? title,
    int? weekday,
    int? startMinutes,
    int? endMinutes,
    int? colorValue,
    DateTime? activeFrom,
    DateTime? activeUntil,
    bool clearActiveUntil = false,
  }) => ScheduleEntryEntity(
    id: id,
    title: title ?? this.title,
    weekday: weekday ?? this.weekday,
    startMinutes: startMinutes ?? this.startMinutes,
    endMinutes: endMinutes ?? this.endMinutes,
    colorValue: colorValue ?? this.colorValue,
    activeFrom: activeFrom ?? this.activeFrom,
    activeUntil: clearActiveUntil ? null : (activeUntil ?? this.activeUntil),
  );

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

  static bool _isSameNullableDate(DateTime? left, DateTime? right) {
    if (left == null || right == null) {
      return left == right;
    }
    return left.isSameDay(right);
  }
}
