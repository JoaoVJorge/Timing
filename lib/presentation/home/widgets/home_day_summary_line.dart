import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/theme/app_spacing.dart";

/// One quiet line closing the page. Four separate metric cards fragmented the
/// reading and repeated what Progress already shows in depth.
class HomeDaySummaryLine extends StatelessWidget {
  const HomeDaySummaryLine({
    required this.focus,
    required this.pages,
    required this.goals,
    super.key,
  });

  final String focus;
  final int pages;
  final int goals;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        Icons.insights_rounded,
        size: 16,
        color: context.colorTokens.textHint,
      ),
      const Gap(AppSpacing.titleToDescription),
      Expanded(
        child: Text(
          context.l10n.homeTodayInline(focus, pages, goals),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.caption,
        ),
      ),
    ],
  );
}
