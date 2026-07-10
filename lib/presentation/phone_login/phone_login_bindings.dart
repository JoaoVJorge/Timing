import "package:get/get.dart";
import "package:help_out/presentation/phone_login/phone_login_controller.dart";

class PhoneLoginBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<PhoneLoginController>(
      PhoneLoginController(
        requestPhoneCodeUseCase: Get.find(),
        appNavigator: Get.find(),
      ),
    );
  }
}
