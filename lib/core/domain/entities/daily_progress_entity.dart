import "package:equatable/equatable.dart";

/// Aggregated activity counters for a single day. Persisted keyed by date so
/// the Home screen can honestly show "today" metrics without a full session
/// history.
class DailyProgressEntity extends Equatable {
  const DailyProgressEntity({
    this.focusSeconds = 0,
    this.sessions = 0,
    this.pages = 0,
  });

  factory DailyProgressEntity.fromMap(Map<String, dynamic> map) =>
      DailyProgressEntity(
        focusSeconds: map["focusSeconds"] as int? ?? 0,
        sessions: map["sessions"] as int? ?? 0,
        pages: map["pages"] as int? ?? 0,
      );

  final int focusSeconds;
  final int sessions;
  final int pages;

  bool get isEmpty => focusSeconds == 0 && sessions == 0 && pages == 0;

  DailyProgressEntity copyWith({int? focusSeconds, int? sessions, int? pages}) =>
      DailyProgressEntity(
        focusSeconds: focusSeconds ?? this.focusSeconds,
        sessions: sessions ?? this.sessions,
        pages: pages ?? this.pages,
      );

  Map<String, dynamic> toMap() => {
    "focusSeconds": focusSeconds,
    "sessions": sessions,
    "pages": pages,
  };

  @override
  List<Object?> get props => [focusSeconds, sessions, pages];
}
