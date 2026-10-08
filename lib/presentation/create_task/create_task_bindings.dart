import "package:get/get.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/route_arguments.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/presentation/create_task/create_task_controller.dart";

class CreateTaskBindings extends Bindings {
  @override
  void dependencies() {
    final DailyTaskEntity? editingTask =
        RouteArguments.maybeOf<DailyTaskEntity>();
    final CreateTaskRouteArguments? createArguments =
        RouteArguments.maybeOf<CreateTaskRouteArguments>();
    Get.put<CreateTaskController>(
      CreateTaskController(
        addDailyTaskUseCase: Get.find(),
        updateDailyTaskUseCase: Get.find(),
        appNavigator: Get.find(),
        achievementUnlockService: Get.find(),
        // Reminders are local notifications, which the app only has on
        // phones.
        ensureNotificationsEnabled: GetPlatform.isAndroid || GetPlatform.isIOS
            ? _ensureNotificationsEnabled
            : null,
        editingTask: editingTask,
        initialName: createArguments?.initialName,
      ),
    );
  }

  Future<bool> _ensureNotificationsEnabled() async {
    final AppController appController = Get.find();
    if (!appController.notificationsEnabled.value) {
      await appController.setNotificationsEnabled(true);
    }
    return appController.notificationsEnabled.value;
  }
}
