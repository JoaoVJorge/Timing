import "package:get/get.dart";
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
import "package:timing/core/services/social/social_store.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/core/services/sync/sync_reconciliation_service.dart";

class RepositoriesBindings extends Bindings {
  @override
  void dependencies() {
    bool isBackendReachable() => Get.find<ConnectivityService>().isOnline.value;

    Get.put<AppConfigRepository>(
      AppConfigRepository(localStorageService: Get.find()),
      permanent: true,
    );
    Get.put<ActivityRepository>(
      ActivityRepository(
        activityDataSource: Get.find(),
        localStorageService: Get.find(),
        pendingSyncStore: Get.find(),
        logger: Get.find(),
        activityChangeBus: Get.find<ActivityChangeBus>(),
        isBackendReachable: isBackendReachable,
      ),
      permanent: true,
    );
    Get.put<SubjectsRepository>(
      SubjectsRepository(
        subjectsDataSource: Get.find(),
        localStorageService: Get.find(),
        logger: Get.find(),
        pendingSyncStore: Get.find(),
      ),
      permanent: true,
    );
    Get.put<DailyTasksRepository>(
      DailyTasksRepository(
        dailyTasksDataSource: Get.find(),
        localStorageService: Get.find(),
        logger: Get.find(),
        pendingSyncStore: Get.find(),
        activityChangeBus: Get.find<ActivityChangeBus>(),
        isBackendReachable: isBackendReachable,
      ),
      permanent: true,
    );
    Get.put<GroupsRepository>(
      GroupsRepository(
        groupsDataSource: Get.find(),
        localStorageService: Get.find(),
        pendingSyncStore: Get.find(),
        logger: Get.find(),
        activityChangeBus: Get.find<ActivityChangeBus>(),
        isBackendReachable: isBackendReachable,
      ),
      permanent: true,
    );
    Get.put<FriendsRepository>(
      FriendsRepository(
        friendsDataSource: Get.find(),
        localStorageService: Get.find(),
        pendingSyncStore: Get.find(),
        logger: Get.find(),
        isBackendReachable: isBackendReachable,
      ),
      permanent: true,
    );
    Get.put<ProfileSyncRepository>(
      ProfileSyncRepository(profileSyncDataSource: Get.find()),
      permanent: true,
    );
    Get.put<PhoneAuthRepository>(
      PhoneAuthRepository(phoneAuthDataSource: Get.find()),
      permanent: true,
    );
    Get.put<ScheduleRepository>(
      ScheduleRepository(
        scheduleDataSource: Get.find(),
        googleCalendarService: Get.find<GoogleCalendarService>(),
        localStorageService: Get.find(),
        logger: Get.find(),
        pendingSyncStore: Get.find(),
      ),
      permanent: true,
    );

    Get.put<SocialStore>(
      SocialStore(friendsRepository: Get.find()),
      permanent: true,
    );
    Get.put<SyncReconciliationService>(
      SyncReconciliationService(
        subjectsRepository: Get.find(),
        googleCalendarService: Get.find<GoogleCalendarService>(),
        scheduleRepository: Get.find(),
        dailyTasksRepository: Get.find(),
        activityRepository: Get.find(),
        groupsRepository: Get.find(),
        friendsRepository: Get.find(),
      ),
      permanent: true,
    );
  }
}
