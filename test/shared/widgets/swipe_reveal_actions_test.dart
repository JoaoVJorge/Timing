import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/shared/widgets/swipe_reveal_actions.dart";
import "package:timing/theme/theme.dart";

void main() {
  testWidgets("reveals actions on either side of a row", (tester) async {
    bool leadingTapped = false;
    bool trailingTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
        home: Scaffold(
          body: SwipeRevealActions(
            leadingActions: [
              SwipeRevealAction(
                iconData: Icons.person_add_alt_1_rounded,
                background: Colors.blue,
                onTap: () => leadingTapped = true,
              ),
            ],
            actions: [
              SwipeRevealAction(
                iconData: Icons.flag_outlined,
                background: Colors.red,
                onTap: () => trailingTapped = true,
              ),
            ],
            child: Container(
              key: const ValueKey("swipe-row"),
              width: double.infinity,
              height: 72,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    await tester.drag(
      find.byKey(const ValueKey("swipe-row")),
      const Offset(90, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.person_add_alt_1_rounded));
    expect(leadingTapped, isTrue);
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey("swipe-row")),
      const Offset(-90, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.flag_outlined));
    expect(trailingTapped, isTrue);
  });

  group("square action blocks", () {
    Future<void> pumpRow(WidgetTester tester, {double? squareSize}) =>
        tester.pumpWidget(
          MaterialApp(
            theme: AppThemes.build(
              seed: Colors.blue,
              brightness: Brightness.light,
            ),
            home: Scaffold(
              body: SwipeRevealActions(
                squareActionSize: squareSize,
                leadingActions: [
                  SwipeRevealAction(
                    iconData: Icons.person_add_alt_1_rounded,
                    background: Colors.blue,
                    onTap: () {},
                  ),
                ],
                actions: [
                  SwipeRevealAction(
                    iconData: Icons.flag_outlined,
                    background: Colors.red,
                    onTap: () {},
                  ),
                  SwipeRevealAction(
                    iconData: Icons.edit_rounded,
                    background: Colors.green,
                    onTap: () {},
                  ),
                ],
                child: Container(
                  key: const ValueKey("swipe-row"),
                  width: double.infinity,
                  height: 90,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );

    Size blockAround(WidgetTester tester, IconData icon) => tester.getSize(
      find
          .ancestor(of: find.byIcon(icon), matching: find.byType(Container))
          .first,
    );

    testWidgets("with a size, every block on both sides is that square", (
      tester,
    ) async {
      await pumpRow(tester, squareSize: 56);

      await tester.drag(
        find.byKey(const ValueKey("swipe-row")),
        const Offset(120, 0),
      );
      await tester.pumpAndSettle();
      expect(
        blockAround(tester, Icons.person_add_alt_1_rounded),
        const Size(56, 56),
      );

      await tester.drag(
        find.byKey(const ValueKey("swipe-row")),
        const Offset(-260, 0),
      );
      await tester.pumpAndSettle();
      expect(blockAround(tester, Icons.flag_outlined), const Size(56, 56));
      expect(blockAround(tester, Icons.edit_rounded), const Size(56, 56));
    });

    testWidgets("the row opens exactly as wide as the squares need", (
      tester,
    ) async {
      await pumpRow(tester, squareSize: 56);

      await tester.drag(
        find.byKey(const ValueKey("swipe-row")),
        const Offset(-400, 0),
      );
      await tester.pumpAndSettle();

      // Two 56 squares, the gap between them and the gap before the row.
      final double shifted = -tester
          .getTopLeft(find.byKey(const ValueKey("swipe-row")))
          .dx;
      expect(shifted, 2 * 56 + 8 + 8);
    });

    testWidgets("without a size the blocks keep filling the row", (
      tester,
    ) async {
      await pumpRow(tester);

      await tester.drag(
        find.byKey(const ValueKey("swipe-row")),
        const Offset(120, 0),
      );
      await tester.pumpAndSettle();

      final Size block = blockAround(tester, Icons.person_add_alt_1_rounded);
      expect(block.width, 58);
      expect(block.height, isNot(58));
    });
  });
}
