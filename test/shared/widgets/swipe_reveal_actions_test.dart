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
}
