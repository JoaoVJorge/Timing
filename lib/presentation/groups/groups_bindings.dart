import "package:get/get.dart";
import "package:timing/presentation/groups/groups_controller.dart";

class GroupsBindings extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<GroupsController>()) return;

    Get.put<GroupsController>(
      GroupsController(
        getGroupsUseCase: Get.find(),
        groupsRepository: Get.find(),
        appNavigator: Get.find(),
        supabaseService: Get.find(),
        localStorageService: Get.find(),
        activityChangeBus: Get.find(),
      ),
      permanent: true,
    );
  }
}
