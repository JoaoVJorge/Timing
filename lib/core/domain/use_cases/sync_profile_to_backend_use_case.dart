import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/profile_sync_repository.dart";
import "package:help_out/core/domain/entities/app_config_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class SyncProfileToBackendUseCase {
  SyncProfileToBackendUseCase({required this._profileSyncRepository});

  final ProfileSyncRepository _profileSyncRepository;

  Future<Either<AppError, void>> call(AppConfigEntity config) => _profileSyncRepository.syncProfile(config);
}
