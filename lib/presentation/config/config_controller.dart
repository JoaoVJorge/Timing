import "package:get/get.dart";
import "package:flutter/material.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/config/widgets/config_dialogs.dart";
import "package:help_out/shared/functions/format_name.dart";
import "package:help_out/theme/app_languages.dart";

class ConfigController extends GetxController {
  ConfigController({required this._appController, required this._appNavigator});

  final AppController _appController;
  final AppNavigator _appNavigator;

  RxBool get isDarkMode => _appController.isDarkMode;
  RxString get userName => _appController.userName;
  RxString get nickName => _appController.nickName;
  RxInt get avatarIconIndex => _appController.avatarIconIndex;
  Rx<Color> get accentColor => _appController.accentColor;
  RxBool get notificationsEnabled => _appController.notificationsEnabled;
  RxString get languageCode => _appController.languageCode;

  String get displayName {
    final String value = capitalizeName(userName.value);
    return value.isEmpty ? Get.context!.l10n.myProfileFallback : value;
  }

  String get displayNickname {
    final String value = nickName.value.trim().replaceAll(
      RegExp(r"^@+\s*"),
      "",
    );
    return value.isEmpty ? "@${Get.context!.l10n.nicknameFallback}" : "@$value";
  }

  String get darkModeSubtitle => isDarkMode.value
      ? Get.context!.l10n.darkModeEnabledSubtitle
      : Get.context!.l10n.darkModeDisabledSubtitle;

  String get notificationsSubtitle => notificationsEnabled.value
      ? Get.context!.l10n.notificationsEnabledSubtitle
      : Get.context!.l10n.notificationsDisabledSubtitle;

  Future<void> onToggleDarkMode(bool value) async {
    await _appController.setDarkMode(value);
  }

  Future<void> onToggleNotifications(bool value) async {
    await _appController.setNotificationsEnabled(value);
    _appNavigator.showSuccessSnackBar(Get.context!.l10n.preferenceSavedMessage);
  }

  void onTapMyProfile() => _appNavigator.toNamed(AppRoutes.editProfile);

  void onTapFaq() => _appNavigator.toNamed(AppRoutes.faq);

  Future<void> onTapLanguage() async {
    final String? selectedCode = await showLanguagePickerDialog(
      currentCode: languageCode.value,
    );
    if (selectedCode != null) {
      await _appController.setLanguageCode(selectedCode);
      _appNavigator.showSuccessSnackBar(
        Get.context!.l10n.languageChangedMessage(
          AppLanguages.byCode(selectedCode).label,
        ),
      );
    }
  }

  String get languageLabel => AppLanguages.byCode(languageCode.value).label;

  void onTapAccentColor() => _appNavigator.toNamed(AppRoutes.editProfile);

  void onTapFeedback() =>
      _appNavigator.showSnackBar(text: Get.context!.l10n.feedbackUnavailable);

  Future<void> onTapLogOut() async {
    final bool? confirmed = await showLogOutDialog();
    if (confirmed ?? false) {
      await _appController.logOut();
    }
  }
}
