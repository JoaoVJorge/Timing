import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

class LoginController extends GetxController {
  LoginController({required this._appNavigator});

  final AppNavigator _appNavigator;

  Future<void> onTapGoogleSignIn() async => _showSocialAuthPending();

  Future<void> onTapAppleSignIn() async => _showSocialAuthPending();

  void _showSocialAuthPending() {
    final String message = switch (Get.context?.languageCode) {
      "pt" =>
        "Use telefone por enquanto. OAuth sera conectado depois dos redirects.",
      "es" =>
        "Usa telefono por ahora. OAuth se conectara despues de los redirects.",
      _ =>
        "Use phone for now. OAuth will be connected after redirects are set.",
    };
    _appNavigator.showErrorSnackBar(message);
  }

  void onTapEmailSignIn() => _appNavigator.toNamed(AppRoutes.phoneLogin);
}
