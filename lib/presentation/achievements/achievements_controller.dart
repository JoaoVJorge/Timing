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
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/achievements/achievements_models.dart";

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
  String languageCode,
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

  void toggleCategoryFilter() {
    final List<AchievementCategory?> options = [
      null,
      ...AchievementCategory.values,
    ];
    final int nextIndex =
        (options.indexOf(selectedCategory.value) + 1) % options.length;
    selectedCategory.value = options[nextIndex];
  }

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
        "Achievement Hunter",
        "Unlock 25 achievements",
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
          tasks.isNotEmpty && tasks.every((task) => task.isCheckedToday),
      languageCode: _languageCode,
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
        inputs.studyingSeconds > 0,
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
        inputs.hasTopStudyingSubject,
      ),
      _achievement(
        16,
        AchievementCategory.study,
        Icons.sync_rounded,
        "Revision Hero",
        "Reach 5 hours studying",
        inputs.studyingSeconds >= 18000,
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
        inputs.focusGoalSeconds > 0,
      ),
      _achievement(
        19,
        AchievementCategory.study,
        Icons.assignment_turned_in_rounded,
        "Exam Ready",
        "Reach 20 hours studying",
        inputs.studyingSeconds >= 72000,
      ),
      _achievement(
        20,
        AchievementCategory.study,
        Icons.emoji_events_rounded,
        "Scholar Mode",
        "Reach 50 hours studying",
        inputs.studyingSeconds >= 180000,
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
        inputs.exercisesSeconds > 0,
      ),
      _achievement(
        46,
        AchievementCategory.social,
        Icons.timer_rounded,
        "30-Min Workout",
        "Exercise for 30 minutes",
        inputs.exercisesSeconds >= 1800,
      ),
      _achievement(
        47,
        AchievementCategory.social,
        Icons.palette_rounded,
        "Hobby Time",
        "Log hobby focus",
        inputs.hobbiesSeconds > 0,
      ),
      _achievement(
        48,
        AchievementCategory.social,
        Icons.lightbulb_rounded,
        "Creative Spark",
        "Reach 30 minutes of hobbies",
        inputs.hobbiesSeconds >= 1800,
      ),
      _achievement(
        49,
        AchievementCategory.social,
        Icons.sports_martial_arts_rounded,
        "Weekend Warrior",
        "Reach 2 hours exercising",
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
    String title,
    String description,
    bool isUnlocked,
  ) => AchievementDefinition(
    id: id,
    category: category,
    icon: icon,
    color: category.color,
    title: _localizedTitle(id, title),
    description: _localizedDescription(id, description),
    isUnlocked: isUnlocked,
  );

  String get _languageCode => Get.context?.languageCode ?? "en";

  String _localizedTitle(int id, String fallback) => switch (_languageCode) {
    "pt" => _ptTitles[id] ?? fallback,
    "es" => _esTitles[id] ?? fallback,
    _ => fallback,
  };

  String _localizedDescription(int id, String fallback) =>
      switch (_languageCode) {
        "pt" => _ptDescriptions[id] ?? fallback,
        "es" => _esDescriptions[id] ?? fallback,
        _ => fallback,
      };
}

