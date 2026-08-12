import "package:get/get.dart";
import "package:help_out/presentation/join_group/join_group_controller.dart";

class JoinGroupBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<JoinGroupController>(JoinGroupController(Get.find(), Get.find()));
  }
}
