import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/shared/widgets/clear_data_confirmation_dialog.dart";
import "package:timing/theme/theme.dart";

Future<void> _pumpHost(WidgetTester tester) async {
  Get.put<AppNavigator>(AppNavigator());
  await tester.pumpWidget(
    GetMaterialApp(
      locale: const Locale("pt"),
      theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const Scaffold(body: SizedBox()),
    ),
  );
  await tester.pump();
}

const String _groupNote =
    "Como faz parte de um grupo, seu progresso individual também sai do "
    "ranking. Você continua no grupo.";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets("names the activity and warns it cannot be undone", (
    tester,
  ) async {
    await _pumpHost(tester);

    final Future<bool> answer = showClearDataConfirmationDialog(
      itemName: "Cálculo",
      isGoal: false,
      isFromGroup: false,
    );
    await tester.pumpAndSettle();

    expect(find.text("Apagar dados?"), findsOneWidget);
    expect(find.textContaining("\"Cálculo\""), findsOneWidget);
    expect(find.textContaining("tempo, páginas e histórico"), findsOneWidget);
    expect(find.textContaining("não poderá ser desfeita"), findsOneWidget);
    expect(find.textContaining(_groupNote), findsNothing);

    await tester.tap(find.text("Cancelar"));
    await tester.pumpAndSettle();
    expect(await answer, isFalse);
  });

  testWidgets("talks about marked days for a goal", (tester) async {
    await _pumpHost(tester);

    final Future<bool> answer = showClearDataConfirmationDialog(
      itemName: "Beber água",
      isGoal: true,
      isFromGroup: false,
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining("Todos os dias que você marcou"),
      findsOneWidget,
    );
    expect(find.textContaining("tempo, páginas"), findsNothing);

    await tester.tap(find.text("Cancelar"));
    await tester.pumpAndSettle();
    await answer;
  });

  testWidgets("for a group item, says it leaves the ranking too", (
    tester,
  ) async {
    await _pumpHost(tester);

    final Future<bool> answer = showClearDataConfirmationDialog(
      itemName: "Meta do grupo",
      isGoal: true,
      isFromGroup: true,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining(_groupNote), findsOneWidget);

    await tester.tap(find.text("Cancelar"));
    await tester.pumpAndSettle();
    await answer;
  });

  testWidgets("the destructive button answers yes", (tester) async {
    await _pumpHost(tester);

    final Future<bool> answer = showClearDataConfirmationDialog(
      itemName: "Cálculo",
      isGoal: false,
      isFromGroup: false,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text("Apagar dados"));
    await tester.pumpAndSettle();

    expect(await answer, isTrue);
  });
}
