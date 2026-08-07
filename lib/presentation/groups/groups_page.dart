import "dart:convert";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/entities/group_image_message_entity.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/groups/group_leaderboard_formatters.dart";
import "package:help_out/presentation/groups/groups_controller.dart";
import "package:help_out/presentation/groups/widgets/current_user_rank_card.dart";
import "package:help_out/presentation/groups/widgets/group_member_avatar.dart";
import "package:help_out/presentation/groups/widgets/groups_header.dart";
import "package:help_out/presentation/groups/widgets/leaderboard_tile.dart";
import "package:help_out/shared/widgets/app_empty_state.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
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

    return Obx(() {
      if (controller.isShowingMemberManagement.value) {
        return AppScaffold(body: _ManageMembersView(controller: controller));
      }

      if (controller.isShowingGroupDetails.value) {
        return AppScaffold(body: _GroupDetailsView(controller: controller));
      }

      return AppScaffold(body: _GroupsHomeView(controller: controller));
    });
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

          if (controller.groups.isEmpty) {
            return _GroupsEmptyState(
              onCreateGroup: controller.onTapCreateGroup,
              onJoinWithCode: controller.onTapJoinWithCode,
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

      final Widget selectedContent = switch (controller
          .selectedDetailsTab
          .value) {
        GroupDetailsTab.ranking => _RankingTab(
          controller: controller,
          group: group,
          members: members,
        ),
        GroupDetailsTab.goals => _GoalsTab(group: group),
        GroupDetailsTab.chat => _ChatTab(controller: controller, group: group),
      };

      return Column(
        children: [
          Gap(4),
          _GroupDetailsHeader(
            group: group,
            onBack: controller.onBackToGroupList,
            onActions: () => _showGroupActionsSheet(context, controller),
          ),
          const Gap(8),
          _GroupDetailsTabs(
            selectedTab: controller.selectedDetailsTab.value,
            onSelectTab: controller.onSelectDetailsTab,
          ),
          const Gap(10),
          Expanded(
            child: controller.selectedDetailsTab.value == GroupDetailsTab.chat
                ? selectedContent
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.betweenSections,
                    ),
                    child: selectedContent,
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
            color: context.colorTokens.black,
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

    return Column(
      children: [
        const Gap(10),
        AppTopBar(
          title: "Gerenciar membros",
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
                _MembersSectionLabel(label: "Líder"),
                const Gap(8),
                _MemberRow(
                  member: leader,
                  roleLabel: "Líder do grupo",
                  badgeLabel: "Líder",
                  isFirst: true,
                  isLast: true,
                ),
                const Gap(12),
              ],
              _MembersSectionLabel(label: "Membros"),
              const Gap(8),
              Container(
                decoration: AppSurfaces.rowGroup(context.colorTokens),
                child: Column(
                  children: [
                    for (int index = 0; index < members.length; index++) ...[
                      _MemberRow(
                        member: members[index],
                        roleLabel: "Membro",
                        isFirst: index == 0,
                        isLast: index == members.length - 1,
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
              const Gap(14),
              _AddMemberButton(onTap: controller.onTapFriends),
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
                "${group.members.length} participantes",
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
  });

  final GroupMemberEntity member;
  final String roleLabel;
  final bool isFirst;
  final bool isLast;
  final String? badgeLabel;

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
        const Gap(8),
        Icon(
          Icons.more_vert_rounded,
          size: 22,
          color: context.colorTokens.textBody,
        ),
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
            "Adicionar membro",
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.black20.copyWith(fontSize: 22),
                ),
                const Gap(4),
                Text(
                  _groupDescription(context, group),
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
                  _friendsCardSubtitle(context, groupCount),
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
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 84,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _DetailBackButton(onTap: onBack),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _DetailIconButton(
                icon: Icons.more_vert_rounded,
                semanticLabel: "Ações do grupo",
                onTap: onActions,
              ),
            ),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _GroupIcon(theme: group.theme, size: 68, iconSize: 32),
                  const Gap(14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 174),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizedGroupName(context, group),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.black28.copyWith(
                            color: context.colorTokens.black,
                            fontSize: 28,
                            height: 1,
                          ),
                        ),
                        const Gap(5),
                        Text(
                          "${group.members.length} membros",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.caption.copyWith(
                            color: context.colorTokens.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _GroupDetailsTabs extends StatelessWidget {
  const _GroupDetailsTabs({
    required this.selectedTab,
    required this.onSelectTab,
  });

  final GroupDetailsTab selectedTab;
  final ValueChanged<GroupDetailsTab> onSelectTab;

  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: context.colorTokens.borderUnfocused.withValues(alpha: 0.45),
      ),
      boxShadow: [
        BoxShadow(
          color: context.colorTokens.surfaceShadow.withValues(alpha: 0.08),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        _TabPill(
          label: "Ranking",
          isSelected: selectedTab == GroupDetailsTab.ranking,
          onTap: () => onSelectTab(GroupDetailsTab.ranking),
        ),
        _TabPill(
          label: "Metas",
          isSelected: selectedTab == GroupDetailsTab.goals,
          onTap: () => onSelectTab(GroupDetailsTab.goals),
        ),
        _TabPill(
          label: "Chat",
          isSelected: selectedTab == GroupDetailsTab.chat,
          onTap: () => onSelectTab(GroupDetailsTab.chat),
        ),
      ],
    ),
  );
}

class _GoalsTab extends StatelessWidget {
  const _GoalsTab({required this.group});

  final GroupEntity group;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _GroupInfoCard(
        icon: Icons.track_changes_rounded,
        title: "Meta do grupo",
        value: _goalTitle(context, group),
        description: _goalDescription(context, group),
      ),
      const Gap(10),
      _GroupInfoCard(
        icon: Icons.shield_outlined,
        title: "Regra principal",
        description: _ruleDescription(context, group),
      ),
      const Gap(10),
      _ProgressInfoCard(memberCount: group.members.length),
      const Gap(10),
      _GroupInfoCard(
        icon: Icons.flag_outlined,
        title: "Próximo marco",
        value:
            "${(group.members.length * 0.7).ceil()}/${group.members.length} membros",
        description: "para liberar o selo \"Foco Total\"",
      ),
    ],
  );
}

class _GroupInfoCard extends StatelessWidget {
  const _GroupInfoCard({
    required this.icon,
    required this.title,
    required this.description,
    this.value,
  });

  final IconData icon;
  final String title;
  final String? value;
  final String description;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: AppSurfaces.content(context.colorTokens),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: context.colorTokens.primary),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.textStyles.cardTitle),
              if (value != null) ...[
                const Gap(3),
                Text(
                  value!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.black20.copyWith(fontSize: 19),
                ),
              ],
              const Gap(6),
              Text(
                description,
                style: context.textStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  height: 1.24,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ProgressInfoCard extends StatelessWidget {
  const _ProgressInfoCard({required this.memberCount});

  final int memberCount;

  @override
  Widget build(BuildContext context) {
    final int completed = memberCount == 0
        ? 0
        : (memberCount * 0.45).round().clamp(1, memberCount).toInt();
    final double progress = memberCount == 0 ? 0 : completed / memberCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppSurfaces.content(context.colorTokens),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.groups_2_outlined,
            size: 27,
            color: context.colorTokens.primary,
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Progresso coletivo", style: context.textStyles.cardTitle),
                const Gap(5),
                Row(
                  children: [
                    Text(
                      "${(progress * 100).round()}%",
                      style: context.textStyles.black20,
                    ),
                    const Gap(12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          color: context.colorTokens.primary,
                          backgroundColor: context.colorTokens.surfaceInnerLayer
                              .withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  "$completed/$memberCount membros concluíram hoje",
                  style: context.textStyles.bodyMedium.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
              ? const Center(child: CircularProgressIndicator())
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
                    _messageTime(message.createdAt),
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
      title: "Nenhuma imagem ainda",
      description: "Envie a primeira imagem do grupo.",
      actionLabel: "Enviar imagem",
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
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: context.colorTokens.borderUnfocused.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.image_outlined, color: context.colorTokens.primary),
          const Gap(10),
          Expanded(
            child: Text(
              isSending ? "Enviando imagem..." : "Enviar imagem",
              style: context.textStyles.cardTitle.copyWith(fontSize: 15),
            ),
          ),
          Container(
            width: 42,
            height: 42,
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

String _messageTime(DateTime date) {
  final DateTime local = date.toLocal();
  return "${local.hour.toString().padLeft(2, "0")}:"
      "${local.minute.toString().padLeft(2, "0")}";
}

// ignore: unused_element
class _MockChatTab extends StatelessWidget {
  const _MockChatTab({required this.controller, required this.group});

  final GroupsController controller;
  final GroupEntity group;

  @override
  Widget build(BuildContext context) {
    final List<GroupMemberEntity> members = group.members.take(3).toList();

    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              reverse: true,
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ChatBubble(
                    member: members.isEmpty ? null : members.first,
                    message: "Fechei 30 min hoje. Bora pra mais!",
                    time: "09:15",
                    isMine: false,
                  ),
                  const Gap(14),
                  _ChatBubble(
                    member: members.length < 2 ? null : members[1],
                    message: "Boa! Vou começar agora. Foco total!",
                    time: "09:18",
                    isMine: true,
                  ),
                  const Gap(14),
                  _ChatBubble(
                    member: members.length < 3 ? null : members[2],
                    message: "Bora manter a meta do grupo",
                    time: "09:19",
                    isMine: false,
                  ),
                ],
              ),
            ),
          ),
        ),
        const Gap(12),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: context.colorTokens.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: context.colorTokens.borderUnfocused.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.attach_file_rounded,
                color: context.colorTokens.textHint,
              ),
              const Gap(10),
              Expanded(
                child: Text(
                  "Enviar mensagem...",
                  style: context.textStyles.caption,
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: context.colorTokens.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: context.colorTokens.primaryForeground,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        Gap(8),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.member,
    required this.message,
    required this.time,
    required this.isMine,
  });

  final GroupMemberEntity? member;
  final String message;
  final String time;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final GroupMemberEntity effectiveMember =
        member ??
        const GroupMemberEntity(
          id: "",
          name: "Membro",
          avatarColorValue: 0xFF6B9528,
          todaySeconds: 0,
          weekSeconds: 0,
          monthSeconds: 0,
        );

    return Row(
      mainAxisAlignment: isMine
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMine) ...[
          GroupMemberAvatar(
            name: effectiveMember.name,
            colorValue: effectiveMember.avatarColorValue,
            avatar: effectiveMember.avatar,
            size: 42,
          ),
          const Gap(8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 14, 10),
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
                  effectiveMember.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: isMine
                        ? context.colorTokens.primary
                        : const Color(0xFFE85888),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(4),
                Text(message, style: context.textStyles.bodyMedium),
                const Gap(4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(time, style: context.textStyles.bodyTiny),
                ),
              ],
            ),
          ),
        ),
        if (isMine) ...[
          const Gap(8),
          GroupMemberAvatar(
            name: effectiveMember.name,
            colorValue: effectiveMember.avatarColorValue,
            avatar: effectiveMember.avatar,
            size: 42,
          ),
        ],
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: BounceTap(
      onTap: onTap,
      pressedScale: 0.98,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isSelected ? context.colorTokens.primaryGradient : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodyMedium.copyWith(
            color: isSelected
                ? context.colorTokens.primaryForeground
                : context.colorTokens.textBody,
            fontWeight: FontWeight.w800,
          ),
        ),
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
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
            label: "Gerenciar membros",
            onTap: onManageMembers,
          ),
          const Gap(8),
          _GroupActionRow(
            icon: Icons.edit_outlined,
            label: "Editar grupo",
            onTap: onEditGroup,
          ),
          const Gap(8),
          _GroupActionRow(
            icon: Icons.logout_rounded,
            label: "Sair do grupo",
            isDestructive: true,
            onTap: onLeaveGroup,
          ),
        ],
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
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 22),
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

