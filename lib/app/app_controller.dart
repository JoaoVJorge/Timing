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
import "package:help_out/theme/accent_presets.dart";

class AppController extends GetxController {
  AppController({
    required this._getAppConfigUseCase,
    required this._saveAppConfigUseCase,
    required this._appNavigator,
  });

  final GetAppConfigUseCase _getAppConfigUseCase;
  final SaveAppConfigUseCase _saveAppConfigUseCase;
  final AppNavigator _appNavigator;

  final RxBool isDarkMode = false.obs;
  final Rx<Color> accentColor = AppAccentPresets.defaultAccent.obs;
  final RxString userName = "".obs;

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
  }

  AppConfigEntity get _currentConfig =>
      AppConfigEntity(isDarkMode: isDarkMode.value, userName: userName.value, accentColorValue: accentColor.value.toARGB32());

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
}
