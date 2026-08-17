import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/use_cases/sign_in_with_google_use_case.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/login/login_controller.dart";
import "package:timing/presentation/login/login_page.dart";
import "package:timing/theme/theme.dart";

class _FakeSignInWithGoogleUseCase implements SignInWithGoogleUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAppController implements AppController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAppNavigator implements AppNavigator {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSupabaseService implements SupabaseService {
  @override
  SupabaseClient? get client => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAppLoggerService implements AppLoggerService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets("keeps the login illustration large on a short screen", (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    Get.put(
      LoginController(
        signInWithGoogleUseCase: _FakeSignInWithGoogleUseCase(),
        appController: _FakeAppController(),
        appNavigator: _FakeAppNavigator(),
        supabaseService: _FakeSupabaseService(),
        logger: _FakeAppLoggerService(),
      ),
    );

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const LoginPage(),
      ),
    );
    await tester.pumpAndSettle();

    final Finder illustration = find.byType(Image);
    expect(illustration, findsOneWidget);
    expect(tester.getSize(illustration).width, greaterThan(220));
    expect(find.text("Continue with Apple"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
