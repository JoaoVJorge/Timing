package com.moonstone.timing

import android.app.ActivityManager
import android.app.KeyguardManager
import android.graphics.Color
import android.os.Build
import android.view.View
import android.view.WindowInsets
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var releasePendingPin = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "timing/focus_guard"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setKeepScreenOn" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    if (enabled) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    }
                    result.success(null)
                }
                "setImmersiveMode" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    setImmersiveMode(enabled)
                    result.success(null)
                }
                "getProtectionStatus" -> {
                    releasePinIfNeeded()
                    result.success(protectionStatus())
                }
                "requestScreenPinning" -> {
                    val keyguard = getSystemService(KEYGUARD_SERVICE) as KeyguardManager
                    if (!hasWindowFocus() || keyguard.isKeyguardLocked) {
                        result.success(protectionStatus())
                    } else {
                        try {
                            releasePendingPin = false
                            if (protectionStatus() != "pinned") {
                                startLockTask()
                            }
                            result.success(protectionStatus())
                        } catch (error: Exception) {
                            result.error("PINNING_UNAVAILABLE", "Screen pinning could not start", null)
                        }
                    }
                }
                "stopScreenPinning" -> {
                    releasePendingPin = true
                    releasePinIfNeeded()
                    result.success(protectionStatus())
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "timing/timer_foreground_service"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    TimerForegroundService.start(
                        context = this,
                        title = call.argument<String>("title") ?: "",
                        actionLabel = call.argument<String>("actionLabel") ?: "",
                        isRunning = call.argument<Boolean>("isRunning") ?: true,
                        isTicking = call.argument<Boolean>("isTicking") ?: false,
                        ticksWhenRunning =
                            call.argument<Boolean>("ticksWhenRunning") ?: true,
                        elapsedSeconds = call.argument<Int>("elapsedSeconds") ?: 0,
                        totalSeconds = call.argument<Int>("totalSeconds") ?: 0,
                        currentSection = call.argument<Int>("currentSection") ?: 1,
                        totalSections = call.argument<Int>("totalSections") ?: 1,
                        color = parseColor(call.argument<String>("colorHex")),
                        activityIcon = call.argument<ByteArray>("activityIcon")
                    )
                    result.success(null)
                }
                "stop" -> {
                    TimerForegroundService.stop(this)
                    result.success(null)
                }
                "consumePendingToggle" -> {
                    result.success(TimerForegroundService.consumePendingToggleRequest())
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "timing/home_widget"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateFocusToday" -> {
                    FocusTodayWidgetProvider.saveData(
                        context = this,
                        focusToday = call.argument<String>("focus_today") ?: "0 min",
                        goalsProgress = call.argument<String>("goals_progress") ?: "Metas 0/0"
                    )
                    FocusTodayWidgetProvider.updateAll(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun protectionStatus(): String {
        val manager = getSystemService(ACTIVITY_SERVICE) as ActivityManager
        return if (manager.lockTaskModeState != ActivityManager.LOCK_TASK_MODE_NONE) {
            "pinned"
        } else {
            "inactive"
        }
    }

    private fun releasePinIfNeeded() {
        if (releasePendingPin && protectionStatus() == "pinned") {
            try {
                stopLockTask()
            } catch (error: Exception) {
                // Report the actual state; never claim that release succeeded.
            }
        }
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) releasePinIfNeeded()
    }

    override fun onDestroy() {
        if (!isChangingConfigurations && protectionStatus() == "pinned") {
            releasePendingPin = true
            releasePinIfNeeded()
        }
        super.onDestroy()
    }

    @Suppress("DEPRECATION")
    private fun setImmersiveMode(enabled: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val controller = window.insetsController ?: return
            if (enabled) {
                controller.systemBarsBehavior =
                    android.view.WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
                controller.hide(WindowInsets.Type.navigationBars())
            } else {
                controller.show(WindowInsets.Type.navigationBars())
            }
            return
        }

        val immersiveFlags =
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
        if (enabled) {
            window.decorView.systemUiVisibility =
                window.decorView.systemUiVisibility or immersiveFlags
        } else {
            window.decorView.systemUiVisibility =
                window.decorView.systemUiVisibility and immersiveFlags.inv()
        }
    }

    private fun parseColor(colorHex: String?): Int {
        if (colorHex.isNullOrEmpty()) {
            return Color.parseColor("#5B8CFF")
        }
        return try {
            Color.parseColor("#$colorHex")
        } catch (error: IllegalArgumentException) {
            Color.parseColor("#5B8CFF")
        }
    }

}
