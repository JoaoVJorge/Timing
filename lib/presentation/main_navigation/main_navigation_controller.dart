import "dart:async";

import "package:flutter/widgets.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/core/services/sync/main_tab_refresh_service.dart";
import "package:timing/presentation/groups/groups_controller.dart";
import "package:timing/presentation/home/home_controller.dart";
import "package:timing/presentation/main_navigation/enums/bottom_nav_button_type.dart";
import "package:timing/presentation/main_navigation/main_tab_slide_transition.dart";
import "package:timing/presentation/progress/progress_controller.dart";

class MainNavigationController extends GetxController {
  MainNavigationController({
    required this._appNavigator,
    required this._mainTabRefreshService,
  });

  final AppNavigator _appNavigator;
  final MainTabRefreshService _mainTabRefreshService;

  final int nestedKey = 1;

  final List<GetPage<dynamic>> pages = AppRoutes.getPages
      .firstWhere((route) => route.name == AppRoutes.mainNavigation)
      .children;

  late final String initialRouteName = pages.first.name;

  final Rx<BottomNavButtonType> selectedButton = BottomNavButtonType.home.obs;
  String currentRouteName = AppRoutes.home;
  final MainTabSlideTransition _tabSlideTransition = MainTabSlideTransition();

  Route<dynamic>? onGenerateRoute(RouteSettings settings) =>
      AppRoutes.onGenerateChildRoute(
        settings: settings,
        parentRouteName: AppRoutes.mainNavigation,
        customTransition: _tabSlideTransition,
      );

  void onTapBottomBarButton(BottomNavButtonType type) {
    if (selectedButton.value == type) {
      if (type == BottomNavButtonType.groups &&
          Get.isRegistered<GroupsController>()) {
        unawaited(Get.find<GroupsController>().loadGroups());
      }
      return;
    }

    final int currentIndex = selectedButton.value.index;
    final bool controllerWasRegistered = switch (type) {
      BottomNavButtonType.home => Get.isRegistered<HomeController>(),
      BottomNavButtonType.progress => Get.isRegistered<ProgressController>(),
      BottomNavButtonType.groups => Get.isRegistered<GroupsController>(),
      BottomNavButtonType.config => false,
    };
    final bool refreshHome =
        type == BottomNavButtonType.home &&
        _mainTabRefreshService.consumeHomeRefresh();
    final bool refreshProgress =
        type == BottomNavButtonType.progress &&
        _mainTabRefreshService.consumeProgressRefresh();

    _tabSlideTransition.setDirection(forward: type.index > currentIndex);
    selectedButton.value = type;
    switch (type) {
      case BottomNavButtonType.home:
        _navigateToTab(AppRoutes.home);
      case BottomNavButtonType.progress:
        _navigateToTab(AppRoutes.progress);
      case BottomNavButtonType.groups:
        _navigateToTab(AppRoutes.groups);
      case BottomNavButtonType.config:
        _navigateToTab(AppRoutes.config);
    }

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
        break;
    }
  }

  bool get isOnHomeTab => selectedButton.value == BottomNavButtonType.home;

  void onSystemBackFromNonHomeTab() {
    onTapBottomBarButton(BottomNavButtonType.home);
  }

  void _navigateToTab(String routeName) {
    if (currentRouteName == routeName) {
      return;
    }
    currentRouteName = routeName;
    _appNavigator.offAllNamed(routeName, id: nestedKey);
  }
}
