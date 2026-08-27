import "dart:async";

import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/log_activity_use_case.dart";
import "package:timing/core/domain/use_cases/update_subject_time_use_case.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/presentation/timer/timer_session_persister.dart";

class _Noop {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeUpdateSubjectTimeUseCase extends _Noop
    implements UpdateSubjectTimeUseCase {
  _FakeUpdateSubjectTimeUseCase({this.succeeds = true});

  bool succeeds;
  int calls = 0;
  final List<int> totalSecondsSeen = <int>[];
  Completer<void>? gate;

  @override
  Future<Either<AppError, void>> call({
    required String subjectId,
    required int totalSeconds,
  }) async {
    calls++;
    totalSecondsSeen.add(totalSeconds);
    if (gate != null) {
      await gate!.future;
    }
    return succeeds
        ? const Right(null)
        : Left(GenericAppError(error: "nope", stackTrace: StackTrace.current));
  }
}

class _FakeLogActivityUseCase extends _Noop implements LogActivityUseCase {
  int calls = 0;

  @override
  Future<Either<AppError, void>> call({
    required TimeCategoryType category,
    required String subjectId,
    required String subjectName,
    int seconds = 0,
    int pages = 0,
    int completedTasks = 0,
  }) async {
    calls++;
    return const Right(null);
  }
}

class _FakeActivityHistoryService extends _Noop
    implements ActivityHistoryService {
  @override
  Future<void> record({
    required TimeCategoryType category,
    required String subjectId,
    required String subjectName,
    int seconds = 0,
    int pages = 0,
    int completedTasks = 0,
  }) async {}
}

class _FakeDailyProgressService extends _Noop implements DailyProgressService {
  int addedSeconds = 0;

  @override
  Future<void> addFocusSeconds(int seconds) async {
    addedSeconds += seconds;
  }
}

class _FakeSubjectDailyHistoryService extends _Noop
    implements SubjectDailyHistoryService {
  int addedSeconds = 0;

  @override
  Future<void> addFocusSeconds(String subjectId, int seconds) async {
    addedSeconds += seconds;
  }
}

class _FakeAchievementUnlockService extends _Noop
    implements AchievementUnlockService {
  @override
  Future<void> checkForNewUnlocks() async {}
}

SubjectEntity _subject() => const SubjectEntity(
  id: "subject-1",
  name: "Matemática",
  category: TimeCategoryType.studying,
  colorValue: 0xFF000000,
  totalSeconds: 100,
  goalSeconds: 1800,
  currentPages: 0,
  goalPages: 0,
  notes: "",
  iconName: "clock",
  restMinutes: 5,
  focusSessionCount: 1,
  wallpaperIndex: 0,
  activityType: SubjectActivityType.permanent,
);

({
  TimerSessionPersister persister,
  _FakeUpdateSubjectTimeUseCase update,
  _FakeLogActivityUseCase log,
  _FakeDailyProgressService daily,
  int Function() groupNotifications,
})
_build({
  required int Function() sessionSeconds,
  bool succeeds = true,
  Duration autoSaveInterval = const Duration(seconds: 10),
  DateTime? now,
}) {
  final update = _FakeUpdateSubjectTimeUseCase(succeeds: succeeds);
  final log = _FakeLogActivityUseCase();
  final daily = _FakeDailyProgressService();
  int groupNotifications = 0;
  final persister = TimerSessionPersister(
    autoSaveInterval: autoSaveInterval,
    updateSubjectTimeUseCase: update,
    logActivityUseCase: log,
    activityHistoryService: _FakeActivityHistoryService(),
    dailyProgressService: daily,
    subjectDailyHistoryService: _FakeSubjectDailyHistoryService(),
    achievementUnlockService: _FakeAchievementUnlockService(),
    subject: _subject,
    sessionSeconds: sessionSeconds,
    onGroupActivityChanged: () => groupNotifications++,
    now: now,
  );
  return (
    persister: persister,
    update: update,
    log: log,
    daily: daily,
    groupNotifications: () => groupNotifications,
  );
}

void main() {
  test("flush writes the elapsed delta once and tracks what was persisted", () {
    int seconds = 0;
    final harness = _build(sessionSeconds: () => seconds);

    seconds = 90;
    harness.persister.flush();

    return Future<void>.delayed(Duration.zero, () {
      expect(harness.update.calls, 1);
      expect(harness.update.totalSecondsSeen, [190]);
      expect(harness.persister.persistedSeconds, 90);
      expect(harness.persister.hasLoggedTime, isTrue);
      expect(harness.daily.addedSeconds, 90);
    });
  });

  test("a flush requested mid-flight coalesces into a single extra pass",
      () async {
    int seconds = 30;
    final harness = _build(sessionSeconds: () => seconds);
    harness.update.gate = Completer<void>();

    harness.persister.flush(); // starts, blocks on the gated backend call
    await Future<void>.delayed(Duration.zero);
    expect(harness.update.calls, 1);

    // Three more flushes while the first is in flight must not start new loops.
    seconds = 45;
    harness.persister.flush();
    harness.persister.flush();
    harness.persister.flush();
    expect(harness.update.calls, 1);

    harness.update.gate!.complete();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    // Exactly one more pass for the coalesced request, not three.
    expect(harness.update.calls, 2);
    expect(harness.persister.persistedSeconds, 45);
  });

  test("keeps flushing while sessionSeconds is still growing", () async {
    int seconds = 20;
    final harness = _build(sessionSeconds: () => seconds);

    // Each backend call bumps the counter, so the loop should re-run until the
    // counter stops moving.
    harness.update.gate = null;
    seconds = 20;
    final int base = harness.update.calls;
    harness.persister.flush();
    await Future<void>.delayed(Duration.zero);
    seconds = 40;
    harness.persister.flush();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(harness.update.calls, greaterThan(base));
    expect(harness.persister.persistedSeconds, 40);
  });

  test("a failed backend write leaves the persisted marker untouched",
      () async {
    int seconds = 60;
    final harness = _build(sessionSeconds: () => seconds, succeeds: false);

    harness.persister.flush();
    await Future<void>.delayed(Duration.zero);

    expect(harness.update.calls, 1);
    expect(harness.persister.hasLoggedTime, isFalse);
    expect(harness.persister.persistedSeconds, 0);
    expect(harness.daily.addedSeconds, 0);
  });

  test("autoSaveIfNeeded only flushes once per interval", () async {
    int seconds = 0;
    final DateTime start = DateTime(2026, 8, 26, 12);
    final harness = _build(
      sessionSeconds: () => seconds,
      autoSaveInterval: const Duration(seconds: 10),
      now: start,
    );

    seconds = 5;
    harness.persister.autoSaveIfNeeded(start.add(const Duration(seconds: 4)));
    expect(harness.update.calls, 0); // inside the interval

    harness.persister.autoSaveIfNeeded(start.add(const Duration(seconds: 11)));
    await Future<void>.delayed(Duration.zero);
    expect(harness.update.calls, 1);

    seconds = 6;
    harness.persister.autoSaveIfNeeded(start.add(const Duration(seconds: 15)));
    expect(harness.update.calls, 1); // interval since last save not elapsed
  });

  test("autoSaveIfNeeded does nothing when there is no new time", () {
    final harness = _build(sessionSeconds: () => 0);
    harness.persister.autoSaveIfNeeded(DateTime(2026, 8, 26, 13));
    expect(harness.update.calls, 0);
  });
}
