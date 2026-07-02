import "package:dartz/dartz.dart";
import "package:help_out/core/data/data_sources/app_config_data_source.dart";
import "package:help_out/core/domain/entities/app_config_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class AppConfigRepository {
  AppConfigRepository({required this._appConfigDataSource});

  final AppConfigDataSource _appConfigDataSource;

  Future<Either<AppError, AppConfigEntity>> getAppConfig() => _appConfigDataSource.getAppConfig();

  Future<Either<AppError, void>> saveAppConfig(AppConfigEntity config) =>
      _appConfigDataSource.saveAppConfig(config);
}
