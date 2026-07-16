import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/auth_onboarding_widgets.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:intl/intl.dart";

class BirthDatePickerSheet extends StatefulWidget {
  const BirthDatePickerSheet({required this.initialDate, super.key});

  final DateTime initialDate;

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
  }) => showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BirthDatePickerSheet(initialDate: initialDate),
  );

  @override
  State<BirthDatePickerSheet> createState() => _BirthDatePickerSheetState();
}

class _BirthDatePickerSheetState extends State<BirthDatePickerSheet> {
  static const int _minYear = 1900;
  static const double _calendarBodyHeight = 296;

  late DateTime _selectedDate;
  late DateTime _visibleMonth;
  bool _isYearPickerVisible = false;

  DateTime get _today {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  int get _daysInVisibleMonth =>
      DateUtils.getDaysInMonth(_visibleMonth.year, _visibleMonth.month);

  int get _leadingEmptyDays =>
      DateTime(_visibleMonth.year, _visibleMonth.month).weekday % 7;

  bool get _canGoToNextMonth =>
      DateTime(_visibleMonth.year, _visibleMonth.month + 1).isBefore(
        DateTime(_today.year, _today.month + 1),
      );

  bool get _canGoToPreviousMonth =>
      _visibleMonth.year > _minYear || _visibleMonth.month > 1;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  void _onTapPreviousMonth() {
    if (!_canGoToPreviousMonth) {
      return;
    }
    setState(
      () => _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month - 1,
      ),
    );
  }

  void _onTapNextMonth() {
    if (!_canGoToNextMonth) {
      return;
    }
    setState(
      () => _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + 1,
      ),
    );
  }

  void _onSelectYear(int year) {
    setState(() {
      final DateTime candidate = DateTime(year, _visibleMonth.month);
      _visibleMonth = candidate.isAfter(_today)
          ? DateTime(_today.year, _today.month)
          : candidate;
      _isYearPickerVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: AuthOnboardingColors.background,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    padding: EdgeInsets.only(
      left: 20,
      right: 20,
      bottom: 20 + MediaQuery.paddingOf(context).bottom,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Gap(12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AuthOnboardingColors.navy.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const Gap(16),
        Text(
          context.l10n.birthDateHint,
          style: const TextStyle(
            color: AuthOnboardingColors.navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const Gap(16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          decoration: AuthOnboardingDecorations.card,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              const Gap(12),
              SizedBox(
                height: _calendarBodyHeight,
                child: _isYearPickerVisible
                    ? _buildYearGrid(context)
                    : _buildCalendar(context),
              ),
            ],
          ),
        ),
        const Gap(20),
        AuthPrimaryButton(
          label: context.l10n.confirmButton,
          onTap: () => Navigator.of(context).pop(_selectedDate),
        ),
      ],
    ),
  );

  Widget _buildHeader(BuildContext context) {
    final String monthName =
        toBeginningOfSentenceCase(
          DateFormat.MMMM(
            Localizations.localeOf(context).toLanguageTag(),
          ).format(_visibleMonth),
        ) ??
        "";

    return Row(
      children: [
        _MonthArrow(
          icon: Icons.chevron_left_rounded,
          enabled: _canGoToPreviousMonth,
          onTap: _onTapPreviousMonth,
        ),
        Expanded(
          child: BounceTap(
            onTap: () => setState(
              () => _isYearPickerVisible = !_isYearPickerVisible,
            ),
            child: Column(
              children: [
                Text(
                  monthName,
                  style: const TextStyle(
                    color: AuthOnboardingColors.navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${_visibleMonth.year}",
                      style: const TextStyle(
                        color: AuthOnboardingColors.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    Icon(
                      _isYearPickerVisible
                          ? Icons.arrow_drop_up_rounded
                          : Icons.arrow_drop_down_rounded,
                      color: AuthOnboardingColors.textMuted,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        _MonthArrow(
          icon: Icons.chevron_right_rounded,
          enabled: _canGoToNextMonth,
          onTap: _onTapNextMonth,
        ),
      ],
    );
  }

  Widget _buildCalendar(BuildContext context) => Column(
    children: [
      Row(
        children: [
          for (final String weekday
              in MaterialLocalizations.of(context).narrowWeekdays)
            Expanded(
              child: Center(
                child: Text(
                  weekday.toUpperCase(),
                  style: const TextStyle(
                    color: AuthOnboardingColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
        ],
      ),
      const Gap(8),
      ..._buildCalendarRows(context),
    ],
  );

  List<Widget> _buildCalendarRows(BuildContext context) {
    final List<Widget> cells = [
      for (int i = 0; i < _leadingEmptyDays; i++) const SizedBox.shrink(),
      for (int day = 1; day <= _daysInVisibleMonth; day++)
        _buildDayCell(context, day),
    ];

    while (cells.length % 7 != 0) {
      cells.add(const SizedBox.shrink());
    }

    return [
      for (int i = 0; i < cells.length; i += 7)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              for (final Widget cell in cells.sublist(i, i + 7))
                Expanded(child: Center(child: cell)),
            ],
          ),
        ),
    ];
  }

  Widget _buildDayCell(BuildContext context, int day) {
    final DateTime date = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      day,
    );
    final bool isFuture = date.isAfter(_today);
    final bool isToday = DateUtils.isSameDay(date, _today);
    final bool isSelected = DateUtils.isSameDay(date, _selectedDate);

    final Color textColor = switch ((isFuture, isSelected)) {
      (true, _) => AuthOnboardingColors.textMuted.withValues(alpha: 0.4),
      (_, true) => AuthOnboardingColors.navy,
      _ => AuthOnboardingColors.navy.withValues(alpha: 0.8),
    };

    return GestureDetector(
      onTap: isFuture ? null : () => setState(() => _selectedDate = date),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isSelected ? AuthOnboardingColors.yellowGradient : null,
          border: isToday && !isSelected
              ? Border.all(
                  color: AuthOnboardingColors.yellow.withValues(alpha: 0.6),
                  width: 1.5,
                )
              : null,
        ),
        child: Text(
          "$day",
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildYearGrid(BuildContext context) {
    final List<int> years = [
      for (int year = _today.year; year >= _minYear; year--) year,
    ];

    return GridView.builder(
      padding: const EdgeInsets.only(top: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.2,
      ),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final int year = years[index];
        final bool isSelected = year == _visibleMonth.year;
        return BounceTap(
          pressedScale: 0.96,
          onTap: () => _onSelectYear(year),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? AuthOnboardingColors.yellowGradient
                  : null,
              color: isSelected
                  ? null
                  : AuthOnboardingColors.background.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AuthOnboardingColors.navy.withValues(
                  alpha: isSelected ? 0 : 0.08,
                ),
              ),
            ),
            child: Text(
              "$year",
              style: TextStyle(
                color: AuthOnboardingColors.navy,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget arrow = Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AuthOnboardingColors.yellowLight.withValues(
          alpha: enabled ? 0.48 : 0.2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: AuthOnboardingColors.navy.withValues(alpha: enabled ? 1 : 0.3),
        size: 26,
      ),
    );

    if (!enabled) {
      return arrow;
    }

    return BounceTap(onTap: onTap, child: arrow);
  }
}
