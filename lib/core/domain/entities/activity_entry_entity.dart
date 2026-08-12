import "package:equatable/equatable.dart";
import "package:timing/core/domain/enums/time_category_type.dart";

/// A single logged activity: the granular, per-session record behind the
/// aggregated daily counters. Persisted locally as an append-only trail so the
/// app can answer time-and-category scoped questions ("how much did I study
/// yesterday", "how many pages did I read this week") without a backend.
class ActivityEntryEntity extends Equatable {
  const ActivityEntryEntity({
    required this.id,
    required this.category,
    required this.subjectId,
    required this.subjectName,
    required this.timestamp,
    this.seconds = 0,
    this.pages = 0,
    this.completedTasks = 0,
  });

  factory ActivityEntryEntity.fromMap(Map<String, dynamic> map) =>
      ActivityEntryEntity(
        id: map["id"] as String,
        category:
            TimeCategoryType.tryByName(map["category"] as String? ?? "") ??
            TimeCategoryType.studying,
        subjectId: map["subjectId"] as String? ?? "",
        subjectName: map["subjectName"] as String? ?? "",
        timestamp: DateTime.parse(map["timestamp"] as String),
        seconds: map["seconds"] as int? ?? 0,
        pages: map["pages"] as int? ?? 0,
        completedTasks: map["completedTasks"] as int? ?? 0,
      );

  final String id;
  final TimeCategoryType category;
  final String subjectId;
  final String subjectName;
  final DateTime timestamp;
  final int seconds;
  final int pages;
  final int completedTasks;

  Map<String, dynamic> toMap() => {
    "id": id,
    "category": category.name,
    "subjectId": subjectId,
    "subjectName": subjectName,
    "timestamp": timestamp.toIso8601String(),
    "seconds": seconds,
    "pages": pages,
    "completedTasks": completedTasks,
  };

  @override
  List<Object?> get props => [
    id,
    category,
    subjectId,
    subjectName,
    timestamp,
    seconds,
    pages,
    completedTasks,
  ];
}
