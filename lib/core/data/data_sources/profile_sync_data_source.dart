import "package:dartz/dartz.dart";
import "package:help_out/core/domain/entities/app_config_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/services/supabase/supabase_service.dart";

class ProfileSyncDataSource {
  ProfileSyncDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  Future<Either<AppError, void>> syncProfile(AppConfigEntity config) async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return const Right(null);
      }
      final user = _supabaseService.client?.auth.currentUser;

      await _supabaseService.requireClient.from("profiles").upsert({
        "id": userId,
        "is_dark_mode": config.isDarkMode,
        "user_name": config.userName,
        "nick_name": config.nickName,
        "email": config.email ?? user?.email,
        "phone_number": config.phoneNumber ?? user?.phone,
        "birth_date": config.birthDate,
        "profile_photo_base64": config.profilePhotoBase64,
        "accent_color_value": config.accentColorValue,
        "avatar_icon_index": config.avatarIconIndex,
        "notifications_enabled": config.notificationsEnabled,
        "language_code": config.languageCode,
        "updated_at": DateTime.now().toUtc().toIso8601String(),
      }, onConflict: "id");
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, AppConfigEntity?>> getCurrentProfile() async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return const Right(null);
      }

      final Map<String, dynamic>? data = await _supabaseService.requireClient
          .from("profiles")
          .select()
          .eq("id", userId)
          .maybeSingle();

      if (data == null) {
        return const Right(null);
      }

      return Right(_profileFromRow(data));
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  AppConfigEntity _profileFromRow(Map<String, dynamic> row) {
    final AppConfigEntity fallback = AppConfigEntity.fallback();
    return fallback.copyWith(
      isDarkMode: row["is_dark_mode"] as bool? ?? fallback.isDarkMode,
      userName: row["user_name"] as String? ?? "",
      nickName: row["nick_name"] as String? ?? "",
      email: row["email"] as String?,
      phoneNumber: row["phone_number"] as String?,
      birthDate: row["birth_date"] as String?,
      profilePhotoBase64: row["profile_photo_base64"] as String?,
      accentColorValue:
          (row["accent_color_value"] as num?)?.toInt() ??
          fallback.accentColorValue,
      avatarIconIndex:
          (row["avatar_icon_index"] as num?)?.toInt() ??
          fallback.avatarIconIndex,
      notificationsEnabled:
          row["notifications_enabled"] as bool? ??
          fallback.notificationsEnabled,
      languageCode: row["language_code"] as String?,
      friendCode: row["friend_code"] as String? ?? "",
    );
  }
}
