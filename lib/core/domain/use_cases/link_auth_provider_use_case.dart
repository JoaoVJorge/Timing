import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/phone_auth_repository.dart";
import "package:timing/core/domain/enums/auth_identity_provider.dart";
import "package:timing/core/domain/errors/app_error.dart";

class LinkAuthProviderUseCase {
  LinkAuthProviderUseCase({required this.phoneAuthRepository});

  final PhoneAuthRepository phoneAuthRepository;

  Future<Either<AppError, bool>> call(AuthIdentityProvider provider) =>
      phoneAuthRepository.linkAuthProvider(provider);
}
