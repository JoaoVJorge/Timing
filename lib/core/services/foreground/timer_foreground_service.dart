import "package:flutter/services.dart";
import "package:get/get_utils/get_utils.dart";

/// Keeps the native focus overlay and ongoing notification attached to a real
/// Android foreground service while a session is active.
///
/// Timer progress itself remains durable through `ActiveTimerSessionService`;
/// this bridge does not imply that the Activity-owned Flutter engine survives
/// after the task is removed from Recents.
class TimerForegroundService {
  static const MethodChannel _channel = MethodChannel(
    "timing/timer_foreground_service",
  );

  bool get _isSupported => GetPlatform.isAndroid;

  Future<void> start({
    required String title,
    required String body,
    DateTime? startedAt,
  }) async {
    if (!_isSupported) {
      return;
    }

    try {
      await _channel.invokeMethod<void>("start", <String, String>{
        "title": title,
        "body": body,
        if (startedAt != null)
          "startedAtMilliseconds": startedAt.millisecondsSinceEpoch.toString(),
      });
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  Future<void> stop() async {
    if (!_isSupported) {
      return;
    }

    try {
      await _channel.invokeMethod<void>("stop");
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }
}
