import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/groups/group_leaderboard_formatters.dart";
import "package:help_out/presentation/groups/widgets/group_member_avatar.dart";
import "package:help_out/theme/group_colors.dart";

class LeaderboardTile extends StatelessWidget {
  const LeaderboardTile({
    required this.rank,
    required this.member,
    required this.theme,
    required this.value,
    required this.isCurrentUser,
    required this.isFirst,
    required this.isLast,
    this.differenceToPrevious,
    super.key,
  });

  final int rank;
  final GroupMemberEntity member;
  final GroupThemeType theme;
  final int value;
  final bool isCurrentUser;
  final bool isFirst;
  final bool isLast;
  final int? differenceToPrevious;

  @override
  Widget build(BuildContext context) {
    final bool isTopThree = rank <= 3;
    final bool isLeader = rank == 1;
    final String score = formatGroupScore(context, value, theme.unit);
    final BorderRadius rowRadius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(18) : Radius.zero,
      bottom: isLast ? const Radius.circular(18) : Radius.zero,
    );

    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.transparent,
        borderRadius: isCurrentUser ? BorderRadius.circular(18) : rowRadius,
        boxShadow: isCurrentUser
            ? [
                BoxShadow(
                  color: context.colorTokens.primary.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 34,
            child: _RankMarker(rank: rank, isTopThree: isTopThree),
          ),
          const Gap(6),
          GroupMemberAvatar(
            name: member.name,
            colorValue: member.avatarColorValue,
            size: 50,
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyLarge,
                ),
                const Gap(2),
                Text(
                  _subtitleText(context, isLeader: isLeader),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: isCurrentUser
                        ? context.colorTokens.primary
                        : context.colorTokens.textHint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Gap(10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodyLarge.copyWith(
                  color: isCurrentUser
                      ? context.colorTokens.primary
                      : context.colorTokens.textBody,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _subtitleText(BuildContext context, {required bool isLeader}) {
    if (isCurrentUser) {
      return switch (context.languageCode) {
        "es" => "Tu posición actual",
        "pt" => "Sua posição atual",
        _ => context.l10n.currentUserRankSubtitle,
      };
    }
    if (isLeader) {
      return switch (context.languageCode) {
        "es" => "Líder de este ranking",
        "pt" => "Líder deste ranking",
        _ => context.l10n.leaderboardTopPosition,
      };
    }
    return _differenceText(context);
  }

  String _differenceText(BuildContext context) {
    final int? difference = differenceToPrevious;
    if (difference == null || difference <= 0) {
      return context.l10n.leaderboardTopPosition;
    }
    return context.l10n.leaderboardDifferenceAhead(
      formatGroupScore(context, difference, theme.unit),
    );
  }
}

class _RankMarker extends StatelessWidget {
  const _RankMarker({required this.rank, required this.isTopThree});

  final int rank;
  final bool isTopThree;

  @override
  Widget build(BuildContext context) {
    if (isTopThree) {
      return Center(
        child: Icon(
          Icons.workspace_premium_rounded,
          size: 32,
          color: LeaderboardMedalColors.byRank(rank),
        ),
      );
    }

    return Center(
      child: Text(
        "$rank",
        textAlign: TextAlign.center,
        style: context.textStyles.bodyLarge.copyWith(
          color: context.colorTokens.textHint,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
