import "dart:convert";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/group_activity_progress_entity.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_image_message_entity.dart";
import "package:timing/core/domain/entities/group_member_entity.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/enums/leaderboard_period_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/groups/group_leaderboard_formatters.dart";
import "package:timing/presentation/groups/groups_controller.dart";
import "package:timing/presentation/groups/widgets/current_user_rank_card.dart";
import "package:timing/presentation/groups/widgets/group_member_avatar.dart";
import "package:timing/presentation/groups/widgets/groups_header.dart";
import "package:timing/presentation/groups/widgets/leaderboard_tile.dart";
import "package:timing/shared/functions/format_duration.dart";
import "package:timing/shared/functions/format_schedule_time.dart";
import "package:timing/shared/widgets/animated_segmented_tabs.dart";
import "package:timing/shared/widgets/app_empty_state.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_skeleton.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/theme/app_spacing.dart";
import "package:timing/theme/app_surfaces.dart";

/// Answers "how am I doing next to other people?". Owns both the group
/// leaderboards and the friends area they are built from.
class GroupsPage extends StatelessWidget {
  const GroupsPage({this.showGroupFlowOnly = false, super.key});

  final bool showGroupFlowOnly;

  @override
  Widget build(BuildContext context) {
    final GroupsController controller = Get.find();

    if (showGroupFlowOnly) {
      return Obx(() {
        if (controller.isShowingMemberManagement.value) {
          return AppScaffold(body: _ManageMembersView(controller: controller));
        }
        return AppScaffold(body: _GroupDetailsView(controller: controller));
      });
    }

    return AppScaffold(body: _GroupsHomeView(controller: controller));
  }
}

class _GroupsHomeView extends StatelessWidget {
  const _GroupsHomeView({required this.controller});

  final GroupsController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Gap(16),
      GroupsHeader(onTapCreateGroup: controller.onTapCreateGroup),
      const Gap(AppSpacing.betweenSections),
      Expanded(
        child: Obx(() {
          if (controller.isLoading.value && controller.groups.isEmpty) {
            return const _GroupsLoadingSkeleton();
          }

          if (controller.didFailLoadingGroups.value &&
              controller.groups.isEmpty) {
            return _GroupsLoadErrorState(onRetry: controller.loadGroups);
          }

          if (controller.groups.isEmpty) {
            return _GroupsEmptyState(
              onCreateGroup: controller.onTapCreateGroup,
              onTapFriends: controller.onTapFriends,
            );
          }

          return _GroupsList(
            groups: controller.groups,
            onTapFriends: controller.onTapFriends,
            onSelectGroup: controller.onSelectGroup,
          );
        }),
      ),
    ],
  );
}

class _GroupDetailsView extends StatelessWidget {
  const _GroupDetailsView({required this.controller});

  final GroupsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final GroupEntity? group = controller.selectedGroup.value;
      final List<GroupMemberEntity> members = controller.rankedMembers;

      if (group == null || members.isEmpty) {
        return Center(
          child: Text(
            context.l10n.noGroupSelected,
            style: context.textStyles.caption,
          ),
        );
      }

      return Column(
        children: [
          Gap(4),
          _GroupDetailsHeader(
            group: group,
            onBack: controller.onBackToGroupList,
            onActions: () => _showGroupActionsSheet(context, controller),
          ),
          const Gap(8),
          _GroupDetailsTabsScope(controller: controller),
          const Gap(10),
          Expanded(
            child: _GroupDetailsContent(
              controller: controller,
              group: group,
              members: members,
            ),
          ),
        ],
      );
    });
  }
}

class _GroupsList extends StatelessWidget {
  const _GroupsList({
    required this.groups,
    required this.onTapFriends,
    required this.onSelectGroup,
  });

  final List<GroupEntity> groups;
  final VoidCallback onTapFriends;
  final ValueChanged<GroupEntity> onSelectGroup;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
    itemCount: groups.length + 1,
    separatorBuilder: (_, _) => const Gap(AppSpacing.betweenRelated),
    itemBuilder: (context, index) {
      if (index == 0) {
        return _FriendsCard(groupCount: groups.length, onTap: onTapFriends);
      }
      final GroupEntity group = groups[index - 1];
      return _GroupCard(group: group, onTap: () => onSelectGroup(group));
    },
  );
}

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

class _GroupSectionTitle extends StatelessWidget {
  const _GroupSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 5,
        height: 22,
        decoration: BoxDecoration(
          color: context.colorTokens.primary,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      const Gap(10),
      Expanded(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.sectionTitle.copyWith(
            color: context.colorTokens.textBody,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ],
  );
}

class _ManageMembersView extends StatelessWidget {
  const _ManageMembersView({required this.controller});

  final GroupsController controller;

