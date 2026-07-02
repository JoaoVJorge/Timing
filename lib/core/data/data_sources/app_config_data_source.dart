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
      final String? savedConfig = await _localStorageService.read<String?>(LocalStorageKeys.appConfig);

      if (savedConfig == null) {
        return Right(AppConfigEntity.fallback());
      }

      return Right(AppConfigEntity.fromJson(savedConfig));
    } catch (error, stackTrace) {
      return Left(SerializationAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> saveAppConfig(AppConfigEntity config) async {
    try {
      await _localStorageService.write(LocalStorageKeys.appConfig, config.toJson());
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }
}
