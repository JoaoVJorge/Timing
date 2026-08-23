import "package:get/get.dart";
import "package:timing/presentation/edit_group/edit_group_controller.dart";

class EditGroupBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<EditGroupController>(
      EditGroupController(
        groupsRepository: Get.find(),
        appNavigator: Get.find(),
      ),
    );
  }
}
