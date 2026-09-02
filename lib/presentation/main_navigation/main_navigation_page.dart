import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/presentation/config/config_bindings.dart";
import "package:timing/presentation/config/config_page.dart";
import "package:timing/presentation/groups/groups_bindings.dart";
import "package:timing/presentation/groups/groups_page.dart";
import "package:timing/presentation/home/home_bindings.dart";
import "package:timing/presentation/home/home_page.dart";
import "package:timing/presentation/main_navigation/enums/bottom_nav_button_type.dart";
import "package:timing/presentation/main_navigation/fade_indexed_stack.dart";
import "package:timing/presentation/main_navigation/main_navigation_controller.dart";
import "package:timing/presentation/main_navigation/widgets/app_bottom_nav_bar.dart";
import "package:timing/presentation/progress/progress_bindings.dart";
import "package:timing/presentation/progress/progress_page.dart";

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MainNavigationController controller = Get.find();

    return Obx(
      () => PopScope(
        canPop: controller.isOnHomeTab,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            controller.onSystemBackFromNonHomeTab();
          }
        },
        child: Scaffold(
          body: FadeIndexedStack(
            index: controller.selectedButton.value.index,
            itemCount: BottomNavButtonType.values.length,
            itemBuilder: _buildTab,
          ),
          bottomNavigationBar: RepaintBoundary(
            child: AppBottomNavBar(
              selectedButton: controller.selectedButton.value,
              onTabTap: controller.onTapBottomBarButton,
            ),
          ),
        ),
      ),
    );
  }

  /// Runs the tab's bindings the first time it is shown (so Progress / Groups /
  /// Config still only load once the user opens them) and returns its page.
  Widget _buildTab(BuildContext context, int index) {
    switch (BottomNavButtonType.values[index]) {
      case BottomNavButtonType.home:
        HomeBindings().dependencies();
        return const HomePage();
      case BottomNavButtonType.progress:
        ProgressBindings().dependencies();
        return const ProgressPage();
      case BottomNavButtonType.groups:
        GroupsBindings().dependencies();
        return const GroupsPage();
      case BottomNavButtonType.config:
        ConfigBindings().dependencies();
        return const ConfigPage();
    }
  }
}
