import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/entities/daily_progress_entity.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/domain/entities/last_activity_entity.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/get_daily_tasks_use_case.dart";
import "package:help_out/core/domain/use_cases/get_subjects_use_case.dart";
import "package:help_out/core/services/daily_progress/daily_progress_service.dart";
import "package:help_out/core/services/last_activity/last_activity_service.dart";
import "package:help_out/presentation/schedule/schedule_controller.dart";

class HomeController extends GetxController {
  HomeController({
    required this._appController,
    required this._appNavigator,
    required this._lastActivityService,
    required this._dailyProgressService,
    required this._getSubjectsUseCase,
    required this._getDailyTasksUseCase,
    required this._scheduleController,
  });

  final AppController _appController;
  final AppNavigator _appNavigator;
  final LastActivityService _lastActivityService;
  final DailyProgressService _dailyProgressService;
  final GetSubjectsUseCase _getSubjectsUseCase;
  final GetDailyTasksUseCase _getDailyTasksUseCase;
  final ScheduleController _scheduleController;

  final RxList<SubjectEntity> subjects = <SubjectEntity>[].obs;
  final RxList<DailyTaskEntity> dailyTasks = <DailyTaskEntity>[].obs;

  RxString get userName => _appController.userName;

  Rx<LastActivityEntity?> get lastActivity => _lastActivityService.lastActivity;

  Rx<DailyProgressEntity> get todayProgress => _dailyProgressService.today;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final Either<AppError, List<SubjectEntity>> subjectsResult =
        await _getSubjectsUseCase();
    subjectsResult.fold((error) {
      subjects.clear();
      _appNavigator.showErrorSnackBar(error.message);
    }, (value) => subjects.value = value);

    final Either<AppError, List<DailyTaskEntity>> tasksResult =
        await _getDailyTasksUseCase();
    tasksResult.fold((error) {
      dailyTasks.clear();
      _appNavigator.showErrorSnackBar(error.message);
    }, (value) => dailyTasks.value = value);

    await _scheduleController.loadEntries();
  }

  bool get hasSubjects => subjects.isNotEmpty;

  /// Subject behind the last recorded activity, when it can be resumed.
  SubjectEntity? get resumableSubject {
    final LastActivityEntity? activity = lastActivity.value;
    if (activity == null || !activity.isResumable) {
      return null;
    }
    return subjects.firstWhereOrNull((s) => s.id == activity.subjectId);
  }

  /// The subject with the most accumulated time, suggested as a starting point
  /// when there is nothing to resume.
  SubjectEntity? get suggestedSubject {
    if (subjects.isEmpty) {
      return null;
    }
    return subjects.reduce(
      (best, current) =>
          current.totalSeconds > best.totalSeconds ? current : best,
    );
  }

  int get goalsDoneToday =>
      dailyTasks.where((task) => task.isCheckedToday).length;

  int get goalsTotal => dailyTasks.length;

  int focusSecondsIn(TimeCategoryType category) => subjects
      .where((s) => s.category == category)
      .fold(0, (sum, s) => sum + s.totalSeconds);

  int pagesIn(TimeCategoryType category) => subjects
      .where((s) => s.category == category)
      .fold(0, (sum, s) => sum + s.currentPages);

  bool hasSubjectsIn(TimeCategoryType category) =>
      subjects.any((s) => s.category == category);

  List<ScheduleEntryEntity> get todayScheduleEntries =>
      _scheduleController.todayEntries;

  /// Next schedule slot still to come today, if any.
  ScheduleEntryEntity? get nextTodayEntry {
    final DateTime now = DateTime.now();
    final int nowMinutes = now.hour * 60 + now.minute;
    final List<ScheduleEntryEntity> upcoming =
        todayScheduleEntries.where((e) => e.startMinutes >= nowMinutes).toList()
          ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  Future<void> onTapCategory(TimeCategoryType category) =>
      _navigateAndRefresh(AppRoutes.category, arguments: category);

  Future<void> onTapDailyGoals() => _navigateAndRefresh(AppRoutes.dailyGoals);

  Future<void> onContinue() {
    final SubjectEntity? subject = resumableSubject;
    if (subject == null) {
      return Future<void>.value();
    }
    return _navigateAndRefresh(AppRoutes.timer, arguments: subject);
  }

  Future<void> onStartSuggested() {
    final SubjectEntity? subject = suggestedSubject;
    if (subject == null) {
      return Future<void>.value();
    }
    return _navigateAndRefresh(AppRoutes.timer, arguments: subject);
  }

  Future<void> onCreateFirstSubject() => _navigateAndRefresh(
    AppRoutes.category,
    arguments: TimeCategoryType.studying,
  );

  Future<void> onTapSchedule() => _navigateAndRefresh(AppRoutes.schedule);

  Future<void> onAddScheduleEntry() async {
    await _scheduleController.onTapAddEntry();
    await load();
  }

  Future<void> _navigateAndRefresh(String route, {Object? arguments}) async {
    await (_appNavigator.toNamed(route, arguments: arguments) ??
        Future<void>.value());
    await load();
  }
}
