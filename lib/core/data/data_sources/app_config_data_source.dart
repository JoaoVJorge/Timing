import "package:dartz/dartz.dart";
import "package:help_out/core/domain/entities/app_config_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/services/local_storage/app_local_storage_service.dart";
import "package:help_out/core/services/local_storage/local_storage_keys.dart";

class AppConfigDataSource {
  AppConfigDataSource({required this._localStorageService});

  final AppLocalStorageService _localStorageService;

  Future<Either<AppError, AppConfigEntity>> getAppConfig() async {
    try {
      final String? savedConfig = await _localStorageService.read<String?>(
        LocalStorageKeys.appConfig,
      );

      if (savedConfig == null) {
        return Right(await _withLocalPreferences(AppConfigEntity.fallback()));
      }

      return Right(
        await _withLocalPreferences(AppConfigEntity.fromJson(savedConfig)),
      );
    } catch (error, stackTrace) {
      return Left(SerializationAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> saveAppConfig(AppConfigEntity config) async {
    try {
      await _localStorageService.write(
        LocalStorageKeys.appConfig,
        config.toJson(),
      );
      await _localStorageService.write(
        LocalStorageKeys.isDarkMode,
        config.isDarkMode,
      );
      await Future.wait([
        _localStorageService.write(
          LocalStorageKeys.focusLockStudyingEnabled,
          config.focusLockStudyingEnabled,
        ),
        _localStorageService.write(
          LocalStorageKeys.focusLockExercisesEnabled,
          config.focusLockExercisesEnabled,
        ),
        _localStorageService.write(
          LocalStorageKeys.focusLockReadingEnabled,
          config.focusLockReadingEnabled,
        ),
        _localStorageService.write(
          LocalStorageKeys.focusLockHobbiesEnabled,
          config.focusLockHobbiesEnabled,
        ),
      ]);
      final String? languageCode = config.languageCode;
      if (languageCode == null) {
        await _localStorageService.delete(LocalStorageKeys.languageCode);
      } else {
        await _localStorageService.write(
          LocalStorageKeys.languageCode,
          languageCode,
        );
      }
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<AppConfigEntity> _withLocalPreferences(AppConfigEntity config) async {
    final bool? savedDarkMode = await _localStorageService.read<bool?>(
      LocalStorageKeys.isDarkMode,
    );
    final String? savedLanguageCode = await _localStorageService.read<String?>(
      LocalStorageKeys.languageCode,
    );
    final bool? savedFocusLockStudying = await _localStorageService.read<bool?>(
      LocalStorageKeys.focusLockStudyingEnabled,
    );
    final bool? savedFocusLockExercises = await _localStorageService
        .read<bool?>(LocalStorageKeys.focusLockExercisesEnabled);
    final bool? savedFocusLockReading = await _localStorageService.read<bool?>(
      LocalStorageKeys.focusLockReadingEnabled,
    );
    final bool? savedFocusLockHobbies = await _localStorageService.read<bool?>(
      LocalStorageKeys.focusLockHobbiesEnabled,
    );
    return config.copyWith(
      isDarkMode: savedDarkMode ?? config.isDarkMode,
      languageCode: savedLanguageCode ?? config.languageCode,
      focusLockStudyingEnabled:
          savedFocusLockStudying ?? config.focusLockStudyingEnabled,
      focusLockExercisesEnabled:
          savedFocusLockExercises ?? config.focusLockExercisesEnabled,
      focusLockReadingEnabled:
          savedFocusLockReading ?? config.focusLockReadingEnabled,
      focusLockHobbiesEnabled:
          savedFocusLockHobbies ?? config.focusLockHobbiesEnabled,
    );
  }
}
