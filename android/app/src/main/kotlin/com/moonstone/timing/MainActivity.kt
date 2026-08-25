package com.moonstone.timing

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
                        isCountUp = call.argument<Boolean>("isCountUp") ?: false,
                        usesFocusRoutine = call.argument<Boolean>("usesFocusRoutine") ?: true,
                        currentFocusSection = call.argument<Int>("currentFocusSection") ?: 1,
                        totalFocusSections = call.argument<Int>("totalFocusSections") ?: 1,
                        focusIntervalSeconds = call.argument<Int>("focusIntervalSeconds") ?: 1800,
                        restIntervalSeconds = call.argument<Int>("restIntervalSeconds") ?: 60,
                        accentColor = parseColor(call.argument<String>("colorHex"))
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

}
