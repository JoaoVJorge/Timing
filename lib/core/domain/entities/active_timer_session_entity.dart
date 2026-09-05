import "package:equatable/equatable.dart";
import "package:timing/core/domain/entities/subject_entity.dart";

/// Durable checkpoint for a timer that may outlive the Flutter process.
class ActiveTimerSessionEntity extends Equatable {
  const ActiveTimerSessionEntity({
    required this.subject,
    required this.sessionSeconds,
    required this.breakCountdownSeconds,
    required this.restCountdownSeconds,
    required this.isRunning,
    required this.isResting,
    required this.completedFocusSections,
    required this.persistedSeconds,
    required this.todayFocusSecondsAtSessionStart,
    required this.capturedAt,
  });

  factory ActiveTimerSessionEntity.fromMap(Map<String, dynamic> map) =>
      ActiveTimerSessionEntity(
        subject: SubjectEntity.fromMap(
          Map<String, dynamic>.from(map["subject"] as Map),
        ),
        sessionSeconds: (map["sessionSeconds"] as num).toInt(),
        breakCountdownSeconds: (map["breakCountdownSeconds"] as num).toInt(),
        restCountdownSeconds: (map["restCountdownSeconds"] as num).toInt(),
        isRunning: map["isRunning"] as bool,
        isResting: map["isResting"] as bool,
        completedFocusSections: (map["completedFocusSections"] as num).toInt(),
        persistedSeconds: (map["persistedSeconds"] as num? ?? 0).toInt(),
        todayFocusSecondsAtSessionStart:
            (map["todayFocusSecondsAtSessionStart"] as num? ?? 0).toInt(),
        capturedAt: DateTime.parse(map["capturedAt"] as String).toUtc(),
      );

  final SubjectEntity subject;
  final int sessionSeconds;
  final int breakCountdownSeconds;
  final int restCountdownSeconds;
  final bool isRunning;
  final bool isResting;
  final int completedFocusSections;
  final int persistedSeconds;
  final int todayFocusSecondsAtSessionStart;
  final DateTime capturedAt;

  Map<String, dynamic> toMap() => {
    "subject": subject.toMap(),
    "sessionSeconds": sessionSeconds,
    "breakCountdownSeconds": breakCountdownSeconds,
    "restCountdownSeconds": restCountdownSeconds,
    "isRunning": isRunning,
    "isResting": isResting,
    "completedFocusSections": completedFocusSections,
    "persistedSeconds": persistedSeconds,
    "todayFocusSecondsAtSessionStart": todayFocusSecondsAtSessionStart,
    "capturedAt": capturedAt.toUtc().toIso8601String(),
  };

  @override
  List<Object?> get props => [
    subject,
    sessionSeconds,
    breakCountdownSeconds,
    restCountdownSeconds,
    isRunning,
    isResting,
    completedFocusSections,
    persistedSeconds,
    todayFocusSecondsAtSessionStart,
    capturedAt,
  ];
}
