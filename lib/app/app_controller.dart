import "dart:async";
import "dart:convert";
import "dart:typed_data";

import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/app/app_constants.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/route_arguments.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/core/domain/entities/app_config_entity.dart";
import "package:timing/core/domain/entities/activity_entry_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/get_activity_entries_use_case.dart";
import "package:timing/core/domain/use_cases/get_app_config_use_case.dart";
import "package:timing/core/domain/use_cases/get_current_profile_use_case.dart";
import "package:timing/core/domain/use_cases/save_app_config_use_case.dart";
import "package:timing/core/domain/use_cases/sign_out_use_case.dart";
import "package:timing/core/domain/use_cases/sync_profile_to_backend_use_case.dart";
import "package:timing/core/services/activity_history/activity_history_service.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/services/auth/offline_grace_period.dart";
import "package:timing/core/services/connectivity/connectivity_service.dart";
import "package:timing/core/services/daily_progress/daily_progress_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/last_activity/last_activity_service.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/notifications/timer_notification_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";
import "package:timing/core/services/sync/sync_reconciliation_service.dart";
import "package:timing/core/services/timer/active_timer_session_service.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/groups/groups_controller.dart";
import "package:timing/presentation/home/home_controller.dart";
import "package:timing/presentation/progress/progress_controller.dart";
import "package:timing/presentation/schedule/schedule_controller.dart";
import "package:timing/theme/accent_presets.dart";

class AppController extends GetxController with WidgetsBindingObserver {
  AppController({
    required this._getAppConfigUseCase,
    required this._getActivityEntriesUseCase,
    required this._getCurrentProfileUseCase,
    required this._saveAppConfigUseCase,
    required this._syncProfileToBackendUseCase,
    required this._signOutUseCase,
    required this._appNavigator,
    required this._supabaseService,
    required this._timerNotificationService,
    required this._activeTimerSessionService,
    required this._syncReconciliationService,
    required this.localStorageService,
    int? initialAccentColorValue,
  }) : accentColor = Color(
         initialAccentColorValue ?? AppAccentPresets.defaultAccentValue,
       ).obs;

  final GetAppConfigUseCase _getAppConfigUseCase;
  final GetActivityEntriesUseCase _getActivityEntriesUseCase;
  final GetCurrentProfileUseCase _getCurrentProfileUseCase;
  final SaveAppConfigUseCase _saveAppConfigUseCase;
  final SyncProfileToBackendUseCase _syncProfileToBackendUseCase;
  final SignOutUseCase _signOutUseCase;
  final AppNavigator _appNavigator;
  final SupabaseService _supabaseService;
  final TimerNotificationService _timerNotificationService;
  final ActiveTimerSessionService _activeTimerSessionService;
  final SyncReconciliationService _syncReconciliationService;
  final AppLocalStorageService localStorageService;

  final RxBool isDarkMode = false.obs;
  final Rx<Color> accentColor;
  final RxString userName = "".obs;
  final RxString nickName = "".obs;
  final Rx<String?> email = Rx<String?>(null);
  final Rx<String?> phoneNumber = Rx<String?>(null);
  final Rx<String?> birthDate = Rx<String?>(null);
  final Rx<String?> profilePhotoBase64 = Rx<String?>(null);
  final RxInt avatarIconIndex = 0.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool isAppInForeground = true.obs;
  final Rx<String?> languageCode = Rx<String?>(null);
  final RxString friendCode = "".obs;
  final RxBool focusLockStudyingEnabled = false.obs;
  final RxBool focusLockExercisesEnabled = false.obs;
  final RxBool focusLockReadingEnabled = false.obs;
  final RxBool focusLockHobbiesEnabled = false.obs;

  String? _decodedPhotoSource;
  Uint8List? _decodedPhotoBytes;
  Timer? _presenceHeartbeat;
  Future<void> _presenceWriteQueue = Future<void>.value();
  final OfflineGracePeriod _offlineGracePeriod = const OfflineGracePeriod();
  StreamSubscription<String>? _pendingSyncSubscription;
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _pendingSyncRetryTimer;
  Future<void>? _reconciliationInProgress;
  Future<bool>? _activityBackfillInProgress;
  bool _hadQueuedOfflineChanges = false;

