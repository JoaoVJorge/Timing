import "package:get/get.dart";
import "package:timing/presentation/home/home_controller.dart";

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<HomeController>()) return;

    Get.put<HomeController>(
      HomeController(
        appController: Get.find(),
        appNavigator: Get.find(),
        lastActivityService: Get.find(),
        dailyProgressService: Get.find(),
        subjectDailyHistoryService: Get.find(),
        getSubjectsUseCase: Get.find(),
        getDailyTasksUseCase: Get.find(),
        scheduleController: Get.find(),
        achievementUnlockService: Get.find(),
        homeWidgetService: Get.find(),
        mainTabRefreshService: Get.find(),
      ),
      permanent: true,
    );
  }
}
