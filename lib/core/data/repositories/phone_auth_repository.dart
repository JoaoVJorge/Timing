import "package:dartz/dartz.dart";
import "package:help_out/core/data/data_sources/phone_auth_data_source.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class PhoneAuthRepository {
  PhoneAuthRepository({required this._phoneAuthDataSource});

  final PhoneAuthDataSource _phoneAuthDataSource;

  Future<Either<AppError, void>> requestCode(String emailAddress) =>
      _phoneAuthDataSource.requestCode(emailAddress);

  Future<Either<AppError, bool>> verifyCode({
    required String emailAddress,
    required String code,
  }) => _phoneAuthDataSource.verifyCode(emailAddress: emailAddress, code: code);

  Future<Either<AppError, void>> signOut() => _phoneAuthDataSource.signOut();
}
