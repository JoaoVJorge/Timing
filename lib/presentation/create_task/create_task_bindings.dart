import "package:get/get.dart";
import "package:timing/app/route_arguments.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/presentation/create_task/create_task_controller.dart";

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
