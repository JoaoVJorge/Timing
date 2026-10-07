package com.moonstone.timing

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.widget.RemoteViews

class FocusTodayWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val widgetData = context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
        updateWidgets(context, appWidgetManager, appWidgetIds, widgetData)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId))
    }

    companion object {
        private const val PREFERENCES_NAME = "timing_home_widget"
        private const val FOCUS_TODAY_KEY = "focus_today"
        private const val GOALS_PROGRESS_KEY = "goals_progress"

        fun saveData(context: Context, focusToday: String, goalsProgress: String) {
            context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
                .edit()
                .putString(FOCUS_TODAY_KEY, focusToday)
                .putString(GOALS_PROGRESS_KEY, goalsProgress)
                .apply()
        }

        fun updateAll(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, FocusTodayWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(component)
            val widgetData = context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
            updateWidgets(context, appWidgetManager, appWidgetIds, widgetData)
        }

        private fun updateWidgets(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray,
            widgetData: SharedPreferences
        ) {
            appWidgetIds.forEach { widgetId ->
                val options = appWidgetManager.getAppWidgetOptions(widgetId)
                // Hosts report landscape's height as min and portrait's as max.
                // Supply both so rotation does not reuse an oversized layout.
                val landscape = widgetViews(context, widgetData,
                    options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 70))
                val portrait = widgetViews(context, widgetData,
                    options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 70))
                val views = RemoteViews(landscape, portrait)
                appWidgetManager.updateAppWidget(widgetId, views)
            }
        }

        private fun widgetViews(
            context: Context,
            widgetData: SharedPreferences,
            heightDp: Int
        ): RemoteViews {
            val expandedMinHeight = 160 * context.resources.configuration.fontScale.coerceAtLeast(1f)
            val layout = if (heightDp >= expandedMinHeight) {
                R.layout.widget_focus_today_expanded
            } else {
                R.layout.widget_focus_today
            }
            return RemoteViews(context.packageName, layout).apply {
                setTextViewText(R.id.widget_focus_value,
                    widgetData.getString(FOCUS_TODAY_KEY, null) ?: "0 min")
                setTextViewText(R.id.widget_goals_value,
                    widgetData.getString(GOALS_PROGRESS_KEY, null) ?: "Metas 0/0")
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                setOnClickPendingIntent(R.id.widget_root, PendingIntent.getActivity(
                    context, 0, launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                ))
            }
        }
    }
}
