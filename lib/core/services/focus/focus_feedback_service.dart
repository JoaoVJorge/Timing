import "dart:async";

import "package:audioplayers/audioplayers.dart";
import "package:flutter/services.dart";

class FocusFeedbackService {
  FocusFeedbackService() {
    _player.setReleaseMode(ReleaseMode.stop);
  }

  static const String finishAlarmAsset = "sounds/finish_focus_alarm.wav";

  final AudioPlayer _player = AudioPlayer();

  Future<void> playFocusFinishedFeedback() async {
    unawaited(_vibrateThreeTimes());
    await _player.stop();
    await _player.play(AssetSource(finishAlarmAsset));
  }

  Future<void> warnFocusLock() async {
    await HapticFeedback.heavyImpact();
  }

  Future<void> _vibrateThreeTimes() async {
    for (int index = 0; index < 3; index++) {
      await HapticFeedback.vibrate();
      if (index < 2) {
        await Future<void>.delayed(const Duration(milliseconds: 220));
      }
    }
  }

  Future<void> dispose() => _player.dispose();
}
