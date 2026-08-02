import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:help_out/theme/app_surfaces.dart";

/// The single headline result of the selected period, plus how it compares to
/// the period before it. Comparison is what makes the number motivating.
class ProgressHeroCard extends StatelessWidget {
  const ProgressHeroCard({
    required this.focusSeconds,
    required this.differenceToPreviousPeriod,
    super.key,
  });

  final int focusSeconds;
  final int? differenceToPreviousPeriod;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: AppSurfaces.primary(context.colorTokens),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.progressFocusResultLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colorTokens.primaryForeground.withValues(
                    alpha: 0.85,
                  ),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Gap(AppSpacing.titleToDescription),
              Text(
                formatDurationLong(Duration(seconds: focusSeconds)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.metricValue.copyWith(
                  color: context.colorTokens.primaryForeground,
                  fontSize: 32,
                ),
              ),
              const Gap(6),
              Row(
                children: [
                  Icon(
                    _comparisonIcon,
                    size: 16,
                    color: context.colorTokens.primaryForeground.withValues(
                      alpha: 0.9,
                    ),
                  ),
                  const Gap(4),
                  Expanded(
                    child: Text(
                      _comparisonText(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodySmall.copyWith(
                        color: context.colorTokens.primaryForeground.withValues(
                          alpha: 0.9,
                        ),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.betweenRelated),
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colorTokens.primaryForeground.withValues(
              alpha: 0.18,
            ),
          ),
          child: Icon(
            Icons.timer_rounded,
            color: context.colorTokens.primaryForeground,
            size: 30,
          ),
        ),
      ],
    ),
  );

  IconData get _comparisonIcon {
    final int? difference = differenceToPreviousPeriod;
    if (difference == null) {
      return Icons.auto_awesome_rounded;
    }
    if (difference > 0) {
      return Icons.trending_up_rounded;
    }
    if (difference < 0) {
      return Icons.trending_down_rounded;
    }
    return Icons.trending_flat_rounded;
  }

  String _comparisonText(BuildContext context) {
    final int? difference = differenceToPreviousPeriod;
    if (difference == null) {
      return context.l10n.progressComparisonFirst;
    }
    if (difference == 0) {
      return context.l10n.progressComparisonSame;
    }

    final String value = formatDurationLong(
      Duration(seconds: difference.abs()),
    );
    return difference > 0
        ? context.l10n.progressComparisonMore(value)
        : context.l10n.progressComparisonLess(value);
  }
}
