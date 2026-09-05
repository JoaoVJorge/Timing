import "package:get/get.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/bindings/data_sources_bindings.dart";
import "package:timing/app/bindings/repositories_bindings.dart";
import "package:timing/app/bindings/services_bindings.dart";
import "package:timing/app/bindings/use_cases_bindings.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/presentation/schedule/schedule_bindings.dart";
import "package:timing/theme/accent_presets.dart";
import "package:shared_preferences/shared_preferences.dart";

class AppBindings extends Bindings {
  @override
  Future<void> dependencies() async {
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
        activeTimerSessionService: Get.find(),
        syncReconciliationService: Get.find(),
        localStorageService: Get.find(),
        initialAccentColorValue:
            localStorage.getInt(LocalStorageKeys.cachedAccentColorValue.name) ??
            AppAccentPresets.defaultAccentValue,
      ),
      permanent: true,
    );

    ScheduleBindings().dependencies();
  }
}
