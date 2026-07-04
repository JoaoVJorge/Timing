import "package:get/get.dart";
import "package:help_out/presentation/create_account/create_account_controller.dart";

class CreateAccountBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<CreateAccountController>(
      CreateAccountController(
        appController: Get.find(),
        appNavigator: Get.find(),
      ),
    );
  }
}
