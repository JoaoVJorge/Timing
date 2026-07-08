import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

/// Compact navigation row for a Home activity area. Tapping anywhere opens the
/// area, so it uses a chevron affordance rather than a play button.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.iconName,
    required this.label,
    required this.onTap,
    this.subtitle,
    super.key,
  });

  final String iconName;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colorTokens.primaryVeryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppIcon(
                iconName,
                size: 22,
                color: context.colorTokens.primary,
              ),
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null) ...[
                  const Gap(2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.textHint,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Gap(8),
          Icon(
            Icons.chevron_right_rounded,
            size: 24,
            color: context.colorTokens.textHint,
          ),
        ],
      ),
    ),
  );
}
