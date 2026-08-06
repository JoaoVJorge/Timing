import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/progress/progress_controller.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/app_spacing.dart";

class ProgressPeriodTabs extends StatelessWidget {
  const ProgressPeriodTabs({
    required this.selectedPeriod,
    required this.onSelectPeriod,
    super.key,
  });

  final ProgressPeriod selectedPeriod;
  final ValueChanged<ProgressPeriod> onSelectPeriod;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: context.colorTokens.borderUnfocused.withValues(alpha: 0.55),
      ),
    ),
    child: Row(
      children: [
        for (final ProgressPeriod period in ProgressPeriod.values) ...[
          if (period != ProgressPeriod.values.first) const Gap(4),
          Expanded(
            flex: period == ProgressPeriod.day ? 4 : 3,
            child: _PeriodTab(
              label: period.localizedLabel(context),
              isSelected: selectedPeriod == period,
              onTap: () => onSelectPeriod(period),
            ),
          ),
        ],
      ],
    ),
  );
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: isSelected,
    child: BounceTap(
      pressedScale: 0.95,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: AppSpacing.minTapTarget - 8,
        decoration: BoxDecoration(
          color: isSelected
              ? context.colorTokens.primaryVeryLight
              : context.colorTokens.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodyMedium.copyWith(
            color: isSelected
                ? context.colorTokens.primary
                : context.colorTokens.textHint,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  );
}

extension ProgressPeriodLabelX on ProgressPeriod {
  String localizedLabel(BuildContext context) => switch (this) {
    ProgressPeriod.day => context.l10n.progressPeriodDay,
    ProgressPeriod.week => context.l10n.progressPeriodWeek,
    ProgressPeriod.month => context.l10n.progressPeriodMonth,
  };
}
