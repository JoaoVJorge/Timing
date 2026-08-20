import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/shared/widgets/swipe_reveal_actions.dart";
import "package:timing/theme/theme.dart";

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
}

void main() {
  testWidgets("reveals actions on left swipe and fires the tapped action", (
    tester,
  ) async {
    var edited = false;
    var deleted = false;

    await _pump(
      tester,
      SwipeRevealActions(
        actions: [
          SwipeRevealAction(
            iconData: Icons.edit_rounded,
            background: Colors.blue,
            onTap: () => edited = true,
          ),
          SwipeRevealAction(
            iconData: Icons.delete_rounded,
            background: Colors.red,
            onTap: () => deleted = true,
          ),
        ],
        child: Container(
          height: 64,
          color: Colors.white,
          alignment: Alignment.center,
          child: const Text("Entry"),
        ),
      ),
    );

    // Hidden until swiped.
    expect(find.byIcon(Icons.edit_rounded), findsNothing);

    await tester.drag(find.text("Entry"), const Offset(-140, 0));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    expect(find.byIcon(Icons.delete_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_rounded));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
    expect(edited, isFalse);
  });
}
