import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/daily_goals/widgets/daily_task_tile.dart";
import "package:timing/theme/theme.dart";

const DailyTaskEntity _personalGoal = DailyTaskEntity(
  id: "goal-1",
  name: "Beber água",
  colorValue: 0xFF4C84FF,
  targetDays: 7,
  completedDates: [],
);

Future<void> _pumpTile(
  WidgetTester tester, {
  DailyTaskEntity task = _personalGoal,
  Future<void> Function()? onToggle,
}) => tester.pumpWidget(
  MaterialApp(
    locale: const Locale("pt"),
    theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      body: DailyTaskTile(
        key: const ValueKey("tile"),
        task: task,
        onEdit: () {},
        onToggle: onToggle ?? () async {},
        onDelete: () {},
      ),
    ),
  ),
);

/// The revealed action buttons: the 56 x 56 squares.
Finder _squares() => find.byWidgetPredicate(
  (widget) =>
      widget is Container &&
      widget.constraints?.maxWidth == 56 &&
      widget.constraints?.maxHeight == 56,
);

void main() {
  testWidgets("tapping the goal tile toggles it", (tester) async {
    int toggles = 0;

    await _pumpTile(tester, onToggle: () async => toggles++);

    await tester.tap(find.text("Beber água"));
    await tester.pumpAndSettle();

    expect(toggles, 1);
  });

  testWidgets("pulling right reveals nothing: a goal's data is not cleared", (
    tester,
  ) async {
    await _pumpTile(tester);
    final Offset before = tester.getTopLeft(find.text("Beber água"));

    await tester.drag(find.byKey(const ValueKey("tile")), const Offset(120, 0));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.delete_sweep_rounded), findsNothing);
    expect(_squares(), findsNothing);
    expect(tester.getTopLeft(find.text("Beber água")), before);
  });

  testWidgets("the edit block is tinted with the goal's color", (tester) async {
    await _pumpTile(tester);

    await tester.drag(
      find.byKey(const ValueKey("tile")),
      const Offset(-200, 0),
    );
    await tester.pumpAndSettle();

    final Container edit = tester.widget<Container>(_squares().first);
    expect(
      (edit.decoration! as BoxDecoration).color,
      const Color(0xFF4C84FF).withValues(alpha: 0.14),
    );
  });

  group("revealed blocks are squares", () {
    testWidgets("the blocks on the left side are the same square, evenly set", (
      tester,
    ) async {
      await _pumpTile(tester);

      await tester.drag(
        find.byKey(const ValueKey("tile")),
        const Offset(-200, 0),
      );
      await tester.pumpAndSettle();

      expect(_squares(), findsNWidgets(2));
      for (final Element block in _squares().evaluate()) {
        expect(block.size, const Size(56, 56));
      }
      // Both sit at the same height, centered on the row.
      final double rowCenter = tester.getCenter(find.byType(DailyTaskTile)).dy;
      for (int index = 0; index < 2; index++) {
        expect(
          tester.getCenter(_squares().at(index)).dy,
          closeTo(rowCenter, 0.01),
        );
      }
    });

    testWidgets("the squares fit inside the row with the same room around", (
      tester,
    ) async {
      await _pumpTile(tester);

      await tester.drag(
        find.byKey(const ValueKey("tile")),
        const Offset(-200, 0),
      );
      await tester.pumpAndSettle();

      final Rect row = tester.getRect(find.byType(DailyTaskTile));
      final Rect square = tester.getRect(_squares().first);
      expect(square.top - row.top, closeTo(row.bottom - square.bottom, 0.01));
      expect(square.top, greaterThanOrEqualTo(row.top));
    });
  });
}
