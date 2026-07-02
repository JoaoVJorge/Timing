import "package:flutter/material.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/widgets/app_button.dart";

class SubjectTile extends StatelessWidget {
  const SubjectTile({required this.subject, required this.onTapPlay, super.key});

  final SubjectEntity subject;
  final VoidCallback onTapPlay;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(color: context.colorTokens.surface, borderRadius: BorderRadius.circular(18)),
    child: Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: Color(subject.colorValue), shape: BoxShape.circle)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subject.name, style: context.textStyles.bodyLarge),
              Text(
                formatDurationLong(Duration(seconds: subject.totalSeconds)),
                style: context.textStyles.bodySmall.copyWith(color: context.colorTokens.textHint),
              ),
            ],
          ),
        ),
        AppButton(icon: Icons.play_arrow_rounded, onTap: onTapPlay, size: 44),
      ],
    ),
  );
}
