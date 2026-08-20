import "dart:math" as math;

import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:intl/intl.dart";

class ScheduleDateStrip extends StatefulWidget {
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
  State<ScheduleDateStrip> createState() => _ScheduleDateStripState();
}

class _ScheduleDateStripState extends State<ScheduleDateStrip> {
  // A calendar month never spans more than six weeks; pinning the grid to six
  // rows keeps the strip the exact same height every month, so nothing below
  // it shifts as the user pages through months.
  static const int _weekRows = 6;
  static const double _rowExtent = 40;
  static const double _rowSpacing = 8;
  static const double _gridHeight =
      _weekRows * _rowExtent + (_weekRows - 1) * _rowSpacing;

  // A large anchor gives effectively unbounded paging in both directions.
  static const int _basePage = 100000;

  late final PageController _pageController;
  late final int _anchorOrdinal;
  late int _currentPage;

  static int _ordinal(DateTime date) => date.year * 12 + (date.month - 1);

  @override
  void initState() {
    super.initState();
    _anchorOrdinal = _ordinal(widget.selectedDate);
    _currentPage = _basePage;
    _pageController = PageController(initialPage: _basePage);
  }

  @override
  void didUpdateWidget(ScheduleDateStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int targetPage =
        _basePage + (_ordinal(widget.selectedDate) - _anchorOrdinal);
    if (targetPage == _currentPage) {
      return;
    }
    // The month changed from outside a swipe (month picker, add flow). Slide to
    // it when it is adjacent, otherwise jump so long distances stay instant.
    final int delta = (targetPage - _currentPage).abs();
    _currentPage = targetPage;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }
      if (delta <= 1) {
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      } else {
        _pageController.jumpToPage(targetPage);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _monthForPage(int page) {
    final int ordinal = _anchorOrdinal + (page - _basePage);
    return DateTime(ordinal ~/ 12, ordinal % 12 + 1);
  }

  void _onPageChanged(int page) {
    final int delta = page - _currentPage;
    if (delta == 0) {
      return;
    }
    _currentPage = page;
    widget.onMonthChanged?.call(delta);
  }

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final DateTime weekdaySeed = DateTime(2024, 1);

    return Column(
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
        SizedBox(
          height: _gridHeight,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, page) => _MonthGrid(
              month: _monthForPage(page),
              selectedDate: widget.selectedDate,
              onSelectDate: widget.onSelectDate,
              hasEntryForDate: widget.hasEntryForDate,
              eventColorsForDate: widget.eventColorsForDate,
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selectedDate,
    required this.onSelectDate,
    required this.hasEntryForDate,
    required this.eventColorsForDate,
  });

  final DateTime month;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final bool Function(DateTime date) hasEntryForDate;
  final List<Color> Function(DateTime date) eventColorsForDate;

  @override
  Widget build(BuildContext context) {
    final DateTime monthStart = DateTime(month.year, month.month);
    final int leadingEmptyDays = monthStart.weekday - DateTime.monday;
    final int daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    const int gridDayCount = _ScheduleDateStripState._weekRows * 7;
    final List<DateTime?> dates = [
      for (int index = 0; index < gridDayCount; index++)
        if (index < leadingEmptyDays || index >= leadingEmptyDays + daysInMonth)
          null
        else
          DateTime(month.year, month.month, index - leadingEmptyDays + 1),
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: _ScheduleDateStripState._rowExtent,
        mainAxisSpacing: _ScheduleDateStripState._rowSpacing,
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
    );
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
