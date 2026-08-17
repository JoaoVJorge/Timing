import "package:flutter_test/flutter_test.dart";
import "package:timing/presentation/schedule/widgets/schedule_date_strip.dart";

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

  testWidgets("shows only dates from the selected month", (tester) async {
    final DateTime selected = DateTime(2026, 8, 15);

    await pumpInScrollView(
      tester,
      ScheduleDateStrip(
        selectedDate: selected,
        onSelectDate: (_) {},
        hasEntryForDate: (_) => false,
        eventColorsForDate: (_) => const [],
      ),
    );

    expect(find.text("1"), findsOneWidget);
    expect(find.text("31"), findsOneWidget);
    expect(find.text("15"), findsOneWidget);
  });

  testWidgets("swiping horizontally requests month changes", (tester) async {
    final DateTime selected = DateTime(2026, 8, 15);
    final List<int> changes = [];

    await pumpInScrollView(
      tester,
      ScheduleDateStrip(
        selectedDate: selected,
        onSelectDate: (_) {},
        onMonthChanged: changes.add,
        hasEntryForDate: (_) => false,
        eventColorsForDate: (_) => const [],
      ),
    );

    await tester.fling(
      find.byType(ScheduleDateStrip),
      const Offset(-300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    await tester.fling(
      find.byType(ScheduleDateStrip),
      const Offset(300, 0),
      1000,
    );
    await tester.pumpAndSettle();

    expect(changes, [1, -1]);
  });
}
