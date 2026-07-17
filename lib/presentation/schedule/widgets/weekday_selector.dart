import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:intl/intl.dart";

class WeekdaySelector extends StatelessWidget {
  const WeekdaySelector({
    required this.selectedWeekday,
    required this.onSelectWeekday,
    super.key,
  });

  final int selectedWeekday;
  final ValueChanged<int> onSelectWeekday;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final DateTime now = DateTime.now();
    final DateTime weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - DateTime.monday));

    return Row(
      children: [
        for (
          int weekday = DateTime.monday;
          weekday <= DateTime.sunday;
          weekday++
        ) ...[
          if (weekday > DateTime.monday) const Gap(6),
          Expanded(
            child: _WeekdayChip(
              label: DateFormat.E(locale)
                  .format(weekStart.add(Duration(days: weekday - 1)))
                  .characters
                  .take(3)
                  .toString()
                  .toUpperCase(),
              day: DateFormat(
                "dd",
                locale,
              ).format(weekStart.add(Duration(days: weekday - 1))),
              isSelected: weekday == selectedWeekday,
              onTap: () => onSelectWeekday(weekday),
            ),
          ),
        ],
      ],
    );
  }
}

class _WeekdayChip extends StatelessWidget {
  const _WeekdayChip({
    required this.label,
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String day;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BounceTap(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 76,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colorTokens.primaryVeryLight
                  : context.colorTokens.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? context.colorTokens.primary.withValues(alpha: 0.36)
                    : context.colorTokens.borderUnfocused.withValues(
                        alpha: 0.45,
                      ),
                width: isSelected ? 1.4 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: isSelected
                        ? context.colorTokens.primary
                        : context.colorTokens.textBody,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(4),
                Text(
                  day,
                  maxLines: 1,
                  style: context.textStyles.black28.copyWith(
                    color: isSelected
                        ? context.colorTokens.primary
                        : context.colorTokens.textBody,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          const Gap(7),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? context.colorTokens.primary
                  : context.colorTokens.borderUnfocused.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
