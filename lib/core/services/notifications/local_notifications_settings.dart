import "package:flutter_local_notifications/flutter_local_notifications.dart";

const String localNotificationIcon = "ic_notification";

/// The notifications plugin is one instance shared by every service that uses
/// it, so they all have to initialize it the same way.
const InitializationSettings localNotificationsSettings =
    InitializationSettings(
      android: AndroidInitializationSettings(localNotificationIcon),
      // iOS asks only once, so the prompt waits until the user turns
      // notifications on instead of appearing when the app starts.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
