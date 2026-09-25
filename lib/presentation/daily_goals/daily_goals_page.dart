import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/daily_goals/daily_goals_controller.dart";
import "package:timing/presentation/daily_goals/widgets/add_task_tile.dart";
import "package:timing/presentation/daily_goals/widgets/daily_task_tile.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_skeleton.dart";
import "package:timing/shared/widgets/app_section_header.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/illustrated_empty_state.dart";
import "package:timing/shared/widgets/swipe_hint_button.dart";
import "package:timing/theme/app_spacing.dart";

class DailyGoalsPage extends StatelessWidget {
  const DailyGoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DailyGoalsController controller = Get.find();

    return AppScaffold(
      topBar: AppTopBar(
        title: context.l10n.homeTasksSection,
        showBackButton: true,
        trailing: SwipeHintButton(
          title: context.l10n.dailyGoalSwipeHintTitle,
          message: context.l10n.dailyGoalSwipeHintMessage,
        ),
      ),
      body: Obx(() {
        final List<DailyTaskEntity> pending = controller.pendingTasks;
        final List<DailyTaskEntity> completed = controller.completedTasks;

        if (controller.isLoading.value && controller.tasks.isEmpty) {
          return const _DailyGoalsLoadingSkeleton();
        }

        if (controller.tasks.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: AppSpacing.betweenRelated,
                bottom: AppSpacing.betweenSections,
              ),
              child: IllustratedEmptyState(
                title: context.l10n.dailyGoalsNoGoalsYetTitle,
                description: context.l10n.dailyGoalsNoGoalsYetDescription,
                actionLabel: context.l10n.addTaskButton,
                onTapAction: controller.onTapAddTask,
                suggestionsTitle: context.l10n.dailyGoalsSuggestionsTitle,
                suggestions: [
                  context.l10n.dailyGoalsSuggestionStudy,
                  context.l10n.dailyGoalsSuggestionRead,
                  context.l10n.dailyGoalsSuggestionTrain,
                ],
                onTapSuggestion: controller.onTapSuggestion,
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
          children: [
            if (pending.isNotEmpty) ...[
              AppSectionHeader(
                title: context.l10n.dailyGoalsPendingSection,
                badge: context.l10n.homeGoalsProgress(
                  controller.doneTodayCount,
                  controller.tasks.length,
                ),
              ),
              const Gap(AppSpacing.betweenRelated),
              _TaskSection(
                tasks: pending,
                onEdit: controller.onEditTask,
                onToggle: controller.onToggleTask,
                onDelete: controller.onDeleteTask,
                onClearData: controller.onClearTaskData,
              ),
            ],
            if (completed.isNotEmpty) ...[
              if (pending.isNotEmpty)
                const Gap(
                  AppSpacing.betweenSections - AppSpacing.betweenRelated,
                ),
              AppSectionHeader(
                title: context.l10n.dailyGoalsCompletedSection,
                // The "done / total" count lives on the pending section while
                // anything is still open; it only moves onto Completed once
                // every goal is done (e.g. 2 of 2).
                badge: pending.isEmpty
                    ? context.l10n.homeGoalsProgress(
                        controller.doneTodayCount,
                        controller.tasks.length,
                      )
                    : null,
              ),
              const Gap(AppSpacing.betweenRelated),
              _TaskSection(
                tasks: completed,
                onEdit: controller.onEditTask,
                onToggle: controller.onToggleTask,
                onDelete: controller.onDeleteTask,
                onClearData: controller.onClearTaskData,
              ),
            ],
            const Gap(AppSpacing.titleToDescription),
            AddTaskTile(onTap: controller.onTapAddTask),
          ],
        );
      }),
    );
  }
}

class _DailyGoalsLoadingSkeleton extends StatelessWidget {
  const _DailyGoalsLoadingSkeleton();

  @override
  Widget build(BuildContext context) => AppSkeleton(
    child: ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
      children: const [
        // Section header: title on the left, "done / total" badge on the right.
        Row(
          children: [
            AppSkeletonBox(width: 120, height: 18, radius: 7),
            Spacer(),
            AppSkeletonBox(width: 44, height: 13, radius: 6),
          ],
        ),
        Gap(AppSpacing.betweenRelated),
        _SkeletonTaskTile(),
        Gap(AppSpacing.betweenRelated),
        _SkeletonTaskTile(),
        Gap(AppSpacing.betweenRelated),
        _SkeletonTaskTile(),
      ],
    ),
  );
}

class _SkeletonTaskTile extends StatelessWidget {
  const _SkeletonTaskTile();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    // Mirrors DailyTaskTile: check circle, the goal name, then the trailing
    // "X days" progress — all on one row.
    child: const Row(
      children: [
        AppSkeletonCircle(size: 32),
        Gap(12),
        Expanded(child: AppSkeletonBox(height: 16, radius: 7)),
        Gap(12),
        AppSkeletonBox(width: 52, height: 14, radius: 6),
      ],
    ),
  );
}

class _TaskSection extends StatelessWidget {
  const _TaskSection({
    required this.tasks,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
    required this.onClearData,
  });

  final List<DailyTaskEntity> tasks;
  final ValueChanged<DailyTaskEntity> onEdit;
  final Future<void> Function(DailyTaskEntity task) onToggle;
  final ValueChanged<DailyTaskEntity> onDelete;
  final ValueChanged<DailyTaskEntity> onClearData;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final (int index, DailyTaskEntity task) in tasks.indexed) ...[
        DailyTaskTile(
          key: ValueKey(task.id),
          task: task,
          onEdit: () => onEdit(task),
          onToggle: () => onToggle(task),
          onDelete: () => onDelete(task),
          onClearData: () => onClearData(task),
        ),
        if (index != tasks.length - 1) const Gap(AppSpacing.betweenRelated),
      ],
    ],
  );
}
