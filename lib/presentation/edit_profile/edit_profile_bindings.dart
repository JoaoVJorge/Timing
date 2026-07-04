import "package:get/get.dart";
import "package:help_out/presentation/edit_profile/edit_profile_controller.dart";

class EditProfileBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<EditProfileController>(
      EditProfileController(
        appController: Get.find(),
        appNavigator: Get.find(),
      ),
    );
  }
}
