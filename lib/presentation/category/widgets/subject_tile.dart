import "package:flutter/material.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/category/widgets/subject_icon_badge.dart";
import "package:timing/shared/functions/format_duration.dart";
import "package:timing/shared/widgets/app_icon_button.dart";

class SubjectTile extends StatelessWidget {
  const SubjectTile({
    required this.subject,
    required this.currentSeconds,
    required this.onTapPlay,
    super.key,
  });

  final SubjectEntity subject;
  final int currentSeconds;
  final VoidCallback onTapPlay;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(subject.colorValue);
    final bool hasGoal = subject.goalSeconds > 0;
    final double progress = hasGoal
        ? (currentSeconds / subject.totalGoalSeconds).clamp(0, 1)
        : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SubjectIconBadge(subject: subject),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyLarge,
                ),
                Text(
                  hasGoal
                      ? "${context.l10n.durationProgress(formatDurationLong(Duration(seconds: currentSeconds)), formatDurationLong(Duration(seconds: subject.totalGoalSeconds)))} - ${(progress * 100).round()}%"
                      : formatDurationLong(Duration(seconds: currentSeconds)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.caption.copyWith(fontSize: 12),
                ),
                if (hasGoal) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: color.withValues(alpha: 0.24),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppIconButton(
            svgName: "play",
            onTap: onTapPlay,
            accent: color,
            size: 44,
          ),
        ],
      ),
    );
  }
}
