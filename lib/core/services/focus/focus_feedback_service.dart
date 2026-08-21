import "dart:async";

import "package:audioplayers/audioplayers.dart";
import "package:flutter/services.dart";

class FocusFeedbackService {
  FocusFeedbackService() {
    _player.setReleaseMode(ReleaseMode.stop);
    unawaited(_player.setAudioContext(_alarmAudioContext));
  }

  static const String finishAlarmAsset = "sounds/finish_focus_alarm.wav";

  static final AudioContext _alarmAudioContext = AudioContext(
    android: const AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: true,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.alarm,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const {AVAudioSessionOptions.mixWithOthers},
    ),
  );

  final AudioPlayer _player = AudioPlayer();

  Future<void> playFocusFinishedFeedback() async {
    unawaited(_vibrateThreeTimes());
    await _player.stop();
    await _player.setAudioContext(_alarmAudioContext);
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
