import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/group_invitation_entity.dart";
import "package:timing/core/domain/entities/sent_group_invitation_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/friends/friends_controller.dart";
import "package:timing/presentation/friends/widgets/friends_shared.dart";
import "package:timing/presentation/groups/widgets/group_member_avatar.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";

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
  Widget build(BuildContext context) => AppScaffold(
    topBar: AppTopBar(
      title: "Convites",
      showBackButton: true,
      onBack: () => Navigator.of(context).maybePop(),
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GroupInvitationTabs(
          selectedMode: selectedMode,
          onSelect: (mode) => setState(() => selectedMode = mode),
        ),
        const Gap(18),
        Expanded(
          child: Obx(
            () => switch (selectedMode) {
              GroupInvitationsMode.incoming => _IncomingInvitationsList(
                invitations: controller.groupInvitations.toList(),
                onAccept: controller.acceptGroupInvitation,
                onDecline: controller.declineGroupInvitation,
              ),
              GroupInvitationsMode.sent => _SentInvitationsList(
                invitations: controller.sentGroupInvitations.toList(),
                onCancel: controller.cancelGroupInvitation,
              ),
            },
          ),
        ),
        const Gap(18),
      ],
    ),
  );
}

class _GroupInvitationTabs extends StatelessWidget {
  const _GroupInvitationTabs({
    required this.selectedMode,
    required this.onSelect,
  });

  final GroupInvitationsMode selectedMode;
  final ValueChanged<GroupInvitationsMode> onSelect;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _GroupInvitationTab(
          icon: Icons.inbox_rounded,
          label: "Recebidos",
          isSelected: selectedMode == GroupInvitationsMode.incoming,
          onTap: () => onSelect(GroupInvitationsMode.incoming),
        ),
      ),
      const Gap(10),
      Expanded(
        child: _GroupInvitationTab(
          icon: Icons.send_rounded,
          label: "Enviados",
          isSelected: selectedMode == GroupInvitationsMode.sent,
          onTap: () => onSelect(GroupInvitationsMode.sent),
        ),
      ),
    ],
  );
}

class _GroupInvitationTab extends StatelessWidget {
  const _GroupInvitationTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.96,
    child: Container(
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: isSelected ? context.colorTokens.primaryGradient : null,
        color: isSelected ? null : context.colorTokens.surfaceInnerLayer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? context.colorTokens.primaryForeground
                : context.colorTokens.textHint,
          ),
          const Gap(7),
          Text(
            label,
            style: context.textStyles.bodySmall.copyWith(
              color: isSelected
                  ? context.colorTokens.primaryForeground
                  : context.colorTokens.textHint,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );
}

class _IncomingInvitationsList extends StatelessWidget {
  const _IncomingInvitationsList({
    required this.invitations,
    required this.onAccept,
    required this.onDecline,
  });

  final List<GroupInvitationEntity> invitations;
  final ValueChanged<GroupInvitationEntity> onAccept;
  final ValueChanged<GroupInvitationEntity> onDecline;

  @override
  Widget build(BuildContext context) {
    if (invitations.isEmpty) {
      return const _GroupInvitationEmptyState(
        icon: Icons.inbox_rounded,
        title: "Nenhum convite recebido",
        description: "Quando alguem convidar voce para um grupo, aparece aqui.",
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
    required this.onAccept,
    required this.onDecline,
  });

  final GroupInvitationEntity invitation;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
    decoration: friendsSurfaceDecoration(context, radius: 18),
    child: Column(
      children: [
        _GroupInvitationHeader(
          groupName: invitation.groupName,
          theme: invitation.theme,
          subtitle: "Convite de ${invitation.inviterName}",
        ),
        const Gap(14),
        Row(
          children: [
            Expanded(
              child: FriendRequestActionButton(
                label: "Recusar",
                isPrimary: false,
                onTap: onDecline,
              ),
            ),
            const Gap(10),
            Expanded(
              child: FriendRequestActionButton(
                label: "Aceitar",
                isPrimary: true,
                onTap: onAccept,
              ),
            ),
          ],
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
      return const _GroupInvitationEmptyState(
        icon: Icons.send_rounded,
        title: "Nenhum convite enviado",
        description:
            "Os convites que voce enviar para alguem entrar em um grupo aparecem aqui.",
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
    decoration: friendsSurfaceDecoration(context, radius: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GroupInvitationHeader(
          groupName: bucket.groupName,
          theme: bucket.theme,
          subtitle:
              "${bucket.invitations.length} ${bucket.invitations.length == 1 ? "pessoa convidada" : "pessoas convidadas"}",
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
          label: "Cancelar",
          isPrimary: false,
          onTap: onCancel,
        ),
      ],
    ),
  );
}

class _GroupInvitationEmptyState extends StatelessWidget {
  const _GroupInvitationEmptyState({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 28),
      decoration: friendsSurfaceDecoration(context, radius: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FriendsPinkBadge(icon: icon, size: 64, iconSize: 34),
          const Gap(14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textStyles.extraBold20.copyWith(
              color: context.colorTokens.textBody,
              fontSize: 17,
            ),
          ),
          const Gap(6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.textHint,
              fontSize: 13,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