  static const Duration _presenceHeartbeatInterval = Duration(seconds: 45);
  static const Duration _presenceRequestTimeout = Duration(seconds: 2);
  static const Duration _presenceLogoutWait = Duration(milliseconds: 1500);
  static const Duration _initialConfigLoadTimeout = Duration(seconds: 10);

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

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    if (_supabaseService.hasSignedInUser) {
      _startPresenceTracking();
    }
    _hadQueuedOfflineChanges = Get.find<PendingSyncStore>().all.isNotEmpty;
    _pendingSyncSubscription = Get.find<PendingSyncStore>().onMarkedPending
        .listen((_) {
          if (!Get.find<ConnectivityService>().isOnline.value) {
            _hadQueuedOfflineChanges = true;
            _appNavigator.showOfflineSnackBar();
          }
        });
    _connectivitySubscription = Get.find<ConnectivityService>().isOnline.listen(
      (online) {
        if (online && _supabaseService.hasSignedInUser) {
          unawaited(_flushPendingAndNotify());
          unawaited(_restoreActivityHistoryFromBackendIfNeeded());
        }
      },
    );
    _pendingSyncRetryTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_supabaseService.hasSignedInUser &&
          Get.find<ConnectivityService>().isOnline.value &&
          Get.find<PendingSyncStore>().all.isNotEmpty) {
        unawaited(_flushPendingAndNotify());
      }
    });
  }

  Future<void> _flushPendingAndNotify() {
    final Future<void>? current = _reconciliationInProgress;
    if (current != null) return current;
    final Future<void> work = _runReconciliation();
    _reconciliationInProgress = work;
    return work.whenComplete(() => _reconciliationInProgress = null);
  }

  Future<void> _runReconciliation() async {
    if (!Get.find<ConnectivityService>().isOnline.value) return;
    final bool hadPending = Get.find<PendingSyncStore>().all.isNotEmpty;
    await _syncReconciliationService.flushPending();
    if (!Get.find<ConnectivityService>().isOnline.value) return;
    if (hadPending && Get.isRegistered<GroupsController>()) {
      await Get.find<GroupsController>().loadGroups();
    }
    if (_hadQueuedOfflineChanges && Get.find<PendingSyncStore>().all.isEmpty) {
      _hadQueuedOfflineChanges = false;
      final BuildContext? context = Get.context;
      if (context != null && context.mounted) {
        _appNavigator.showSuccessSnackBar(
          context.l10n.offlineSyncCompletedMessage,
        );
      }
    }
  }

  Future<void> initialize() async {
    // Bounded so a stalled network call (e.g. racing the OAuth deep-link
    // session exchange right after a cold start) can never leave the splash
    // screen stuck forever. The underlying calls keep running in the
    // background and still apply their results whenever they resolve.
    await Future.wait([
      _loadInitialConfig().timeout(_initialConfigLoadTimeout, onTimeout: () {}),
      Future.delayed(AppConstants.splashScreenDuration),
    ]);
    await _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    if (_supabaseService.isConfigured && !_supabaseService.hasSignedInUser) {
      await _appNavigator.offAllNamed(AppRoutes.login);
      return;
    }

    if (_supabaseService.hasSignedInUser && await _hasGracePeriodExpired()) {
      await _forceReauthentication();
      return;
    }

    if (userName.value.isEmpty) {
      await _appNavigator.offAllNamed(AppRoutes.login);
      return;
    }

    final activeSession = await _activeTimerSessionService.restore();
    unawaited(
      _appNavigator.offAllNamed<void>(AppRoutes.mainNavigation) ??
          Future<void>.value(),
    );
    if (activeSession == null) {
      return;
    }

    // Navigation futures complete when the pushed route is later removed, not
    // when its first frame is shown. Push the recovered timer after Home has
    // been installed instead of awaiting mainNavigation forever.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute != AppRoutes.mainNavigation) {
        return;
      }
      unawaited(
        _appNavigator.toNamed<void>(
              AppRoutes.timer,
              arguments: TimerRouteArguments(
                subject: activeSession.subject,
                restoredSession: activeSession,
              ),
            ) ??
            Future<void>.value(),
      );
    });
  }

  Future<void> _loadInitialConfig() async {
    await _loadAppConfig();
    await Future.wait([
      refreshProfileFromBackend(),
      _restoreActivityHistoryFromBackendIfNeeded(),
    ]);
    // The saved preference is enough to paint the first frame. Reconciling it
    // with the OS notification permission can complete after navigation.
    unawaited(refreshNotificationsEnabledFromSystem());
    if (_supabaseService.hasSignedInUser) {
      unawaited(_flushPendingAndNotify());
    }
  }

  Future<void> _loadAppConfig() async {
    final Either<AppError, AppConfigEntity> result =
        await _getAppConfigUseCase();
    result.fold((error) => null, _applyConfig);
  }

  /// Marks "the app just talked to the backend successfully while signed
  /// in" — resets the 7-day offline grace clock. Called from every place
  /// that confirms a real round-trip: a successful profile refresh here and
  /// a fresh sign-in in [LoginController].
  Future<void> recordSuccessfulBackendContact() => localStorageService.write(
    LocalStorageKeys.lastVerifiedOnlineAt,
    DateTime.now().toUtc().toIso8601String(),
  );

  /// Whether this device has gone more than [OfflineGracePeriod.duration]
  /// without ever successfully reaching the backend while signed in. A
  /// device that predates this check (no timestamp recorded yet) is
  /// grandfathered in as not expired, so existing signed-in users aren't
  /// forced to re-authenticate purely because the app updated.
  Future<bool> _hasGracePeriodExpired() async {
    final String? raw = await localStorageService.read<String?>(
      LocalStorageKeys.lastVerifiedOnlineAt,
    );
    final DateTime? lastVerified = raw == null ? null : DateTime.tryParse(raw);
    if (lastVerified == null) {
      await recordSuccessfulBackendContact();
      return false;
    }
    return _offlineGracePeriod.hasExpired(
      lastVerifiedOnlineAt: lastVerified,
      now: DateTime.now(),
    );
  }

  Future<void> _forceReauthentication() async {
    final bool wasOffline =
        Get.isRegistered<ConnectivityService>() &&
        !Get.find<ConnectivityService>().isOnline.value;
    await _signOutUseCase();
    await _appNavigator.offAllNamed(AppRoutes.login);
    if (wasOffline) {
      final BuildContext? context = Get.context;
      if (context != null && context.mounted) {
        _appNavigator.showOfflineSnackBar(
          context.l10n.offlineSessionExpiredMessage,
        );
      }
    }
  }

  void _applyConfig(AppConfigEntity config) {
    isDarkMode.value = config.isDarkMode;
    accentColor.value = Color(config.accentColorValue);
    _saveCachedAccentColorValue(config.accentColorValue);
    userName.value = config.userName;
    nickName.value = config.nickName;
    email.value = config.email;
    phoneNumber.value = config.phoneNumber;
    birthDate.value = config.birthDate;
    profilePhotoBase64.value = config.profilePhotoBase64;
    avatarIconIndex.value = config.avatarIconIndex;
    notificationsEnabled.value = config.notificationsEnabled;
    Get.find<AchievementUnlockService>().setNotificationsEnabled(
      config.notificationsEnabled,
    );
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
    _startPresenceTracking();

    final Either<AppError, AppConfigEntity?> result =
        await _getCurrentProfileUseCase();
    return await result.fold((error) async => false, (config) async {
      await recordSuccessfulBackendContact();
      if (config == null) {
        return false;
      }
      final AppConfigEntity mergedConfig = _withLocalDevicePreferences(config);
      _applyConfig(mergedConfig);
      await _saveAppConfigUseCase(_currentConfig);
      return config.userName.isNotEmpty;
    });
  }

  AppConfigEntity _withLocalDevicePreferences(AppConfigEntity config) =>
      config.copyWith(
        isDarkMode: isDarkMode.value,
        languageCode: languageCode.value,
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
      Get.find<SubjectDailyHistoryService>().load(),
      Get.find<ActivityHistoryService>().load(),
      Get.find<ScheduleController>().loadEntries(),
    ];

    if (Get.isRegistered<GroupsController>()) {
      reloads.add(Get.find<GroupsController>().loadGroups());
    }
    if (Get.isRegistered<HomeController>()) {
      reloads.add(Get.find<HomeController>().load(reloadSchedule: false));
    }
    if (Get.isRegistered<ProgressController>()) {
      reloads.add(Get.find<ProgressController>().loadStats());
    }

    await Future.wait(reloads);
    await _restoreActivityHistoryFromBackendIfNeeded();
  }

  /// Backfills local progress caches from `activity_entries` so a device
  /// whose local history doesn't cover everything the account has logged
  /// elsewhere (a reinstall, a new device, or a cache that only partially
  /// rebuilt) catches up. Gated on a persisted flag rather than the caches
  /// being empty: local storage is per-device, so as soon as the user logs
  /// one session here the caches stop being empty even though older history
  /// logged on another device is still missing, which would otherwise close
  /// this backfill's only chance to run ever again.
  Future<bool> _restoreActivityHistoryFromBackendIfNeeded() {
    final Future<bool>? current = _activityBackfillInProgress;
    if (current != null) return current;
    final Future<bool> work = _runActivityHistoryBackfill();
    _activityBackfillInProgress = work;
    return work.whenComplete(() => _activityBackfillInProgress = null);
  }

  Future<bool> _runActivityHistoryBackfill() async {
    if (!_supabaseService.hasSignedInUser) {
      return false;
    }

    final bool alreadyBackfilled =
        await localStorageService.read<bool?>(
          LocalStorageKeys.activityHistoryBackfillCompleted,
        ) ??
        false;
    if (alreadyBackfilled) {
      return false;
    }

    final ActivityHistoryService activityHistoryService =
        Get.find<ActivityHistoryService>();
    final DailyProgressService dailyProgressService =
        Get.find<DailyProgressService>();
    final SubjectDailyHistoryService subjectDailyHistoryService =
        Get.find<SubjectDailyHistoryService>();

    final Either<AppError, List<ActivityEntryEntity>> result =
        await _getActivityEntriesUseCase(
          retentionDays: ActivityHistoryService.retentionDays,
        );
    return await result.fold((error) async => false, (entries) async {
      bool merged = false;
      if (entries.isNotEmpty) {
        final List<bool> results = await Future.wait([
          activityHistoryService.mergeMissingDaysFromActivityEntries(entries),
          dailyProgressService.mergeMissingDaysFromActivityEntries(entries),
          subjectDailyHistoryService.mergeMissingDaysFromActivityEntries(
            entries,
          ),
        ]);
        merged = results.any((didMerge) => didMerge);
      }
      await localStorageService.write(
        LocalStorageKeys.activityHistoryBackfillCompleted,
        true,
      );
      return merged;
    });
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode.value = value;
    await _saveAppConfigUseCase(_currentConfig);
  }

  Future<void> setAccentColor(Color value) async {
    accentColor.value = value;
    await _saveCachedAccentColorValue(value.toARGB32());
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
    if (!value) {
      await _timerNotificationService.disableNotifications();
      notificationsEnabled.value = false;
      Get.find<AchievementUnlockService>().setNotificationsEnabled(false);
      await _saveAppConfigUseCase(_currentConfig);
      return;
    }

    final bool allowed = await _timerNotificationService
        .requestNotificationsEnabled();
    notificationsEnabled.value = allowed;
    Get.find<AchievementUnlockService>().setNotificationsEnabled(allowed);
    await _saveAppConfigUseCase(_currentConfig);
  }

  Future<void> refreshNotificationsEnabledFromSystem() async {
    final bool allowed = await _timerNotificationService
        .areNotificationsEnabled();
    if (!notificationsEnabled.value || allowed) {
      return;
    }
    notificationsEnabled.value = false;
    Get.find<AchievementUnlockService>().setNotificationsEnabled(false);
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

  Future<void> setFocusLockPreferences({
    required bool studying,
    required bool exercises,
    required bool reading,
    required bool hobbies,
  }) async {
    focusLockStudyingEnabled.value = studying;
    focusLockExercisesEnabled.value = exercises;
    focusLockReadingEnabled.value = reading;
    focusLockHobbiesEnabled.value = hobbies;
    await _saveAppConfigUseCase(_currentConfig);
  }

  Locale _resolvedLocale(String? code) {
    if (code != null &&
        AppLocalizations.supportedLocales.any(
          (locale) => locale.languageCode == code,
        )) {
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
    _presenceHeartbeat?.cancel();
    _presenceHeartbeat = null;
    await _writePresence(
      isOnline: false,
    ).timeout(_presenceLogoutWait, onTimeout: () {});
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
    accentColor.value = AppAccentPresets.defaultAccent;
    await _saveCachedAccentColorValue(AppAccentPresets.defaultAccentValue);
    await reloadUserScopedState();
    await _appNavigator.offAllNamed(AppRoutes.login);
  }

  Future<void> _saveCachedAccentColorValue(int value) =>
      localStorageService.write(LocalStorageKeys.cachedAccentColorValue, value);

  void _startPresenceTracking() {
    if (!_supabaseService.hasSignedInUser) {
      return;
    }
    unawaited(_writePresence(isOnline: true));
    _presenceHeartbeat ??= Timer.periodic(
      _presenceHeartbeatInterval,
      (_) => unawaited(_writePresence(isOnline: true)),
    );
  }

  Future<void> _writePresence({required bool isOnline}) async {
    final String? userId = _supabaseService.currentUserId;
    if (userId == null) {
      return;
    }
    _presenceWriteQueue = _presenceWriteQueue.then((_) async {
      try {
        await _supabaseService.requireClient
            .from("profiles")
            .update({
              "is_online": isOnline,
              "last_seen_at": DateTime.now().toUtc().toIso8601String(),
            })
            .eq("id", userId)
            .timeout(_presenceRequestTimeout);
      } catch (_) {
        // Presence is best-effort and must never block navigation or logout.
      }
    });
    await _presenceWriteQueue;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      isAppInForeground.value = true;
      _startPresenceTracking();
      unawaited(Get.find<ConnectivityService>().refresh());
      return;
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      isAppInForeground.value = false;
      _presenceHeartbeat?.cancel();
      _presenceHeartbeat = null;
      unawaited(_writePresence(isOnline: false));
    }
  }

  @override
  void onClose() {
    _presenceHeartbeat?.cancel();
    _pendingSyncRetryTimer?.cancel();
    unawaited(_pendingSyncSubscription?.cancel());
    unawaited(_connectivitySubscription?.cancel());
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