String _groupDescription(BuildContext context, GroupEntity group) {
  final String metric = groupMetricDescription(context, group.theme);
  return switch (context.languageCode) {
    "pt" => "Compartilhando $metric e superando desafios.",
    "es" => "Compartiendo $metric y superando retos.",
    _ => "Sharing $metric and beating challenges together.",
  };
}

GroupMemberEntity? _leaderFor(GroupEntity group) {
  for (final GroupMemberEntity member in group.members) {
    if (member.id == group.ownerId || member.role == "owner") {
      return member;
    }
  }
  return group.members.isEmpty ? null : group.members.first;
}

String _friendsCardSubtitle(BuildContext context, int groupCount) =>
    switch (context.languageCode) {
      "pt" => "Solicitações, convites e $groupCount em grupos",
      "es" => "Solicitudes, invitaciones y $groupCount en grupos",
      _ => "Requests, invites and $groupCount in groups",
    };

String _goalTitle(BuildContext context, GroupEntity group) {
  final String metric = groupMetricDescription(context, group.theme);
  return switch (context.languageCode) {
    "pt" => "Manter $metric todos os dias",
    "es" => "Mantener $metric todos los dias",
    _ => "Keep $metric every day",
  };
}

String _goalDescription(BuildContext context, GroupEntity group) {
  final String metric = groupMetricDescription(context, group.theme);
  return switch (context.languageCode) {
    "pt" =>
      "Cada participante deve registrar progresso em $metric para manter a sequência do grupo.",
    "es" =>
      "Cada participante debe registrar progreso en $metric para mantener la racha del grupo.",
    _ =>
      "Each member should log progress in $metric to keep the group streak going.",
  };
}

