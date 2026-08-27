part of "groups_page.dart";

// The bottom sheet of owner/member actions for a group.

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