  @override
  Widget build(BuildContext context) {
    final GroupEntity? group = controller.selectedGroup.value;
    if (group == null) {
      return Center(
        child: Text(
          context.l10n.noGroupSelected,
          style: context.textStyles.caption,
        ),
      );
    }

    final GroupMemberEntity? leader = _leaderFor(group);
    final List<GroupMemberEntity> members = group.members
        .where((member) => member.id != leader?.id)
        .toList();
    final bool currentUserIsLeader =
        leader != null && leader.id == controller.currentUserId;

    return Column(
      children: [
        const Gap(12),
        AppTopBar(
          title: context.l10n.manageMembersTitle,
          showBackButton: true,
          onBack: controller.onBackToGroupDetails,
        ),
        const Gap(12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
            children: [
              _ManageGroupSummaryCard(group: group),
              const Gap(12),
              if (leader != null) ...[
                _MembersSectionLabel(label: context.l10n.groupLeaderLabel),
                const Gap(8),
                _MemberRow(
                  member: leader,
                  roleLabel: context.l10n.groupLeaderRoleLabel,
                  badgeLabel: context.l10n.groupLeaderLabel,
                  isFirst: true,
                  isLast: true,
                  showActions: false,
                ),
                const Gap(12),
              ],
              _MembersSectionLabel(label: context.l10n.groupMembersLabel),
              const Gap(8),
              Container(
                decoration: AppSurfaces.rowGroup(context.colorTokens),
                child: Column(
                  children: [
                    for (int index = 0; index < members.length; index++) ...[
                      _MemberRow(
                        member: members[index],
                        roleLabel: context.l10n.groupMemberRoleLabel,
                        isFirst: index == 0,
                        isLast: index == members.length - 1,
                        showActions: currentUserIsLeader,
                      ),
                      if (index < members.length - 1)
                        Divider(
                          height: 1,
                          indent: 78,
                          color: context.colorTokens.divider,
                        ),
                    ],
                  ],
                ),
              ),
              if (currentUserIsLeader) ...[
                const Gap(14),
                _AddMemberButton(onTap: controller.onTapInviteMembers),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ManageGroupSummaryCard extends StatelessWidget {
  const _ManageGroupSummaryCard({required this.group});

  final GroupEntity group;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: AppSurfaces.content(context.colorTokens),
    child: Row(
      children: [
        _GroupIcon(theme: group.theme, size: 54, iconSize: 26),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizedGroupName(context, group),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.black20.copyWith(fontSize: 20),
              ),
              const Gap(3),
              Text(
                context.l10n.groupParticipantsCount(group.members.length),
                style: context.textStyles.bodyMedium.copyWith(
                  color: context.colorTokens.textHint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MembersSectionLabel extends StatelessWidget {
  const _MembersSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: context.textStyles.sectionTitle.copyWith(
      color: context.colorTokens.textHint,
      fontSize: 16,
    ),
  );
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.roleLabel,
    required this.isFirst,
    required this.isLast,
    this.badgeLabel,
    this.showActions = false,
  });

  final GroupMemberEntity member;
  final String roleLabel;
  final bool isFirst;
  final bool isLast;
  final String? badgeLabel;
  final bool showActions;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 64),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(18) : Radius.zero,
        bottom: isLast ? const Radius.circular(18) : Radius.zero,
      ),
      border: badgeLabel == null
          ? null
          : Border.all(
              color: context.colorTokens.borderUnfocused.withValues(alpha: 0.4),
            ),
    ),
    child: Row(
      children: [
        GroupMemberAvatar(
          name: member.name,
          colorValue: member.avatarColorValue,
          avatar: member.avatar,
          size: 44,
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                member.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodyLarge.copyWith(fontSize: 15),
              ),
              const Gap(2),
              Text(
                roleLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodyMedium.copyWith(
                  color: context.colorTokens.textHint,
                ),
              ),
            ],
          ),
        ),
        if (badgeLabel != null) ...[
          const Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.colorTokens.primaryVeryLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badgeLabel!,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colorTokens.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
        if (showActions) ...[
          const Gap(8),
          Icon(
            Icons.more_vert_rounded,
            size: 22,
            color: context.colorTokens.textBody,
          ),
        ],
      ],
    ),
  );
}

class _AddMemberButton extends StatelessWidget {
  const _AddMemberButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.98,
    child: Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colorTokens.primary, width: 1.4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_alt_1_rounded,
            color: context.colorTokens.primary,
            size: 22,
          ),
          const Gap(8),
          Text(
            context.l10n.addMemberButton,
            style: context.textStyles.cardTitle.copyWith(
              color: context.colorTokens.primary,
            ),
          ),
        ],
      ),
    ),
  );
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, required this.onTap});

  final GroupEntity group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.98,
    child: Container(
      constraints: const BoxConstraints(minHeight: 124),
      padding: const EdgeInsets.all(14),
      decoration: AppSurfaces.content(context.colorTokens),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GroupIcon(theme: group.theme, size: 72, iconSize: 34),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizedGroupName(context, group),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.black20.copyWith(fontSize: 22),
                ),
                const Gap(4),
                Text(
                  groupDescription(context, group),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium.copyWith(height: 1.28),
                ),
                const Gap(12),
                _OverlappingMembers(members: group.members),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _FriendsCard extends StatelessWidget {
  const _FriendsCard({required this.groupCount, required this.onTap});

  final int groupCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.98,
    child: Container(
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.all(14),
      decoration: AppSurfaces.content(context.colorTokens),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: context.colorTokens.primaryVeryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: 26,
              color: context.colorTokens.primary,
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.groupsFriendsTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.cardTitle.copyWith(
                    color: context.colorTokens.primary,
                  ),
                ),
                const Gap(3),
                Text(
                  friendsCardSubtitle(context, groupCount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.textBody,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          Icon(
            Icons.chevron_right_rounded,
            size: 28,
            color: context.colorTokens.textHint,
          ),
        ],
      ),
    ),
  );
}

