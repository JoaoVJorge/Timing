import "package:get/get.dart";
import "package:help_out/core/data/data_sources/app_config_data_source.dart";
import "package:help_out/core/data/data_sources/activity_data_source.dart";
import "package:help_out/core/data/data_sources/daily_tasks_data_source.dart";
import "package:help_out/core/data/data_sources/groups_data_source.dart";
import "package:help_out/core/data/data_sources/phone_auth_data_source.dart";
import "package:help_out/core/data/data_sources/profile_sync_data_source.dart";
import "package:help_out/core/data/data_sources/schedule_data_source.dart";
import "package:help_out/core/data/data_sources/subjects_data_source.dart";

class DataSourcesBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AppConfigDataSource>(
      AppConfigDataSource(localStorageService: Get.find()),
      permanent: true,
    );
    Get.put<ActivityDataSource>(
      ActivityDataSource(supabaseService: Get.find()),
      permanent: true,
    );
    Get.put<SubjectsDataSource>(
      SubjectsDataSource(localStorageService: Get.find()),
      permanent: true,
    );
    Get.put<DailyTasksDataSource>(
      DailyTasksDataSource(localStorageService: Get.find()),
      permanent: true,
    );
    Get.put<GroupsDataSource>(
      GroupsDataSource(supabaseService: Get.find()),
      permanent: true,
    );
    Get.put<ProfileSyncDataSource>(
      ProfileSyncDataSource(supabaseService: Get.find()),
      permanent: true,
    );
    Get.put<PhoneAuthDataSource>(
      PhoneAuthDataSource(supabaseService: Get.find()),
      permanent: true,
    );
    Get.put<ScheduleDataSource>(
      ScheduleDataSource(localStorageService: Get.find()),
      permanent: true,
    );
  }
}