const Map<int, String> _ptTitles = {
  1: "Primeiro foco",
  2: "Começo de 25 min",
  3: "1 hora de foco",
  4: "Foco profundo",
  5: "Zero distrações",
  6: "Maratona de foco",
  7: "Madrugador",
  8: "Coruja da noite",
  9: "Sequência de foco",
  10: "Mestre do foco",
  11: "Estudo iniciado",
  12: "3 sessões",
  13: "5 sessões",
  14: "10 sessões",
  15: "Explorador de matérias",
  16: "Herói da revisão",
  17: "Quiz finalizado",
  18: "Planejador de estudos",
  19: "Pronto para prova",
  20: "Modo estudante",
  21: "Primeira página",
  22: "10 páginas",
  23: "25 páginas",
  24: "50 páginas",
  25: "100 páginas",
  26: "Capítulo completo",
  27: "Leitor de fim de semana",
  28: "Leitor diário",
  29: "Leitor dedicado",
  30: "Lenda da biblioteca",
  31: "Primeira meta",
  32: "Meta vencida",
  33: "Todas as metas feitas",
  34: "Rotina da manhã",
  35: "Dia equilibrado",
  36: "Construtor de hábito",
  37: "Dia perfeito",
  38: "Retomada",
  39: "Estrela da constância",
  40: "Imparável",
  41: "Primeiro grupo",
  42: "Jogador em equipe",
  43: "Amigo prestativo",
  44: "Vencedor de desafio",
  45: "Exercício iniciado",
  46: "Treino de 30 min",
  47: "Hora do hobby",
  48: "Faísca criativa",
  49: "Guerreiro do fim de semana",
  50: "Caçador de conquistas",
};

const Map<int, String> _ptDescriptions = {
  1: "Conclua sua primeira sessão de foco",
  2: "Foque por 25 minutos",
  3: "Foque por 1 hora",
  4: "Alcance 2 horas de foco",
  5: "Conclua 3 sessões de foco",
  6: "Alcance 10 horas de foco",
  7: "Registre foco em 5 dias",
  8: "Conclua 10 sessões de foco",
  9: "Registre foco em 7 dias",
  10: "Alcance 25 horas de foco",
  11: "Crie seu primeiro registro de estudo",
  12: "Conclua 3 sessões",
  13: "Conclua 5 sessões",
  14: "Conclua 10 sessões",
  15: "Estude pelo menos uma matéria",
  16: "Alcance 5 horas estudando",
  17: "Conclua 15 sessões",
  18: "Crie uma meta de foco",
  19: "Alcance 20 horas estudando",
  20: "Alcance 50 horas estudando",
  21: "Leia sua primeira página",
  22: "Leia 10 páginas",
  23: "Leia 25 páginas",
  24: "Leia 50 páginas",
  25: "Leia 100 páginas",
  26: "Leia 150 páginas",
  27: "Leia 250 páginas",
  28: "Leia 300 páginas",
  29: "Leia 500 páginas",
  30: "Leia 1000 páginas",
  31: "Crie sua primeira meta",
  32: "Conclua uma meta",
  33: "Finalize todas as metas hoje",
  34: "Conclua metas em 3 dias",
  35: "Conclua metas em 5 dias",
  36: "Conclua metas em 10 dias",
  37: "Conclua metas em 15 dias",
  38: "Conclua metas em 20 dias",
  39: "Conclua metas em 30 dias",
  40: "Conclua metas em 50 dias",
  41: "Entre em um grupo de estudos",
  42: "Compita com amigos",
  43: "Ajude um amigo a manter constância",
  44: "Vença um desafio",
  45: "Registre foco em exercício",
  46: "Exercite-se por 30 minutos",
  47: "Registre foco em hobby",
  48: "Alcance 30 minutos em hobbies",
  49: "Alcance 2 horas se exercitando",
  50: "Desbloqueie 25 conquistas",
};

