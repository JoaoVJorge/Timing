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
          title: context.l10n.groupMembersPageTitle,
          showBackButton: true,
          onBack: controller.onBackToGroupDetails,
        ),
        const Gap(12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
            children: [
              // The leader answers who is waiting here; everyone else just
              // sees which group this is.
              if (currentUserIsLeader)
                _JoinRequestsCard(controller: controller)
              else
                _ManageGroupSummaryCard(group: group),
              const Gap(12),
              if (leader != null) ...[
                _MembersSectionLabel(label: context.l10n.groupLeaderLabel),
                const Gap(8),
                _MemberSwipeActions(
                  controller: controller,
                  member: leader,
                  roleLabel: context.l10n.groupLeaderRoleLabel,
                  badgeLabel: context.l10n.groupLeaderLabel,
                  isFirst: true,
                  isLast: true,
                  isStandalone: true,
                  canTransferLeadership: false,
                  canManageMember: false,
                ),
                const Gap(12),
              ],
              if (members.isNotEmpty) ...[
                _MembersSectionLabel(label: context.l10n.groupMembersLabel),
                const Gap(8),
                _MemberRowGroup(
                  controller: controller,
                  group: group,
                  members: members,
                  roleLabel: context.l10n.groupMemberRoleLabel,
                  canTransferLeadership: currentUserIsLeader,
                ),
              ],
              // Every member may bring someone in; the leader answers the
              // request that follows.
              const Gap(14),
              _AddMemberButton(onTap: controller.onTapInviteMembers),
            ],
          ),
        ),
      ],
    );
  }
}

/// Each member uses the same standalone surface as the leader's row.
class _MemberRowGroup extends StatelessWidget {
  const _MemberRowGroup({
    required this.controller,
    required this.group,
    required this.members,
    required this.roleLabel,
    required this.canTransferLeadership,
  });

  final GroupsController controller;
  final GroupEntity group;
  final List<GroupMemberEntity> members;
  final String roleLabel;
  final bool canTransferLeadership;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (int index = 0; index < members.length; index++) ...[
        _MemberSwipeActions(
          controller: controller,
          member: members[index],
          roleLabel: roleLabel,
          isFirst: true,
          isLast: true,
          isStandalone: true,
          canTransferLeadership: canTransferLeadership,
          canManageMember: controller.canManageMember(group, members[index]),
        ),
        if (index < members.length - 1) const Gap(10),
      ],
    ],
  );
}

/// The leader's answer list at the top of the member screen: who asked to
/// join, through the group's link or through a member's invitation.
class _JoinRequestsCard extends StatelessWidget {
  const _JoinRequestsCard({required this.controller});

  final GroupsController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final List<GroupJoinRequestEntity> requests = controller.joinRequests
        .toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppSurfaces.content(context.colorTokens),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: context.colorTokens.primaryVeryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.how_to_reg_rounded,
                  size: 22,
                  color: context.colorTokens.primary,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.groupJoinRequestsTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.cardTitle,
                    ),
                    const Gap(2),
                    Text(
                      context.l10n.groupJoinRequestsCount(requests.length),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyMedium.copyWith(
                        color: requests.isEmpty
                            ? context.colorTokens.textHint
                            : context.colorTokens.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.isLoadingJoinRequests.value)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colorTokens.primary,
                  ),
                ),
            ],
          ),
          if (requests.isEmpty) ...[
            const Gap(10),
            Text(
              context.l10n.groupJoinRequestsEmptyHint,
              style: context.textStyles.bodyMedium.copyWith(
                color: context.colorTokens.textHint,
              ),
            ),
          ],
          for (final GroupJoinRequestEntity request in requests) ...[
            const Gap(10),
            Divider(height: 1, color: context.colorTokens.divider),
            const Gap(10),
            _JoinRequestRow(controller: controller, request: request),
          ],
        ],
      ),
    );
  });
}

class _JoinRequestRow extends StatelessWidget {
  const _JoinRequestRow({required this.controller, required this.request});