class _OverlappingMembers extends StatelessWidget {
  const _OverlappingMembers({required this.members});

  final List<GroupMemberEntity> members;

  @override
  Widget build(BuildContext context) {
    const int visibleCount = 3;
    const double size = 30;
    const double overlap = 10;
    final List<GroupMemberEntity> visibleMembers = members
        .take(visibleCount)
        .toList();
    final int extraCount = members.length - visibleMembers.length;

    return SizedBox(
      height: size,
      width: visibleMembers.isEmpty
          ? 0
          : size +
                (visibleMembers.length - 1) * (size - overlap) +
                (extraCount > 0 ? size - overlap : 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int index = 0; index < visibleMembers.length; index++)
            Positioned(
              left: index * (size - overlap),
              child: GroupMemberAvatar(
                name: visibleMembers[index].name,
                colorValue: visibleMembers[index].avatarColorValue,
                avatar: visibleMembers[index].avatar,
                size: size,
                borderColor: context.colorTokens.surface,
              ),
            ),
          if (extraCount > 0)
            Positioned(
              left: visibleMembers.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colorTokens.primaryVeryLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colorTokens.surface,
                    width: 2,
                  ),
                ),
                child: Text(
                  "+$extraCount",
                  maxLines: 1,
                  style: context.textStyles.bodyTiny.copyWith(
                    color: context.colorTokens.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupDetailsHeader extends StatelessWidget {
  const _GroupDetailsHeader({
    required this.group,
    required this.onBack,
    required this.onActions,
  });

  final GroupEntity group;
  final VoidCallback onBack;
  final VoidCallback onActions;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 72,
    child: Row(
      children: [
        _DetailBackButton(onTap: onBack),
        const Gap(8),
        _GroupIcon(theme: group.theme, size: 56, iconSize: 27),
        const Gap(12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizedGroupName(context, group),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.black28.copyWith(
                  color: context.colorTokens.textBody,
                  fontSize: 24,
                  height: 1,
                ),
              ),
              const Gap(4),
              Text(
                context.l10n.groupMembersCount(group.members.length),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.caption.copyWith(
                  color: context.colorTokens.primary,
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        _DetailIconButton(
          icon: Icons.more_vert_rounded,
          semanticLabel: context.l10n.groupActionsLabel,
          onTap: onActions,
        ),
      ],
    ),
  );
}

class _GroupDetailsTabs extends StatelessWidget {
  const _GroupDetailsTabs({
    required this.selectedTab,
    required this.onSelectTab,
    required this.onSwipeTab,
  });

  final GroupDetailsTab selectedTab;
  final ValueChanged<GroupDetailsTab> onSelectTab;
  final ValueChanged<int> onSwipeTab;

  @override
  Widget build(BuildContext context) => AnimatedSegmentedTabs(
    labels: [
      context.l10n.leaderboardTitle,
      context.l10n.goalsTabLabel,
      context.l10n.chatTabLabel,
    ],
    selectedIndex: selectedTab.index,
    onSelectIndex: (index) => onSelectTab(GroupDetailsTab.values[index]),
    onSwipe: onSwipeTab,
  );
}

class _GroupDetailsTabsScope extends StatelessWidget {
  const _GroupDetailsTabsScope({required this.controller});

  final GroupsController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => _GroupDetailsTabs(
      selectedTab: controller.selectedDetailsTab.value,
      onSelectTab: controller.onSelectDetailsTab,
      onSwipeTab: controller.onSwipeDetailsTab,
    ),
  );
}

class _GroupDetailsContent extends StatelessWidget {
  const _GroupDetailsContent({
    required this.controller,
    required this.group,
    required this.members,
  });

  final GroupsController controller;
  final GroupEntity group;
  final List<GroupMemberEntity> members;

  @override
  Widget build(BuildContext context) => Obx(() {
    final GroupDetailsTab selectedTab = controller.selectedDetailsTab.value;
    final bool showLoadingOverlay =
        selectedTab == GroupDetailsTab.goals &&
            controller.isLoadingActivityProgress.value &&
            controller.activityHeaders.isNotEmpty ||
        selectedTab == GroupDetailsTab.chat &&
            controller.isLoadingChat.value &&
            controller.imageMessagesFor(group.id).isNotEmpty;

    return RepaintBoundary(
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: IndexedStack(
                sizing: StackFit.expand,
                index: selectedTab.index,
                children: [
                  _ScrollableDetailsTab(
                    child: _RankingTab(
                      controller: controller,
                      group: group,
                      members: members,
                    ),
                  ),
                  _ScrollableDetailsTab(
                    child: _GoalsTab(controller: controller, group: group),
                  ),
                  _ChatTab(controller: controller, group: group),
                ],
              ),
            ),
            _LoadingOverlay(isVisible: showLoadingOverlay),
          ],
        ),
      ),
    );
  });
}

