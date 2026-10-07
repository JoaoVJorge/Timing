package com.moonstone.timing

import android.app.Application
import android.app.Notification
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.view.View
import android.widget.FrameLayout
import android.widget.RemoteViews
import android.widget.TextView
import org.junit.Assert.*
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [35, 36], application = Application::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class TimerSurfacesTest {
    @Test
    fun timerIsNotMediaAndPauseResumeStillWorks() {
        val controller = Robolectric.buildService(TimerForegroundService::class.java).create()
        val service = controller.get()
        try {
            service.onStartCommand(Intent(service, TimerForegroundService::class.java).apply {
                putExtra("title", "Study")
                putExtra("isRunning", true)
                putExtra("isTicking", true)
                putExtra("elapsedSeconds", 42)
                putExtra("totalSeconds", 1500)
            }, 0, 1)
            val notification = shadowOf(service).lastForegroundNotification
            assertEquals(Notification.CATEGORY_STOPWATCH, notification.category)
            assertNull(notification.extras.getParcelable<android.os.Parcelable>(Notification.EXTRA_MEDIA_SESSION))
            assertFalse(notification.extras.getString(Notification.EXTRA_TEMPLATE).orEmpty().contains("Media"))
            assertTrue(notification.flags and Notification.FLAG_ONGOING_EVENT != 0)
            if (Build.VERSION.SDK_INT >= 36) {
                // The initial API 36 image predates the opt-in Live Updates contract.
                assertTrue(notification.extras.getBoolean("android.requestPromotedOngoing"))
                assertFalse(notification.extras.getBoolean(Notification.EXTRA_COLORIZED))
                assertNull(notification.contentView)
            }
            val manager = service.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            assertNull(manager.getNotificationChannel(notification.channelId).sound)
            val toggle = shadowOf(notification.actions.single().actionIntent).savedIntent
            service.onStartCommand(toggle, 0, 2)
            val paused = shadowOf(service).lastForegroundNotification
            assertFalse(paused.extras.getBoolean(Notification.EXTRA_SHOW_CHRONOMETER))
            assertTrue(TimerForegroundService.consumePendingToggleRequest())
            assertFalse(TimerForegroundService.consumePendingToggleRequest())
            service.onStartCommand(toggle, 0, 3)
            assertTrue(shadowOf(service).lastForegroundNotification.extras.getBoolean(Notification.EXTRA_SHOW_CHRONOMETER))
        } finally {
            TimerForegroundService.consumePendingToggleRequest()
            controller.destroy()
        }
    }

    @Test
    fun compactWidgetKeepsAllThreeRowsInsideTwoByOneBounds() {
        val context = RuntimeEnvironment.getApplication()
        val density = context.resources.displayMetrics.density
        for ((width, height) in listOf(140 to 70, 180 to 60, 220 to 90)) {
            val view = RemoteViews(context.packageName, R.layout.widget_focus_today)
                .apply(context, FrameLayout(context))
            val widthPx = (width * density).toInt()
            val heightPx = (height * density).toInt()
            // Auto-size may request a second traversal after its first layout.
            repeat(2) {
                view.measure(View.MeasureSpec.makeMeasureSpec(widthPx, View.MeasureSpec.EXACTLY),
                    View.MeasureSpec.makeMeasureSpec(heightPx, View.MeasureSpec.EXACTLY))
                view.layout(0, 0, widthPx, heightPx)
            }
            for (id in listOf(R.id.widget_label, R.id.widget_focus_value, R.id.widget_goals_value)) {
                val row = view.findViewById<TextView>(id)
                assertTrue("Row must fit vertically at ${width}x$height", row.bottom <= heightPx - view.paddingBottom)
                assertTrue("Text ${row.text} at ${width}x$height: layout=${row.layout.height}, row=${row.height}, textSize=${row.textSize}", row.layout.height <= row.height)
                assertEquals("Default value must be fully visible", 0, row.layout.getEllipsisCount(0))
            }
        }
    }
}
