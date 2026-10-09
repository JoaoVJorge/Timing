import "package:timing/core/domain/enums/auth_identity_provider.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:supabase_flutter/supabase_flutter.dart";

/// Sign-in, sign-out and linked identities on Supabase Auth. Every call
/// throws whatever it fails with; `PhoneAuthRepository` turns that into an
/// `AppError`.
class PhoneAuthDataSource {
  PhoneAuthDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;
  // A remote call must fail fast on a "connected but no real internet"
  // network instead of hanging on the platform's own (much longer) socket
  // timeout — signOut() in particular must never leave a user unable to log
  // out just because the network is degraded.
  static const Duration _remoteCallTimeout = Duration(seconds: 10);

  Future<void> requestCode(String emailAddress) async {
    await _supabaseService.requireClient.auth
        .signInWithOtp(email: _normalizedEmailAddress(emailAddress))
        .timeout(_remoteCallTimeout);
  }

  Future<void> verifyCode({
    required String emailAddress,
    required String code,
  }) async {
    await _supabaseService.requireClient.auth
        .verifyOTP(
          email: _normalizedEmailAddress(emailAddress),
          token: code,
          type: OtpType.email,
        )
        .timeout(_remoteCallTimeout);
  }

  Future<void> signOut() async {
    if (_supabaseService.isConfigured) {
      await _supabaseService.requireClient.auth.signOut().timeout(
        _remoteCallTimeout,
      );
    }
  }

  String _normalizedEmailAddress(String emailAddress) =>
      emailAddress.trim().toLowerCase();

  Future<void> signInWithGoogle() async {
    await _supabaseService.requireClient.auth
        .signInWithOAuth(
          OAuthProvider.google,
          redirectTo: SupabaseService.oauthRedirectUrl,
          authScreenLaunchMode: LaunchMode.externalApplication,
        )
        .timeout(_remoteCallTimeout);
  }

  Future<Set<String>> getLinkedAuthProviders() async {
    final client = _supabaseService.requireClient;
    final identities = await client.auth.getUserIdentities().timeout(
      _remoteCallTimeout,
    );
    final Set<String> providers = {
      for (final identity in identities) identity.provider,
    };
    return providers;
  }

  Future<bool> linkAuthProvider(AuthIdentityProvider provider) async {
    final bool launched = await _supabaseService.requireClient.auth
        .linkIdentity(
          _oauthProvider(provider),
          redirectTo: SupabaseService.oauthRedirectUrl,
          authScreenLaunchMode: LaunchMode.externalApplication,
        )
        .timeout(_remoteCallTimeout);
    return launched;
  }

  OAuthProvider _oauthProvider(AuthIdentityProvider provider) =>
      switch (provider) {
        AuthIdentityProvider.google => OAuthProvider.google,
        AuthIdentityProvider.apple => OAuthProvider.apple,
      };
}
