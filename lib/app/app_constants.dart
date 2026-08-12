import "package:flutter/foundation.dart";

class AppConstants {
  const AppConstants._();

  static const String appTitle = "Timing";
  static const String appVersion = "0.1.0";

  static const String appLogo = "assets/images/logo_without_background.png";
  static const String appLogoFull = "assets/images/logo.png";

  static const bool useMockData = kDebugMode;
  static const Duration splashScreenDuration = Duration(seconds: 2);
}
