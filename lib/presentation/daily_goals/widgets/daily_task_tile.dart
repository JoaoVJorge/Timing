import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class DailyTaskTile extends StatelessWidget {
  const DailyTaskTile({
    required this.task,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final DailyTaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final Color taskColor = Color(task.colorValue);
    final bool isCheckedToday = task.isCheckedToday;
    final double progress = task.targetDays == 0
        ? 0
        : (task.completedDays / task.targetDays).clamp(0.0, 1.0);

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: context.colorTokens.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const AppIcon("trash", color: Colors.white, size: 26),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorTokens.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            BounceTap(
              onTap: onToggle,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCheckedToday ? taskColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: taskColor, width: 2),
                ),
                child: isCheckedToday
                    ? const Center(
                        child: AppIcon("check", size: 14, color: Colors.white),
                      )
                    : null,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Gap(8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: context.colorTokens.surfaceInnerLayer,
                      valueColor: AlwaysStoppedAnimation<Color>(taskColor),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),
            Text(
              task.isCompleted
                  ? context.l10n.taskCompletedLabel
                  : context.l10n.taskDaysProgress(
                      task.completedDays,
                      task.targetDays,
                    ),
              style: context.textStyles.bodySmall.copyWith(
                color: task.isCompleted
                    ? context.colorTokens.success
                    : context.colorTokens.textHint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
