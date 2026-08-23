package com.moonstone.timing

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
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
                val views = RemoteViews(context.packageName, R.layout.widget_focus_today)

                val focusValue = widgetData.getString(FOCUS_TODAY_KEY, null) ?: "0 min"
                val goalsValue = widgetData.getString(GOALS_PROGRESS_KEY, null) ?: "Metas 0/0"

                views.setTextViewText(R.id.widget_focus_value, focusValue)
                views.setTextViewText(R.id.widget_goals_value, goalsValue)

                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                appWidgetManager.updateAppWidget(widgetId, views)
            }
        }
    }
}
