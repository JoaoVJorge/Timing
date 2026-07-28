import "package:dartz/dartz.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/services/supabase/supabase_service.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class PhoneAuthDataSource {
  PhoneAuthDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  Future<Either<AppError, void>> requestCode(String phoneNumber) async {
    try {
      await _supabaseService.requireClient.auth.signInWithOtp(
        phone: _normalizedPhoneNumber(phoneNumber),
      );
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, bool>> verifyCode({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      if (!RegExp(r"^[0-9]{6}$").hasMatch(code)) {
        return const Right(false);
      }

      await _supabaseService.requireClient.auth.verifyOTP(
        phone: _normalizedPhoneNumber(phoneNumber),
        token: code,
        type: OtpType.sms,
      );
      return const Right(true);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> signOut() async {
    try {
      if (_supabaseService.isConfigured) {
        await _supabaseService.requireClient.auth.signOut();
      }
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  String _normalizedPhoneNumber(String phoneNumber) =>
      phoneNumber.replaceAll(RegExp(r"[^+0-9]"), "");
}
