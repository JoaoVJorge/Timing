import "package:flutter_dotenv/flutter_dotenv.dart";

abstract class EnvironmentKeys {
  const EnvironmentKeys._();

  static String get baseUrl => dotenv.env["baseUrl"] ?? "";
}
