import "dart:typed_data";

import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:get/get_utils/get_utils.dart";
import "package:timezone/data/latest_all.dart" as tz;
import "package:timezone/timezone.dart" as tz;

/// Shows an ongoing, lockscreen-visible notification (media-player style)
/// with a live chronometer while a focus session is running.
class TimerNotificationService {
  static const int _notificationId = 1001;
  static const int _focusFinishedNotificationId = 1002;
  static const int _restFinishedNotificationId = 1003;
  static const int _timelineNotificationIdBase = 1100;
  static const int _maxTimelineAlarms = 64;
  static const String _channelId = "focus_timer";
  static const String _channelName = "Focus timer";
  static const String _channelDescription =
      "Ongoing focus session shown on the lockscreen";
  static const String _finishChannelId = "focus_timer_finished_v3";
  static const String _finishChannelName = "Focus timer finished";
  static const String _finishChannelDescription =
      "Alerts when a focus section ends";
  static const String _finishSound = "finish_focus_alarm";
  static const String _notificationIcon = "ic_notification";
  static final Int64List _alarmVibrationPattern = Int64List.fromList(<int>[
    0,
    600,
    300,
    600,
    300,
    600,
    300,
    600,
  ]);

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get _isSupported => GetPlatform.isAndroid;

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings(_notificationIcon),
    );
    tz.initializeTimeZones();
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  Future<bool> areNotificationsEnabled() async {
    if (!_isSupported) {
      return false;
    }

    try {
      await _ensureInitialized();
      return await _androidPlugin?.areNotificationsEnabled() ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestNotificationsEnabled() async {
    if (!_isSupported) {
      return false;
    }

    try {
      await _ensureInitialized();
      final bool allowed =
          await _androidPlugin?.requestNotificationsPermission() ?? false;
      if (allowed) {
        await _androidPlugin?.requestExactAlarmsPermission();
        await _androidPlugin?.requestFullScreenIntentPermission();
      }
      return allowed;
    } catch (_) {
      return false;
    }
  }

  Future<void> disableNotifications() async {
    if (!_isSupported) {
      return;
    }

    try {
      await _ensureInitialized();
      await Future.wait([
        _plugin.cancelAll(),
        _plugin.cancelAllPendingNotifications(),
      ]);
    } catch (_) {
      // Nothing to do if the platform notification backend is unavailable.
    }
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
      if (!await areNotificationsEnabled()) {
        return;
      }
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
            icon: _notificationIcon,
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
      if (!await areNotificationsEnabled()) {
        return;
      }
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
            icon: _notificationIcon,
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
  }) => _scheduleAlarm(
    id: _focusFinishedNotificationId,
    title: title,
    body: body,
    remaining: remaining,
  );

  Future<void> scheduleRestFinished({
    required String title,
    required String body,
    required Duration remaining,
  }) => _scheduleAlarm(
    id: _restFinishedNotificationId,
    title: title,
    body: body,
    remaining: remaining,
  );

  /// Schedules every remaining focus/rest boundary up front. Android can then
  /// deliver the alarms even if the Flutter engine is suspended or the app
  /// process is reclaimed while it is in the background.
  Future<void> scheduleSessionTimeline({
    required String title,
    required String focusFinishedBody,
    required String restFinishedBody,
    required String sessionFinishedBody,
    required Duration focusRemaining,
    required Duration restRemaining,
    required Duration focusInterval,
    required Duration restInterval,
    required int remainingFocusSections,
    required bool isResting,
  }) async {
    if (!_isSupported || remainingFocusSections <= 0) {
      return;
    }

    await cancelTimelineAlarms();
    Duration offset = Duration.zero;
    int alarmIndex = 0;

    Future<void> addAlarm(String body) async {
      if (alarmIndex >= _maxTimelineAlarms || offset <= Duration.zero) {
        return;
      }
      await _scheduleAlarm(
        id: _timelineNotificationIdBase + alarmIndex,
        title: title,
        body: body,
        remaining: offset,
      );
      alarmIndex++;
    }

    if (isResting) {
      offset += restRemaining;
      await addAlarm(restFinishedBody);
    }

    for (int section = 0; section < remainingFocusSections; section++) {
      offset += !isResting && section == 0 ? focusRemaining : focusInterval;
      final bool isLastSection = section == remainingFocusSections - 1;
      await addAlarm(isLastSection ? sessionFinishedBody : focusFinishedBody);
      if (!isLastSection) {
        offset += restInterval;
        await addAlarm(restFinishedBody);
      }
    }
  }

  Future<void> _scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required Duration remaining,
  }) async {
    if (!_isSupported || remaining <= Duration.zero) {
      return;
    }

    try {
      await _ensureInitialized();
      if (!await areNotificationsEnabled()) {
        return;
      }
      await _plugin.cancel(id: id);
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _finishChannelId,
            _finishChannelName,
            channelDescription: _finishChannelDescription,
            importance: Importance.max,
            priority: Priority.max,
            autoCancel: true,
            showWhen: true,
            fullScreenIntent: true,
            visibility: NotificationVisibility.public,
            category: AndroidNotificationCategory.alarm,
            icon: _notificationIcon,
            playSound: true,
            sound: const RawResourceAndroidNotificationSound(_finishSound),
            enableVibration: true,
            vibrationPattern: _alarmVibrationPattern,
            audioAttributesUsage: AudioAttributesUsage.alarm,
          );
      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
      );

      try {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.now(tz.local).add(remaining),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } catch (_) {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.now(tz.local).add(remaining),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (_) {
      // The timer must keep working even if notifications are unavailable.
    }
  }

  Future<void> cancelFocusFinished() async {
    await _cancelAlarm(_focusFinishedNotificationId);
  }

  Future<void> cancelRestFinished() async {
    await _cancelAlarm(_restFinishedNotificationId);
  }

  Future<void> cancelScheduledAlarms() async {
    if (!_isSupported || !_initialized) {
      return;
    }

    try {
      await Future.wait(<Future<void>>[
        _plugin.cancel(id: _focusFinishedNotificationId),
        _plugin.cancel(id: _restFinishedNotificationId),
        ...List<Future<void>>.generate(
          _maxTimelineAlarms,
          (int index) =>
              _plugin.cancel(id: _timelineNotificationIdBase + index),
        ),
      ]);
    } catch (_) {
      // Nothing to do if there is no scheduled notification to cancel.
    }
  }

  Future<void> cancelTimelineAlarms() async {
    if (!_isSupported || !_initialized) {
      return;
    }
    try {
      await Future.wait(
        List<Future<void>>.generate(
          _maxTimelineAlarms,
          (int index) =>
              _plugin.cancel(id: _timelineNotificationIdBase + index),
        ),
      );
    } catch (_) {
      // Nothing to do if there is no timeline alarm to cancel.
    }
  }

  Future<void> cancelOngoing() async {
    if (!_isSupported || !_initialized) {
      return;
    }
    try {
      await _plugin.cancel(id: _notificationId);
    } catch (_) {
      // Nothing to do if there is no ongoing notification to cancel.
    }
  }

  Future<void> _cancelAlarm(int id) async {
    if (!_isSupported || !_initialized) {
      return;
    }

    try {
      await _plugin.cancel(id: id);
    } catch (_) {
      // Nothing to do if there is no scheduled notification to cancel.
    }
  }

  Future<void> cancel() async {
    if (!_isSupported || !_initialized) {
      return;
    }

    try {
      await cancelOngoing();
      await cancelScheduledAlarms();
    } catch (_) {
      // Nothing to do if there is no notification to cancel.
    }
  }
}
