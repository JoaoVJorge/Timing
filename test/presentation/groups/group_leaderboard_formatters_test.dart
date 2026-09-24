import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/groups/group_leaderboard_formatters.dart";

Future<String> _format(
  WidgetTester tester,
  int value,
  String Function(BuildContext, int, GroupMetricUnit) formatter,
) async {
  late String result;
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale("pt"),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) {
          result = formatter(context, value, GroupMetricUnit.hours);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return result;
}

void main() {
  testWidgets("a session under a minute shows its seconds", (tester) async {
    expect(await _format(tester, 45, formatGroupScore), "45s");
    expect(await _format(tester, 45, formatMetricValue), "45s");
  });

  testWidgets("a minute or more keeps the minute formats", (tester) async {
    expect(await _format(tester, 60, formatGroupScore), "1 min");
    expect(await _format(tester, 3660, formatGroupScore), "1h 1 min");
    expect(await _format(tester, 5400, formatMetricValue), "90 min");
  });

  testWidgets("zero stays zero minutes", (tester) async {
    expect(await _format(tester, 0, formatGroupScore), "0 min");
  });
}
