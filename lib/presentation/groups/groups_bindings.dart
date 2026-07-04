import "package:get/get.dart";
import "package:help_out/presentation/groups/groups_controller.dart";

class GroupsBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<GroupsController>(
      GroupsController(getGroupsUseCase: Get.find(), appNavigator: Get.find()),
    );
  }
}
