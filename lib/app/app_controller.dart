import "dart:convert";
import "dart:typed_data";

import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_constants.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/entities/app_config_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/get_app_config_use_case.dart";
import "package:help_out/core/domain/use_cases/get_current_profile_use_case.dart";
import "package:help_out/core/domain/use_cases/save_app_config_use_case.dart";
import "package:help_out/core/domain/use_cases/sign_out_use_case.dart";
import "package:help_out/core/domain/use_cases/sync_profile_to_backend_use_case.dart";
import "package:help_out/core/services/daily_progress/daily_progress_service.dart";
import "package:help_out/core/services/last_activity/last_activity_service.dart";
import "package:help_out/core/services/supabase/supabase_service.dart";
import "package:help_out/l10n/app_localizations.dart";
import "package:help_out/presentation/groups/groups_controller.dart";
import "package:help_out/presentation/schedule/schedule_controller.dart";
import "package:help_out/theme/accent_presets.dart";

class AppController extends GetxController {
  AppController({
    required this._getAppConfigUseCase,
    required this._getCurrentProfileUseCase,
    required this._saveAppConfigUseCase,
    required this._syncProfileToBackendUseCase,
    required this._signOutUseCase,
    required this._appNavigator,
    required this._supabaseService,
  });

  final GetAppConfigUseCase _getAppConfigUseCase;
  final GetCurrentProfileUseCase _getCurrentProfileUseCase;
  final SaveAppConfigUseCase _saveAppConfigUseCase;
  final SyncProfileToBackendUseCase _syncProfileToBackendUseCase;
  final SignOutUseCase _signOutUseCase;
  final AppNavigator _appNavigator;
  final SupabaseService _supabaseService;

  final RxBool isDarkMode = false.obs;
  final Rx<Color> accentColor = AppAccentPresets.defaultAccent.obs;
  final RxString userName = "".obs;
  final RxString nickName = "".obs;
  final Rx<String?> email = Rx<String?>(null);
  final Rx<String?> phoneNumber = Rx<String?>(null);
  final Rx<String?> birthDate = Rx<String?>(null);
  final Rx<String?> profilePhotoBase64 = Rx<String?>(null);
  final RxInt avatarIconIndex = 0.obs;
  final RxBool notificationsEnabled = true.obs;
  final Rx<String?> languageCode = Rx<String?>(null);
  final RxString friendCode = "".obs;
  final RxBool focusLockStudyingEnabled = false.obs;
  final RxBool focusLockExercisesEnabled = false.obs;
  final RxBool focusLockReadingEnabled = false.obs;
  final RxBool focusLockHobbiesEnabled = false.obs;

  String? _decodedPhotoSource;
  Uint8List? _decodedPhotoBytes;

  /// Decoded once per photo change and reused afterwards: `Image.memory` keys
  /// its cache by byte-list identity, so handing it a fresh list on every
  /// rebuild would re-decode the whole image each frame.
  Uint8List? get profilePhotoBytes {
    final String? source = profilePhotoBase64.value;
    if (source == null) {
      _decodedPhotoSource = null;
      _decodedPhotoBytes = null;
      return null;
    }
    if (_decodedPhotoSource != source) {
      _decodedPhotoSource = source;
      _decodedPhotoBytes = base64Decode(source);
    }
    return _decodedPhotoBytes;
  }

  Locale get selectedLocale => _resolvedLocale(languageCode.value);

  String get effectiveLanguageCode => selectedLocale.languageCode;

  Future<void> initialize() async {
    await Future.wait([
      _loadInitialConfig(),
      Future.delayed(AppConstants.splashScreenDuration),
    ]);
    await _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    if (_supabaseService.isConfigured && !_supabaseService.hasSignedInUser) {
      await _appNavigator.offAllNamed(AppRoutes.login);
      return;
    }

    if (userName.value.isEmpty) {
      await _appNavigator.offAllNamed(AppRoutes.login);
      return;
    }

    await _appNavigator.offAllNamed(AppRoutes.mainNavigation);
  }

  Future<void> _loadInitialConfig() async {
    await _loadAppConfig();
    await refreshProfileFromBackend();
  }

  Future<void> _loadAppConfig() async {
    final Either<AppError, AppConfigEntity> result =
        await _getAppConfigUseCase();
    result.fold((error) => null, _applyConfig);
  }

  void _applyConfig(AppConfigEntity config) {
    isDarkMode.value = config.isDarkMode;
    accentColor.value = Color(config.accentColorValue);
    userName.value = config.userName;
    nickName.value = config.nickName;
    email.value = config.email;
    phoneNumber.value = config.phoneNumber;
    birthDate.value = config.birthDate;
    profilePhotoBase64.value = config.profilePhotoBase64;
    avatarIconIndex.value = config.avatarIconIndex;
    notificationsEnabled.value = config.notificationsEnabled;
    languageCode.value = config.languageCode;
    friendCode.value = config.friendCode;
    focusLockStudyingEnabled.value = config.focusLockStudyingEnabled;
    focusLockExercisesEnabled.value = config.focusLockExercisesEnabled;
    focusLockReadingEnabled.value = config.focusLockReadingEnabled;
    focusLockHobbiesEnabled.value = config.focusLockHobbiesEnabled;
    // The saved language only reaches here after GetMaterialApp's first
    // build (see the comment in setLanguageCode), so it must be applied
    // explicitly too, not just left to the `locale:` constructor param.
    Get.updateLocale(_resolvedLocale(config.languageCode));
  }

