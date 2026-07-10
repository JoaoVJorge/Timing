import "dart:convert";

import "package:equatable/equatable.dart";

class LastActivityEntity extends Equatable {
  const LastActivityEntity({
    required this.label,
    required this.timestamp,
    this.subjectId,
  });

  factory LastActivityEntity.fromJson(String source) =>
      LastActivityEntity.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory LastActivityEntity.fromMap(Map<String, dynamic> map) =>
      LastActivityEntity(
        label: map["label"] as String,
        timestamp: DateTime.parse(map["timestamp"] as String),
        subjectId: map["subjectId"] as String?,
      );

  final String label;
  final DateTime timestamp;

  /// Id of the subject this activity came from, when it is a timer session.
  /// `null` for activities that cannot be resumed (e.g. a daily task check).
  final String? subjectId;

  /// Whether tapping this activity can reopen a subject's timer.
  bool get isResumable => subjectId != null;

  Map<String, dynamic> toMap() => {
    "label": label,
    "timestamp": timestamp.toIso8601String(),
    "subjectId": subjectId,
  };

  String toJson() => jsonEncode(toMap());

  @override
  List<Object?> get props => [label, timestamp, subjectId];
}
