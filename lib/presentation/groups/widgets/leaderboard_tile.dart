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
    final Color accentColor = isCurrentUser
        ? context.colorTokens.primary
        : isTopThree
        ? _medalColors[rank - 1]
        : context.colorTokens.borderUnfocused;
    final Color backgroundColor = isCurrentUser
        ? context.colorTokens.primaryVeryLight
        : context.colorTokens.surface;
    final String memberName = isCurrentUser ? context.l10n.you : member.name;
    final String score = formatGroupScore(context, value, theme.unit);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: isCurrentUser ? 0.7 : 0.45),
          width: isCurrentUser || isTopThree ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: _RankMarker(rank: rank, isTopThree: isTopThree),
          ),
          const SizedBox(width: 12),
          GroupMemberAvatar(
            name: memberName,
            colorValue: member.avatarColorValue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        memberName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodyLarge,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorTokens.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          context.l10n.you,
                          style: context.textStyles.bodyTiny.copyWith(
                            color: context.colorTokens.primaryForeground,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const Gap(4),
                Text(
                  isCurrentUser
                      ? context.l10n.currentUserRankSubtitle
                      : _differenceText(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            score,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodyLarge.copyWith(
              color: isCurrentUser
                  ? context.colorTokens.primary
                  : context.colorTokens.textBody,
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
      return Icon(
        Icons.workspace_premium_rounded,
        size: 24,
        color: LeaderboardTile._medalColors[rank - 1],
      );
    }

    return Text(
      "$rank",
      textAlign: TextAlign.center,
      style: context.textStyles.bodyLarge.copyWith(
        color: context.colorTokens.textHint,
      ),
    );
  }
}
