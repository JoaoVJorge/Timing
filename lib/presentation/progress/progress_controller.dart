import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/core/domain/entities/daily_progress_entity.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/entities/profile_stats_entity.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/get_daily_tasks_use_case.dart";
import "package:timing/core/domain/use_cases/get_profile_stats_use_case.dart";
import "package:timing/core/domain/use_cases/get_subjects_use_case.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";

enum ProgressPeriod { day, week, month }

class ProgressController extends GetxController {
  ProgressController({
    required this._getProfileStatsUseCase,
    required this._getDailyTasksUseCase,
    required this._getSubjectsUseCase,
    required this._dailyProgressService,
    required this._activityHistoryService,
    required this._appNavigator,
  });

  final GetProfileStatsUseCase _getProfileStatsUseCase;
  final GetDailyTasksUseCase _getDailyTasksUseCase;
  final GetSubjectsUseCase _getSubjectsUseCase;
  final DailyProgressService _dailyProgressService;
  final ActivityHistoryService _activityHistoryService;
  final AppNavigator _appNavigator;

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
  final RxList<SubjectEntity> subjects = <SubjectEntity>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<ProgressPeriod> selectedPeriod = ProgressPeriod.week.obs;

  ProgressPeriod? _cachedPeriod;
  DailyProgressEntity? _cachedToday;
  List<DailyProgressEntity> _cachedCurrentPeriod = const [];
  List<DailyProgressEntity> _cachedPreviousPeriod = const [];

  bool get hasGoalStarted =>
      tasks.any((task) => task.completedDays > 0 || task.isDoneForCurrentCycle);

  bool get hasValidFirstFocus => stats.value.totalFocusSeconds >= 60;

  int get goalsDone => tasks.where((task) => task.isDoneForCurrentCycle).length;

  List<int> get evolutionFocusSeconds =>
      _currentPeriod.map((progress) => progress.focusSeconds).toList();

  int get selectedPeriodFocusSeconds => _sumFocus(_currentPeriod);

  int get previousPeriodFocusSeconds => _sumFocus(_previousPeriod);

  /// `null` when there is nothing earlier to compare against, so the UI can say
  /// "your first data here" instead of claiming a meaningless +100%.
  int? get focusDifferenceToPreviousPeriod {
    if (_previousPeriod.every((progress) => progress.isEmpty)) {
      return null;
    }
    return selectedPeriodFocusSeconds - previousPeriodFocusSeconds;
  }

  int get selectedPeriodPages =>
      _currentPeriod.fold(0, (total, progress) => total + progress.pages);

  int get selectedPeriodSessions =>
      _currentPeriod.fold(0, (total, progress) => total + progress.sessions);

  int selectedPeriodSecondsFor(TimeCategoryType category) {
    final (DateTime start, DateTime end) = _selectedPeriodWindow;
    final int historyValue = _activityHistoryService.secondsBetween(
      start,
      end,
      category: category,
    );
    if (historyValue > 0) {
      return historyValue;
    }
    if (category == TimeCategoryType.studying) {
      return selectedPeriodFocusSeconds;
    }
    return 0;
  }

  int get selectedPeriodReadingPages {
    final (DateTime start, DateTime end) = _selectedPeriodWindow;
    final int historyValue = _activityHistoryService.pagesBetween(
      start,
      end,
      category: TimeCategoryType.reading,
    );
    return historyValue > 0 ? historyValue : selectedPeriodPages;
  }

  bool hasActivityFor(TimeCategoryType category) =>
      subjects.any((subject) => subject.category == category);

  int selectedPeriodGoalSecondsFor(TimeCategoryType category) {
    final List<SubjectEntity> categorySubjects = subjects
        .where((subject) => subject.category == category)
        .toList();
    return categorySubjects.fold(
      0,
      (total, subject) =>
          total +
          subject.totalGoalSeconds * _activeDaysInSelectedPeriod(subject),
    );
  }

  int get selectedPeriodReadingGoalPages {
    final List<SubjectEntity> readingSubjects = subjects
        .where((subject) => subject.category == TimeCategoryType.reading)
        .toList();
    return readingSubjects.fold(
      0,
      (total, subject) =>
          total + subject.goalPages * _activeDaysInSelectedPeriod(subject),
    );
  }

