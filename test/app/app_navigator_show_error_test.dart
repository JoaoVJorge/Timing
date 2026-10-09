import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/connectivity/connectivity_service.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/theme/theme.dart";

class _Connectivity implements ConnectivityService {
  _Connectivity({required bool online}) : isOnline = online.obs;

  @override
  final RxBool isOnline;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final AppLocalizations pt = lookupAppLocalizations(const Locale("pt"));

  tearDown(Get.reset);

  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
    GetMaterialApp(
      theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
      locale: const Locale("pt"),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const Scaffold(),
    ),
  );

  Future<void> showAndSettle(WidgetTester tester, AppError error) async {
    AppNavigator().showError(error);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> dismiss(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets("explains the failure in the user's language, without the "
      "diagnostics", (tester) async {
    await pumpApp(tester);

    await showAndSettle(
      tester,
      const RejectedError(code: "23505", cause: "duplicate key value"),
    );

    expect(find.text(pt.errorRejectedMessage), findsOneWidget);
    expect(find.textContaining("duplicate"), findsNothing);
    expect(find.textContaining("23505"), findsNothing);
    await dismiss(tester);
  });

  testWidgets("a missing session asks the user to sign in again", (
    tester,
  ) async {
    await pumpApp(tester);

    await showAndSettle(tester, const SignedOutError());

    expect(find.text(pt.errorSignedOutMessage), findsOneWidget);
    await dismiss(tester);
  });

  testWidgets("while the app is offline any failure is a connection problem", (
    tester,
  ) async {
    Get.put<ConnectivityService>(_Connectivity(online: false));
    await pumpApp(tester);

    await showAndSettle(tester, const UnexpectedError(cause: "no row"));

    expect(find.text(pt.errorOfflineMessage), findsOneWidget);
    expect(find.text(pt.genericErrorMessage), findsNothing);
    await dismiss(tester);
  });
}