class _ScrollableDetailsTab extends StatelessWidget {
  const _ScrollableDetailsTab({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
    child: child,
  );
}

class _TabLoadingIndicator extends StatelessWidget {
  const _TabLoadingIndicator();

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: 28,
      height: 28,
      child: CircularProgressIndicator(
        strokeWidth: 2.6,
        color: context.colorTokens.primary,
      ),
    ),
  );
}

class _InlineLoadingIndicator extends StatelessWidget {
  const _InlineLoadingIndicator();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: context.colorTokens.primary,
          ),
        ),
      ],
    ),
  );
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.isVisible});

  final bool isVisible;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: true,
    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: isVisible ? 1 : 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorTokens.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: context.colorTokens.borderUnfocused.withValues(
                  alpha: 0.45,
                ),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _GoalsTab extends StatefulWidget {
  const _GoalsTab({required this.controller, required this.group});

  final GroupsController controller;
  final GroupEntity group;

  @override
  State<_GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends State<_GoalsTab> {
  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void didUpdateWidget(_GoalsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group.id != widget.group.id) {
      _loadProgress();
    }
  }

  void _loadProgress() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.loadActivityProgress();
      }
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _GroupActivityDataView(
        controller: widget.controller,
        group: widget.group,
      ),
    ],
  );
}

class _GroupActivityDataView extends StatelessWidget {
  const _GroupActivityDataView({required this.controller, required this.group});

  final GroupsController controller;
  final GroupEntity group;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<GroupActivityProgressEntity> headers =
          controller.activityHeaders;
      if (controller.isLoadingActivityProgress.value && headers.isEmpty) {
        return const _InlineLoadingIndicator();
      }
      if (headers.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        children: [
          for (final GroupActivityProgressEntity header in headers) ...[
            _activityData(context, controller, header),
            const Gap(AppSpacing.betweenSections),
          ],
        ],
      );
    });
  }

  Widget _activityData(
    BuildContext context,
    GroupsController controller,
    GroupActivityProgressEntity header,
  ) {
    final LeaderboardPeriodType period = controller.selectedPeriod.value;
    final int total = group.members.length;
    final int focusSeconds = header.focusSeconds > 0
        ? header.focusSeconds
        : header.target;
    final int targetPerMember = _targetForPeriod(
      header.target > 0 ? header.target : focusSeconds,
      period,
    );
    final Map<String, int> progressByMember = {
      for (final GroupMemberEntity member in group.members)
        member.id: member.secondsFor(period),
    };
    final List<GroupMemberEntity> completedMembers = group.members
        .where(
          (member) => (progressByMember[member.id] ?? 0) >= targetPerMember,
        )
        .toList();
    final List<GroupMemberEntity> pendingMembers = group.members
        .where((member) => (progressByMember[member.id] ?? 0) < targetPerMember)
        .toList();
    final int reached = completedMembers.length;
    final int totalPeriodValue = group.members.fold<int>(
      0,
      (sum, member) => sum + (progressByMember[member.id] ?? 0),
    );

    return Column(
      children: [
        _ParticipantsProgressCard(
          total: total,
          completedMembers: completedMembers,
          pendingMembers: pendingMembers,
          progressByMember: progressByMember,
          targetPerMember: targetPerMember,
          unit: group.theme.unit,
        ),
        const Gap(AppSpacing.betweenRelated),
        _GroupStatisticsCard(
          totalPeriodValue: totalPeriodValue,
          completedSessions: reached,
          participants: total,
          unit: group.theme.unit,
          period: period,
        ),
        const Gap(AppSpacing.betweenRelated),
        _ActivityOverviewCard(
          group: group,
          header: header,
          focusSeconds: focusSeconds,
        ),
      ],
    );
  }
}

class _ActivityOverviewCard extends StatelessWidget {
  const _ActivityOverviewCard({
    required this.group,
    required this.header,
    required this.focusSeconds,
  });

  final GroupEntity group;
  final GroupActivityProgressEntity header;
  final int focusSeconds;

