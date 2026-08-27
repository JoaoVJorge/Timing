import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/use_cases/update_subject_pages_use_case.dart";
import "package:timing/core/domain/use_cases/update_subject_time_use_case.dart";
import "package:timing/core/domain/use_cases/log_activity_use_case.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/services/analytics/analytics_event.dart";
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
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/timer/timer_session_persister.dart";
import "package:timing/presentation/timer/widgets/timer_exit_dialog.dart";

class TimerController extends GetxController with WidgetsBindingObserver {
  TimerController({
    required this.updateSubjectTimeUseCase,
    required this.updateSubjectPagesUseCase,
    required this.logActivityUseCase,
    required this.lastActivityService,
    required this.activityHistoryService,
    required this.dailyProgressService,
    required this.subjectDailyHistoryService,
    required this.achievementUnlockService,
    required this.timerNotificationService,
    required this.timerLiveActivityService,
    required this.focusFeedbackService,
    required this.focusGuardService,
    required this.focusOverlayService,
    required this.analyticsService,
    required this.activityChangeBus,
    required this.appController,
    required this.appNavigator,
    required this.subject,
  }) : _todayFocusSecondsAtSessionStart = subjectDailyHistoryService
           .todayForSubject(subject.id)
           .focusSeconds;

  static const int defaultFocusIntervalSeconds = 30 * 60;
  static const Duration autoSaveInterval = Duration(seconds: 10);
  static const Duration focusLockReturnCooldown = Duration(seconds: 5);

  /// Upper bound for a session-seconds value coming back from the Live Activity
  /// bridge, so a bogus payload can never push the counter to a nonsensical
  /// value. ~68 years — far past any real reading session.
  static const int _maxSessionSeconds = 1 << 31;

  final UpdateSubjectTimeUseCase updateSubjectTimeUseCase;
  final UpdateSubjectPagesUseCase updateSubjectPagesUseCase;
  final LogActivityUseCase logActivityUseCase;
  final LastActivityService lastActivityService;
  final ActivityHistoryService activityHistoryService;
  final DailyProgressService dailyProgressService;
  final SubjectDailyHistoryService subjectDailyHistoryService;
  final AchievementUnlockService achievementUnlockService;
  final TimerNotificationService timerNotificationService;
  final TimerLiveActivityService timerLiveActivityService;
  final FocusFeedbackService focusFeedbackService;
  final FocusGuardService focusGuardService;
  final FocusOverlayService focusOverlayService;
  final AnalyticsService analyticsService;
  final ActivityChangeBus activityChangeBus;
  final AppController appController;
  final AppNavigator appNavigator;

  SubjectEntity subject;

  final RxInt sessionSeconds = 0.obs;
  late final RxInt breakCountdownSeconds = _initialBreakCountdownSeconds.obs;
  late final RxInt restCountdownSeconds = restIntervalSeconds.obs;
  final RxBool isRunning = true.obs;
  final RxBool isResting = false.obs;
  final RxBool isSessionFinished = false.obs;
  final RxInt completedFocusSections = 0.obs;

  Timer? _ticker;
  bool _hasRecordedLastActivity = false;
  bool _isConsumingLiveActivityAction = false;
  bool _isFinishingSession = false;
  bool _isAppInForeground = true;
  bool _isCatchingUpAfterBackground = false;
  bool _isRequestingFocusLockReturn = false;
  final int _todayFocusSecondsAtSessionStart;
  DateTime? _lastFocusLockWarningAt;
  Timer? _focusLockReturnResetTimer;
  late DateTime _lastTickAt;

  late final TimerSessionPersister _persister = TimerSessionPersister(
    updateSubjectTimeUseCase: updateSubjectTimeUseCase,
    logActivityUseCase: logActivityUseCase,
    activityHistoryService: activityHistoryService,
    dailyProgressService: dailyProgressService,
    subjectDailyHistoryService: subjectDailyHistoryService,
    achievementUnlockService: achievementUnlockService,
    subject: () => subject,
    sessionSeconds: () => sessionSeconds.value,
    onGroupActivityChanged: _notifyGroupActivityChanged,
    autoSaveInterval: autoSaveInterval,
  );

