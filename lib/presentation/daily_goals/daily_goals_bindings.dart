import "package:get/get.dart";
import "package:help_out/presentation/daily_goals/daily_goals_controller.dart";

class DailyGoalsBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<DailyGoalsController>(
      DailyGoalsController(
        appNavigator: Get.find(),
        getDailyTasksUseCase: Get.find(),
        toggleDailyTaskCheckUseCase: Get.find(),
        deleteDailyTaskUseCase: Get.find(),
        lastActivityService: Get.find(),
      ),
    );
  }
}
