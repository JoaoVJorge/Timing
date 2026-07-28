import "package:get/get.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/app/route_arguments.dart";
import "package:help_out/presentation/otp/otp_controller.dart";

class OtpBindings extends Bindings {
  @override
  void dependencies() {
    final String emailAddress = RouteArguments.of<String>(AppRoutes.otp);
    Get.put<OtpController>(
      OtpController(
        verifyPhoneCodeUseCase: Get.find(),
        requestPhoneCodeUseCase: Get.find(),
        appController: Get.find(),
        appNavigator: Get.find(),
        logger: Get.find(),
        emailAddress: emailAddress,
      ),
    );
  }
}
