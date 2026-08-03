import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/groups/groups_controller.dart";
import "package:help_out/presentation/groups/widgets/current_user_rank_card.dart";
import "package:help_out/presentation/groups/widgets/group_member_avatar.dart";
import "package:help_out/presentation/groups/widgets/group_selector.dart";
import "package:help_out/presentation/groups/widgets/groups_header.dart";
import "package:help_out/presentation/groups/widgets/leaderboard_tile.dart";
import "package:help_out/presentation/groups/widgets/period_selector.dart";
import "package:help_out/shared/widgets/app_empty_state.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_section_header.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:help_out/theme/app_surfaces.dart";

/// Answers "how am I doing next to other people?". Owns both the group
/// leaderboards and the friends area they are built from.
class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupsController controller = Get.find();

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(16),
          GroupsHeader(
            onTapFriends: controller.onTapFriends,
            onTapCreateGroup: controller.onTapCreateGroup,
          ),
          const Gap(AppSpacing.betweenRelated),
          Obx(() {
            if (controller.isLoading.value && controller.groups.isEmpty) {
              return const _GroupSelectorSkeleton();
            }
            if (controller.groups.isEmpty) {
              return const Gap(AppSpacing.betweenSections);
            }

            return Column(
              children: [
                GroupSelector(
                  groups: controller.groups,
                  selectedGroupId: controller.selectedGroup.value?.id,
                  onSelectGroup: controller.onSelectGroup,
                ),
                const Gap(AppSpacing.titleToDescription),
              ],
            );
          }),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.groups.isEmpty) {
                return const _GroupsLoadingSkeleton();
              }

              if (controller.groups.isEmpty) {
                return _GroupsEmptyState(
                  onCreateGroup: controller.onTapCreateGroup,
                  onJoinWithCode: controller.onTapJoinWithCode,
                );
              }

              final List<GroupMemberEntity> members = controller.rankedMembers;
              final GroupEntity? group = controller.selectedGroup.value;
              final GroupMemberEntity? currentUser =
                  controller.currentUserMember;

              if (members.isEmpty || group == null) {
                return Center(
                  child: Text(
                    context.l10n.noGroupSelected,
                    style: context.textStyles.caption,
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.betweenSections,
                ),
                children: [
                  GroupPeriodSelector(
                    selectedPeriod: controller.selectedPeriod.value,
                    onSelectPeriod: controller.onSelectPeriod,
                  ),
                  const Gap(AppSpacing.betweenSections),
                  if (currentUser != null) ...[
                    CurrentUserRankCard(
                      rank: controller.currentUserRank,
                      theme: group.theme,
                      value: currentUser.secondsFor(
                        controller.selectedPeriod.value,
                      ),
                      differenceToPrevious: controller.differenceToPrevious(
                        currentUser,
                      ),
                      memberAhead: controller.memberAheadOfCurrentUser,
                      isTiedForFirst: controller.currentUserIsTiedForFirst,
                    ),
                    const Gap(AppSpacing.betweenSections),
                  ],
                  AppSectionHeader(title: context.l10n.leaderboardTitle),
                  const Gap(AppSpacing.betweenRelated),
                  Container(
                    decoration: AppSurfaces.rowGroup(context.colorTokens),
                    child: Column(
                      children: [
                        for (
                          int index = 0;
                          index < members.length;
                          index++
                        ) ...[
                          LeaderboardTile(
                            rank: controller.rankOf(members[index]),
                            member: members[index],
                            theme: group.theme,
                            value: members[index].secondsFor(
                              controller.selectedPeriod.value,
                            ),
                            isCurrentUser: controller.isCurrentUser(
                              members[index],
                            ),
                            isFirst: index == 0,
                            isLast: index == members.length - 1,
                            differenceToPrevious: controller
                                .differenceToPrevious(members[index]),
                          ),
                          if (index < members.length - 1)
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
            }),
          ),
        ],
      ),
    );
  }
}

