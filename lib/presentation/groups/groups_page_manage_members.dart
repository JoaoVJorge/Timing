part of "groups_page.dart";

// The "manage members" screen reached from a group's actions sheet.

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
