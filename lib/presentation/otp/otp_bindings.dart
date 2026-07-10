import "package:get/get.dart";
import "package:help_out/presentation/otp/otp_controller.dart";

class OtpBindings extends Bindings {
  @override
  void dependencies() {
    final String phoneNumber = Get.arguments as String;
    Get.put<OtpController>(
      OtpController(
        verifyPhoneCodeUseCase: Get.find(),
        requestPhoneCodeUseCase: Get.find(),
        appController: Get.find(),
        appNavigator: Get.find(),
        phoneNumber: phoneNumber,
      ),
    );
  }
}
