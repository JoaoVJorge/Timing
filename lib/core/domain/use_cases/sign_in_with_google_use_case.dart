import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/phone_auth_repository.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class SignInWithGoogleUseCase {
  SignInWithGoogleUseCase({required this.phoneAuthRepository});

  final PhoneAuthRepository phoneAuthRepository;

  Future<Either<AppError, void>> call() =>
      phoneAuthRepository.signInWithGoogle();
}
