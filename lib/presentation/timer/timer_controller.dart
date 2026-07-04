import "dart:async";

import "package:get/get.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/use_cases/update_subject_time_use_case.dart";

class TimerController extends GetxController {
  TimerController({
    required this._updateSubjectTimeUseCase,
    required this.subject,
  });

  static const int _breakIntervalSeconds = 25 * 60;

  final UpdateSubjectTimeUseCase _updateSubjectTimeUseCase;

  final SubjectEntity subject;

  late int _baselineSeconds = subject.totalSeconds;
  final RxInt sessionSeconds = 0.obs;
  final RxInt breakCountdownSeconds = _breakIntervalSeconds.obs;
  final RxBool isRunning = true.obs;

  Timer? _ticker;

  int get totalSeconds => _baselineSeconds + sessionSeconds.value;

  @override
  void onInit() {
    super.onInit();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) => _tick());
  }

  void _tick() {
    if (!isRunning.value) {
      return;
    }

    sessionSeconds.value++;
    breakCountdownSeconds.value--;

    if (breakCountdownSeconds.value <= 0) {
      breakCountdownSeconds.value = _breakIntervalSeconds;
    }
  }

  void togglePause() {
    isRunning.value = !isRunning.value;

    if (!isRunning.value) {
      _persistAccumulatedTime();
    }
  }

  void saveProgress() => _persistAccumulatedTime();

  void _persistAccumulatedTime() {
    _baselineSeconds += sessionSeconds.value;
    sessionSeconds.value = 0;
    _updateSubjectTimeUseCase(
      subjectId: subject.id,
      totalSeconds: _baselineSeconds,
    );
  }

  @override
  void onClose() {
    _ticker?.cancel();
    _persistAccumulatedTime();
    super.onClose();
  }
}
