import "package:get/get.dart";
import "package:help_out/presentation/create_group/create_group_controller.dart";

class CreateGroupBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<CreateGroupController>(
      CreateGroupController(getInvitableFriendsUseCase: Get.find(), createGroupUseCase: Get.find(), appNavigator: Get.find()),
    );
  }
}
