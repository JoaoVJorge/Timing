import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:help_out/theme/theme.dart";

void main() {
  testWidgets("back button meets the minimum tap target", (tester) async {
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
    expect(
      tester.getSize(backButton),
      const Size(AppSpacing.minTapTarget, AppSpacing.minTapTarget),
    );

    await tester.tapAt(tester.getCenter(backButton));
    await tester.pump();

    expect(tapCount, 1);
  });

  testWidgets("long titles wrap instead of being clipped to one line", (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
        home: Scaffold(
          body: AppTopBar(
            title: "Perguntas frequentes",
            showBackButton: true,
            onBack: () {},
          ),
        ),
      ),
    );

    final Text title = tester.widget<Text>(find.text("Perguntas frequentes"));
    expect(title.maxLines, 2);
  });
}
