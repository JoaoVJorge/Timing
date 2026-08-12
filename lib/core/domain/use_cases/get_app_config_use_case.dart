import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/app_config_repository.dart";
import "package:timing/core/domain/entities/app_config_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

class GetAppConfigUseCase {
  GetAppConfigUseCase({required this._appConfigRepository});

  final AppConfigRepository _appConfigRepository;

  Future<Either<AppError, AppConfigEntity>> call() =>
      _appConfigRepository.getAppConfig();
}
