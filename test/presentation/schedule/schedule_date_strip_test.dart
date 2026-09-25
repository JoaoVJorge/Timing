import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
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

  /// Day circles filled with the selection color (nothing has an entry here).
  int markedDays(WidgetTester tester) {
    final Color primary = tester
        .element(find.byType(ScheduleDateStrip))
        .colorTokens
        .primary;
    return tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .where((box) {
          final Decoration? decoration = box.decoration;
          return decoration is BoxDecoration && decoration.color == primary;
        })
        .length;
  }

  testWidgets("marks the selected date in its own month only", (tester) async {
    await pumpInScrollView(
      tester,
      ScheduleDateStrip(
        selectedDate: DateTime(2026, 9, 25),
        onSelectDate: (_) {},
        hasEntryForDate: (_) => false,
        eventColorsForDate: (_) => const [],
      ),
    );

    expect(markedDays(tester), 1);
  });

  testWidgets("marks no day in a month the selected date is not in", (
    tester,
  ) async {
    await pumpInScrollView(
      tester,
      ScheduleDateStrip(
        selectedDate: DateTime(2026, 9, 25),
        visibleMonth: DateTime(2026, 10),
        onSelectDate: (_) {},
        hasEntryForDate: (_) => false,
        eventColorsForDate: (_) => const [],
      ),
    );

    // October has a 25th too, and a 31st that September lacks.
    expect(find.text("31"), findsOneWidget);
    expect(find.text("25"), findsOneWidget);
    expect(markedDays(tester), 0);
  });

  testWidgets("follows the visible month when it changes", (tester) async {
    Widget strip(DateTime month) => ScheduleDateStrip(
      selectedDate: DateTime(2026, 9, 25),
      visibleMonth: month,
      onSelectDate: (_) {},
      hasEntryForDate: (_) => false,
      eventColorsForDate: (_) => const [],
    );

    await pumpInScrollView(tester, strip(DateTime(2026, 9)));
    expect(find.text("31"), findsNothing);
    expect(markedDays(tester), 1);

    await pumpInScrollView(tester, strip(DateTime(2026, 10)));
    await tester.pumpAndSettle();
    expect(find.text("31"), findsOneWidget);
    expect(markedDays(tester), 0);
  });
}
