import "package:get/get.dart";
import "package:help_out/presentation/profile/profile_controller.dart";

class ProfileBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<ProfileController>(ProfileController(getProfileStatsUseCase: Get.find(), appController: Get.find()));
  }
}
