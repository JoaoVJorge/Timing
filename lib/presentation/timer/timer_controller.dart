import "dart:async";

import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/use_cases/update_subject_time_use_case.dart";
import "package:help_out/core/services/daily_progress/daily_progress_service.dart";
import "package:help_out/core/services/last_activity/last_activity_service.dart";
import "package:help_out/core/services/notifications/timer_notification_service.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/timer/widgets/timer_exit_dialog.dart";

class TimerController extends GetxController {
  TimerController({
    required this.updateSubjectTimeUseCase,
    required this.lastActivityService,
    required this.dailyProgressService,
    required this.timerNotificationService,
    required this.subject,
  });

  static const int focusIntervalSeconds = 25 * 60;

  final UpdateSubjectTimeUseCase updateSubjectTimeUseCase;
  final LastActivityService lastActivityService;
  final DailyProgressService dailyProgressService;
  final TimerNotificationService timerNotificationService;

  final SubjectEntity subject;

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
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) => _tick());
    _updateNotification();
  }

  void _tick() {
    if (!isRunning.value) {
      return;
    }

    if (isResting.value) {
      restCountdownSeconds.value--;
      if (restCountdownSeconds.value <= 0) {
        isResting.value = false;
        isRunning.value = false;
        breakCountdownSeconds.value = focusIntervalSeconds;
        _updateNotification();
      }
      return;
    }

    sessionSeconds.value++;
    breakCountdownSeconds.value--;

    if (breakCountdownSeconds.value <= 0) {
      isResting.value = true;
      restCountdownSeconds.value = restIntervalSeconds;
      _persistAccumulatedTime();
      _updateNotification();
    }
  }

  void togglePause() {
    isRunning.value = !isRunning.value;

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

  void finishSession() {
    _persistAccumulatedTime();
    _registerSessionIfNeeded();
    isRunning.value = false;
    isSessionFinished.value = true;
    _ticker?.cancel();
    timerNotificationService.cancel();
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

  @override
  void onClose() {
    _ticker?.cancel();
    _persistAccumulatedTime();
    _registerSessionIfNeeded();
    timerNotificationService.cancel();
    super.onClose();
  }
}