const Map<int, String> _esTitles = {
  1: "Primer enfoque",
  2: "Inicio de 25 min",
  3: "1 hora de enfoque",
  4: "Enfoque profundo",
  5: "Cero distracciones",
  6: "Maratón de enfoque",
  7: "Madrugador",
  8: "Nocturno",
  9: "Racha de enfoque",
  10: "Maestro del enfoque",
  11: "Estudio iniciado",
  12: "3 sesiones",
  13: "5 sesiones",
  14: "10 sesiones",
  15: "Explorador de materias",
  16: "Héroe de revisión",
  17: "Quiz finalizado",
  18: "Planificador de estudios",
  19: "Listo para el examen",
  20: "Modo estudiante",
  21: "Primera página",
  22: "10 páginas",
  23: "25 páginas",
  24: "50 páginas",
  25: "100 páginas",
  26: "Capítulo completo",
  27: "Lector de fin de semana",
  28: "Lector diario",
  29: "Lector dedicado",
  30: "Leyenda de biblioteca",
  31: "Primera meta",
  32: "Meta lograda",
  33: "Todas las metas hechas",
  34: "Rutina de mañana",
  35: "Día equilibrado",
  36: "Constructor de hábito",
  37: "Día perfecto",
  38: "Regreso",
  39: "Estrella constante",
  40: "Imparable",
  41: "Primer grupo",
  42: "Jugador de equipo",
  43: "Amigo servicial",
  44: "Ganador de desafío",
  45: "Ejercicio iniciado",
  46: "Entreno de 30 min",
  47: "Hora del hobby",
  48: "Chispa creativa",
  49: "Guerrero de fin de semana",
  50: "Cazador de logros",
};

const Map<int, String> _esDescriptions = {
  1: "Completa tu primera sesión de enfoque",
  2: "Enfócate durante 25 minutos",
  3: "Enfócate durante 1 hora",
  4: "Alcanza 2 horas de enfoque",
  5: "Completa 3 sesiones de enfoque",
  6: "Alcanza 10 horas de enfoque",
  7: "Registra enfoque en 5 días",
  8: "Completa 10 sesiones de enfoque",
  9: "Registra enfoque en 7 días",
  10: "Alcanza 25 horas de enfoque",
  11: "Crea tu primer registro de estudio",
  12: "Completa 3 sesiones",
  13: "Completa 5 sesiones",
  14: "Completa 10 sesiones",
  15: "Estudia al menos una materia",
  16: "Alcanza 5 horas estudiando",
  17: "Completa 15 sesiones",
  18: "Crea una meta de enfoque",
  19: "Alcanza 20 horas estudiando",
  20: "Alcanza 50 horas estudiando",
  21: "Lee tu primera página",
  22: "Lee 10 páginas",
  23: "Lee 25 páginas",
  24: "Lee 50 páginas",
  25: "Lee 100 páginas",
  26: "Lee 150 páginas",
  27: "Lee 250 páginas",
  28: "Lee 300 páginas",
  29: "Lee 500 páginas",
  30: "Lee 1000 páginas",
  31: "Crea tu primera meta",
  32: "Completa una meta",
  33: "Termina todas las metas hoy",
  34: "Completa metas en 3 días",
  35: "Completa metas en 5 días",
  36: "Completa metas en 10 días",
  37: "Completa metas en 15 días",
  38: "Completa metas en 20 días",
  39: "Completa metas en 30 días",
  40: "Completa metas en 50 días",
  41: "Únete a un grupo de estudio",
  42: "Compite con amigos",
  43: "Ayuda a un amigo a ser constante",
  44: "Gana un desafío",
  45: "Registra enfoque en ejercicio",
  46: "Haz ejercicio durante 30 minutos",
  47: "Registra enfoque en hobby",
  48: "Alcanza 30 minutos en hobbies",
  49: "Alcanza 2 horas de ejercicio",
  50: "Desbloquea 25 logros",
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
    AchievementCategory.focus => switch (context.languageCode) {
      "pt" => "Foco",
      "es" => "Enfoque",
      _ => "Focus",
    },
    AchievementCategory.study => switch (context.languageCode) {
      "pt" => "Estudo",
      "es" => "Estudio",
      _ => "Study",
    },
    AchievementCategory.reading => switch (context.languageCode) {
      "pt" => "Leitura",
      "es" => "Lectura",
      _ => "Reading",
    },
    AchievementCategory.goals => switch (context.languageCode) {
      "pt" => "Metas",
      "es" => "Metas",
      _ => "Goals",
    },
    AchievementCategory.social => switch (context.languageCode) {
      "pt" => "Estilo de vida",
      "es" => "Estilo de vida",
      _ => "Lifestyle",
    },
  };
}
