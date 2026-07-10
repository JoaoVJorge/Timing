import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/phone_auth_repository.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class RequestPhoneCodeUseCase {
  RequestPhoneCodeUseCase({required this._phoneAuthRepository});

  final PhoneAuthRepository _phoneAuthRepository;

  Future<Either<AppError, void>> call(String phoneNumber) =>
      _phoneAuthRepository.requestCode(phoneNumber);
}
