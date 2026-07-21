import "dart:async";

import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/use_cases/update_subject_time_use_case.dart";
import "package:help_out/core/services/daily_progress/daily_progress_service.dart";
import "package:help_out/core/services/last_activity/last_activity_service.dart";
import "package:help_out/core/services/live_activity/timer_live_activity_service.dart";
import "package:help_out/core/services/notifications/timer_notification_service.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/timer/widgets/timer_exit_dialog.dart";

class TimerController extends GetxController with WidgetsBindingObserver {
  TimerController({
    required this.updateSubjectTimeUseCase,
    required this.lastActivityService,
    required this.dailyProgressService,
    required this.timerNotificationService,
    required this.timerLiveActivityService,
    required this.subject,
  });

  static const int focusIntervalSeconds = 25 * 60;

  final UpdateSubjectTimeUseCase updateSubjectTimeUseCase;
  final LastActivityService lastActivityService;
  final DailyProgressService dailyProgressService;
  final TimerNotificationService timerNotificationService;
  final TimerLiveActivityService timerLiveActivityService;

  SubjectEntity subject;

  final RxInt sessionSeconds = 0.obs;
  final RxInt breakCountdownSeconds = focusIntervalSeconds.obs;
  late final RxInt restCountdownSeconds = restIntervalSeconds.obs;
  final RxBool isRunning = true.obs;
  final RxBool isResting = false.obs;
  final RxBool isSessionFinished = false.obs;

  Timer? _ticker;
  int _persistedSessionSeconds = 0;
  bool _hasLoggedTime = false;
  bool _hasRegisteredSession = false;
  bool _isConsumingLiveActivityAction = false;
  late DateTime _lastTickAt;

  int get totalSeconds => subject.totalSeconds + sessionSeconds.value;

  int get cycleElapsedSeconds =>
      focusIntervalSeconds - breakCountdownSeconds.value;

  double get focusProgress =>
      (cycleElapsedSeconds / focusIntervalSeconds).clamp(0, 1).toDouble();

  bool get hasActiveSession =>
      !isSessionFinished.value && sessionSeconds.value > 0;

  int get restIntervalSeconds =>
      (subject.restMinutes > 0
          ? subject.restMinutes
          : SubjectEntity.defaultRestMinutes) *
      60;

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
      if (isResting.value) {
        if (restCountdownSeconds.value <= 0) {
          isResting.value = false;
          isRunning.value = false;
          breakCountdownSeconds.value = focusIntervalSeconds;
          _updateNotification();
          continue;
        }
        final int step = remaining.clamp(0, restCountdownSeconds.value);
        restCountdownSeconds.value -= step;
        remaining -= step;
        if (restCountdownSeconds.value <= 0) {
          isResting.value = false;
          isRunning.value = false;
          breakCountdownSeconds.value = focusIntervalSeconds;
          _updateNotification();
        }
        continue;
      }

      if (breakCountdownSeconds.value <= 0) {
        isResting.value = true;
        restCountdownSeconds.value = restIntervalSeconds;
        _persistAccumulatedTime();
        _updateNotification();
        continue;
      }
      final int step = remaining.clamp(0, breakCountdownSeconds.value);
      sessionSeconds.value += step;
      breakCountdownSeconds.value -= step;
      remaining -= step;
      if (breakCountdownSeconds.value <= 0) {
        isResting.value = true;
        restCountdownSeconds.value = restIntervalSeconds;
        _persistAccumulatedTime();
        _updateNotification();
      }
    }
  }

  void togglePause() {
    isRunning.value = !isRunning.value;
    _lastTickAt = DateTime.now();

    if (!isRunning.value) {
      _persistAccumulatedTime();
    }
    _updateNotification();
  }

  void saveProgress() => _persistAccumulatedTime();

  void skipRest() {
    if (!isResting.value) {
      return;
    }
    isResting.value = false;
    isRunning.value = true;
    restCountdownSeconds.value = restIntervalSeconds;
    breakCountdownSeconds.value = focusIntervalSeconds;
    _updateNotification();
  }

  void continueFocus() {
    isResting.value = false;
    isRunning.value = true;
    restCountdownSeconds.value = restIntervalSeconds;
    breakCountdownSeconds.value = focusIntervalSeconds;
    _updateNotification();
  }

  void updateSubjectNotes(String notes) {
    subject = subject.copyWith(notes: notes);
  }

  void finishSession() {
    _persistAccumulatedTime();
    _registerSessionIfNeeded();
    isRunning.value = false;
    isSessionFinished.value = true;
    _ticker?.cancel();
    timerNotificationService.cancel();
    unawaited(timerLiveActivityService.end());
  }

  Future<bool> confirmExitIfNeeded() async {
    if (!hasActiveSession) {
      saveProgress();
      return true;
    }

    final BuildContext context = Get.context!;
    final bool? shouldExit = await showTimerExitDialog(
      context: context,
      accentColor: Color(subject.colorValue),
      title: context.l10n.timerExitDialogTitle,
      content: context.l10n.timerExitDialogContent(
        _formatMinutesForDialog(sessionSeconds.value),
        subject.name,
      ),
      cancelLabel: context.l10n.timerExitDialogCancel,
      confirmLabel: context.l10n.timerExitDialogConfirm,
    );

    if (shouldExit == true) {
      finishSession();
    }
    return shouldExit == true;
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
    dailyProgressService.addFocusSeconds(elapsedSinceLastPersist);
  }

  void _registerSessionIfNeeded() {
    if (!_hasLoggedTime || _hasRegisteredSession) {
      return;
    }
    _hasRegisteredSession = true;
    lastActivityService.record(subject.name, subjectId: subject.id);
    dailyProgressService.registerSession();
  }

  String _formatMinutesForDialog(int seconds) {
    final int minutes = (seconds / 60).ceil();
    return "$minutes min";
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
        isResting.value = true;
        isRunning.value = true;
        restCountdownSeconds.value = restIntervalSeconds;
        return;
      }
    } else {
      restCountdownSeconds.value = value.remainingSeconds;
      if (value.remainingSeconds <= 0) {
        isResting.value = false;
        isRunning.value = false;
        breakCountdownSeconds.value = focusIntervalSeconds;
        return;
      }
    }
    isResting.value = value.isResting;
    isRunning.value = value.isRunning;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_tick());
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _persistAccumulatedTime();
    _registerSessionIfNeeded();
    timerNotificationService.cancel();
    unawaited(timerLiveActivityService.end());
    super.onClose();
  }
}
