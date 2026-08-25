import "dart:io";

import "package:flutter/services.dart";

class TimerLiveActivityAction {
  const TimerLiveActivityAction({
    required this.action,
    required this.isRunning,
    required this.isResting,
    required this.remainingSeconds,
  });

  final String action;
  final bool isRunning;
  final bool isResting;
  final int remainingSeconds;
}

/// Bridges the Flutter timer to the iOS Live Activity / Dynamic Island.
///
/// Every call is best-effort: an unavailable or disabled Live Activity must
/// never interrupt the focus session itself.
class TimerLiveActivityService {
  static const MethodChannel _channel = MethodChannel(
    "com.timing/timer_live_activity",
  );

  bool get _isSupported => Platform.isIOS;

  Future<void> startOrUpdate({
    required String subjectName,
    required int colorValue,
    required int remainingSeconds,
    required bool isRunning,
    required bool isResting,
    required bool isCountUp,
  }) async {
    if (!_isSupported) {
      return;
    }

    try {
      await _channel.invokeMethod<void>("startOrUpdate", {
        "subjectName": subjectName,
        "colorHex": (colorValue & 0xFFFFFF).toRadixString(16).padLeft(6, "0"),
        "remainingSeconds": remainingSeconds,
        "isRunning": isRunning,
        "isResting": isResting,
        "isCountUp": isCountUp,
      });
    } catch (_) {
      // iOS < 16.2, disabled activities, simulator and signing failures are
      // intentionally non-fatal for the timer.
    }
  }

  Future<TimerLiveActivityAction?> consumePendingAction() async {
    if (!_isSupported) {
      return null;
    }

    try {
      final Map<Object?, Object?>? value = await _channel
          .invokeMapMethod<Object?, Object?>("consumePendingAction");
      if (value == null) {
        return null;
      }
      return TimerLiveActivityAction(
        action: value["action"] as String,
        isRunning: value["isRunning"] as bool,
        isResting: value["isResting"] as bool,
        remainingSeconds: value["remainingSeconds"] as int,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> end() async {
    if (!_isSupported) {
      return;
    }
    try {
      await _channel.invokeMethod<void>("end");
    } catch (_) {
      // The activity may already have been ended from its own close button.
    }
  }
}
