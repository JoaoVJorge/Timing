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
        _GroupSectionTitle(title: context.l10n.leaderboardTitle),
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
