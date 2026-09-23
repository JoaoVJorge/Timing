import "dart:typed_data";

import "package:get/get.dart";
import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";
import "package:timing/app/app_constants.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/config/widgets/config_dialogs.dart";
import "package:timing/shared/functions/format_name.dart";
import "package:timing/shared/widgets/app_confirmation_dialog.dart";
import "package:timing/theme/app_languages.dart";

class ConfigController extends GetxController {
  ConfigController({required this._appController, required this._appNavigator});

  final AppController _appController;
  final AppNavigator _appNavigator;

  RxBool get isDarkMode => _appController.isDarkMode;
  RxString get userName => _appController.userName;
  RxString get nickName => _appController.nickName;
  RxInt get avatarIconIndex => _appController.avatarIconIndex;
  Rx<String?> get profilePhotoBase64 => _appController.profilePhotoBase64;

  Uint8List? get profilePhotoBytes => _appController.profilePhotoBytes;
  Rx<Color> get accentColor => _appController.accentColor;
  RxBool get notificationsEnabled => _appController.notificationsEnabled;
  Rx<String?> get languageCode => _appController.languageCode;
  RxBool get focusLockStudyingEnabled =>
      _appController.focusLockStudyingEnabled;
  RxBool get focusLockExercisesEnabled =>
      _appController.focusLockExercisesEnabled;
  RxBool get focusLockReadingEnabled => _appController.focusLockReadingEnabled;
  RxBool get focusLockHobbiesEnabled => _appController.focusLockHobbiesEnabled;

  @override
  void onInit() {
    super.onInit();
    syncNotificationsFromSystem();
  }

  /// Reconciles the stored notifications preference with the OS permission.
  /// Called on first build and every time the Config tab is reopened, since
  /// the user may have changed the permission in the system settings.
  void syncNotificationsFromSystem() {
    _appController.refreshNotificationsEnabledFromSystem();
  }

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

  Future<void> onToggleDarkMode(bool value) async {
    await _appController.setDarkMode(value);
  }

  Future<void> onToggleNotifications(bool value) async {
    await _appController.setNotificationsEnabled(value);
    if (notificationsEnabled.value == value) {
      _appNavigator.showSuccessSnackBar(
        Get.context!.l10n.preferenceSavedMessage,
      );
      return;
    }
    _appNavigator.showErrorSnackBar();
  }

  Future<void> onSaveFocusLockPreferences({
    required bool studying,
    required bool exercises,
    required bool reading,
    required bool hobbies,
  }) async {
    final bool hasChanges =
        studying != focusLockStudyingEnabled.value ||
        exercises != focusLockExercisesEnabled.value ||
        reading != focusLockReadingEnabled.value ||
        hobbies != focusLockHobbiesEnabled.value;
    if (!hasChanges) {
      return;
    }

    await _appController.setFocusLockPreferences(
      studying: studying,
      exercises: exercises,
      reading: reading,
      hobbies: hobbies,
    );
    _appNavigator.showSuccessSnackBar(Get.context!.l10n.preferenceSavedMessage);
  }

  void onTapMyProfile() => _appNavigator.toNamed(AppRoutes.editProfile);

  void onTapFaq() => _appNavigator.toNamed(AppRoutes.faq);

  Future<void> onTapLanguage() async {
    final String? selectedCode = await showLanguagePickerDialog(
      currentCode: languageCode.value ?? _appController.effectiveLanguageCode,
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

  String get languageLabel => AppLanguages.byCode(
    languageCode.value ?? _appController.effectiveLanguageCode,
  ).label;

  void onTapFeedback() =>
      _appNavigator.showSnackBar(text: Get.context!.l10n.feedbackUnavailable);

  Future<void> onTapLogOut() async {
    final bool? confirmed = await showLogOutDialog();
    if (confirmed ?? false) {
      await _appController.logOut();
    }
  }

  Future<void> onTapDeleteAccount() async {
    final context = Get.context!;
    final bool confirmed = await showAppConfirmationDialog(
      title: context.l10n.deleteAccountDialogTitle,
      message: context.l10n.deleteAccountDialogMessage,
      cancelLabel: context.l10n.cancelButton,
      confirmLabel: context.l10n.deleteAccountRequestButton,
      icon: Icons.person_remove_rounded,
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      final bool opened = await launchUrl(
        Uri.parse(AppConstants.accountDeletionUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) _appNavigator.showErrorSnackBar();
    } on Exception {
      _appNavigator.showErrorSnackBar();
    }
  }
}
