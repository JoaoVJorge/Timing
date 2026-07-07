import "dart:convert";

import "package:equatable/equatable.dart";

class LastActivityEntity extends Equatable {
  const LastActivityEntity({required this.label, required this.timestamp});

  factory LastActivityEntity.fromJson(String source) =>
      LastActivityEntity.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory LastActivityEntity.fromMap(Map<String, dynamic> map) =>
      LastActivityEntity(
        label: map["label"] as String,
        timestamp: DateTime.parse(map["timestamp"] as String),
      );

  final String label;
  final DateTime timestamp;

  Map<String, dynamic> toMap() => {
    "label": label,
    "timestamp": timestamp.toIso8601String(),
  };

  String toJson() => jsonEncode(toMap());

  @override
  List<Object?> get props => [label, timestamp];
}
