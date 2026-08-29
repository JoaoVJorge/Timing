import "package:get/get.dart";
import "package:timing/presentation/progress/progress_controller.dart";

class ProgressBindings extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<ProgressController>()) return;

    Get.put<ProgressController>(
      ProgressController(
        getProfileStatsUseCase: Get.find(),
        getDailyTasksUseCase: Get.find(),
        getSubjectsUseCase: Get.find(),
        dailyProgressService: Get.find(),
        activityHistoryService: Get.find(),
        appNavigator: Get.find(),
      ),
      permanent: true,
    );
  }
}