  final GroupsController controller;
  final GroupJoinRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final bool isAnswering = controller.answeringJoinRequestIds.contains(
      request.id,
    );
    final String? invitedBy = request.invitedByName;
    return IgnorePointer(
      ignoring: isAnswering,
      child: Opacity(
        opacity: isAnswering ? 0.5 : 1,
        child: Row(
          children: [
            GroupMemberAvatar(
              name: request.userName,
              colorValue: request.accentColorValue,
              avatar: request.avatar,
              avatarIconIndex: request.avatarIconIndex,
              size: 42,
              useSolidFallbackBackground: true,
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyLarge.copyWith(fontSize: 15),
                  ),
                  const Gap(2),
                  Text(
                    invitedBy == null
                        ? context.l10n.groupJoinRequestFromLink
                        : context.l10n.groupJoinRequestInvitedBy(invitedBy),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyMedium.copyWith(
                      color: context.colorTokens.textHint,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
            _JoinRequestButton(
              icon: Icons.close_rounded,
              color: context.colorTokens.error,
              isFilled: false,
              onTap: () =>
                  controller.onAnswerJoinRequest(request, approve: false),
            ),
            const Gap(8),
            _JoinRequestButton(
              icon: Icons.check_rounded,
              color: context.colorTokens.primary,
              isFilled: true,
              onTap: () =>
                  controller.onAnswerJoinRequest(request, approve: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinRequestButton extends StatelessWidget {
  const _JoinRequestButton({
    required this.icon,
    required this.color,
    required this.isFilled,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final bool isFilled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.94,
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isFilled ? color : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: isFilled
            ? null
            : Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Icon(
        icon,
        size: 20,
        color: isFilled ? context.colorTokens.white : color,
      ),
    ),
  );
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
        _GroupIcon(group: group, size: 54, iconSize: 26),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizedGroupName(context, group),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.black20,
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
    this.isStandalone = false,
    this.badgeLabel,
    this.friendshipStatusLabel,
  });

  final GroupMemberEntity member;
  final String roleLabel;
  final bool isFirst;
  final bool isLast;

  /// A row shown on its own, outside a group of rows, draws its own outline.
  final bool isStandalone;
  final String? badgeLabel;
  final String? friendshipStatusLabel;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 64),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(18) : Radius.zero,
        bottom: isLast ? const Radius.circular(18) : Radius.zero,
      ),
      border: !isStandalone
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
          avatarIconIndex: member.avatarIconIndex,
          size: 44,
          useSolidFallbackBackground: true,
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
                friendshipStatusLabel == null
                    ? roleLabel
                    : "$roleLabel · $friendshipStatusLabel",
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
      ],
    ),
  );
}

class _MemberSwipeActions extends StatelessWidget {
  const _MemberSwipeActions({
    required this.controller,
    required this.member,
    required this.roleLabel,
    required this.isFirst,
    required this.isLast,
    required this.canTransferLeadership,
    required this.canManageMember,
    this.isStandalone = false,
    this.badgeLabel,
  });

  final GroupsController controller;
  final GroupMemberEntity member;
  final String roleLabel;
  final bool isFirst;
  final bool isLast;
  final bool isStandalone;

  /// Only the leader hands the leadership over.
  final bool canTransferLeadership;

  /// Only the leader may remove another member.
  final bool canManageMember;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    if (controller.isCurrentUser(member)) {
      return _MemberRow(
        member: member,
        roleLabel: roleLabel,
        badgeLabel: badgeLabel,
        isFirst: isFirst,
        isLast: isLast,
        isStandalone: isStandalone,
      );
    }
    return Obx(() {
      final bool isFriend = controller.isFriend(member.id);
      final bool hasSentRequest =
          controller.sentFriendRequestFor(member.id) != null;
      final bool hasIncomingRequest = controller.hasIncomingFriendRequest(
        member.id,
      );
      final String? statusLabel = isFriend
          ? context.l10n.friendStatusLabel
          : hasSentRequest
          ? context.l10n.pendingLabel
          : hasIncomingRequest
          ? context.l10n.friendRequestReceivedLabel
          : null;
      final bool isUpdatingFriendship = controller.updatingFriendshipMemberIds
          .contains(member.id);
      final bool isUpdatingMembership = controller.updatingGroupMemberIds
          .contains(member.id);

      return IgnorePointer(
        ignoring: isUpdatingFriendship || isUpdatingMembership,
        child: SwipeRevealActions(
          leadingActions: [
            SwipeRevealAction(
              iconData: isFriend
                  ? Icons.person_remove_alt_1_rounded
                  : hasSentRequest
                  ? Icons.close_rounded
                  : Icons.person_add_alt_1_rounded,
              background: context.colorTokens.transparent,
              iconColor: isFriend
                  ? context.colorTokens.error
                  : context.colorTokens.primary,
              onTap: () => controller.onTapFriendshipMemberAction(member),
            ),
            if (canTransferLeadership)
              SwipeRevealAction(
                iconData: Icons.workspace_premium_outlined,
                background: context.colorTokens.transparent,
                iconColor: context.colorTokens.primary,
                onTap: () => controller.onTransferGroupLeadership(member),
              ),
          ],
          actions: [
            if (canManageMember)
              SwipeRevealAction(
                iconData: Icons.close_rounded,
                background: context.colorTokens.transparent,
                iconColor: context.colorTokens.error,
                onTap: () => controller.onRemoveGroupMember(member),
              ),
            SwipeRevealAction(
              iconData: Icons.flag_outlined,
              background: context.colorTokens.transparent,
              iconColor: context.colorTokens.error,
              onTap: () => controller.onReportGroupMember(member),
            ),
          ],
          child: _MemberRow(
            member: member,
            roleLabel: roleLabel,
            badgeLabel: badgeLabel,
            friendshipStatusLabel: statusLabel,
            isFirst: isFirst,
            isLast: isLast,
            isStandalone: isStandalone,
          ),
        ),
      );
    });
  }
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
