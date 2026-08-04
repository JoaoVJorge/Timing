import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:get/get_utils/get_utils.dart";
import "package:timezone/data/latest_all.dart" as tz;
import "package:timezone/timezone.dart" as tz;

/// Shows an ongoing, lockscreen-visible notification (media-player style)
/// with a live chronometer while a focus session is running.
class TimerNotificationService {
  static const int _notificationId = 1001;
  static const int _finishNotificationId = 1002;
  static const String _channelId = "focus_timer";
  static const String _channelName = "Focus timer";
  static const String _channelDescription =
      "Ongoing focus session shown on the lockscreen";
  static const String _finishChannelId = "focus_timer_finished_v2";
  static const String _finishChannelName = "Focus timer finished";
  static const String _finishChannelDescription =
      "Alerts when a focus section ends";
  static const String _finishSound = "finish_focus_alarm";

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
    tz.initializeTimeZones();
    await _plugin.initialize(settings: settings);
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
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
        notificationDetails: const NotificationDetails(android: androidDetails),
      );
    } catch (_) {
      // The timer must keep working even if notifications are unavailable.
    }
  }

  Future<void> scheduleFocusFinished({
    required String title,
    required String body,
    required Duration remaining,
  }) async {
    if (!_isSupported || remaining <= Duration.zero) {
      return;
    }

    try {
      await _ensureInitialized();
      await _plugin.cancel(id: _finishNotificationId);
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _finishChannelId,
            _finishChannelName,
            channelDescription: _finishChannelDescription,
            importance: Importance.max,
            priority: Priority.max,
            autoCancel: true,
            showWhen: true,
            visibility: NotificationVisibility.public,
            category: AndroidNotificationCategory.alarm,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(_finishSound),
            enableVibration: true,
            audioAttributesUsage: AudioAttributesUsage.alarm,
          );

      try {
        await _plugin.zonedSchedule(
          id: _finishNotificationId,
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.now(tz.local).add(remaining),
          notificationDetails: const NotificationDetails(
            android: androidDetails,
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } catch (_) {
        await _plugin.zonedSchedule(
          id: _finishNotificationId,
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.now(tz.local).add(remaining),
          notificationDetails: const NotificationDetails(
            android: androidDetails,
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (_) {
      // The timer must keep working even if notifications are unavailable.
    }
  }

  Future<void> cancelFocusFinished() async {
    if (!_isSupported || !_initialized) {
      return;
    }

    try {
      await _plugin.cancel(id: _finishNotificationId);
    } catch (_) {
      // Nothing to do if there is no scheduled notification to cancel.
    }
  }

  Future<void> cancel() async {
    if (!_isSupported || !_initialized) {
      return;
    }

    try {
      await Future.wait([
        _plugin.cancel(id: _notificationId),
        _plugin.cancel(id: _finishNotificationId),
      ]);
    } catch (_) {
      // Nothing to do if there is no notification to cancel.
    }
  }
}
