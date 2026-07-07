import "dart:async";

import "package:flutter/widgets.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/use_cases/update_subject_time_use_case.dart";
import "package:help_out/core/services/last_activity/last_activity_service.dart";
import "package:help_out/core/services/notifications/timer_notification_service.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

class TimerController extends GetxController {
  TimerController({
    required this._updateSubjectTimeUseCase,
    required this._lastActivityService,
    required this._timerNotificationService,
    required this.subject,
  });

  static const int _focusIntervalSeconds = 25 * 60;

  final UpdateSubjectTimeUseCase _updateSubjectTimeUseCase;
  final LastActivityService _lastActivityService;
  final TimerNotificationService _timerNotificationService;

  final SubjectEntity subject;

  late int _baselineSeconds = subject.totalSeconds;
  final RxInt sessionSeconds = 0.obs;
  final RxInt breakCountdownSeconds = _focusIntervalSeconds.obs;
  late final RxInt restCountdownSeconds = restIntervalSeconds.obs;
  final RxBool isRunning = true.obs;
  final RxBool isResting = false.obs;

  Timer? _ticker;
  bool _hasLoggedTime = false;

  int get totalSeconds => _baselineSeconds + sessionSeconds.value;

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
        breakCountdownSeconds.value = _focusIntervalSeconds;
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

  void _persistAccumulatedTime() {
    if (sessionSeconds.value > 0) {
      _hasLoggedTime = true;
    }
    _baselineSeconds += sessionSeconds.value;
    sessionSeconds.value = 0;
    _updateSubjectTimeUseCase(
      subjectId: subject.id,
      totalSeconds: _baselineSeconds,
    );
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
    if (_hasLoggedTime) {
      _lastActivityService.record(subject.name);
    }
    _timerNotificationService.cancel();
    super.onClose();
  }
}
