package com.moonstone.timing

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.media.MediaMetadata
import android.media.session.MediaSession
import android.media.session.PlaybackState
import android.os.Build
import android.os.IBinder

/// Keeps the native, user-visible focus indicator alive while a session runs
/// outside the app.
///
/// Without a real foreground service, that notification is just a flag
/// (`ongoing = true`) on a regular notification: it does not stop Android
/// from killing the process the moment the user swipes the app away from
/// Recents, since there is no component pinning the notification.
///
/// This service deliberately does not own a FlutterEngine. If Android destroys
/// the Activity and its Dart isolate, the durable timer checkpoint remains the
/// source of truth and the elapsed wall time is recovered on the next launch.
///
/// The ongoing notification is built with `Notification.MediaStyle` bound to a
/// `MediaSession`, which is what makes Android render it as an interactive
/// mini player on the lock screen (like a music app), with the pause/resume
/// action tappable without unlocking. The lock screen's dedicated media card
/// reads its title/art/elapsed-time from the MediaSession's metadata and
/// playback state — not from the notification's own chronometer — so both
/// are kept in sync here. A plain notification action, by contrast, is
/// generally hidden or requires unlocking on most OEMs. Because of this, this
/// service is now the sole owner of the ongoing notification —
/// TimerNotificationService (flutter_local_notifications) no longer posts to
/// the same id, since flutter_local_notifications has no MediaStyle support
/// and would otherwise clobber this richer presentation on every tick.
class TimerForegroundService : Service() {

    private var mediaSession: MediaSession? = null
    private var cachedTitle: String = ""
    private var cachedBody: String = ""
    private var cachedActionLabel: String = ""
    private var cachedIsRunning: Boolean = true
    private var cachedIsTicking: Boolean = false
    private var cachedElapsedSeconds: Int = 0
    private var cachedColor: Int = DEFAULT_COLOR

    override fun onCreate() {
        super.onCreate()
        val session = MediaSession(this, "TimerFocusSession")
        session.setCallback(object : MediaSession.Callback() {
            override fun onPause() = handleToggleFromLockScreen()
            override fun onPlay() = handleToggleFromLockScreen()
        })
        session.isActive = true
        mediaSession = session
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_TOGGLE_PAUSE) {
            handleToggleFromLockScreen()
            return START_NOT_STICKY
        }

        cachedTitle = intent?.getStringExtra(EXTRA_TITLE).orEmpty()
        cachedBody = intent?.getStringExtra(EXTRA_BODY).orEmpty()
        cachedActionLabel = intent?.getStringExtra(EXTRA_ACTION_LABEL).orEmpty()
        cachedIsRunning = intent?.getBooleanExtra(EXTRA_IS_RUNNING, true) ?: true
        cachedIsTicking = intent?.getBooleanExtra(EXTRA_IS_TICKING, false) ?: false
        cachedElapsedSeconds = intent?.getIntExtra(EXTRA_ELAPSED_SECONDS, 0) ?: 0
        cachedColor = intent
            ?.takeIf { it.hasExtra(EXTRA_COLOR) }
            ?.getIntExtra(EXTRA_COLOR, DEFAULT_COLOR)
            ?: DEFAULT_COLOR

