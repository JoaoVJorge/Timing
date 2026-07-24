import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/theme/theme.dart";

void main() {
  testWidgets("back button has a 38.4x38.4 tap target", (tester) async {
    int tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
        home: Scaffold(
          body: AppTopBar(
            title: "Title",
            showBackButton: true,
            onBack: () => tapCount++,
          ),
        ),
      ),
    );

    final Finder backButton = find.byType(GestureDetector);
    expect(tester.getSize(backButton), const Size(38.4, 38.4));

    final Offset topLeft = tester.getTopLeft(backButton);
    await tester.tapAt(topLeft + const Offset(37, 19.2));
    await tester.pump();

    expect(tapCount, 1);
  });
}
