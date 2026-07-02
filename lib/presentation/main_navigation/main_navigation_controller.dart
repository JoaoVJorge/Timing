import "package:flutter/widgets.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/presentation/main_navigation/enums/bottom_nav_button_type.dart";

class MainNavigationController extends GetxController {
  MainNavigationController({required this._appNavigator});

  final AppNavigator _appNavigator;

  final int nestedKey = 1;

  final List<GetPage<dynamic>> pages = AppRoutes.getPages
      .firstWhere((route) => route.name == AppRoutes.mainNavigation)
      .children;

  late final String initialRouteName = pages.first.name;

  final Rx<BottomNavButtonType> selectedButton = BottomNavButtonType.home.obs;
  String currentRouteName = AppRoutes.home;

  Route<dynamic>? onGenerateRoute(RouteSettings settings) =>
      AppRoutes.onGenerateChildRoute(settings: settings, parentRouteName: AppRoutes.mainNavigation);

  void onTapBottomBarButton(BottomNavButtonType type) {
    selectedButton.value = type;
    switch (type) {
      case BottomNavButtonType.home:
        _onTapHome();
      case BottomNavButtonType.config:
        _onTapConfig();
    }
  }

  void _onTapHome() {
    if (currentRouteName == AppRoutes.home) {
      return;
    }
    currentRouteName = AppRoutes.home;
    _appNavigator.offAllNamed(AppRoutes.home, id: nestedKey);
  }

  void _onTapConfig() {
    if (currentRouteName == AppRoutes.config) {
      return;
    }
    currentRouteName = AppRoutes.config;
    _appNavigator.offAllNamed(AppRoutes.config, id: nestedKey);
  }
}
