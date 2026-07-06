import "package:flutter/foundation.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/bindings/data_sources_bindings.dart";
import "package:help_out/app/bindings/repositories_bindings.dart";
import "package:help_out/app/bindings/services_bindings.dart";
import "package:help_out/app/bindings/use_cases_bindings.dart";
import "package:help_out/presentation/schedule/schedule_controller.dart";

class AppBindings extends Bindings {
  @override
  Future<void> dependencies() async {
    await dotenv.load(
      fileName: kDebugMode ? "lib/env/debug.env" : "lib/env/prod.env",
    );

    Get.put<AppNavigator>(AppNavigator(), permanent: true);

    await ServicesBindings().dependencies();
    DataSourcesBindings().dependencies();
    RepositoriesBindings().dependencies();
    UseCasesBindings().dependencies();

    Get.put<AppController>(
      AppController(
        getAppConfigUseCase: Get.find(),
        saveAppConfigUseCase: Get.find(),
        syncProfileToBackendUseCase: Get.find(),
        appNavigator: Get.find(),
      ),
      permanent: true,
    );

    // Shared singleton so every screen observes the exact same schedule list — no manual refresh-on-return needed.
    Get.put<ScheduleController>(
      ScheduleController(
        getScheduleEntriesUseCase: Get.find(),
        addScheduleEntryUseCase: Get.find(),
        deleteScheduleEntryUseCase: Get.find(),
        appNavigator: Get.find(),
      ),
      permanent: true,
    );
  }
}