  DailyTaskEntity? get longestGoal {
    final List<DailyTaskEntity> finiteTasks = tasks
        .where((task) => !task.hasInfiniteTarget)
        .toList();
    final List<DailyTaskEntity> source = finiteTasks.isEmpty
        ? tasks.toList()
        : finiteTasks;
    if (source.isEmpty) {
      return null;
    }
    return source.reduce((a, b) => b.targetDays > a.targetDays ? b : a);
  }

  SubjectEntity? get mainReadingSubject {
    final List<SubjectEntity> readings = stats.value.topReadingSubjects;
    return readings.isEmpty ? null : readings.first;
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

  /// The selected window plus the one immediately before it, oldest first.
  List<DailyProgressEntity> get _currentPeriod {
    _refreshPeriodCacheIfNeeded();
    return _cachedCurrentPeriod;
  }

  List<DailyProgressEntity> get _previousPeriod {
    _refreshPeriodCacheIfNeeded();
    return _cachedPreviousPeriod;
  }

  (DateTime start, DateTime end) get _selectedPeriodWindow {
    final DateTime now = DateTime.now();
    final DateTime todayStart = DateTime(now.year, now.month, now.day);
    final DateTime start = todayStart.subtract(
      Duration(days: selectedPeriod.value.dayCount - 1),
    );
    return (start, todayStart.add(const Duration(days: 1)));
  }

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    try {
      final statsFuture = _getProfileStatsUseCase();
      final tasksFuture = _getDailyTasksUseCase();
      final subjectsFuture = _getSubjectsUseCase();

      final Either<AppError, ProfileStatsEntity> statsResult =
          await statsFuture;
      final Either<AppError, List<DailyTaskEntity>> tasksResult =
          await tasksFuture;
      final Either<AppError, List<SubjectEntity>> subjectsResult =
          await subjectsFuture;

      statsResult.fold((error) => null, (value) => stats.value = value);
      tasksResult.fold((error) => null, (value) => tasks.assignAll(value));
      subjectsResult.fold(
        (error) => null,
        (value) => subjects.assignAll(value),
      );
      _invalidatePeriodCache();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onTapAchievements() =>
      _navigateAndRefresh(AppRoutes.achievements);

  void onSelectPeriod(ProgressPeriod period) {
    if (selectedPeriod.value == period) {
      return;
    }
    selectedPeriod.value = period;
    _invalidatePeriodCache();
  }

  void _refreshPeriodCacheIfNeeded() {
    final ProgressPeriod period = selectedPeriod.value;
    final DailyProgressEntity today = _dailyProgressService.today.value;
    if (_cachedPeriod == period && identical(_cachedToday, today)) {
      return;
    }

    final int dayCount = period.dayCount;
    final List<DailyProgressEntity> both = _dailyProgressService
        .progressForLastDays(dayCount * 2);
    _cachedPeriod = period;
    _cachedToday = today;
    _cachedPreviousPeriod = List.unmodifiable(both.take(dayCount));
    _cachedCurrentPeriod = List.unmodifiable(both.skip(dayCount));
  }

  void _invalidatePeriodCache() {
    _cachedPeriod = null;
    _cachedToday = null;
  }

  int _sumFocus(List<DailyProgressEntity> period) =>
      period.fold(0, (total, progress) => total + progress.focusSeconds);

  int _activeDaysInSelectedPeriod(SubjectEntity subject) {
    final (DateTime periodStart, DateTime periodEnd) = _selectedPeriodWindow;
    final DateTime subjectStart = _startOfDay(
      subject.createdAt ?? _firstEntryDateForSubject(subject.id) ?? periodStart,
    );
    final DateTime activeStart = subjectStart.isAfter(periodStart)
        ? subjectStart
        : periodStart;
    if (!activeStart.isBefore(periodEnd)) {
      return 0;
    }
    return periodEnd.difference(activeStart).inDays;
  }

  DateTime? _firstEntryDateForSubject(String subjectId) {
    DateTime? first;
    for (final entry in _activityHistoryService.all) {
      if (entry.subjectId != subjectId) {
        continue;
      }
      if (first == null || entry.timestamp.isBefore(first)) {
        first = entry.timestamp;
      }
    }
    return first;
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<void> _navigateAndRefresh(String route, {Object? arguments}) async {
    await (_appNavigator.toNamed(route, arguments: arguments) ??
        Future<void>.value());
  }
}

extension ProgressPeriodX on ProgressPeriod {
  int get dayCount => switch (this) {
    ProgressPeriod.day => 1,
    ProgressPeriod.week => 7,
    ProgressPeriod.month => 30,
  };
}
