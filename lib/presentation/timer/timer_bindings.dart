import "package:get/get.dart";
import "package:help_out/presentation/timer/timer_controller.dart";

class TimerBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<TimerController>(TimerController(updateSubjectTimeUseCase: Get.find()));
  }
}
