import "package:flutter_test/flutter_test.dart";
import "package:help_out/presentation/schedule/widgets/schedule_date_strip.dart";
import "package:intl/intl.dart";

import "../../support/pump_in_scroll_view.dart";

void main() {
  testWidgets("renders 21 days with today selectable", (tester) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    DateTime? tapped;

    await pumpInScrollView(
      tester,
      ScheduleDateStrip(selectedDate: today, onSelectDate: (date) => tapped = date),
    );

    final String todayDay = DateFormat("dd").format(today);
    expect(find.text(todayDay), findsWidgets);

    await tester.tap(find.text(todayDay).first);
    await tester.pumpAndSettle();
    expect(tapped, today);
  });

  testWidgets("shows past and future dates", (tester) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    await pumpInScrollView(
      tester,
      ScheduleDateStrip(selectedDate: today, onSelectDate: (_) {}),
    );

    final String pastDay = DateFormat(
      "dd",
    ).format(today.subtract(const Duration(days: 10)));
    final String futureDay = DateFormat(
      "dd",
    ).format(today.add(const Duration(days: 10)));
    expect(find.text(pastDay), findsWidgets);
    expect(find.text(futureDay), findsWidgets);
  });
}
