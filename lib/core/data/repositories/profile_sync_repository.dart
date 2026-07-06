import "package:dartz/dartz.dart";
import "package:help_out/core/data/data_sources/profile_sync_data_source.dart";
import "package:help_out/core/domain/entities/app_config_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class ProfileSyncRepository {
  ProfileSyncRepository({required this._profileSyncDataSource});

  final ProfileSyncDataSource _profileSyncDataSource;

  Future<Either<AppError, void>> syncProfile(AppConfigEntity config) => _profileSyncDataSource.syncProfile(config);
}