String _ruleDescription(BuildContext context, GroupEntity group) {
  final String metric = groupMetricDescription(context, group.theme);
  return switch (context.languageCode) {
    "pt" =>
      "Registre pelo menos uma atividade de $metric por dia. Manter a sequência fortalece o grupo.",
    "es" =>
      "Registra al menos una actividad de $metric por día. Mantener la racha fortalece el grupo.",
    _ =>
      "Log at least one $metric activity per day. Keeping the streak strengthens the group.",
  };
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

class _GroupsLoadingSkeleton extends StatelessWidget {
  const _GroupsLoadingSkeleton();

  @override
  Widget build(BuildContext context) => ListView(
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
        Container(
          width: isFriends ? 46 : 72,
          height: isFriends ? 46 : 72,
          decoration: BoxDecoration(
            color: context.colorTokens.primaryVeryLight,
            shape: BoxShape.circle,
          ),
        ),
        const Gap(14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonBox(width: 96, height: 18, radius: 8),
              Gap(8),
              _SkeletonBox(height: 12, radius: 6),
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF343434)
                    : const Color(0xFFE5E5E5),
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

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height, this.width, this.radius = 14});

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveColor = isDarkMode
        ? const Color(0xFF343434)
        : const Color(0xFFE5E5E5);

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
