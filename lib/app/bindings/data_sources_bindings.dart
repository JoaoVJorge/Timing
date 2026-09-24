import "package:get/get.dart";
import "package:timing/core/services/connectivity/connectivity_service.dart";
import "package:timing/core/data/data_sources/app_config_data_source.dart";
import "package:timing/core/data/data_sources/activity_data_source.dart";
import "package:timing/core/data/data_sources/daily_tasks_data_source.dart";
import "package:timing/core/data/data_sources/friends_data_source.dart";
import "package:timing/core/data/data_sources/groups_data_source.dart";
import "package:timing/core/data/data_sources/phone_auth_data_source.dart";
import "package:timing/core/data/data_sources/profile_sync_data_source.dart";
import "package:timing/core/data/data_sources/schedule_data_source.dart";
import "package:timing/core/data/data_sources/subjects_data_source.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/core/services/sync/sync_reconciliation_service.dart";

class DataSourcesBindings extends Bindings {
  @override
  void dependencies() {
    bool isBackendReachable() => Get.find<ConnectivityService>().isOnline.value;

    Get.put<AppConfigDataSource>(
      AppConfigDataSource(localStorageService: Get.find()),
      permanent: true,
    );
    Get.put<ActivityDataSource>(
      ActivityDataSource(
        activityChangeBus: Get.find<ActivityChangeBus>(),
        supabaseService: Get.find(),
        localStorageService: Get.find(),
        pendingSyncStore: Get.find(),
        logger: Get.find(),
        isBackendReachable: isBackendReachable,
      ),
      permanent: true,
    );
    Get.put<SubjectsDataSource>(
      SubjectsDataSource(
        localStorageService: Get.find(),
        supabaseService: Get.find(),
        logger: Get.find(),
        pendingSyncStore: Get.find(),
      ),
      permanent: true,
    );
    Get.put<DailyTasksDataSource>(
      DailyTasksDataSource(
        activityChangeBus: Get.find<ActivityChangeBus>(),
        localStorageService: Get.find(),
        supabaseService: Get.find(),
        logger: Get.find(),
        pendingSyncStore: Get.find(),
        isBackendReachable: isBackendReachable,
      ),
      permanent: true,
    );
    Get.put<GroupsDataSource>(
      GroupsDataSource(
        activityChangeBus: Get.find<ActivityChangeBus>(),
        supabaseService: Get.find(),
        logger: Get.find(),
        localStorageService: Get.find(),
        pendingSyncStore: Get.find(),
        isBackendReachable: isBackendReachable,
      ),
      permanent: true,
    );
    Get.put<FriendsDataSource>(
      FriendsDataSource(
        supabaseService: Get.find(),
        logger: Get.find(),
        localStorageService: Get.find(),
        pendingSyncStore: Get.find(),
        isBackendReachable: isBackendReachable,
      ),
      permanent: true,
    );
    Get.put<ProfileSyncDataSource>(
      ProfileSyncDataSource(supabaseService: Get.find(), logger: Get.find()),
      permanent: true,
    );
    Get.put<PhoneAuthDataSource>(
      PhoneAuthDataSource(supabaseService: Get.find()),
      permanent: true,
    );
    Get.put<ScheduleDataSource>(
      ScheduleDataSource(
        localStorageService: Get.find(),
        supabaseService: Get.find(),
        logger: Get.find(),
        pendingSyncStore: Get.find(),
      ),
      permanent: true,
    );

    Get.put<SyncReconciliationService>(
      SyncReconciliationService(
        subjectsDataSource: Get.find(),
        scheduleDataSource: Get.find(),
        dailyTasksDataSource: Get.find(),
        activityDataSource: Get.find(),
        groupsDataSource: Get.find(),
        friendsDataSource: Get.find(),
      ),
      permanent: true,
    );
  }
}
