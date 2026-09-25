import "dart:async";

import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/app/route_arguments.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/clear_daily_task_data_use_case.dart";
import "package:timing/core/domain/use_cases/delete_daily_task_use_case.dart";
import "package:timing/core/domain/use_cases/get_daily_tasks_use_case.dart";
import "package:timing/core/domain/use_cases/toggle_daily_task_check_use_case.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/services/last_activity/last_activity_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/daily_goals/widgets/missed_yesterday_multi_dialog.dart";
import "package:timing/shared/widgets/clear_data_confirmation_dialog.dart";
import "package:timing/shared/widgets/delete_confirmation_dialog.dart";

class DailyGoalsController extends GetxController {
  DailyGoalsController({
    required this._appNavigator,
    required this._getDailyTasksUseCase,
    required this._toggleDailyTaskCheckUseCase,
    required this._deleteDailyTaskUseCase,
    required this._clearDailyTaskDataUseCase,
    required this._lastActivityService,
    required this._achievementUnlockService,
    required this._activityChangeBus,
    this._confirmDelete = showDeleteConfirmationDialog,
    this._confirmClearData = showClearDataConfirmationDialog,
  });

  final AppNavigator _appNavigator;
  final GetDailyTasksUseCase _getDailyTasksUseCase;
  final ToggleDailyTaskCheckUseCase _toggleDailyTaskCheckUseCase;
  final DeleteDailyTaskUseCase _deleteDailyTaskUseCase;
  final ClearDailyTaskDataUseCase _clearDailyTaskDataUseCase;
  final LastActivityService _lastActivityService;
  final AchievementUnlockService _achievementUnlockService;
  final ActivityChangeBus _activityChangeBus;
  final DeleteConfirmationCallback _confirmDelete;
  final ClearDataConfirmationCallback _confirmClearData;

  final RxList<DailyTaskEntity> tasks = <DailyTaskEntity>[].obs;
  final RxBool isLoading = true.obs;
  final Set<String> _togglingTaskIds = <String>{};

  List<DailyTaskEntity> get pendingTasks =>
      tasks.where((task) => !task.isDoneForCurrentCycle).toList();

  List<DailyTaskEntity> get completedTasks =>
      tasks.where((task) => task.isDoneForCurrentCycle).toList();

