import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/daily_progress_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";

import "../../../support/supabase_test_harness.dart";

String _dayKey(int daysAgo) => DailyProgressService.dateKey(
  DateTime.now().subtract(Duration(days: daysAgo)),
);

Map<String, dynamic> _day({int seconds = 0, int pages = 0}) =>
    DailyProgressEntity(focusSeconds: seconds, pages: pages).toMap();

Map<String, dynamic> _entry(
  String id,
  String subjectId,
  int daysAgo, {
  int seconds = 0,
  int pages = 0,
}) => {
  "id": id,
  "category": TimeCategoryType.studying.name,
  "subjectId": subjectId,
  "subjectName": subjectId,
  "timestamp": DateTime.now()
      .subtract(Duration(days: daysAgo))
      .toIso8601String(),
  "seconds": seconds,
  "pages": pages,
  "completedTasks": 0,
};

void main() {
  group("SubjectDailyHistoryService.removeFocusSeconds", () {
    late MemoryStorage storage;
    late SubjectDailyHistoryService history;

    /// "math" did 10 min two days ago, 5 min yesterday and 2 min today.
    Future<void> seed() async {
      storage = MemoryStorage();
      storage.data[LocalStorageKeys.subjectDailyHistory] = jsonEncode({
        "math": {
          _dayKey(2): _day(seconds: 600, pages: 4),
          _dayKey(1): _day(seconds: 300),
          _dayKey(0): _day(seconds: 120),
        },
        "physics": {_dayKey(0): _day(seconds: 500)},
      });
      history = SubjectDailyHistoryService(localStorageService: storage);
      await history.load();
    }

    List<int> lastThreeDays(String subjectId) => history
        .historyForLastDays(subjectId, 3)
        .map((day) => day.focusSeconds)
        .toList();

    setUp(seed);

    test("takes the time off the newest days first", () async {
      final removed = await history.removeFocusSeconds("math", 200);

      expect(lastThreeDays("math"), [600, 220, 0]);
      expect(removed.map((key, day) => MapEntry(key, day.focusSeconds)), {
        _dayKey(0): 120,
        _dayKey(1): 80,
      });
    });

    test("leaves pages and other activities alone", () async {
      await history.removeFocusSeconds("math", 1000);

      expect(history.historyForLastDays("math", 3).first.pages, 4);
      expect(lastThreeDays("physics"), [0, 0, 500]);
    });

    test("stops at zero when asked for more than there is", () async {
      final removed = await history.removeFocusSeconds("math", 5000);

      expect(lastThreeDays("math"), [0, 0, 0]);
      expect(
        removed.values.fold<int>(0, (sum, day) => sum + day.focusSeconds),
        1020,
      );
    });

    test("is saved, so it survives the app restarting", () async {
      await history.removeFocusSeconds("math", 200);

      final reloaded = SubjectDailyHistoryService(localStorageService: storage);
      await reloaded.load();

      expect(reloaded.todayForSubject("math").focusSeconds, 0);
    });

    test("does nothing for an activity with no trail", () async {
      expect(await history.removeFocusSeconds("unknown", 60), isEmpty);
      expect(await history.removeFocusSeconds("math", 0), isEmpty);
    });

    test(
      "what came off each day also comes off the account's totals",
      () async {
        storage.data[LocalStorageKeys.dailyProgress] = jsonEncode({
          _dayKey(1): _day(seconds: 900),
          _dayKey(0): _day(seconds: 620),
        });
        final daily = DailyProgressService(localStorageService: storage);
        await daily.load();

        await daily.subtract(await history.removeFocusSeconds("math", 200));

        expect(daily.progressForLastDays(2).map((day) => day.focusSeconds), [
          820,
          500,
        ]);
      },
    );
  });

  group("ActivityHistoryService.removeSeconds", () {
    late MemoryStorage storage;
    late ActivityHistoryService trail;

    Future<void> seed() async {
      storage = MemoryStorage();
      storage.data[LocalStorageKeys.activityHistory] = jsonEncode([
        _entry("1", "math", 2, seconds: 600),
        _entry("2", "physics", 1, seconds: 500),
        _entry("3", "math", 1, seconds: 300, pages: 7),
        _entry("4", "math", 0, seconds: 120),
      ]);
      trail = ActivityHistoryService(localStorageService: storage);
      await trail.load();
    }

    List<String> entries() => [
      for (final entry in trail.all)
        "${entry.id}:${entry.subjectId}:${entry.seconds}s/${entry.pages}p",
    ];

    setUp(seed);

    test("shortens the newest entries of that activity first", () async {
      await trail.removeSeconds("math", 200);

      expect(entries(), [
        "1:math:600s/0p",
        "2:physics:500s/0p",
        "3:math:220s/7p",
      ]);
    });

    test("keeps an emptied entry that still carries pages", () async {
      await trail.removeSeconds("math", 420);

      expect(entries(), [
        "1:math:600s/0p",
        "2:physics:500s/0p",
        "3:math:0s/7p",
      ]);
    });

    test("stops when the activity has nothing left", () async {
      await trail.removeSeconds("math", 99999);

      expect(entries(), ["2:physics:500s/0p", "3:math:0s/7p"]);
    });

    test("is saved, so it survives the app restarting", () async {
      await trail.removeSeconds("math", 120);

      final reloaded = ActivityHistoryService(localStorageService: storage);
      await reloaded.load();

      expect(reloaded.all.map((entry) => entry.id), ["1", "2", "3"]);
    });
  });
}
