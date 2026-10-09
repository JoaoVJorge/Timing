import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/activity_entry_entity.dart";
import "package:timing/core/domain/entities/daily_progress_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";

import "../../../support/supabase_test_harness.dart";

String _key(DateTime date) => DailyProgressService.dateKey(date);

void main() {
  final DateTime today = DateTime.now();
  final DateTime yesterday = today.subtract(const Duration(days: 1));

  group("SubjectDailyHistoryService.removeSubject", () {
    test("forgets the subject's days and hands them back", () async {
      final MemoryStorage storage = MemoryStorage();
      final SubjectDailyHistoryService history = SubjectDailyHistoryService(
        localStorageService: storage,
      );
      await history.addFocusSeconds("a", 600);
      await history.addPages("a", 4);
      await history.addFocusSeconds("b", 300);

      final Map<String, DailyProgressEntity> removed = await history
          .removeSubject("a");

      expect(removed[_key(today)]?.focusSeconds, 600);
      expect(removed[_key(today)]?.pages, 4);
      expect(history.todayForSubject("a").isEmpty, isTrue);
      expect(history.todayForSubject("b").focusSeconds, 300);
    });

    test("stays forgotten after a restart", () async {
      final MemoryStorage storage = MemoryStorage();
      final SubjectDailyHistoryService history = SubjectDailyHistoryService(
        localStorageService: storage,
      );
      await history.addFocusSeconds("a", 600);

      await history.removeSubject("a");

      final SubjectDailyHistoryService reloaded = SubjectDailyHistoryService(
        localStorageService: storage,
      );
      await reloaded.load();
      expect(reloaded.todayForSubject("a").isEmpty, isTrue);
    });

    test("a subject with no history gives back nothing", () async {
      final SubjectDailyHistoryService history = SubjectDailyHistoryService(
        localStorageService: MemoryStorage(),
      );

      expect(await history.removeSubject("nobody"), isEmpty);
    });
  });

  group("ActivityHistoryService.removeSubject", () {
    test("drops only that subject's sessions, for good", () async {
      final MemoryStorage storage = MemoryStorage();
      final ActivityHistoryService history = ActivityHistoryService(
        localStorageService: storage,
      );
      await history.record(
        category: TimeCategoryType.studying,
        subjectId: "a",
        subjectName: "A",
        seconds: 600,
      );
      await history.record(
        category: TimeCategoryType.reading,
        subjectId: "b",
        subjectName: "B",
        pages: 3,
      );

      await history.removeSubject("a");

      expect(history.all.map((ActivityEntryEntity e) => e.subjectId), ["b"]);
      final ActivityHistoryService reloaded = ActivityHistoryService(
        localStorageService: storage,
      );
      await reloaded.load();
      expect(reloaded.all.map((ActivityEntryEntity e) => e.subjectId), ["b"]);
    });
  });

  group("DailyProgressService.subtract", () {
    test("takes an activity's share out of the day", () async {
      final DailyProgressService progress = DailyProgressService(
        localStorageService: MemoryStorage(),
      );
      await progress.addFocusSeconds(900);
      await progress.addPages(10);

      await progress.subtract({
        _key(today): const DailyProgressEntity(focusSeconds: 600, pages: 4),
      });

      expect(progress.today.value.focusSeconds, 300);
      expect(progress.today.value.pages, 6);
    });

    test("never goes below zero and ignores days it does not have", () async {
      final DailyProgressService progress = DailyProgressService(
        localStorageService: MemoryStorage(),
      );
      await progress.addFocusSeconds(100);

      await progress.subtract({
        _key(today): const DailyProgressEntity(focusSeconds: 5000, pages: 9),
        "2001-01-01": const DailyProgressEntity(focusSeconds: 60),
      });

      expect(progress.today.value.focusSeconds, 0);
      expect(progress.today.value.pages, 0);
    });

    test("drops sessions with the day when nothing else is left", () async {
      final DailyProgressService progress = DailyProgressService(
        localStorageService: MemoryStorage(),
      );
      await progress.addFocusSeconds(600);
      await progress.registerSession();

      await progress.subtract({
        _key(today): const DailyProgressEntity(focusSeconds: 600),
      });

      expect(progress.today.value.sessions, 0);
    });

    test("keeps the other activities' sessions on a shared day", () async {
      final DailyProgressService progress = DailyProgressService(
        localStorageService: MemoryStorage(),
      );
      await progress.addFocusSeconds(900);
      await progress.registerSession();
      await progress.registerSession();

      await progress.subtract({
        _key(today): const DailyProgressEntity(focusSeconds: 600, sessions: 1),
      });

      expect(progress.today.value.sessions, 1);
    });

    test(
      "a day that only had that activity stops counting for the streak",
      () async {
        final DailyProgressService progress = DailyProgressService(
          localStorageService: MemoryStorage(),
        );
        await progress.addFocusSeconds(600);
        await progress.reconcileWithActivityEntries([
          ActivityEntryEntity(
            id: "e1",
            category: TimeCategoryType.studying,
            subjectId: "a",
            subjectName: "A",
            timestamp: yesterday,
            seconds: 600,
          ),
        ]);
        expect(progress.currentStreak.value, 2);

        await progress.subtract({
          _key(yesterday): const DailyProgressEntity(focusSeconds: 600),
        });

        expect(progress.currentStreak.value, 1);
      },
    );

    test("persists what it took out", () async {
      final MemoryStorage storage = MemoryStorage();
      final DailyProgressService progress = DailyProgressService(
        localStorageService: storage,
      );
      await progress.addFocusSeconds(900);

      await progress.subtract({
        _key(today): const DailyProgressEntity(focusSeconds: 600),
      });

      final DailyProgressService reloaded = DailyProgressService(
        localStorageService: storage,
      );
      await reloaded.load();
      expect(reloaded.today.value.focusSeconds, 300);
    });
  });
}
