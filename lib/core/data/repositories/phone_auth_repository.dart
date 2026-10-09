import "package:dartz/dartz.dart";
import "package:timing/core/data/data_sources/phone_auth_data_source.dart";
import "package:timing/core/data/errors/backend_error.dart";
import "package:timing/core/domain/enums/auth_identity_provider.dart";
import "package:timing/core/domain/errors/app_error.dart";

/// Signing in and out. Nothing here works offline, so every failure is
/// reported as a typed [AppError].
class PhoneAuthRepository {
  PhoneAuthRepository({required this._phoneAuthDataSource});

  final PhoneAuthDataSource _phoneAuthDataSource;

  static final RegExp _codePattern = RegExp(r"^[0-9]{6}$");

  Future<Either<AppError, void>> requestCode(String emailAddress) =>
      guardBackendCall(() => _phoneAuthDataSource.requestCode(emailAddress));

  /// Whether [code] signed the user in. A code that cannot be valid is turned
  /// down without asking the backend.
  Future<Either<AppError, bool>> verifyCode({
    required String emailAddress,
    required String code,
  }) async {
    if (!_codePattern.hasMatch(code)) {
      return const Right(false);
    }
    return guardBackendCall(() async {
      await _phoneAuthDataSource.verifyCode(
        emailAddress: emailAddress,
        code: code,
      );
      return true;
    });
  }

  Future<Either<AppError, void>> signOut() =>
      guardBackendCall(_phoneAuthDataSource.signOut);

  Future<Either<AppError, void>> signInWithGoogle() =>
      guardBackendCall(_phoneAuthDataSource.signInWithGoogle);

  Future<Either<AppError, Set<String>>> getLinkedAuthProviders() =>
      guardBackendCall(_phoneAuthDataSource.getLinkedAuthProviders);

  Future<Either<AppError, bool>> linkAuthProvider(
    AuthIdentityProvider provider,
  ) => guardBackendCall(() => _phoneAuthDataSource.linkAuthProvider(provider));
}
