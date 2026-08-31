part of "groups_page.dart";

// The leaderboard tab shown inside a group's details.

class _RankingTab extends StatelessWidget {
  const _RankingTab({
    required this.controller,
    required this.group,
    required this.members,
  });

  final GroupsController controller;
  final GroupEntity group;
  final List<GroupMemberEntity> members;

  @override
  Widget build(BuildContext context) {
    final GroupMemberEntity? currentUser = controller.currentUserMember;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentUser != null) ...[
          CurrentUserRankCard(
            rank: controller.currentUserRank,
            theme: group.theme,
            value: currentUser.secondsFor(controller.selectedPeriod.value),
            differenceToPrevious: controller.differenceToPrevious(currentUser),
            memberAhead: controller.memberAheadOfCurrentUser,
            isTiedForFirst: controller.currentUserIsTiedForFirst,
          ),
          const Gap(AppSpacing.betweenSections),
        ],
        _GroupSectionTitle(
          title: context.l10n.leaderboardTitle,
          trailing: _LeaderboardPeriodFilter(controller: controller),
        ),
        const Gap(AppSpacing.betweenRelated),
        Container(
          decoration: AppSurfaces.rowGroup(context.colorTokens),
          child: Column(
            children: [
              for (int index = 0; index < members.length; index++) ...[
                LeaderboardTile(
                  rank: controller.rankOf(members[index]),
                  member: members[index],
                  theme: group.theme,
                  value: members[index].secondsFor(
                    controller.selectedPeriod.value,
                  ),
                  isCurrentUser: controller.isCurrentUser(members[index]),
                  isFirst: index == 0,
                  isLast: index == members.length - 1,
                  differenceToPrevious: controller.differenceToPrevious(
                    members[index],
                  ),
                ),
                if (index < members.length - 1 &&
                    !controller.isCurrentUser(members[index]) &&
                    !controller.isCurrentUser(members[index + 1]))
                  Divider(
                    height: 1,
                    indent: 22,
                    endIndent: 22,
                    color: context.colorTokens.divider,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaderboardPeriodFilter extends StatelessWidget {
  const _LeaderboardPeriodFilter({required this.controller});

  final GroupsController controller;

  @override
  Widget build(BuildContext context) {
    final LeaderboardPeriodType selected = controller.selectedPeriod.value;
    final BorderRadius buttonRadius = BorderRadius.circular(16);

    return Theme(
      data: Theme.of(
        context,
      ).copyWith(highlightColor: context.colorTokens.primaryVeryLight),
      child: PopupMenuButton<LeaderboardPeriodType>(
        key: const ValueKey("leaderboard-period-filter"),
        initialValue: selected,
        tooltip: selected.localizedLabel(context),
        onSelected: controller.onSelectPeriod,
        position: PopupMenuPosition.under,
        offset: const Offset(0, 6),
        color: context.colorTokens.surface,
        surfaceTintColor: context.colorTokens.transparent,
        elevation: 8,
        menuPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        borderRadius: buttonRadius,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        itemBuilder: (context) => [
          for (final LeaderboardPeriodType period
              in LeaderboardPeriodType.values)
            PopupMenuItem<LeaderboardPeriodType>(
              value: period,
              child: Row(
                children: [
                  Icon(
                    _periodIcon(period),
                    size: 22,
                    color: context.colorTokens.primary,
                  ),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      period.localizedLabel(context),
                      style: context.textStyles.bodySmall.copyWith(
                        color: context.colorTokens.textBody,
                        fontWeight: period == selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (period == selected) ...[
                    const Gap(16),
                    Icon(
                      Icons.check_rounded,
                      size: 22,
                      color: context.colorTokens.primary,
                    ),
                  ],
                ],
              ),
            ),
        ],
        child: Container(
          constraints: const BoxConstraints(minWidth: 120, minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: context.colorTokens.primaryGradient,
            borderRadius: buttonRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  selected.localizedLabel(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colorTokens.primaryForeground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Gap(8),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 21,
                color: context.colorTokens.primaryForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _periodIcon(LeaderboardPeriodType period) => switch (period) {
    LeaderboardPeriodType.today => Icons.today_rounded,
    LeaderboardPeriodType.thisWeek => Icons.date_range_rounded,
    LeaderboardPeriodType.thisMonth => Icons.calendar_month_rounded,
    LeaderboardPeriodType.total => Icons.bar_chart_rounded,
  };
}
