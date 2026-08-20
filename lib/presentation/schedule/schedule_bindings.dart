import "package:get/get.dart";
import "package:timing/presentation/schedule/schedule_controller.dart";

/// Registers [ScheduleController] as a permanent singleton so every screen
/// (home, the schedule tab, add-entry) observes the exact same schedule list —
/// no manual refresh-on-return needed. Wired both from [AppBindings] (so it
/// exists before the first schedule read) and from the schedule routes.
class ScheduleBindings extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<ScheduleController>()) return;

    Get.put<ScheduleController>(
      ScheduleController(
        getScheduleEntriesUseCase: Get.find(),
        addScheduleEntryUseCase: Get.find(),
        deleteScheduleEntryUseCase: Get.find(),
        updateScheduleEntryUseCase: Get.find(),
        appNavigator: Get.find(),
      ),
      permanent: true,
    );
  }
}
