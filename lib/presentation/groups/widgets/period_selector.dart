import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/enums/leaderboard_period_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/app_spacing.dart";

class GroupPeriodSelector extends StatelessWidget {
  const GroupPeriodSelector({
    required this.selectedPeriod,
    required this.onSelectPeriod,
    super.key,
  });

  final LeaderboardPeriodType selectedPeriod;
  final ValueChanged<LeaderboardPeriodType> onSelectPeriod;

  /// Deliberately lighter than [GroupSelector]: which group you are looking at
  /// matters more than which window of time.
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: context.colorTokens.borderUnfocused.withValues(alpha: 0.45),
      ),
    ),
    child: Row(
      children: [
        for (
          int index = 0;
          index < LeaderboardPeriodType.values.length;
          index++
        ) ...[
          if (index > 0) const Gap(4),
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
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: isSelected,
    child: BounceTap(
      pressedScale: 0.95,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: AppSpacing.minTapTarget - 8,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 34,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colorTokens.primaryVeryLight
                  : context.colorTokens.transparent,
              borderRadius: BorderRadius.circular(12),
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
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