        updateMediaSession()
        startForegroundCompat()
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        mediaSession?.isActive = false
        mediaSession?.release()
        mediaSession = null
        super.onDestroy()
    }

    /// A tap on the lock screen's mini player arrives here (via MediaSession's
    /// transport controls). It flips the cached playback state immediately so
    /// the icon responds without delay, then flags the request for Dart to
    /// consume and apply the real pause/resume side effects on its next poll.
    private fun handleToggleFromLockScreen() {
        pendingToggleRequested = true
        cachedIsRunning = !cachedIsRunning
        cachedIsTicking = cachedIsTicking && cachedIsRunning
        updateMediaSession()
        startForegroundCompat()
    }

    private fun updateMediaSession() {
        val session = mediaSession ?: return
        val positionMilliseconds = cachedElapsedSeconds.toLong() * 1000L
        val state = if (cachedIsRunning) PlaybackState.STATE_PLAYING else PlaybackState.STATE_PAUSED
        val speed = if (cachedIsTicking) 1f else 0f
        session.setPlaybackState(
            PlaybackState.Builder()
                .setActions(PlaybackState.ACTION_PLAY_PAUSE)
                .setState(state, positionMilliseconds, speed)
                .build()
        )
        session.setMetadata(
            MediaMetadata.Builder()
                .putString(MediaMetadata.METADATA_KEY_TITLE, cachedTitle)
                .putString(MediaMetadata.METADATA_KEY_ARTIST, cachedBody)
                .putBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART, buildArtBitmap())
                .build()
        )
    }

    /// A colored tile matching the activity's accent color, used as the lock
    /// screen mini player's "album art" so the card carries the activity's
    /// color and a recognizable glyph instead of a blank/generic icon.
    private fun buildArtBitmap(): Bitmap {
        val sizePx = dpToPx(96)
        val bitmap = Bitmap.createBitmap(sizePx, sizePx, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val backgroundPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = cachedColor }
        val cornerRadius = sizePx * 0.24f
        canvas.drawRoundRect(
            RectF(0f, 0f, sizePx.toFloat(), sizePx.toFloat()),
            cornerRadius,
            cornerRadius,
            backgroundPaint
        )

        val glyph = resources.getDrawable(R.drawable.ic_notification, theme).mutate()
        glyph.setTint(Color.WHITE)
        val inset = (sizePx * 0.28f).toInt()
        glyph.setBounds(inset, inset, sizePx - inset, sizePx - inset)
        glyph.draw(canvas)
        return bitmap
    }

    private fun dpToPx(value: Int): Int {
        val density = resources.displayMetrics.density
        return (value * density).toInt()
    }

    private fun startForegroundCompat() {
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

        val toggleIntent = Intent(this, TimerForegroundService::class.java)
            .setAction(ACTION_TOGGLE_PAUSE)
        val togglePendingIntent = PendingIntent.getService(
            this,
            0,
            toggleIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val toggleIcon = if (cachedIsRunning) R.drawable.ic_overlay_pause else R.drawable.ic_overlay_play

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        builder
            .setContentTitle(cachedTitle)
            .setContentText(cachedBody)
            .setSmallIcon(R.drawable.ic_notification)
            .setLargeIcon(buildArtBitmap())
            .setColor(cachedColor)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setCategory(Notification.CATEGORY_STOPWATCH)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setStyle(
                Notification.MediaStyle()
                    .setMediaSession(mediaSession?.sessionToken)
                    .setShowActionsInCompactView(0)
            )
            .addAction(
                Notification.Action.Builder(
                    android.graphics.drawable.Icon.createWithResource(this, toggleIcon),
                    cachedActionLabel,
                    togglePendingIntent
                ).build()
            )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // The colorized background (tinting the whole card with the
            // activity's color) is only available from API 26 onward.
            builder.setColorized(true)
        }
        if (cachedIsTicking) {
            val startedAtMilliseconds =
                System.currentTimeMillis() - cachedElapsedSeconds.toLong() * 1000L
            builder.setShowWhen(true).setWhen(startedAtMilliseconds).setUsesChronometer(true)
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
            NotificationManager.IMPORTANCE_DEFAULT
        )
        channel.description = "Ongoing focus session shown on the lockscreen"
        channel.setShowBadge(false)
        manager.createNotificationChannel(channel)
    }

    companion object {
        // Must match TimerNotificationService's channel/notification ids on the
        // Dart side so both sides update the same notification slot — the
        // importance must match too, since Android channels are immutable
        // once created and whichever side runs first otherwise locks it in.
        private const val CHANNEL_ID = "focus_timer_v2"
        private const val NOTIFICATION_ID = 1001
        private const val EXTRA_TITLE = "title"
        private const val EXTRA_BODY = "body"
        private const val EXTRA_ACTION_LABEL = "actionLabel"
        private const val EXTRA_IS_RUNNING = "isRunning"
        private const val EXTRA_IS_TICKING = "isTicking"
        private const val EXTRA_ELAPSED_SECONDS = "elapsedSeconds"
        private const val EXTRA_COLOR = "color"
        private const val ACTION_TOGGLE_PAUSE = "com.moonstone.timing.action.TOGGLE_PAUSE"
        private const val DEFAULT_COLOR = 0xFF5B8CFF.toInt()

        /// Set from the MediaSession callback when the user taps pause/resume
        /// on the lock screen mini player. Polled and reset from Dart, mirroring
        /// how TimerNotificationService surfaces its own pending toggle.
        @Volatile
        private var pendingToggleRequested: Boolean = false

        fun consumePendingToggleRequest(): Boolean {
            if (!pendingToggleRequested) {
                return false
            }
            pendingToggleRequested = false
            return true
        }

        fun start(
            context: Context,
            title: String,
            body: String,
            actionLabel: String,
            isRunning: Boolean,
            isTicking: Boolean,
            elapsedSeconds: Int,
            color: Int
        ) {
            val intent = Intent(context, TimerForegroundService::class.java)
            intent.putExtra(EXTRA_TITLE, title)
            intent.putExtra(EXTRA_BODY, body)
            intent.putExtra(EXTRA_ACTION_LABEL, actionLabel)
            intent.putExtra(EXTRA_IS_RUNNING, isRunning)
            intent.putExtra(EXTRA_IS_TICKING, isTicking)
            intent.putExtra(EXTRA_ELAPSED_SECONDS, elapsedSeconds)
            intent.putExtra(EXTRA_COLOR, color)
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
