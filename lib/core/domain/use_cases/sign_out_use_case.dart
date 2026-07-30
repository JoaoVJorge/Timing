import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/phone_auth_repository.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class SignOutUseCase {
  SignOutUseCase({required this.phoneAuthRepository});

  final PhoneAuthRepository phoneAuthRepository;

  Future<Either<AppError, void>> call() => phoneAuthRepository.signOut();
}
