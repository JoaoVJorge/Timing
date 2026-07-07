import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:get/get_utils/get_utils.dart";

/// Shows an ongoing, lockscreen-visible notification (media-player style)
/// with a live chronometer while a focus session is running.
class TimerNotificationService {
  static const int _notificationId = 1001;
  static const String _channelId = "focus_timer";
  static const String _channelName = "Focus timer";
  static const String _channelDescription =
      "Ongoing focus session shown on the lockscreen";

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get _isSupported => GetPlatform.isAndroid;

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    );
    await _plugin.initialize(settings: settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  Future<void> showRunning({
    required String title,
    required String body,
    required DateTime startedAt,
  }) async {
    if (!_isSupported) {
      return;
    }

    try {
      await _ensureInitialized();
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
            showWhen: true,
            usesChronometer: true,
            when: startedAt.millisecondsSinceEpoch,
            visibility: NotificationVisibility.public,
            category: AndroidNotificationCategory.stopwatch,
            onlyAlertOnce: true,
            playSound: false,
            enableVibration: false,
          );
      await _plugin.show(
        id: _notificationId,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(android: androidDetails),
      );
    } catch (_) {
      // The timer must keep working even if notifications are unavailable.
    }
  }

  Future<void> showStatic({required String title, required String body}) async {
    if (!_isSupported) {
      return;
    }

    try {
      await _ensureInitialized();
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
            showWhen: false,
            visibility: NotificationVisibility.public,
            category: AndroidNotificationCategory.stopwatch,
            onlyAlertOnce: true,
            playSound: false,
            enableVibration: false,
          );
      await _plugin.show(
        id: _notificationId,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: androidDetails,
        ),
      );
    } catch (_) {
      // The timer must keep working even if notifications are unavailable.
    }
  }

  Future<void> cancel() async {
    if (!_isSupported || !_initialized) {
      return;
    }

    try {
      await _plugin.cancel(id: _notificationId);
    } catch (_) {
      // Nothing to do if there is no notification to cancel.
    }
  }
}
