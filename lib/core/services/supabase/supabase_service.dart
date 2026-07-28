import "package:help_out/env/environment_keys.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class SupabaseService {
  SupabaseService._({required this.isConfigured, this.client});

  final bool isConfigured;
  final SupabaseClient? client;

  static Future<SupabaseService> initialize() async {
    if (!EnvironmentKeys.hasSupabaseConfig) {
      return SupabaseService._(isConfigured: false);
    }

    final Supabase supabase = await Supabase.initialize(
      url: EnvironmentKeys.supabaseUrl,
      publishableKey: EnvironmentKeys.supabasePublishableKey,
    );
    return SupabaseService._(isConfigured: true, client: supabase.client);
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
