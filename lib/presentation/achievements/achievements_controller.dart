import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/domain/entities/profile_stats_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/get_daily_tasks_use_case.dart";
import "package:help_out/core/domain/use_cases/get_profile_stats_use_case.dart";
import "package:help_out/core/services/daily_progress/daily_progress_service.dart";
import "package:help_out/presentation/achievements/achievements_models.dart";

class AchievementsController extends GetxController {
  AchievementsController({
    required this.getProfileStatsUseCase,
    required this.getDailyTasksUseCase,
    required this.dailyProgressService,
    required this.appNavigator,
  });

  final GetProfileStatsUseCase getProfileStatsUseCase;
  final GetDailyTasksUseCase getDailyTasksUseCase;
  final DailyProgressService dailyProgressService;
  final AppNavigator appNavigator;

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
  final Rx<AchievementFilter> selectedFilter = AchievementFilter.all.obs;
  final Rxn<AchievementCategory> selectedCategory = Rxn<AchievementCategory>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    final Either<AppError, ProfileStatsEntity> statsResult =
        await getProfileStatsUseCase();
    final Either<AppError, List<DailyTaskEntity>> tasksResult =
        await getDailyTasksUseCase();

    statsResult.fold((error) => null, (value) => stats.value = value);
    tasksResult.fold((error) => null, (value) => tasks.assignAll(value));
    isLoading.value = false;
  }

  void onBack() => appNavigator.back<void>();

  void onSelectFilter(AchievementFilter filter) =>
      selectedFilter.value = filter;

  void onSelectCategory(AchievementCategory? category) =>
      selectedCategory.value = category;

  void toggleCategoryFilter() {
    final List<AchievementCategory?> options = [
      null,
      ...AchievementCategory.values,
    ];
    final int nextIndex =
        (options.indexOf(selectedCategory.value) + 1) % options.length;
    selectedCategory.value = options[nextIndex];
  }

  List<AchievementDefinition> get achievements {
    dailyProgressService.today.value;
    final List<AchievementDefinition> base = _baseAchievements;
    final int unlockedWithoutHunter = base
        .where((achievement) => achievement.isUnlocked)
        .length;

    return [
      ...base,
      _achievement(
        50,
        AchievementCategory.social,
        Icons.military_tech_rounded,
        "Achievement Hunter",
        "Unlock 25 achievements",
        unlockedWithoutHunter >= 25,
      ),
    ];
  }

  List<AchievementDefinition> get _baseAchievements {
    final ProfileStatsEntity currentStats = stats.value;
    final int focusMinutes = currentStats.totalFocusSeconds ~/ 60;
    final int totalSessions = dailyProgressService.allProgress.fold<int>(
      0,
      (total, progress) => total + progress.sessions,
    );
    final int totalPages = currentStats.readingTotalPages;
    final int completedGoalDays = tasks.fold<int>(
      0,
      (total, task) => total + task.completedDays,
    );
    final bool hasGoal = tasks.isNotEmpty;
    final bool hasCompletedGoal = tasks.any((task) => task.isCompleted);
    final bool allGoalsDoneToday =
        tasks.isNotEmpty && tasks.every((task) => task.isCheckedToday);

    return [
      _achievement(
        1,
        AchievementCategory.focus,
        Icons.bolt_rounded,
        "First Focus",
        "Complete your first focus session",
        focusMinutes > 0,
      ),
      _achievement(
        2,
        AchievementCategory.focus,
        Icons.timer_rounded,
        "25-Min Starter",
        "Focus for 25 minutes",
        focusMinutes >= 25,
      ),
      _achievement(
        3,
        AchievementCategory.focus,
        Icons.schedule_rounded,
        "1-Hour Focus",
        "Focus for 1 hour",
        focusMinutes >= 60,
      ),
      _achievement(
        4,
        AchievementCategory.focus,
        Icons.psychology_rounded,
        "Deep Work",
        "Reach 2 hours of focus",
        focusMinutes >= 120,
      ),
      _achievement(
        5,
        AchievementCategory.focus,
        Icons.notifications_off_rounded,
        "Zero Distractions",
        "Complete 3 focus sessions",
        totalSessions >= 3,
      ),
      _achievement(
        6,
        AchievementCategory.focus,
        Icons.local_fire_department_rounded,
        "Focus Marathon",
        "Reach 10 hours of focus",
        focusMinutes >= 600,
      ),
      _achievement(
        7,
        AchievementCategory.focus,
        Icons.wb_sunny_rounded,
        "Early Bird",
        "Log focus on 5 days",
        activeDays >= 5,
      ),
      _achievement(
        8,
        AchievementCategory.focus,
        Icons.nights_stay_rounded,
        "Night Owl",
        "Complete 10 focus sessions",
        totalSessions >= 10,
      ),
      _achievement(
        9,
        AchievementCategory.focus,
        Icons.event_available_rounded,
        "Focus Streak",
        "Log focus on 7 days",
        activeDays >= 7,
      ),
      _achievement(
        10,
        AchievementCategory.focus,
        Icons.workspace_premium_rounded,
        "Focus Master",
        "Reach 25 hours of focus",
        focusMinutes >= 1500,
      ),
      _achievement(
        11,
        AchievementCategory.study,
        Icons.menu_book_rounded,
        "Study Started",
        "Create your first study record",
        currentStats.studyingTotalSeconds > 0,
      ),
      _achievement(
        12,
        AchievementCategory.study,
        Icons.looks_3_rounded,
        "3 Sessions",
        "Complete 3 sessions",
        totalSessions >= 3,
      ),
      _achievement(
        13,
        AchievementCategory.study,
        Icons.looks_5_rounded,
        "5 Sessions",
        "Complete 5 sessions",
        totalSessions >= 5,
      ),
      _achievement(
        14,
        AchievementCategory.study,
        Icons.filter_9_plus_rounded,
        "10 Sessions",
        "Complete 10 sessions",
        totalSessions >= 10,
      ),
      _achievement(
        15,
        AchievementCategory.study,
        Icons.search_rounded,
        "Subject Explorer",
        "Study at least one subject",
        currentStats.hasTopStudyingSubject,
      ),
      _achievement(
        16,
        AchievementCategory.study,
        Icons.sync_rounded,
        "Revision Hero",
        "Reach 5 hours studying",
        currentStats.studyingTotalSeconds >= 18000,
      ),
      _achievement(
        17,
        AchievementCategory.study,
        Icons.quiz_rounded,
        "Quiz Finisher",
        "Complete 15 sessions",
        totalSessions >= 15,
      ),
      _achievement(
        18,
        AchievementCategory.study,
        Icons.calendar_month_rounded,
        "Study Planner",
        "Create a focus goal",
        currentStats.totalFocusGoalSeconds > 0,
      ),
      _achievement(
        19,
        AchievementCategory.study,
        Icons.assignment_turned_in_rounded,
        "Exam Ready",
        "Reach 20 hours studying",
        currentStats.studyingTotalSeconds >= 72000,
      ),
      _achievement(
        20,
        AchievementCategory.study,
        Icons.emoji_events_rounded,
        "Scholar Mode",
        "Reach 50 hours studying",
        currentStats.studyingTotalSeconds >= 180000,
      ),
      _achievement(
        21,
        AchievementCategory.reading,
        Icons.book_rounded,
        "First Page",
        "Read your first page",
        totalPages >= 1,
      ),
      _achievement(
        22,
        AchievementCategory.reading,
        Icons.auto_stories_rounded,
        "10 Pages",
        "Read 10 pages",
        totalPages >= 10,
      ),
      _achievement(
        23,
        AchievementCategory.reading,
        Icons.library_books_rounded,
        "25 Pages",
        "Read 25 pages",
        totalPages >= 25,
      ),
      _achievement(
        24,
        AchievementCategory.reading,
        Icons.chrome_reader_mode_rounded,
        "50 Pages",
        "Read 50 pages",
        totalPages >= 50,
      ),
      _achievement(
        25,
        AchievementCategory.reading,
        Icons.import_contacts_rounded,
        "100 Pages",
        "Read 100 pages",
        totalPages >= 100,
      ),
      _achievement(
        26,
        AchievementCategory.reading,
        Icons.bookmark_rounded,
        "Chapter Complete",
        "Read 150 pages",
        totalPages >= 150,
      ),
      _achievement(
        27,
        AchievementCategory.reading,
        Icons.light_mode_rounded,
        "Weekend Reader",
        "Read 250 pages",
        totalPages >= 250,
      ),
      _achievement(
        28,
        AchievementCategory.reading,
        Icons.today_rounded,
        "Daily Reader",
        "Read 300 pages",
        totalPages >= 300,
      ),
      _achievement(
        29,
        AchievementCategory.reading,
        Icons.cable_rounded,
        "Bookworm",
        "Read 500 pages",
        totalPages >= 500,
      ),
      _achievement(
        30,
        AchievementCategory.reading,
        Icons.account_balance_rounded,
        "Library Legend",
        "Read 1000 pages",
        totalPages >= 1000,
      ),
      _achievement(
        31,
        AchievementCategory.goals,
        Icons.flag_rounded,
        "First Goal",
        "Create your first goal",
        hasGoal,
      ),
      _achievement(
        32,
        AchievementCategory.goals,
        Icons.track_changes_rounded,
        "Goal Crusher",
        "Complete a goal",
        hasCompletedGoal,
      ),
      _achievement(
        33,
        AchievementCategory.goals,
        Icons.celebration_rounded,
        "All Goals Done",
        "Finish every goal today",
        allGoalsDoneToday,
      ),
      _achievement(
        34,
        AchievementCategory.goals,
        Icons.wb_twilight_rounded,
        "Morning Routine",
        "Complete goals on 3 days",
        completedGoalDays >= 3,
      ),
      _achievement(
        35,
        AchievementCategory.goals,
        Icons.balance_rounded,
        "Balanced Day",
        "Complete goals on 5 days",
        completedGoalDays >= 5,
      ),
      _achievement(
        36,
        AchievementCategory.goals,
        Icons.extension_rounded,
        "Habit Builder",
        "Complete goals on 10 days",
        completedGoalDays >= 10,
      ),
      _achievement(
        37,
        AchievementCategory.goals,
        Icons.star_border_rounded,
        "Perfect Day",
        "Complete goals on 15 days",
        completedGoalDays >= 15,
      ),
      _achievement(
        38,
        AchievementCategory.goals,
        Icons.keyboard_return_rounded,
        "Comeback",
        "Complete goals on 20 days",
        completedGoalDays >= 20,
      ),
      _achievement(
        39,
        AchievementCategory.goals,
        Icons.stars_rounded,
        "Consistency Star",
        "Complete goals on 30 days",
        completedGoalDays >= 30,
      ),
      _achievement(
        40,
        AchievementCategory.goals,
        Icons.rocket_launch_rounded,
        "Unstoppable",
        "Complete goals on 50 days",
        completedGoalDays >= 50,
      ),
      _achievement(
        41,
        AchievementCategory.social,
        Icons.groups_rounded,
        "First Group",
        "Join a study group",
        false,
      ),
      _achievement(
        42,
        AchievementCategory.social,
        Icons.handshake_rounded,
        "Team Player",
        "Compete with friends",
        false,
      ),
      _achievement(
        43,
        AchievementCategory.social,
        Icons.favorite_rounded,
        "Helpful Friend",
        "Help a friend stay consistent",
        false,
      ),
      _achievement(
        44,
        AchievementCategory.social,
        Icons.emoji_events_rounded,
        "Challenge Winner",
        "Win a challenge",
        false,
      ),
      _achievement(
        45,
        AchievementCategory.social,
        Icons.directions_run_rounded,
        "Exercise Start",
        "Log exercise focus",
        currentStats.exercisesTotalSeconds > 0,
      ),
      _achievement(
        46,
        AchievementCategory.social,
        Icons.timer_rounded,
        "30-Min Workout",
        "Exercise for 30 minutes",
        currentStats.exercisesTotalSeconds >= 1800,
      ),
      _achievement(
        47,
        AchievementCategory.social,
        Icons.palette_rounded,
        "Hobby Time",
        "Log hobby focus",
        currentStats.hobbiesTotalSeconds > 0,
      ),
      _achievement(
        48,
        AchievementCategory.social,
        Icons.lightbulb_rounded,
        "Creative Spark",
        "Reach 30 minutes of hobbies",
        currentStats.hobbiesTotalSeconds >= 1800,
      ),
      _achievement(
        49,
        AchievementCategory.social,
        Icons.sports_martial_arts_rounded,
        "Weekend Warrior",
        "Reach 2 hours exercising",
        currentStats.exercisesTotalSeconds >= 7200,
      ),
    ];
  }

  int get activeDays => dailyProgressService.allProgress
      .where((progress) => progress.focusSeconds > 0)
      .length;

  int get unlockedCount =>
      achievements.where((achievement) => achievement.isUnlocked).length;

  List<AchievementDefinition> get filteredAchievements {
    Iterable<AchievementDefinition> result = achievements;
    final AchievementCategory? category = selectedCategory.value;
    if (category != null) {
      result = result.where((achievement) => achievement.category == category);
    }
    return switch (selectedFilter.value) {
      AchievementFilter.unlocked =>
        result.where((achievement) => achievement.isUnlocked).toList(),
      AchievementFilter.locked =>
        result.where((achievement) => !achievement.isUnlocked).toList(),
      AchievementFilter.all => result.toList(),
    };
  }

  AchievementDefinition? get nextUnlock =>
      achievements.firstWhereOrNull((achievement) => !achievement.isUnlocked);

  int get xp => unlockedCount * 80;

  int get level => (xp ~/ 800) + 1;

  int get levelXp => xp % 800;

  double get levelProgress => levelXp / 800;

  AchievementDefinition _achievement(
    int id,
    AchievementCategory category,
    IconData icon,
    String title,
    String description,
    bool isUnlocked,
  ) => AchievementDefinition(
    id: id,
    category: category,
    icon: icon,
    color: category.color,
    title: title,
    description: description,
    isUnlocked: isUnlocked,
  );
}

extension AchievementCategoryX on AchievementCategory {
  Color get color => switch (this) {
    AchievementCategory.focus => const Color(0xFFE9A900),
    AchievementCategory.study => const Color(0xFF7867E8),
    AchievementCategory.reading => const Color(0xFF35B96F),
    AchievementCategory.goals => const Color(0xFFE8862E),
    AchievementCategory.social => const Color(0xFFEC4899),
  };

  String label(BuildContext context) => switch (this) {
    AchievementCategory.focus => "Focus",
    AchievementCategory.study => "Study",
    AchievementCategory.reading => "Reading",
    AchievementCategory.goals => "Goals",
    AchievementCategory.social => "Lifestyle",
  };
}
