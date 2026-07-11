import "package:get/get.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/presentation/timer/timer_controller.dart";

class TimerBindings extends Bindings {
  @override
  void dependencies() {
    final SubjectEntity subject = Get.arguments as SubjectEntity;

    Get.put<TimerController>(
      TimerController(
        updateSubjectTimeUseCase: Get.find(),
        lastActivityService: Get.find(),
        dailyProgressService: Get.find(),
        timerNotificationService: Get.find(),
        timerLiveActivityService: Get.find(),
        subject: subject,
      ),
    );
  }
}
