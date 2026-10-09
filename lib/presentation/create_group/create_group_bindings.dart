import "package:get/get.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/presentation/create_group/create_group_controller.dart";

class CreateGroupBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<CreateGroupController>(
      CreateGroupController(
        groupsRepository: Get.find(),
        dailyTasksRepository: Get.find<DailyTasksRepository>(),
        subjectsRepository: Get.find<SubjectsRepository>(),
        appNavigator: Get.find(),
      ),
    );
  }
}
