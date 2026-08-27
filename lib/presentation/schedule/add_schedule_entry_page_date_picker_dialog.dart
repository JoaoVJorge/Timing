part of "add_schedule_entry_page.dart";

class _ScheduleDatePickerDialog extends StatefulWidget {
  const _ScheduleDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;

  @override
  State<_ScheduleDatePickerDialog> createState() =>
      _ScheduleDatePickerDialogState();
}

class _ScheduleDatePickerDialogState extends State<_ScheduleDatePickerDialog> {
  late DateTime _selectedDate = _dateOnly(widget.initialDate);

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: context.colorTokens.dialogSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CalendarMonthHeader(
              label: formatMonthYearLabel(locale, _selectedDate),
              onPrevious: _onPreviousMonth,
              onNext: _onNextMonth,
            ),
            const Gap(22),
            ScheduleDateStrip(
              selectedDate: _selectedDate,
              onSelectDate: _onSelectDate,
              onMonthChanged: _onChangeMonth,
              hasEntryForDate: (_) => false,
              eventColorsForDate: (_) => const [],
            ),
            const Gap(16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: context.colorTokens.surfaceInnerLayer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: context.colorTokens.primary,
                    size: 18,
                  ),
                  const Gap(8),
                  Flexible(
                    child: Text(
                      context.l10n.selectDateHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyMedium.copyWith(
                        color: context.colorTokens.dialogTextMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(18),
            Row(
              children: [
                Expanded(
                  child: _DialogSecondaryButton(
                    label: context.l10n.periodToday,
                    onTap: () => _onSelectDate(_todayDate()),
                  ),
                ),
                const Gap(14),
                Expanded(
                  flex: 2,
                  child: _DialogPrimaryButton(
                    label: context.l10n.confirmButton,
                    onTap: () => Navigator.of(context).pop(_selectedDate),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onPreviousMonth() {
    final DateTime previous = _clampedMonth(_selectedDate, -1);
    if (previous.isBefore(_dateOnly(widget.firstDate))) {
      setState(() => _selectedDate = _dateOnly(widget.firstDate));
      return;
    }
    setState(() => _selectedDate = previous);
  }

  void _onNextMonth() =>
      setState(() => _selectedDate = _clampedMonth(_selectedDate, 1));

  void _onChangeMonth(int monthDelta) {
    final DateTime next = _clampedMonth(_selectedDate, monthDelta);
    if (next.isBefore(_dateOnly(widget.firstDate))) {
      setState(() => _selectedDate = _dateOnly(widget.firstDate));
      return;
    }
    setState(() => _selectedDate = next);
  }

  void _onSelectDate(DateTime date) {
    final DateTime normalized = _dateOnly(date);
    if (normalized.isBefore(_dateOnly(widget.firstDate))) {
      return;
    }
    setState(() => _selectedDate = normalized);
  }

  DateTime _clampedMonth(DateTime value, int monthDelta) {
    final DateTime monthStart = DateTime(value.year, value.month + monthDelta);
    final int day = value.day.clamp(
      1,
      DateUtils.getDaysInMonth(monthStart.year, monthStart.month),
    );
    return DateTime(monthStart.year, monthStart.month, day);
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime _todayDate() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

class _CalendarMonthHeader extends StatelessWidget {
  const _CalendarMonthHeader({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Container(
    height: 58,
    padding: const EdgeInsets.symmetric(horizontal: 6),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: context.colorTokens.borderUnfocused),
      boxShadow: [
        BoxShadow(
          color: context.colorTokens.surfaceShadow.withValues(alpha: 0.10),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        _MonthArrowButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.extraBold20.copyWith(
              color: context.colorTokens.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        _MonthArrowButton(icon: Icons.chevron_right_rounded, onTap: onNext),
      ],
    ),
  );
}

class _MonthArrowButton extends StatelessWidget {
  const _MonthArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.92,
    child: SizedBox(
      width: 46,
      height: 46,
      child: Icon(icon, color: context.colorTokens.primary, size: 34),
    ),
  );
}

class _DialogSecondaryButton extends StatelessWidget {
  const _DialogSecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.97,
    child: Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodyMedium.copyWith(
          color: context.colorTokens.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class _DialogPrimaryButton extends StatelessWidget {
  const _DialogPrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.97,
    child: Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: context.colorTokens.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.textPrimaryButton.copyWith(
          color: context.colorTokens.primaryForeground,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}
