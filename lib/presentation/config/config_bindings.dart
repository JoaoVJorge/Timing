import "package:get/get.dart";
import "package:timing/presentation/config/config_controller.dart";

class ConfigBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<ConfigController>(
      ConfigController(appController: Get.find(), appNavigator: Get.find()),
    );
  }
}
