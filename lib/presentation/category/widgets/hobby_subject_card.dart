import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/category/widgets/group_activity_lock_badge.dart";
import "package:timing/shared/functions/format_duration.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/bounce_tap.dart";

class HobbySubjectCard extends StatelessWidget {
  const HobbySubjectCard({
    required this.subject,
    required this.onTapPlay,
    required this.onTapStats,
    required this.onTapEdit,
    required this.onTapPin,
    required this.onDelete,
    required this.isPinned,
    super.key,
  });

  final SubjectEntity subject;
  final VoidCallback onTapPlay;
  final VoidCallback onTapStats;
  final VoidCallback onTapEdit;
  final VoidCallback onTapPin;
  final VoidCallback onDelete;
  final bool isPinned;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(subject.colorValue);

    return BounceTap(
      pressedScale: 0.96,
      onTap: onTapPlay,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcon(
                      _hobbyIconName(subject),
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  subject.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.extraBold20.copyWith(
                    color: Colors.white,
                  ),
                ),
                const Gap(4),
                Text(
                  formatDurationLong(Duration(seconds: subject.totalSeconds)),
                  style: context.textStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            Positioned(
              top: -8,
              right: -8,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showOptions(context),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.more_horiz_rounded,
                    color: context.colorTokens.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOptions(BuildContext context) async {
    final String? action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorTokens.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => _HobbyOptionsSheet(
        subject: subject,
        isPinned: isPinned,
        onAction: (action) => Navigator.of(context).pop(action),
      ),
    );

    if (action == "stats") {
      onTapStats();
    }
    if (action == "edit") {
      onTapEdit();
    }
    if (action == "pin") {
      onTapPin();
    }
    if (action == "delete") {
      onDelete();
    }
  }
}

String _hobbyIconName(SubjectEntity subject) =>
    subject.iconName.isEmpty ? "music" : subject.iconName;

class _HobbyOptionsSheet extends StatelessWidget {
  const _HobbyOptionsSheet({
    required this.subject,
    required this.isPinned,
    required this.onAction,
  });

  final SubjectEntity subject;
  final bool isPinned;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final Color accent = Color(subject.colorValue);

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          16,
          6,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: context.colorTokens.dialogSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 3,
              decoration: BoxDecoration(
                color: context.colorTokens.borderUnfocused,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const Gap(16),
            Row(
              children: [
                _HobbySheetIcon(
                  color: accent.withValues(alpha: 0.14),
                  child: AppIcon(
                    _hobbyIconName(subject),
                    size: 22,
                    color: accent,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.extraBold24.copyWith(
                          color: context.colorTokens.dialogText,
                          fontSize: 20,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        context.l10n.hobbyPracticeMinutes(
                          Duration(seconds: subject.totalSeconds).inMinutes,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodyLarge.copyWith(
                          color: context.colorTokens.dialogTextMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                BounceTap(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: context.colorTokens.dialogTextMuted,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(18),
            Container(
              decoration: BoxDecoration(
                color: context.colorTokens.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colorTokens.divider),
              ),
              child: Column(
                children: [
                  _HobbySheetAction(
                    icon: Icons.bar_chart_rounded,
                    label: context.l10n.hobbyViewStatistics,
                    accent: accent,
                    onTap: () => onAction("stats"),
                  ),
                  Divider(height: 1, color: context.colorTokens.divider),
                  _HobbySheetAction(
                    icon: Icons.edit_rounded,
                    label: context.l10n.hobbyEdit,
                    accent: accent,
                    isLocked: subject.isFromGroup,
                    onTap: () => onAction("edit"),
                  ),
                  Divider(height: 1, color: context.colorTokens.divider),
                  _HobbySheetAction(
                    icon: Icons.push_pin_outlined,
                    label: context.l10n.pinToStart,
                    accent: accent,
                    trailing: Switch.adaptive(
                      value: isPinned,
                      activeThumbColor: accent,
                      activeTrackColor: accent.withValues(alpha: 0.32),
                      onChanged: isPinned ? null : (_) => onAction("pin"),
                    ),
                    onTap: isPinned ? null : () => onAction("pin"),
                  ),
                ],
              ),
            ),
            const Gap(14),
            _HobbyDeleteAction(
              isLocked: subject.isFromGroup,
              label: context.l10n.hobbyDelete,
              subtitle: context.l10n.deleteActionCannotBeUndone,
              onTap: () => onAction("delete"),
            ),
          ],
        ),
      ),
    );
  }
}

class _HobbySheetIcon extends StatelessWidget {
  const _HobbySheetIcon({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    alignment: Alignment.center,
    child: child,
  );
}

class _HobbySheetAction extends StatelessWidget {
  const _HobbySheetAction({
    required this.icon,
    required this.label,
    required this.accent,
    this.isLocked = false,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final bool isLocked;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Color actionColor = isLocked ? context.colorTokens.textHint : accent;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _HobbySheetIcon(
                  color: actionColor.withValues(alpha: 0.12),
                  child: Icon(icon, color: actionColor, size: 22),
                ),
                if (isLocked)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: GroupActivityLockBadge(
                      size: 20,
                      iconSize: 12,
                      backgroundColor: context.colorTokens.surface,
                      iconColor: actionColor,
                    ),
                  ),
              ],
            ),
            const Gap(12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodyLarge.copyWith(
                  color: isLocked
                      ? context.colorTokens.textHint
                      : context.colorTokens.dialogText,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: actionColor,
                  size: 28,
                ),
          ],
        ),
      ),
    );
  }
}

class _HobbyDeleteAction extends StatelessWidget {
  const _HobbyDeleteAction({
    required this.isLocked,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final bool isLocked;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = isLocked
        ? context.colorTokens.textHint
        : context.colorTokens.error;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.26)),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _HobbySheetIcon(
                  color: isLocked ? accent.withValues(alpha: 0.12) : accent,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: isLocked ? accent : context.colorTokens.white,
                    size: 22,
                  ),
                ),
                if (isLocked)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: GroupActivityLockBadge(
                      size: 20,
                      iconSize: 12,
                      backgroundColor: context.colorTokens.surface,
                      iconColor: accent,
                    ),
                  ),
              ],
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyLarge.copyWith(
                      color: accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyMedium.copyWith(
                      color: accent.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
            Icon(Icons.chevron_right_rounded, color: accent, size: 26),
          ],
        ),
      ),
    );
  }
}
