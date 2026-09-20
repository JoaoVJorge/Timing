import "package:flutter/services.dart";
import "package:get/get_utils/get_utils.dart";

/// Keeps the ongoing, lock-screen-visible notification attached to a real
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
    required String actionLabel,
    required bool isRunning,
    required bool isTicking,
    required int elapsedSeconds,
    required int colorValue,
  }) async {
    if (!_isSupported) {
      return;
    }

    try {
      await _channel.invokeMethod<void>("start", <String, Object>{
        "title": title,
        "body": body,
        "actionLabel": actionLabel,
        "isRunning": isRunning,
        "isTicking": isTicking,
        "elapsedSeconds": elapsedSeconds,
        "colorHex": (colorValue & 0xFFFFFF).toRadixString(16).padLeft(6, "0"),
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

  /// Consumes a pause/resume tap made on the lock screen's mini player
  /// (MediaSession transport controls), if any.
  Future<bool> consumePendingToggleRequest() async {
    if (!_isSupported) {
      return false;
    }

    try {
      return await _channel.invokeMethod<bool>("consumePendingToggle") ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
