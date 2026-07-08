import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

/// Compact identity block at the top of the Profile screen: a small avatar,
/// the display name, the nickname handle and a discreet "Edit" action that
/// opens the edit-profile screen.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.name,
    required this.handle,
    required this.avatarIcon,
    required this.onTapEdit,
    super.key,
  });

  final String name;
  final String handle;
  final IconData avatarIcon;
  final VoidCallback onTapEdit;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: context.colorTokens.primaryGradient,
        ),
        child: Icon(avatarIcon, color: Colors.white, size: 24),
      ),
      const Gap(12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.extraBold20,
            ),
            Text(
              handle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colorTokens.textHint,
              ),
            ),
          ],
        ),
      ),
      const Gap(12),
      BounceTap(
        onTap: onTapEdit,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: context.colorTokens.primaryVeryLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            context.l10n.editButton,
            style: context.textStyles.textButtonMedium.copyWith(fontSize: 14),
          ),
        ),
      ),
    ],
  );
}
