import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";

SubjectEntity _subject({
  TimeCategoryType category = TimeCategoryType.studying,
  int restMinutes = 5,
  int focusSessionCount = 1,
}) => SubjectEntity(
  id: "subject-1",
  name: "Matemática",
  category: category,
  colorValue: 0xFF000000,
  totalSeconds: 0,
  goalSeconds: 1800,
  currentPages: 0,
  goalPages: 0,
  notes: "",
  iconName: "clock",
  restMinutes: restMinutes,
  focusSessionCount: focusSessionCount,
  wallpaperIndex: 0,
);

void main() {
  group("SubjectEntity.hasRest", () {
    test("a single session has nothing to rest between", () {
      expect(_subject().hasRest, isFalse);
      expect(_subject().restSeconds, 0);
    });

    test("two sessions do have a break between them", () {
      final SubjectEntity subject = _subject(focusSessionCount: 2);

      expect(subject.hasRest, isTrue);
      expect(subject.restSeconds, 5 * 60);
    });

    test("a stored break is ignored while the subject runs one session", () {
      expect(_subject(restMinutes: 30).restSeconds, 0);
    });

    test("exercises keep counting their break in seconds", () {
      final SubjectEntity subject = _subject(
        category: TimeCategoryType.exercises,
        restMinutes: 45,
        focusSessionCount: 3,
      );

      expect(subject.restSeconds, 45);
    });

    test("reading never rests, however many sessions are stored", () {
      final SubjectEntity subject = _subject(
        category: TimeCategoryType.reading,
        focusSessionCount: 4,
      );

      expect(subject.sessionCount, 1);
      expect(subject.hasRest, isFalse);
      expect(subject.restSeconds, 0);
    });

    test("hobbies never rest either", () {
      expect(
        _subject(
          category: TimeCategoryType.hobbies,
          focusSessionCount: 4,
        ).hasRest,
        isFalse,
      );
    });

    test("a break still falls back to the default once it exists", () {
      expect(
        _subject(restMinutes: 0, focusSessionCount: 2).restSeconds,
        SubjectEntity.defaultRestMinutes * 60,
      );
      expect(
        _subject(
          category: TimeCategoryType.exercises,
          restMinutes: 0,
          focusSessionCount: 2,
        ).restSeconds,
        SubjectEntity.defaultRestSeconds,
      );
    });
  });
}
