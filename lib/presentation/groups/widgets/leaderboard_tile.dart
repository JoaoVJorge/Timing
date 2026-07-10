import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/groups/group_leaderboard_formatters.dart";
import "package:help_out/presentation/groups/widgets/group_member_avatar.dart";

class LeaderboardTile extends StatelessWidget {
  const LeaderboardTile({
    required this.rank,
    required this.member,
    required this.theme,
    required this.value,
    required this.isCurrentUser,
    this.differenceToPrevious,
    super.key,
  });

  final int rank;
  final GroupMemberEntity member;
  final GroupThemeType theme;
  final int value;
  final bool isCurrentUser;
  final int? differenceToPrevious;

  static const List<Color> _medalColors = [
    Color(0xFFFFC107),
    Color(0xFFB0BEC5),
    Color(0xFFD08A55),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isTopThree = rank <= 3;
    final String score = formatGroupScore(context, value, theme.unit);

    return Container(
      color: isCurrentUser
          ? context.colorTokens.primaryVeryLight.withValues(alpha: 0.45)
          : context.colorTokens.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                  style: context.textStyles.bodyLarge.copyWith(fontSize: 15),
                ),
                const Gap(2),
                Text(
                  isCurrentUser
                      ? context.l10n.currentUserRankSubtitle
                      : _differenceText(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.textHint,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Gap(10),
          Text(
            score,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodyLarge.copyWith(
              color: isCurrentUser
                  ? context.colorTokens.primary
                  : context.colorTokens.textBody,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              size: 32,
              color: LeaderboardTile._medalColors[rank - 1],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                "$rank",
                style: context.textStyles.bodyTiny.copyWith(
                  color: context.colorTokens.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
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
