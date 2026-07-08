import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/groups/group_leaderboard_formatters.dart";

class CurrentUserRankCard extends StatelessWidget {
  const CurrentUserRankCard({
    required this.rank,
    required this.theme,
    required this.value,
    required this.differenceToPrevious,
    super.key,
  });

  final int rank;
  final GroupThemeType theme;
  final int value;
  final int? differenceToPrevious;

  @override
  Widget build(BuildContext context) {
    final String score = formatGroupScore(context, value, theme.unit);
    final int? difference = differenceToPrevious;

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
            context.l10n.currentUserRankTitle,
            style: context.textStyles.bodyLarge,
          ),
          const Gap(8),
          Text(
            context.l10n.currentUserRankValue(
              formatRankLabel(context, rank),
              score,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.black20,
          ),
          const Gap(4),
          Text(
            difference == null || difference <= 0
                ? context.l10n.currentUserRankLeading
                : context.l10n.currentUserRankNextStep(
                    formatGroupScore(context, difference, theme.unit),
                  ),
            style: context.textStyles.bodySmall.copyWith(
              color: context.colorTokens.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
