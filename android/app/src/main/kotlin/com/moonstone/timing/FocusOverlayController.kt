package com.moonstone.timing

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import kotlin.math.abs

/// A floating pill drawn over other apps while a focus session runs.
///
/// It updates the time locally (one tick per second) so it stays accurate even
/// when the Flutter engine is throttled in the background. The displayed clock
/// mirrors the app's elapsed-time clock and therefore only counts up.
object FocusOverlayController {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var layoutParams: WindowManager.LayoutParams? = null

    private val handler = Handler(Looper.getMainLooper())
    private var ticker: Runnable? = null

    private var elapsedSeconds = 0
    private var sessionElapsedSeconds = 0
    private var intervalRemainingSeconds = 0
    private var isRunning = false
    private var isResting = false
    private var usesFocusRoutine = true
    private var subjectName = ""
    private var currentFocusSection = 1
    private var totalFocusSections = 1
    private var focusIntervalSeconds = 1800
    private var restIntervalSeconds = 60
    private var accentColor = 0

    fun hasPermission(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(context)
        } else {
            true
        }
    }

    @SuppressLint("ClickableViewAccessibility", "InflateParams")
    fun show(
        context: Context,
        subjectName: String,
        elapsedSeconds: Int,
        sessionElapsedSeconds: Int,
        intervalRemainingSeconds: Int,
        isRunning: Boolean,
        isResting: Boolean,
        usesFocusRoutine: Boolean,
        currentFocusSection: Int,
        totalFocusSections: Int,
        focusIntervalSeconds: Int,
        restIntervalSeconds: Int,
        accentColor: Int
    ) {
        if (!hasPermission(context)) {
            return
        }
        this.subjectName = subjectName
        this.elapsedSeconds = elapsedSeconds.coerceAtLeast(0)
        this.sessionElapsedSeconds = sessionElapsedSeconds.coerceAtLeast(0)
        this.intervalRemainingSeconds = intervalRemainingSeconds.coerceAtLeast(0)
        this.isRunning = isRunning
        this.isResting = isResting
        this.usesFocusRoutine = usesFocusRoutine
        this.currentFocusSection = currentFocusSection.coerceAtLeast(1)
        this.totalFocusSections = totalFocusSections.coerceAtLeast(1)
        this.focusIntervalSeconds = focusIntervalSeconds.coerceAtLeast(1)
        this.restIntervalSeconds = restIntervalSeconds.coerceAtLeast(1)
        this.accentColor = accentColor

        if (overlayView != null) {
            applyState(accentColor)
            restartTicker(context)
            return
        }

        val appContext = context.applicationContext
        val manager = appContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val view = LayoutInflater.from(appContext)
            .inflate(R.layout.overlay_focus_chip, null)

        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.TOP or Gravity.END
        params.x = dp(appContext, 12)
        params.y = dp(appContext, 64)

        attachTouchListener(appContext, view, params, manager)

        try {
            manager.addView(view, params)
        } catch (error: Exception) {
            return
        }

        windowManager = manager
        overlayView = view
        layoutParams = params

        applyState(accentColor)
        restartTicker(appContext)
    }

    fun hide() {
        stopTicker()
        val view = overlayView
        val manager = windowManager
        if (view != null && manager != null) {
            try {
                manager.removeView(view)
            } catch (error: Exception) {
                // Already detached.
            }
        }
        overlayView = null
        windowManager = null
        layoutParams = null
    }

    private fun applyState(accentColor: Int?) {
        val view = overlayView ?: return
        val title = view.findViewById<TextView>(R.id.overlay_title)
        val time = view.findViewById<TextView>(R.id.overlay_time)
        title.text = if (!usesFocusRoutine) {
            subjectName.ifEmpty { "Hobby" }
        } else if (isResting) {
            "Descanso · próxima ${nextFocusSection()}/$totalFocusSections"
        } else {
            "${subjectName.ifEmpty { "Foco" }} · $currentFocusSection/$totalFocusSections"
        }
        time.text = formatTime(elapsedSeconds)
        if (accentColor != null) {
            view.findViewById<View>(R.id.overlay_dot)
                .background
                ?.setTint(accentColor)
        }
    }

    private fun restartTicker(context: Context) {
        stopTicker()
        if (!isRunning) {
            return
        }
        val runnable = object : Runnable {
            override fun run() {
                if (!isRunning) {
                    return
                }
                elapsedSeconds += 1
                if (!isResting) {
                    sessionElapsedSeconds += 1
                }
                overlayView?.findViewById<TextView>(R.id.overlay_time)?.text =
                    formatTime(elapsedSeconds)

                if (usesFocusRoutine && intervalRemainingSeconds > 0) {
                    intervalRemainingSeconds -= 1
                }
                if (usesFocusRoutine && intervalRemainingSeconds <= 0) {
                    advanceCycle()
                    if (overlayView == null) {
                        return
                    }
                }
                handler.postDelayed(this, 1000L)
            }
        }
        ticker = runnable
        handler.postDelayed(runnable, 1000L)
    }

    private fun advanceCycle() {
        if (isResting) {
            isResting = false
            currentFocusSection = nextFocusSection()
            elapsedSeconds = sessionElapsedSeconds
            intervalRemainingSeconds = focusIntervalSeconds
            applyState(accentColor)
            return
        }

        // Focus intervals are milestones. The app starts the next interval
        // immediately, so the native overlay must keep counting up as well.
        currentFocusSection = nextFocusSection()
        intervalRemainingSeconds = focusIntervalSeconds
        applyState(accentColor)
    }

    private fun nextFocusSection(): Int =
        (currentFocusSection + 1).coerceAtMost(totalFocusSections)

    private fun stopTicker() {
        ticker?.let { handler.removeCallbacks(it) }
        ticker = null
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun attachTouchListener(
        context: Context,
        view: View,
        params: WindowManager.LayoutParams,
        manager: WindowManager
    ) {
        var initialX = 0
        var initialY = 0
        var touchX = 0f
        var touchY = 0f
        var moved = false

        view.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params.x
                    initialY = params.y
                    touchX = event.rawX
                    touchY = event.rawY
                    moved = false
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = (event.rawX - touchX).toInt()
                    val dy = (event.rawY - touchY).toInt()
                    if (abs(dx) > 8 || abs(dy) > 8) {
                        moved = true
                    }
                    // Gravity is TOP|END, so a rightward drag decreases x.
                    params.x = (initialX - dx).coerceAtLeast(0)
                    params.y = (initialY + dy).coerceAtLeast(0)
                    try {
                        manager.updateViewLayout(view, params)
                    } catch (error: Exception) {
                        // View may have been removed mid-drag.
                    }
                    true
                }
                MotionEvent.ACTION_UP -> {
                    if (!moved) {
                        openApp(context)
                    }
                    true
                }
                else -> false
            }
        }
    }

    private fun openApp(context: Context) {
        val launchIntent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
        launchIntent?.addFlags(
            android.content.Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                android.content.Intent.FLAG_ACTIVITY_SINGLE_TOP or
                android.content.Intent.FLAG_ACTIVITY_NEW_TASK
        )
        if (launchIntent != null) {
            context.startActivity(launchIntent)
        }
    }

    private fun formatTime(totalSeconds: Int): String {
        val safe = totalSeconds.coerceAtLeast(0)
        val minutes = safe / 60
        val seconds = safe % 60
        return String.format("%02d:%02d", minutes, seconds)
    }

    private fun dp(context: Context, value: Int): Int {
        val density = context.resources.displayMetrics.density
        return (value * density).toInt()
    }
}
