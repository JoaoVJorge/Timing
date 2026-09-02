import "package:get/get.dart";
import "package:timing/presentation/config/config_controller.dart";

class ConfigBindings extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<ConfigController>()) return;

    Get.put<ConfigController>(
      ConfigController(appController: Get.find(), appNavigator: Get.find()),
      permanent: true,
    );
  }
}