  int get doneTodayCount =>
      tasks.where((task) => task.isDoneForCurrentCycle).length;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    isLoading.value = true;
    try {
      final Either<AppError, List<DailyTaskEntity>> result =
          await _getDailyTasksUseCase();
      result.fold((error) => null, (loadedTasks) {
        tasks.value = loadedTasks;
        _scheduleMissedYesterdayPrompt();
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onTapAddTask() => _openCreateTask();

  Future<void> onTapSuggestion(String suggestion) =>
      _openCreateTask(initialName: suggestion);

  Future<void> _openCreateTask({String? initialName}) async {
    final dynamic result = await _appNavigator.toNamed(
      AppRoutes.createTask,
      arguments: initialName == null
          ? null
          : CreateTaskRouteArguments(initialName: initialName),
    );
    final DailyTaskEntity? createdTask = result as DailyTaskEntity?;
    if (createdTask != null) {
      tasks.add(createdTask);
      unawaited(_askAboutMissedYesterday());
    }
  }

  Future<void> onEditTask(DailyTaskEntity task) async {
    if (task.isFromGroup) {
      _appNavigator.showErrorSnackBar(
        Get.context?.l10n.groupGoalEditBlockedMessage,
      );
      return;
    }

    final dynamic result = await _appNavigator.toNamed(
      AppRoutes.createTask,
      arguments: task,
    );
    final DailyTaskEntity? updatedTask = result as DailyTaskEntity?;
    if (updatedTask == null) {
      return;
    }
    final int index = tasks.indexWhere((item) => item.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
    }
  }

  Future<void> onToggleTask(DailyTaskEntity task) async {
    if (!_togglingTaskIds.add(task.id)) {
      return;
    }

    try {
      final int originalIndex = tasks.indexWhere((item) => item.id == task.id);
      if (originalIndex == -1) {
        return;
      }
      final DailyTaskEntity originalTask = tasks[originalIndex];

      final DateTime toggleDate = DateTime.now();
      tasks[originalIndex] = originalTask.copyWith(
        completedDates: originalTask.completedDatesAfterToggle(toggleDate),
        updatedAt: DateTime.now().toUtc(),
      );

      late final Either<AppError, DailyTaskEntity> result;
      try {
        result = await _toggleDailyTaskCheckUseCase(
          taskId: task.id,
          date: toggleDate,
        );
      } catch (_) {
        _restoreTask(originalTask);
        _appNavigator.showErrorSnackBar();
        return;
      }

      result.fold(
        (error) {
          _restoreTask(originalTask);
          _appNavigator.showErrorSnackBar();
        },
        (updatedTask) {
          final int index = tasks.indexWhere(
            (item) => item.id == updatedTask.id,
          );
          if (index != -1) {
            tasks[index] = updatedTask;
          }
          if (updatedTask.isCheckedToday) {
            unawaited(_lastActivityService.record(updatedTask.name));
          }
          if (updatedTask.isFromGroup) {
            _activityChangeBus.notifyGroupActivityChanged(
              groupId: updatedTask.groupId,
            );
          }
          unawaited(_achievementUnlockService.checkForNewUnlocks());
        },
      );
    } finally {
      _togglingTaskIds.remove(task.id);
    }
  }

  void _restoreTask(DailyTaskEntity task) {
    final int index = tasks.indexWhere((item) => item.id == task.id);
    if (index != -1) {
      tasks[index] = task;
    }
  }

  void _scheduleMissedYesterdayPrompt() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed) {
        return;
      }
      unawaited(_askAboutMissedYesterday());
    });
  }

  Future<void> _askAboutMissedYesterday() async {
    final BuildContext? context = Get.context;
    if (context == null) {
      return;
    }

    final DateTime now = DateTime.now();
    final List<DailyTaskEntity> missedTasks = tasks
        .where((task) => task.shouldAskAboutMissedYesterday(now))
        .toList();
    if (missedTasks.isEmpty) {
      return;
    }

    final DateTime yesterday = now.subtract(const Duration(days: 1));
    final String missedDate = DailyTaskEntity.dateKey(yesterday);

    final Set<String>? completedTaskIds = missedTasks.length == 1
        ? await _askAboutSingleMissedTask(missedTasks.first)
        : await _askAboutMultipleMissedTasks(missedTasks);
    if (completedTaskIds == null) {
      return;
    }

    bool didUnlockCheck = false;
    for (final DailyTaskEntity missedTask in missedTasks) {
      final bool didComplete = completedTaskIds.contains(missedTask.id);
      final Either<AppError, DailyTaskEntity> result =
          await _toggleDailyTaskCheckUseCase(
            taskId: missedTask.id,
            date: didComplete ? yesterday : null,
            resolvedMissedDate: missedDate,
            toggleDate: didComplete,
          );

      result.fold((error) => _appNavigator.showErrorSnackBar(), (updatedTask) {
        final int index = tasks.indexWhere((item) => item.id == updatedTask.id);
        if (index != -1) {
          tasks[index] = updatedTask;
        }
        if (updatedTask.isFromGroup) {
          _activityChangeBus.notifyGroupActivityChanged(
            groupId: updatedTask.groupId,
          );
        }
        didUnlockCheck = true;
      });
    }

    if (didUnlockCheck) {
      unawaited(_achievementUnlockService.checkForNewUnlocks());
    }
  }

  Future<Set<String>?> _askAboutSingleMissedTask(DailyTaskEntity task) async {
    final bool? didComplete = await _appNavigator.dialog<bool>(
      child: _MissedYesterdayDialog(taskName: task.name),
      barrierDismissible: false,
    );
    if (didComplete == null) {
      return null;
    }
    return didComplete ? <String>{task.id} : <String>{};
  }

  Future<Set<String>?> _askAboutMultipleMissedTasks(
    List<DailyTaskEntity> missedTasks,
  ) => _appNavigator.dialog<Set<String>>(
    child: MissedYesterdayMultiDialog(tasks: missedTasks),
    barrierDismissible: false,
  );

  Future<void> onDeleteTask(DailyTaskEntity task) async {
    if (task.isFromGroup) {
      _appNavigator.showErrorSnackBar(
        Get.context?.l10n.groupGoalDeleteBlockedMessage,
      );
      return;
    }

    final bool confirmed = await _confirmDelete(
      itemName: task.name,
      itemTypeName: _goalTypeName,
    );
    if (!confirmed) {
      return;
    }

    final List<DailyTaskEntity> previousTasks = List.of(tasks);
    tasks.removeWhere((item) => item.id == task.id);
    final Either<AppError, void> result = await _deleteDailyTaskUseCase(
      taskId: task.id,
    );
    result.fold((error) {
      tasks.value = previousTasks;
      _appNavigator.showErrorSnackBar(error.message);
    }, (_) {});
  }

  /// Wipes the days marked on a goal but keeps the goal. For a group goal this
  /// is also what takes the user's share out of the group ranking.
  Future<void> onClearTaskData(DailyTaskEntity task) async {
    if (!_togglingTaskIds.add(task.id)) {
      return;
    }

    try {
      final bool confirmed = await _confirmClearData(
        itemName: task.name,
        isGoal: true,
        isFromGroup: task.isFromGroup,
      );
      final int index = tasks.indexWhere((item) => item.id == task.id);
      if (!confirmed || index == -1) {
        return;
      }

      final DailyTaskEntity previousTask = tasks[index];
      tasks[index] = previousTask.copyWith(
        completedDates: const [],
        updatedAt: DateTime.now().toUtc(),
      );
      final Either<AppError, DailyTaskEntity> result =
          await _clearDailyTaskDataUseCase(taskId: task.id);
      result.fold(
        (error) {
          _restoreTask(previousTask);
          _appNavigator.showErrorSnackBar(error.message);
        },
        (clearedTask) {
          final int clearedIndex = tasks.indexWhere(
            (item) => item.id == clearedTask.id,
          );
          if (clearedIndex != -1) {
            tasks[clearedIndex] = clearedTask;
          }
          if (clearedTask.isFromGroup) {
            _activityChangeBus.notifyGroupActivityChanged(
              groupId: clearedTask.groupId,
            );
          }
          _appNavigator.showSuccessSnackBar(
            Get.context?.l10n.clearDataSuccessMessage ?? "Data deleted.",
          );
        },
      );
    } finally {
      _togglingTaskIds.remove(task.id);
    }
  }

  String? get _goalTypeName {
    final context = Get.context;
    if (context == null) {
      return null;
    }
    return context.l10n.goalTypeName;
  }
}

