import "dart:io";

import "package:flutter/services.dart";

/// Drives a small floating pill (like the "your ride is on the way" chip in
/// ride-hailing apps) that hovers over other apps while a focus session runs.
///
/// Everything is local and native: no external API. The chip is only shown on
/// Android and only when the user granted the "draw over other apps"
/// permission. Every call is best-effort and never interrupts the timer.
class FocusOverlayService {
  static const MethodChannel _channel = MethodChannel("timing/focus_overlay");

  bool get _isSupported => Platform.isAndroid;

  Future<bool> hasPermission() async {
    if (!_isSupported) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>("hasPermission") ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> requestPermission() async {
    if (!_isSupported) {
      return;
    }
    await _invoke("requestPermission");
  }

  Future<void> show({
    required String subjectName,
    required int elapsedSeconds,
    required int sessionElapsedSeconds,
    required int intervalRemainingSeconds,
    required bool isRunning,
    required bool isResting,
    required bool usesFocusRoutine,
    required int colorValue,
    required int currentFocusSection,
    required int totalFocusSections,
    required int focusIntervalSeconds,
    required int restIntervalSeconds,
  }) async {
    await _invoke("show", <String, Object?>{
      "subjectName": subjectName,
      "elapsedSeconds": elapsedSeconds,
      "sessionElapsedSeconds": sessionElapsedSeconds,
      "intervalRemainingSeconds": intervalRemainingSeconds,
      "isRunning": isRunning,
      "isResting": isResting,
      "usesFocusRoutine": usesFocusRoutine,
      "currentFocusSection": currentFocusSection,
      "totalFocusSections": totalFocusSections,
      "focusIntervalSeconds": focusIntervalSeconds,
      "restIntervalSeconds": restIntervalSeconds,
      "colorHex": (colorValue & 0xFFFFFF).toRadixString(16).padLeft(6, "0"),
    });
  }

  Future<void> hide() async {
    await _invoke("hide");
  }

  Future<void> _invoke(String method, [Map<String, Object?>? arguments]) async {
    if (!_isSupported) {
      return;
    }
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }
}
