import "dart:async";

import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/use_cases/update_subject_time_use_case.dart";
import "package:help_out/core/services/daily_progress/daily_progress_service.dart";
import "package:help_out/core/services/last_activity/last_activity_service.dart";
import "package:help_out/core/services/notifications/timer_notification_service.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

class TimerController extends GetxController {
  TimerController({
    required this._updateSubjectTimeUseCase,
    required this._lastActivityService,
    required this._dailyProgressService,
    required this._timerNotificationService,
    required this.subject,
  });

  static const int focusIntervalSeconds = 25 * 60;

  final UpdateSubjectTimeUseCase _updateSubjectTimeUseCase;
  final LastActivityService _lastActivityService;
  final DailyProgressService _dailyProgressService;
  final TimerNotificationService _timerNotificationService;

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
    _timerNotificationService.cancel();
  }

  Future<bool> confirmExitIfNeeded() async {
    if (!hasActiveSession) {
      saveProgress();
      return true;
    }

    final BuildContext context = Get.context!;
    final bool? shouldExit = await appNavigator.dialog<bool>(
      child: AlertDialog(
        title: Text(context.l10n.timerExitDialogTitle),
        content: Text(
          context.l10n.timerExitDialogContent(
            _formatMinutesForDialog(sessionSeconds.value),
            subject.name,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => appNavigator.back<bool>(result: false),
            child: Text(context.l10n.timerExitDialogCancel),
          ),
          TextButton(
            onPressed: () => appNavigator.back<bool>(result: true),
            child: Text(context.l10n.timerExitDialogConfirm),
          ),
        ],
      ),
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
    _updateSubjectTimeUseCase(
      subjectId: subject.id,
      totalSeconds: totalSeconds,
    );
    _dailyProgressService.addFocusSeconds(elapsedSinceLastPersist);
  }

  void _registerSessionIfNeeded() {
    if (!_hasLoggedTime || _hasRegisteredSession) {
      return;
    }
    _hasRegisteredSession = true;
    _lastActivityService.record(subject.name, subjectId: subject.id);
    _dailyProgressService.registerSession();
  }

  String _formatMinutesForDialog(int seconds) {
    final int minutes = (seconds / 60).ceil();
    return "${minutes}min";
  }

  void _updateNotification() {
    final BuildContext? context = Get.context;
    if (context == null) {
      return;
    }

    if (!isRunning.value) {
      _timerNotificationService.showStatic(
        title: subject.name,
        body: context.l10n.timerNotificationPaused,
      );
      return;
    }

    if (isResting.value) {
      _timerNotificationService.showStatic(
        title: subject.name,
        body: context.l10n.timerNotificationResting,
      );
      return;
    }

    _timerNotificationService.showRunning(
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
    _timerNotificationService.cancel();
    super.onClose();
  }
}
