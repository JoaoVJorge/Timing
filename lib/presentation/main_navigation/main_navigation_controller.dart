import "dart:async";

import "package:get/get.dart";
import "package:timing/core/services/sync/main_tab_refresh_service.dart";
import "package:timing/presentation/config/config_controller.dart";
import "package:timing/presentation/groups/groups_controller.dart";
import "package:timing/presentation/home/home_controller.dart";
import "package:timing/presentation/main_navigation/enums/bottom_nav_button_type.dart";
import "package:timing/presentation/progress/progress_controller.dart";

class MainNavigationController extends GetxController {
  MainNavigationController({required this._mainTabRefreshService});

  final MainTabRefreshService _mainTabRefreshService;

  /// Drives the visible tab in [FadeIndexedStack]; the four tab pages stay
  /// mounted, so switching is a paint, not a rebuild.
  final Rx<BottomNavButtonType> selectedButton = BottomNavButtonType.home.obs;

  bool get isOnHomeTab => selectedButton.value == BottomNavButtonType.home;

  void onSystemBackFromNonHomeTab() {
    onTapBottomBarButton(BottomNavButtonType.home);
  }

  void onTapBottomBarButton(BottomNavButtonType type) {
    if (selectedButton.value == type) {
      if (type == BottomNavButtonType.groups &&
          Get.isRegistered<GroupsController>()) {
        unawaited(Get.find<GroupsController>().loadGroups());
      }
      return;
    }

    final bool controllerWasRegistered = switch (type) {
      BottomNavButtonType.home => Get.isRegistered<HomeController>(),
      BottomNavButtonType.progress => Get.isRegistered<ProgressController>(),
      BottomNavButtonType.groups => Get.isRegistered<GroupsController>(),
      BottomNavButtonType.config => Get.isRegistered<ConfigController>(),
    };
    final bool refreshHome =
        type == BottomNavButtonType.home &&
        _mainTabRefreshService.consumeHomeRefresh();
    final bool refreshProgress =
        type == BottomNavButtonType.progress &&
        _mainTabRefreshService.consumeProgressRefresh();

    selectedButton.value = type;

    // On the first visit the tab's controller is not registered yet: the page
    // subtree builds, its bindings run and its own onInit loads the data. Only
    // revisits need an explicit refresh here.
    if (!controllerWasRegistered) {
      return;
    }
    switch (type) {
      case BottomNavButtonType.home:
        if (refreshHome) {
          unawaited(
            Get.find<HomeController>().load(
              reloadSchedule: false,
              reloadDailyTasks: true,
            ),
          );
        }
      case BottomNavButtonType.progress:
        if (refreshProgress) {
          unawaited(Get.find<ProgressController>().loadStats());
        }
      case BottomNavButtonType.groups:
        unawaited(Get.find<GroupsController>().loadGroups());
      case BottomNavButtonType.config:
        Get.find<ConfigController>().syncNotificationsFromSystem();
    }
  }
}
