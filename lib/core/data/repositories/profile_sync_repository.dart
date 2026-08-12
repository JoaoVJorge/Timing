import "package:dartz/dartz.dart";
import "package:timing/core/data/data_sources/profile_sync_data_source.dart";
import "package:timing/core/domain/entities/app_config_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

class ProfileSyncRepository {
  ProfileSyncRepository({required this._profileSyncDataSource});

  final ProfileSyncDataSource _profileSyncDataSource;

  Future<Either<AppError, void>> syncProfile(AppConfigEntity config) =>
      _profileSyncDataSource.syncProfile(config);

  Future<Either<AppError, AppConfigEntity?>> getCurrentProfile() =>
      _profileSyncDataSource.getCurrentProfile();
}
