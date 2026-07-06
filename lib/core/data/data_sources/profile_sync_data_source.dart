import "package:dartz/dartz.dart";
import "package:help_out/core/domain/entities/app_config_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class ProfileSyncDataSource {
  Future<Either<AppError, void>> syncProfile(AppConfigEntity config) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const Right(null);
  }
}