  @override
  Widget build(BuildContext context) {
    final Color accent = _groupDataAccent(context);

    return _GroupDataCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _DataSectionIcon(
                color: accent,
                child: header.isGoal
                    ? Icon(Icons.flag_rounded, size: 20, color: accent)
                    : AppIcon(group.theme.iconName, size: 20, color: accent),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  localizedGroupName(context, group),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.black20.copyWith(
                    color: context.colorTokens.textBody,
                    fontSize: 18,
                  ),
                ),
              ),
              const Gap(8),
              _FrequencyBadge(label: context.l10n.dailyLabel),
            ],
          ),
          const Gap(14),
          _GroupDataDivider(),
          const Gap(14),
          Text(
            group.description.trim().isEmpty
                ? context.l10n.goalLabel
                : group.description.trim(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.textHint,
              fontSize: 15,
              height: 1.18,
            ),
          ),
          const Gap(16),
          _GroupDataDivider(),
          const Gap(16),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _ActivityDataTile(
                    icon: Icons.timer_outlined,
                    label: context.l10n.groupActivityFocusDataLabel,
                    value: formatDurationTotalMinutes(
                      Duration(seconds: focusSeconds),
                    ),
                  ),
                ),
                if (group.theme != GroupThemeType.hobbies) ...[
                  _MetricDivider(),
                  Expanded(
                    child: _ActivityDataTile(
                      icon: Icons.coffee_outlined,
                      label: context.l10n.groupActivityPauseDataLabel,
                      value: _formatRestValue(
                        context,
                        group.theme,
                        header.restMinutes,
                      ),
                    ),
                  ),
                  _MetricDivider(),
                  Expanded(
                    child: _ActivityDataTile(
                      icon: Icons.repeat_rounded,
                      label: context.l10n.groupActivitySessionsDataLabel,
                      value: header.focusSessionCount.toString(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatRestValue(BuildContext context, GroupThemeType theme, int value) {
  if (theme == GroupThemeType.exercises) {
    final int seconds = value <= 20 ? value * 60 : value;
    return "${seconds}s";
  }
  final int minutes = value > 0 ? value : SubjectEntity.defaultRestMinutes;
  return context.l10n.restMinutesChip(minutes);
}

class _ParticipantsProgressCard extends StatelessWidget {
  const _ParticipantsProgressCard({
    required this.total,
    required this.completedMembers,
    required this.pendingMembers,
    required this.progressByMember,
    required this.targetPerMember,
    required this.unit,
  });

  final int total;
  final List<GroupMemberEntity> completedMembers;
  final List<GroupMemberEntity> pendingMembers;
  final Map<String, int> progressByMember;
  final int targetPerMember;
  final GroupMetricUnit unit;

  @override
  Widget build(BuildContext context) => _GroupDataCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _DataSectionIcon(
              color: context.colorTokens.primary,
              child: Icon(
                Icons.groups_2_outlined,
                size: 24,
                color: context.colorTokens.primary,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Text(
                context.l10n.groupParticipantsDataTitle(total),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.black20.copyWith(
                  color: context.colorTokens.textBody,
                  fontSize: 19,
                ),
              ),
            ),
          ],
        ),
        const Gap(24),
        _ParticipantsSectionLabel(
          label: context.l10n.groupCompletedMembersTitle(
            completedMembers.length,
          ),
          color: _groupDataAccent(context),
        ),
        const Gap(14),
        if (completedMembers.isEmpty)
          _ParticipantsEmptyState(
            title: context.l10n.groupNoCompletedMembersTitle,
            subtitle: context.l10n.groupNoCompletedMembersSubtitle,
          )
        else
          for (final GroupMemberEntity member in completedMembers) ...[
            _ParticipantProgressRow(
              member: member,
              current: progressByMember[member.id] ?? 0,
              target: targetPerMember,
              unit: unit,
              isCompleted: true,
            ),
            const Gap(10),
          ],
        const Gap(22),
        _ParticipantsSectionLabel(
          label: context.l10n.groupPendingMembersTitle(pendingMembers.length),
          color: context.colorTokens.primary,
        ),
        const Gap(14),
        if (pendingMembers.isEmpty)
          Text(
            context.l10n.groupActivityAllCompletedToday,
            style: context.textStyles.bodyMedium.copyWith(fontSize: 13),
          )
        else
          for (final GroupMemberEntity member in pendingMembers) ...[
            _ParticipantProgressRow(
              member: member,
              current: progressByMember[member.id] ?? 0,
              target: targetPerMember,
              unit: unit,
              isCompleted: false,
            ),
            const Gap(10),
          ],
      ],
    ),
  );
}

class _GroupStatisticsCard extends StatelessWidget {
  const _GroupStatisticsCard({
    required this.totalPeriodValue,
    required this.completedSessions,
    required this.participants,
    required this.unit,
    required this.period,
  });

  final int totalPeriodValue;
  final int completedSessions;
  final int participants;
  final GroupMetricUnit unit;
  final LeaderboardPeriodType period;

  @override
  Widget build(BuildContext context) => _GroupDataCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _DataSectionIcon(
              color: context.colorTokens.primary,
              child: Icon(
                Icons.trending_up_rounded,
                size: 24,
                color: context.colorTokens.primary,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Text(
                context.l10n.groupStatisticsTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.black20.copyWith(
                  color: context.colorTokens.textBody,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const Gap(22),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.65,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _GroupStatItem(
              icon: Icons.local_fire_department_rounded,
              color: context.colorTokens.warning,
              value: context.l10n.unitDays(0),
              label: context.l10n.groupStreakStatLabel,
            ),
            _GroupStatItem(
              icon: Icons.access_time_rounded,
              color: context.colorTokens.primary,
              value: formatMetricValue(context, totalPeriodValue, unit),
              label: period == LeaderboardPeriodType.today
                  ? context.l10n.groupTodayTotalStatLabel
                  : context.l10n.groupPeriodTotalStatLabel,
            ),
            _GroupStatItem(
              icon: Icons.trending_up_rounded,
              color: _groupDataAccent(context),
              value: completedSessions.toString(),
              label: context.l10n.groupCompletedSessionsStatLabel,
            ),
            _GroupStatItem(
              icon: Icons.groups_2_outlined,
              color: context.colorTokens.info,
              value: participants.toString(),
              label: context.l10n.groupParticipantsStatLabel,
            ),
          ],
        ),
      ],
    ),
  );
}

