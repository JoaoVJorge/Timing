import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/entities/profile_stats_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/get_daily_tasks_use_case.dart";
import "package:timing/core/domain/use_cases/get_profile_stats_use_case.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/achievements/achievements_models.dart";

/// Everything the 50 achievement definitions are derived from. Records give
/// value equality for free, which is what makes the cache check cheap.
typedef _AchievementInputs = ({
  int focusMinutes,
  int totalSessions,
  int totalPages,
  int completedGoalDays,
  int activeDays,
  int studyingSeconds,
  int exercisesSeconds,
  int hobbiesSeconds,
  int focusGoalSeconds,
  bool hasTopStudyingSubject,
  bool hasGoal,
  bool hasCompletedGoal,
  bool allGoalsDoneToday,
});

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
    readingTotalSeconds: 0,
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

  /// Rebuilding the 50 definitions is expensive and the page reads this getter
  /// several times per frame, so the result is kept until an input changes.
  List<AchievementDefinition> _cachedAchievements = const [];
  _AchievementInputs? _cachedInputs;

  List<AchievementDefinition> get achievements {
    final _AchievementInputs inputs = _currentInputs;
    if (_cachedInputs == inputs) {
      return _cachedAchievements;
    }

    final List<AchievementDefinition> base = _baseAchievements(inputs);
    final int unlockedWithoutHunter = base
        .where((achievement) => achievement.isUnlocked)
        .length;

    _cachedInputs = inputs;
    _cachedAchievements = [
      ...base,
      _achievement(
        50,
        AchievementCategory.social,
        Icons.military_tech_rounded,
        unlockedWithoutHunter >= 25,
      ),
    ];
    return _cachedAchievements;
  }

  /// Reads every reactive source the definitions depend on, so `Obx` keeps
  /// tracking them even when the cached list is returned.
  _AchievementInputs get _currentInputs {
    dailyProgressService.today.value;
    final ProfileStatsEntity profileStats = stats.value;

    return (
      focusMinutes: profileStats.totalFocusSeconds ~/ 60,
      totalSessions: dailyProgressService.allProgress.fold<int>(
        0,
        (total, progress) => total + progress.sessions,
      ),
      totalPages: profileStats.readingTotalPages,
      completedGoalDays: tasks.fold<int>(
        0,
        (total, task) => total + task.completedDays,
      ),
      activeDays: activeDays,
      studyingSeconds: profileStats.studyingTotalSeconds,
      exercisesSeconds: profileStats.exercisesTotalSeconds,
      hobbiesSeconds: profileStats.hobbiesTotalSeconds,
      focusGoalSeconds: profileStats.totalFocusGoalSeconds,
      hasTopStudyingSubject: profileStats.hasTopStudyingSubject,
      hasGoal: tasks.isNotEmpty,
      hasCompletedGoal: tasks.any((task) => task.isCompleted),
      allGoalsDoneToday:
          tasks.isNotEmpty && tasks.every((task) => task.isDoneForCurrentCycle),
    );
  }

  List<AchievementDefinition> _baseAchievements(_AchievementInputs inputs) {
    final int focusMinutes = inputs.focusMinutes;
    final int totalSessions = inputs.totalSessions;
    final int totalPages = inputs.totalPages;
    final int completedGoalDays = inputs.completedGoalDays;
    final int activeDays = inputs.activeDays;
    final bool hasGoal = inputs.hasGoal;
    final bool hasCompletedGoal = inputs.hasCompletedGoal;
    final bool allGoalsDoneToday = inputs.allGoalsDoneToday;

    return [
      _achievement(
        1,
        AchievementCategory.focus,
        Icons.bolt_rounded,
        focusMinutes > 0,
      ),
      _achievement(
        2,
        AchievementCategory.focus,
        Icons.timer_rounded,
        focusMinutes >= 25,
      ),
      _achievement(
        3,
        AchievementCategory.focus,
        Icons.schedule_rounded,
        focusMinutes >= 60,
      ),
      _achievement(
        4,
        AchievementCategory.focus,
        Icons.psychology_rounded,
        focusMinutes >= 120,
      ),
      _achievement(
        5,
        AchievementCategory.focus,
        Icons.notifications_off_rounded,
        totalSessions >= 3,
      ),
      _achievement(
        6,
        AchievementCategory.focus,
        Icons.local_fire_department_rounded,
        focusMinutes >= 600,
      ),
      _achievement(
        7,
        AchievementCategory.focus,
        Icons.wb_sunny_rounded,
        activeDays >= 5,
      ),
      _achievement(
        8,
        AchievementCategory.focus,
        Icons.nights_stay_rounded,
        totalSessions >= 10,
      ),
      _achievement(
        9,
        AchievementCategory.focus,
        Icons.event_available_rounded,
        activeDays >= 7,
      ),
      _achievement(
        10,
        AchievementCategory.focus,
        Icons.workspace_premium_rounded,
        focusMinutes >= 1500,
      ),
      _achievement(
        11,
        AchievementCategory.study,
        Icons.menu_book_rounded,
        inputs.studyingSeconds > 0,
      ),
      _achievement(
        12,
        AchievementCategory.study,
        Icons.looks_3_rounded,
        totalSessions >= 3,
      ),
      _achievement(
        13,
        AchievementCategory.study,
        Icons.looks_5_rounded,
        totalSessions >= 5,
      ),
      _achievement(
        14,
        AchievementCategory.study,
        Icons.filter_9_plus_rounded,
        totalSessions >= 10,
      ),
      _achievement(
        15,
        AchievementCategory.study,
        Icons.search_rounded,
        inputs.hasTopStudyingSubject,
      ),
      _achievement(
        16,
        AchievementCategory.study,
        Icons.sync_rounded,
        inputs.studyingSeconds >= 18000,
      ),
      _achievement(
        17,
        AchievementCategory.study,
        Icons.quiz_rounded,
        totalSessions >= 15,
      ),
      _achievement(
        18,
        AchievementCategory.study,
        Icons.calendar_month_rounded,
        inputs.focusGoalSeconds > 0,
      ),
      _achievement(
        19,
        AchievementCategory.study,
        Icons.assignment_turned_in_rounded,
        inputs.studyingSeconds >= 72000,
      ),
      _achievement(
        20,
        AchievementCategory.study,
        Icons.emoji_events_rounded,
        inputs.studyingSeconds >= 180000,
      ),
      _achievement(
        21,
        AchievementCategory.reading,
        Icons.book_rounded,
        totalPages >= 1,
      ),
      _achievement(
        22,
        AchievementCategory.reading,
        Icons.auto_stories_rounded,
        totalPages >= 10,
      ),
      _achievement(
        23,
        AchievementCategory.reading,
        Icons.library_books_rounded,
        totalPages >= 25,
      ),
      _achievement(
        24,
        AchievementCategory.reading,
        Icons.chrome_reader_mode_rounded,
        totalPages >= 50,
      ),
      _achievement(
        25,
        AchievementCategory.reading,
        Icons.import_contacts_rounded,
        totalPages >= 100,
      ),
      _achievement(
        26,
        AchievementCategory.reading,
        Icons.bookmark_rounded,
        totalPages >= 150,
      ),
      _achievement(
        27,
        AchievementCategory.reading,
        Icons.light_mode_rounded,
        totalPages >= 250,
      ),
      _achievement(
        28,
        AchievementCategory.reading,
        Icons.today_rounded,
        totalPages >= 300,
      ),
      _achievement(
        29,
        AchievementCategory.reading,
        Icons.cable_rounded,
        totalPages >= 500,
      ),
      _achievement(
        30,
        AchievementCategory.reading,
        Icons.account_balance_rounded,
        totalPages >= 1000,
      ),
      _achievement(31, AchievementCategory.goals, Icons.flag_rounded, hasGoal),
      _achievement(
        32,
        AchievementCategory.goals,
        Icons.track_changes_rounded,
        hasCompletedGoal,
      ),
      _achievement(
        33,
        AchievementCategory.goals,
        Icons.celebration_rounded,
        allGoalsDoneToday,
      ),
      _achievement(
        34,
        AchievementCategory.goals,
        Icons.wb_twilight_rounded,
        completedGoalDays >= 3,
      ),
      _achievement(
        35,
        AchievementCategory.goals,
        Icons.balance_rounded,
        completedGoalDays >= 5,
      ),
      _achievement(
        36,
        AchievementCategory.goals,
        Icons.extension_rounded,
        completedGoalDays >= 10,
      ),
      _achievement(
        37,
        AchievementCategory.goals,
        Icons.star_border_rounded,
        completedGoalDays >= 15,
      ),
      _achievement(
        38,
        AchievementCategory.goals,
        Icons.keyboard_return_rounded,
        completedGoalDays >= 20,
      ),
      _achievement(
        39,
        AchievementCategory.goals,
        Icons.stars_rounded,
        completedGoalDays >= 30,
      ),
      _achievement(
        40,
        AchievementCategory.goals,
        Icons.rocket_launch_rounded,
        completedGoalDays >= 50,
      ),
      _achievement(41, AchievementCategory.social, Icons.groups_rounded, false),
      _achievement(
        42,
        AchievementCategory.social,
        Icons.handshake_rounded,
        false,
      ),
      _achievement(
        43,
        AchievementCategory.social,
        Icons.favorite_rounded,
        false,
      ),
      _achievement(
        44,
        AchievementCategory.social,
        Icons.emoji_events_rounded,
        false,
      ),
      _achievement(
        45,
        AchievementCategory.social,
        Icons.directions_run_rounded,
        inputs.exercisesSeconds > 0,
      ),
      _achievement(
        46,
        AchievementCategory.social,
        Icons.timer_rounded,
        inputs.exercisesSeconds >= 1800,
      ),
      _achievement(
        47,
        AchievementCategory.social,
        Icons.palette_rounded,
        inputs.hobbiesSeconds > 0,
      ),
      _achievement(
        48,
        AchievementCategory.social,
        Icons.lightbulb_rounded,
        inputs.hobbiesSeconds >= 1800,
      ),
      _achievement(
        49,
        AchievementCategory.social,
        Icons.sports_martial_arts_rounded,
        inputs.exercisesSeconds >= 7200,
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

  RankTier get currentTier => RankTierX.forLevel(level);

  int get levelXp => xp % 800;

  double get levelProgress => levelXp / 800;

  AchievementDefinition _achievement(
    int id,
    AchievementCategory category,
    IconData icon,
    bool isUnlocked,
  ) {
    final l10n = Get.context!.l10n;
    return AchievementDefinition(
      id: id,
      category: category,
      icon: icon,
      color: category.color,
      title: achievementTitleForId(l10n, id),
      description: _localizedDescription(l10n, id),
      isUnlocked: isUnlocked,
    );
  }
}

String achievementTitleForId(AppLocalizations l10n, int id) => switch (id) {
  1 => l10n.achievement1Title,
  2 => l10n.achievement2Title,
  3 => l10n.achievement3Title,
  4 => l10n.achievement4Title,
  5 => l10n.achievement5Title,
  6 => l10n.achievement6Title,
  7 => l10n.achievement7Title,
  8 => l10n.achievement8Title,
  9 => l10n.achievement9Title,
  10 => l10n.achievement10Title,
  11 => l10n.achievement11Title,
  12 => l10n.achievement12Title,
  13 => l10n.achievement13Title,
  14 => l10n.achievement14Title,
  15 => l10n.achievement15Title,
  16 => l10n.achievement16Title,
  17 => l10n.achievement17Title,
  18 => l10n.achievement18Title,
  19 => l10n.achievement19Title,
  20 => l10n.achievement20Title,
  21 => l10n.achievement21Title,
  22 => l10n.achievement22Title,
  23 => l10n.achievement23Title,
  24 => l10n.achievement24Title,
  25 => l10n.achievement25Title,
  26 => l10n.achievement26Title,
  27 => l10n.achievement27Title,
  28 => l10n.achievement28Title,
  29 => l10n.achievement29Title,
  30 => l10n.achievement30Title,
  31 => l10n.achievement31Title,
  32 => l10n.achievement32Title,
  33 => l10n.achievement33Title,
  34 => l10n.achievement34Title,
  35 => l10n.achievement35Title,
  36 => l10n.achievement36Title,
  37 => l10n.achievement37Title,
  38 => l10n.achievement38Title,
  39 => l10n.achievement39Title,
  40 => l10n.achievement40Title,
  41 => l10n.achievement41Title,
  42 => l10n.achievement42Title,
  43 => l10n.achievement43Title,
  44 => l10n.achievement44Title,
  45 => l10n.achievement45Title,
  46 => l10n.achievement46Title,
  47 => l10n.achievement47Title,
  48 => l10n.achievement48Title,
  49 => l10n.achievement49Title,
  50 => l10n.achievement50Title,
  _ => l10n.profileAchievementLocked,
};

String _localizedDescription(AppLocalizations l10n, int id) => switch (id) {
  1 => l10n.achievement1Description,
  2 => l10n.achievement2Description,
  3 => l10n.achievement3Description,
  4 => l10n.achievement4Description,
  5 => l10n.achievement5Description,
  6 => l10n.achievement6Description,
  7 => l10n.achievement7Description,
  8 => l10n.achievement8Description,
  9 => l10n.achievement9Description,
  10 => l10n.achievement10Description,
  11 => l10n.achievement11Description,
  12 => l10n.achievement12Description,
  13 => l10n.achievement13Description,
  14 => l10n.achievement14Description,
  15 => l10n.achievement15Description,
  16 => l10n.achievement16Description,
  17 => l10n.achievement17Description,
  18 => l10n.achievement18Description,
  19 => l10n.achievement19Description,
  20 => l10n.achievement20Description,
  21 => l10n.achievement21Description,
  22 => l10n.achievement22Description,
  23 => l10n.achievement23Description,
  24 => l10n.achievement24Description,
  25 => l10n.achievement25Description,
  26 => l10n.achievement26Description,
  27 => l10n.achievement27Description,
  28 => l10n.achievement28Description,
  29 => l10n.achievement29Description,
  30 => l10n.achievement30Description,
  31 => l10n.achievement31Description,
  32 => l10n.achievement32Description,
  33 => l10n.achievement33Description,
  34 => l10n.achievement34Description,
  35 => l10n.achievement35Description,
  36 => l10n.achievement36Description,
  37 => l10n.achievement37Description,
  38 => l10n.achievement38Description,
  39 => l10n.achievement39Description,
  40 => l10n.achievement40Description,
  41 => l10n.achievement41Description,
  42 => l10n.achievement42Description,
  43 => l10n.achievement43Description,
  44 => l10n.achievement44Description,
  45 => l10n.achievement45Description,
  46 => l10n.achievement46Description,
  47 => l10n.achievement47Description,
  48 => l10n.achievement48Description,
  49 => l10n.achievement49Description,
  50 => l10n.achievement50Description,
  _ => l10n.profileAchievementsStartHint,
};

extension AchievementCategoryX on AchievementCategory {
  Color get color => switch (this) {
    AchievementCategory.focus => const Color(0xFFE9A900),
    AchievementCategory.study => const Color(0xFF7867E8),
    AchievementCategory.reading => const Color(0xFF35B96F),
    AchievementCategory.goals => const Color(0xFFE8862E),
    AchievementCategory.social => const Color(0xFFEC4899),
  };

  String label(BuildContext context) => switch (this) {
    AchievementCategory.focus => context.l10n.achievementCategoryFocus,
    AchievementCategory.study => context.l10n.achievementCategoryStudy,
    AchievementCategory.reading => context.l10n.achievementCategoryReading,
    AchievementCategory.goals => context.l10n.achievementCategoryGoals,
    AchievementCategory.social => context.l10n.achievementCategoryLifestyle,
  };
}