  Future<bool> refreshProfileFromBackend() async {
    if (!_supabaseService.hasSignedInUser) {
      return false;
    }

    final Either<AppError, AppConfigEntity?> result =
        await _getCurrentProfileUseCase();
    return await result.fold((error) async => false, (config) async {
      if (config == null) {
        return false;
      }
      final AppConfigEntity mergedConfig = _withLocalConcentrationSettings(
        config,
      );
      _applyConfig(mergedConfig);
      await _saveAppConfigUseCase(_currentConfig);
      return config.userName.isNotEmpty;
    });
  }

  AppConfigEntity _withLocalConcentrationSettings(AppConfigEntity config) =>
      config.copyWith(
        focusLockStudyingEnabled: focusLockStudyingEnabled.value,
        focusLockExercisesEnabled: focusLockExercisesEnabled.value,
        focusLockReadingEnabled: focusLockReadingEnabled.value,
        focusLockHobbiesEnabled: focusLockHobbiesEnabled.value,
      );

  AppConfigEntity get _currentConfig => AppConfigEntity(
    isDarkMode: isDarkMode.value,
    userName: userName.value,
    nickName: nickName.value,
    email: email.value,
    phoneNumber: phoneNumber.value,
    birthDate: birthDate.value,
    profilePhotoBase64: profilePhotoBase64.value,
    accentColorValue: accentColor.value.toARGB32(),
    avatarIconIndex: avatarIconIndex.value,
    notificationsEnabled: notificationsEnabled.value,
    languageCode: languageCode.value,
    friendCode: friendCode.value,
    focusLockStudyingEnabled: focusLockStudyingEnabled.value,
    focusLockExercisesEnabled: focusLockExercisesEnabled.value,
    focusLockReadingEnabled: focusLockReadingEnabled.value,
    focusLockHobbiesEnabled: focusLockHobbiesEnabled.value,
  );

  Future<void> reloadUserScopedState() async {
    final List<Future<void>> reloads = [
      Get.find<LastActivityService>().load(),
      Get.find<DailyProgressService>().load(),
      Get.find<ScheduleController>().loadEntries(),
    ];

    if (Get.isRegistered<GroupsController>()) {
      reloads.add(Get.find<GroupsController>().loadGroups());
    }

    await Future.wait(reloads);
  }

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

  Future<void> setProfilePhotoBase64(String? value) async {
    profilePhotoBase64.value = value;
    await _saveAppConfigUseCase(_currentConfig);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled.value = value;
    await _saveAppConfigUseCase(_currentConfig);
  }

  Future<void> setLanguageCode(String? value) async {
    languageCode.value = value;
    // GetMaterialApp only reads its `locale:` constructor param once, on the
    // very first build (see GetBuilder<GetMaterialController>'s initState in
    // the get package) — later rebuilds with a new `locale:` value are
    // ignored. Get.updateLocale is GetX's own API for propagating a runtime
    // locale change and forcing the app to rebuild with it.
    await Get.updateLocale(_resolvedLocale(value));
    await _saveAppConfigUseCase(_currentConfig);
  }

  bool isFocusLockEnabledFor(TimeCategoryType category) => switch (category) {
    TimeCategoryType.studying => focusLockStudyingEnabled.value,
    TimeCategoryType.exercises => focusLockExercisesEnabled.value,
    TimeCategoryType.reading => focusLockReadingEnabled.value,
    TimeCategoryType.hobbies => focusLockHobbiesEnabled.value,
  };

  Future<void> setFocusLockEnabledFor(
    TimeCategoryType category,
    bool value,
  ) async {
    switch (category) {
      case TimeCategoryType.studying:
        focusLockStudyingEnabled.value = value;
      case TimeCategoryType.exercises:
        focusLockExercisesEnabled.value = value;
      case TimeCategoryType.reading:
        focusLockReadingEnabled.value = value;
      case TimeCategoryType.hobbies:
        focusLockHobbiesEnabled.value = value;
    }
    await _saveAppConfigUseCase(_currentConfig);
  }

  Locale _resolvedLocale(String? code) {
    if (code != null) {
      return Locale(code);
    }

    final Locale? deviceLocale = Get.deviceLocale;
    if (deviceLocale != null) {
      final String deviceLanguageCode = deviceLocale.languageCode;
      if (deviceLanguageCode == "pt" || deviceLocale.countryCode == "BR") {
        return const Locale("pt");
      }
      if (AppLocalizations.supportedLocales.any(
        (locale) => locale.languageCode == deviceLanguageCode,
      )) {
        return Locale(deviceLanguageCode);
      }
    }

    return const Locale("en");
  }

  Future<Either<AppError, void>> updateProfile({
    required String userName,
    required String nickName,
    String? email,
    String? phoneNumber,
    String? birthDate,
    String? profilePhotoBase64,
  }) async {
    this.userName.value = userName;
    this.nickName.value = nickName;
    this.email.value = email;
    this.phoneNumber.value = phoneNumber;
    this.birthDate.value = birthDate;
    this.profilePhotoBase64.value =
        profilePhotoBase64 ?? this.profilePhotoBase64.value;

    await _saveAppConfigUseCase(_currentConfig);
    return _syncProfileToBackendUseCase(_currentConfig);
  }

  Future<void> logOut() async {
    await _signOutUseCase();
    userName.value = "";
    nickName.value = "";
    email.value = null;
    phoneNumber.value = null;
    birthDate.value = null;
    profilePhotoBase64.value = null;
    avatarIconIndex.value = 0;
    friendCode.value = "";
    focusLockStudyingEnabled.value = false;
    focusLockExercisesEnabled.value = false;
    focusLockReadingEnabled.value = false;
    focusLockHobbiesEnabled.value = false;
    await reloadUserScopedState();
    await _appNavigator.offAllNamed(AppRoutes.login);
  }
}
