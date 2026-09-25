import "package:get/get.dart";
import "package:timing/presentation/daily_goals/daily_goals_controller.dart";

class DailyGoalsBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<DailyGoalsController>(
      DailyGoalsController(
        appNavigator: Get.find(),
        getDailyTasksUseCase: Get.find(),
        toggleDailyTaskCheckUseCase: Get.find(),
        deleteDailyTaskUseCase: Get.find(),
        clearDailyTaskDataUseCase: Get.find(),
        lastActivityService: Get.find(),
        achievementUnlockService: Get.find(),
        activityChangeBus: Get.find(),
      ),
    );
  }
}
