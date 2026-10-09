import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:timing/core/data/repositories/phone_auth_repository.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/login/login_controller.dart";
import "package:timing/presentation/login/login_page.dart";
import "package:timing/presentation/login/sign_in_step.dart";
import "package:timing/presentation/login/widgets/sign_in_progress_overlay.dart";
import "package:timing/theme/theme.dart";

import "../../support/pump_in_scroll_view.dart";

class _FakePhoneAuthRepository implements PhoneAuthRepository {
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
        phoneAuthRepository: _FakePhoneAuthRepository(),
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

  testWidgets("covers the login page while the account is being signed in", (
    tester,
  ) async {
    final LoginController controller = Get.put(
      LoginController(
        phoneAuthRepository: _FakePhoneAuthRepository(),
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
    expect(find.byType(SignInProgressOverlay), findsNothing);
    expect(find.text("Continue with Google").hitTestable(), findsOneWidget);

    controller.signInStep.value = SignInStep.loadingProfile;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("Signing you in"), findsOneWidget);
    expect(find.text("Loading your profile..."), findsOneWidget);
    expect(find.text("Continue with Google").hitTestable(), findsNothing);

    controller.signInStep.value = null;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SignInProgressOverlay), findsNothing);
    expect(find.text("Continue with Google").hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets("the sign-in progress lays out for every step", (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    for (final SignInStep step in SignInStep.values) {
      await pumpInScrollView(
        tester,
        TickerMode(enabled: false, child: SignInProgressOverlay(step: step)),
      );
      expect(find.text("Signing you in"), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
