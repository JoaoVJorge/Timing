import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

/// Full-width empty state shown on the Profile screen when the user has not
/// tracked any focus time or reading yet. Replaces the grid of zeroed cards
/// with guidance about what will appear here after activity is tracked.
class ProfileEmptyState extends StatelessWidget {
  const ProfileEmptyState({super.key});

  @override
  Widget build(BuildContext context) => Container(
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
        Text(
          context.l10n.profileEmptyGuidance,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.textHint,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
