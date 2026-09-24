import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/activity_entry_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";

class _FakeStorage implements AppLocalStorageService {
  Object? saved;

  @override
  Future<T?> read<T>(LocalStorageKeys key) async => saved as T?;

  @override
  Future<void> write<T>(LocalStorageKeys key, T value) async {
    saved = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

ActivityEntryEntity _entry(
  DateTime timestamp, {
  int seconds = 1800,
  int pages = 0,
  String subjectId = "subject-1",
}) => ActivityEntryEntity(
  id: "id-${timestamp.toIso8601String()}-$subjectId",
  category: TimeCategoryType.studying,
  subjectId: subjectId,
  subjectName: "Subject",
  timestamp: timestamp,
  seconds: seconds,
  pages: pages,
);

DateTime _daysAgo(int days) =>
    DateTime.now().subtract(Duration(days: days, hours: 1));

void main() {
  group("DailyProgressService.reconcileWithActivityEntries", () {
    test("fills a day the device has no local record for", () async {
      final service = DailyProgressService(localStorageService: _FakeStorage());
      await service.load();

      final bool changed = await service.reconcileWithActivityEntries([
        _entry(_daysAgo(30), seconds: 900),
      ]);

      expect(changed, isTrue);
      expect(service.allProgress.any((day) => day.focusSeconds == 900), isTrue);
    });

    test(
      "raises a day the other device logged more on, without adding to it",
      () async {
        final service = DailyProgressService(
          localStorageService: _FakeStorage(),
        );
        await service.load();
        await service.addFocusSeconds(600);

        // The backend holds this device's 600s plus 300s from another phone.
        final bool changed = await service.reconcileWithActivityEntries([
          _entry(DateTime.now(), seconds: 600),
          _entry(DateTime.now(), seconds: 300),
        ]);

        expect(changed, isTrue);
        expect(service.today.value.focusSeconds, 900);
      },
    );

    test("never lowers a day that has unsynced local time", () async {
      final service = DailyProgressService(localStorageService: _FakeStorage());
      await service.load();
      await service.addFocusSeconds(600);

      final bool changed = await service.reconcileWithActivityEntries([
        _entry(DateTime.now(), seconds: 100),
      ]);

      expect(changed, isFalse);
      expect(service.today.value.focusSeconds, 600);
    });

    test("is idempotent: a second pass changes nothing", () async {
      final service = DailyProgressService(localStorageService: _FakeStorage());
      await service.load();
      final entries = [_entry(_daysAgo(3), seconds: 900, pages: 12)];

      await service.reconcileWithActivityEntries(entries);
      final bool again = await service.reconcileWithActivityEntries(entries);

      expect(again, isFalse);
    });

    test("keeps the local session count", () async {
      final service = DailyProgressService(localStorageService: _FakeStorage());
      await service.load();
      await service.registerSession();
      await service.addFocusSeconds(60);

      await service.reconcileWithActivityEntries([
        _entry(DateTime.now(), seconds: 500),
      ]);

      expect(service.today.value.sessions, 1);
      expect(service.today.value.focusSeconds, 500);
    });

    test("returns false when there is nothing to reconcile", () async {
      final service = DailyProgressService(localStorageService: _FakeStorage());
      await service.load();

      expect(await service.reconcileWithActivityEntries([]), isFalse);
    });
  });

  group("SubjectDailyHistoryService.reconcileWithActivityEntries", () {
    test("raises a subject's day per subject, never lowers it", () async {
      final service = SubjectDailyHistoryService(
        localStorageService: _FakeStorage(),
      );
      await service.load();
      await service.addFocusSeconds("a", 600);
      await service.addFocusSeconds("b", 900);

      final bool changed = await service.reconcileWithActivityEntries([
        _entry(DateTime.now(), seconds: 1000, subjectId: "a"),
        _entry(DateTime.now(), seconds: 100, subjectId: "b"),
      ]);

      expect(changed, isTrue);
      expect(service.todayForSubject("a").focusSeconds, 1000);
      expect(service.todayForSubject("b").focusSeconds, 900);
    });

    test("fills a subject that only the other device used", () async {
      final service = SubjectDailyHistoryService(
        localStorageService: _FakeStorage(),
      );
      await service.load();

      await service.reconcileWithActivityEntries([
        _entry(DateTime.now(), seconds: 300, pages: 4, subjectId: "book"),
      ]);

      expect(service.todayForSubject("book").focusSeconds, 300);
      expect(service.todayForSubject("book").pages, 4);
    });
  });

  group("ActivityHistoryService.reconcileWithActivityEntries", () {
    test("adds only what the backend has beyond the local entries", () async {
      final service = ActivityHistoryService(
        localStorageService: _FakeStorage(),
      );
      await service.load();
      await service.record(
        category: TimeCategoryType.studying,
        subjectId: "subject-1",
        subjectName: "Subject",
        seconds: 600,
      );

      final bool changed = await service.reconcileWithActivityEntries([
        _entry(DateTime.now(), seconds: 600),
        _entry(DateTime.now(), seconds: 300),
      ]);

      expect(changed, isTrue);
      final DateTime start = DateTime.now().subtract(const Duration(days: 1));
      final DateTime end = DateTime.now().add(const Duration(days: 1));
      expect(service.secondsBetween(start, end), 900);
    });

    test("does not double count entries this device already has", () async {
      final service = ActivityHistoryService(
        localStorageService: _FakeStorage(),
      );
      await service.load();
      await service.record(
        category: TimeCategoryType.studying,
        subjectId: "subject-1",
        subjectName: "Subject",
        seconds: 600,
      );

      final bool changed = await service.reconcileWithActivityEntries([
        _entry(DateTime.now(), seconds: 600),
      ]);

      expect(changed, isFalse);
      expect(service.all, hasLength(1));
    });

    test("is idempotent: a second pass adds nothing", () async {
      final service = ActivityHistoryService(
        localStorageService: _FakeStorage(),
      );
      await service.load();
      final entries = [
        _entry(_daysAgo(5), seconds: 700, pages: 9, subjectId: "book"),
      ];

      await service.reconcileWithActivityEntries(entries);
      final bool again = await service.reconcileWithActivityEntries(entries);

      expect(again, isFalse);
      expect(service.all, hasLength(1));
    });
  });
}
