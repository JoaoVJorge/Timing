import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";

class ConfigController extends GetxController {
  ConfigController({required this._appController, required this._appNavigator});

  final AppController _appController;
  final AppNavigator _appNavigator;

  RxBool get isDarkMode => _appController.isDarkMode;
  RxString get userName => _appController.userName;
  RxString get nickName => _appController.nickName;
  RxInt get avatarIconIndex => _appController.avatarIconIndex;

  void onToggleDarkMode(bool value) => _appController.setDarkMode(value);

  void onTapMyProfile() => _appNavigator.toNamed(AppRoutes.editProfile);

  void onTapFaq() => _appNavigator.toNamed(AppRoutes.faq);
}
