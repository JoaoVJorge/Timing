import "package:get/get.dart";
import "package:help_out/core/domain/use_cases/add_daily_task_use_case.dart";
import "package:help_out/core/domain/use_cases/add_schedule_entry_use_case.dart";
import "package:help_out/core/domain/use_cases/add_subject_use_case.dart";
import "package:help_out/core/domain/use_cases/delete_daily_task_use_case.dart";
import "package:help_out/core/domain/use_cases/delete_subject_use_case.dart";
import "package:help_out/core/domain/use_cases/get_daily_tasks_use_case.dart";
import "package:help_out/core/domain/use_cases/toggle_daily_task_check_use_case.dart";
import "package:help_out/core/domain/use_cases/create_group_use_case.dart";
import "package:help_out/core/domain/use_cases/delete_schedule_entry_use_case.dart";
import "package:help_out/core/domain/use_cases/get_app_config_use_case.dart";
import "package:help_out/core/domain/use_cases/get_current_profile_use_case.dart";
import "package:help_out/core/domain/use_cases/get_groups_use_case.dart";
import "package:help_out/core/domain/use_cases/get_invitable_friends_use_case.dart";
import "package:help_out/core/domain/use_cases/get_profile_stats_use_case.dart";
import "package:help_out/core/domain/use_cases/get_schedule_entries_use_case.dart";
import "package:help_out/core/domain/use_cases/get_subjects_use_case.dart";
import "package:help_out/core/domain/use_cases/log_activity_use_case.dart";
import "package:help_out/core/domain/use_cases/pin_subject_to_start_use_case.dart";
import "package:help_out/core/domain/use_cases/save_app_config_use_case.dart";
import "package:help_out/core/domain/use_cases/sign_out_use_case.dart";
import "package:help_out/core/domain/use_cases/sign_in_with_google_use_case.dart";
import "package:help_out/core/domain/use_cases/sync_profile_to_backend_use_case.dart";
import "package:help_out/core/domain/use_cases/update_subject_notes_use_case.dart";
import "package:help_out/core/domain/use_cases/update_subject_use_case.dart";
import "package:help_out/core/domain/use_cases/update_subject_pages_use_case.dart";
import "package:help_out/core/domain/use_cases/update_subject_time_use_case.dart";

class UseCasesBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<GetAppConfigUseCase>(
      GetAppConfigUseCase(appConfigRepository: Get.find()),
      permanent: true,
    );
    Get.put<SaveAppConfigUseCase>(
      SaveAppConfigUseCase(appConfigRepository: Get.find()),
      permanent: true,
    );
    Get.put<GetSubjectsUseCase>(
      GetSubjectsUseCase(subjectsRepository: Get.find()),
      permanent: true,
    );
    Get.put<LogActivityUseCase>(
      LogActivityUseCase(activityRepository: Get.find()),
      permanent: true,
    );
    Get.put<DeleteSubjectUseCase>(
      DeleteSubjectUseCase(subjectsRepository: Get.find()),
    );

    Get.put<AddSubjectUseCase>(
      AddSubjectUseCase(subjectsRepository: Get.find()),
      permanent: true,
    );
    Get.put<UpdateSubjectTimeUseCase>(
      UpdateSubjectTimeUseCase(subjectsRepository: Get.find()),
      permanent: true,
    );
    Get.put<UpdateSubjectPagesUseCase>(
      UpdateSubjectPagesUseCase(subjectsRepository: Get.find()),
      permanent: true,
    );
    Get.put<UpdateSubjectNotesUseCase>(
      UpdateSubjectNotesUseCase(subjectsRepository: Get.find()),
      permanent: true,
    );
    Get.put<UpdateSubjectUseCase>(
      UpdateSubjectUseCase(subjectsRepository: Get.find()),
      permanent: true,
    );
    Get.put<PinSubjectToStartUseCase>(
      PinSubjectToStartUseCase(subjectsRepository: Get.find()),
      permanent: true,
    );
    Get.put<GetProfileStatsUseCase>(
      GetProfileStatsUseCase(subjectsRepository: Get.find()),
      permanent: true,
    );
    Get.put<GetDailyTasksUseCase>(
      GetDailyTasksUseCase(dailyTasksRepository: Get.find()),
      permanent: true,
    );
    Get.put<AddDailyTaskUseCase>(
      AddDailyTaskUseCase(dailyTasksRepository: Get.find()),
      permanent: true,
    );
    Get.put<ToggleDailyTaskCheckUseCase>(
      ToggleDailyTaskCheckUseCase(dailyTasksRepository: Get.find()),
      permanent: true,
    );
    Get.put<DeleteDailyTaskUseCase>(
      DeleteDailyTaskUseCase(dailyTasksRepository: Get.find()),
      permanent: true,
    );
    Get.put<GetGroupsUseCase>(
      GetGroupsUseCase(groupsRepository: Get.find()),
      permanent: true,
    );
    Get.put<GetInvitableFriendsUseCase>(
      GetInvitableFriendsUseCase(groupsRepository: Get.find()),
      permanent: true,
    );
    Get.put<CreateGroupUseCase>(
      CreateGroupUseCase(groupsRepository: Get.find()),
      permanent: true,
    );
    Get.put<SyncProfileToBackendUseCase>(
      SyncProfileToBackendUseCase(profileSyncRepository: Get.find()),
      permanent: true,
    );
    Get.put<GetCurrentProfileUseCase>(
      GetCurrentProfileUseCase(profileSyncRepository: Get.find()),
      permanent: true,
    );
    Get.put<SignOutUseCase>(
      SignOutUseCase(phoneAuthRepository: Get.find()),
      permanent: true,
    );
    Get.put<SignInWithGoogleUseCase>(
      SignInWithGoogleUseCase(phoneAuthRepository: Get.find()),
      permanent: true,
    );
    Get.put<GetScheduleEntriesUseCase>(
      GetScheduleEntriesUseCase(scheduleRepository: Get.find()),
      permanent: true,
    );
    Get.put<AddScheduleEntryUseCase>(
      AddScheduleEntryUseCase(scheduleRepository: Get.find()),
      permanent: true,
    );
    Get.put<DeleteScheduleEntryUseCase>(
      DeleteScheduleEntryUseCase(scheduleRepository: Get.find()),
      permanent: true,
    );
  }
}
