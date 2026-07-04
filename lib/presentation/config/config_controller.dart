import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/presentation/config/widgets/language_picker_dialog.dart";
import "package:help_out/presentation/config/widgets/log_out_dialog.dart";
import "package:help_out/theme/app_languages.dart";

class ConfigController extends GetxController {
  ConfigController({required this._appController, required this._appNavigator});

  final AppController _appController;
  final AppNavigator _appNavigator;

  RxBool get isDarkMode => _appController.isDarkMode;
  RxString get userName => _appController.userName;
  RxString get nickName => _appController.nickName;
  RxInt get avatarIconIndex => _appController.avatarIconIndex;
  RxBool get notificationsEnabled => _appController.notificationsEnabled;
  RxString get languageCode => _appController.languageCode;

  void onToggleDarkMode(bool value) => _appController.setDarkMode(value);

  void onToggleNotifications(bool value) =>
      _appController.setNotificationsEnabled(value);

  void onTapMyProfile() => _appNavigator.toNamed(AppRoutes.editProfile);

  void onTapFaq() => _appNavigator.toNamed(AppRoutes.faq);

  Future<void> onTapLanguage() async {
    final String? selectedCode = await _appNavigator.dialog<String>(
      child: LanguagePickerDialog(currentCode: languageCode.value),
    );
    if (selectedCode != null) {
      await _appController.setLanguageCode(selectedCode);
    }
  }

  String get languageLabel => AppLanguages.byCode(languageCode.value).label;

  Future<void> onTapLogOut() async {
    final bool? confirmed = await _appNavigator.dialog<bool>(
      child: const LogOutDialog(),
    );
    if (confirmed ?? false) {
      await _appController.logOut();
    }
  }
}
