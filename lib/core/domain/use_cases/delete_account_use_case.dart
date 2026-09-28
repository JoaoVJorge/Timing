import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/profile_sync_repository.dart";
import "package:timing/core/domain/errors/app_error.dart";

class DeleteAccountUseCase {
  DeleteAccountUseCase({required this._profileSyncRepository});

  final ProfileSyncRepository _profileSyncRepository;

  Future<Either<AppError, void>> call() =>
      _profileSyncRepository.deleteAccount();
}
