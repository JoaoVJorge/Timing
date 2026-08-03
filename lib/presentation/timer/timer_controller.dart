import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/domain/use_cases/update_subject_pages_use_case.dart";
import "package:help_out/core/domain/use_cases/update_subject_time_use_case.dart";
import "package:help_out/core/domain/use_cases/log_activity_use_case.dart";
import "package:help_out/core/services/daily_progress/daily_progress_service.dart";
import "package:help_out/core/services/focus/focus_feedback_service.dart";
import "package:help_out/core/services/focus/focus_guard_service.dart";
import "package:help_out/core/services/last_activity/last_activity_service.dart";
import "package:help_out/core/services/live_activity/timer_live_activity_service.dart";
import "package:help_out/core/services/notifications/timer_notification_service.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/timer/widgets/timer_exit_dialog.dart";

class TimerController extends GetxController with WidgetsBindingObserver {
  TimerController({
    required this.updateSubjectTimeUseCase,
    required this.updateSubjectPagesUseCase,
    required this.logActivityUseCase,
    required this.lastActivityService,
    required this.dailyProgressService,
    required this.timerNotificationService,
    required this.timerLiveActivityService,
    required this.focusFeedbackService,
    required this.focusGuardService,
    required this.appController,
    required this.appNavigator,
    required this.subject,
  });

  static const int defaultFocusIntervalSeconds = 25 * 60;

  final UpdateSubjectTimeUseCase updateSubjectTimeUseCase;
  final UpdateSubjectPagesUseCase updateSubjectPagesUseCase;
  final LogActivityUseCase logActivityUseCase;
  final LastActivityService lastActivityService;
  final DailyProgressService dailyProgressService;
  final TimerNotificationService timerNotificationService;
  final TimerLiveActivityService timerLiveActivityService;
  final FocusFeedbackService focusFeedbackService;
  final FocusGuardService focusGuardService;
  final AppController appController;
  final AppNavigator appNavigator;

  SubjectEntity subject;

  final RxInt sessionSeconds = 0.obs;
  late final RxInt breakCountdownSeconds = focusIntervalSeconds.obs;
  late final RxInt restCountdownSeconds = restIntervalSeconds.obs;
  final RxBool isRunning = true.obs;
  final RxBool isResting = false.obs;
  final RxBool isSessionFinished = false.obs;
  final RxInt completedFocusSections = 0.obs;

  Timer? _ticker;
  int _persistedSessionSeconds = 0;
  bool _hasLoggedTime = false;
  bool _hasRecordedLastActivity = false;
  bool _isConsumingLiveActivityAction = false;
  late DateTime _lastTickAt;

  int get totalSeconds => subject.totalSeconds + sessionSeconds.value;

  bool get isReading => subject.category == TimeCategoryType.reading;

  int get focusIntervalSeconds => subject.goalSeconds > 0
      ? subject.goalSeconds
      : defaultFocusIntervalSeconds;

  int get cycleElapsedSeconds =>
      focusIntervalSeconds - breakCountdownSeconds.value;

  double get focusProgress =>
      (cycleElapsedSeconds / focusIntervalSeconds).clamp(0, 1).toDouble();

  bool get hasActiveSession =>
      !isSessionFinished.value && sessionSeconds.value > 0;

  bool get isFocusLockActive =>
      appController.isFocusLockEnabledFor(subject.category) &&
      isRunning.value &&
      !isResting.value &&
      !isSessionFinished.value;

  int get restIntervalSeconds =>
      (subject.restMinutes > 0
          ? subject.restMinutes
          : SubjectEntity.defaultRestMinutes) *
      60;

  int get focusSessionCount =>
      subject.focusSessionCount > 0 ? subject.focusSessionCount : 1;

