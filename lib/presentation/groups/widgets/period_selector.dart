import "package:flutter/material.dart";
import "package:help_out/core/domain/enums/leaderboard_period_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({required this.selectedPeriod, required this.onSelectPeriod, super.key});

  final LeaderboardPeriodType selectedPeriod;
  final ValueChanged<LeaderboardPeriodType> onSelectPeriod;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: context.colorTokens.surfaceInnerLayer, borderRadius: BorderRadius.circular(16)),
    child: Row(
      children: LeaderboardPeriodType.values.map((period) {
        final bool isSelected = period == selectedPeriod;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelectPeriod(period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? context.colorTokens.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [BoxShadow(color: context.colorTokens.surfaceShadow, blurRadius: 8, offset: const Offset(0, 3))]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                period.label,
                style: context.textStyles.bodySmall.copyWith(
                  color: isSelected ? context.colorTokens.primary : context.colorTokens.textHint,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}
