import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/daily_goals/daily_goals_controller.dart";
import "package:help_out/presentation/daily_goals/widgets/add_task_tile.dart";
import "package:help_out/presentation/daily_goals/widgets/daily_task_tile.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";

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
      body: Obx(
        () => ListView(
          children: [
            for (final DailyTaskEntity task in controller.tasks) ...[
              DailyTaskTile(
                task: task,
                onToggle: () => controller.onToggleTask(task),
                onDelete: () => controller.onDeleteTask(task),
              ),
              const Gap(12),
            ],
            AddTaskTile(onTap: controller.onTapAddTask),
          ],
        ),
      ),
    );
  }
}
