import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/daily_progress_entity.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/log_activity_use_case.dart";
import "package:timing/core/domain/use_cases/update_subject_pages_use_case.dart";
import "package:timing/core/domain/use_cases/update_subject_time_use_case.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/analytics/analytics_service.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/focus/focus_feedback_service.dart";
import "package:timing/core/services/focus/focus_guard_service.dart";
import "package:timing/core/services/focus/focus_overlay_service.dart";
import "package:timing/core/services/last_activity/last_activity_service.dart";
import "package:timing/core/services/live_activity/timer_live_activity_service.dart";
import "package:timing/core/services/notifications/timer_notification_service.dart";
import "package:timing/presentation/timer/timer_controller.dart";

/// Catch-all fake: none of these dependencies is exercised by the pure getters
/// under test, so every member routes through [noSuchMethod] and returns null.
class _Noop {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeUpdateSubjectTimeUseCase extends _Noop
    implements UpdateSubjectTimeUseCase {
  @override
  Future<Either<AppError, void>> call({
    required String subjectId,
    required int totalSeconds,
  }) async => const Right(null);
}

class _FakeUpdateSubjectPagesUseCase extends _Noop
    implements UpdateSubjectPagesUseCase {}

class _FakeLogActivityUseCase extends _Noop implements LogActivityUseCase {
  @override
  Future<Either<AppError, void>> call({
    required TimeCategoryType category,
    required String subjectId,
    required String subjectName,
    int seconds = 0,
    int pages = 0,
    int completedTasks = 0,
  }) async => const Right(null);
}

class _FakeLastActivityService extends _Noop implements LastActivityService {}

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
  @override
  Future<void> addFocusSeconds(int seconds) async {}

  @override
  Future<void> registerSession() async {}
}

class _FakeSubjectDailyHistoryService extends _Noop
    implements SubjectDailyHistoryService {
  @override
  DailyProgressEntity todayForSubject(String subjectId) =>
      const DailyProgressEntity();

  @override
  Future<void> addFocusSeconds(String subjectId, int seconds) async {}
}

class _FakeAchievementUnlockService extends _Noop
    implements AchievementUnlockService {
  @override
  Future<void> checkForNewUnlocks() async {}
}

class _FakeTimerNotificationService extends _Noop
    implements TimerNotificationService {}

class _FakeTimerLiveActivityService extends _Noop
    implements TimerLiveActivityService {
  @override
  Future<void> startOrUpdate({
    required String subjectName,
    required int colorValue,
    required int remainingSeconds,
    required bool isRunning,
    required bool isResting,
  }) async {}

  @override
  Future<TimerLiveActivityAction?> consumePendingAction() async => null;

  @override
  Future<void> end() async {}
}

class _FakeFocusFeedbackService extends _Noop implements FocusFeedbackService {
  int finishFeedbackCount = 0;

  @override
  Future<void> playFocusFinishedFeedback() async {
    finishFeedbackCount++;
  }
}

class _FakeFocusGuardService extends _Noop implements FocusGuardService {
  @override
  Future<void> setKeepScreenOn(bool enabled) async {}

  @override
  Future<void> startScreenLock() async {}

  @override
  Future<void> stopScreenLock() async {}
}

class _FakeFocusOverlayService extends _Noop implements FocusOverlayService {
  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> show({
    required String subjectName,
    required int remainingSeconds,
    required bool isRunning,
    required bool isResting,
    required int colorValue,
  }) async {}

  @override
  Future<void> update({
    required int remainingSeconds,
    required bool isRunning,
    required bool isResting,
  }) async {}

  @override
  Future<void> hide() async {}
}

class _FakeAnalyticsService extends _Noop implements AnalyticsService {}

class _FakeAppController extends _Noop implements AppController {
  @override
  bool isFocusLockEnabledFor(TimeCategoryType category) => false;
}

class _FakeAppNavigator extends _Noop implements AppNavigator {}

