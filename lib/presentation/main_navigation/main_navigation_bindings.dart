import "package:get/get.dart";
import "package:help_out/presentation/main_navigation/main_navigation_controller.dart";

class MainNavigationBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<MainNavigationController>(MainNavigationController(appNavigator: Get.find()));
  }
}
