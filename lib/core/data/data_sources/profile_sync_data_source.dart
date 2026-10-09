import "package:timing/core/domain/entities/app_config_entity.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";

/// The signed-in user's profile rows on the backend. Every call throws
/// whatever it fails with; `ProfileSyncRepository` turns that into an
/// `AppError` and decides what a missing session means.
class ProfileSyncDataSource {
  ProfileSyncDataSource({
    required this._supabaseService,
    required this._logger,
  });

  final SupabaseService _supabaseService;
  final AppLoggerService _logger;
  // A remote call must fail fast on a "connected but no real internet"
  // network instead of hanging on the platform's own (much longer) socket
  // timeout: saving the profile has no other timeout wrapping it when called
  // from EditProfileController.onTapSave().
  static const Duration _remoteCallTimeout = Duration(seconds: 10);

  String? get currentUserId => _supabaseService.currentUserId;

  Future<void> upsertProfile({
    required String userId,
    required AppConfigEntity config,
  }) async {
    final user = _supabaseService.client?.auth.currentUser;

    await _supabaseService.requireClient
        .from("profiles")
        .upsert({
          "id": userId,
          "user_name": config.userName,
          "nick_name": config.nickName,
          "profile_photo_base64": config.profilePhotoBase64,
          "avatar_icon_index": config.avatarIconIndex,
          "notifications_enabled": config.notificationsEnabled,
          "focus_lock_studying_enabled": config.focusLockStudyingEnabled,
          "focus_lock_exercises_enabled": config.focusLockExercisesEnabled,
          "focus_lock_reading_enabled": config.focusLockReadingEnabled,
          "focus_lock_hobbies_enabled": config.focusLockHobbiesEnabled,
        }, onConflict: "id")
        .timeout(_remoteCallTimeout);
    await _supabaseService.requireClient
        .from("profile_private_data")
        .upsert({
          "user_id": userId,
          "email": config.email ?? user?.email,
          "phone_number": config.phoneNumber ?? user?.phone,
          "birth_date": config.birthDate,
        }, onConflict: "user_id")
        .timeout(_remoteCallTimeout);
  }

  Future<void> deleteAccount() async {
    await _supabaseService.requireClient
        .rpc("delete_my_account")
        .timeout(_remoteCallTimeout);
  }

  Future<AppConfigEntity?> fetchProfile(String userId) async {
    final List<Map<String, dynamic>?> rows = await Future.wait([
      _supabaseService.requireClient
          .from("profiles")
          .select(
            "id, friend_code, is_dark_mode, user_name, nick_name, "
            "profile_photo_base64, avatar_icon_index, "
            "notifications_enabled, "
            "focus_lock_studying_enabled, focus_lock_exercises_enabled, "
            "focus_lock_reading_enabled, focus_lock_hobbies_enabled",
          )
          .eq("id", userId)
          .maybeSingle()
          .timeout(_remoteCallTimeout),
      _supabaseService.requireClient
          .from("profile_private_data")
          .select("email, phone_number, birth_date")
          .eq("user_id", userId)
          .maybeSingle()
          .timeout(_remoteCallTimeout),
    ]);
    final Map<String, dynamic>? data = rows.first;
    final Map<String, dynamic>? privateData = rows.last;
    _logger.logResponse("select public.profiles", data);

    if (data == null) {
      return null;
    }

    return _profileFromRow({...data, ...?privateData});
  }

  AppConfigEntity _profileFromRow(Map<String, dynamic> row) {
    final AppConfigEntity fallback = AppConfigEntity.fallback();
    return fallback.copyWith(
      userName: row["user_name"] as String? ?? "",
      nickName: row["nick_name"] as String? ?? "",
      email: row["email"] as String?,
      phoneNumber: row["phone_number"] as String?,
      birthDate: row["birth_date"] as String?,
      profilePhotoBase64: row["profile_photo_base64"] as String?,
      avatarIconIndex:
          (row["avatar_icon_index"] as num?)?.toInt() ??
          fallback.avatarIconIndex,
      notificationsEnabled:
          row["notifications_enabled"] as bool? ??
          fallback.notificationsEnabled,
      friendCode: row["friend_code"] as String? ?? "",
      focusLockStudyingEnabled:
          row["focus_lock_studying_enabled"] as bool? ??
          fallback.focusLockStudyingEnabled,
      focusLockExercisesEnabled:
          row["focus_lock_exercises_enabled"] as bool? ??
          fallback.focusLockExercisesEnabled,
      focusLockReadingEnabled:
          row["focus_lock_reading_enabled"] as bool? ??
          fallback.focusLockReadingEnabled,
      focusLockHobbiesEnabled:
          row["focus_lock_hobbies_enabled"] as bool? ??
          fallback.focusLockHobbiesEnabled,
    );
  }
}
