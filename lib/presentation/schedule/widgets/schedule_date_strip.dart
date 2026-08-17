import "dart:math" as math;

import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:intl/intl.dart";

class ScheduleDateStrip extends StatelessWidget {
  const ScheduleDateStrip({
    required this.selectedDate,
    required this.onSelectDate,
    required this.hasEntryForDate,
    required this.eventColorsForDate,
    this.onMonthChanged,
    super.key,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final bool Function(DateTime date) hasEntryForDate;
  final List<Color> Function(DateTime date) eventColorsForDate;
  final ValueChanged<int>? onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final DateTime monthStart = DateTime(selectedDate.year, selectedDate.month);
    final int leadingEmptyDays = monthStart.weekday - DateTime.monday;
    final int daysInMonth = DateUtils.getDaysInMonth(
      selectedDate.year,
      selectedDate.month,
    );
    final int gridDayCount =
        ((leadingEmptyDays + daysInMonth + 6) / 7).floor() * 7;
    final List<DateTime?> dates = [
      for (int index = 0; index < gridDayCount; index++)
        if (index < leadingEmptyDays || index >= leadingEmptyDays + daysInMonth)
          null
        else
          DateTime(
            selectedDate.year,
            selectedDate.month,
            index - leadingEmptyDays + 1,
          ),
    ];
    final DateTime weekdaySeed = DateTime(2024, 1);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: _handleHorizontalDragEnd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (
                int weekday = DateTime.monday;
                weekday <= DateTime.sunday;
                weekday++
              )
                Expanded(
                  child: Text(
                    DateFormat.E(locale)
                        .format(weekdaySeed.add(Duration(days: weekday - 1)))
                        .characters
                        .take(3)
                        .toString()
                        .toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.textHint,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const Gap(10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 40,
              mainAxisSpacing: 8,
            ),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final DateTime? date = dates[index];
              if (date == null) {
                return const SizedBox.shrink();
              }
              return _CalendarDay(
                date: date,
                isSelected: _isSameDate(date, selectedDate),
                hasEntry: hasEntryForDate(date),
                eventColors: eventColorsForDate(date),
                onTap: () => onSelectDate(date),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final double? velocity = details.primaryVelocity;
    if (velocity == null || velocity.abs() < 180) {
      return;
    }
    onMonthChanged?.call(velocity < 0 ? 1 : -1);
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.date,
    required this.isSelected,
    required this.hasEntry,
    required this.eventColors,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool hasEntry;
  final List<Color> eventColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color eventAccent = eventColors.isEmpty
        ? context.colorTokens.primary
        : eventColors.first;
    final Color eventFill =
        Color.lerp(
          eventAccent,
          Colors.white,
          context.isDarkMode ? 0.74 : 0.84,
        ) ??
        eventAccent;
    final Color textColor = isSelected
        ? context.colorTokens.primaryForeground
        : context.colorTokens.textBody;

    return BounceTap(
      onTap: onTap,
      child: Center(
        child: SizedBox(
          width: 48,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? context.colorTokens.primary
                      : hasEntry
                      ? eventFill.withValues(alpha: 0.72)
                      : Colors.transparent,
                ),
                child: Text(
                  "${date.day}",
                  maxLines: 1,
                  style: context.textStyles.black20.copyWith(
                    color: textColor,
                    fontSize: 15,
                  ),
                ),
              ),
              if (hasEntry)
                Positioned.fill(
                  child: IgnorePointer(child: _EventDots(colors: eventColors)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventDots extends StatelessWidget {
  const _EventDots({required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final List<Color> visibleColors = colors.take(4).toList();
    const double dotSize = 5;
    const double ringSize = 38;
    const double radius = 15.5;
    final List<double> angles = switch (visibleColors.length) {
      1 => const [math.pi / 2],
      2 => const [math.pi * 0.40, math.pi * 0.60],
      3 => const [math.pi * 0.35, math.pi / 2, math.pi * 0.65],
      _ => const [
        math.pi * 0.30,
        math.pi * 0.43,
        math.pi * 0.57,
        math.pi * 0.70,
      ],
    };

    return Center(
      child: SizedBox(
        width: ringSize,
        height: ringSize,
        child: Stack(
          children: [
            for (int index = 0; index < visibleColors.length; index++)
              Positioned(
                left:
                    ringSize / 2 +
                    math.cos(angles[index]) * radius -
                    dotSize / 2,
                top:
                    ringSize / 2 +
                    math.sin(angles[index]) * radius -
                    dotSize / 2,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: visibleColors[index].withValues(alpha: 0.9),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
