import "package:flutter_test/flutter_test.dart";
import "package:help_out/core/domain/entities/activity_entry_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";

void main() {
  group("ActivityEntryEntity", () {
    test("round-trips through map serialization", () {
      final ActivityEntryEntity entry = ActivityEntryEntity(
        id: "123-0",
        category: TimeCategoryType.reading,
        subjectId: "subject-1",
        subjectName: "Clean Code",
        timestamp: DateTime.parse("2026-08-09T14:30:00.000"),
        pages: 12,
      );

      expect(ActivityEntryEntity.fromMap(entry.toMap()), entry);
    });

    test("falls back to studying for an unknown category name", () {
      final ActivityEntryEntity entry = ActivityEntryEntity.fromMap({
        "id": "1-0",
        "category": "not-a-category",
        "subjectId": "s",
        "subjectName": "S",
        "timestamp": "2026-08-09T14:30:00.000",
        "seconds": 60,
      });

      expect(entry.category, TimeCategoryType.studying);
      expect(entry.seconds, 60);
    });
  });
}
