import "package:get/get.dart";
import "package:help_out/core/domain/use_cases/add_schedule_entry_use_case.dart";
import "package:help_out/core/domain/use_cases/add_subject_use_case.dart";
import "package:help_out/core/domain/use_cases/create_group_use_case.dart";
import "package:help_out/core/domain/use_cases/delete_schedule_entry_use_case.dart";
import "package:help_out/core/domain/use_cases/get_app_config_use_case.dart";
import "package:help_out/core/domain/use_cases/get_groups_use_case.dart";
import "package:help_out/core/domain/use_cases/get_invitable_friends_use_case.dart";
import "package:help_out/core/domain/use_cases/get_profile_stats_use_case.dart";
import "package:help_out/core/domain/use_cases/get_schedule_entries_use_case.dart";
import "package:help_out/core/domain/use_cases/get_subjects_use_case.dart";
import "package:help_out/core/domain/use_cases/save_app_config_use_case.dart";
import "package:help_out/core/domain/use_cases/sync_profile_to_backend_use_case.dart";
import "package:help_out/core/domain/use_cases/update_subject_pages_use_case.dart";
import "package:help_out/core/domain/use_cases/update_subject_time_use_case.dart";

class UseCasesBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<GetAppConfigUseCase>(GetAppConfigUseCase(appConfigRepository: Get.find()), permanent: true);
    Get.put<SaveAppConfigUseCase>(SaveAppConfigUseCase(appConfigRepository: Get.find()), permanent: true);
    Get.put<GetSubjectsUseCase>(GetSubjectsUseCase(subjectsRepository: Get.find()), permanent: true);
    Get.put<AddSubjectUseCase>(AddSubjectUseCase(subjectsRepository: Get.find()), permanent: true);
    Get.put<UpdateSubjectTimeUseCase>(UpdateSubjectTimeUseCase(subjectsRepository: Get.find()), permanent: true);
    Get.put<UpdateSubjectPagesUseCase>(UpdateSubjectPagesUseCase(subjectsRepository: Get.find()), permanent: true);
    Get.put<GetProfileStatsUseCase>(GetProfileStatsUseCase(subjectsRepository: Get.find()), permanent: true);
    Get.put<GetGroupsUseCase>(GetGroupsUseCase(groupsRepository: Get.find()), permanent: true);
    Get.put<GetInvitableFriendsUseCase>(GetInvitableFriendsUseCase(groupsRepository: Get.find()), permanent: true);
    Get.put<CreateGroupUseCase>(CreateGroupUseCase(groupsRepository: Get.find()), permanent: true);
    Get.put<SyncProfileToBackendUseCase>(SyncProfileToBackendUseCase(profileSyncRepository: Get.find()), permanent: true);
    Get.put<GetScheduleEntriesUseCase>(GetScheduleEntriesUseCase(scheduleRepository: Get.find()), permanent: true);
    Get.put<AddScheduleEntryUseCase>(AddScheduleEntryUseCase(scheduleRepository: Get.find()), permanent: true);
    Get.put<DeleteScheduleEntryUseCase>(DeleteScheduleEntryUseCase(scheduleRepository: Get.find()), permanent: true);
  }
}
