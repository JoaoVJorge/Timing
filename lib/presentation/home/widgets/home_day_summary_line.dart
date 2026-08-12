import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/progress/progress_category_style.dart";
import "package:timing/theme/app_spacing.dart";

/// One quiet line closing the page. Four separate metric cards fragmented the
/// reading and repeated what Progress already shows in depth.
class HomeDaySummaryLine extends StatelessWidget {
  const HomeDaySummaryLine({
    required this.focus,
    required this.pages,
    required this.goals,
    super.key,
  });

  final String focus;
  final int pages;
  final int goals;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    constraints: const BoxConstraints(minHeight: 46),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: context.isDarkMode
          ? context.colorTokens.surface
          : Color.lerp(
              context.colorTokens.surface,
              context.colorTokens.primary,
              0.04,
            ),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: context.colorTokens.borderUnfocused.withValues(alpha: 0.45),
      ),
    ),
    child: Row(
      children: [
        Icon(
          Icons.insights_rounded,
          size: 18,
          color: context.colorTokens.primary,
        ),
        const Gap(AppSpacing.titleToDescription),
        Text(
          context.l10n.periodToday,
          style: context.textStyles.caption.copyWith(
            color: context.colorTokens.textBody,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Gap(10),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MetricDot(color: TimeCategoryType.studying.accentColor),
              Text(
                context.l10n.homeDaySummaryFocusValue(focus),
                style: context.textStyles.caption.copyWith(fontSize: 12),
              ),
              _MetricDot(color: TimeCategoryType.reading.accentColor),
              Text(
                context.l10n.createSubjectPagesValue(pages),
                style: context.textStyles.caption.copyWith(fontSize: 12),
              ),
              _MetricDot(color: context.colorTokens.primary),
              Text(
                context.l10n.homeDaySummaryGoalsValue(goals),
                style: context.textStyles.caption.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MetricDot extends StatelessWidget {
  const _MetricDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 6,
    height: 6,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
