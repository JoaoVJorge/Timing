import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/domain/entities/profile_stats_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/get_daily_tasks_use_case.dart";
import "package:help_out/core/domain/use_cases/get_profile_stats_use_case.dart";
import "package:help_out/core/services/daily_progress/daily_progress_service.dart";

enum ProfilePeriod { fiveDays, week, month }

class ProfileController extends GetxController {
  ProfileController({
    required this._getProfileStatsUseCase,
    required this._getDailyTasksUseCase,
    required this._dailyProgressService,
    required this._appNavigator,
  });

  final GetProfileStatsUseCase _getProfileStatsUseCase;
  final GetDailyTasksUseCase _getDailyTasksUseCase;
  final DailyProgressService _dailyProgressService;
  final AppNavigator _appNavigator;

  final Rx<ProfileStatsEntity> stats = const ProfileStatsEntity(
    studyingTotalSeconds: 0,
    studyingGoalSeconds: 0,
    exercisesTotalSeconds: 0,
    exercisesGoalSeconds: 0,
    hobbiesTotalSeconds: 0,
    readingTotalPages: 0,
    readingGoalPages: 0,
    topStudyingSubject: null,
    topReadingSubjects: [],
  ).obs;
  final RxList<DailyTaskEntity> tasks = <DailyTaskEntity>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<ProfilePeriod> selectedPeriod = ProfilePeriod.week.obs;

  bool get hasGoalStarted =>
      tasks.any((task) => task.completedDays > 0 || task.isCheckedToday);

  bool get hasValidFirstFocus => stats.value.totalFocusSeconds >= 60;

  bool get hasAnyUnlockedAchievement {
    final ProfileStatsEntity currentStats = stats.value;
    return hasValidFirstFocus ||
        hasGoalStarted ||
        currentStats.studyingTotalSeconds > 0 ||
        currentStats.exercisesTotalSeconds > 0 ||
        currentStats.hobbiesTotalSeconds > 0 ||
        currentStats.readingTotalPages > 0;
  }

  List<int> get evolutionFocusSeconds {
    _dailyProgressService.today.value;
    return _dailyProgressService
        .progressForLastDays(selectedPeriod.value.dayCount)
        .map((progress) => progress.focusSeconds)
        .toList();
  }

  int get selectedPeriodFocusSeconds {
    _dailyProgressService.today.value;
    return _dailyProgressService
        .progressForLastDays(selectedPeriod.value.dayCount)
        .fold(0, (total, progress) => total + progress.focusSeconds);
  }

  int get selectedPeriodPages {
    _dailyProgressService.today.value;
    return _dailyProgressService
        .progressForLastDays(selectedPeriod.value.dayCount)
        .fold(0, (total, progress) => total + progress.pages);
  }

  int get selectedPeriodSessions {
    _dailyProgressService.today.value;
    return _dailyProgressService
        .progressForLastDays(selectedPeriod.value.dayCount)
        .fold(0, (total, progress) => total + progress.sessions);
  }

  int get totalSessions {
    _dailyProgressService.today.value;
    return _dailyProgressService.allProgress.fold(
      0,
      (total, progress) => total + progress.sessions,
    );
  }

  int get activeDays {
    _dailyProgressService.today.value;
    return _dailyProgressService.allProgress
        .where((progress) => !progress.isEmpty)
        .length;
  }

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    final Either<AppError, ProfileStatsEntity> statsResult =
        await _getProfileStatsUseCase();
    final Either<AppError, List<DailyTaskEntity>> tasksResult =
        await _getDailyTasksUseCase();

    statsResult.fold((error) => null, (value) => stats.value = value);
    tasksResult.fold((error) => null, (value) => tasks.assignAll(value));
    isLoading.value = false;
  }

  Future<void> onTapAchievements() =>
      _navigateAndRefresh(AppRoutes.achievements);

  Future<void> onTapFriends() async =>
      _appNavigator.toNamed(AppRoutes.friends, id: 1);

  void onSelectPeriod(ProfilePeriod period) => selectedPeriod.value = period;

  Future<void> _navigateAndRefresh(String route, {Object? arguments}) async {
    await (_appNavigator.toNamed(route, arguments: arguments) ??
        Future<void>.value());
    await loadStats();
  }
}

extension ProfilePeriodX on ProfilePeriod {
  int get dayCount => switch (this) {
    ProfilePeriod.fiveDays => 1,
    ProfilePeriod.week => 7,
    ProfilePeriod.month => 30,
  };
}
