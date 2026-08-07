import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

BoxDecoration friendsSurfaceDecoration(
  BuildContext context, {
  required double radius,
}) => BoxDecoration(
  color: context.colorTokens.surface,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: context.colorTokens.borderUnfocused),
  boxShadow: [
    BoxShadow(
      color: context.colorTokens.surfaceShadow.withValues(alpha: 0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ],
);

class FriendsPinkBadge extends StatelessWidget {
  const FriendsPinkBadge({
    required this.icon,
    required this.size,
    required this.iconSize,
    super.key,
  });

  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: context.colorTokens.primaryVeryLight,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: context.colorTokens.primary, size: iconSize),
  );
}

class FriendNameBlock extends StatelessWidget {
  const FriendNameBlock({required this.name, required this.handle, super.key});

  final String name;
  final String handle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      const Gap(2),
      Text(
        handle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: context.colorTokens.textHint,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class FriendWidePrimaryButton extends StatelessWidget {
  const FriendWidePrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
    required this.icon,
    super.key,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.97,
    onTap: isLoading ? () {} : onTap,
    child: Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        gradient: context.colorTokens.primaryGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: context.colorTokens.primaryForeground,
                strokeWidth: 2.4,
              ),
            )
          else
            Icon(icon, color: context.colorTokens.primaryForeground, size: 21),
          const Gap(8),
          Text(
            label,
            style: context.textStyles.textPrimaryButton.copyWith(
              color: context.colorTokens.primaryForeground,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );
}

class FriendAddButton extends StatelessWidget {
  const FriendAddButton({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.96,
    onTap: onTap,
    child: Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: context.colorTokens.primaryGradient,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: context.colorTokens.primaryForeground,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class FriendSentChip extends StatelessWidget {
  const FriendSentChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: 30,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: context.colorTokens.surfaceInnerLayer,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      children: [
        Icon(
          Icons.check_rounded,
          size: 16,
          color: context.colorTokens.textHint,
        ),
        const Gap(4),
        Text(
          label,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.textHint,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class FriendRequestActionButton extends StatelessWidget {
  const FriendRequestActionButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.96,
    onTap: onTap,
    child: Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: isPrimary ? context.colorTokens.primaryGradient : null,
        color: isPrimary ? null : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(999),
        border: isPrimary
            ? null
            : Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: isPrimary
              ? context.colorTokens.primaryForeground
              : context.colorTokens.textHint,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class FriendShareButton extends StatelessWidget {
  const FriendShareButton({
    required this.onTap,
    required this.label,
    super.key,
  });

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.96,
    child: Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        border: Border.all(color: context.colorTokens.primary),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.ios_share_rounded,
            color: context.colorTokens.primary,
            size: 18,
          ),
          const Gap(8),
          Text(
            label,
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );
}
