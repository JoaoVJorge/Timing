import "package:flutter/material.dart";
import "package:help_out/core/domain/enums/leaderboard_period_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    required this.selectedPeriod,
    required this.onSelectPeriod,
    super.key,
  });

  final LeaderboardPeriodType selectedPeriod;
  final ValueChanged<LeaderboardPeriodType> onSelectPeriod;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: context.colorTokens.surfaceInnerLayer,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        for (
          int index = 0;
          index < LeaderboardPeriodType.values.length;
          index++
        ) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: _PeriodSegment(
              period: LeaderboardPeriodType.values[index],
              isSelected: LeaderboardPeriodType.values[index] == selectedPeriod,
              onTap: () => onSelectPeriod(LeaderboardPeriodType.values[index]),
            ),
          ),
        ],
      ],
    ),
  );
}

class _PeriodSegment extends StatelessWidget {
  const _PeriodSegment({
    required this.period,
    required this.isSelected,
    required this.onTap,
  });

  final LeaderboardPeriodType period;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.95,
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorTokens.surface
            : context.colorTokens.surface.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: context.colorTokens.surfaceShadow,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        period.localizedLabel(context),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: isSelected
              ? context.colorTokens.primary
              : context.colorTokens.textHint,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
