import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/activity_entry_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/activity_history/activity_history_reconciler.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";

import "../../../support/supabase_test_harness.dart";

/// One storage per key so the three caches do not overwrite each other.
class _KeyedStorage extends MemoryStorage {}

ActivityEntryEntity _entry(DateTime timestamp, {int seconds = 600}) =>
    ActivityEntryEntity(
      id: "id-${timestamp.microsecondsSinceEpoch}",
      category: TimeCategoryType.studying,
      subjectId: "s1",
      subjectName: "Subject",
      timestamp: timestamp,
      seconds: seconds,
    );

class _Rig {
  _Rig({DateTime? at}) : clock = at ?? DateTime(2026, 9, 24, 12) {
    reconciler = ActivityHistoryReconciler(
      fetchEntries: ({required int retentionDays}) async {
        requestedWindows.add(retentionDays);
        if (failing) {
          return Left(
            GenericAppError(error: "offline", stackTrace: StackTrace.empty),
          );
        }
        return Right(entries);
      },
      activityHistory: ActivityHistoryService(
        localStorageService: _KeyedStorage(),
      ),
      dailyProgress: DailyProgressService(localStorageService: _KeyedStorage()),
      subjectHistory: SubjectDailyHistoryService(
        localStorageService: _KeyedStorage(),
      ),
      localStorage: storage,
      now: () => clock,
    );
  }

  final MemoryStorage storage = MemoryStorage();
  final List<int> requestedWindows = [];
  List<ActivityEntryEntity> entries = [];
  bool failing = false;
  DateTime clock;
  late final ActivityHistoryReconciler reconciler;
}

void main() {
  test("the first pass reads the whole retention window", () async {
    final rig = _Rig();

    await rig.reconciler.reconcile();

    expect(rig.requestedWindows, [ActivityHistoryService.retentionDays]);
    expect(
      rig.storage.data[LocalStorageKeys.activityHistoryReconciledAt],
      isNotNull,
    );
  });

  test("a pass soon after another does not hit the backend", () async {
    final rig = _Rig();
    await rig.reconciler.reconcile();

    rig.clock = rig.clock.add(const Duration(hours: 5));
    final bool changed = await rig.reconciler.reconcile();

    expect(changed, isFalse);
    expect(rig.requestedWindows, hasLength(1));
  });

  test("later passes read only the recent window", () async {
    final rig = _Rig();
    await rig.reconciler.reconcile();

    rig.clock = rig.clock.add(const Duration(hours: 7));
    await rig.reconciler.reconcile();

    expect(rig.requestedWindows, [
      ActivityHistoryService.retentionDays,
      ActivityHistoryReconciler.recentWindowDays,
    ]);
  });

  test("force runs regardless of the interval", () async {
    final rig = _Rig();
    await rig.reconciler.reconcile();

    await rig.reconciler.reconcile(force: true);

    expect(rig.requestedWindows, hasLength(2));
  });

  test("a failed read is not counted as a pass", () async {
    final rig = _Rig()..failing = true;

    final bool changed = await rig.reconciler.reconcile();

    expect(changed, isFalse);
    expect(
      rig.storage.data[LocalStorageKeys.activityHistoryReconciledAt],
      isNull,
    );

    rig.failing = false;
    await rig.reconciler.reconcile();
    expect(rig.requestedWindows, hasLength(2));
  });

  test(
    "a phone that ran before the backend had the history catches up later",
    () async {
      final rig = _Rig();
      // First pass: the backend only knows two days.
      rig.entries = [
        _entry(DateTime(2026, 9, 23, 10)),
        _entry(DateTime(2026, 9, 24, 10)),
      ];
      expect(await rig.reconciler.reconcile(), isTrue);

      // The other phone uploads its queued month; hours later this one reconciles.
      rig.entries = [
        for (int day = 1; day <= 24; day++) _entry(DateTime(2026, 9, day, 10)),
      ];
      rig.clock = rig.clock.add(const Duration(hours: 7));

      expect(await rig.reconciler.reconcile(), isTrue);
      expect(
        rig.reconciler.dailyProgress.allProgress.where(
          (d) => d.focusSeconds > 0,
        ),
        hasLength(24),
      );
    },
  );
}
