import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/progress/widgets/top_theme_tile.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:help_out/theme/app_surfaces.dart";

/// "Top reading" section for the Progress screen. Lists the reading subjects
/// with the most pages logged, or a guidance empty state when there are none.
class ProgressTopSubjectsList extends StatelessWidget {
  const ProgressTopSubjectsList({required this.subjects, super.key});

  final List<SubjectEntity> subjects;

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: AppSurfaces.content(context.colorTokens),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.profileTopReadingEmptyTitle,
              style: context.textStyles.cardTitle,
            ),
            const Gap(AppSpacing.titleToDescription),
            Text(
              context.l10n.profileTopReadingEmptyDescription,
              style: context.textStyles.caption,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (int index = 0; index < subjects.length; index++) ...[
          if (index > 0) const Gap(AppSpacing.betweenRelated),
          TopThemeTile(rank: index + 1, subject: subjects[index]),
        ],
      ],
    );
  }
}
