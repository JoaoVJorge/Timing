import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/core/domain/use_cases/sign_in_with_google_use_case.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/presentation/login/login_controller.dart";

class _Stub extends Fake {}

class _AuthClient extends _Stub implements GoTrueClient {
  @override
  Stream<AuthState> get onAuthStateChange => const Stream.empty();
}

class _Client extends _Stub implements SupabaseClient {
  @override
  final GoTrueClient auth = _AuthClient();
}

class _SignedInService extends _Stub implements SupabaseService {
  @override
  final SupabaseClient client = _Client();

  @override
  bool get hasSignedInUser => true;
}

class _SignedOutService extends _Stub implements SupabaseService {
  _SignedOutService(this.client);

  @override
  final SupabaseClient client;

  @override
  bool get hasSignedInUser => false;
}

class _AppController extends _Stub implements AppController {
  int reloads = 0;
  int verifiedContacts = 0;

  @override
  Future<bool> refreshProfileFromBackend() async => true;

  @override
  Future<void> reloadUserScopedState() async {
    reloads++;
  }

  @override
  Future<void> recordSuccessfulBackendContact() async {
    verifiedContacts++;
  }
}

class _Navigator extends _Stub implements AppNavigator {
  final Completer<void> routeClosed = Completer<void>();
  final List<String> routes = [];
  int errors = 0;

  @override
  Future<T?>? offAllNamed<T>(
    String newRouteName, {
    Object? arguments,
    int? id,
  }) {
    routes.add(newRouteName);
    return routeClosed.future.then<T?>((_) => null);
  }

  @override
  void showErrorSnackBar([String? text]) {
    errors++;
  }
}

class _SignIn extends _Stub implements SignInWithGoogleUseCase {}

void main() {
  testWidgets("successful login does not time out while Home remains open", (
    tester,
  ) async {
    Get.testMode = true;
    final service = _SignedInService();
    final app = _AppController();
    final navigator = _Navigator();
    final controller = LoginController(
      signInWithGoogleUseCase: _SignIn(),
      appController: app,
      appNavigator: navigator,
      supabaseService: service,
      logger: AppLoggerService(),
    );
    controller.onInit();
    await tester.pump();

    expect(navigator.routes, [AppRoutes.mainNavigation]);
    expect(app.reloads, 1);
    expect(app.verifiedContacts, 1);
    expect(navigator.routeClosed.isCompleted, isFalse);

    await tester.pump(const Duration(seconds: 16));
    expect(navigator.errors, 0);

    controller.onClose();
    navigator.routeClosed.complete();
    Get.reset();
  });

  testWidgets("a failed OAuth callback is reported once, not again when the "
      "login page reopens", (tester) async {
    Get.testMode = true;
    // The real auth client: its state stream replays the latest error to
    // every new listener.
    final client = SupabaseClient(
      "https://proj.supabase.co",
      "anon",
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    final navigator = _Navigator();
    LoginController openLoginPage() => LoginController(
      signInWithGoogleUseCase: _SignIn(),
      appController: _AppController(),
      appNavigator: navigator,
      supabaseService: _SignedOutService(client),
      logger: AppLoggerService(),
    )..onInit();

    final LoginController first = openLoginPage();
    // What supabase_flutter does when the deep link's code exchange fails.
    // ignore: invalid_use_of_internal_member
    client.auth.notifyException(const AuthException("Failed host lookup"));
    await tester.pump();
    expect(navigator.errors, 1);

    first.onClose();
    final LoginController second = openLoginPage();
    await tester.pump();
    expect(navigator.errors, 1);

    // ignore: invalid_use_of_internal_member
    client.auth.notifyException(const AuthException("access_denied"));
    await tester.pump();
    expect(navigator.errors, 2);

    second.onClose();
    unawaited(client.dispose());
    Get.reset();
  });
}
