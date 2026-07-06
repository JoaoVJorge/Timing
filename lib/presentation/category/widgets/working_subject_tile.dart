import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/widgets/app_button.dart";
import "package:help_out/shared/widgets/app_icon.dart";

class WorkingSubjectTile extends StatelessWidget {
  const WorkingSubjectTile({
    required this.subject,
    required this.onTapPlay,
    super.key,
  });

  final SubjectEntity subject;
  final VoidCallback onTapPlay;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(subject.colorValue);
    final bool hasGoal = subject.goalSeconds > 0;
    final double progress = hasGoal
        ? (subject.totalSeconds / subject.goalSeconds).clamp(0, 1)
        : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(child: AppIcon("building", size: 22, color: color)),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.extraBold20,
                ),
                const Gap(4),
                Text(
                  hasGoal
                      ? context.l10n.durationProgress(
                          formatDurationLong(
                            Duration(seconds: subject.totalSeconds),
                          ),
                          formatDurationLong(
                            Duration(seconds: subject.goalSeconds),
                          ),
                        )
                      : formatDurationLong(
                          Duration(seconds: subject.totalSeconds),
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colorTokens.textHint,
                  ),
                ),
                if (hasGoal) ...[
                  const Gap(8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: color.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Gap(8),
          AppButton(svgName: "play", onTap: onTapPlay, size: 52),
        ],
      ),
    );
  }
}
