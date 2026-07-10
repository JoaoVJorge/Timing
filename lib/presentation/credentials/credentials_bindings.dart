import "package:get/get.dart";
import "package:help_out/presentation/credentials/credentials_controller.dart";

class CredentialsBindings extends Bindings {
  @override
  void dependencies() {
    final String phoneNumber = Get.arguments as String;
    Get.put<CredentialsController>(
      CredentialsController(
        appController: Get.find(),
        appNavigator: Get.find(),
        phoneNumber: phoneNumber,
      ),
    );
  }
}
