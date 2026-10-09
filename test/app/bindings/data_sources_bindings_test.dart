import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/bindings/data_sources_bindings.dart";
import "package:timing/app/bindings/repositories_bindings.dart";
import "package:timing/core/data/data_sources/schedule_data_source.dart";
import "package:timing/core/data/repositories/activity_repository.dart";
import "package:timing/core/data/repositories/app_config_repository.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/data/repositories/friends_repository.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/data/repositories/phone_auth_repository.dart";
import "package:timing/core/data/repositories/profile_sync_repository.dart";
import "package:timing/core/data/repositories/schedule_repository.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/services/connectivity/connectivity_service.dart";
import "package:timing/core/services/google_calendar/google_calendar_service.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/social/social_store.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";
import "package:timing/core/services/sync/sync_reconciliation_service.dart";

import "../../support/supabase_test_harness.dart";

class _SupabaseService implements SupabaseService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ConnectivityService implements ConnectivityService {
  @override
  final RxBool isOnline = false.obs;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(Get.reset);

  test("data sources resolve the registered non-nullable Calendar service", () {
    final storage = MemoryStorage();
    final supabase = _SupabaseService();
    final pending = PendingSyncStore(localStorageService: storage);
    Get.put<AppLocalStorageService>(storage);
    Get.put<SupabaseService>(supabase);
    Get.put<PendingSyncStore>(pending);
    Get.put<AppLoggerService>(AppLoggerService());
    Get.put<ConnectivityService>(_ConnectivityService());
    Get.put<ActivityChangeBus>(ActivityChangeBus());
    final calendar = Get.put<GoogleCalendarService>(
      GoogleCalendarService(
        supabaseService: supabase,
        localStorageService: storage,
        pendingSyncStore: pending,
      ),
    );

    expect(() => DataSourcesBindings().dependencies(), returnsNormally);
    expect(Get.find<GoogleCalendarService>(), same(calendar));
    expect(Get.isRegistered<ScheduleDataSource>(), isTrue);
    // The reconciliation service flushes through the repositories, so it is
    // registered with them.
    expect(() => RepositoriesBindings().dependencies(), returnsNormally);
    expect(Get.isRegistered<SyncReconciliationService>(), isTrue);
    // Every screen builds its controller from these.
    expect(Get.isRegistered<ActivityRepository>(), isTrue);
    expect(Get.isRegistered<AppConfigRepository>(), isTrue);
    expect(Get.isRegistered<DailyTasksRepository>(), isTrue);
    expect(Get.isRegistered<FriendsRepository>(), isTrue);
    expect(Get.isRegistered<GroupsRepository>(), isTrue);
    expect(Get.isRegistered<PhoneAuthRepository>(), isTrue);
    expect(Get.isRegistered<ProfileSyncRepository>(), isTrue);
    expect(Get.isRegistered<ScheduleRepository>(), isTrue);
    expect(Get.isRegistered<SubjectsRepository>(), isTrue);
    expect(Get.isRegistered<SocialStore>(), isTrue);
  });
}
