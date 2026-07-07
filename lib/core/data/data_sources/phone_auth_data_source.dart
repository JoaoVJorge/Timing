import "package:dartz/dartz.dart";
import "package:help_out/core/domain/errors/app_error.dart";

/// Mock phone authentication backend. There is no real SMS provider yet, so
/// requesting a code just simulates a network round-trip and verifying accepts
/// any well-formed 6-digit code.
class PhoneAuthDataSource {
  Future<Either<AppError, void>> requestCode(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return const Right(null);
  }

  Future<Either<AppError, bool>> verifyCode({
    required String phoneNumber,
    required String code,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final bool isValid = RegExp(r"^[0-9]{6}$").hasMatch(code);
    return Right(isValid);
  }
}
