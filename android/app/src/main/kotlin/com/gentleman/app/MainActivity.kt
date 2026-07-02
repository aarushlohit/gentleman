package com.gentleman.app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.gentleman/protection"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityEnabled" -> {
                    result.success(false)
                }
                "isOverlayEnabled" -> {
                    result.success(false)
                }
                "openAccessibilitySettings" -> {
                    val intent = android.provider.Settings.ACTION_ACCESSIBILITY_SETTINGS
                    startActivity(android.content.Intent(intent))
                    result.success(null)
                }
                "openOverlaySettings" -> {
                    val intent = android.provider.Settings.ACTION_MANAGE_OVERLAY_PERMISSION
                    startActivity(android.content.Intent(intent))
                    result.success(null)
                }
                "openBatterySettings" -> {
                    val intent = android.provider.Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS
                    startActivity(android.content.Intent(intent))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
