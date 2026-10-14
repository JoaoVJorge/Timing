import "package:flutter/foundation.dart";

class AppConstants {
  const AppConstants._();

  static const String appTitle = "Timing";
  static const String appVersion = "0.1.0";

  static const String appLogo = "assets/icons/logo_without_background.svg";
  static const String appLogoFull = "assets/icons/logo.svg";

  /// The scheme the OS hands back to the app, registered on both platforms.
  /// `groupLink` builds what a leader shares so the link opens the join
  /// screen with the code already filled in; `friendLink` does the same for
  /// the add-friend screen.
  static const String deepLinkScheme = "com.moonstone.timing";
  static const String joinGroupLinkHost = "join-group";
  static const String addFriendLinkHost = "add-friend";

  static Uri groupUri(String inviteCode) =>
      _inviteUri(host: joinGroupLinkHost, code: inviteCode);

  static String groupLink(String inviteCode) => groupUri(inviteCode).toString();

  static Uri friendUri(String friendCode) =>
      _inviteUri(host: addFriendLinkHost, code: friendCode);

  static String friendLink(String friendCode) =>
      friendUri(friendCode).toString();

  static Uri _inviteUri({required String host, required String code}) => Uri(
    scheme: deepLinkScheme,
    host: host,
    queryParameters: {"code": code.trim().toUpperCase()},
  );

  static const bool useMockData = kDebugMode;
  static const Duration splashScreenDuration = Duration(seconds: 2);
}
