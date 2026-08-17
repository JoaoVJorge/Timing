import "package:dartz/dartz.dart";
import "package:timing/core/domain/enums/auth_identity_provider.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class PhoneAuthDataSource {
  PhoneAuthDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  Future<Either<AppError, void>> requestCode(String emailAddress) async {
    try {
      await _supabaseService.requireClient.auth.signInWithOtp(
        email: _normalizedEmailAddress(emailAddress),
      );
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, bool>> verifyCode({
    required String emailAddress,
    required String code,
  }) async {
    try {
      if (!RegExp(r"^[0-9]{6}$").hasMatch(code)) {
        return const Right(false);
      }

      await _supabaseService.requireClient.auth.verifyOTP(
        email: _normalizedEmailAddress(emailAddress),
        token: code,
        type: OtpType.email,
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

  String _normalizedEmailAddress(String emailAddress) =>
      emailAddress.trim().toLowerCase();

  Future<Either<AppError, void>> signInWithGoogle() async {
    try {
      await _supabaseService.requireClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: SupabaseService.oauthRedirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, Set<String>>> getLinkedAuthProviders() async {
    try {
      final client = _supabaseService.requireClient;
      final identities = await client.auth.getUserIdentities();
      final Set<String> providers = {
        for (final identity in identities) identity.provider,
      };
      return Right(providers);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, bool>> linkAuthProvider(
    AuthIdentityProvider provider,
  ) async {
    try {
      final bool launched = await _supabaseService.requireClient.auth
          .linkIdentity(
            _oauthProvider(provider),
            redirectTo: SupabaseService.oauthRedirectUrl,
            authScreenLaunchMode: LaunchMode.externalApplication,
          );
      return Right(launched);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  OAuthProvider _oauthProvider(AuthIdentityProvider provider) =>
      switch (provider) {
        AuthIdentityProvider.google => OAuthProvider.google,
        AuthIdentityProvider.apple => OAuthProvider.apple,
      };
}
