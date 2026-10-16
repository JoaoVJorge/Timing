import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/subject_stats/widgets/time_adjustment_dialog.dart";
import "package:timing/theme/theme.dart";

void main() {
  int? result;
  int calls = 0;
  setUp(() {
    result = null;
    calls = 0;
  });

  final confirm = find.byKey(const ValueKey("time-adjustment-confirm"));

  /// Pushes the dialog as a route so what it answers on confirmation is
  /// captured, the way the page awaits it.
  Future<void> show(
    WidgetTester tester, {
    int max = 86400,
    bool removing = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
        locale: const Locale("pt"),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final answer = await Navigator.of(context).push<int>(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    body: TimeAdjustmentDialog(
                      isRemoving: removing,
                      maxSeconds: max,
                    ),
                  ),
                ),
              );
              result = answer;
              calls++;
            },
            child: const Text("open"),
          ),
        ),
      ),
    );
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();
  }

  testWidgets("accepts a typed duration and adjusts by one minute", (
    tester,
  ) async {
    await show(tester);
    await tester.enterText(find.byType(TextField), "83");
    await tester.pump();
    expect(find.text("Adicionar 1h 23 min"), findsOneWidget);
    await tester.tap(find.byTooltip("+1 min"));
    await tester.pump();
    expect(find.text("Adicionar 1h 24 min"), findsOneWidget);
    await tester.tap(find.byTooltip("−1 min"));
    await tester.pump();
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(result, 83 * 60);
  });

  testWidgets("empty, zero and over-limit amounts cannot be confirmed", (
    tester,
  ) async {
    await show(tester, max: 3600);
    for (final value in ["", "0", "61"]) {
      await tester.enterText(find.byType(TextField), value);
      await tester.pump();
      final button = tester.widget<FilledButton>(confirm);
      expect(button.onPressed, isNull);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(calls, 0);
    }
  });

  testWidgets("removal preview and result include the remaining seconds", (
    tester,
  ) async {
    await show(tester, max: 90, removing: true);
    expect(find.text("Remover 1 min 30s"), findsOneWidget);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(result, 90);
  });

  testWidgets("can remove an activity with less than a minute", (tester) async {
    await show(tester, max: 25, removing: true);
    expect(find.text("Remover 25s"), findsOneWidget);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(result, 25);
  });

  testWidgets("remains usable on a small screen with keyboard open", (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await show(tester);
    await tester.enterText(find.byType(TextField), "12");
    await tester.ensureVisible(confirm);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(result, 720);
  });
}
