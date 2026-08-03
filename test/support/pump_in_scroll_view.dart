import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:help_out/l10n/app_localizations.dart";
import "package:help_out/theme/theme.dart";

/// Renders [child] in the same unbounded-height context the pages use:
/// a scroll view wrapping a Column. Widgets that force infinite constraints
/// (for example `CrossAxisAlignment.stretch` on a Row) fail here, while
/// `flutter analyze` and non-widget tests stay green.
Future<void> pumpInScrollView(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppThemes.build(seed: Colors.blue, brightness: brightness),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [child],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
