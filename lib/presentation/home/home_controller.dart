import "dart:async";

import "package:flutter/material.dart";
import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/core/domain/entities/daily_progress_entity.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/entities/last_activity_entity.dart";
import "package:timing/core/domain/entities/schedule_entry_entity.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/get_daily_tasks_use_case.dart";
import "package:timing/core/domain/use_cases/get_subjects_use_case.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/services/home_widget/home_widget_service.dart";
import "package:timing/core/services/last_activity/last_activity_service.dart";
import "package:timing/presentation/schedule/schedule_controller.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/extensions/enum_localization_extensions.dart";

class HomeController extends GetxController {
  HomeController({
    required this._appController,
    required this._appNavigator,
    required this._lastActivityService,
    required this._dailyProgressService,
    required this._subjectDailyHistoryService,
    required this._getSubjectsUseCase,
    required this._getDailyTasksUseCase,
    required this._scheduleController,
    required this._achievementUnlockService,
    required this._homeWidgetService,
  });

  final AppController _appController;
  final AppNavigator _appNavigator;
  final LastActivityService _lastActivityService;
  final DailyProgressService _dailyProgressService;
  final SubjectDailyHistoryService _subjectDailyHistoryService;
  final GetSubjectsUseCase _getSubjectsUseCase;
  final GetDailyTasksUseCase _getDailyTasksUseCase;
  final ScheduleController _scheduleController;
  final AchievementUnlockService _achievementUnlockService;
  final HomeWidgetService _homeWidgetService;

  final RxList<SubjectEntity> subjects = <SubjectEntity>[].obs;
  final RxList<DailyTaskEntity> dailyTasks = <DailyTaskEntity>[].obs;

  RxString get userName => _appController.userName;

  Rx<LastActivityEntity?> get lastActivity => _lastActivityService.lastActivity;

  Rx<DailyProgressEntity> get todayProgress => _dailyProgressService.today;

  /// Consecutive days of studying, surfaced as a streak on Home.
  RxInt get currentStreak => _dailyProgressService.currentStreak;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({
    bool reloadSchedule = true,
    bool reloadDailyTasks = true,
  }) async {
    final Either<AppError, List<SubjectEntity>> subjectsResult =
        await _getSubjectsUseCase();
    subjectsResult.fold((error) {
      subjects.clear();
      _appNavigator.showErrorSnackBar(error.message);
    }, (value) => subjects.value = value);

    // Daily tasks only change on the Daily Goals screen, so most returns to Home
    // keep the in-memory list instead of re-fetching it on every navigation.
    if (reloadDailyTasks) {
      final Either<AppError, List<DailyTaskEntity>> tasksResult =
          await _getDailyTasksUseCase();
      tasksResult.fold((error) {
        dailyTasks.clear();
        _appNavigator.showErrorSnackBar(error.message);
      }, (value) => dailyTasks.value = value);
    }

    if (reloadSchedule) {
      await _scheduleController.loadEntries();
    }
    await _achievementUnlockService.initializeBaselineIfNeeded();
    unawaited(_syncHomeWidget());
  }

  Future<void> _syncHomeWidget() => _homeWidgetService.updateFocusToday(
    focusSeconds: todayProgress.value.focusSeconds,
    goalsDone: goalsDoneToday,
    goalsTotal: goalsTotal,
  );

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
      dailyTasks.where((task) => task.isDoneForCurrentCycle).length;

  int get goalsTotal => dailyTasks.length;

  int focusSecondsIn(TimeCategoryType category) => subjects
      .where((s) => s.category == category)
      .fold(0, (sum, s) => sum + _focusSecondsForTodayCard(s));

  int pagesIn(TimeCategoryType category) => subjects
      .where((s) => s.category == category)
      .fold(0, (sum, s) => sum + _pagesForTodayCard(s));

  bool hasSubjectsIn(TimeCategoryType category) =>
      subjects.any((s) => s.category == category);

  String emptyCategoryValue(BuildContext context, TimeCategoryType category) {
    final String item = category.itemNoun(context).toLowerCase();
    return context.l10n.homeCategoryEmptyValue(item);
  }

  /// Most-tracked subject of a category, used as the tile's "what you were
  /// working on" line.
  SubjectEntity? topSubjectIn(TimeCategoryType category) {
    final List<SubjectEntity> inCategory = subjects
        .where((s) => s.category == category)
        .toList();
    if (inCategory.isEmpty) {
      return null;
    }
    return inCategory.reduce(
      (best, current) =>
          current.totalSeconds > best.totalSeconds ? current : best,
    );
  }

  int _focusSecondsForTodayCard(SubjectEntity subject) =>
      _subjectDailyHistoryService.todayForSubject(subject.id).focusSeconds;

  int _pagesForTodayCard(SubjectEntity subject) =>
      _subjectDailyHistoryService.todayForSubject(subject.id).pages;

  List<ScheduleEntryEntity> get todayScheduleEntries =>
      _scheduleController.todayEntries;

  /// Next schedule slot still to come today, if any.
  ScheduleEntryEntity? get nextTodayEntry {
    final DateTime now = DateTime.now();
    final int nowMinutes = now.hour * 60 + now.minute;
    final List<ScheduleEntryEntity> upcoming =
        todayScheduleEntries
            .where(
              (e) => e.startMinutes != null && e.startMinutes! >= nowMinutes,
            )
            .toList()
          ..sort((a, b) => a.startMinutes!.compareTo(b.startMinutes!));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  Future<void> onTapCategory(TimeCategoryType category) => _navigateAndRefresh(
    AppRoutes.category,
    arguments: category,
    reloadSchedule: false,
  );

  Future<void> onTapDailyGoals() => _navigateAndRefresh(
    AppRoutes.dailyGoals,
    reloadSchedule: false,
    reloadDailyTasks: true,
  );

  Future<void> onContinue() {
    final SubjectEntity? subject = resumableSubject;
    if (subject == null) {
      return Future<void>.value();
    }
    return _navigateAndRefresh(
      AppRoutes.timer,
      arguments: subject,
      reloadSchedule: false,
    );
  }

  Future<void> onStartSuggested() {
    final SubjectEntity? subject = suggestedSubject;
    if (subject == null) {
      return Future<void>.value();
    }
    return _navigateAndRefresh(
      AppRoutes.timer,
      arguments: subject,
      reloadSchedule: false,
    );
  }

  Future<void> onCreateFirstSubject() => _navigateAndRefresh(
    AppRoutes.category,
    arguments: TimeCategoryType.studying,
    reloadSchedule: false,
  );

  Future<void> onTapSchedule() => _navigateAndRefresh(AppRoutes.schedule);

  /// The schedule only changes on the routes that can edit it, so screens that
  /// cannot touch it skip re-reading and re-decoding the stored entries.
  Future<void> _navigateAndRefresh(
    String route, {
    Object? arguments,
    bool reloadSchedule = true,
    bool reloadDailyTasks = false,
  }) async {
    await (_appNavigator.toNamed(route, arguments: arguments) ??
        Future<void>.value());
    await load(
      reloadSchedule: reloadSchedule,
      reloadDailyTasks: reloadDailyTasks,
    );
  }
}
