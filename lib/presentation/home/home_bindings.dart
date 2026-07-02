import "package:get/get.dart";
import "package:help_out/presentation/home/home_controller.dart";

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController(appController: Get.find(), appNavigator: Get.find()));
  }
}
