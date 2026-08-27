abstract class EnvironmentKeys {
  const EnvironmentKeys._();

  static const String baseUrl = String.fromEnvironment("baseUrl");

  static const String supabaseUrl = String.fromEnvironment("supabaseUrl");

  static const String supabasePublishableKey = String.fromEnvironment(
    "supabasePublishableKey",
  );

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
