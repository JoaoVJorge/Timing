import "package:get/get.dart";
import "package:help_out/presentation/login/login_controller.dart";

class LoginBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<LoginController>(
      LoginController(appController: Get.find(), appNavigator: Get.find()),
    );
  }
}
