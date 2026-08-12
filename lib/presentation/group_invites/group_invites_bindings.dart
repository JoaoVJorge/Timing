import "package:get/get.dart";
import "package:timing/presentation/group_invites/group_invites_controller.dart";

class GroupInvitesBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<GroupInvitesController>(
      GroupInvitesController(
        groupsRepository: Get.find(),
        appNavigator: Get.find(),
      ),
    );
  }
}
