import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/profile_sync_repository.dart";
import "package:timing/core/domain/entities/app_config_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

class GetCurrentProfileUseCase {
  GetCurrentProfileUseCase({required this.profileSyncRepository});

  final ProfileSyncRepository profileSyncRepository;

  Future<Either<AppError, AppConfigEntity?>> call() =>
      profileSyncRepository.getCurrentProfile();
}