class _GroupDataCard extends StatelessWidget {
  const _GroupDataCard({required this.child}) : padding = 20;

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(padding),
    decoration: AppSurfaces.content(context.colorTokens),
    child: child,
  );
}

class _FrequencyBadge extends StatelessWidget {
  const _FrequencyBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final Color accent = _groupDataAccent(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colorTokens.primaryVeryLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: context.textStyles.bodySmall.copyWith(
          color: accent,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DataSectionIcon extends StatelessWidget {
  const _DataSectionIcon({required this.child, required this.color});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
    ),
    alignment: Alignment.center,
    child: child,
  );
}

class _GroupDataDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: 1,
    color: context.colorTokens.borderUnfocused.withValues(alpha: 0.55),
  );
}

class _ActivityDataTile extends StatelessWidget {
  const _ActivityDataTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final Color accent = _groupDataAccent(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: accent),
          const Gap(6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.textHint,
              fontSize: 13,
              height: 1.1,
            ),
          ),
          const Gap(2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.textStyles.black20.copyWith(
              color: context.colorTokens.textBody,
              fontSize: 18,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    color: context.colorTokens.borderUnfocused.withValues(alpha: 0.55),
  );
}

class _ParticipantsSectionLabel extends StatelessWidget {
  const _ParticipantsSectionLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: context.textStyles.cardTitle.copyWith(color: color, fontSize: 15),
  );
}