class _GroupsEmptyState extends StatelessWidget {
  const _GroupsEmptyState({
    required this.onCreateGroup,
    required this.onJoinWithCode,
  });

  final VoidCallback onCreateGroup;
  final VoidCallback onJoinWithCode;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
    children: [
      AppEmptyState(
        icon: Icons.groups_2_outlined,
        title: context.l10n.groupsEmptyTitle,
        description: context.l10n.groupsEmptyDescription,
        actionLabel: context.l10n.groupsEmptyButton,
        onTapAction: onCreateGroup,
      ),
      const Gap(AppSpacing.betweenRelated),
      _JoinWithCodeButton(
        label: _joinWithCodeLabel(context),
        onTap: onJoinWithCode,
      ),
      const Gap(AppSpacing.betweenSections),
      Center(child: _BenefitsHeader(label: _benefitsHeader(context))),
      const Gap(AppSpacing.betweenRelated),
      Row(
        children: [
          Expanded(
            child: _BenefitTile(
              icon: Icons.leaderboard_rounded,
              label: _rankingLabel(context),
            ),
          ),
          const Gap(AppSpacing.titleToDescription),
          Expanded(
            child: _BenefitTile(
              icon: Icons.show_chart_rounded,
              label: _progressLabel(context),
            ),
          ),
          const Gap(AppSpacing.titleToDescription),
          Expanded(
            child: _BenefitTile(
              icon: Icons.favorite_border_rounded,
              label: context.l10n.groupsFriendsTitle,
            ),
          ),
        ],
      ),
    ],
  );

  String _joinWithCodeLabel(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "Tengo un código de invitación",
        "pt" => "Tenho um código de convite",
        _ => "I have an invite code",
      };

  String _benefitsHeader(BuildContext context) =>
      switch (context.languageCode) {
        "es" => "En un grupo puedes:",
        "pt" => "Em um grupo você pode:",
        _ => "In a group you can:",
      };

  String _rankingLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Ranking",
    "pt" => "Ranking",
    _ => "Ranking",
  };

  String _progressLabel(BuildContext context) => switch (context.languageCode) {
    "es" => "Progreso",
    "pt" => "Progresso",
    _ => "Progress",
  };
}

class _JoinWithCodeButton extends StatelessWidget {
  const _JoinWithCodeButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.97,
    child: Container(
      width: double.infinity,
      height: AppSpacing.minTapTarget,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.colorTokens.borderUnfocused.withValues(alpha: 0.95),
          width: 1.4,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.cardTitle,
      ),
    ),
  );
}

class _GroupSelectorSkeleton extends StatelessWidget {
  const _GroupSelectorSkeleton();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(
      top: 10,
      bottom: AppSpacing.titleToDescription,
    ),
    child: Row(
      children: [
        Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            gradient: context.colorTokens.primaryGradient,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorTokens.white.withValues(alpha: 0.25),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: context.colorTokens.white,
                  size: 20,
                ),
              ),
              const Gap(10),
              _SkeletonBox(
                width: 118,
                height: 16,
                radius: 8,
                color: context.colorTokens.white.withValues(alpha: 0.36),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _GroupsLoadingSkeleton extends StatelessWidget {
  const _GroupsLoadingSkeleton();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
    children: [
      const _CurrentUserRankSkeleton(),
      const Gap(AppSpacing.betweenRelated),
      Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: context.colorTokens.textHint,
          ),
          const Gap(6),
          const Expanded(child: _SkeletonBox(height: 12, radius: 6)),
        ],
      ),
      const Gap(AppSpacing.betweenSections),
      const _SkeletonBox(width: 116, height: 22, radius: 10),
      const Gap(AppSpacing.betweenRelated),
      Container(
        decoration: AppSurfaces.rowGroup(context.colorTokens),
        child: const Column(
          children: [
            _SkeletonLeaderboardRow(
              rank: 1,
              name: "Ana",
              colorValue: 0xFFE85888,
              scoreWidth: 62,
              isFirst: true,
            ),
            Divider(height: 1, indent: 22, endIndent: 22),
            _SkeletonLeaderboardRow(
              rank: 2,
              name: "Bia",
              colorValue: 0xFF4F7DF3,
              scoreWidth: 54,
              isCurrentUser: true,
            ),
            Divider(height: 1, indent: 22, endIndent: 22),
            _SkeletonLeaderboardRow(
              rank: 3,
              name: "Leo",
              colorValue: 0xFF42B976,
              scoreWidth: 48,
              isLast: true,
            ),
          ],
        ),
      ),
    ],
  );
}

