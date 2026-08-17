import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/app/route_arguments.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/delete_daily_task_use_case.dart";
import "package:timing/core/domain/use_cases/get_daily_tasks_use_case.dart";
import "package:timing/core/domain/use_cases/toggle_daily_task_check_use_case.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/services/last_activity/last_activity_service.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/delete_confirmation_dialog.dart";

class DailyGoalsController extends GetxController {
  DailyGoalsController({
    required this._appNavigator,
    required this._getDailyTasksUseCase,
    required this._toggleDailyTaskCheckUseCase,
    required this._deleteDailyTaskUseCase,
    required this._lastActivityService,
    required this._achievementUnlockService,
  });

  final AppNavigator _appNavigator;
  final GetDailyTasksUseCase _getDailyTasksUseCase;
  final ToggleDailyTaskCheckUseCase _toggleDailyTaskCheckUseCase;
  final DeleteDailyTaskUseCase _deleteDailyTaskUseCase;
  final LastActivityService _lastActivityService;
  final AchievementUnlockService _achievementUnlockService;

  final RxList<DailyTaskEntity> tasks = <DailyTaskEntity>[].obs;

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
    final Either<AppError, List<DailyTaskEntity>> result =
        await _getDailyTasksUseCase();
    result.fold((error) => null, (loadedTasks) {
      tasks.value = loadedTasks;
      _askAboutMissedYesterday();
    });
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
      _askAboutMissedYesterday();
    }
  }

  Future<void> onEditTask(DailyTaskEntity task) async {
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
    final Either<AppError, DailyTaskEntity> result =
        await _toggleDailyTaskCheckUseCase(taskId: task.id);

    result.fold((error) => _appNavigator.showErrorSnackBar(), (updatedTask) {
      final int index = tasks.indexWhere((item) => item.id == updatedTask.id);
      if (index != -1) {
        tasks[index] = updatedTask;
      }
      if (updatedTask.isCheckedToday) {
        _lastActivityService.record(updatedTask.name);
      }
      _achievementUnlockService.checkForNewUnlocks();
    });
  }

  Future<void> _askAboutMissedYesterday() async {
    final BuildContext? context = Get.context;
    if (context == null) {
      return;
    }

    final DateTime now = DateTime.now();
    final DailyTaskEntity? task = tasks.firstWhereOrNull(
      (task) => task.shouldAskAboutMissedYesterday(now),
    );
    if (task == null) {
      return;
    }

    final DateTime yesterday = now.subtract(const Duration(days: 1));
    final String missedDate = DailyTaskEntity.dateKey(yesterday);
    final bool? didComplete = await _appNavigator.dialog<bool>(
      child: _MissedYesterdayDialog(taskName: task.name),
      barrierDismissible: false,
    );
    if (didComplete == null) {
      return;
    }

    final Either<AppError, DailyTaskEntity> result =
        await _toggleDailyTaskCheckUseCase(
          taskId: task.id,
          date: didComplete ? yesterday : null,
          resolvedMissedDate: missedDate,
          toggleDate: didComplete,
        );

    result.fold((error) => _appNavigator.showErrorSnackBar(), (updatedTask) {
      final int index = tasks.indexWhere((item) => item.id == updatedTask.id);
      if (index != -1) {
        tasks[index] = updatedTask;
      }
      _achievementUnlockService.checkForNewUnlocks();
    });
  }

  Future<void> onDeleteTask(DailyTaskEntity task) async {
    final bool confirmed = await showDeleteConfirmationDialog(
      itemName: task.name,
      itemTypeName: _goalTypeName,
    );
    if (!confirmed) {
      return;
    }

    tasks.removeWhere((item) => item.id == task.id);
    await _deleteDailyTaskUseCase(taskId: task.id);
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
