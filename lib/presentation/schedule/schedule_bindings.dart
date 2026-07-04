import "package:get/get.dart";
import "package:help_out/presentation/schedule/schedule_controller.dart";

class ScheduleBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<ScheduleController>(
      ScheduleController(
        getScheduleEntriesUseCase: Get.find(),
        addScheduleEntryUseCase: Get.find(),
        deleteScheduleEntryUseCase: Get.find(),
        appNavigator: Get.find(),
      ),
    );
  }
}
