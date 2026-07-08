import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

/// Full-width empty state shown on the Profile screen when the user has not
/// tracked any focus time or reading yet. Replaces the grid of zeroed cards
/// with an inviting call to action plus quick shortcuts.
class ProfileEmptyState extends StatelessWidget {
  const ProfileEmptyState({
    required this.onStart,
    required this.onCreateSubject,
    required this.onCreateGoal,
    required this.onAddSchedule,
    super.key,
  });

  final VoidCallback onStart;
  final VoidCallback onCreateSubject;
  final VoidCallback onCreateGoal;
  final VoidCallback onAddSchedule;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colorTokens.primaryVeryLight,
              context.colorTokens.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: context.colorTokens.borderUnfocused),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.profileEmptyTitle,
              style: context.textStyles.extraBold20,
            ),
            const Gap(8),
            Text(
              context.l10n.profileEmptyDescription,
              style: context.textStyles.bodyMedium.copyWith(
                color: context.colorTokens.textHint,
              ),
            ),
            const Gap(16),
            BounceTap(
              onTap: onStart,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: context.colorTokens.primaryGradient,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  context.l10n.profileEmptyStartButton,
                  style: context.textStyles.textPrimaryButton,
                ),
              ),
            ),
          ],
        ),
      ),
      const Gap(16),
      Text(
        context.l10n.profileShortcutsTitle,
        style: context.textStyles.extraBold20,
      ),
      const Gap(12),
      _ShortcutChip(
        iconName: "studing",
        label: context.l10n.profileShortcutCreateSubject,
        onTap: onCreateSubject,
      ),
      const Gap(8),
      _ShortcutChip(
        iconName: "check",
        label: context.l10n.profileShortcutCreateGoal,
        onTap: onCreateGoal,
      ),
      const Gap(8),
      _ShortcutChip(
        iconName: "timer",
        label: context.l10n.profileShortcutAddSchedule,
        onTap: onAddSchedule,
      ),
    ],
  );
}

class _ShortcutChip extends StatelessWidget {
  const _ShortcutChip({
    required this.iconName,
    required this.label,
    required this.onTap,
  });

  final String iconName;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorTokens.primaryVeryLight,
            ),
            child: SizedBox.square(
              dimension: 18,
              child: ClipRect(
                child: AppIcon(
                  iconName,
                  size: 18,
                  color: context.colorTokens.primary,
                ),
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyLarge,
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: context.colorTokens.textHint,
          ),
        ],
      ),
    ),
  );
}
