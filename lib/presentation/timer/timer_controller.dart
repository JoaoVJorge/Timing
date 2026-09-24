import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/active_timer_session_entity.dart";
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
import "package:timing/core/services/foreground/timer_foreground_service.dart";
import "package:timing/core/services/last_activity/last_activity_service.dart";
import "package:timing/core/services/live_activity/timer_live_activity_service.dart";
import "package:timing/core/services/notifications/timer_notification_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/core/services/timer/active_timer_session_service.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/core/utils/serial_task_queue.dart";
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
    required this.activeTimerSessionService,
    required this.focusFeedbackService,
    required this.focusGuardService,
    required this.timerForegroundService,
    required this.analyticsService,
    required this.activityChangeBus,
    required this.appController,
    required this.appNavigator,
    required this.subject,
    this.restoredSession,
  }) : _todayFocusSecondsAtSessionStart =
           restoredSession?.todayFocusSecondsAtSessionStart ??
           subjectDailyHistoryService.todayForSubject(subject.id).focusSeconds;

  static const int defaultFocusIntervalSeconds = 30 * 60;
  static const Duration autoSaveInterval = Duration(seconds: 10);
  static const Duration maxTrustedRecoveryGap = Duration(hours: 4);
  static const Duration maxStaleCheckpointCatchUp = Duration(hours: 1);

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
  final ActiveTimerSessionService activeTimerSessionService;
  final FocusFeedbackService focusFeedbackService;
  final FocusGuardService focusGuardService;
  final TimerForegroundService timerForegroundService;
  final AnalyticsService analyticsService;
  final ActivityChangeBus activityChangeBus;
  final AppController appController;
  final AppNavigator appNavigator;

  SubjectEntity subject;
  final ActiveTimerSessionEntity? restoredSession;

  late final RxInt sessionSeconds = (restoredSession?.sessionSeconds ?? 0).obs;
  late final RxInt breakCountdownSeconds =
      (restoredSession?.breakCountdownSeconds ?? _initialBreakCountdownSeconds)
          .obs;
  late final RxInt restCountdownSeconds =
      (restoredSession?.restCountdownSeconds ?? restIntervalSeconds).obs;
  late final RxBool isRunning = (restoredSession?.isRunning ?? true).obs;
  late final RxBool isResting = (restoredSession?.isResting ?? false).obs;
  final RxBool isSessionFinished = false.obs;
  final Rx<FocusProtectionStatus> focusProtectionStatus =
      FocusProtectionStatus.unavailable.obs;
  late final RxInt completedFocusSections =
      (restoredSession?.completedFocusSections ?? 0).obs;

  Timer? _ticker;
  bool _hasRecordedLastActivity = false;
  bool _isConsumingLiveActivityAction = false;
  bool _isFinishingSession = false;
  bool _isAppInForeground = true;
  bool _isCatchingUpAfterBackground = false;
  bool _focusGuardDisposed = false;
  bool _hasRequestedScreenPinning = false;
  bool _isReady = false;
  int _focusActivationGeneration = 0;
  final SerialTaskQueue _focusGuardQueue = SerialTaskQueue();
  final int _todayFocusSecondsAtSessionStart;
  DateTime? _lastSessionCheckpointAt;
  ActiveTimerSessionEntity? _lastQueuedSessionCheckpoint;
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
    initialPersistedSeconds: restoredSession?.persistedSeconds ?? 0,
    initialHasLoggedTime: (restoredSession?.persistedSeconds ?? 0) > 0,
    onPersisted: () => unawaited(_saveActiveSession()),
  );

  int get totalSeconds => subject.totalSeconds + sessionSeconds.value;

  int get currentActivitySeconds =>
      _todayFocusSecondsAtSessionStart + sessionSeconds.value;

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

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    final DateTime now = DateTime.now();
    _lastTickAt = now;
    _restoreElapsedSinceCheckpoint(now);
    if (_isDailyHobbyGoalAlreadyComplete) {
      completedFocusSections.value = focusSessionCount;
    }
    if (!isSessionFinished.value) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_isAppInForeground && isFocusLockActive) {
          unawaited(refreshFocusProtection());
        }
        unawaited(_tick());
      });
      unawaited(_saveActiveSession(capturedAt: now));
    }
    unawaited(_ensureTimerNotifications());
    _syncFocusGuard();
    analyticsService.track(
      AnalyticsEvent.focusSessionStarted(category: subject.category),
    );
  }

  @override
  void onReady() {
    super.onReady();
    _isReady = true;
    _requestScreenPinningIfNeeded();
  }

  Future<void> _tick() async {
    final bool consumedAction = await _consumeLiveActivityAction();
    if (consumedAction || isSessionFinished.value) {
      return;
    }
    if (await _consumeAndroidToggleAction()) {
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
    if (_lastSessionCheckpointAt == null ||
        now.difference(_lastSessionCheckpointAt!) >= autoSaveInterval) {
      unawaited(_saveActiveSession(capturedAt: now));
    }
  }

  void _restoreElapsedSinceCheckpoint(DateTime now) {
    final ActiveTimerSessionEntity? checkpoint = restoredSession;
    if (checkpoint == null || !checkpoint.isRunning) {
      return;
    }
    final Duration elapsed = now.difference(checkpoint.capturedAt);
    final bool isStale = elapsed > maxTrustedRecoveryGap;
    final int elapsedSeconds = (isStale
        ? elapsed.inSeconds.clamp(
            0,
            <int>[
              focusIntervalSeconds,
              maxStaleCheckpointCatchUp.inSeconds,
            ].reduce((a, b) => a < b ? a : b),
          )
        : elapsed.inSeconds.clamp(0, _maxSessionSeconds));
    if (elapsedSeconds <= 0) {
      return;
    }
    _isCatchingUpAfterBackground = true;
    try {
      _advanceBy(elapsedSeconds);
    } finally {
      _isCatchingUpAfterBackground = false;
    }
    if (isStale) {
      isRunning.value = false;
    }
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

      if (isHobby) {
        final int previousRemaining = breakCountdownSeconds.value;
        sessionSeconds.value += remaining;
        breakCountdownSeconds.value = (previousRemaining - remaining).clamp(
          0,
          focusIntervalSeconds,
        );
        // Reaching the goal is a milestone, not the end of a hobby session.
        if (previousRemaining > 0 && breakCountdownSeconds.value == 0) {
          _completeFocusSection();
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
      return;
    }

    // A focus interval is a milestone, not a mandatory stop. Keep the timer
    // running and start the next interval immediately after the alarm.
    isResting.value = false;
    restCountdownSeconds.value = restIntervalSeconds;
    breakCountdownSeconds.value = focusIntervalSeconds;
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
    unawaited(activeTimerSessionService.clear());
    _ticker?.cancel();
    unawaited(HapticFeedback.mediumImpact());
    if (_isAppInForeground) {
      timerNotificationService.cancel();
    } else {
      // Keep the already scheduled final alarm alive. It is the only reliable
      // sound/vibration source when Flutter is suspended in the background.
      timerNotificationService.cancelOngoing();
    }
    unawaited(timerForegroundService.stop());
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
      final Future<void> pagesSaved = updateSubjectPagesUseCase(
        subjectId: subject.id,
        currentPages: nextPages,
      ).then((_) => achievementUnlockService.checkForNewUnlocks());
      unawaited(pagesSaved);
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
      final Future<void> pagesLogged = logActivityUseCase(
        category: subject.category,
        subjectId: subject.id,
        subjectName: subject.name,
        pages: sanitizedPages,
      );
      // The group's progress reads the subject's saved page count while its
      // ranking reads the logged entry, so refresh only once both reached the
      // backend instead of right after the entry.
      unawaited(
        Future.wait<void>([
          pagesSaved,
          pagesLogged,
        ]).then((_) => _notifyGroupActivityChanged()),
      );
    }
    _recordLastActivityIfNeeded();
    final bool alreadyFinished = isSessionFinished.value;
    isRunning.value = false;
    isSessionFinished.value = true;
    unawaited(activeTimerSessionService.clear());
    _ticker?.cancel();
    if (_isAppInForeground) {
      timerNotificationService.cancel();
    } else {
      timerNotificationService.cancelOngoing();
    }
    unawaited(timerForegroundService.stop());
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

  // Reading has no fixed target ("keeps counting up without sections or an
  // end"), so there is no meaningful total to show for it.
  int get _notificationTotalSeconds =>
      isReading ? 0 : focusIntervalSeconds * focusSessionCount;

  void _updateNotification() {
    unawaited(_saveActiveSession());
    unawaited(
      timerLiveActivityService.startOrUpdate(
        subjectName: subject.name,
        colorValue: subject.colorValue,
        elapsedSeconds: _displayElapsedSeconds,
        isRunning: isRunning.value,
        isResting: isResting.value,
        isReading: isReading,
      ),
    );

    if (!appController.notificationsEnabled.value) {
      timerNotificationService.cancel();
      unawaited(timerForegroundService.stop());
      return;
    }

    final AppLocalizations l10n = lookupAppLocalizations(
      appController.selectedLocale,
    );
    final String notificationIconName = subject.iconName.isEmpty
        ? subject.category.iconName
        : subject.iconName;

    if (!isRunning.value) {
      timerNotificationService.cancelScheduledAlarms();
      unawaited(
        timerForegroundService.start(
          title: subject.name,
          actionLabel: l10n.timerNotificationResumeAction,
          isRunning: false,
          isTicking: false,
          ticksWhenRunning: !isResting.value,
          elapsedSeconds: _displayElapsedSeconds,
          totalSeconds: _notificationTotalSeconds,
          currentSection: currentFocusSection,
          totalSections: focusSessionCount,
          colorValue: subject.colorValue,
          iconName: notificationIconName,
        ),
      );
      return;
    }

    if (isResting.value) {
      unawaited(
        timerForegroundService.start(
          title: subject.name,
          actionLabel: l10n.timerNotificationPauseAction,
          isRunning: true,
          isTicking: false,
          ticksWhenRunning: false,
          elapsedSeconds: _displayElapsedSeconds,
          totalSeconds: _notificationTotalSeconds,
          currentSection: currentFocusSection,
          totalSections: focusSessionCount,
          colorValue: subject.colorValue,
          iconName: notificationIconName,
        ),
      );
      return;
    }

    timerNotificationService.cancelRestFinished();
    unawaited(
      timerForegroundService.start(
        title: subject.name,
        actionLabel: l10n.timerNotificationPauseAction,
        isRunning: true,
        isTicking: true,
        ticksWhenRunning: true,
        elapsedSeconds: _displayElapsedSeconds,
        totalSeconds: _notificationTotalSeconds,
        currentSection: currentFocusSection,
        totalSections: focusSessionCount,
        colorValue: subject.colorValue,
        iconName: notificationIconName,
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

    if (!isHobby) {
      unawaited(
        timerNotificationService.scheduleIntervalReminders(
          title: subject.name,
          body: isReading
              ? l10n.timerReadingReminderBody
              : l10n.timerFocusFinishedBody,
          firstReminder: Duration(
            seconds: isReading
                ? readingIntervalRemainingSeconds
                : breakCountdownSeconds.value,
          ),
          interval: Duration(
            seconds: isReading
                ? defaultFocusIntervalSeconds
                : focusIntervalSeconds,
          ),
        ),
      );
      return;
    }

    if (breakCountdownSeconds.value <= 0) {
      return;
    }
    unawaited(
      timerNotificationService.scheduleFocusFinished(
        title: subject.name,
        body: l10n.timerHobbyFinishedBody,
        remaining: Duration(seconds: breakCountdownSeconds.value),
      ),
    );
  }

  int get _displayElapsedSeconds {
    if (isResting.value) {
      return (restIntervalSeconds - restCountdownSeconds.value).clamp(
        0,
        restIntervalSeconds,
      );
    }
    if (_isDailyHobbyGoal) {
      return currentActivitySeconds;
    }
    return sessionSeconds.value;
  }

  Future<void> _saveActiveSession({DateTime? capturedAt}) async {
    if (isSessionFinished.value) {
      _lastQueuedSessionCheckpoint = null;
      await activeTimerSessionService.clear();
      return;
    }
    final DateTime checkpointAt = capturedAt ?? DateTime.now();
    _lastSessionCheckpointAt = checkpointAt;
    final ActiveTimerSessionEntity checkpoint = ActiveTimerSessionEntity(
      subject: subject,
      sessionSeconds: sessionSeconds.value,
      breakCountdownSeconds: breakCountdownSeconds.value,
      restCountdownSeconds: restCountdownSeconds.value,
      isRunning: isRunning.value,
      isResting: isResting.value,
      completedFocusSections: completedFocusSections.value,
      persistedSeconds: _persister.persistedSeconds,
      todayFocusSecondsAtSessionStart: _todayFocusSecondsAtSessionStart,
      capturedAt: checkpointAt,
    );
    if (_hasSameCheckpointState(_lastQueuedSessionCheckpoint, checkpoint)) {
      return;
    }
    _lastQueuedSessionCheckpoint = checkpoint;
    await activeTimerSessionService.save(checkpoint);
  }

  bool _hasSameCheckpointState(
    ActiveTimerSessionEntity? previous,
    ActiveTimerSessionEntity current,
  ) =>
      previous != null &&
      previous.subject == current.subject &&
      previous.sessionSeconds == current.sessionSeconds &&
      previous.breakCountdownSeconds == current.breakCountdownSeconds &&
      previous.restCountdownSeconds == current.restCountdownSeconds &&
      previous.isRunning == current.isRunning &&
      previous.isResting == current.isResting &&
      previous.completedFocusSections == current.completedFocusSections &&
      previous.persistedSeconds == current.persistedSeconds &&
      previous.todayFocusSecondsAtSessionStart ==
          current.todayFocusSecondsAtSessionStart;

  /// Consumes a pause/resume tap from the ongoing notification's lock screen
  /// mini player or the tray notification, if any.
  Future<bool> _consumeAndroidToggleAction() async {
    if (isSessionFinished.value) {
      return false;
    }
    final bool foregroundServiceRequested = await timerForegroundService
        .consumePendingToggleRequest();
    if (!foregroundServiceRequested) {
      return false;
    }
    togglePause();
    return true;
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
    if (isHobby) {
      final int elapsedSeconds =
          value.elapsedSeconds.clamp(0, _maxSessionSeconds) -
          _displayElapsedSeconds;
      isRunning.value = true;
      _advanceBy(elapsedSeconds);
      isResting.value = false;
      isRunning.value = value.isRunning;
      _syncFocusGuard();
      return;
    }
    if (isReading) {
      sessionSeconds.value = value.elapsedSeconds.clamp(0, _maxSessionSeconds);
      isResting.value = false;
      isRunning.value = value.isRunning;
      _syncFocusGuard();
      return;
    }
    if (!value.isResting) {
      final int elapsedSeconds =
          value.elapsedSeconds.clamp(0, _maxSessionSeconds) -
          sessionSeconds.value;
      isResting.value = false;
      isRunning.value = true;
      _advanceBy(elapsedSeconds);
    } else {
      restCountdownSeconds.value =
          (restIntervalSeconds -
                  value.elapsedSeconds.clamp(0, restIntervalSeconds))
              .clamp(0, restIntervalSeconds);
      if (restCountdownSeconds.value <= 0) {
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
    }
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
    // Every transition (pause/resume, rest/focus, foreground/background,
    // disposal) starts a new activation epoch. A screen-pinning request
    // captures the epoch it started in and, once the native round trip
    // completes, checks whether that epoch is still current instead of
    // re-reading individual flags — one comparison instead of re-deriving
    // "did anything relevant change" from scratch after every await.
    _focusActivationGeneration++;
    if (!_focusGuardDisposed && isFocusLockActive) {
      _requestScreenPinningIfNeeded();
    } else {
      // Reset so the next time focus lock activates (a new focus interval,
      // a resume from pause, returning to the foreground) it is requested
      // again instead of staying silently unpinned for the rest of the
      // session.
      _hasRequestedScreenPinning = false;
    }
    unawaited(
      _focusGuardQueue.run(() async {
        final bool active = !_focusGuardDisposed && isFocusLockActive;
        await focusGuardService.setKeepScreenOn(active);
        focusProtectionStatus.value = active
            ? await focusGuardService.getProtectionStatus()
            : await focusGuardService.stopScreenPinning();
        await focusGuardService.setImmersiveMode(
          active && focusProtectionStatus.value == FocusProtectionStatus.pinned,
        );
      }),
    );
  }

  void _requestScreenPinningIfNeeded() {
    if (!_isReady || _hasRequestedScreenPinning || !isFocusLockActive) {
      return;
    }
    _hasRequestedScreenPinning = true;
    unawaited(requestScreenPinning());
  }

  void _disableFocusGuard() {
    _focusGuardDisposed = true;
    _syncFocusGuard();
  }

  Future<void> refreshFocusProtection() => _focusGuardQueue.run(() async {
    if (_focusGuardDisposed) {
      return;
    }
    focusProtectionStatus.value = await focusGuardService.getProtectionStatus();
    await focusGuardService.setImmersiveMode(
      isFocusLockActive &&
          focusProtectionStatus.value == FocusProtectionStatus.pinned,
    );
  });

  Future<void> requestScreenPinning() {
    if (_focusGuardDisposed || !isFocusLockActive) {
      return Future<void>.value();
    }
    final int requestedGeneration = _focusActivationGeneration;
    return _focusGuardQueue.run(() async {
      if (_focusGuardDisposed ||
          _focusActivationGeneration != requestedGeneration ||
          !_isAppInForeground) {
        return;
      }
      focusProtectionStatus.value = await focusGuardService
          .requestScreenPinning();
      // The native confirmation can complete after this activation ended
      // (session paused, rest started, app backgrounded, ...).
      if (_focusGuardDisposed ||
          _focusActivationGeneration != requestedGeneration) {
        focusProtectionStatus.value = await focusGuardService
            .stopScreenPinning();
      }
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _persister.flush();
    if (!isSessionFinished.value) {
      if (_isAppInForeground && sessionSeconds.value == 0) {
        _lastQueuedSessionCheckpoint = null;
        unawaited(activeTimerSessionService.clear());
      } else {
        unawaited(_saveActiveSession());
      }
    }
    _recordLastActivityIfNeeded();
    if (_isAppInForeground) {
      timerNotificationService.cancel();
    } else {
      timerNotificationService.cancelOngoing();
    }
    unawaited(timerForegroundService.stop());
    _disableFocusGuard();
    unawaited(timerLiveActivityService.end());
    super.onClose();
  }
}
