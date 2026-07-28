import "package:flutter_dotenv/flutter_dotenv.dart";

abstract class EnvironmentKeys {
  const EnvironmentKeys._();

  static String get baseUrl => dotenv.env["baseUrl"] ?? "";

  static String get supabaseUrl => dotenv.env["supabaseUrl"] ?? "";

  static String get supabasePublishableKey =>
      dotenv.env["supabasePublishableKey"] ?? "";

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
