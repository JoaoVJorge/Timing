import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/category/widgets/subject_icon_badge.dart";
import "package:help_out/shared/widgets/app_icon_button.dart";

class ReadingSubjectTile extends StatelessWidget {
  const ReadingSubjectTile({
    required this.subject,
    required this.onTapPlay,
    super.key,
  });

  final SubjectEntity subject;
  final VoidCallback onTapPlay;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(subject.colorValue);
    final bool hasGoal = subject.goalPages > 0;
    final double progress = hasGoal
        ? (subject.currentPages / subject.goalPages).clamp(0, 1)
        : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SubjectIconBadge(
            subject: subject,
            width: 40,
            height: 56,
            iconSize: 22,
            borderRadius: 8,
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
                  style: context.textStyles.bodyLarge,
                ),
                Text(
                  hasGoal
                      ? context.l10n.pagesProgress(
                          subject.currentPages,
                          subject.goalPages,
                        )
                      : context.l10n.pagesReadOnly(subject.currentPages),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
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
          AppIconButton(svgName: "play", onTap: onTapPlay, size: 44),
        ],
      ),
    );
  }
}
