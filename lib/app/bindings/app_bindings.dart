import "package:flutter/foundation.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:get/get.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/bindings/data_sources_bindings.dart";
import "package:timing/app/bindings/repositories_bindings.dart";
import "package:timing/app/bindings/services_bindings.dart";
import "package:timing/app/bindings/use_cases_bindings.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/presentation/schedule/schedule_controller.dart";
import "package:timing/theme/accent_presets.dart";
import "package:shared_preferences/shared_preferences.dart";

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

    final SharedPreferences localStorage = Get.find();
    Get.put<AppController>(
      AppController(
        getAppConfigUseCase: Get.find(),
        getActivityEntriesUseCase: Get.find(),
        getCurrentProfileUseCase: Get.find(),
        saveAppConfigUseCase: Get.find(),
        syncProfileToBackendUseCase: Get.find(),
        signOutUseCase: Get.find(),
        appNavigator: Get.find(),
        supabaseService: Get.find(),
        timerNotificationService: Get.find(),
        syncReconciliationService: Get.find(),
        localStorageService: Get.find(),
        initialAccentColorValue:
            localStorage.getInt(LocalStorageKeys.cachedAccentColorValue.name) ??
            AppAccentPresets.defaultAccentValue,
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
