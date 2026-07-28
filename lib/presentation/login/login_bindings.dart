import "package:get/get.dart";
import "package:help_out/presentation/login/login_controller.dart";

class LoginBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<LoginController>(LoginController(appNavigator: Get.find()));
  }
}
