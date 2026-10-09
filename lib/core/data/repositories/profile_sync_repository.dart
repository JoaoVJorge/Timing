import "package:dartz/dartz.dart";
import "package:timing/core/data/data_sources/profile_sync_data_source.dart";
import "package:timing/core/data/errors/backend_error.dart";
import "package:timing/core/domain/entities/app_config_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

/// The signed-in user's profile on the backend. Nothing here is cached or
/// queued: a failure is reported as a typed [AppError], and without a session
/// there is simply no profile to read or sync.
class ProfileSyncRepository {
  ProfileSyncRepository({required this._profileSyncDataSource});

  final ProfileSyncDataSource _profileSyncDataSource;

  Future<Either<AppError, void>> syncProfile(AppConfigEntity config) async {
    final String? userId = _profileSyncDataSource.currentUserId;
    if (userId == null) {
      return const Right(null);
    }
    return guardBackendCall(
      () =>
          _profileSyncDataSource.upsertProfile(userId: userId, config: config),
      operation: "upsert public.profiles",
    );
  }

  Future<Either<AppError, void>> deleteAccount() async {
    if (_profileSyncDataSource.currentUserId == null) {
      return const Left(SignedOutError(operation: "delete the account"));
    }
    return guardBackendCall(
      _profileSyncDataSource.deleteAccount,
      operation: "rpc public.delete_my_account",
    );
  }

  Future<Either<AppError, AppConfigEntity?>> getCurrentProfile() async {
    final String? userId = _profileSyncDataSource.currentUserId;
    if (userId == null) {
      return const Right(null);
    }
    return guardBackendCall(
      () => _profileSyncDataSource.fetchProfile(userId),
      operation: "select public.profiles",
    );
  }
}
