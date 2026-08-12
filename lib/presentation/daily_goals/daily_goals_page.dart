import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/daily_goals/daily_goals_controller.dart";
import "package:timing/presentation/daily_goals/widgets/add_task_tile.dart";
import "package:timing/presentation/daily_goals/widgets/daily_task_tile.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_section_header.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/illustrated_empty_state.dart";
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
      ),
      body: Obx(() {
        final List<DailyTaskEntity> pending = controller.pendingTasks;
        final List<DailyTaskEntity> completed = controller.completedTasks;

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
              for (final DailyTaskEntity task in pending) ...[
                DailyTaskTile(
                  task: task,
                  onEdit: () => controller.onEditTask(task),
                  onToggle: () => controller.onToggleTask(task),
                  onDelete: () => controller.onDeleteTask(task),
                ),
                const Gap(AppSpacing.betweenRelated),
              ],
            ],
            if (completed.isNotEmpty) ...[
              if (pending.isNotEmpty)
                const Gap(
                  AppSpacing.betweenSections - AppSpacing.betweenRelated,
                ),
              AppSectionHeader(
                title: context.l10n.dailyGoalsCompletedSection,
                badge: context.l10n.homeGoalsProgress(
                  controller.doneTodayCount,
                  controller.tasks.length,
                ),
              ),
              const Gap(AppSpacing.betweenRelated),
              for (final DailyTaskEntity task in completed) ...[
                DailyTaskTile(
                  task: task,
                  onEdit: () => controller.onEditTask(task),
                  onToggle: () => controller.onToggleTask(task),
                  onDelete: () => controller.onDeleteTask(task),
                ),
                const Gap(AppSpacing.betweenRelated),
              ],
            ],
            const Gap(AppSpacing.titleToDescription),
            AddTaskTile(onTap: controller.onTapAddTask),
          ],
        );
      }),
    );
  }
}