  int get currentFocusSection =>
      (completedFocusSections.value + 1).clamp(1, focusSessionCount);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _lastTickAt = DateTime.now();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => unawaited(_tick()),
    );
    _updateNotification();
    _syncFocusGuard();
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
  }

  void _advanceBy(int seconds) {
    int remaining = seconds;
    while (remaining > 0 && isRunning.value) {
      if (isReading) {
        sessionSeconds.value += remaining;
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
    _persistAccumulatedTime();
    completedFocusSections.value = (completedFocusSections.value + 1).clamp(
      0,
      focusSessionCount,
    );
    unawaited(dailyProgressService.registerSession());
    unawaited(focusFeedbackService.playFocusFinishedFeedback());

    if (completedFocusSections.value >= focusSessionCount) {
      finishSession();
      return;
    }

    isResting.value = true;
    restCountdownSeconds.value = restIntervalSeconds;
    _updateNotification();
    _syncFocusGuard();
  }

  void _finishRestPeriod() {
    isResting.value = false;
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
      _persistAccumulatedTime();
    }
    _updateNotification();
    _syncFocusGuard();
  }

  void saveProgress() => _persistAccumulatedTime();

  void skipRest() {
    if (!isResting.value || isReading) {
      return;
    }
    restCountdownSeconds.value = restIntervalSeconds;
    _finishRestPeriod();
  }

  void continueFocus() {
    isResting.value = false;
    isRunning.value = true;
    restCountdownSeconds.value = restIntervalSeconds;
    breakCountdownSeconds.value = focusIntervalSeconds;
    _updateNotification();
    _syncFocusGuard();
  }

  void updateSubjectNotes(String notes) {
    subject = subject.copyWith(notes: notes);
  }

  void finishSession() {
    _persistAccumulatedTime();
    _recordLastActivityIfNeeded();
    isRunning.value = false;
    isSessionFinished.value = true;
    _ticker?.cancel();
    unawaited(HapticFeedback.mediumImpact());
    timerNotificationService.cancel();
    _syncFocusGuard();
    unawaited(timerLiveActivityService.end());
  }

  void warnFocusLock() {
    unawaited(focusFeedbackService.warnFocusLock());
    appNavigator.showSnackBar(
      text: "Modo concentração ativo. Termine ou pause o foco para sair.",
      isAnError: true,
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
        accentColor: Color(subject.colorValue),
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
      accentColor: Color(subject.colorValue),
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
    if (!isReading) {
      finishSession();
      return true;
    }

    final BuildContext context = Get.context!;
    final int? pagesRead = await showReadingExitDialog(
      context: context,
      accentColor: Color(subject.colorValue),
      title: context.l10n.timerExitDialogTitle,
      content: _readingExitContent(context),
      cancelLabel: context.l10n.timerExitBackToFocus,
      confirmLabel: context.l10n.timerExitSaveAndEnd,
    );

    if (pagesRead == null) {
      return false;
    }
    finishReadingSession(pagesRead);
    return true;
  }

  void finishReadingSession(int pagesRead) {
    final int sanitizedPages = pagesRead < 0 ? 0 : pagesRead;
    _persistAccumulatedTime();
    if (sanitizedPages > 0) {
      final int nextPages = subject.currentPages + sanitizedPages;
      subject = subject.copyWith(currentPages: nextPages);
      updateSubjectPagesUseCase(subjectId: subject.id, currentPages: nextPages);
      dailyProgressService.addPages(sanitizedPages);
      unawaited(
        logActivityUseCase(
          category: subject.category,
          subjectId: subject.id,
          subjectName: subject.name,
          pages: sanitizedPages,
        ),
      );
    }
    _recordLastActivityIfNeeded();
    isRunning.value = false;
    isSessionFinished.value = true;
    _ticker?.cancel();
    timerNotificationService.cancel();
    _syncFocusGuard();
    unawaited(timerLiveActivityService.end());
  }

  void _persistAccumulatedTime() {
    final int elapsedSinceLastPersist =
        sessionSeconds.value - _persistedSessionSeconds;
    if (elapsedSinceLastPersist <= 0) {
      return;
    }

    if (elapsedSinceLastPersist > 0) {
      _hasLoggedTime = true;
    }
    _persistedSessionSeconds = sessionSeconds.value;
    updateSubjectTimeUseCase(subjectId: subject.id, totalSeconds: totalSeconds);
    unawaited(
      logActivityUseCase(
        category: subject.category,
        subjectId: subject.id,
        subjectName: subject.name,
        seconds: elapsedSinceLastPersist,
      ),
    );
    if (!isReading) {
      dailyProgressService.addFocusSeconds(elapsedSinceLastPersist);
    }
  }

  void _recordLastActivityIfNeeded() {
    if (!_hasLoggedTime || _hasRecordedLastActivity) {
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
    return switch (context.languageCode) {
      "es" =>
        "Leíste durante $duration. Informa cuántas páginas leíste en ${subject.name}.",
      "pt" =>
        "Você leu por $duration. Informe quantas páginas foram lidas em ${subject.name}.",
      _ =>
        "You read for $duration. Enter how many pages you read in ${subject.name}.",
    };
  }

  void _updateNotification() {
    unawaited(
      timerLiveActivityService.startOrUpdate(
        subjectName: subject.name,
        colorValue: subject.colorValue,
        remainingSeconds: isResting.value
            ? restCountdownSeconds.value
            : breakCountdownSeconds.value,
        isRunning: isRunning.value,
        isResting: isResting.value,
      ),
    );

    final BuildContext? context = Get.context;
    if (context == null) {
      return;
    }

    if (!isRunning.value) {
      timerNotificationService.showStatic(
        title: subject.name,
        body: context.l10n.timerNotificationPaused,
      );
      return;
    }

    if (isResting.value) {
      timerNotificationService.showStatic(
        title: subject.name,
        body: context.l10n.timerNotificationResting,
      );
      return;
    }

    timerNotificationService.showRunning(
      title: subject.name,
      body: context.l10n.timerNotificationRunning,
      startedAt: DateTime.now().subtract(
        Duration(seconds: sessionSeconds.value),
      ),
    );
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
        _persistAccumulatedTime();
      }
      _updateNotification();
      return true;
    } finally {
      _isConsumingLiveActivityAction = false;
    }
  }

  void _applyLiveActivityState(TimerLiveActivityAction value) {
    if (isReading) {
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
      unawaited(_tick());
      if (isFocusLockActive) {
        warnFocusLock();
      }
      _syncFocusGuard();
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      if (isFocusLockActive) {
        unawaited(focusFeedbackService.warnFocusLock());
        unawaited(focusGuardService.bringAppToFront());
      }
    }
  }

  void _syncFocusGuard() {
    unawaited(focusGuardService.setKeepScreenOn(isFocusLockActive));
  }

  void _disableFocusGuard() {
    unawaited(focusGuardService.setKeepScreenOn(false));
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _persistAccumulatedTime();
    _recordLastActivityIfNeeded();
    timerNotificationService.cancel();
    _disableFocusGuard();
    unawaited(timerLiveActivityService.end());
    super.onClose();
  }
}
