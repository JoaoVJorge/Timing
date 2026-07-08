import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/profile/widgets/top_theme_tile.dart";

/// "Top reading" section for the Profile screen. Lists the reading subjects
/// with the most pages logged, or a guidance empty state when there are none.
class ProfileTopSubjectsList extends StatelessWidget {
  const ProfileTopSubjectsList({required this.subjects, super.key});

  final List<SubjectEntity> subjects;

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorTokens.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.colorTokens.borderUnfocused),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.profileTopReadingEmptyTitle,
              style: context.textStyles.bodyLarge,
            ),
            const Gap(4),
            Text(
              context.l10n.profileTopReadingEmptyDescription,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colorTokens.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (int index = 0; index < subjects.length; index++) ...[
          if (index > 0) const Gap(12),
          TopThemeTile(rank: index + 1, subject: subjects[index]),
        ],
      ],
    );
  }
}
