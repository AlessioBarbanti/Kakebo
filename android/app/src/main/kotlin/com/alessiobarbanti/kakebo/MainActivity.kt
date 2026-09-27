package com.alessiobarbanti.kakebo

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var widget: MethodChannel? = null

    // The home screen widget's channel (lib/services/home_screen_widget.dart): the app sends the widget's moments, and hears
    // which screen a tap on the widget asks for, whether it started the app ("launch") or found it already open ("open").
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        widget = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "kakebo/widget").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "show" -> {
                        KakeboWidget.show(this@MainActivity, call.arguments as String)
                        result.success(null)
                    }
                    "launch" -> {
                        result.success(tap(intent))
                        intent?.action = Intent.ACTION_MAIN // once
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        tap(intent)?.let { widget?.invokeMethod("open", it) }
    }

    private fun tap(intent: Intent?) =
        if (intent?.action == KakeboWidget.OPEN) mapOf("screen" to intent.getStringExtra("screen"), "pillar" to intent.getStringExtra("pillar")) else null
}
