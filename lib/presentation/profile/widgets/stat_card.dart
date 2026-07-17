import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";

/// Reusable statistic card for the Profile screen. Renders either a real value
/// (with an optional goal subtitle and progress bar) or a guidance empty state
/// when there is nothing tracked yet.
class ProfileStatCard extends StatelessWidget {
  const ProfileStatCard({
    required this.iconName,
    required this.accentColor,
    required this.label,
    required this.value,
    this.subtitle,
    this.progress,
    this.isEmpty = false,
    this.emptyTitle,
    this.emptyDescription,
    super.key,
  });

  final String iconName;
  final Color accentColor;
  final String label;
  final String value;
  final String? subtitle;

  /// Progress in the 0..1 range. When null (or when [isEmpty]) no bar is shown.
  final double? progress;
  final bool isEmpty;
  final String? emptyTitle;
  final String? emptyDescription;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: context.colorTokens.borderUnfocused),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 20,
                child: AppIcon(iconName, size: 20, color: accentColor),
              ),
            ),
          ],
        ),
        const Gap(12),
        if (isEmpty) ..._buildEmpty(context) else ..._buildValue(context),
      ],
    ),
  );

  List<Widget> _buildValue(BuildContext context) => [
    Text(
      value,
      style: context.textStyles.black20.copyWith(
        color: context.colorTokens.textBody,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    const Gap(4),
    Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textStyles.bodySmall.copyWith(
        color: context.colorTokens.textHint,
      ),
    ),
    if (progress != null) ...[
      const Gap(12),
      _ProgressBar(progress: progress!, color: accentColor),
    ] else if (subtitle != null) ...[
      const Gap(8),
      Text(
        subtitle!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(color: accentColor),
      ),
    ],
  ];

  List<Widget> _buildEmpty(BuildContext context) => [
    Text(
      emptyTitle ?? label,
      style: context.textStyles.bodyLarge,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
    if (emptyDescription != null) ...[
      const Gap(4),
      Text(
        emptyDescription!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: context.colorTokens.textHint,
        ),
      ),
    ],
  ];
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double clamped = progress.clamp(0, 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.16),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const Gap(4),
        Text(
          "${(clamped * 100).round()}%",
          style: context.textStyles.bodySmall.copyWith(color: color),
        ),
      ],
    );
  }
}
