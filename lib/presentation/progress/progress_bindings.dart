import "package:get/get.dart";
import "package:timing/presentation/progress/progress_controller.dart";

class ProgressBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<ProgressController>(
      ProgressController(
        getProfileStatsUseCase: Get.find(),
        getDailyTasksUseCase: Get.find(),
        dailyProgressService: Get.find(),
        appNavigator: Get.find(),
      ),
    );
  }
}
