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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (
            int weekday = DateTime.monday;
            weekday <= DateTime.sunday;
            weekday++
          ) ...[
            if (weekday > DateTime.monday) const Gap(8),
            _WeekdayChip(
              label: DateFormat.E(locale).format(DateTime(2024, 1, weekday)),
              isSelected: weekday == selectedWeekday,
              onTap: () => onSelectWeekday(weekday),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeekdayChip extends StatelessWidget {
  const _WeekdayChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: isSelected
            ? context.colorTokens.primaryGradient
            : LinearGradient(
                colors: [
                  context.colorTokens.surface,
                  context.colorTokens.surface,
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.colorTokens.surfaceShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: isSelected
            ? context.textStyles.textPrimaryButton
            : context.textStyles.bodyMedium.copyWith(
                color: context.colorTokens.textBody,
              ),
      ),
    ),
  );
}
