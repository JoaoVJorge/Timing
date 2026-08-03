import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/app_spacing.dart";

/// Title that opens a section of a page, with an optional trailing action.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    this.description,
    this.actionLabel,
    this.onTapAction,
    this.badge,
    super.key,
  });

  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onTapAction;

  /// Read-only counter shown on the right, e.g. "2 of 4 done".
  final String? badge;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.sectionTitle,
            ),
          ),
          if (badge != null) ...[
            const Gap(AppSpacing.titleToDescription),
            Text(
              badge!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.caption.copyWith(fontSize: 12),
            ),
          ],
          if (actionLabel != null && onTapAction != null) ...[
            const Gap(AppSpacing.titleToDescription),
            BounceTap(
              pressedScale: 0.95,
              onTap: onTapAction!,
              child: Text(
                actionLabel!,
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colorTokens.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
      if (description != null) ...[
        const Gap(AppSpacing.titleToDescription),
        Text(description!, style: context.textStyles.caption),
      ],
    ],
  );
}
