import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:help_out/theme/app_surfaces.dart";

/// Empty state that teaches instead of just stating the absence of data:
/// icon, what is missing, why it matters and the action that fills it.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onTapAction,
    this.preview,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onTapAction;

  /// Optional dimmed sample of what the feature looks like once it has data.
  final Widget? preview;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
    decoration: AppSurfaces.content(context.colorTokens),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colorTokens.primaryVeryLight,
          ),
          child: Icon(icon, size: 36, color: context.colorTokens.primary),
        ),
        const Gap(AppSpacing.betweenRelated),
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.textStyles.sectionTitle,
        ),
        const Gap(AppSpacing.titleToDescription),
        Text(
          description,
          textAlign: TextAlign.center,
          style: context.textStyles.caption,
        ),
        if (preview != null) ...[
          const Gap(AppSpacing.betweenRelated),
          Opacity(opacity: 0.55, child: preview),
        ],
        if (actionLabel != null && onTapAction != null) ...[
          const Gap(AppSpacing.betweenSections - 4),
          BounceTap(
            pressedScale: 0.97,
            onTap: onTapAction!,
            child: Container(
              width: double.infinity,
              height: AppSpacing.minTapTarget,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: context.colorTokens.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                actionLabel!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.textPrimaryButton.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
