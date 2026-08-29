import "package:dio/dio.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:get/get.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/analytics/analytics_service.dart";
import "package:timing/core/services/analytics/logging_analytics_service.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/focus/focus_feedback_service.dart";
import "package:timing/core/services/focus/focus_guard_service.dart";
import "package:timing/core/services/focus/focus_overlay_service.dart";
import "package:timing/core/services/home_widget/home_widget_service.dart";
import "package:timing/core/services/http/http_client_service.dart";
import "package:timing/core/services/last_activity/last_activity_service.dart";
import "package:timing/core/services/live_activity/timer_live_activity_service.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/notifications/timer_notification_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/core/services/sync/main_tab_refresh_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";
import "package:timing/env/environment_keys.dart";
import "package:shared_preferences/shared_preferences.dart";

class ServicesBindings extends Bindings {
  @override
  Future<void> dependencies() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(sharedPreferences, permanent: true);
    Get.put<FlutterSecureStorage>(
      const FlutterSecureStorage(),
      permanent: true,
    );
    Get.put<AppLoggerService>(AppLoggerService(), permanent: true);
    Get.put<ActivityChangeBus>(ActivityChangeBus(), permanent: true);
    Get.put<MainTabRefreshService>(MainTabRefreshService(), permanent: true);
    Get.put<AnalyticsService>(
      LoggingAnalyticsService(logger: Get.find()),
      permanent: true,
    );
    Get.put<TimerNotificationService>(
      TimerNotificationService(logger: Get.find<AppLoggerService>()),
      permanent: true,
    );
    Get.put<TimerLiveActivityService>(
      TimerLiveActivityService(),
      permanent: true,
    );
    Get.put<FocusFeedbackService>(FocusFeedbackService(), permanent: true);
    Get.put<FocusGuardService>(FocusGuardService(), permanent: true);
    Get.put<FocusOverlayService>(FocusOverlayService(), permanent: true);
    Get.put<HomeWidgetService>(HomeWidgetService(), permanent: true);

    final SupabaseService supabaseService = await SupabaseService.initialize();
    Get.put<SupabaseService>(supabaseService, permanent: true);

    Get.put<AppLocalStorageService>(
      AppLocalStorageService(
        localStorage: Get.find(),
        secureStorage: Get.find(),
        supabaseService: Get.find(),
      ),
      permanent: true,
    );

    final PendingSyncStore pendingSyncStore = PendingSyncStore(
      localStorageService: Get.find(),
    );
    await pendingSyncStore.load();
    Get.put<PendingSyncStore>(pendingSyncStore, permanent: true);

    final LastActivityService lastActivityService = LastActivityService(
      localStorageService: Get.find(),
    );
    await lastActivityService.load();
    Get.put<LastActivityService>(lastActivityService, permanent: true);

    final DailyProgressService dailyProgressService = DailyProgressService(
      localStorageService: Get.find(),
    );
    await dailyProgressService.load();
    Get.put<DailyProgressService>(dailyProgressService, permanent: true);

    final SubjectDailyHistoryService subjectDailyHistoryService =
        SubjectDailyHistoryService(localStorageService: Get.find());
    await subjectDailyHistoryService.load();
    Get.put<SubjectDailyHistoryService>(
      subjectDailyHistoryService,
      permanent: true,
    );

    final ActivityHistoryService activityHistoryService =
        ActivityHistoryService(localStorageService: Get.find());
    await activityHistoryService.load();
    Get.put<ActivityHistoryService>(activityHistoryService, permanent: true);

    final Dio dio = Dio(BaseOptions(baseUrl: EnvironmentKeys.baseUrl));
    Get.put<Dio>(dio, permanent: true);
    Get.put<HttpClientService>(
      HttpClientService(dio: Get.find()),
      permanent: true,
    );
  }
}
