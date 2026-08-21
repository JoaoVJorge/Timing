import "package:get/get.dart";
import "package:timing/presentation/create_group/create_group_controller.dart";

class CreateGroupBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<CreateGroupController>(
      CreateGroupController(
        getInvitableFriendsUseCase: Get.find(),
        createGroupUseCase: Get.find(),
        addDailyTaskUseCase: Get.find(),
        addSubjectUseCase: Get.find(),
        appNavigator: Get.find(),
      ),
    );
  }
}
