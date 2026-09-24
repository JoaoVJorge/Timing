import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "package:timing/core/services/log/http_traffic_logger.dart";
import "package:timing/env/environment_keys.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class SupabaseService {
  SupabaseService._({required this.isConfigured, this.client});

  static const String oauthRedirectUrl = "timing://login-callback";

  final bool isConfigured;
  final SupabaseClient? client;

  static Future<SupabaseService> initialize() async {
    if (!EnvironmentKeys.hasSupabaseConfig) {
      if (kReleaseMode) {
        throw StateError(
          "A release build requires supabaseUrl and "
          "supabasePublishableKey. Pass the production environment through "
          "--dart-define-from-file.",
        );
      }
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
      httpClient: kDebugMode ? LoggingHttpClient(http.Client()) : null,
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
        "Supabase is not configured. Provide supabaseUrl and "
        "supabasePublishableKey through --dart-define or "
        "--dart-define-from-file.",
      );
    }
    return configuredClient;
  }

  String? get currentUserId => client?.auth.currentUser?.id;

  bool get hasSignedInUser => currentUserId != null;
}
