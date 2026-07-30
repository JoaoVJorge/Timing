import "package:flutter/foundation.dart";
import "package:help_out/env/environment_keys.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class SupabaseService {
  SupabaseService._({required this.isConfigured, this.client});

  static const String oauthRedirectUrl = "helpout://login-callback";

  final bool isConfigured;
  final SupabaseClient? client;

  static Future<SupabaseService> initialize() async {
    if (!EnvironmentKeys.hasSupabaseConfig) {
      return SupabaseService._(isConfigured: false);
    }

    final String projectUrl = _normalizedProjectUrl(
      EnvironmentKeys.supabaseUrl,
    );
    if (kDebugMode) {
      debugPrint("[INFO] Initializing Supabase with url: $projectUrl");
    }

    final Supabase supabase = await Supabase.initialize(
      url: projectUrl,
      publishableKey: EnvironmentKeys.supabasePublishableKey,
    );
    return SupabaseService._(isConfigured: true, client: supabase.client);
  }

  static String _normalizedProjectUrl(String rawUrl) {
    final Uri uri = Uri.parse(rawUrl.trim());
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
    ).toString();
  }

  SupabaseClient get requireClient {
    final SupabaseClient? configuredClient = client;
    if (configuredClient == null) {
      throw StateError(
        "Supabase is not configured. Add supabaseUrl and supabasePublishableKey to the env file.",
      );
    }
    return configuredClient;
  }

  String? get currentUserId => client?.auth.currentUser?.id;

  bool get hasSignedInUser => currentUserId != null;
}