  int get totalSeconds => subject.totalSeconds + sessionSeconds.value;

  int get currentActivitySeconds {
    final int seconds = _todayFocusSecondsAtSessionStart + sessionSeconds.value;
    if (_isDailyHobbyGoal) {
      return seconds.clamp(0, focusIntervalSeconds).toInt();
    }
    return seconds;
  }

  int get currentActivityPages =>
      subject.activityType == SubjectActivityType.daily
      ? subjectDailyHistoryService.todayForSubject(subject.id).pages
      : subject.currentPages;

  bool get isReading => subject.category == TimeCategoryType.reading;

  bool get isHobby => subject.category == TimeCategoryType.hobbies;

  bool get _isDailyHobbyGoal =>
      isHobby &&
      subject.activityType == SubjectActivityType.daily &&
      focusIntervalSeconds > 0;

  bool get _isDailyHobbyGoalAlreadyComplete =>
      _isDailyHobbyGoal &&
      _todayFocusSecondsAtSessionStart >= focusIntervalSeconds;

  int get focusIntervalSeconds => subject.goalSeconds > 0
      ? subject.goalSeconds
      : defaultFocusIntervalSeconds;

  int get cycleElapsedSeconds =>
      focusIntervalSeconds - breakCountdownSeconds.value;

  int get readingIntervalRemainingSeconds {
    if (!isReading) {
      return breakCountdownSeconds.value;
    }
    final int elapsedInInterval =
        sessionSeconds.value % defaultFocusIntervalSeconds;
    return elapsedInInterval == 0
        ? defaultFocusIntervalSeconds
        : defaultFocusIntervalSeconds - elapsedInInterval;
  }

  double get focusProgress =>
      (cycleElapsedSeconds / focusIntervalSeconds).clamp(0, 1).toDouble();

  bool get hasActiveSession =>
      !isSessionFinished.value && sessionSeconds.value > 0;

  bool get isFocusLockActive =>
      appController.isFocusLockEnabledFor(subject.category) &&
      isRunning.value &&
      !isResting.value &&
      !isSessionFinished.value;

  int get restIntervalSeconds => subject.restSeconds > 0
      ? subject.restSeconds
      : SubjectEntity.defaultRestSeconds;

  int get focusSessionCount => isHobby
      ? 1
      : subject.focusSessionCount > 0
      ? subject.focusSessionCount
      : 1;

  int get currentFocusSection =>
      (completedFocusSections.value + 1).clamp(1, focusSessionCount);

  int get _initialBreakCountdownSeconds {
    if (isReading || focusIntervalSeconds <= 0) {
      return focusIntervalSeconds;
    }
    if (_isDailyHobbyGoal) {
      final int remainingSeconds =
          focusIntervalSeconds - _todayFocusSecondsAtSessionStart;
      return remainingSeconds.clamp(0, focusIntervalSeconds).toInt();
    }
    final int elapsedInSection =
        (subject.activityType == SubjectActivityType.daily
            ? subjectDailyHistoryService
                  .todayForSubject(subject.id)
                  .focusSeconds
            : subject.totalSeconds) %
        focusIntervalSeconds;
    if (elapsedInSection == 0) {
      return focusIntervalSeconds;
    }
    return focusIntervalSeconds - elapsedInSection;
  }

