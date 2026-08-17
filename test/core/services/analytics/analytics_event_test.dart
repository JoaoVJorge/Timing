import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/services/analytics/analytics_event.dart";

void main() {
  group("AnalyticsEvent catalog", () {
    test("focusSessionStarted carries the category", () {
      final event = AnalyticsEvent.focusSessionStarted(
        category: TimeCategoryType.studying,
      );

      expect(event.name, "focus_session_started");
      expect(event.properties, {"category": "studying"});
    });

    test("focusSessionCompleted carries duration and completion flag", () {
      final event = AnalyticsEvent.focusSessionCompleted(
        category: TimeCategoryType.reading,
        seconds: 1800,
        completedAllSections: true,
      );

      expect(event.name, "focus_session_completed");
      expect(event.properties, {
        "category": "reading",
        "seconds": 1800,
        "completed_all_sections": true,
      });
    });

    test("subjectCreated carries the category", () {
      final event = AnalyticsEvent.subjectCreated(
        category: TimeCategoryType.hobbies,
      );

      expect(event.name, "subject_created");
      expect(event.properties, {"category": "hobbies"});
    });

    test("events with equal name and properties are equal", () {
      expect(
        AnalyticsEvent.subjectCreated(category: TimeCategoryType.exercises),
        AnalyticsEvent.subjectCreated(category: TimeCategoryType.exercises),
      );
    });
  });
}
