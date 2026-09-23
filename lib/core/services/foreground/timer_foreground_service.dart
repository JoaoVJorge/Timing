import "dart:math" as math;
import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:get/get_utils/get_utils.dart";
import "package:timing/theme/subject_icons.dart";

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

  static final Map<String, Future<Uint8List?>> _iconCache =
      <String, Future<Uint8List?>>{};

  Future<void> start({
    required String title,
    required String actionLabel,
    required bool isRunning,
    required bool isTicking,
    required bool ticksWhenRunning,
    required int elapsedSeconds,
    required int totalSeconds,
    required int currentSection,
    required int totalSections,
    required int colorValue,
    required String iconName,
  }) async {
    if (!_isSupported) {
      return;
    }

    try {
      final Uint8List? activityIcon = await _iconCache.putIfAbsent(
        iconName,
        () => _renderActivityIcon(iconName),
      );
      await _channel.invokeMethod<void>("start", <String, Object?>{
        "title": title,
        "actionLabel": actionLabel,
        "isRunning": isRunning,
        "isTicking": isTicking,
        "ticksWhenRunning": ticksWhenRunning,
        "elapsedSeconds": elapsedSeconds,
        "totalSeconds": totalSeconds,
        "currentSection": currentSection,
        "totalSections": totalSections,
        "colorHex": (colorValue & 0xFFFFFF).toRadixString(16).padLeft(6, "0"),
        "activityIcon": activityIcon,
      });
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  static Future<Uint8List?> _renderActivityIcon(String iconName) async {
    const int size = 96;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final IconData? materialIcon = SubjectIcons.byName(iconName);

    try {
      if (materialIcon != null) {
        final TextPainter painter = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(materialIcon.codePoint),
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.72,
              fontFamily: materialIcon.fontFamily,
              package: materialIcon.fontPackage,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        painter.paint(
          canvas,
          Offset((size - painter.width) / 2, (size - painter.height) / 2),
        );
      } else {
        final PictureInfo info = await vg.loadPicture(
          SvgAssetLoader("assets/icons/$iconName.svg"),
          null,
        );
        final double scale =
            (size * 0.72) / math.max(info.size.width, info.size.height);
        final double dx = (size - info.size.width * scale) / 2;
        final double dy = (size - info.size.height * scale) / 2;
        canvas.saveLayer(
          Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
          Paint()
            ..colorFilter = const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
        );
        canvas.translate(dx, dy);
        canvas.scale(scale);
        canvas.drawPicture(info.picture);
        canvas.restore();
        info.picture.dispose();
      }

      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(size, size);
      picture.dispose();
      final ByteData? bytes = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      image.dispose();
      return bytes?.buffer.asUint8List();
    } catch (_) {
      return null;
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
      return await _channel.invokeMethod<bool>("consumePendingToggle") ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
