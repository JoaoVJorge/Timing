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
    isOwner: controller.isSelectedGroupOwner,
    onManageMembers: () {
      Navigator.of(sheetContext).pop();
      controller.onManageMembers();
    },
    onEditGroup: () {
      Navigator.of(sheetContext).pop();
      controller.onTapEditGroup();
    },
    onResetGroup: () {
      Navigator.of(sheetContext).pop();
      controller.onTapResetGroup();
    },
    onLeaveGroup: () {
      Navigator.of(sheetContext).pop();
      controller.onTapLeaveGroup();
    },
    onReportGroup: () => Navigator.of(sheetContext).pop(),
  ),
);

class _GroupActionsSheet extends StatelessWidget {
  const _GroupActionsSheet({
    required this.isOwner,
    required this.onManageMembers,
    required this.onEditGroup,
    required this.onResetGroup,
    required this.onLeaveGroup,
    required this.onReportGroup,
  });

  final bool isOwner;
  final VoidCallback onManageMembers;
  final VoidCallback onEditGroup;
  final VoidCallback onResetGroup;
  final VoidCallback onLeaveGroup;
  final VoidCallback onReportGroup;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
            const Gap(16),
            _GroupActionRow(
              icon: Icons.groups_2_outlined,
              label: context.l10n.viewMembersLabel,
              onTap: onManageMembers,
            ),
            const Gap(8),
            if (isOwner) ...[
              _GroupActionRow(
                icon: Icons.edit_outlined,
                label: context.l10n.editGroupLabel,
                onTap: onEditGroup,
              ),
              const Gap(8),
              _GroupActionRow(
                icon: Icons.restart_alt_rounded,
                label: context.l10n.resetGroupLabel,
                style: _GroupActionStyle.outlinedDestructive,
                onTap: onResetGroup,
              ),
              const Gap(8),
            ],
            if (!isOwner) ...[
              _GroupActionRow(
                icon: Icons.flag_outlined,
                label: context.l10n.reportGroupLabel,
                style: _GroupActionStyle.outlinedDestructive,
                onTap: onReportGroup,
              ),
              const Gap(8),
            ],
            _GroupActionRow(
              icon: Icons.logout_rounded,
              label: context.l10n.leaveGroupLabel,
              style: _GroupActionStyle.destructive,
              onTap: onLeaveGroup,
            ),
          ],
        ),
      ),
    ),
  );
}

enum _GroupActionStyle { standard, outlinedDestructive, destructive }

class _GroupActionRow extends StatelessWidget {
  const _GroupActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.style = _GroupActionStyle.standard,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final _GroupActionStyle style;

  @override
  Widget build(BuildContext context) {
    final bool usesDangerColor = style != _GroupActionStyle.standard;
    final bool isDestructive = style == _GroupActionStyle.destructive;
    final Color color = usesDangerColor
        ? context.colorTokens.error
        : context.colorTokens.primary;

    return BounceTap(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDestructive
              ? context.colorTokens.error.withValues(alpha: 0.08)
              : context.colorTokens.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: usesDangerColor
                ? color.withValues(alpha: 0.45)
                : context.colorTokens.borderUnfocused.withValues(alpha: 0.45),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive ? color : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive ? context.colorTokens.white : color,
                size: 22,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.cardTitle.copyWith(
                  color: usesDangerColor ? color : context.colorTokens.textBody,
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
