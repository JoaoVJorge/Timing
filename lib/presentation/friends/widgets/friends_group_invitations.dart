import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/group_invitation_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

/// Pending group invitations shown in the Friends area, next to friend
/// requests. Each row lets the user accept (join the group) or decline.
class FriendsGroupInvitations extends StatelessWidget {
  const FriendsGroupInvitations({
    required this.invitations,
    required this.onAccept,
    required this.onDecline,
    super.key,
  });

  final List<GroupInvitationEntity> invitations;
  final ValueChanged<GroupInvitationEntity> onAccept;
  final ValueChanged<GroupInvitationEntity> onDecline;

  @override
  Widget build(BuildContext context) {
    if (invitations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.groupInvitesTitle(invitations.length),
          style: context.textStyles.bodyMedium.copyWith(
            color: context.colorTokens.textBody,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Gap(12),
        for (int index = 0; index < invitations.length; index++) ...[
          if (index > 0) const Gap(8),
          _InvitationCard(
            invitation: invitations[index],
            onAccept: () => onAccept(invitations[index]),
            onDecline: () => onDecline(invitations[index]),
          ),
        ],
        const Gap(18),
      ],
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.invitation,
    required this.onAccept,
    required this.onDecline,
  });

  final GroupInvitationEntity invitation;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: context.colorTokens.borderUnfocused),
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: context.colorTokens.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AppIcon(
              invitation.theme.iconName,
              size: 22,
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
                invitation.groupName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Gap(2),
              Text(
                context.l10n.groupInvitedBy(invitation.inviterName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colorTokens.textHint,
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        _InvitationAction(
          icon: Icons.close_rounded,
          color: context.colorTokens.textHint,
          background: context.colorTokens.borderUnfocused.withValues(
            alpha: 0.35,
          ),
          semanticLabel: context.l10n.declineButton,
          onTap: onDecline,
        ),
        const Gap(8),
        _InvitationAction(
          icon: Icons.check_rounded,
          color: context.colorTokens.primaryForeground,
          background: context.colorTokens.primary,
          semanticLabel: context.l10n.acceptButton,
          onTap: onAccept,
        ),
      ],
    ),
  );
}

class _InvitationAction extends StatelessWidget {
  const _InvitationAction({
    required this.icon,
    required this.color,
    required this.background,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    child: BounceTap(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 22),
      ),
    ),
  );
}
