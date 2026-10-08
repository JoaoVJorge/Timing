import "package:equatable/equatable.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:get/get_utils/get_utils.dart";
import "package:timezone/timezone.dart" as tz;
import "package:timing/core/services/notifications/local_notifications_settings.dart";

/// One goal reminder as the system should hold it.
class GoalReminder extends Equatable {
  const GoalReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.fireAt,
    required this.repeatsDaily,
  });

  final int id;
  final String title;
  final String body;

  /// When it is shown, or first shown when it [repeatsDaily].
  final DateTime fireAt;

  /// Whether it comes back every day at the time of [fireAt].
  final bool repeatsDaily;

  @override
  List<Object?> get props => [id, title, body, fireAt, repeatsDaily];
}

/// The system side of goal reminders, kept apart from the rules that decide
/// which reminders should exist.
abstract class GoalReminderNotifications {
  /// Whether a single notification can start on a chosen day and repeat daily
  /// from there. Where it cannot, every day needs a notification of its own.
  bool get canRepeatFromAnyDay;

  /// Whether this device can show a reminder at all right now.
  Future<bool> canNotify();

  /// The reminders waiting to be shown.
  Future<Set<int>> scheduledIds();

  /// The reminders on screen right now.
  Future<Set<int>> shownIds();

  Future<void> schedule(GoalReminder reminder, {required String channelName});

  /// Drops the reminder, whether it is waiting or already on screen.
  Future<void> cancel(int id);
}

class LocalGoalReminderNotifications implements GoalReminderNotifications {
  static const String _channelId = "daily_goal_reminders";

  /// Tells goal reminders apart from the timer alarms that share the plugin.
  static const String _payload = "goal_reminder";

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get _isSupported => GetPlatform.isAndroid || GetPlatform.isIOS;

  /// Android starts a daily notification on the date it is given. iOS only
  /// matches the time of day, so a daily one could never skip today.
  @override
  bool get canRepeatFromAnyDay => GetPlatform.isAndroid;

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    await _plugin.initialize(settings: localNotificationsSettings);
    _initialized = true;
  }

  @override
  Future<bool> canNotify() async {
    if (!_isSupported) {
      return false;
    }
    await _ensureInitialized();
    if (GetPlatform.isIOS) {
      final NotificationsEnabledOptions? permissions = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.checkPermissions();
      return permissions?.isEnabled ?? false;
    }
    return await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled() ??
        false;
  }

  @override
  Future<Set<int>> scheduledIds() async {
    if (!_isSupported) {
      return const <int>{};
    }
    await _ensureInitialized();
    final List<PendingNotificationRequest> pending = await _plugin
        .pendingNotificationRequests();
    return {
      for (final PendingNotificationRequest request in pending)
        if (request.payload == _payload) request.id,
    };
  }

  @override
  Future<Set<int>> shownIds() async {
    if (!_isSupported) {
      return const <int>{};
    }
    await _ensureInitialized();
    final List<ActiveNotification> shown = await _plugin
        .getActiveNotifications();
    // Android reports the channel of a shown notification but not its payload,
    // and iOS the other way around.
    return {
      for (final ActiveNotification notification in shown)
        if (notification.id case final int id
            when notification.payload == _payload ||
                notification.channelId == _channelId)
          id,
    };
  }

  @override
  Future<void> schedule(
    GoalReminder reminder, {
    required String channelName,
  }) async {
    if (!_isSupported) {
      return;
    }
    // A reminder for a single day is of no use once its time has gone, and
    // the plugin refuses to schedule one in the past.
    if (!reminder.repeatsDaily && !reminder.fireAt.isAfter(DateTime.now())) {
      return;
    }
    await _ensureInitialized();
    final NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        icon: localNotificationIcon,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    // The app never learns the device's time zone name, so the reminder is
    // pinned to its UTC instant. A daily one repeats every 24 hours from
    // there, which only drifts across a clock change, and the next time the
    // app opens the reminder is scheduled again from the local time.
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      reminder.fireAt,
      tz.UTC,
    );

    Future<void> schedule(AndroidScheduleMode mode) => _plugin.zonedSchedule(
      id: reminder.id,
      title: reminder.title,
      body: reminder.body,
      payload: _payload,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: mode,
      matchDateTimeComponents: reminder.repeatsDaily
          ? DateTimeComponents.time
          : null,
    );

    try {
      await schedule(AndroidScheduleMode.exactAllowWhileIdle);
    } catch (_) {
      if (!GetPlatform.isAndroid) {
        rethrow;
      }
      // Exact alarms can be denied by the system; a reminder a few minutes
      // late is still better than none.
      await schedule(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  @override
  Future<void> cancel(int id) async {
    if (!_isSupported) {
      return;
    }
    await _ensureInitialized();
    await _plugin.cancel(id: id);
  }
}
