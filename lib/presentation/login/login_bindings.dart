import "package:get/get.dart";
import "package:timing/presentation/login/login_controller.dart";

class LoginBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<LoginController>(
      LoginController(
        signInWithGoogleUseCase: Get.find(),
        appController: Get.find(),
        appNavigator: Get.find(),
        supabaseService: Get.find(),
        logger: Get.find(),
      ),
    );
  }
}
