import "package:get/get.dart";
import "package:timing/core/domain/use_cases/get_daily_tasks_use_case.dart";
import "package:timing/core/domain/use_cases/get_subjects_use_case.dart";
import "package:timing/presentation/create_group/create_group_controller.dart";

class CreateGroupBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<CreateGroupController>(
      CreateGroupController(
        getInvitableFriendsUseCase: Get.find(),
        createGroupUseCase: Get.find(),
        getDailyTasksUseCase: Get.find<GetDailyTasksUseCase>(),
        getSubjectsUseCase: Get.find<GetSubjectsUseCase>(),
        appNavigator: Get.find(),
      ),
    );
  }
}
