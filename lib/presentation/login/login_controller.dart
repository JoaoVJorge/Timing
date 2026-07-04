import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";

class LoginController extends GetxController {
  LoginController({required this._appController, required this._appNavigator});

  final AppController _appController;
  final AppNavigator _appNavigator;

  Future<void> onTapGoogleSignIn() => _mockSocialSignIn("Google User");

  Future<void> onTapAppleSignIn() => _mockSocialSignIn("Apple User");

  Future<void> _mockSocialSignIn(String mockName) async {
    await _appController.setUserName(mockName);
    await _appNavigator.offAllNamed(AppRoutes.mainNavigation);
  }

  void onTapCreateAccount() => _appNavigator.toNamed(AppRoutes.createAccount);
}
