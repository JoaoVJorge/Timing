import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/enums/leaderboard_period_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

class GroupPeriodSelector extends StatelessWidget {
  const GroupPeriodSelector({
    required this.selectedPeriod,
    required this.onSelectPeriod,
    super.key,
  });

  final LeaderboardPeriodType selectedPeriod;
  final ValueChanged<LeaderboardPeriodType> onSelectPeriod;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: context.colorTokens.borderUnfocused.withValues(alpha: 0.45),
      ),
      boxShadow: [
        BoxShadow(
          color: context.colorTokens.surfaceShadow.withValues(alpha: 0.08),
          blurRadius: 10,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        for (
          int index = 0;
          index < LeaderboardPeriodType.values.length;
          index++
        ) ...[
          if (index > 0) const Gap(6),
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
      height: 42,
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.surface.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(20),
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
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
