package com.moonstone.timing

import android.app.Notification
import android.app.KeyguardManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.BroadcastReceiver
import android.content.Intent
import android.content.IntentFilter
import android.content.res.ColorStateList
import android.content.pm.ServiceInfo
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.media.MediaMetadata
import android.media.session.MediaSession
import android.media.session.PlaybackState
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import java.util.Locale

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
/// playback state, kept in sync with the notification's own text below.
/// A plain notification action, by contrast, is
/// generally hidden or requires unlocking on most OEMs. Because of this, this
/// service is now the sole owner of the ongoing notification —
/// TimerNotificationService (flutter_local_notifications) no longer posts to
/// the same id, since flutter_local_notifications has no MediaStyle support
/// and would otherwise clobber this richer presentation on every tick.
///
/// The custom card's Chronometer views tick inside System UI on their own,
/// without reposting. The lock screen's media widget is not one of them: it
/// paints from the last *posted* Notification, not from MediaSession pushes
/// alone, so it stays frozen unless the notification is actually reposted.
/// A partial wake lock keeps that once-a-second repost loop running even
/// with the screen off, where Doze would otherwise stall it.
class TimerForegroundService : Service() {

    private var mediaSession: MediaSession? = null
    private var cachedTitle: String = ""
    private var cachedActionLabel: String = ""
    private var cachedIsRunning: Boolean = true
    private var cachedIsTicking: Boolean = false
    private var cachedTicksWhenRunning: Boolean = true
    private var cachedElapsedSeconds: Int = 0
    private var cachedTotalSeconds: Int = 0
    private var cachedCurrentSection: Int = 1
    private var cachedTotalSections: Int = 1
    private var cachedColor: Int = DEFAULT_COLOR
    private var cachedActivityIcon: Bitmap? = null
    private var cachedArtwork: Bitmap? = null
    private var hasSession: Boolean = false
    private var wakeLock: PowerManager.WakeLock? = null
    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (hasSession) refreshNotification()
        }
    }
    private var elapsedAnchorAtMilliseconds: Long = SystemClock.elapsedRealtime()
    private val tickHandler = Handler(Looper.getMainLooper())
    private var isTickScheduled = false
    private val tickRunnable = object : Runnable {
        override fun run() {
            updateMediaSession()
            // The lock screen's media widget is system-drawn from the last
            // *posted* Notification, not just from MediaSession pushes — it
            // does not repaint on setMetadata()/setPlaybackState() alone. A
            // real repost every second is what makes its elapsed time move;
            // our own Chronometer-based cards keep ticking natively in
            // between, so this doesn't reset or flicker them.
            refreshNotification()
            tickHandler.postDelayed(this, 1_000L)
        }
    }

    override fun onCreate() {
        super.onCreate()
        val screenEvents = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_USER_PRESENT)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(screenReceiver, screenEvents, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            registerReceiver(screenReceiver, screenEvents)
        }
        val session = MediaSession(this, "TimerFocusSession")
        session.setCallback(object : MediaSession.Callback() {
            override fun onPause() = handleToggleFromLockScreen()
            override fun onPlay() = handleToggleFromLockScreen()
        })
        session.isActive = true
        mediaSession = session
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "$packageName:timerTick"
        ).apply { setReferenceCounted(false) }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_TOGGLE_PAUSE) {
            handleToggleFromLockScreen()
            return START_NOT_STICKY
        }

        cachedTitle = intent?.getStringExtra(EXTRA_TITLE).orEmpty()
        cachedActionLabel = intent?.getStringExtra(EXTRA_ACTION_LABEL).orEmpty()
        cachedIsRunning = intent?.getBooleanExtra(EXTRA_IS_RUNNING, true) ?: true
        cachedIsTicking = intent?.getBooleanExtra(EXTRA_IS_TICKING, false) ?: false
        cachedTicksWhenRunning =
            intent?.getBooleanExtra(EXTRA_TICKS_WHEN_RUNNING, true) ?: true
        cachedElapsedSeconds = intent?.getIntExtra(EXTRA_ELAPSED_SECONDS, 0) ?: 0
        cachedTotalSeconds = intent?.getIntExtra(EXTRA_TOTAL_SECONDS, 0) ?: 0
        cachedCurrentSection = intent?.getIntExtra(EXTRA_CURRENT_SECTION, 1) ?: 1
        cachedTotalSections = intent?.getIntExtra(EXTRA_TOTAL_SECTIONS, 1) ?: 1
        elapsedAnchorAtMilliseconds =
            SystemClock.elapsedRealtime() - cachedElapsedSeconds.toLong() * 1_000L
        val previousColor = cachedColor
        cachedColor = intent
            ?.takeIf { it.hasExtra(EXTRA_COLOR) }
            ?.getIntExtra(EXTRA_COLOR, DEFAULT_COLOR)
            ?: DEFAULT_COLOR
        if (cachedColor != previousColor) {
            cachedArtwork = null
        }
        intent?.getByteArrayExtra(EXTRA_ACTIVITY_ICON)?.let { bytes ->
            cachedActivityIcon = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
        }

        hasSession = true
        updateMediaSession()
        startForegroundCompat()
        applyTickingState()
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        hasSession = false
        unregisterReceiver(screenReceiver)
        stopTicking()
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

    /// Starts or stops the once-a-second refresh loop to match
    /// [cachedIsTicking], instead of leaving a stale loop running (or a
    /// needed one stopped) after a play/pause/section change.
    private fun applyTickingState() {
        if (cachedIsTicking) {
            startTicking()
        } else {
            stopTicking()
        }
    }

    private fun startTicking() {
        // Without a wake lock, Doze can suspend this Handler loop once the
        // screen locks, so the lock screen media card's time text stops
        // advancing even though the foreground service is still alive.
        wakeLock?.acquire(WAKE_LOCK_TIMEOUT_MS)
        if (isTickScheduled) {
            return
        }
        isTickScheduled = true
        tickHandler.postDelayed(tickRunnable, 1_000L)
    }

    private fun stopTicking() {
        isTickScheduled = false
        tickHandler.removeCallbacks(tickRunnable)
        wakeLock?.let { if (it.isHeld) it.release() }
    }

    private fun refreshNotification() {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(NOTIFICATION_ID, buildNotification())
    }

    /// A tap on the lock screen's mini player arrives here (via MediaSession's
    /// transport controls). It flips the cached playback state immediately so
    /// the icon responds without delay, then flags the request for Dart to
    /// consume and apply the real pause/resume side effects on its next poll.
    private fun handleToggleFromLockScreen() {
        pendingToggleRequested = true
        if (cachedIsTicking) {
            cachedElapsedSeconds = liveElapsedSeconds()
        }
        cachedIsRunning = !cachedIsRunning
        cachedIsTicking = cachedIsRunning && cachedTicksWhenRunning
        elapsedAnchorAtMilliseconds =
            SystemClock.elapsedRealtime() - cachedElapsedSeconds.toLong() * 1_000L
        updateMediaSession()
        startForegroundCompat()
        applyTickingState()
    }

    private fun liveElapsedSeconds(): Int {
        if (!cachedIsTicking) {
            return cachedElapsedSeconds
        }
        return ((SystemClock.elapsedRealtime() - elapsedAnchorAtMilliseconds) / 1_000L)
            .toInt()
            .coerceAtLeast(0)
    }

    private fun formatElapsed(totalSeconds: Int): String {
        val hours = totalSeconds / 3_600
        val minutes = (totalSeconds % 3_600) / 60
        val seconds = totalSeconds % 60
        return if (hours > 0) {
            String.format("%d:%02d:%02d", hours, minutes, seconds)
        } else {
            String.format("%02d:%02d", minutes, seconds)
        }
    }

    private fun updateMediaSession() {
        val session = mediaSession ?: return
        val elapsedSeconds = liveElapsedSeconds()
        val positionMilliseconds = elapsedSeconds.toLong() * 1_000L
        val state = if (cachedIsRunning) PlaybackState.STATE_PLAYING else PlaybackState.STATE_PAUSED
        val speed = if (cachedIsTicking) 1f else 0f
        session.setPlaybackState(
            PlaybackState.Builder()
                .setActions(PlaybackState.ACTION_PLAY_PAUSE)
                .setState(state, positionMilliseconds, speed, SystemClock.elapsedRealtime())
                .build()
        )
        updateMediaMetadata(elapsedSeconds)
    }

    private fun updateMediaMetadata(elapsedSeconds: Int) {
        val session = mediaSession ?: return
        val timeLabel = formatElapsed(elapsedSeconds)
        val metadata = MediaMetadata.Builder()
            .putString(MediaMetadata.METADATA_KEY_TITLE, cachedTitle)
            .putString(MediaMetadata.METADATA_KEY_DISPLAY_TITLE, cachedTitle)
            .putString(MediaMetadata.METADATA_KEY_ARTIST, timeLabel)
            .putString(MediaMetadata.METADATA_KEY_DISPLAY_SUBTITLE, timeLabel)
            .putString(MediaMetadata.METADATA_KEY_ALBUM, phaseLabel())
            .putString(MediaMetadata.METADATA_KEY_DISPLAY_DESCRIPTION,
                "${phaseLabel()} • ${sessionLabel()}")
            .putBitmap(MediaMetadata.METADATA_KEY_DISPLAY_ICON, buildActivityArtwork())
        // Keep the real target; the custom chronometers continue into overtime.
        if (cachedTotalSeconds > 0) {
            metadata.putLong(
                MediaMetadata.METADATA_KEY_DURATION,
                cachedTotalSeconds.toLong() * 1_000L
            )
        }
        session.setMetadata(metadata.build())
    }

    private fun sessionLabel(): String = getString(
        R.string.timer_notification_session, cachedCurrentSection, cachedTotalSections)

    private fun remainingLabel(elapsedSeconds: Int): String = when {
        !cachedIsRunning -> getString(R.string.timer_notification_paused)
        cachedTotalSeconds <= 0 -> ""
        elapsedSeconds > cachedTotalSeconds -> getString(
            R.string.timer_notification_overtime, formatElapsed(elapsedSeconds - cachedTotalSeconds))
        else -> getString(R.string.timer_notification_remaining,
            formatElapsed(cachedTotalSeconds - elapsedSeconds))
    }

    private fun phaseLabel(): String = getString(
        if (cachedTicksWhenRunning) R.string.timer_notification_focus
        else R.string.timer_notification_rest
    )

    private fun toggleLabel(): String = getString(
        if (cachedIsRunning) R.string.timer_notification_pause
        else R.string.timer_notification_resume
    )

    private fun darken(color: Int, factor: Float = 0.55f): Int = Color.rgb(
        (Color.red(color) * factor).toInt().coerceIn(0, 255),
        (Color.green(color) * factor).toInt().coerceIn(0, 255),
        (Color.blue(color) * factor).toInt().coerceIn(0, 255)
    )

    private fun lighten(color: Int, amount: Float = 0.32f): Int = Color.rgb(
        (Color.red(color) + (255 - Color.red(color)) * amount).toInt().coerceIn(0, 255),
        (Color.green(color) + (255 - Color.green(color)) * amount).toInt().coerceIn(0, 255),
        (Color.blue(color) + (255 - Color.blue(color)) * amount).toInt().coerceIn(0, 255)
    )

    private fun readableForeground(color: Int): Int {
        val luminance = (0.299 * Color.red(color) +
            0.587 * Color.green(color) + 0.114 * Color.blue(color)) / 255.0
        return if (luminance > 0.62) 0xFF1F231E.toInt() else Color.WHITE
    }

    private fun tintBackground(views: RemoteViews, viewId: Int, color: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            views.setColorStateList(
                viewId,
                "setBackgroundTintList",
                ColorStateList.valueOf(color)
            )
        } else {
            views.setInt(viewId, "setBackgroundColor", color)
        }
    }

    private fun tintProgress(views: RemoteViews, color: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            views.setColorStateList(
                R.id.timer_progress,
                "setProgressTintList",
                ColorStateList.valueOf(lighten(color))
            )
            views.setColorStateList(
                R.id.timer_progress,
                "setProgressBackgroundTintList",
                ColorStateList.valueOf(darken(color, 0.72f))
            )
        }
    }

    /// A flat, glyph-free swatch of the activity color. System/OEM surfaces
    /// (Samsung's Now Bar, the lock screen media art) derive their own
    /// background from this bitmap, so it must stay a solid fill — drawing an
    /// icon into it is what previously reappeared as an oversized watermark
    /// once those surfaces blew the art up to fill their background.
    private fun buildActivityArtwork(): Bitmap {
        cachedArtwork?.let { return it }
        val size = (96 * resources.displayMetrics.density).toInt()
        val artwork = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        artwork.eraseColor(darken(cachedColor))
        cachedArtwork = artwork
        return artwork
    }

    private fun timerContent(
        expanded: Boolean,
        toggleIntent: PendingIntent,
        elapsedSeconds: Int
    ): RemoteViews {
        val views = RemoteViews(packageName, if (expanded) {
            R.layout.notification_timer_expanded
        } else {
            R.layout.notification_timer_compact
        })
        val elapsed = formatElapsed(elapsedSeconds)
        val total = formatElapsed(cachedTotalSeconds)
        val hasTarget = cachedTotalSeconds > 0
        val foreground = readableForeground(cachedColor)
        tintBackground(views, R.id.timer_card, if (expanded) cachedColor else darken(cachedColor))
        tintProgress(views, cachedColor)
        views.setProgressBar(
            R.id.timer_progress,
            cachedTotalSeconds.coerceAtLeast(1),
            elapsedSeconds.coerceIn(0, cachedTotalSeconds.coerceAtLeast(1)),
            false
        )
        views.setViewVisibility(R.id.timer_progress, if (hasTarget) View.VISIBLE else View.GONE)
        views.setImageViewResource(R.id.timer_toggle,
            if (cachedIsRunning) R.drawable.ic_overlay_pause else R.drawable.ic_overlay_play)
        views.setContentDescription(R.id.timer_toggle, toggleLabel())
        views.setOnClickPendingIntent(R.id.timer_toggle, toggleIntent)
        if (expanded) {
            tintBackground(views, R.id.timer_session, darken(cachedColor, 0.68f))
            tintBackground(views, R.id.timer_toggle, darken(cachedColor, 0.62f))
            views.setTextColor(R.id.timer_header, foreground)
            views.setTextColor(R.id.timer_title, foreground)
            views.setTextColor(R.id.timer_session, foreground)
            views.setTextColor(R.id.timer_elapsed, foreground)
            views.setTextColor(R.id.timer_total, foreground)
            views.setTextColor(R.id.timer_remaining, foreground)
            views.setInt(R.id.timer_toggle, "setColorFilter", foreground)
            views.setTextViewText(R.id.timer_header,
                getString(R.string.timer_notification_header, phaseLabel().uppercase(Locale.getDefault())))
            views.setTextViewText(R.id.timer_title, cachedTitle)
            views.setTextViewText(R.id.timer_session, sessionLabel())
            bindElapsedClock(views, R.id.timer_elapsed, elapsedSeconds, null)
            views.setTextViewText(R.id.timer_total, getString(R.string.timer_notification_total, total))
            views.setViewVisibility(R.id.timer_total, if (hasTarget) View.VISIBLE else View.GONE)
            val remainingFormat = getString(
                if (elapsedSeconds > cachedTotalSeconds) R.string.timer_notification_overtime
                else R.string.timer_notification_remaining, "%s")
            val targetBase = elapsedAnchorAtMilliseconds + cachedTotalSeconds.toLong() * 1_000L
            views.setChronometerCountDown(R.id.timer_remaining, elapsedSeconds <= cachedTotalSeconds)
            views.setChronometer(R.id.timer_remaining, targetBase, remainingFormat,
                cachedIsTicking && hasTarget)
            if (!cachedIsTicking || !hasTarget) {
                views.setTextViewText(R.id.timer_remaining, remainingLabel(elapsedSeconds))
            }
        } else {
            tintBackground(views, R.id.timer_icon_circle, cachedColor)
            cachedActivityIcon?.let {
                views.setImageViewBitmap(R.id.timer_activity_icon, it)
            }
            views.setInt(R.id.timer_activity_icon, "setColorFilter", Color.WHITE)
            views.setTextColor(R.id.timer_phase, foreground)
            views.setTextColor(R.id.timer_time, foreground)
            views.setInt(R.id.timer_toggle, "setColorFilter", foreground)
            views.setTextViewText(R.id.timer_phase, if (cachedIsRunning) phaseLabel()
                else getString(R.string.timer_notification_paused))
            bindElapsedClock(views, R.id.timer_time, elapsedSeconds,
                if (hasTarget) "%s / $total" else null)
        }
        return views
    }

    private fun bindElapsedClock(views: RemoteViews, id: Int, seconds: Int, format: String?) {
        views.setChronometer(id, elapsedAnchorAtMilliseconds, format, cachedIsTicking)
        if (!cachedIsTicking) {
            val elapsed = formatElapsed(seconds)
            views.setTextViewText(id, format?.replace("%s", elapsed) ?: elapsed)
        }
    }

    private fun startForegroundCompat() {
        ensureChannel()
        val notification = buildNotification()

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

    private fun buildNotification(): Notification {
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
        // Text is a fallback snapshot. Custom views tick locally in System UI.
        val elapsedSeconds = liveElapsedSeconds()
        val elapsedLabel = formatElapsed(elapsedSeconds)
        val contentText = if (cachedTotalSeconds > 0) {
            "$elapsedLabel / ${formatElapsed(cachedTotalSeconds)}"
        } else {
            elapsedLabel
        }
        val subText = sessionLabel()
        builder
            .setContentTitle(cachedTitle)
            .setContentText(contentText)
            .setSubText(subText)
            .setSmallIcon(R.drawable.ic_notification)
            .setLargeIcon(buildActivityArtwork())
            .setColor(cachedColor)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setCategory(Notification.CATEGORY_STOPWATCH)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setStyle((if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                Notification.DecoratedMediaCustomViewStyle()
            } else Notification.MediaStyle())
                .setMediaSession(mediaSession?.sessionToken)
                .setShowActionsInCompactView(0))
            .addAction(
                Notification.Action.Builder(
                    android.graphics.drawable.Icon.createWithResource(this, toggleIcon),
                    toggleLabel(),
                    togglePendingIntent
                ).build()
            )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Media/Now Bar surfaces that ignore the custom RemoteViews use
            // this color for their own background.
            builder.setColorized(true)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            // OEM Now Bar/media players may render their own surface from the
            // MediaSession. These layouts cover the notification surfaces that
            // accept custom content. Use the compact layout while locked, even
            // when the system requests the expanded notification presentation.
            val compact = timerContent(false, togglePendingIntent, elapsedSeconds)
            val locked = (getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager).isKeyguardLocked
            val expanded = if (locked) compact else timerContent(true, togglePendingIntent, elapsedSeconds)
            builder.setCustomContentView(compact)
                .setCustomBigContentView(expanded)
                // Heads-up slots can be limited to 88dp. The full card belongs
                // in the expanded notification / Samsung live-activity surface.
                .setCustomHeadsUpContentView(compact)
            if (Build.MANUFACTURER.equals("samsung", ignoreCase = true)) {
                // Best-effort One UI extension, gated by Samsung's own app
                // eligibility. Standard RemoteViews alone do not configure Now Bar.
                // https://akexorcist.dev/live-notifications-and-now-bar-in-samsung-one-ui-7-as-developer-en/
                builder.addExtras(Bundle().apply {
                    putInt("android.ongoingActivityNoti.style", 1)
                    putString("android.ongoingActivityNoti.primaryInfo", cachedTitle)
                    putString("android.ongoingActivityNoti.secondaryInfo", "$contentText • ${sessionLabel()}")
                    putString("android.ongoingActivityNoti.chipExpandedText", elapsedLabel)
                    putInt("android.ongoingActivityNoti.chipBgColor", cachedColor)
                    putParcelable("android.ongoingActivityNoti.chronometerRemoteView", expanded)
                    putInt("android.ongoingActivityNoti.chronometerRemoteViewPosition", 1)
                    putString("android.ongoingActivityNoti.chronometerRemoteViewTag", "timing_timer")
                    putInt("android.ongoingActivityNoti.nowbarChronometerPosition", 1)
                    putString("android.ongoingActivityNoti.nowbarPrimaryInfo", cachedTitle)
                    putString("android.ongoingActivityNoti.nowbarSecondaryInfo", contentText)
                    putInt("android.ongoingActivityNoti.actionType", 1)
                    putInt("android.ongoingActivityNoti.actionPrimarySet", 0)
                })
            }
        }
        // OEM surfaces that ignore custom RemoteViews still receive a native,
        // interpolated chronometer. System UI advances it without reposting.
        if (cachedIsTicking) {
            val startedAtWallTime =
                System.currentTimeMillis() - elapsedSeconds.toLong() * 1_000L
            builder.setShowWhen(true)
                .setWhen(startedAtWallTime)
                .setUsesChronometer(true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                builder.setChronometerCountDown(false)
            }
        } else {
            builder.setShowWhen(false).setUsesChronometer(false)
        }
        if (contentIntent != null) {
            builder.setContentIntent(contentIntent)
        }
        return builder.build()
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
        private const val EXTRA_ACTION_LABEL = "actionLabel"
        private const val EXTRA_IS_RUNNING = "isRunning"
        private const val EXTRA_IS_TICKING = "isTicking"
        private const val EXTRA_TICKS_WHEN_RUNNING = "ticksWhenRunning"
        private const val EXTRA_ELAPSED_SECONDS = "elapsedSeconds"
        private const val EXTRA_TOTAL_SECONDS = "totalSeconds"
        private const val EXTRA_CURRENT_SECTION = "currentSection"
        private const val EXTRA_TOTAL_SECTIONS = "totalSections"
        private const val EXTRA_COLOR = "color"
        private const val EXTRA_ACTIVITY_ICON = "activityIcon"
        private const val ACTION_TOGGLE_PAUSE = "com.moonstone.timing.action.TOGGLE_PAUSE"
        private const val DEFAULT_COLOR = 0xFF5B8CFF.toInt()
        // Safety net so a missed release (e.g. a crash mid-session) can't pin
        // the wake lock forever; startTicking() renews it long before this.
        private const val WAKE_LOCK_TIMEOUT_MS = 6 * 60 * 60 * 1_000L

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
            actionLabel: String,
            isRunning: Boolean,
            isTicking: Boolean,
            ticksWhenRunning: Boolean,
            elapsedSeconds: Int,
            totalSeconds: Int,
            currentSection: Int,
            totalSections: Int,
            color: Int,
            activityIcon: ByteArray?
        ) {
            val intent = Intent(context, TimerForegroundService::class.java)
            intent.putExtra(EXTRA_TITLE, title)
            intent.putExtra(EXTRA_ACTION_LABEL, actionLabel)
            intent.putExtra(EXTRA_IS_RUNNING, isRunning)
            intent.putExtra(EXTRA_IS_TICKING, isTicking)
            intent.putExtra(EXTRA_TICKS_WHEN_RUNNING, ticksWhenRunning)
            intent.putExtra(EXTRA_ELAPSED_SECONDS, elapsedSeconds)
            intent.putExtra(EXTRA_TOTAL_SECONDS, totalSeconds)
            intent.putExtra(EXTRA_CURRENT_SECTION, currentSection)
            intent.putExtra(EXTRA_TOTAL_SECTIONS, totalSections)
            intent.putExtra(EXTRA_COLOR, color)
            intent.putExtra(EXTRA_ACTIVITY_ICON, activityIcon)
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
