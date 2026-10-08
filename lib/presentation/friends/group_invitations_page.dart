import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/group_invitation_entity.dart";
import "package:timing/core/domain/entities/sent_group_invitation_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/friends/friends_controller.dart";
import "package:timing/presentation/friends/widgets/friends_shared.dart";
import "package:timing/presentation/friends/widgets/friends_request_widgets.dart";
import "package:timing/presentation/groups/widgets/group_member_avatar.dart";
import "package:timing/shared/widgets/app_icon.dart";

import "package:timing/theme/app_spacing.dart";

enum GroupInvitationsMode { incoming, sent }

class GroupInvitationsPage extends StatefulWidget {
  const GroupInvitationsPage({super.key});

  @override
  State<GroupInvitationsPage> createState() => _GroupInvitationsPageState();
}

class _GroupInvitationsPageState extends State<GroupInvitationsPage> {
  final FriendsController controller = Get.find();
  GroupInvitationsMode selectedMode = GroupInvitationsMode.incoming;

  @override
  Widget build(BuildContext context) =>
      FriendsRequestLayout<GroupInvitationsMode>(
        title: context.l10n.groupInvitationsTitle,
        selectedMode: selectedMode,
        incomingMode: GroupInvitationsMode.incoming,
        sentMode: GroupInvitationsMode.sent,
        onSelect: (mode) => setState(() => selectedMode = mode),
        child: Obx(
          () => switch (selectedMode) {
            GroupInvitationsMode.incoming => _IncomingInvitationsList(
              invitations: controller.groupInvitations.toList(),
              acceptingInvitationIds: controller.acceptingGroupInvitationIds
                  .toSet(),
              onAccept: controller.acceptGroupInvitation,
              onDecline: controller.declineGroupInvitation,
            ),
            GroupInvitationsMode.sent => _SentInvitationsList(
              invitations: controller.sentGroupInvitations.toList(),
              onCancel: controller.cancelGroupInvitation,
            ),
          },
        ),
      );
}

class _IncomingInvitationsList extends StatelessWidget {
  const _IncomingInvitationsList({
    required this.invitations,
    required this.acceptingInvitationIds,
    required this.onAccept,
    required this.onDecline,
  });

  final List<GroupInvitationEntity> invitations;
  final Set<String> acceptingInvitationIds;
  final ValueChanged<GroupInvitationEntity> onAccept;
  final ValueChanged<GroupInvitationEntity> onDecline;

  @override
  Widget build(BuildContext context) {
    if (invitations.isEmpty) {
      return FriendsRequestEmptyState(
        icon: Icons.inbox_rounded,
        title: context.l10n.groupInvitationsReceivedEmptyTitle,
        description: context.l10n.groupInvitationsReceivedEmptyDescription,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 18),
      itemCount: invitations.length,
      separatorBuilder: (context, index) => const Gap(12),
      itemBuilder: (context, index) {
        final GroupInvitationEntity invitation = invitations[index];
        return _IncomingInvitationCard(
          invitation: invitation,
          isAccepting: acceptingInvitationIds.contains(invitation.id),
          onAccept: () => onAccept(invitation),
          onDecline: () => onDecline(invitation),
        );
      },
    );
  }
}

class _IncomingInvitationCard extends StatelessWidget {
  const _IncomingInvitationCard({
    required this.invitation,
    required this.isAccepting,
    required this.onAccept,
    required this.onDecline,
  });

  final GroupInvitationEntity invitation;
  final bool isAccepting;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) => FriendsRequestCard(
    child: Column(
      children: [
        _GroupInvitationHeader(
          groupName: invitation.groupName,
          theme: invitation.theme,
          subtitle: context.l10n.groupInvitationFrom(invitation.inviterName),
        ),
        const Gap(14),
        FriendsRequestActions(
          isAccepting: isAccepting,
          onAccept: onAccept,
          onDecline: onDecline,
        ),
      ],
    ),
  );
}

