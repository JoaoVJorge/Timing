import "package:get/get.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/app/route_arguments.dart";
import "package:help_out/presentation/credentials/credentials_controller.dart";

class CredentialsBindings extends Bindings {
  @override
  void dependencies() {
    final String phoneNumber = RouteArguments.of<String>(AppRoutes.credentials);
    Get.put<CredentialsController>(
      CredentialsController(
        appController: Get.find(),
        appNavigator: Get.find(),
        phoneNumber: phoneNumber,
      ),
    );
  }
}
