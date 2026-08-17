import "package:get/get.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/app/route_arguments.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/presentation/timer/timer_controller.dart";

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
        activityHistoryService: Get.find(),
        dailyProgressService: Get.find(),
        subjectDailyHistoryService: Get.find(),
        achievementUnlockService: Get.find(),
        timerNotificationService: Get.find(),
        timerLiveActivityService: Get.find(),
        focusFeedbackService: Get.find(),
        focusGuardService: Get.find(),
        analyticsService: Get.find(),
        appController: Get.find(),
        appNavigator: Get.find(),
        subject: subject,
      ),
    );
  }
}
