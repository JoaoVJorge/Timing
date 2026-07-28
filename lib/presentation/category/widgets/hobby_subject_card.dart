import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class HobbySubjectCard extends StatelessWidget {
  const HobbySubjectCard({
    required this.subject,
    required this.onTapPlay,
    required this.onTapEdit,
    required this.onTapPin,
    required this.onDelete,
    required this.isPinned,
    super.key,
  });

  final SubjectEntity subject;
  final VoidCallback onTapPlay;
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
          18,
          8,
          18,
          18 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: context.colorTokens.dialogSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 5,
              decoration: BoxDecoration(
                color: context.colorTokens.borderUnfocused,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const Gap(18),
            Row(
              children: [
                _HobbySheetIcon(
                  color: accent.withValues(alpha: 0.14),
                  child: AppIcon(
                    _hobbyIconName(subject),
                    size: 24,
                    color: accent,
                  ),
                ),
                const Gap(12),
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
                          fontSize: 22,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        _practiceLabel(context),
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
                const Gap(10),
                BounceTap(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: context.colorTokens.dialogTextMuted,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(20),
            Container(
              decoration: BoxDecoration(
                color: context.colorTokens.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.colorTokens.divider),
              ),
              child: Column(
                children: [
                  _HobbySheetAction(
                    icon: Icons.edit_rounded,
                    label: _editLabel(context),
                    accent: accent,
                    onTap: () => onAction("edit"),
                  ),
                  Divider(height: 1, color: context.colorTokens.divider),
                  _HobbySheetAction(
                    icon: Icons.push_pin_outlined,
                    label: _pinLabel(context),
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
            const Gap(16),
            _HobbyDeleteAction(
              accent: context.colorTokens.error,
              label: _deleteLabel(context),
              subtitle: _deleteSubtitle(context),
              onTap: () => onAction("delete"),
            ),
          ],
        ),
      ),
    );
  }

  String _practiceLabel(BuildContext context) {
    final int minutes = Duration(seconds: subject.totalSeconds).inMinutes;
    return switch (context.languageCode) {
      "en" => "$minutes min of practice",
      "es" => "$minutes min de práctica",
      _ => "$minutes min de prática",
    };
  }

  String _editLabel(BuildContext context) => switch (context.languageCode) {
    "en" => "Edit hobby",
    "es" => "Editar hobby",
    _ => "Editar hobby",
  };

  String _pinLabel(BuildContext context) => switch (context.languageCode) {
    "en" => "Pin to start",
    "es" => "Fijar al inicio",
    _ => "Fixar no início",
  };

  String _deleteLabel(BuildContext context) => switch (context.languageCode) {
    "en" => "Delete hobby",
    "es" => "Eliminar hobby",
    _ => "Excluir hobby",
  };

  String _deleteSubtitle(BuildContext context) =>
      switch (context.languageCode) {
        "en" => "This action cannot be undone.",
        "es" => "Esta acción no se puede deshacer.",
        _ => "Esta ação não pode ser desfeita.",
      };
}

class _HobbySheetIcon extends StatelessWidget {
  const _HobbySheetIcon({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
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
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          _HobbySheetIcon(
            color: accent.withValues(alpha: 0.12),
            child: Icon(icon, color: accent, size: 24),
          ),
          const Gap(14),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyLarge.copyWith(
                color: context.colorTokens.dialogText,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          trailing ??
              Icon(Icons.chevron_right_rounded, color: accent, size: 30),
        ],
      ),
    ),
  );
}

class _HobbyDeleteAction extends StatelessWidget {
  const _HobbyDeleteAction({
    required this.accent,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final Color accent;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _HobbySheetIcon(
            color: accent.withValues(alpha: 0.14),
            child: Icon(Icons.delete_outline_rounded, color: accent, size: 24),
          ),
          const Gap(14),
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
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colorTokens.dialogTextMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Gap(10),
          Icon(Icons.chevron_right_rounded, color: accent, size: 28),
        ],
      ),
    ),
  );
}
