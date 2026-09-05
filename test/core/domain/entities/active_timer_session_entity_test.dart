import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/active_timer_session_entity.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";

void main() {
  test("active timer checkpoint round-trips through map serialization", () {
    final checkpoint = ActiveTimerSessionEntity(
      subject: const SubjectEntity(
        id: "subject-1",
        name: "Leitura",
        category: TimeCategoryType.reading,
        colorValue: 0xFF336699,
        totalSeconds: 600,
        goalSeconds: 1800,
        currentPages: 10,
        goalPages: 100,
        notes: "",
        iconName: "book",
        restMinutes: 5,
        focusSessionCount: 1,
        wallpaperIndex: 0,
      ),
      sessionSeconds: 1200,
      breakCountdownSeconds: 600,
      restCountdownSeconds: 300,
      isRunning: true,
      isResting: false,
      completedFocusSections: 1,
      persistedSeconds: 900,
      todayFocusSecondsAtSessionStart: 120,
      capturedAt: DateTime.utc(2026, 9, 4, 12, 30),
    );

    expect(ActiveTimerSessionEntity.fromMap(checkpoint.toMap()), checkpoint);
  });
}
