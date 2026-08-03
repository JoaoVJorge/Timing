import "package:get/get.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/app/route_arguments.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/presentation/timer/timer_controller.dart";

class TimerBindings extends Bindings {
  @override
  void dependencies() {
    final SubjectEntity subject = RouteArguments.of<SubjectEntity>(
      AppRoutes.timer,
    );

    Get.put<TimerController>(
      TimerController(
        updateSubjectTimeUseCase: Get.find(),
        updateSubjectPagesUseCase: Get.find(),
        logActivityUseCase: Get.find(),
        lastActivityService: Get.find(),
        dailyProgressService: Get.find(),
        timerNotificationService: Get.find(),
        timerLiveActivityService: Get.find(),
        focusFeedbackService: Get.find(),
        focusGuardService: Get.find(),
        appController: Get.find(),
        appNavigator: Get.find(),
        subject: subject,
      ),
    );
  }
}
