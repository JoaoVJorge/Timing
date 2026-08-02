import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:intl/intl.dart";

class ScheduleDateStrip extends StatefulWidget {
  const ScheduleDateStrip({
    required this.selectedDate,
    required this.onSelectDate,
    super.key,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  static const int _daysBefore = 10;
  static const int _daysAfter = 10;
  static const double _chipWidth = 62;
  static const double _chipGap = 8;

  @override
  State<ScheduleDateStrip> createState() => _ScheduleDateStripState();
}

class _ScheduleDateStripState extends State<ScheduleDateStrip> {
  late final ScrollController _scrollController;
  late final DateTime _today;
  late final List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _dates = [
      for (
        int offset = -ScheduleDateStrip._daysBefore;
        offset <= ScheduleDateStrip._daysAfter;
        offset++
      )
        _today.add(Duration(days: offset)),
    ];
    // Open with today as the first visible card; earlier days stay scrollable
    // to the left.
    final double todayOffset =
        ScheduleDateStrip._daysBefore *
        (ScheduleDateStrip._chipWidth + ScheduleDateStrip._chipGap);
    _scrollController = ScrollController(initialScrollOffset: todayOffset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          for (int index = 0; index < _dates.length; index++) ...[
            if (index > 0) const Gap(ScheduleDateStrip._chipGap),
            SizedBox(
              width: ScheduleDateStrip._chipWidth,
              child: _DateChip(
                label: DateFormat.E(locale)
                    .format(_dates[index])
                    .characters
                    .take(3)
                    .toString()
                    .toUpperCase(),
                day: DateFormat("dd", locale).format(_dates[index]),
                isSelected: _isSameDate(_dates[index], widget.selectedDate),
                isToday: _isSameDate(_dates[index], _today),
                onTap: () => widget.onSelectDate(_dates[index]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final String label;
  final String day;
  final bool isSelected;
  final bool isToday;
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
            width: ScheduleDateStrip._chipWidth,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colorTokens.primaryVeryLight
                  : context.colorTokens.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? context.colorTokens.primary
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
                  : isToday
                  ? context.colorTokens.primary.withValues(alpha: 0.4)
                  : context.colorTokens.borderUnfocused.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
