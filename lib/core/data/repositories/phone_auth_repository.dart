import "package:dartz/dartz.dart";
import "package:timing/core/data/data_sources/phone_auth_data_source.dart";
import "package:timing/core/domain/enums/auth_identity_provider.dart";
import "package:timing/core/domain/errors/app_error.dart";

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

  Future<Either<AppError, void>> signInWithGoogle() =>
      _phoneAuthDataSource.signInWithGoogle();

  Future<Either<AppError, Set<String>>> getLinkedAuthProviders() =>
      _phoneAuthDataSource.getLinkedAuthProviders();

  Future<Either<AppError, bool>> linkAuthProvider(
    AuthIdentityProvider provider,
  ) => _phoneAuthDataSource.linkAuthProvider(provider);
}
