import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/presentation/main_navigation/main_navigation_controller.dart";
import "package:help_out/presentation/main_navigation/widgets/app_bottom_nav_bar.dart";

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MainNavigationController controller = Get.find();

    return Scaffold(
      body: Navigator(
        key: Get.nestedKey(controller.nestedKey),
        initialRoute: controller.initialRouteName,
        onGenerateRoute: controller.onGenerateRoute,
      ),
      bottomNavigationBar: Obx(
        () => AppBottomNavBar(selectedButton: controller.selectedButton.value, onTabTap: controller.onTapBottomBarButton),
      ),
    );
  }
}
