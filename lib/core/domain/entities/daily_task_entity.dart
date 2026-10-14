import "package:equatable/equatable.dart";

enum DailyTaskGoalType {
  daily,
  total;

  factory DailyTaskGoalType.fromName(String? name) {
    if (name == "intense") return DailyTaskGoalType.daily;
    if (name == "casual") return DailyTaskGoalType.total;
    return DailyTaskGoalType.values.firstWhere(
      (type) => type.name == name,
      orElse: () => DailyTaskGoalType.total,
    );
  }
}

enum DailyTaskSequenceType {
  intense,
  casual;

  factory DailyTaskSequenceType.fromName(String? name) {
    if (name == null) return DailyTaskSequenceType.casual;
    if (name == "daily") return DailyTaskSequenceType.intense;
    if (name == "total") return DailyTaskSequenceType.casual;
    return DailyTaskSequenceType.values.firstWhere(
      (type) => type.name == name,
      orElse: () => DailyTaskSequenceType.casual,
    );
  }
}

class DailyTaskEntity extends Equatable {
  const DailyTaskEntity({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.targetDays,
    required this.completedDates,
    this.sequenceType = DailyTaskSequenceType.casual,
    this.lastResolvedMissedDate,
    this.goalType = DailyTaskGoalType.total,
    this.updatedAt,
    this.reminderMinutes,
  });

  factory DailyTaskEntity.fromMap(Map<String, dynamic> map) => DailyTaskEntity(
    id: map["id"] as String,
    name: map["name"] as String,
    colorValue: map["colorValue"] as int,
    targetDays: map["targetDays"] as int,
    completedDates: (map["completedDates"] as List<dynamic>? ?? [])
        .cast<String>(),
    sequenceType: DailyTaskSequenceType.fromName(
      map["sequenceType"] as String? ?? map["goalType"] as String?,
    ),
    lastResolvedMissedDate: map["lastResolvedMissedDate"] as String?,
    goalType: DailyTaskGoalType.fromName(map["goalType"] as String?),
    updatedAt: _parseUpdatedAt(map["updatedAt"]),
    reminderMinutes: _parseReminderMinutes(map["reminderMinutes"]),
  );

  static DateTime? _parseUpdatedAt(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }

  static const int minutesPerDay = 24 * 60;

  static int? _parseReminderMinutes(dynamic value) {
    if (value is! num) {
      return null;
    }
    final int minutes = value.toInt();
    return minutes < 0 || minutes >= minutesPerDay ? null : minutes;
  }

  final String id;
  final String name;
  final int colorValue;
  final int targetDays;
  final List<String> completedDates;
  final DailyTaskSequenceType sequenceType;
  final String? lastResolvedMissedDate;
  final DailyTaskGoalType goalType;

  /// Minute of the day (local time) a reminder is shown while the goal is
  /// still unchecked that day. Null when the goal has no reminder.
  final int? reminderMinutes;

  /// When this task was last mutated. Drives last-write-wins reconciliation
  /// between the local copy and a possibly-stale remote copy, so a change that
  /// hasn't finished syncing yet is not clobbered on the next read.
  final DateTime? updatedAt;

  static String dateKey(DateTime date) =>
      "${date.year.toString().padLeft(4, "0")}-"
      "${date.month.toString().padLeft(2, "0")}-"
      "${date.day.toString().padLeft(2, "0")}";

  List<String> completedDatesAfterToggle(DateTime date) {
    final String selectedDate = dateKey(date);
    if (completedDates.contains(selectedDate)) {
      return completedDates.where((value) => value != selectedDate).toList();
    }
    return [...completedDates, selectedDate];
  }

  bool get isCheckedToday => completedDates.contains(dateKey(DateTime.now()));

  int get completedDays => completedDates.length;

  bool get hasInfiniteTarget => targetDays == 0;

  int get currentProgress => switch (sequenceType) {
    DailyTaskSequenceType.intense => _currentIntenseSequence(),
    DailyTaskSequenceType.casual => completedDays,
  };

  int get currentTarget => hasInfiniteTarget ? 0 : targetDays;

  bool get isCompleted =>
      !hasInfiniteTarget &&
      currentTarget > 0 &&
      currentProgress >= currentTarget;

  bool get isDoneForCurrentCycle => isCheckedToday;

  bool shouldAskAboutMissedYesterday(DateTime now) {
    if (sequenceType != DailyTaskSequenceType.intense) {
      return false;
    }
    if (completedDates.isEmpty || isCheckedToday) {
      return false;
    }

    final String yesterday = dateKey(now.subtract(const Duration(days: 1)));
    return !completedDates.contains(yesterday) &&
        lastResolvedMissedDate != yesterday;
  }

  /// The next moment the reminder is due: today at [reminderMinutes] while the
  /// goal is unchecked and that time is still ahead, otherwise tomorrow.
  /// Checking the goal is what moves its reminder off today.
  DateTime? nextReminderAt(DateTime now) {
    final int? minutes = reminderMinutes;
    if (minutes == null) {
      return null;
    }
    final bool isDueToday =
        !completedDates.contains(dateKey(now)) &&
        DateTime(
          now.year,
          now.month,
          now.day,
          minutes ~/ 60,
          minutes % 60,
        ).isAfter(now);
    return DateTime(
      now.year,
      now.month,
      isDueToday ? now.day : now.day + 1,
      minutes ~/ 60,
      minutes % 60,
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "colorValue": colorValue,
    "targetDays": targetDays,
    "completedDates": completedDates,
    "sequenceType": sequenceType.name,
    "lastResolvedMissedDate": lastResolvedMissedDate,
    "goalType": goalType.name,
    "updatedAt": updatedAt?.toUtc().toIso8601String(),
    "reminderMinutes": reminderMinutes,
  };

  DailyTaskEntity copyWith({
    String? name,
    int? colorValue,
    int? targetDays,
    List<String>? completedDates,
    DailyTaskSequenceType? sequenceType,
    String? lastResolvedMissedDate,
    DailyTaskGoalType? goalType,
    DateTime? updatedAt,
    bool clearReminder = false,
    int? reminderMinutes,
  }) => DailyTaskEntity(
    id: id,
    name: name ?? this.name,
    colorValue: colorValue ?? this.colorValue,
    targetDays: targetDays ?? this.targetDays,
    completedDates: completedDates ?? this.completedDates,
    sequenceType: sequenceType ?? this.sequenceType,
    lastResolvedMissedDate:
        lastResolvedMissedDate ?? this.lastResolvedMissedDate,
    goalType: goalType ?? this.goalType,
    updatedAt: updatedAt ?? this.updatedAt,
    reminderMinutes: clearReminder
        ? null
        : reminderMinutes ?? this.reminderMinutes,
  );

  int _currentIntenseSequence() {
    if (completedDates.isEmpty) {
      return 0;
    }

    final Set<String> dates = completedDates.toSet();
    DateTime cursor = DateTime.now();
    if (!dates.contains(dateKey(cursor))) {
      final DateTime yesterday = cursor.subtract(const Duration(days: 1));
      if (!dates.contains(dateKey(yesterday))) {
        return 0;
      }
      cursor = yesterday;
    }

    int sequence = 0;
    while (dates.contains(dateKey(cursor))) {
      sequence++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return sequence;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    colorValue,
    targetDays,
    completedDates,
    sequenceType,
    lastResolvedMissedDate,
    goalType,
    updatedAt,
    reminderMinutes,
  ];
}