class _ParticipantsEmptyState extends StatelessWidget {
  const _ParticipantsEmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: BoxDecoration(
      color: context.colorTokens.surfaceInnerLayer.withValues(alpha: 0.32),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Icon(
          Icons.groups_2_outlined,
          color: context.colorTokens.textHint.withValues(alpha: 0.55),
          size: 28,
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.cardTitle.copyWith(
                  color: context.colorTokens.textHint,
                ),
              ),
              const Gap(2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodyMedium.copyWith(
                  color: context.colorTokens.textHint,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ParticipantProgressRow extends StatelessWidget {
  const _ParticipantProgressRow({
    required this.member,
    required this.current,
    required this.target,
    required this.unit,
    required this.isCompleted,
  });

  final GroupMemberEntity member;
  final int current;
  final int target;
  final GroupMetricUnit unit;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final Color accent = _groupDataAccent(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.colorTokens.surfaceInnerLayer.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          GroupMemberAvatar(
            name: member.name,
            colorValue: member.avatarColorValue,
            avatar: member.avatar,
            size: 38,
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.cardTitle,
                ),
                const Gap(2),
                Row(
                  children: [
                    _StatusPill(
                      label: isCompleted
                          ? context.l10n.completedLabel
                          : context.l10n.pendingLabel,
                      isCompleted: isCompleted,
                    ),
                    const Gap(6),
                    Expanded(
                      child: Text(
                        progressLabel(context, current, target, unit),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodyMedium.copyWith(
                          color: context.colorTokens.textHint,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(6),
          Icon(
            isCompleted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 22,
            color: isCompleted ? accent : context.colorTokens.borderUnfocused,
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.isCompleted});

  final String label;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final Color accent = _groupDataAccent(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isCompleted
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: isCompleted ? accent : context.colorTokens.textHint,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _GroupStatItem extends StatelessWidget {
  const _GroupStatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: context.colorTokens.surfaceInnerLayer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 25),
          const Gap(8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.black20.copyWith(
                    color: color,
                    fontSize: 18,
                    height: 1,
                  ),
                ),
                const Gap(1),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.textHint,
                    fontSize: 12,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _groupDataAccent(BuildContext context) => context.colorTokens.primary;

int _targetForPeriod(int dailyTarget, LeaderboardPeriodType period) =>
    dailyTarget * _elapsedDaysForPeriod(period);

int _elapsedDaysForPeriod(LeaderboardPeriodType period) {
  final DateTime now = DateTime.now();
  return switch (period) {
    LeaderboardPeriodType.today => 1,
    LeaderboardPeriodType.thisWeek => now.weekday,
    LeaderboardPeriodType.thisMonth => now.day,
  };
}

class _ChatTab extends StatelessWidget {
  const _ChatTab({required this.controller, required this.group});

  final GroupsController controller;
  final GroupEntity group;

  @override
  Widget build(BuildContext context) => Obx(() {
    final List<GroupImageMessageEntity> messages = controller.imageMessagesFor(
      group.id,
    );

    return Column(
      children: [
        Expanded(
          child: controller.isLoadingChat.value && messages.isEmpty
              ? const _TabLoadingIndicator()
              : messages.isEmpty
              ? _ChatEmptyImages(
                  onTapSend: () => controller.onTapSendGroupImage(group.id),
                )
              : ListView.separated(
                  reverse: true,
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  itemCount: messages.length,
                  separatorBuilder: (_, _) => const Gap(14),
                  itemBuilder: (context, index) {
                    final GroupImageMessageEntity message =
                        messages[messages.length - index - 1];
                    return _ImageMessageBubble(
                      message: message,
                      isMine: message.senderId == controller.currentUserId,
                    );
                  },
                ),
        ),
        const Gap(12),
        _SendImageBar(
          isSending: controller.isSendingImage.value,
          onTap: () => controller.onTapSendGroupImage(group.id),
        ),
        Gap(8),
      ],
    );
  });
}

class _ImageMessageBubble extends StatelessWidget {
  const _ImageMessageBubble({required this.message, required this.isMine});

  final GroupImageMessageEntity message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final Uint8List imageBytes = base64Decode(message.imageBase64);

    return Row(
      mainAxisAlignment: isMine
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMine) ...[
          GroupMemberAvatar(
            name: message.senderName,
            colorValue: message.senderAvatarColorValue,
            avatar: message.senderAvatar,
            size: 42,
          ),
          const Gap(8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            decoration: BoxDecoration(
              color: isMine
                  ? context.colorTokens.primaryVeryLight
                  : context.colorTokens.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colorTokens.borderUnfocused.withValues(
                  alpha: 0.38,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.senderName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: isMine
                        ? context.colorTokens.primary
                        : const Color(0xFFE85888),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    imageBytes,
                    width: 220,
                    fit: BoxFit.cover,
                  ),
                ),
                const Gap(6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatClockTime(message.createdAt),
                    style: context.textStyles.bodyTiny,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isMine) ...[
          const Gap(8),
          GroupMemberAvatar(
            name: message.senderName,
            colorValue: message.senderAvatarColorValue,
            avatar: message.senderAvatar,
            size: 42,
          ),
        ],
      ],
    );
  }
}

class _ChatEmptyImages extends StatelessWidget {
  const _ChatEmptyImages({required this.onTapSend});

  final VoidCallback onTapSend;

  @override
  Widget build(BuildContext context) => Center(
    child: AppEmptyState(
      icon: Icons.image_outlined,
      title: context.l10n.groupNoImagesTitle,
      description: context.l10n.groupNoImagesDescription,
      actionLabel: context.l10n.groupSendImageButton,
      onTapAction: onTapSend,
    ),
  );
}

class _SendImageBar extends StatelessWidget {
  const _SendImageBar({required this.isSending, required this.onTap});

  final bool isSending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: isSending ? () {} : onTap,
    pressedScale: 0.98,
    child: Container(
      height: 56,
      padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: context.colorTokens.borderUnfocused.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Icon(
              Icons.image_outlined,
              color: context.colorTokens.primary,
              size: 22,
            ),
          ),
          const Gap(10),
          Expanded(
            child: Text(
              isSending
                  ? context.l10n.groupSendingImage
                  : context.l10n.groupSendImageButton,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.cardTitle.copyWith(fontSize: 15),
            ),
          ),
          const Gap(10),
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: context.colorTokens.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: isSending
                ? Padding(
                    padding: const EdgeInsets.all(11),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colorTokens.primaryForeground,
                    ),
                  )
                : Icon(
                    Icons.add_photo_alternate_outlined,
                    color: context.colorTokens.primaryForeground,
                    size: 22,
                  ),
          ),
        ],
      ),
    ),
  );
}

class _DetailIconButton extends StatelessWidget {
  const _DetailIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    child: BounceTap(
      onTap: onTap,
      pressedScale: 0.92,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: AppSpacing.minTapTarget,
        height: AppSpacing.minTapTarget,
        child: Icon(icon, size: 24, color: context.colorTokens.primary),
      ),
    ),
  );
}

class _DetailBackButton extends StatelessWidget {
  const _DetailBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: MaterialLocalizations.of(context).backButtonTooltip,
    child: BounceTap(
      onTap: onTap,
      pressedScale: 0.92,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: AppSpacing.minTapTarget,
        height: AppSpacing.minTapTarget,
        child: Center(
          child: AppIcon(
            "left_back",
            size: 20,
            color: context.colorTokens.primary,
          ),
        ),
      ),
    ),
  );
}

Future<void> _showGroupActionsSheet(
  BuildContext context,
  GroupsController controller,
) => showModalBottomSheet<void>(
  context: context,
  backgroundColor: context.colorTokens.transparent,
  barrierColor: context.colorTokens.black.withValues(alpha: 0.42),
  builder: (sheetContext) => _GroupActionsSheet(
    onManageMembers: () {
      Navigator.of(sheetContext).pop();
      controller.onManageMembers();
    },
    onEditGroup: () {
      Navigator.of(sheetContext).pop();
      controller.onTapEditGroup();
    },
    onLeaveGroup: () {
      Navigator.of(sheetContext).pop();
      controller.onConfirmLeaveGroup();
    },
  ),
);

class _GroupActionsSheet extends StatelessWidget {
  const _GroupActionsSheet({
    required this.onManageMembers,
    required this.onEditGroup,
    required this.onLeaveGroup,
  });

