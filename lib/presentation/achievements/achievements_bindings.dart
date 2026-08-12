import "package:get/get.dart";
import "package:timing/presentation/achievements/achievements_controller.dart";

class AchievementsBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AchievementsController>(
      AchievementsController(
        getProfileStatsUseCase: Get.find(),
        getDailyTasksUseCase: Get.find(),
        dailyProgressService: Get.find(),
        appNavigator: Get.find(),
      ),
    );
  }
}
