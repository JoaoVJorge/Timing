import "package:get/get.dart";
import "package:help_out/presentation/create_task/create_task_controller.dart";

class CreateTaskBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<CreateTaskController>(
      CreateTaskController(
        addDailyTaskUseCase: Get.find(),
        appNavigator: Get.find(),
      ),
    );
  }
}
