import "package:get/get.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/services/notifications/goal_reminder_notifications.dart";
import "package:timing/core/services/notifications/goal_reminder_service.dart";
import "package:timing/core/domain/use_cases/add_daily_task_use_case.dart";
import "package:timing/core/domain/use_cases/add_schedule_entry_use_case.dart";
import "package:timing/core/domain/use_cases/add_subject_time_use_case.dart";
import "package:timing/core/domain/use_cases/add_subject_use_case.dart";
import "package:timing/core/domain/use_cases/clear_subject_data_use_case.dart";
import "package:timing/core/domain/use_cases/delete_daily_task_use_case.dart";
import "package:timing/core/domain/use_cases/delete_subject_use_case.dart";
import "package:timing/core/domain/use_cases/toggle_daily_task_check_use_case.dart";
import "package:timing/core/domain/use_cases/delete_schedule_entry_use_case.dart";
import "package:timing/core/domain/use_cases/get_profile_stats_use_case.dart";
import "package:timing/core/domain/use_cases/remove_subject_time_use_case.dart";
import "package:timing/core/domain/use_cases/update_subject_notes_use_case.dart";
import "package:timing/core/domain/use_cases/update_subject_use_case.dart";
import "package:timing/core/domain/use_cases/update_subject_pages_use_case.dart";
import "package:timing/core/domain/use_cases/update_subject_time_use_case.dart";
import "package:timing/core/domain/use_cases/update_daily_task_use_case.dart";
import "package:timing/core/domain/use_cases/update_schedule_entry_use_case.dart";

class UseCasesBindings extends Bindings {
  @override
  void dependencies() {
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
    Get.put<GetProfileStatsUseCase>(
      GetProfileStatsUseCase(subjectsRepository: Get.find()),
      permanent: true,
    );
    Get.put<AddDailyTaskUseCase>(
      AddDailyTaskUseCase(dailyTasksRepository: Get.find()),
      permanent: true,
    );
    Get.put<UpdateDailyTaskUseCase>(
      UpdateDailyTaskUseCase(dailyTasksRepository: Get.find()),
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
    Get.put<ClearSubjectDataUseCase>(
      ClearSubjectDataUseCase(
        subjectsRepository: Get.find(),
        activityRepository: Get.find(),
        activityHistoryService: Get.find(),
        subjectDailyHistoryService: Get.find(),
        dailyProgressService: Get.find(),
        lastActivityService: Get.find(),
      ),
      permanent: true,
    );
    Get.put<AddSubjectTimeUseCase>(
      AddSubjectTimeUseCase(
        subjectsRepository: Get.find(),
        activityRepository: Get.find(),
        activityHistoryService: Get.find(),
        subjectDailyHistoryService: Get.find(),
        dailyProgressService: Get.find(),
        activityChangeBus: Get.find(),
      ),
      permanent: true,
    );
    Get.put<RemoveSubjectTimeUseCase>(
      RemoveSubjectTimeUseCase(
        subjectsRepository: Get.find(),
        activityRepository: Get.find(),
        activityHistoryService: Get.find(),
        subjectDailyHistoryService: Get.find(),
        dailyProgressService: Get.find(),
      ),
      permanent: true,
    );
    Get.put<AchievementUnlockService>(
      AchievementUnlockService(
        getProfileStatsUseCase: Get.find(),
        dailyTasksRepository: Get.find(),
        dailyProgressService: Get.find(),
        localStorageService: Get.find(),
      ),
      permanent: true,
    );
    Get.put<GoalReminderService>(
      GoalReminderService(
        dailyTasksRepository: Get.find(),
        notifications: LocalGoalReminderNotifications(),
        logger: Get.find(),
      )..start(),
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
    Get.put<UpdateScheduleEntryUseCase>(
      UpdateScheduleEntryUseCase(scheduleRepository: Get.find()),
      permanent: true,
    );
  }
}
