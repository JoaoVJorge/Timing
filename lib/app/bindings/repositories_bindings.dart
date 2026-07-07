import "package:get/get.dart";
import "package:help_out/core/data/repositories/app_config_repository.dart";
import "package:help_out/core/data/repositories/daily_tasks_repository.dart";
import "package:help_out/core/data/repositories/groups_repository.dart";
import "package:help_out/core/data/repositories/phone_auth_repository.dart";
import "package:help_out/core/data/repositories/profile_sync_repository.dart";
import "package:help_out/core/data/repositories/schedule_repository.dart";
import "package:help_out/core/data/repositories/subjects_repository.dart";

class RepositoriesBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AppConfigRepository>(AppConfigRepository(appConfigDataSource: Get.find()), permanent: true);
    Get.put<SubjectsRepository>(SubjectsRepository(subjectsDataSource: Get.find()), permanent: true);
    Get.put<DailyTasksRepository>(DailyTasksRepository(dailyTasksDataSource: Get.find()), permanent: true);
    Get.put<GroupsRepository>(GroupsRepository(groupsDataSource: Get.find()), permanent: true);
    Get.put<ProfileSyncRepository>(ProfileSyncRepository(profileSyncDataSource: Get.find()), permanent: true);
    Get.put<PhoneAuthRepository>(PhoneAuthRepository(phoneAuthDataSource: Get.find()), permanent: true);
    Get.put<ScheduleRepository>(ScheduleRepository(scheduleDataSource: Get.find()), permanent: true);
  }
}
