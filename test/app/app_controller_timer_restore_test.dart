import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/core/domain/entities/active_timer_session_entity.dart";
import "package:timing/core/domain/entities/app_config_entity.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/get_activity_entries_use_case.dart";
import "package:timing/core/domain/use_cases/get_app_config_use_case.dart";
import "package:timing/core/domain/use_cases/get_current_profile_use_case.dart";
import "package:timing/core/domain/use_cases/save_app_config_use_case.dart";
import "package:timing/core/domain/use_cases/sign_out_use_case.dart";
import "package:timing/core/domain/use_cases/sync_profile_to_backend_use_case.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/notifications/timer_notification_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/sync_reconciliation_service.dart";
import "package:timing/core/services/timer/active_timer_session_service.dart";

class _Noop {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeGetAppConfigUseCase extends _Noop implements GetAppConfigUseCase {
  @override
  Future<Either<AppError, AppConfigEntity>> call() async =>
      Right(AppConfigEntity.fallback().copyWith(userName: "Timer tester"));
}

class _FakeSupabaseService extends _Noop implements SupabaseService {
  @override
  bool get isConfigured => false;

  @override
  bool get hasSignedInUser => false;
}

class _FakeTimerNotificationService extends _Noop
    implements TimerNotificationService {
  @override
  Future<bool> areNotificationsEnabled() async => true;
}

class _FakeActiveTimerSessionService extends _Noop
    implements ActiveTimerSessionService {
  _FakeActiveTimerSessionService(this.session);

  final ActiveTimerSessionEntity session;

  @override
  Future<ActiveTimerSessionEntity?> restore() async => session;
}

class _FakeLocalStorageService extends _Noop implements AppLocalStorageService {
  @override
  Future<void> write<T>(LocalStorageKeys key, T value) async {}
}

class _FakeAchievementUnlockService extends _Noop
    implements AchievementUnlockService {
  @override
  void setNotificationsEnabled(bool value) {}
}

class _FakeGetActivityEntriesUseCase extends _Noop
    implements GetActivityEntriesUseCase {}

class _FakeGetCurrentProfileUseCase extends _Noop
    implements GetCurrentProfileUseCase {}

class _FakeSaveAppConfigUseCase extends _Noop implements SaveAppConfigUseCase {}

class _FakeSyncProfileToBackendUseCase extends _Noop
    implements SyncProfileToBackendUseCase {}

class _FakeSignOutUseCase extends _Noop implements SignOutUseCase {}

class _FakeSyncReconciliationService extends _Noop
    implements SyncReconciliationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.put<AchievementUnlockService>(_FakeAchievementUnlockService());
  });

  tearDown(Get.reset);

  testWidgets("opens a recovered timer after installing the main route", (
    tester,
  ) async {
    final subject = SubjectEntity(
      id: "subject-1",
      name: "Focus",
      category: TimeCategoryType.studying,
      colorValue: Colors.blue.toARGB32(),
      totalSeconds: 0,
      goalSeconds: 30 * 60,
      currentPages: 0,
      goalPages: 0,
      notes: "",
      iconName: "book",
      restMinutes: 5,
      focusSessionCount: 1,
      wallpaperIndex: 0,
    );
    final session = ActiveTimerSessionEntity(
      subject: subject,
      sessionSeconds: 5 * 60,
      breakCountdownSeconds: 25 * 60,
      restCountdownSeconds: 5 * 60,
      isRunning: true,
      isResting: false,
      completedFocusSections: 0,
      persistedSeconds: 5 * 60,
      todayFocusSecondsAtSessionStart: 0,
      capturedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: "/splash-test",
        getPages: <GetPage<void>>[
          GetPage<void>(
            name: "/splash-test",
            page: () => const SizedBox.shrink(),
          ),
          GetPage<void>(
            name: AppRoutes.mainNavigation,
            page: () => const Scaffold(body: Text("main")),
          ),
          GetPage<void>(
            name: AppRoutes.timer,
            page: () => const Scaffold(body: Text("timer")),
          ),
        ],
      ),
    );

    final controller = AppController(
      getAppConfigUseCase: _FakeGetAppConfigUseCase(),
      getActivityEntriesUseCase: _FakeGetActivityEntriesUseCase(),
      getCurrentProfileUseCase: _FakeGetCurrentProfileUseCase(),
      saveAppConfigUseCase: _FakeSaveAppConfigUseCase(),
      syncProfileToBackendUseCase: _FakeSyncProfileToBackendUseCase(),
      signOutUseCase: _FakeSignOutUseCase(),
      appNavigator: AppNavigator(),
      supabaseService: _FakeSupabaseService(),
      timerNotificationService: _FakeTimerNotificationService(),
      activeTimerSessionService: _FakeActiveTimerSessionService(session),
      syncReconciliationService: _FakeSyncReconciliationService(),
      localStorageService: _FakeLocalStorageService(),
    );

    final initialization = controller.initialize();
    await tester.pump(const Duration(seconds: 2));
    await initialization;
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.timer);
    expect(find.text("timer"), findsOneWidget);
  });
}
