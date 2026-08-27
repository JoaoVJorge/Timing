import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/presentation/groups/widgets/groups_header.dart";
import "package:timing/presentation/home/widgets/home_activity_grid.dart";
import "package:timing/shared/widgets/app_empty_state.dart";
import "package:timing/shared/widgets/app_section_header.dart";

import "../../support/pump_in_scroll_view.dart";

void main() {
  testWidgets("AppEmptyState renders icon, copy, preview and action", (
    tester,
  ) async {
    int taps = 0;

    await pumpInScrollView(
      tester,
      AppEmptyState(
        icon: Icons.calendar_month_rounded,
        title: "Nothing yet",
        description: "Create the first one to get going.",
        actionLabel: "Create",
        onTapAction: () => taps++,
        preview: const Text("Example"),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text("Example"), findsOneWidget);

    await tester.tap(find.text("Create"));
    expect(taps, 1);
  });

  testWidgets("AppSectionHeader shows a badge without an action", (
    tester,
  ) async {
    await pumpInScrollView(
      tester,
      const AppSectionHeader(title: "Pending", badge: "2 of 4 done"),
    );

    expect(tester.takeException(), isNull);
    expect(find.text("2 of 4 done"), findsOneWidget);
  });

  testWidgets("HomeActivityGrid lays out four tiles", (tester) async {
    await pumpInScrollView(
      tester,
      HomeActivityGrid(
        activities: [
          for (final TimeCategoryType category in TimeCategoryType.values)
            (category: category, label: category.name, value: "12m"),
        ],
        onTapActivity: (_) {},
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text("12m"), findsNWidgets(TimeCategoryType.values.length));
  });

  testWidgets("GroupsHeader exposes create action", (tester) async {
    int create = 0;

    await pumpInScrollView(
      tester,
      GroupsHeader(onTapCreateGroup: () => create++),
    );

    await tester.tap(find.byIcon(Icons.add_rounded));

    expect(create, 1);
  });
}