  final VoidCallback onManageMembers;
  final VoidCallback onEditGroup;
  final VoidCallback onLeaveGroup;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorTokens.textHint.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const Gap(14),
            _GroupActionRow(
              icon: Icons.groups_2_outlined,
              label: context.l10n.manageMembersTitle,
              onTap: onManageMembers,
            ),
            const Gap(8),
            _GroupActionRow(
              icon: Icons.edit_outlined,
              label: context.l10n.editGroupLabel,
              onTap: onEditGroup,
            ),
            const Gap(8),
            _GroupActionRow(
              icon: Icons.logout_rounded,
              label: context.l10n.leaveGroupLabel,
              isDestructive: true,
              onTap: onLeaveGroup,
            ),
          ],
        ),
      ),
    ),
  );
}

class _GroupActionRow extends StatelessWidget {
  const _GroupActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color color = isDestructive
        ? context.colorTokens.error
        : context.colorTokens.primary;

    return BounceTap(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDestructive
              ? context.colorTokens.error.withValues(alpha: 0.08)
              : context.colorTokens.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: context.colorTokens.borderUnfocused.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 38,
              decoration: BoxDecoration(
                color: isDestructive ? color : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                color: isDestructive ? context.colorTokens.white : color,
                size: 22,
              ),
            ),
            const Gap(14),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.cardTitle.copyWith(
                  color: isDestructive ? color : context.colorTokens.textBody,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}

class _GroupIcon extends StatelessWidget {
  const _GroupIcon({
    required this.theme,
    required this.size,
    required this.iconSize,
  });

  final GroupThemeType theme;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: context.colorTokens.primaryGradient,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: AppIcon(
        theme.iconName,
        size: iconSize,
        color: context.colorTokens.primaryForeground,
      ),
    ),
  );
}

GroupMemberEntity? _leaderFor(GroupEntity group) {
  for (final GroupMemberEntity member in group.members) {
    if (member.id == group.ownerId || member.role == "owner") {
      return member;
    }
  }
  return group.members.isEmpty ? null : group.members.first;
}

class _GroupsEmptyState extends StatelessWidget {
  const _GroupsEmptyState({
    required this.onCreateGroup,
    required this.onTapFriends,
  });

  final VoidCallback onCreateGroup;
  final VoidCallback onTapFriends;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
    children: [
      _FriendsCard(groupCount: 0, onTap: onTapFriends),
      const Gap(AppSpacing.betweenRelated),
      AppEmptyState(
        icon: Icons.groups_2_outlined,
        title: context.l10n.groupsEmptyTitle,
        description: context.l10n.groupsEmptyDescription,
        actionLabel: context.l10n.groupsEmptyButton,
        onTapAction: onCreateGroup,
      ),
      const Gap(AppSpacing.betweenSections),
      Center(child: _BenefitsHeader(label: context.l10n.groupsBenefitsHeader)),
      const Gap(AppSpacing.betweenRelated),
      Row(
        children: [
          Expanded(
            child: _BenefitTile(
              icon: Icons.leaderboard_rounded,
              label: context.l10n.leaderboardTitle,
            ),
          ),
          const Gap(AppSpacing.titleToDescription),
          Expanded(
            child: _BenefitTile(
              icon: Icons.show_chart_rounded,
              label: context.l10n.progressTitle,
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
}

class _GroupsLoadErrorState extends StatelessWidget {
  const _GroupsLoadErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
    children: [
      AppEmptyState(
        icon: Icons.cloud_off_rounded,
        title: "Não foi possível carregar os grupos",
        description:
            "A conexão demorou mais do que o esperado. Seus grupos podem existir, mas não conseguimos buscar agora.",
        actionLabel: "Tentar novamente",
        onTapAction: onRetry,
      ),
    ],
  );
}

class _GroupsLoadingSkeleton extends StatelessWidget {
  const _GroupsLoadingSkeleton();

  @override
  Widget build(BuildContext context) => AppSkeleton(
    child: ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
      children: const [
        _SkeletonGroupCard(isFriends: true),
        Gap(AppSpacing.betweenRelated),
        _SkeletonGroupCard(),
        Gap(AppSpacing.betweenRelated),
        _SkeletonGroupCard(),
        Gap(AppSpacing.betweenRelated),
        _SkeletonGroupCard(),
      ],
    ),
  );
}

class _SkeletonGroupCard extends StatelessWidget {
  const _SkeletonGroupCard({this.isFriends = false});

  final bool isFriends;

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(minHeight: isFriends ? 78 : 124),
    padding: const EdgeInsets.all(14),
    decoration: AppSurfaces.content(context.colorTokens),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeletonCircle(
          size: isFriends ? 46 : 72,
          color: context.colorTokens.primaryVeryLight,
        ),
        const Gap(14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeletonBox(width: 96, height: 18, radius: 8),
              Gap(8),
              AppSkeletonBox(height: 12, radius: 6),
              Gap(10),
              _SkeletonAvatarRow(),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SkeletonAvatarRow extends StatelessWidget {
  const _SkeletonAvatarRow();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 86,
    height: 30,
    child: Stack(
      children: [
        for (int index = 0; index < 3; index++)
          Positioned(
            left: index * 20,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: context.colorTokens.surfaceInnerLayer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colorTokens.surface,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    ),
  );
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
