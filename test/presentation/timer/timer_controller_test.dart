import "package:fake_async/fake_async.dart";
import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:flutter/material.dart";
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
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/timer/timer_controller.dart";
import "package:timing/presentation/timer/timer_page.dart";
import "package:timing/theme/theme.dart";

/// Catch-all fake: none of these dependencies is exercised by the pure getters
/// under test, so every member routes through [noSuchMethod] and returns null.
class _Noop {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeUpdateSubjectTimeUseCase extends _Noop
    implements UpdateSubjectTimeUseCase {
  final List<int> totals = <int>[];

  @override
  Future<Either<AppError, void>> call({
    required String subjectId,
    required int totalSeconds,
  }) async {
    totals.add(totalSeconds);
    return const Right(null);
  }
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

class _FakeLastActivityService extends _Noop implements LastActivityService {
  @override
  Future<void> record(String label, {String? subjectId}) async {}
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
  int registeredSessions = 0;

  @override
  Future<void> addFocusSeconds(int seconds) async {}

  @override
  Future<void> registerSession() async {
    registeredSessions++;
  }
}

class _FakeSubjectDailyHistoryService extends _Noop
    implements SubjectDailyHistoryService {
  _FakeSubjectDailyHistoryService([
    this.progress = const DailyProgressEntity(),
  ]);

  final DailyProgressEntity progress;
  int addedSeconds = 0;

  @override
  DailyProgressEntity todayForSubject(String subjectId) => progress;

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

class _FakeTimerNotificationService extends _Noop
    implements TimerNotificationService {
  int cancelFocusFinishedCount = 0;
  int cancelRestFinishedCount = 0;
  int cancelScheduledAlarmsCount = 0;
  int scheduleFocusFinishedCount = 0;
  int scheduleRestFinishedCount = 0;
  int scheduleReadingRemindersCount = 0;
  int scheduleSessionTimelineCount = 0;
  int cancelOngoingCount = 0;
  int cancelCount = 0;
  int showRunningCount = 0;
  Duration? readingFirstReminder;
  Duration? readingReminderInterval;

  @override
  Future<void> cancelFocusFinished() async {
    cancelFocusFinishedCount++;
  }

  @override
  Future<void> cancelRestFinished() async {
    cancelRestFinishedCount++;
  }

  @override
  Future<void> cancelScheduledAlarms() async {
    cancelScheduledAlarmsCount++;
  }

  @override
  Future<void> scheduleFocusFinished({
    required String title,
    required String body,
    required Duration remaining,
  }) async {
    scheduleFocusFinishedCount++;
  }

  @override
  Future<void> scheduleRestFinished({
    required String title,
    required String body,
    required Duration remaining,
  }) async {
    scheduleRestFinishedCount++;
  }

  @override
  Future<void> scheduleReadingReminders({
    required String title,
    required String body,
    required Duration firstReminder,
    required Duration interval,
  }) async {
    scheduleReadingRemindersCount++;
    readingFirstReminder = firstReminder;
    readingReminderInterval = interval;
  }

  @override
  Future<void> scheduleSessionTimeline({
    required String title,
    required String focusFinishedBody,
    required String restFinishedBody,
    required String sessionFinishedBody,
    required Duration focusRemaining,
    required Duration restRemaining,
    required Duration focusInterval,
    required Duration restInterval,
    required int remainingFocusSections,
    required bool isResting,
  }) async {
    scheduleSessionTimelineCount++;
  }

  @override
  Future<void> cancelOngoing() async {
    cancelOngoingCount++;
  }

  @override
  Future<void> showRunning({
    required String title,
    required String body,
    required DateTime startedAt,
  }) async {
    showRunningCount++;
  }

  @override
  Future<void> showStatic({
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancel() async {
    cancelCount++;
  }
}

class _FakeTimerLiveActivityService extends _Noop
    implements TimerLiveActivityService {
  TimerLiveActivityAction? pendingAction;
  int? timerSeconds;
  bool? countsUp;
  int endCount = 0;

  @override
  Future<void> startOrUpdate({
    required String subjectName,
    required int colorValue,
    required int remainingSeconds,
    required bool isRunning,
    required bool isResting,
    required bool isCountUp,
  }) async {
    timerSeconds = remainingSeconds;
    countsUp = isCountUp;
  }

  @override
  Future<TimerLiveActivityAction?> consumePendingAction() async {
    final action = pendingAction;
    pendingAction = null;
    return action;
  }

  @override
  Future<void> end() async {
    endCount++;
  }
}

class _FakeFocusFeedbackService extends _Noop implements FocusFeedbackService {
  int finishFeedbackCount = 0;
  int focusLockWarningCount = 0;

  @override
  Future<void> playFocusFinishedFeedback() async {
    finishFeedbackCount++;
  }

  @override
  Future<void> warnFocusLock() async {
    focusLockWarningCount++;
  }
}

class _FakeFocusGuardService extends _Noop implements FocusGuardService {
  final List<bool> keepScreenOnValues = <bool>[];
  final List<bool> immersiveModeValues = <bool>[];
  int bringAppToFrontCount = 0;

  @override
  Future<void> setKeepScreenOn(bool enabled) async {
    keepScreenOnValues.add(enabled);
  }

  @override
  Future<void> setImmersiveMode(bool enabled) async {
    immersiveModeValues.add(enabled);
  }

  @override
  Future<void> bringAppToFront() async {
    bringAppToFrontCount++;
  }
}

class _FakeFocusOverlayService extends _Noop implements FocusOverlayService {
  int showCount = 0;
  int? timerSeconds;
  bool? countsUp;
  bool? usesRoutine;

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
    required bool isCountUp,
    required bool usesFocusRoutine,
    required int colorValue,
    required int currentFocusSection,
    required int totalFocusSections,
    required int focusIntervalSeconds,
    required int restIntervalSeconds,
  }) async {
    showCount++;
    timerSeconds = remainingSeconds;
    countsUp = isCountUp;
    usesRoutine = usesFocusRoutine;
  }

  @override
  Future<void> hide() async {}
}

class _FakeAnalyticsService extends _Noop implements AnalyticsService {}

class _FakeAppController extends _Noop implements AppController {
  _FakeAppController({
    this.focusLockEnabled = false,
    bool notificationsEnabled = true,
  }) : notificationsEnabled = notificationsEnabled.obs;

  final bool focusLockEnabled;
  int enableNotificationsCount = 0;

  @override
  final RxBool notificationsEnabled;

  @override
  Locale get selectedLocale => const Locale("pt");

  @override
  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled.value = value;
    if (value) {
      enableNotificationsCount++;
    }
  }

  @override
  bool isFocusLockEnabledFor(TimeCategoryType category) => focusLockEnabled;
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
  SubjectActivityType activityType = SubjectActivityType.permanent,
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
  // Permanent keeps most getter tests off the daily-history service, so the
  // getters stay pure unless a test opts into daily activity behavior.
  activityType: activityType,
);

TimerController _controller(
  SubjectEntity subject, {
  FocusFeedbackService? focusFeedbackService,
  FocusGuardService? focusGuardService,
  FocusOverlayService? focusOverlayService,
  TimerNotificationService? timerNotificationService,
  TimerLiveActivityService? timerLiveActivityService,
  UpdateSubjectTimeUseCase? updateSubjectTimeUseCase,
  DailyProgressService? dailyProgressService,
  SubjectDailyHistoryService? subjectDailyHistoryService,
  AppController? appController,
}) => TimerController(
  updateSubjectTimeUseCase:
      updateSubjectTimeUseCase ?? _FakeUpdateSubjectTimeUseCase(),
  updateSubjectPagesUseCase: _FakeUpdateSubjectPagesUseCase(),
  logActivityUseCase: _FakeLogActivityUseCase(),
  lastActivityService: _FakeLastActivityService(),
  activityHistoryService: _FakeActivityHistoryService(),
  dailyProgressService: dailyProgressService ?? _FakeDailyProgressService(),
  subjectDailyHistoryService:
      subjectDailyHistoryService ?? _FakeSubjectDailyHistoryService(),
  achievementUnlockService: _FakeAchievementUnlockService(),
  timerNotificationService:
      timerNotificationService ?? _FakeTimerNotificationService(),
  timerLiveActivityService:
      timerLiveActivityService ?? _FakeTimerLiveActivityService(),
  focusFeedbackService: focusFeedbackService ?? _FakeFocusFeedbackService(),
  focusGuardService: focusGuardService ?? _FakeFocusGuardService(),
  focusOverlayService: focusOverlayService ?? _FakeFocusOverlayService(),
  analyticsService: _FakeAnalyticsService(),
  activityChangeBus: ActivityChangeBus(),
  appController: appController ?? _FakeAppController(),
  appNavigator: _FakeAppNavigator(),
  subject: subject,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("hobby overtime keeps the full ring and working controls", (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(Get.reset);
    Get.put<AppNavigator>(AppNavigator());
    final controller = Get.put(
      _controller(
        _subject(
          category: TimeCategoryType.hobbies,
          goalSeconds: 30 * 60,
          activityType: SubjectActivityType.daily,
        ),
      ),
    );
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.dark),
        locale: const Locale("pt"),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const TimerPage(),
      ),
    );
    final l10n = lookupAppLocalizations(const Locale("pt"));
    Finder actionButton(String label) => find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == label,
      ),
      matching: find.byType(GestureDetector),
    );
    final fullRing = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label == l10n.timerProgressSemanticLabel(100),
    );
    controller.advanceForTesting(30 * 60);
    await tester.pump();
    expect(fullRing, findsOneWidget);

    controller.advanceForTesting(60);
    await tester.pump();
    expect(find.text("31"), findsOneWidget);
    expect(fullRing, findsOneWidget);
    expect(find.text(l10n.timerPauseButton), findsOneWidget);
    expect(find.text(l10n.timerEndActionLabel), findsOneWidget);
    expect(find.text(l10n.timerSessionSavedTitle), findsNothing);

    await tester.tap(actionButton(l10n.timerPauseButton));
    await tester.pump();
    controller.advanceForTesting(60);
    expect(controller.sessionSeconds.value, 31 * 60);
    expect(fullRing, findsOneWidget);

    await tester.tap(actionButton(l10n.timerContinueButton));
    await tester.pump();
    controller.advanceForTesting(60);
    await tester.pump();
    expect(find.text("32"), findsOneWidget);

    await tester.tap(actionButton(l10n.timerEndActionLabel));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(controller.isSessionFinished.value, isTrue);
    expect(controller.sessionSeconds.value, 32 * 60);
    expect(tester.takeException(), isNull);
  });

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
    test("uses rest seconds for exercises", () {
      final controller = _controller(
        _subject(category: TimeCategoryType.exercises, restMinutes: 30),
      );

      expect(controller.restIntervalSeconds, 30);
    });

    test("uses small exercise rest values as seconds", () {
      final controller = _controller(
        _subject(category: TimeCategoryType.exercises, restMinutes: 8),
      );

      expect(controller.restIntervalSeconds, 8);
    });

    test("uses rest minutes for studying", () {
      final controller = _controller(
        _subject(category: TimeCategoryType.studying, restMinutes: 30),
      );

      expect(controller.restIntervalSeconds, 30 * 60);
    });

    test(
      "falls back to the default exercise rest seconds when non-positive",
      () {
        final controller = _controller(
          _subject(category: TimeCategoryType.exercises, restMinutes: 0),
        );

        expect(
          controller.restIntervalSeconds,
          SubjectEntity.defaultRestSeconds,
        );
      },
    );

    test("falls back to the default study rest minutes when non-positive", () {
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

    test("hobbies always use a single continuous duration", () {
      final controller = _controller(
        _subject(category: TimeCategoryType.hobbies, focusSessionCount: 3),
      );

      expect(controller.focusSessionCount, 1);
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

    test("daily hobbies stay complete after today's goal is reached", () {
      final controller = _controller(
        _subject(
          category: TimeCategoryType.hobbies,
          goalSeconds: 30 * 60,
          activityType: SubjectActivityType.daily,
        ),
        subjectDailyHistoryService: _FakeSubjectDailyHistoryService(
          const DailyProgressEntity(focusSeconds: 36 * 60),
        ),
      );

      expect(controller.breakCountdownSeconds.value, 0);
      expect(controller.focusProgress, 1);
      expect(controller.currentActivitySeconds, 36 * 60);
    });

    test("daily hobbies already completed today can keep running", () async {
      final guard = _FakeFocusGuardService();
      final feedback = _FakeFocusFeedbackService();
      final daily = _FakeDailyProgressService();
      final controller = _controller(
        _subject(
          category: TimeCategoryType.hobbies,
          goalSeconds: 30 * 60,
          activityType: SubjectActivityType.daily,
        ),
        focusGuardService: guard,
        focusFeedbackService: feedback,
        dailyProgressService: daily,
        appController: _FakeAppController(focusLockEnabled: true),
        subjectDailyHistoryService: _FakeSubjectDailyHistoryService(
          const DailyProgressEntity(focusSeconds: 36 * 60),
        ),
      );

      controller.onInit();
      await Future<void>.delayed(Duration.zero);

      controller.advanceForTesting(60);

      expect(controller.isRunning.value, isTrue);
      expect(controller.isSessionFinished.value, isFalse);
      expect(controller.completedFocusSections.value, 1);
      expect(controller.currentActivitySeconds, 37 * 60);
      expect(controller.focusProgress, 1);
      expect(guard.keepScreenOnValues.last, isTrue);
      expect(feedback.finishFeedbackCount, 0);
      expect(daily.registeredSessions, 0);

      controller.onClose();
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

    test(
      "focus lock does not block an explicit exit without progress",
      () async {
        final feedback = _FakeFocusFeedbackService();
        final controller = _controller(
          _subject(),
          focusFeedbackService: feedback,
          appController: _FakeAppController(focusLockEnabled: true),
        );

        expect(await controller.confirmExitIfNeeded(), isTrue);
        expect(feedback.focusLockWarningCount, 0);
        expect(controller.isSessionFinished.value, isFalse);
      },
    );

    test("pausing focus lock allows the normal exit flow", () async {
      final feedback = _FakeFocusFeedbackService();
      final controller = _controller(
        _subject(),
        focusFeedbackService: feedback,
        appController: _FakeAppController(focusLockEnabled: true),
      );
      controller.isRunning.value = false;

      expect(await controller.confirmExitIfNeeded(), isTrue);
      expect(feedback.focusLockWarningCount, 0);
    });
  });

  group("TimerController focus guard", () {
    test("keeps the screen awake and hides navigation while active", () async {
      final guard = _FakeFocusGuardService();
      final controller = _controller(
        _subject(),
        focusGuardService: guard,
        appController: _FakeAppController(focusLockEnabled: true),
      );

      controller.onInit();
      await Future<void>.delayed(Duration.zero);

      expect(guard.keepScreenOnValues, contains(true));
      expect(guard.immersiveModeValues, contains(true));

      controller.onClose();
    });

    test("restores screen navigation when the session is paused", () async {
      final guard = _FakeFocusGuardService();
      final controller = _controller(
        _subject(),
        focusGuardService: guard,
        appController: _FakeAppController(focusLockEnabled: true),
      );

      controller.togglePause();
      await Future<void>.delayed(Duration.zero);

      expect(guard.keepScreenOnValues.last, isFalse);
      expect(guard.immersiveModeValues.last, isFalse);
    });
  });

  group("TimerController focus/rest cycle", () {
    test("reading keeps counting up without sections or an end", () {
      final feedback = _FakeFocusFeedbackService();
      final controller = _controller(
        _subject(category: TimeCategoryType.reading, goalSeconds: 0),
        focusFeedbackService: feedback,
      );

      controller.advanceForTesting(90 * 60 + 7);

      expect(controller.sessionSeconds.value, 90 * 60 + 7);
      expect(controller.completedFocusSections.value, 0);
      expect(controller.isResting.value, isFalse);
      expect(controller.isSessionFinished.value, isFalse);
      expect(feedback.finishFeedbackCount, 3);
    });

    test("hobby keeps running after the goal without starting a rest", () {
      final feedback = _FakeFocusFeedbackService();
      final daily = _FakeDailyProgressService();
      final liveActivity = _FakeTimerLiveActivityService();
      final controller = _controller(
        _subject(
          category: TimeCategoryType.hobbies,
          goalSeconds: 10,
          restMinutes: 15,
          focusSessionCount: 3,
        ),
        focusFeedbackService: feedback,
        dailyProgressService: daily,
        timerLiveActivityService: liveActivity,
      );

      controller.advanceForTesting(10);

      expect(controller.sessionSeconds.value, 10);
      expect(controller.completedFocusSections.value, 1);
      expect(controller.isResting.value, isFalse);
      expect(controller.isSessionFinished.value, isFalse);
      expect(controller.isRunning.value, isTrue);
      expect(controller.focusProgress, 1);

      controller.advanceForTesting(90);
      controller.advanceForTesting(1);

      expect(controller.sessionSeconds.value, 101);
      expect(controller.breakCountdownSeconds.value, 0);
      expect(controller.focusProgress, 1);
      expect(feedback.finishFeedbackCount, 1);
      expect(daily.registeredSessions, 1);
      expect(liveActivity.endCount, 0);
    });

    test("hobby daily goal keeps the extra time with a full ring", () {
      final controller = _controller(
        _subject(
          category: TimeCategoryType.hobbies,
          goalSeconds: 30 * 60,
          activityType: SubjectActivityType.daily,
        ),
        subjectDailyHistoryService: _FakeSubjectDailyHistoryService(
          const DailyProgressEntity(focusSeconds: 29 * 60),
        ),
      );

      controller.advanceForTesting(120);

      expect(controller.sessionSeconds.value, 120);
      expect(controller.currentActivitySeconds, 31 * 60);
      expect(controller.breakCountdownSeconds.value, 0);
      expect(controller.completedFocusSections.value, 1);
      expect(controller.focusProgress, 1);
      expect(controller.isSessionFinished.value, isFalse);
      expect(controller.isRunning.value, isTrue);
    });

    test("hobby overtime can be paused, resumed and saved on finish", () async {
      final update = _FakeUpdateSubjectTimeUseCase();
      final history = _FakeSubjectDailyHistoryService();
      final controller = _controller(
        _subject(
          category: TimeCategoryType.hobbies,
          goalSeconds: 30 * 60,
          totalSeconds: 100,
          activityType: SubjectActivityType.daily,
        ),
        updateSubjectTimeUseCase: update,
        subjectDailyHistoryService: history,
      );

      controller.advanceForTesting(31 * 60);
      controller.togglePause();
      controller.advanceForTesting(60);
      await Future<void>.delayed(Duration.zero);

      expect(controller.sessionSeconds.value, 31 * 60);
      expect(controller.isRunning.value, isFalse);
      expect(controller.focusProgress, 1);
      expect(update.totals.last, 100 + 31 * 60);

      controller.togglePause();
      controller.advanceForTesting(60);
      controller.finishSession();
      controller.advanceForTesting(60);
      await Future<void>.delayed(Duration.zero);

      expect(controller.sessionSeconds.value, 32 * 60);
      expect(controller.currentActivitySeconds, 32 * 60);
      expect(controller.isSessionFinished.value, isTrue);
      expect(controller.isRunning.value, isFalse);
      expect(update.totals.last, 100 + 32 * 60);
      expect(history.addedSeconds, 32 * 60);
    });

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

    test("finishes a single-section activity only after its rest", () {
      final feedback = _FakeFocusFeedbackService();
      final controller = _controller(
        _subject(
          category: TimeCategoryType.exercises,
          goalSeconds: 10,
          restMinutes: 30,
          focusSessionCount: 1,
        ),
        focusFeedbackService: feedback,
      );

      controller.advanceForTesting(10);

      expect(controller.isResting.value, isTrue);
      expect(controller.isSessionFinished.value, isFalse);
      expect(controller.restCountdownSeconds.value, 30);
      expect(feedback.finishFeedbackCount, 1);

      controller.advanceForTesting(30);

      expect(controller.isResting.value, isFalse);
      expect(controller.isSessionFinished.value, isTrue);
      expect(feedback.finishFeedbackCount, 2);
    });
  });

  group("TimerController background focus indicator", () {
    test("counts all hobby overtime in the background without stopping", () {
      final feedback = _FakeFocusFeedbackService();
      final controller = _controller(
        _subject(category: TimeCategoryType.hobbies, goalSeconds: 30 * 60),
        focusFeedbackService: feedback,
      );
      controller.didChangeAppLifecycleState(AppLifecycleState.paused);

      controller.advanceForTesting(31 * 60);

      expect(controller.sessionSeconds.value, 31 * 60);
      expect(controller.focusProgress, 1);
      expect(controller.isRunning.value, isTrue);
      expect(controller.isSessionFinished.value, isFalse);
      expect(feedback.finishFeedbackCount, 0);
    });

    test(
      "hobby live activity supports pause, resume and finish in overtime",
      () {
        fakeAsync((async) {
          final liveActivity = _FakeTimerLiveActivityService();
          final daily = _FakeDailyProgressService();
          final controller = _controller(
            _subject(
              category: TimeCategoryType.hobbies,
              activityType: SubjectActivityType.daily,
            ),
            timerLiveActivityService: liveActivity,
            dailyProgressService: daily,
            subjectDailyHistoryService: _FakeSubjectDailyHistoryService(
              const DailyProgressEntity(focusSeconds: 29 * 60),
            ),
          );
          controller.onInit();
          async.flushMicrotasks();
          expect(liveActivity.countsUp, isTrue);

          liveActivity.pendingAction = const TimerLiveActivityAction(
            action: "pause",
            isRunning: false,
            isResting: false,
            remainingSeconds: 120,
          );
          async.elapse(const Duration(seconds: 1));
          expect(controller.currentActivitySeconds, 31 * 60);
          expect(controller.isRunning.value, isFalse);
          expect(controller.isSessionFinished.value, isFalse);
          expect(controller.focusProgress, 1);

          liveActivity.pendingAction = const TimerLiveActivityAction(
            action: "resume",
            isRunning: true,
            isResting: false,
            remainingSeconds: 120,
          );
          async.elapse(const Duration(seconds: 1));
          expect(controller.isRunning.value, isTrue);
          expect(liveActivity.timerSeconds, 120);

          liveActivity.pendingAction = const TimerLiveActivityAction(
            action: "finish",
            isRunning: false,
            isResting: false,
            remainingSeconds: 180,
          );
          async.elapse(const Duration(seconds: 1));
          expect(controller.currentActivitySeconds, 32 * 60);
          expect(controller.isSessionFinished.value, isTrue);
          expect(controller.isRunning.value, isFalse);
          expect(daily.registeredSessions, 1);
          expect(liveActivity.endCount, 1);
          controller.onClose();
          async.flushMicrotasks();
        });
      },
    );

    test("enables timer alerts when a session starts", () async {
      final notifications = _FakeTimerNotificationService();
      final appController = _FakeAppController(notificationsEnabled: false);
      final controller = _controller(
        _subject(),
        timerNotificationService: notifications,
        appController: appController,
      );

      controller.onInit();
      await Future<void>.delayed(Duration.zero);

      expect(appController.notificationsEnabled.value, isTrue);
      expect(appController.enableNotificationsCount, 1);
      expect(notifications.showRunningCount, 1);

      controller.onClose();
    });

    test("returns to the app when focus lock goes to background", () async {
      final overlay = _FakeFocusOverlayService();
      final guard = _FakeFocusGuardService();
      final feedback = _FakeFocusFeedbackService();
      final controller = _controller(
        _subject(),
        focusOverlayService: overlay,
        focusGuardService: guard,
        focusFeedbackService: feedback,
        appController: _FakeAppController(focusLockEnabled: true),
      );

      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      await Future<void>.delayed(Duration.zero);

      expect(feedback.focusLockWarningCount, 1);
      expect(guard.bringAppToFrontCount, 1);
      expect(overlay.showCount, 0);
      controller.onClose();
    });

    test("shows reading as a count-up stopwatch in the overlay", () {
      final overlay = _FakeFocusOverlayService();
      final controller = _controller(
        _subject(category: TimeCategoryType.reading, goalSeconds: 0),
        focusOverlayService: overlay,
      );
      controller.sessionSeconds.value = 42;

      controller.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(overlay.timerSeconds, 42);
      expect(overlay.countsUp, isTrue);
    });

    test("hides sections and rest cycles from the hobby overlay", () {
      final overlay = _FakeFocusOverlayService();
      final controller = _controller(
        _subject(category: TimeCategoryType.hobbies),
        focusOverlayService: overlay,
      );

      controller.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(overlay.countsUp, isTrue);
      expect(overlay.usesRoutine, isFalse);
    });

    test("schedules reading reminders every 30 minutes", () {
      final notifications = _FakeTimerNotificationService();
      final controller = _controller(
        _subject(category: TimeCategoryType.reading, goalSeconds: 0),
        timerNotificationService: notifications,
      );
      controller.sessionSeconds.value = 5 * 60;

      controller.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(notifications.scheduleReadingRemindersCount, 1);
      expect(notifications.readingFirstReminder, const Duration(minutes: 25));
      expect(
        notifications.readingReminderInterval,
        const Duration(minutes: 30),
      );
      expect(notifications.scheduleSessionTimelineCount, 0);
    });

    test("schedules only the hobby completion alarm", () {
      final notifications = _FakeTimerNotificationService();
      final controller = _controller(
        _subject(category: TimeCategoryType.hobbies, goalSeconds: 20),
        timerNotificationService: notifications,
      );

      controller.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(notifications.scheduleFocusFinishedCount, 1);
      expect(notifications.scheduleSessionTimelineCount, 0);
      expect(notifications.scheduleRestFinishedCount, 0);
    });

    test("keeps the hobby overlay counting without new alarms in overtime", () {
      final overlay = _FakeFocusOverlayService();
      final notifications = _FakeTimerNotificationService();
      final controller = _controller(
        _subject(category: TimeCategoryType.hobbies),
        focusOverlayService: overlay,
        timerNotificationService: notifications,
      );
      controller.advanceForTesting(31 * 60);

      controller.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(overlay.timerSeconds, 31 * 60);
      expect(overlay.countsUp, isTrue);
      expect(overlay.usesRoutine, isFalse);
      expect(notifications.scheduleFocusFinishedCount, 0);
      expect(notifications.showRunningCount, 1);
      expect(notifications.cancelOngoingCount, 0);
    });

    test(
      "schedules the complete remaining timeline when sent to background",
      () {
        final notifications = _FakeTimerNotificationService();
        final controller = _controller(
          _subject(goalSeconds: 10, restMinutes: 3, focusSessionCount: 2),
          timerNotificationService: notifications,
        );

        controller.didChangeAppLifecycleState(AppLifecycleState.paused);

        expect(notifications.scheduleSessionTimelineCount, 1);

        controller.didChangeAppLifecycleState(AppLifecycleState.hidden);
        expect(notifications.scheduleSessionTimelineCount, 1);
      },
    );

    test("keeps the final alarm scheduled when the background timer ends", () {
      final notifications = _FakeTimerNotificationService();
      final controller = _controller(
        _subject(
          category: TimeCategoryType.exercises,
          goalSeconds: 10,
          restMinutes: 30,
        ),
        timerNotificationService: notifications,
      );

      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      controller.advanceForTesting(40);

      expect(controller.isSessionFinished.value, isTrue);
      expect(notifications.cancelOngoingCount, 1);
      expect(notifications.cancelCount, 0);
    });
  });
}
