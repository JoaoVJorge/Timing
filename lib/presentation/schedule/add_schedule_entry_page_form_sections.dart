part of "add_schedule_entry_page.dart";

class _ScheduleColorSelector extends StatelessWidget {
  const _ScheduleColorSelector({
    required this.selectedColor,
    required this.onSelected,
  });

  final Color selectedColor;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [...SubjectColors.values, ...SubjectColors.darkValues]
        .map(
          (color) => CreationColorChoice(
            color: color,
            isSelected: color.toARGB32() == selectedColor.toARGB32(),
            onTap: () => onSelected(color),
          ),
        )
        .toList(),
  );
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.icon,
    required this.child,
  }) : assert(icon is String || icon is IconData);

  final String title;
  final Object icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: context.colorTokens.borderUnfocused),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.colorTokens.primaryVeryLight,
                shape: BoxShape.circle,
              ),
              child: icon is IconData
                  ? Icon(
                      icon as IconData,
                      color: context.colorTokens.primary,
                      size: 22,
                    )
                  : AppIcon(
                      icon as String,
                      color: context.colorTokens.primary,
                      size: 24,
                    ),
            ),
            const Gap(12),
            Text(
              title,
              style: context.textStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const Gap(12),
        child,
      ],
    ),
  );
}

class _WeekdayMultiSelector extends StatelessWidget {
  const _WeekdayMultiSelector({
    required this.selectedWeekdays,
    required this.onToggle,
  });

  final Set<int> selectedWeekdays;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final DateTime monday = DateTime(2024, 1, 1);

    return Row(
      children: [
        for (
          int weekday = DateTime.monday;
          weekday <= DateTime.sunday;
          weekday++
        ) ...[
          if (weekday > DateTime.monday) const Gap(6),
          Expanded(
            child: _WeekdayToggleChip(
              label: DateFormat.E(locale)
                  .format(monday.add(Duration(days: weekday - 1)))
                  .characters
                  .take(3)
                  .toString()
                  .toUpperCase(),
              isSelected: selectedWeekdays.contains(weekday),
              onTap: () => onToggle(weekday),
            ),
          ),
        ],
      ],
    );
  }
}

class _WeekdayToggleChip extends StatelessWidget {
  const _WeekdayToggleChip({
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
      duration: const Duration(milliseconds: 180),
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorTokens.primary
            : context.colorTokens.scaffold.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? context.colorTokens.primary
              : context.colorTokens.borderUnfocused,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: isSelected
              ? context.colorTokens.white
              : context.colorTokens.textBody,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class _PreviewFrame extends StatelessWidget {
  const _PreviewFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: context.colorTokens.scaffold.withValues(alpha: 0.48),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: context.colorTokens.primaryVeryLight,
        width: 1.4,
      ),
    ),
    child: child,
  );
}

/// Pinned above the keyboard. When it is disabled it says *why*, instead of
/// leaving the user tapping a dead button.
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isEnabled,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  final bool isEnabled;
  final String label;
  final String? hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (hint != null) ...[
        Text(
          hint!,
          textAlign: TextAlign.center,
          style: context.textStyles.caption.copyWith(fontSize: 12),
        ),
        const Gap(AppSpacing.titleToDescription),
      ],
      Semantics(
        button: true,
        enabled: isEnabled,
        child: BounceTap(
          pressedScale: isEnabled ? 0.97 : 1,
          onTap: onTap,
          child: Opacity(
            opacity: isEnabled ? 1 : 0.45,
            child: Container(
              width: double.infinity,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: context.colorTokens.primaryGradient,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(
                    "schedule",
                    color: context.colorTokens.primaryForeground,
                  ),
                  const Gap(AppSpacing.titleToDescription),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.textPrimaryButton.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.textStyles.bodySmall.copyWith(
      color: context.colorTokens.textBody,
      fontWeight: FontWeight.w800,
    ),
  );
}
