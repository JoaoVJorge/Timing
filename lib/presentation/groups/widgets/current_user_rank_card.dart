import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
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
    required this.isTiedForFirst,
    this.memberAhead,
    super.key,
  });

  final int rank;
  final GroupThemeType theme;
  final int value;
  final int? differenceToPrevious;
  final bool isTiedForFirst;

  /// Whoever sits one position above, so the gap has a name attached to it.
  final GroupMemberEntity? memberAhead;

  @override
  Widget build(BuildContext context) {
    final String score = formatGroupScore(context, value, theme.unit);
    final String formattedRank = isTiedForFirst
        ? _tiedFirstLabel(context)
        : formatRankLabel(context, rank);
    final String rankSummary = context.l10n.currentUserRankValue(
      formattedRank,
      score,
    );
    final int separatorIndex = rankSummary.indexOf("·");
    final String rankText = separatorIndex < 0
        ? formattedRank
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
            _nextStepText(context, difference),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.caption.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _nextStepText(BuildContext context, int? difference) {
    if (value <= 0) {
      return switch (context.languageCode) {
        "es" => "Completa tu primera meta para entrar al ranking.",
        "pt" => "Conclua sua primeira meta para entrar no ranking.",
        _ => "Complete your first goal to enter the ranking.",
      };
    }
    if (isTiedForFirst) {
      return switch (context.languageCode) {
        "es" => "Empate en el liderazgo.",
        "pt" => "Empate na liderança.",
        _ => "Tied for the lead.",
      };
    }
    if (difference == null || difference <= 0) {
      return context.l10n.currentUserRankLeading;
    }

    final String score = formatGroupScore(context, difference, theme.unit);
    final GroupMemberEntity? ahead = memberAhead;
    return ahead == null
        ? context.l10n.currentUserRankNextStep(score)
        : context.l10n.currentUserRankNextStepNamed(score, ahead.name);
  }

  String _tiedFirstLabel(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Empate en 1er lugar",
        "pt" => "Empate em 1º lugar",
        _ => "Tied for 1st",
      };
}
