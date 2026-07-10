import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/phone_auth_repository.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class VerifyPhoneCodeUseCase {
  VerifyPhoneCodeUseCase({required this._phoneAuthRepository});

  final PhoneAuthRepository _phoneAuthRepository;

  Future<Either<AppError, bool>> call({
    required String phoneNumber,
    required String code,
  }) => _phoneAuthRepository.verifyCode(phoneNumber: phoneNumber, code: code);
}