class _MissedYesterdayDialog extends StatelessWidget {
  const _MissedYesterdayDialog({required this.taskName});

  final String taskName;

  @override
  Widget build(BuildContext context) {
    final Color accent = context.colorTokens.primary;

    return Dialog(
      elevation: 0,
      backgroundColor: context.colorTokens.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 34),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 390),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        decoration: BoxDecoration(
          color: context.colorTokens.dialogSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.colorTokens.black.withValues(alpha: 0.16),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history_rounded, color: accent, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.missedYesterdayDialogTitle,
              textAlign: TextAlign.center,
              style: context.textStyles.extraBold24.copyWith(
                color: context.colorTokens.dialogText,
                fontSize: 21,
                height: 1.12,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.missedYesterdayDialogContent(taskName),
              textAlign: TextAlign.center,
              style: context.textStyles.bodyLarge.copyWith(
                color: context.colorTokens.dialogTextMuted,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.38,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _MissedDialogButton(
                    label: context.l10n.missedYesterdayMissedButton,
                    foreground: accent,
                    borderColor: accent,
                    onTap: () => _appNavigatorBack(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MissedDialogButton(
                    label: context.l10n.missedYesterdayCompletedButton,
                    foreground: context.colorTokens.white,
                    background: accent,
                    onTap: () => _appNavigatorBack(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _appNavigatorBack(bool result) {
    appNavigator.back<bool>(result: result);
  }
}

class _MissedDialogButton extends StatelessWidget {
  const _MissedDialogButton({
    required this.label,
    required this.foreground,
    required this.onTap,
    this.borderColor,
    this.background,
  });

  final String label;
  final Color foreground;
  final VoidCallback onTap;
  final Color? borderColor;
  final Color? background;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodyLarge.copyWith(
          color: foreground,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
