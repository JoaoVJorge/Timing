import "package:flutter_test/flutter_test.dart";
import "package:timing/core/services/sync/main_tab_refresh_service.dart";
import "package:timing/presentation/main_navigation/enums/bottom_nav_button_type.dart";
import "package:timing/presentation/main_navigation/main_navigation_controller.dart";

void main() {
  late MainNavigationController controller;

  setUp(() {
    controller = MainNavigationController(
      mainTabRefreshService: MainTabRefreshService(),
    );
  });

  test("starts on the home tab", () {
    expect(controller.selectedButton.value, BottomNavButtonType.home);
    expect(controller.isOnHomeTab, isTrue);
  });

  test("tapping a tab selects it", () {
    controller.onTapBottomBarButton(BottomNavButtonType.progress);

    expect(controller.selectedButton.value, BottomNavButtonType.progress);
    expect(controller.isOnHomeTab, isFalse);
  });

  test("tapping the already selected tab keeps the selection", () {
    controller.onTapBottomBarButton(BottomNavButtonType.groups);
    controller.onTapBottomBarButton(BottomNavButtonType.groups);

    expect(controller.selectedButton.value, BottomNavButtonType.groups);
  });

  test("system back from a non-home tab returns to home", () {
    controller.onTapBottomBarButton(BottomNavButtonType.config);
    controller.onSystemBackFromNonHomeTab();

    expect(controller.selectedButton.value, BottomNavButtonType.home);
  });
}
