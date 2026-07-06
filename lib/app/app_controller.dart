import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_constants.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/entities/app_config_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/get_app_config_use_case.dart";
import "package:help_out/core/domain/use_cases/save_app_config_use_case.dart";
import "package:help_out/core/domain/use_cases/sync_profile_to_backend_use_case.dart";
import "package:help_out/theme/accent_presets.dart";

class AppController extends GetxController {
  AppController({
    required this._getAppConfigUseCase,
    required this._saveAppConfigUseCase,
    required this._syncProfileToBackendUseCase,
    required this._appNavigator,
  });

  final GetAppConfigUseCase _getAppConfigUseCase;
  final SaveAppConfigUseCase _saveAppConfigUseCase;
  final SyncProfileToBackendUseCase _syncProfileToBackendUseCase;
  final AppNavigator _appNavigator;

  final RxBool isDarkMode = false.obs;
  final Rx<Color> accentColor = AppAccentPresets.defaultAccent.obs;
  final RxString userName = "".obs;
  final RxString nickName = "".obs;
  final Rx<String?> email = Rx<String?>(null);
  final Rx<String?> phoneNumber = Rx<String?>(null);
  final RxInt avatarIconIndex = 0.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxString languageCode = "en".obs;

  Future<void> initialize() async {
    await Future.wait([_loadAppConfig(), Future.delayed(AppConstants.splashScreenDuration)]);
    await _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    if (userName.value.isEmpty) {
      await _appNavigator.offAllNamed(AppRoutes.login);
    } else {
      await _appNavigator.offAllNamed(AppRoutes.mainNavigation);
    }
  }

  Future<void> _loadAppConfig() async {
    final Either<AppError, AppConfigEntity> result = await _getAppConfigUseCase();
    result.fold((error) => null, _applyConfig);
  }

  void _applyConfig(AppConfigEntity config) {
    isDarkMode.value = config.isDarkMode;
    accentColor.value = Color(config.accentColorValue);
    userName.value = config.userName;
    nickName.value = config.nickName;
    email.value = config.email;
    phoneNumber.value = config.phoneNumber;
    avatarIconIndex.value = config.avatarIconIndex;
    notificationsEnabled.value = config.notificationsEnabled;
    languageCode.value = config.languageCode;
    // The saved language only reaches here after GetMaterialApp's first
    // build (see the comment in setLanguageCode), so it must be applied
    // explicitly too, not just left to the `locale:` constructor param.
    Get.updateLocale(Locale(config.languageCode));
  }

  AppConfigEntity get _currentConfig => AppConfigEntity(
    isDarkMode: isDarkMode.value,
    userName: userName.value,
    nickName: nickName.value,
    email: email.value,
    phoneNumber: phoneNumber.value,
    accentColorValue: accentColor.value.toARGB32(),
    avatarIconIndex: avatarIconIndex.value,
    notificationsEnabled: notificationsEnabled.value,
    languageCode: languageCode.value,
  );

  Future<void> setDarkMode(bool value) async {
    isDarkMode.value = value;
    await _saveAppConfigUseCase(_currentConfig);
  }

  Future<void> setAccentColor(Color value) async {
    accentColor.value = value;
    await _saveAppConfigUseCase(_currentConfig);
  }

  Future<void> setUserName(String value) async {
    userName.value = value;
    await _saveAppConfigUseCase(_currentConfig);
  }

  Future<void> setAvatarIconIndex(int value) async {
    avatarIconIndex.value = value;
    await _saveAppConfigUseCase(_currentConfig);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled.value = value;
    await _saveAppConfigUseCase(_currentConfig);
  }

  Future<void> setLanguageCode(String value) async {
    languageCode.value = value;
    // GetMaterialApp only reads its `locale:` constructor param once, on the
    // very first build (see GetBuilder<GetMaterialController>'s initState in
    // the get package) — later rebuilds with a new `locale:` value are
    // ignored. Get.updateLocale is GetX's own API for propagating a runtime
    // locale change and forcing the app to rebuild with it.
    await Get.updateLocale(Locale(value));
    await _saveAppConfigUseCase(_currentConfig);
  }

  Future<Either<AppError, void>> updateProfile({
    required String userName,
    required String nickName,
    String? email,
    String? phoneNumber,
  }) async {
    this.userName.value = userName;
    this.nickName.value = nickName;
    this.email.value = email;
    this.phoneNumber.value = phoneNumber;

    await _saveAppConfigUseCase(_currentConfig);
    return _syncProfileToBackendUseCase(_currentConfig);
  }

  Future<void> logOut() async {
    userName.value = "";
    nickName.value = "";
    email.value = null;
    phoneNumber.value = null;
    avatarIconIndex.value = 0;
    await _saveAppConfigUseCase(_currentConfig);
    await _appNavigator.offAllNamed(AppRoutes.login);
  }
}
