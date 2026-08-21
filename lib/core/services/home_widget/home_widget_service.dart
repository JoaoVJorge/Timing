import "dart:io";

import "package:home_widget/home_widget.dart";

/// Pushes a lightweight snapshot of today's focus to the Android home-screen
/// widget. Everything is local: no network or external API is involved.
class HomeWidgetService {
  static const String _androidProvider = "FocusTodayWidgetProvider";
  static const String _focusTodayKey = "focus_today";
  static const String _goalsProgressKey = "goals_progress";

  bool get _isSupported => Platform.isAndroid;

  Future<void> updateFocusToday({
    required int focusSeconds,
    required int goalsDone,
    required int goalsTotal,
  }) async {
    if (!_isSupported) {
      return;
    }

    try {
      await HomeWidget.saveWidgetData<String>(
        _focusTodayKey,
        _formatDuration(focusSeconds),
      );
      await HomeWidget.saveWidgetData<String>(
        _goalsProgressKey,
        "Metas $goalsDone/$goalsTotal",
      );
      await HomeWidget.updateWidget(androidName: _androidProvider);
    } catch (_) {
      // The widget is a best-effort mirror; failures must never affect the app.
    }
  }

  String _formatDuration(int seconds) {
    final int totalMinutes = seconds ~/ 60;
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    if (hours <= 0) {
      return "$minutes min";
    }
    return "${hours}h ${minutes.toString().padLeft(2, "0")}m";
  }
}
