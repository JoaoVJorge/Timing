package com.moonstone.timing

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder

/// Keeps the native, user-visible focus indicator alive while a session runs
/// outside the app.
///
/// Without a real foreground service, that notification is just a flag
/// (`ongoing = true`) on a regular notification: it does not stop Android
/// from killing the process the moment the user swipes the app away from
/// Recents, since there is no component pinning the native overlay.
///
/// This service deliberately does not own a FlutterEngine. If Android destroys
/// the Activity and its Dart isolate, the durable timer checkpoint remains the
/// source of truth and the elapsed wall time is recovered on the next launch.
///
/// It reuses the same notification channel/id that flutter_local_notifications
/// already posts to (see TimerNotificationService), so its own notification is
/// immediately replaced by the richer one (chronometer, actions, etc.) the next
/// time the Flutter side calls FlutterLocalNotificationsPlugin.show.
class TimerForegroundService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val title = intent?.getStringExtra(EXTRA_TITLE).orEmpty()
        val body = intent?.getStringExtra(EXTRA_BODY).orEmpty()
        val startedAtMilliseconds = intent
            ?.takeIf { it.hasExtra(EXTRA_STARTED_AT_MILLISECONDS) }
            ?.getLongExtra(EXTRA_STARTED_AT_MILLISECONDS, 0L)
        startForegroundCompat(title, body, startedAtMilliseconds)
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        super.onDestroy()
    }

    private fun startForegroundCompat(
        title: String,
        body: String,
        startedAtMilliseconds: Long?
    ) {
        ensureChannel()

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        launchIntent?.addFlags(
            Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_SINGLE_TOP
        )
        val contentIntent = launchIntent?.let {
            PendingIntent.getActivity(
                this,
                0,
                it,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
        }

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        builder
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(R.drawable.ic_notification)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setCategory(Notification.CATEGORY_STOPWATCH)
        if (startedAtMilliseconds != null) {
            builder
                .setShowWhen(true)
                .setWhen(startedAtMilliseconds)
                .setUsesChronometer(true)
        } else {
            builder.setShowWhen(false)
        }
        if (contentIntent != null) {
            builder.setContentIntent(contentIntent)
        }
        val notification: Notification = builder.build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(CHANNEL_ID) != null) {
            return
        }
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Focus timer",
            NotificationManager.IMPORTANCE_LOW
        )
        channel.description = "Ongoing focus session shown on the lockscreen"
        channel.setShowBadge(false)
        manager.createNotificationChannel(channel)
    }

    companion object {
        // Must match TimerNotificationService's channel/notification ids on the
        // Dart side so both sides update the same notification slot.
        private const val CHANNEL_ID = "focus_timer"
        private const val NOTIFICATION_ID = 1001
        private const val EXTRA_TITLE = "title"
        private const val EXTRA_BODY = "body"
        private const val EXTRA_STARTED_AT_MILLISECONDS = "startedAtMilliseconds"

        fun start(
            context: Context,
            title: String,
            body: String,
            startedAtMilliseconds: Long?
        ) {
            val intent = Intent(context, TimerForegroundService::class.java)
            intent.putExtra(EXTRA_TITLE, title)
            intent.putExtra(EXTRA_BODY, body)
            if (startedAtMilliseconds != null) {
                intent.putExtra(EXTRA_STARTED_AT_MILLISECONDS, startedAtMilliseconds)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, TimerForegroundService::class.java))
        }
    }
}
