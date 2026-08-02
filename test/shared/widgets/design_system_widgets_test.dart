import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/domain/enums/leaderboard_period_type.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/presentation/groups/widgets/group_identity_card.dart";
import "package:help_out/presentation/groups/widgets/groups_header.dart";
import "package:help_out/presentation/home/widgets/home_activity_grid.dart";
import "package:help_out/presentation/home/widgets/home_day_summary_line.dart";
import "package:help_out/shared/widgets/app_empty_state.dart";
import "package:help_out/shared/widgets/app_nav_row.dart";
import "package:help_out/shared/widgets/app_section_header.dart";

import "../../support/pump_in_scroll_view.dart";

GroupMemberEntity _member(String id, String name) => GroupMemberEntity(
  id: id,
  name: name,
  avatarColorValue: 0xFF4F7DF3,
  todaySeconds: 600,
  weekSeconds: 3600,
  monthSeconds: 7200,
);

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

  testWidgets("AppNavRowGroup renders dividers between rows", (tester) async {
    await pumpInScrollView(
      tester,
      AppNavRowGroup(
        rows: [
          AppNavRow(
            icon: Icons.task_alt_rounded,
            title: "Goals",
            subtitle: "2 of 4 done",
            onTap: () {},
          ),
          AppNavRow(
            icon: Icons.calendar_month_rounded,
            title: "Schedule",
            onTap: () {},
          ),
        ],
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets("AppNavRow keeps the whole row tappable", (tester) async {
    int taps = 0;

    await pumpInScrollView(
      tester,
      AppNavRow(
        icon: Icons.task_alt_rounded,
        title: "Goals",
        onTap: () => taps++,
      ),
    );

    final Rect row = tester.getRect(find.byType(AppNavRow));
    // Empty padding on the far right, away from any text or icon.
    await tester.tapAt(Offset(row.right - 4, row.center.dy));
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
            (
              category: category,
              label: category.name,
              value: "12m",
              meta: "Biology",
            ),
        ],
        onTapActivity: (_) {},
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text("12m"), findsNWidgets(TimeCategoryType.values.length));
  });

  testWidgets("HomeDaySummaryLine renders one line", (tester) async {
    await pumpInScrollView(
      tester,
      const HomeDaySummaryLine(focus: "12m", pages: 15, goals: 2),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets("GroupIdentityCard shows the member count and overflow", (
    tester,
  ) async {
    await pumpInScrollView(
      tester,
      GroupIdentityCard(
        group: GroupEntity(
          id: "g1",
          name: "Study Squad",
          theme: GroupThemeType.studying,
          members: [
            for (int index = 0; index < 7; index++)
              _member("m$index", "Member $index"),
          ],
        ),
        period: LeaderboardPeriodType.thisWeek,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text("Study Squad"), findsOneWidget);
    expect(find.text("+2"), findsOneWidget);
  });

  testWidgets("GroupsHeader exposes friends and create actions", (
    tester,
  ) async {
    int friends = 0;
    int create = 0;

    await pumpInScrollView(
      tester,
      GroupsHeader(
        onTapFriends: () => friends++,
        onTapCreateGroup: () => create++,
      ),
    );

    await tester.tap(find.byIcon(Icons.group_rounded));
    await tester.tap(find.byIcon(Icons.add_rounded));

    expect(friends, 1);
    expect(create, 1);
  });
}
