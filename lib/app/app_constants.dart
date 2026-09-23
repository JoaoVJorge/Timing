import "package:flutter/foundation.dart";

class AppConstants {
  const AppConstants._();

  static const String appTitle = "Timing";
  static const String appVersion = "0.1.0";

  static const String appLogo = "assets/icons/logo_without_background.svg";
  static const String appLogoFull = "assets/icons/logo.svg";
  static const String accountDeletionUrl =
      "https://github.com/JoaoVJorge/Timing/blob/main/docs/play-store/account-deletion-en.md";

  static const bool useMockData = kDebugMode;
  static const Duration splashScreenDuration = Duration(seconds: 2);
}
