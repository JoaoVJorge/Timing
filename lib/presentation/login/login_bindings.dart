import "package:app_links/app_links.dart";
import "package:get/get.dart";
import "package:timing/presentation/login/login_controller.dart";

class LoginBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<LoginController>(
      LoginController(
        phoneAuthRepository: Get.find(),
        appController: Get.find(),
        appNavigator: Get.find(),
        supabaseService: Get.find(),
        logger: Get.find(),
        oauthCallbacks: AppLinks().uriLinkStream,
      ),
    );
  }
}
