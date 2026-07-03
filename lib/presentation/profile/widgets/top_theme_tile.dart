import "package:flutter/material.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_duration.dart";

class TopThemeTile extends StatelessWidget {
  const TopThemeTile({required this.rank, required this.subject, super.key});

  final int rank;
  final SubjectEntity subject;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: BoxDecoration(color: context.colorTokens.surface, borderRadius: BorderRadius.circular(18)),
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Color(subject.colorValue).withValues(alpha: 0.18), shape: BoxShape.circle),
          child: Text("#$rank", style: context.textStyles.bodyTiny.copyWith(color: Color(subject.colorValue))),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(subject.name, style: context.textStyles.bodyLarge)),
        Text(
          formatDurationLong(Duration(seconds: subject.totalSeconds)),
          style: context.textStyles.bodySmall.copyWith(color: context.colorTokens.textHint),
        ),
      ],
    ),
  );
}
