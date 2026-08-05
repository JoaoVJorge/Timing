import "package:get/get.dart";
import "package:help_out/app/route_arguments.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/presentation/create_task/create_task_controller.dart";

class CreateTaskBindings extends Bindings {
  @override
  void dependencies() {
    final DailyTaskEntity? editingTask =
        RouteArguments.maybeOf<DailyTaskEntity>();
    Get.put<CreateTaskController>(
      CreateTaskController(
        addDailyTaskUseCase: Get.find(),
        updateDailyTaskUseCase: Get.find(),
        appNavigator: Get.find(),
        editingTask: editingTask,
      ),
    );
  }
}