  static bool _overlayPermissionRequested = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _lastTickAt = DateTime.now();
    if (_isDailyHobbyGoalAlreadyComplete) {
      _markDailyHobbyGoalCompleteAtStart();
      _disableFocusGuard();
      return;
    }
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => unawaited(_tick()),
    );
    unawaited(_ensureTimerNotifications());
    _syncFocusGuard();
    unawaited(_ensureOverlayPermission());
    analyticsService.track(
      AnalyticsEvent.focusSessionStarted(category: subject.category),
    );
  }

  void _markDailyHobbyGoalCompleteAtStart() {
    completedFocusSections.value = focusSessionCount;
    breakCountdownSeconds.value = 0;
    isRunning.value = false;
    isResting.value = false;
    isSessionFinished.value = true;
  }

  Future<void> _tick() async {
    final bool consumedAction = await _consumeLiveActivityAction();
    if (consumedAction || isSessionFinished.value) {
      return;
    }

    final DateTime now = DateTime.now();
    final int elapsedSeconds = now.difference(_lastTickAt).inSeconds;
    if (elapsedSeconds <= 0) {
      return;
    }
    _lastTickAt = _lastTickAt.add(Duration(seconds: elapsedSeconds));

    if (!isRunning.value) {
      return;
    }

    _advanceBy(elapsedSeconds);
    _persister.autoSaveIfNeeded(now);
  }

  void _advanceBy(int seconds) {
    int remaining = seconds;
    while (remaining > 0 && isRunning.value) {
      if (isReading) {
        final int previousReminder =
            sessionSeconds.value ~/ defaultFocusIntervalSeconds;
        sessionSeconds.value += remaining;
        final int currentReminder =
            sessionSeconds.value ~/ defaultFocusIntervalSeconds;
        if (_isAppInForeground && !_isCatchingUpAfterBackground) {
          for (
            int reminder = previousReminder;
            reminder < currentReminder;
            reminder++
          ) {
            unawaited(focusFeedbackService.playFocusFinishedFeedback());
          }
        }
        remaining = 0;
        continue;
      }

      if (isResting.value) {
        if (restCountdownSeconds.value <= 0) {
          _finishRestPeriod();
          continue;
        }
        final int step = remaining.clamp(0, restCountdownSeconds.value);
        restCountdownSeconds.value -= step;
        remaining -= step;
        if (restCountdownSeconds.value <= 0) {
          _finishRestPeriod();
        }
        continue;
      }

      if (breakCountdownSeconds.value <= 0) {
        _completeFocusSection();
        continue;
      }
      final int step = remaining.clamp(0, breakCountdownSeconds.value);
      sessionSeconds.value += step;
      breakCountdownSeconds.value -= step;
      remaining -= step;
      if (breakCountdownSeconds.value <= 0) {
        _completeFocusSection();
      }
    }
  }

  void _completeFocusSection() {
    _persister.flush();
    completedFocusSections.value = (completedFocusSections.value + 1).clamp(
      0,
      focusSessionCount,
    );
    unawaited(
      dailyProgressService.registerSession().then(
        (_) => achievementUnlockService.checkForNewUnlocks(),
      ),
    );
    if (_isAppInForeground && !_isCatchingUpAfterBackground) {
      unawaited(focusFeedbackService.playFocusFinishedFeedback());
    }

    if (isHobby) {
      finishSession();
      return;
    }

    isResting.value = true;
    restCountdownSeconds.value = restIntervalSeconds;
    _updateNotification();
    _syncFocusGuard();
  }

  void _finishRestPeriod({bool playFeedback = true}) {
    isResting.value = false;
    if (playFeedback && _isAppInForeground && !_isCatchingUpAfterBackground) {
      unawaited(focusFeedbackService.playFocusFinishedFeedback());
    }
    if (completedFocusSections.value >= focusSessionCount) {
      finishSession();
      return;
    }
    isRunning.value = true;
    breakCountdownSeconds.value = focusIntervalSeconds;
    _updateNotification();
    _syncFocusGuard();
  }

  void togglePause() {
    isRunning.value = !isRunning.value;
    _lastTickAt = DateTime.now();

    unawaited(HapticFeedback.selectionClick());
    if (!isRunning.value) {
      _persister.flush();
    }
    _updateNotification();
    _syncFocusGuard();
  }

  void saveProgress() => _persister.flush();

  void skipRest() {
    if (!isResting.value || isReading) {
      return;
    }
    restCountdownSeconds.value = restIntervalSeconds;
    _finishRestPeriod(playFeedback: false);
  }

  void continueFocus() {
    isResting.value = false;
    isRunning.value = true;
    restCountdownSeconds.value = restIntervalSeconds;
    breakCountdownSeconds.value = focusIntervalSeconds;
    _updateNotification();
    _syncFocusGuard();
  }

  @visibleForTesting
  void advanceForTesting(int seconds) => _advanceBy(seconds);

  void updateSubjectNotes(String notes) {
    subject = subject.copyWith(notes: notes);
  }

  void finishSession() {
    final bool alreadyFinished = isSessionFinished.value;
    _persister.flush();
    _recordLastActivityIfNeeded();
    isRunning.value = false;
    isSessionFinished.value = true;
    _ticker?.cancel();
    unawaited(HapticFeedback.mediumImpact());
    if (_isAppInForeground) {
      timerNotificationService.cancel();
    } else {
      // Keep the already scheduled final alarm alive. It is the only reliable
      // sound/vibration source when Flutter is suspended in the background.
      timerNotificationService.cancelOngoing();
    }
    _hideOverlay();
    _syncFocusGuard();
    unawaited(timerLiveActivityService.end());
    if (!alreadyFinished) {
      _trackSessionCompleted();
    }
  }

  void _trackSessionCompleted() {
    analyticsService.track(
      AnalyticsEvent.focusSessionCompleted(
        category: subject.category,
        seconds: sessionSeconds.value,
        completedAllSections: completedFocusSections.value >= focusSessionCount,
      ),
    );
  }

  void warnFocusLock() {
    unawaited(focusFeedbackService.warnFocusLock());
    final BuildContext? context = Get.context;
    if (context == null) {
      return;
    }
    appNavigator.showSuccessSnackBar(context.l10n.timerFocusLockWarning);
  }

  Future<bool> confirmExitIfNeeded() async {
    if (!hasActiveSession) {
      saveProgress();
      return true;
    }

    final BuildContext context = Get.context!;
    if (isReading) {
      final int? pagesRead = await showReadingExitDialog(
        context: context,
        accentColor: context.colorTokens.primary,
        title: context.l10n.timerExitDialogTitle,
        content: _readingExitContent(context),
        cancelLabel: context.l10n.timerExitBackToFocus,
        confirmLabel: context.l10n.timerExitSaveAndEnd,
      );

      if (pagesRead != null) {
        finishReadingSession(pagesRead);
        return true;
      }
      return false;
    }

    final bool? shouldExit = await showTimerExitDialog(
      context: context,
      accentColor: context.colorTokens.primary,
      title: context.l10n.timerExitDialogTitle,
      content: context.l10n.timerExitDialogContent(
        _formatMinutesForDialog(sessionSeconds.value),
        subject.name,
      ),
      cancelLabel: context.l10n.timerExitBackToFocus,
      confirmLabel: context.l10n.timerExitSaveAndEnd,
    );

    if (shouldExit == true) {
      finishSession();
    }
    return shouldExit == true;
  }

  Future<bool> confirmFinishSession() async {
    if (_isFinishingSession || isSessionFinished.value) {
      return false;
    }
    _isFinishingSession = true;
    if (!isReading) {
      unawaited(HapticFeedback.selectionClick());
      await Future<void>.delayed(const Duration(milliseconds: 140));
      finishSession();
      if (Get.context != null) {
        await showTimerSessionEndedDialog(
          accentColor: Color(subject.colorValue),
          subjectName: subject.name,
        );
      }
      _isFinishingSession = false;
      return true;
    }

    final BuildContext context = Get.context!;
    final int? pagesRead = await showReadingExitDialog(
      context: context,
      accentColor: context.colorTokens.primary,
      title: context.l10n.timerExitDialogTitle,
      content: _readingExitContent(context),
      cancelLabel: context.l10n.timerExitBackToFocus,
      confirmLabel: context.l10n.timerExitSaveAndEnd,
    );

    if (pagesRead == null) {
      _isFinishingSession = false;
      return false;
    }
    finishReadingSession(pagesRead);
    _isFinishingSession = false;
    return true;
  }

  void finishReadingSession(int pagesRead) {
    final int sanitizedPages = pagesRead < 0 ? 0 : pagesRead;
    _persister.flush();
    if (sanitizedPages > 0) {
      final int nextPages = subject.currentPages + sanitizedPages;
      subject = subject.copyWith(currentPages: nextPages);
      unawaited(
        updateSubjectPagesUseCase(
          subjectId: subject.id,
          currentPages: nextPages,
        ).then((_) => achievementUnlockService.checkForNewUnlocks()),
      );
      unawaited(
        dailyProgressService
            .addPages(sanitizedPages)
            .then((_) => achievementUnlockService.checkForNewUnlocks()),
      );
      unawaited(
        subjectDailyHistoryService.addPages(subject.id, sanitizedPages),
      );
      unawaited(
        activityHistoryService.record(
          category: subject.category,
          subjectId: subject.id,
          subjectName: subject.name,
          pages: sanitizedPages,
        ),
      );
      unawaited(
        logActivityUseCase(
          category: subject.category,
          subjectId: subject.id,
          subjectName: subject.name,
          pages: sanitizedPages,
        ).then((_) => _notifyGroupActivityChanged()),
      );
    }
    _recordLastActivityIfNeeded();
    final bool alreadyFinished = isSessionFinished.value;
    isRunning.value = false;
    isSessionFinished.value = true;
    _ticker?.cancel();
    if (_isAppInForeground) {
      timerNotificationService.cancel();
    } else {
      timerNotificationService.cancelOngoing();
    }
    _hideOverlay();
    _syncFocusGuard();
    unawaited(timerLiveActivityService.end());
    if (!alreadyFinished) {
      _trackSessionCompleted();
    }
  }

  void _notifyGroupActivityChanged() {
    if (subject.isFromGroup) {
      activityChangeBus.notifyGroupActivityChanged(groupId: subject.groupId);
    }
  }

  void _recordLastActivityIfNeeded() {
    if (!_persister.hasLoggedTime || _hasRecordedLastActivity) {
      return;
    }
    _hasRecordedLastActivity = true;
    lastActivityService.record(subject.name, subjectId: subject.id);
  }

  String _formatMinutesForDialog(int seconds) {
    final int minutes = (seconds / 60).ceil();
    return "$minutes min";
  }

  String _readingExitContent(BuildContext context) {
    final String duration = _formatMinutesForDialog(sessionSeconds.value);
    return context.l10n.timerReadingExitContent(duration, subject.name);
  }

  void _updateNotification() {
    unawaited(
      timerLiveActivityService.startOrUpdate(
        subjectName: subject.name,
        colorValue: subject.colorValue,
        remainingSeconds: isReading
            ? sessionSeconds.value
            : isResting.value
            ? restCountdownSeconds.value
            : breakCountdownSeconds.value,
        isRunning: isRunning.value,
        isResting: isResting.value,
        isCountUp: isReading,
      ),
    );

    if (!appController.notificationsEnabled.value) {
      timerNotificationService.cancel();
      return;
    }

    final AppLocalizations l10n = lookupAppLocalizations(
      appController.selectedLocale,
    );
    final String runningBody = l10n.timerNotificationRunning;
    final String restingBody = l10n.timerNotificationResting;
    final String pausedBody = l10n.timerNotificationPaused;
    final String backgroundRunningBody = _isAppInForeground
        ? runningBody
        : "$runningBody · ${l10n.timerBackgroundSuffix}";
    final String backgroundRestingBody = _isAppInForeground
        ? restingBody
        : "$restingBody · ${l10n.timerBackgroundSuffix}";

    if (!isRunning.value) {
      timerNotificationService.cancelScheduledAlarms();
      timerNotificationService.showStatic(
        title: subject.name,
        body: pausedBody,
      );
      return;
    }

    if (isResting.value) {
      timerNotificationService.showStatic(
        title: subject.name,
        body: backgroundRestingBody,
      );
      return;
    }

    timerNotificationService.cancelRestFinished();
    timerNotificationService.showRunning(
      title: subject.name,
      body: backgroundRunningBody,
      startedAt: DateTime.now().subtract(
        Duration(seconds: sessionSeconds.value),
      ),
    );
  }

  Future<void> _ensureTimerNotifications() async {
    if (!appController.notificationsEnabled.value) {
      await appController.setNotificationsEnabled(true);
    }
    if (isSessionFinished.value) {
      return;
    }
    _updateNotification();
    if (!_isAppInForeground) {
      _scheduleBackgroundTimeline();
    }
  }

  void _scheduleBackgroundTimeline() {
    if (!appController.notificationsEnabled.value ||
        !isRunning.value ||
        isSessionFinished.value) {
      return;
    }
    final AppLocalizations l10n = lookupAppLocalizations(
      appController.selectedLocale,
    );

    if (isReading) {
      unawaited(
        timerNotificationService.scheduleReadingReminders(
          title: subject.name,
          body: l10n.timerReadingReminderBody,
          firstReminder: Duration(seconds: readingIntervalRemainingSeconds),
          interval: const Duration(seconds: defaultFocusIntervalSeconds),
        ),
      );
      return;
    }

    if (isHobby) {
      unawaited(
        timerNotificationService.scheduleFocusFinished(
          title: subject.name,
          body: l10n.timerHobbyFinishedBody,
          remaining: Duration(seconds: breakCountdownSeconds.value),
        ),
      );
      return;
    }

    unawaited(
      timerNotificationService.scheduleSessionTimeline(
        title: subject.name,
        focusFinishedBody: l10n.timerFocusFinishedBody,
        restFinishedBody: l10n.timerRestFinishedBody,
        sessionFinishedBody: l10n.timerSessionFinishedBody,
        focusRemaining: Duration(seconds: breakCountdownSeconds.value),
        restRemaining: Duration(seconds: restCountdownSeconds.value),
        focusInterval: Duration(seconds: focusIntervalSeconds),
        restInterval: Duration(seconds: restIntervalSeconds),
        remainingFocusSections:
            focusSessionCount - completedFocusSections.value,
        isResting: isResting.value,
      ),
    );
  }

  int get _overlayRemainingSeconds {
    if (isReading) {
      return sessionSeconds.value;
    }
    if (isResting.value) {
      return restCountdownSeconds.value;
    }
    return breakCountdownSeconds.value;
  }

  Future<void> _ensureOverlayPermission() async {
    if (_overlayPermissionRequested) {
      return;
    }
    _overlayPermissionRequested = true;
    if (await focusOverlayService.hasPermission()) {
      return;
    }
    await focusOverlayService.requestPermission();
  }

  void _showOverlay() {
    if (isSessionFinished.value) {
      return;
    }
    unawaited(
      focusOverlayService.show(
        subjectName: subject.name,
        remainingSeconds: _overlayRemainingSeconds,
        isRunning: isRunning.value,
        isResting: isResting.value,
        isCountUp: isReading,
        usesFocusRoutine: !isReading && !isHobby,
        colorValue: subject.colorValue,
        currentFocusSection: currentFocusSection,
        totalFocusSections: focusSessionCount,
        focusIntervalSeconds: focusIntervalSeconds,
        restIntervalSeconds: restIntervalSeconds,
      ),
    );
  }

  void _hideOverlay() {
    unawaited(focusOverlayService.hide());
  }

  Future<bool> _consumeLiveActivityAction() async {
    if (_isConsumingLiveActivityAction || isSessionFinished.value) {
      return _isConsumingLiveActivityAction;
    }
    _isConsumingLiveActivityAction = true;
    try {
      final TimerLiveActivityAction? value = await timerLiveActivityService
          .consumePendingAction();
      if (value == null) {
        return false;
      }

      _applyLiveActivityState(value);
      if (value.action == "finish") {
        finishSession();
        return true;
      }
      _lastTickAt = DateTime.now();
      if (!value.isRunning) {
        _persister.flush();
      }
      _updateNotification();
      return true;
    } finally {
      _isConsumingLiveActivityAction = false;
    }
  }

  void _applyLiveActivityState(TimerLiveActivityAction value) {
    if (isReading) {
      sessionSeconds.value = value.remainingSeconds.clamp(0, _maxSessionSeconds);
      isResting.value = false;
      isRunning.value = value.isRunning;
      _syncFocusGuard();
      return;
    }
    if (!value.isResting) {
      final int completedCycles = sessionSeconds.value - cycleElapsedSeconds;
      sessionSeconds.value =
          completedCycles.clamp(0, sessionSeconds.value) +
          (focusIntervalSeconds - value.remainingSeconds).clamp(
            0,
            focusIntervalSeconds,
          );
      breakCountdownSeconds.value = value.remainingSeconds;
      if (value.remainingSeconds <= 0) {
        _completeFocusSection();
        return;
      }
    } else {
      restCountdownSeconds.value = value.remainingSeconds;
      if (value.remainingSeconds <= 0) {
        _finishRestPeriod();
        return;
      }
    }
    isResting.value = value.isResting;
    isRunning.value = value.isRunning;
    _syncFocusGuard();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isAppInForeground = true;
      _clearFocusLockReturnRequest();
      _hideOverlay();
      unawaited(_resumeFromBackground());
      _syncFocusGuard();
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      final bool wasInForeground = _isAppInForeground;
      _isAppInForeground = false;
      _persister.flush();
      _recordLastActivityIfNeeded();
      _updateNotification();
      if (wasInForeground) {
        _scheduleBackgroundTimeline();
      }
      if (isFocusLockActive) {
        _requestFocusLockReturn();
      } else {
        _showOverlay();
      }
    }
  }

  void _requestFocusLockReturn() {
    final DateTime now = DateTime.now();
    if (_lastFocusLockWarningAt == null ||
        now.difference(_lastFocusLockWarningAt!) >= focusLockReturnCooldown) {
      _lastFocusLockWarningAt = now;
      warnFocusLock();
    }

    if (_isRequestingFocusLockReturn) {
      return;
    }

    _isRequestingFocusLockReturn = true;
    _focusLockReturnResetTimer?.cancel();
    _focusLockReturnResetTimer = Timer(
      focusLockReturnCooldown,
      _clearFocusLockReturnRequest,
    );
    unawaited(focusGuardService.bringAppToFront());
  }

  void _clearFocusLockReturnRequest() {
    _focusLockReturnResetTimer?.cancel();
    _focusLockReturnResetTimer = null;
    _isRequestingFocusLockReturn = false;
  }

  Future<void> _catchUpAfterBackground() async {
    _isCatchingUpAfterBackground = true;
    try {
      await _tick();
    } finally {
      _isCatchingUpAfterBackground = false;
    }
  }

  Future<void> _resumeFromBackground() async {
    await _catchUpAfterBackground();
    await timerNotificationService.cancelScheduledAlarms();
  }

  void _syncFocusGuard() {
    final bool lockActive = isFocusLockActive;
    unawaited(focusGuardService.setKeepScreenOn(lockActive));
    unawaited(focusGuardService.setImmersiveMode(lockActive));
  }

  void _disableFocusGuard() {
    unawaited(focusGuardService.setKeepScreenOn(false));
    unawaited(focusGuardService.setImmersiveMode(false));
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _focusLockReturnResetTimer?.cancel();
    _persister.flush();
    _recordLastActivityIfNeeded();
    if (_isAppInForeground) {
      timerNotificationService.cancel();
    } else {
      timerNotificationService.cancelOngoing();
    }
    _hideOverlay();
    _disableFocusGuard();
    unawaited(timerLiveActivityService.end());
    super.onClose();
  }
}
