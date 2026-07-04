import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class HobbySubjectCard extends StatelessWidget {
  const HobbySubjectCard({required this.subject, required this.onTapPlay, super.key});

  final SubjectEntity subject;
  final VoidCallback onTapPlay;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(subject.colorValue);

    return BounceTap(
      pressedScale: 0.96,
      onTap: onTapPlay,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Center(child: AppIcon("guitar", size: 20, color: Colors.white)),
            ),
            const Spacer(),
            Text(
              subject.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.extraBold20.copyWith(color: Colors.white),
            ),
            const Gap(4),
            Text(
              formatDurationLong(Duration(seconds: subject.totalSeconds)),
              style: context.textStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
