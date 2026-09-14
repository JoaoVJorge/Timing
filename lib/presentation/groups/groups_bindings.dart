import "package:get/get.dart";
import "package:timing/core/services/sync/main_tab_refresh_service.dart";
import "package:timing/presentation/groups/groups_controller.dart";

class GroupsBindings extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<GroupsController>()) return;

    Get.put<GroupsController>(
      GroupsController(
        getGroupsUseCase: Get.find(),
        getFriendsSocialUseCase: Get.find(),
        sendFriendRequestUseCase: Get.find(),
        cancelFriendRequestUseCase: Get.find(),
        acceptFriendRequestUseCase: Get.find(),
        removeFriendUseCase: Get.find(),
        groupsRepository: Get.find(),
        appNavigator: Get.find(),
        supabaseService: Get.find(),
        localStorageService: Get.find(),
        activityChangeBus: Get.find(),
        mainTabRefreshService: Get.find<MainTabRefreshService>(),
      ),
      permanent: true,
    );
  }
}