SubjectEntity _subject({
  TimeCategoryType category = TimeCategoryType.studying,
  int totalSeconds = 0,
  int goalSeconds = 1800,
  int restMinutes = 5,
  int focusSessionCount = 1,
  int currentPages = 0,
  String notes = "",
}) => SubjectEntity(
  id: "subject-1",
  name: "Matemática",
  category: category,
  colorValue: 0xFF000000,
  totalSeconds: totalSeconds,
  goalSeconds: goalSeconds,
  currentPages: currentPages,
  goalPages: 0,
  notes: notes,
  iconName: "clock",
  restMinutes: restMinutes,
  focusSessionCount: focusSessionCount,
  wallpaperIndex: 0,
  // Permanent keeps _initialBreakCountdownSeconds off the daily-history
  // service, so the getters stay pure.
  activityType: SubjectActivityType.permanent,
);

TimerController _controller(
  SubjectEntity subject, {
  FocusFeedbackService? focusFeedbackService,
}) => TimerController(
  updateSubjectTimeUseCase: _FakeUpdateSubjectTimeUseCase(),
  updateSubjectPagesUseCase: _FakeUpdateSubjectPagesUseCase(),
  logActivityUseCase: _FakeLogActivityUseCase(),
  lastActivityService: _FakeLastActivityService(),
  activityHistoryService: _FakeActivityHistoryService(),
  dailyProgressService: _FakeDailyProgressService(),
  subjectDailyHistoryService: _FakeSubjectDailyHistoryService(),
  achievementUnlockService: _FakeAchievementUnlockService(),
  timerNotificationService: _FakeTimerNotificationService(),
  timerLiveActivityService: _FakeTimerLiveActivityService(),
  focusFeedbackService: focusFeedbackService ?? _FakeFocusFeedbackService(),
  focusGuardService: _FakeFocusGuardService(),
  focusOverlayService: _FakeFocusOverlayService(),
  analyticsService: _FakeAnalyticsService(),
  appController: _FakeAppController(),
  appNavigator: _FakeAppNavigator(),
  subject: subject,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("TimerController focus interval", () {
    test("uses the subject goal when it is positive", () {
      final controller = _controller(_subject(goalSeconds: 1500));

      expect(controller.focusIntervalSeconds, 1500);
    });

    test("falls back to the default interval when the goal is zero", () {
      final controller = _controller(_subject(goalSeconds: 0));

      expect(
        controller.focusIntervalSeconds,
        TimerController.defaultFocusIntervalSeconds,
      );
    });
  });

  group("TimerController rest interval", () {
    test("uses the subject rest minutes when positive", () {
      final controller = _controller(_subject(restMinutes: 8));

      expect(controller.restIntervalSeconds, 8 * 60);
    });

    test("falls back to the default rest minutes when non-positive", () {
      final controller = _controller(_subject(restMinutes: 0));

      expect(
        controller.restIntervalSeconds,
        SubjectEntity.defaultRestMinutes * 60,
      );
    });
  });

  group("TimerController focus sections", () {
    test("never reports fewer than one section", () {
      final controller = _controller(_subject(focusSessionCount: 0));

      expect(controller.focusSessionCount, 1);
    });

    test("current section starts at one and clamps to the total", () {
      final controller = _controller(_subject(focusSessionCount: 3));

      expect(controller.currentFocusSection, 1);

      controller.completedFocusSections.value = 5;
      expect(controller.currentFocusSection, 3);
    });
  });

  group("TimerController initial break countdown", () {
    test("starts a full interval for a fresh subject", () {
      final controller = _controller(_subject(goalSeconds: 1800));

      expect(controller.breakCountdownSeconds.value, 1800);
      expect(controller.cycleElapsedSeconds, 0);
    });

    test("resumes mid-section from the elapsed time within the interval", () {
      // Two full intervals plus 400s into the third section.
      final controller = _controller(
        _subject(goalSeconds: 1800, totalSeconds: 1800 * 2 + 400),
      );

      expect(controller.breakCountdownSeconds.value, 1800 - 400);
      expect(controller.cycleElapsedSeconds, 400);
    });

    test("keeps a full interval for reading subjects", () {
      final controller = _controller(
        _subject(category: TimeCategoryType.reading, totalSeconds: 1234),
      );

      expect(controller.isReading, isTrue);
      expect(controller.breakCountdownSeconds.value, 1800);
    });
  });

  group("TimerController reading interval remaining", () {
    test("returns the remaining seconds within the current interval", () {
      final controller = _controller(
        _subject(category: TimeCategoryType.reading, goalSeconds: 1800),
      );

      controller.sessionSeconds.value = 500;
      expect(controller.readingIntervalRemainingSeconds, 1300);
    });

    test("returns a full interval at the boundary and at the start", () {
      final controller = _controller(
        _subject(category: TimeCategoryType.reading, goalSeconds: 1800),
      );

      controller.sessionSeconds.value = 0;
      expect(controller.readingIntervalRemainingSeconds, 1800);

      controller.sessionSeconds.value = 1800;
      expect(controller.readingIntervalRemainingSeconds, 1800);
    });
  });

  group("TimerController focus progress", () {
    test("is zero at the start of a section and 0.5 halfway through", () {
      final controller = _controller(_subject(goalSeconds: 1800));

      expect(controller.focusProgress, 0);

      controller.breakCountdownSeconds.value = 900;
      expect(controller.focusProgress, 0.5);
    });

    test("clamps to one once the countdown is exhausted", () {
      final controller = _controller(_subject(goalSeconds: 1800));

      controller.breakCountdownSeconds.value = -50;
      expect(controller.focusProgress, 1);
    });
  });

  group("TimerController session state", () {
    test("totalSeconds sums the subject total and the session", () {
      final controller = _controller(_subject(totalSeconds: 600));

      controller.sessionSeconds.value = 120;
      expect(controller.totalSeconds, 720);
    });

    test("hasActiveSession tracks session progress and completion", () {
      final controller = _controller(_subject());

      expect(controller.hasActiveSession, isFalse);

      controller.sessionSeconds.value = 10;
      expect(controller.hasActiveSession, isTrue);

      controller.isSessionFinished.value = true;
      expect(controller.hasActiveSession, isFalse);
    });

    test("updateSubjectNotes replaces the notes on the subject", () {
      final controller = _controller(_subject(notes: "antes"));

      controller.updateSubjectNotes("depois");
      expect(controller.subject.notes, "depois");
    });
  });

  group("TimerController focus/rest cycle", () {
    test("alarms at section end and rest end before the next section", () {
      final feedback = _FakeFocusFeedbackService();
      final controller = _controller(
        _subject(goalSeconds: 10, restMinutes: 1, focusSessionCount: 2),
        focusFeedbackService: feedback,
      );

      controller.advanceForTesting(10);

      expect(feedback.finishFeedbackCount, 1);
      expect(controller.isResting.value, isTrue);
      expect(controller.completedFocusSections.value, 1);

      controller.restCountdownSeconds.value = 1;
      controller.advanceForTesting(1);

      expect(feedback.finishFeedbackCount, 2);
      expect(controller.isResting.value, isFalse);
      expect(controller.breakCountdownSeconds.value, 10);
      expect(controller.completedFocusSections.value, 1);
    });

    test("does not alarm when the user skips rest manually", () {
      final feedback = _FakeFocusFeedbackService();
      final controller = _controller(
        _subject(goalSeconds: 10, restMinutes: 1, focusSessionCount: 2),
        focusFeedbackService: feedback,
      );

      controller.advanceForTesting(10);
      controller.skipRest();

      expect(feedback.finishFeedbackCount, 1);
      expect(controller.isResting.value, isFalse);
      expect(controller.breakCountdownSeconds.value, 10);
    });
  });
}
