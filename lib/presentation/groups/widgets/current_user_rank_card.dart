import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/groups/group_leaderboard_formatters.dart";
import "package:help_out/shared/widgets/app_icon.dart";

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
    final String rankSummary = context.l10n.currentUserRankValue(
      formatRankLabel(context, rank),
      score,
    );
    final int separatorIndex = rankSummary.indexOf("·");
    final String rankText = separatorIndex < 0
        ? formatRankLabel(context, rank)
        : rankSummary.substring(0, separatorIndex).trim();
    final int? difference = differenceToPrevious;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colorTokens.borderUnfocused.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorTokens.surfaceShadow.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: context.colorTokens.primaryVeryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppIcon(
                    "trophy",
                    size: 30,
                    color: context.colorTokens.primary,
                  ),
                ),
              ),
              const Gap(14),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.currentUserRankTitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodySmall.copyWith(
                        color: context.colorTokens.textHint,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      rankText,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.black20.copyWith(fontSize: 26),
                    ),
                  ],
                ),
              ),
              const Gap(8),
            ],
          ),
          const Gap(14),
          Divider(height: 1, color: context.colorTokens.divider),
          const Gap(14),
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 22,
                color: context.colorTokens.primary,
              ),
              Flexible(
                child: Text(
                  score,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.black20.copyWith(fontSize: 26),
                ),
              ),
            ],
          ),
          const Gap(6),
          Text(
            difference == null || difference <= 0
                ? context.l10n.currentUserRankLeading
                : context.l10n.currentUserRankNextStep(
                    formatGroupScore(context, difference, theme.unit),
                  ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodySmall.copyWith(
              color: context.colorTokens.textHint,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
