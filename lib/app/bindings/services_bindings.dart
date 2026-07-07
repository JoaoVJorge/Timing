import "package:dio/dio.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:get/get.dart";
import "package:help_out/core/services/http/http_client_service.dart";
import "package:help_out/core/services/last_activity/last_activity_service.dart";
import "package:help_out/core/services/local_storage/app_local_storage_service.dart";
import "package:help_out/core/services/log/app_logger_service.dart";
import "package:help_out/core/services/notifications/timer_notification_service.dart";
import "package:help_out/env/environment_keys.dart";
import "package:shared_preferences/shared_preferences.dart";

class ServicesBindings extends Bindings {
  @override
  Future<void> dependencies() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(sharedPreferences, permanent: true);
    Get.put<FlutterSecureStorage>(const FlutterSecureStorage(), permanent: true);
    Get.put<AppLoggerService>(AppLoggerService(), permanent: true);
    Get.put<TimerNotificationService>(TimerNotificationService(), permanent: true);

    Get.put<AppLocalStorageService>(
      AppLocalStorageService(localStorage: Get.find(), secureStorage: Get.find()),
      permanent: true,
    );

    final LastActivityService lastActivityService = LastActivityService(localStorageService: Get.find());
    await lastActivityService.load();
    Get.put<LastActivityService>(lastActivityService, permanent: true);

    final Dio dio = Dio(BaseOptions(baseUrl: EnvironmentKeys.baseUrl));
    Get.put<Dio>(dio, permanent: true);
    Get.put<HttpClientService>(HttpClientService(dio: Get.find()), permanent: true);
  }
}
