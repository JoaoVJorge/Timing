package com.moonstone.timing

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
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
                "bringAppToFront" -> {
                    val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
                    launchIntent?.addFlags(
                        Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                            Intent.FLAG_ACTIVITY_SINGLE_TOP or
                            Intent.FLAG_ACTIVITY_NEW_TASK
                    )
                    if (launchIntent != null) {
                        startActivity(launchIntent)
                    }
                    result.success(null)
                }
                "startScreenLock" -> {
                    result.success(startScreenLock())
                }
                "stopScreenLock" -> {
                    stopScreenLock()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "timing/focus_overlay"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasPermission" -> {
                    result.success(FocusOverlayController.hasPermission(this))
                }
                "requestPermission" -> {
                    requestOverlayPermission()
                    result.success(null)
                }
                "show" -> {
                    FocusOverlayController.show(
                        context = this,
                        subjectName = call.argument<String>("subjectName") ?: "",
                        remainingSeconds = call.argument<Int>("remainingSeconds") ?: 0,
                        isRunning = call.argument<Boolean>("isRunning") ?: false,
                        isResting = call.argument<Boolean>("isResting") ?: false,
                        accentColor = parseColor(call.argument<String>("colorHex"))
                    )
                    result.success(null)
                }
                "update" -> {
                    FocusOverlayController.update(
                        remainingSeconds = call.argument<Int>("remainingSeconds") ?: 0,
                        isRunning = call.argument<Boolean>("isRunning") ?: false,
                        isResting = call.argument<Boolean>("isResting") ?: false
                    )
                    result.success(null)
                }
                "hide" -> {
                    FocusOverlayController.hide()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)) {
            return
        }
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:$packageName")
        )
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            startActivity(intent)
        } catch (error: Exception) {
            // The settings screen may be unavailable on some devices.
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

    private fun startScreenLock(): Boolean {
        return try {
            if (!isInLockTaskMode()) {
                startLockTask()
            }
            true
        } catch (error: Exception) {
            false
        }
    }

    private fun stopScreenLock() {
        try {
            if (isInLockTaskMode()) {
                stopLockTask()
            }
        } catch (error: Exception) {
            // Nothing to do if the app is not pinned.
        }
    }

    private fun isInLockTaskMode(): Boolean {
        val activityManager =
            getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            activityManager.lockTaskModeState != ActivityManager.LOCK_TASK_MODE_NONE
        } else {
            @Suppress("DEPRECATION")
            activityManager.isInLockTaskMode
        }
    }
}
