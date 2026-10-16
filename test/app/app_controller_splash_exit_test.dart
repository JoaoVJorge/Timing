import "dart:async";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/core/data/repositories/activity_repository.dart";
import "package:timing/core/data/repositories/app_config_repository.dart";
import "package:timing/core/data/repositories/phone_auth_repository.dart";
import "package:timing/core/data/repositories/profile_sync_repository.dart";
import "package:timing/core/domain/entities/active_timer_session_entity.dart";
import "package:timing/core/domain/entities/app_config_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/services/connectivity/connectivity_service.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/notifications/goal_reminder_service.dart";
import "package:timing/core/services/notifications/timer_notification_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/sync_reconciliation_service.dart";
import "package:timing/core/services/timer/active_timer_session_service.dart";

class _Noop {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _ThrowingAppConfigRepository extends _Noop
    implements AppConfigRepository {
  @override
  Future<Either<AppError, AppConfigEntity>> getAppConfig() async =>
      throw StateError("config storage unavailable");
}

class _SavedAppConfigRepository extends _Noop implements AppConfigRepository {
  @override
  Future<Either<AppError, AppConfigEntity>> getAppConfig() async =>
      Right(AppConfigEntity.fallback().copyWith(userName: "Splash tester"));
}

class _FakeSupabaseService extends _Noop implements SupabaseService {
  _FakeSupabaseService({required this.hasSignedInUser});

  @override
  final bool hasSignedInUser;

  @override
  bool get isConfigured => true;

  @override
  String? get currentUserId => hasSignedInUser ? "user-1" : null;
}

class _OfflineProfileSyncRepository extends _Noop
    implements ProfileSyncRepository {
  @override
  Future<Either<AppError, AppConfigEntity?>> getCurrentProfile() async =>
      const Left(OfflineError());
}

class _FakeTimerNotificationService extends _Noop
    implements TimerNotificationService {
  @override
  Future<bool> areNotificationsEnabled() async => true;
}

class _FakeGoalReminderService extends _Noop implements GoalReminderService {
  @override
  Future<void> configure({required bool enabled, required Locale locale}) =>
      Future<void>.value();
}

/// A device keystore that never answers: every encrypted read stalls.
class _StalledLocalStorageService extends _Noop
    implements AppLocalStorageService {
  @override
  Future<T?> read<T>(LocalStorageKeys key) => Completer<T?>().future;

  @override
  Future<void> write<T>(LocalStorageKeys key, T value) =>
      Completer<void>().future;
}

class _StalledActiveTimerSessionService extends _Noop
    implements ActiveTimerSessionService {
  @override
  Future<ActiveTimerSessionEntity?> restore() =>
      Completer<ActiveTimerSessionEntity?>().future;
}

class _FakeAchievementUnlockService extends _Noop
    implements AchievementUnlockService {
  @override
  void setNotificationsEnabled(bool value) {}
}

class _FakeActivityRepository extends _Noop implements ActivityRepository {}

class _FakePhoneAuthRepository extends _Noop implements PhoneAuthRepository {}

class _FakeSyncReconciliationService extends _Noop
    implements SyncReconciliationService {}

AppController _controller({
  required AppConfigRepository appConfigRepository,
  required bool hasSignedInUser,
}) => AppController(
  appConfigRepository: appConfigRepository,
  activityRepository: _FakeActivityRepository(),
  profileSyncRepository: _OfflineProfileSyncRepository(),
  phoneAuthRepository: _FakePhoneAuthRepository(),
  appNavigator: AppNavigator(),
  supabaseService: _FakeSupabaseService(hasSignedInUser: hasSignedInUser),
  timerNotificationService: _FakeTimerNotificationService(),
  goalReminderService: _FakeGoalReminderService(),
  activeTimerSessionService: _StalledActiveTimerSessionService(),
  syncReconciliationService: _FakeSyncReconciliationService(),
  localStorageService: _StalledLocalStorageService(),
);

Future<void> _pumpSplash(WidgetTester tester) => tester.pumpWidget(
  GetMaterialApp(
    initialRoute: AppRoutes.splash,
    getPages: <GetPage<void>>[
      GetPage<void>(
        name: AppRoutes.splash,
        page: () => const Scaffold(body: Text("splash")),
      ),
      GetPage<void>(
        name: AppRoutes.login,
        page: () => const Scaffold(body: Text("login")),
      ),
      GetPage<void>(
        name: AppRoutes.mainNavigation,
        page: () => const Scaffold(body: Text("main")),
      ),
    ],
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.put<AchievementUnlockService>(_FakeAchievementUnlockService());
    Get.put<ConnectivityService>(
      ConnectivityService(
        checkConnectivity: () async => <ConnectivityResult>[],
        connectivityChanges: const Stream<List<ConnectivityResult>>.empty(),
        checkBackend: () async => false,
      ),
    );
  });

  tearDown(Get.reset);

  testWidgets("leaves the splash for login when the config load throws", (
    tester,
  ) async {
    await _pumpSplash(tester);
    final AppController controller = _controller(
      appConfigRepository: _ThrowingAppConfigRepository(),
      hasSignedInUser: false,
    );

    unawaited(controller.initialize());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, AppRoutes.login);
    expect(find.text("login"), findsOneWidget);
  });

  testWidgets(
    "opens the main screen for a signed-in user whose keystore never answers",
    (tester) async {
      await _pumpSplash(tester);
      final AppController controller = _controller(
        appConfigRepository: _SavedAppConfigRepository(),
        hasSignedInUser: true,
      );

      unawaited(controller.initialize());
      // Splash delay, then the grace-period read and the timer restore each
      // give up after their own timeout.
      for (int second = 0; second < 13; second++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle();

      expect(Get.currentRoute, AppRoutes.mainNavigation);
      expect(find.text("main"), findsOneWidget);
      // Stops the presence heartbeat the signed-in load started.
      controller.onClose();
    },
  );
}