class _SentInvitationsList extends StatelessWidget {
  const _SentInvitationsList({
    required this.invitations,
    required this.onCancel,
  });

  final List<SentGroupInvitationEntity> invitations;
  final ValueChanged<SentGroupInvitationEntity> onCancel;

  @override
  Widget build(BuildContext context) {
    if (invitations.isEmpty) {
      return FriendsRequestEmptyState(
        icon: Icons.send_rounded,
        title: context.l10n.groupInvitationsSentEmptyTitle,
        description: context.l10n.groupInvitationsSentEmptyDescription,
      );
    }

    final List<_SentGroupInvitationBucket> groups =
        _SentGroupInvitationBucket.fromInvitations(invitations);

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 18),
      itemCount: groups.length,
      separatorBuilder: (context, index) => const Gap(12),
      itemBuilder: (context, index) =>
          _SentGroupInvitationCard(bucket: groups[index], onCancel: onCancel),
    );
  }
}

class _SentGroupInvitationCard extends StatelessWidget {
  const _SentGroupInvitationCard({
    required this.bucket,
    required this.onCancel,
  });

  final _SentGroupInvitationBucket bucket;
  final ValueChanged<SentGroupInvitationEntity> onCancel;

  @override
  Widget build(BuildContext context) => FriendsRequestCard(
    padding: AppSpacing.tile,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GroupInvitationHeader(
          groupName: bucket.groupName,
          theme: bucket.theme,
          subtitle: context.l10n.invitedPeopleCount(bucket.invitations.length),
        ),
        const Gap(14),
        for (int index = 0; index < bucket.invitations.length; index++) ...[
          if (index > 0) const Gap(10),
          _SentInviteeRow(
            invitation: bucket.invitations[index],
            onCancel: () => onCancel(bucket.invitations[index]),
          ),
        ],
      ],
    ),
  );
}

class _GroupInvitationHeader extends StatelessWidget {
  const _GroupInvitationHeader({
    required this.groupName,
    required this.theme,
    required this.subtitle,
  });

  final String groupName;
  final GroupThemeType theme;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: context.colorTokens.primaryGradient,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: AppIcon(
            theme.iconName,
            size: 24,
            color: context.colorTokens.primaryForeground,
          ),
        ),
      ),
      const Gap(12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              groupName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const Gap(3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colorTokens.textHint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _SentInviteeRow extends StatelessWidget {
  const _SentInviteeRow({required this.invitation, required this.onCancel});

  final SentGroupInvitationEntity invitation;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
    decoration: BoxDecoration(
      color: context.colorTokens.surfaceInnerLayer.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        GroupMemberAvatar(
          name: invitation.inviteeName,
          colorValue: invitation.inviteeColorValue,
          size: 38,
        ),
        const Gap(10),
        Expanded(
          child: Text(
            invitation.inviteeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const Gap(10),
        FriendRequestActionButton(
          label: context.l10n.cancelButton,
          isPrimary: false,
          onTap: onCancel,
        ),
      ],
    ),
  );
}

class _SentGroupInvitationBucket {
  const _SentGroupInvitationBucket({
    required this.groupId,
    required this.groupName,
    required this.theme,
    required this.invitations,
  });

  final String groupId;
  final String groupName;
  final GroupThemeType theme;
  final List<SentGroupInvitationEntity> invitations;

  static List<_SentGroupInvitationBucket> fromInvitations(
    List<SentGroupInvitationEntity> invitations,
  ) {
    final Map<String, List<SentGroupInvitationEntity>> byGroup = {};
    for (final SentGroupInvitationEntity invitation in invitations) {
      byGroup.putIfAbsent(invitation.groupId, () => []).add(invitation);
    }

    return byGroup.entries.map((entry) {
      final SentGroupInvitationEntity first = entry.value.first;
      return _SentGroupInvitationBucket(
        groupId: entry.key,
        groupName: first.groupName,
        theme: first.theme,
        invitations: entry.value,
      );
    }).toList();
  }
}
