package com.alessiobarbanti.kakebo

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject

/**
 * The home screen widget: one question per moment (the day, the evening, the month to close), as the app asks it.
 * The app works out every moment ahead with its texts (lib/services/home_screen_widget.dart); this shows the one begun last
 * and wakes itself when the next begins.
 */
class KakeboWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) = draw(context)

    override fun onAppWidgetOptionsChanged(context: Context, manager: AppWidgetManager, id: Int, options: Bundle) = draw(context)

    companion object {
        /** The intent action of the widget's taps: MainActivity passes the screen (and pillar) on to the app. */
        const val OPEN = "com.alessiobarbanti.kakebo.OPEN"

        private val pillars = listOf("needs" to R.id.needs, "wants" to R.id.wants, "culture" to R.id.culture, "unexpected" to R.id.unexpected)

        fun show(context: Context, json: String) {
            context.getSharedPreferences("widget", Context.MODE_PRIVATE).edit().putString("moments", json).apply()
            draw(context)
        }

        private fun draw(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, KakeboWidget::class.java))
            val saved = JSONObject(context.getSharedPreferences("widget", Context.MODE_PRIVATE).getString("moments", null) ?: "{}")
            val frames = saved.optJSONArray("frames") ?: JSONArray()
            val texts = saved.optJSONObject("texts") ?: JSONObject()

            // The moment begun last; the next one's start is when to look again. The alarm does not wake the phone:
            // the widget only needs to be right when the screen is on.
            val now = System.currentTimeMillis()
            var frame: JSONObject? = null
            var next = 0L
            for (i in 0 until frames.length()) {
                val f = frames.getJSONObject(i)
                if (f.getLong("at") > now) {
                    next = f.getLong("at")
                    break
                }
                frame = f
            }
            val wake = PendingIntent.getBroadcast(
                context,
                0,
                Intent(context, KakeboWidget::class.java).setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE).putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids),
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
            val alarms = context.getSystemService(AlarmManager::class.java)
            if (next > 0) alarms.set(AlarmManager.RTC, next, wake) else alarms.cancel(wake)

            val small = small(context, frame, texts)
            val large = large(context, frame, texts)
            if (Build.VERSION.SDK_INT >= 31) {
                // Android 12+ picks by the widget's size as it is resized.
                manager.updateAppWidget(ids, RemoteViews(mapOf(SizeF(110f, 40f) to small, SizeF(250f, 150f) to large)))
            } else {
                for (id in ids) {
                    val options = manager.getAppWidgetOptions(id)
                    val big = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH) >= 250 && options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT) >= 150
                    manager.updateAppWidget(id, if (big) large else small)
                }
            }
        }

        // Both layouts set every view they change for every moment: the launcher applies an update over the views it already
        // shows when the layout is the same, so what the moment before showed (the evening's note, its smaller title) would stay.

        private fun small(context: Context, f: JSONObject?, texts: JSONObject) = RemoteViews(context.packageName, R.layout.widget_small).apply {
            setOnClickPendingIntent(android.R.id.background, tap(context, f))
            if (f == null) return@apply
            val kind = f.getString("kind")
            shown(R.id.kicker, kind == "day")
            shown(R.id.seal, kind == "close")
            shown(R.id.action, kind != "close")
            setTextViewTextSize(R.id.title, TypedValue.COMPLEX_UNIT_SP, if (kind == "day") 28f else 15f)
            when (kind) {
                "day" -> {
                    setTextViewText(R.id.kicker, f.getString("kicker"))
                    setTextViewText(R.id.title, f.getString("title"))
                    action(context, "+", texts.optString("add"), "add")
                }
                "evening" -> {
                    setTextViewText(R.id.title, f.getString("title"))
                    action(context, "筆", texts.optString("write"), "thought")
                }
                "close" -> setTextViewText(R.id.title, f.getString("small"))
            }
        }

        private fun large(context: Context, f: JSONObject?, texts: JSONObject) = RemoteViews(context.packageName, R.layout.widget_large).apply {
            setOnClickPendingIntent(android.R.id.background, tap(context, f))
            if (f == null) return@apply
            val kind = f.getString("kind")
            val day = kind == "day"
            shown(R.id.sub, day)
            shown(R.id.pillars, day)
            shown(R.id.notes, !day)
            shown(R.id.seal, kind == "close")
            shown(R.id.month, true)
            setTextViewText(R.id.kicker, f.getString("kicker"))
            setTextViewText(R.id.title, f.getString("title"))
            setTextViewTextSize(R.id.title, TypedValue.COMPLEX_UNIT_SP, if (day) 40f else 22f)
            if (day) {
                setTextViewText(R.id.sub, f.getString("sub"))
                pillars.forEachIndexed { i, (key, id) ->
                    setOnClickPendingIntent(id, open(context, 2 + i, "add", key))
                    setContentDescription(id, texts.optString(key))
                }
            } else {
                setTextViewText(R.id.note, f.getString("note"))
                setTextViewText(R.id.button, f.getString("button"))
                setOnClickPendingIntent(R.id.button, tap(context, f))
            }
            setImageViewBitmap(R.id.line, line(context, f.getDouble("ink").toFloat(), f.getDouble("tick").toFloat()))
            setContentDescription(R.id.line, f.getString("line"))
            setTextViewText(R.id.stamp, f.getString("stamp"))
        }

        private fun RemoteViews.shown(id: Int, on: Boolean) = setViewVisibility(id, if (on) View.VISIBLE else View.GONE)

        private fun RemoteViews.action(context: Context, glyph: String, description: String, screen: String) {
            setTextViewText(R.id.action, glyph)
            setContentDescription(R.id.action, description)
            setOnClickPendingIntent(R.id.action, open(context, if (screen == "add") 1 else 6, screen))
        }

        /** A tap anywhere: by day the app, in the evening the thought, at the month's end the review. */
        private fun tap(context: Context, f: JSONObject?) = when (f?.getString("kind")) {
            "evening" -> open(context, 6, "thought")
            "close" -> open(context, 7, "review")
            else -> open(context, 0, null)
        }

        private fun open(context: Context, code: Int, screen: String?, pillar: String? = null): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            if (screen == null) intent.action = Intent.ACTION_MAIN else intent.setAction(OPEN).putExtra("screen", screen).putExtra("pillar", pillar)
            return PendingIntent.getActivity(context, code, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        }

        /** The month as a line: the track, the ink of what is spent, today's notch; stretched to the widget's width. */
        private fun line(context: Context, ink: Float, tick: Float): Bitmap {
            val d = context.resources.displayMetrics.density
            val w = 320 * d
            val h = 14 * d
            val bitmap = Bitmap.createBitmap(w.toInt(), h.toInt(), Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG)
            val mid = h / 2
            paint.color = context.getColor(R.color.widget_track)
            canvas.drawRoundRect(0f, mid - d, w, mid + d, d, d, paint)
            paint.color = context.getColor(R.color.widget_ink)
            if (ink > 0) canvas.drawRoundRect(0f, mid - 2 * d, maxOf(4 * d, w * ink), mid + 2 * d, 2 * d, 2 * d, paint)
            paint.color = context.getColor(R.color.widget_tick)
            val x = (w - 2 * d) * tick
            canvas.drawRoundRect(x, 0f, x + 2 * d, h, d, d, paint)
            return bitmap
        }
    }
}
