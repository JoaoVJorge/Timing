import "package:flutter_test/flutter_test.dart";
import "package:help_out/presentation/schedule/widgets/schedule_date_strip.dart";

import "../../support/pump_in_scroll_view.dart";

void main() {
  testWidgets("renders selected month with selected day tappable", (
    tester,
  ) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    DateTime? tapped;

    await pumpInScrollView(
      tester,
      ScheduleDateStrip(
        selectedDate: today,
        onSelectDate: (date) => tapped = date,
        hasEntryForDate: (_) => false,
        eventColorsForDate: (_) => const [],
      ),
    );

    final String todayDay = "${today.day}";
    expect(find.text(todayDay), findsWidgets);

    await tester.tap(find.text(todayDay).first);
    await tester.pumpAndSettle();
    expect(tapped, today);
  });

  testWidgets("shows leading and trailing dates around the month", (
    tester,
  ) async {
    final DateTime now = DateTime.now();
    final DateTime selected = DateTime(now.year, now.month, 15);
    final DateTime monthStart = DateTime(selected.year, selected.month);
    final DateTime gridStart = monthStart.subtract(
      Duration(days: monthStart.weekday - DateTime.monday),
    );
    final DateTime nextMonthStart = DateTime(selected.year, selected.month + 1);
    final int gridDayCount =
        ((nextMonthStart.difference(gridStart).inDays + 6) / 7).ceil() * 7;
    final DateTime gridEnd = gridStart.add(Duration(days: gridDayCount - 1));

    await pumpInScrollView(
      tester,
      ScheduleDateStrip(
        selectedDate: selected,
        onSelectDate: (_) {},
        hasEntryForDate: (_) => false,
        eventColorsForDate: (_) => const [],
      ),
    );

    expect(find.text("${gridStart.day}"), findsWidgets);
    expect(find.text("${gridEnd.day}"), findsWidgets);
  });
}