class _CurrentUserRankSkeleton extends StatelessWidget {
  const _CurrentUserRankSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: AppSurfaces.content(context.colorTokens),
    child: Column(
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
              child: Icon(
                Icons.emoji_events_rounded,
                size: 30,
                color: context.colorTokens.primary,
              ),
            ),
            const Gap(14),
            const Flexible(
              child: Column(
                children: [
                  _SkeletonBox(width: 86, height: 12, radius: 6),
                  Gap(AppSpacing.titleToDescription),
                  _SkeletonBox(width: 64, height: 24, radius: 10),
                ],
              ),
            ),
            const Gap(AppSpacing.titleToDescription),
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
            const _SkeletonBox(width: 76, height: 24, radius: 10),
          ],
        ),
        const Gap(AppSpacing.titleToDescription),
        const _SkeletonBox(width: 160, height: 12, radius: 6),
      ],
    ),
  );
}

class _SkeletonLeaderboardRow extends StatelessWidget {
  const _SkeletonLeaderboardRow({
    required this.rank,
    required this.name,
    required this.colorValue,
    required this.scoreWidth,
    this.isCurrentUser = false,
    this.isFirst = false,
    this.isLast = false,
  });

  final int rank;
  final String name;
  final int colorValue;
  final double scoreWidth;
  final bool isCurrentUser;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final BorderRadius userRadius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(18) : Radius.zero,
      bottom: isLast ? const Radius.circular(18) : Radius.zero,
    );

    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.transparent,
        borderRadius: isCurrentUser ? userRadius : BorderRadius.zero,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Center(
              child: Icon(
                Icons.workspace_premium_rounded,
                size: 32,
                color: _SkeletonMedalColors.byRank(rank),
              ),
            ),
          ),
          const Gap(6),
          GroupMemberAvatar(name: name, colorValue: colorValue, size: 50),
          const Gap(14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(width: 118, height: 16, radius: 8),
                Gap(AppSpacing.titleToDescription),
                _SkeletonBox(width: 94, height: 11, radius: 6),
              ],
            ),
          ),
          const Gap(10),
          _SkeletonBox(width: scoreWidth, height: 16, radius: 8),
        ],
      ),
    );
  }
}

class _SkeletonMedalColors {
  static Color byRank(int rank) => switch (rank) {
    1 => const Color(0xFFE4B13B),
    2 => const Color(0xFF9AA3AD),
    3 => const Color(0xFFC98549),
    _ => const Color(0xFF9AA3AD),
  };
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.height,
    this.width,
    this.radius = 14,
    this.color,
  });

  final double height;
  final double? width;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveColor =
        color ??
        (isDarkMode ? const Color(0xFF343434) : const Color(0xFFE5E5E5));

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _BenefitsHeader extends StatelessWidget {
  const _BenefitsHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _HeaderLine(color: context.colorTokens.borderUnfocused),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(label, style: context.textStyles.caption),
      ),
      _HeaderLine(color: context.colorTokens.borderUnfocused),
    ],
  );
}

class _HeaderLine extends StatelessWidget {
  const _HeaderLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: 22, height: 1.2, color: color);
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: 88,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    decoration: AppSurfaces.content(context.colorTokens),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 26, color: context.colorTokens.primary),
        const Gap(AppSpacing.titleToDescription),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.cardTitle.copyWith(fontSize: 14),
        ),
      ],
    ),
  );
}
