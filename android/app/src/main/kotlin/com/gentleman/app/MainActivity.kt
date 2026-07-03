package com.gentleman.app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.gentleman/protection"

    // Keep references to receivers so we can unregister them in onDestroy.
    private var protectionEventReceiver: BroadcastReceiver? = null
    private var protectionDecisionReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        // Register a receiver to get protection events from the AccessibilityService and forward to Dart.
        protectionEventReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent == null) return
                val pkg = intent.getStringExtra("package")
                val interaction = intent.getStringExtra("interaction")
                val payload = mapOf("package" to pkg, "interaction" to interaction)
                try {
                    methodChannel.invokeMethod("onProtectionEvent", payload)
                } catch (e: Exception) {
                    // ignore invocation failures
                }
            }
        }
        if (android.os.Build.VERSION.SDK_INT >= 33) { // Build.VERSION_CODES.TIRAMISU
            registerReceiver(
                protectionEventReceiver,
                IntentFilter("com.gentleman.ACTION_PROTECTION_EVENT"),
                Context.RECEIVER_NOT_EXPORTED
            )
        } else {
            registerReceiver(
                protectionEventReceiver,
                IntentFilter("com.gentleman.ACTION_PROTECTION_EVENT")
            )
        }
 
        // Listen for overlay decisions and forward to Flutter as well.
        protectionDecisionReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent == null) return
                val pkg = intent.getStringExtra(OverlayService.EXTRA_PACKAGE)
                val interaction = intent.getStringExtra(OverlayService.EXTRA_INTERACTION)
                val result = intent.getStringExtra(OverlayService.EXTRA_RESULT)
                val payload = mapOf("package" to pkg, "interaction" to interaction, "result" to result)
                try {
                    methodChannel.invokeMethod("onProtectionDecision", payload)
                } catch (e: Exception) {
                }
            }
        }
        if (android.os.Build.VERSION.SDK_INT >= 33) {
            registerReceiver(
                protectionDecisionReceiver,
                IntentFilter("com.gentleman.ACTION_PROTECTION_DECISION"),
                Context.RECEIVER_NOT_EXPORTED
            )
        } else {
            registerReceiver(
                protectionDecisionReceiver,
                IntentFilter("com.gentleman.ACTION_PROTECTION_DECISION")
            )
        }

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityEnabled" -> {
                    result.success(isOurAccessibilityServiceEnabled())
                }
                "isOverlayEnabled" -> {
                    val allowed = android.provider.Settings.canDrawOverlays(this)
                    result.success(allowed)
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
                "isServiceRunning" -> {
                    val enabled = isOurAccessibilityServiceEnabled()
                    result.success(enabled)
                }
                "isBatteryOptimizationDisabled" -> {
                    val pm = getSystemService(POWER_SERVICE) as android.os.PowerManager
                    val ignored = pm.isIgnoringBatteryOptimizations(packageName)
                    result.success(ignored)
                }
                "setHoldDurationMs" -> {
                    val ms = call.argument<Int>("ms") ?: 1000
                    val prefs = getSharedPreferences("gentleman_settings", Context.MODE_PRIVATE)
                    prefs.edit().putInt("holdDurationMs", ms).apply()
                    result.success(null)
                }
                "getForegroundApp" -> {
                    val pkg = getForegroundAppPackage()
                    result.success(pkg)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        // Unregister receivers to prevent memory leaks when the activity is destroyed.
        protectionEventReceiver?.let { unregisterReceiver(it) }
        protectionDecisionReceiver?.let { unregisterReceiver(it) }
        protectionEventReceiver = null
        protectionDecisionReceiver = null
        super.onDestroy()
    }

    private fun isOurAccessibilityServiceEnabled(): Boolean {
        try {
            val expectedLong = "$packageName/$packageName.AccessibilityMonitorService"
            val expectedShort = "$packageName/.AccessibilityMonitorService"
            val enabledServices = android.provider.Settings.Secure.getString(contentResolver, android.provider.Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
            if (enabledServices != null) {
                val services = enabledServices.split(":")
                for (s in services) {
                    if (s == expectedLong || s == expectedShort || s.contains("AccessibilityMonitorService")) {
                        return true
                    }
                }
            }
        } catch (e: Exception) {
            // ignore
        }
        return false
    }

    private fun getForegroundAppPackage(): String? {
        try {
            val usm = getSystemService(USAGE_STATS_SERVICE) as android.app.usage.UsageStatsManager
            val endTime = System.currentTimeMillis()
            val beginTime = endTime - 1000 * 60
            val usageStats = usm.queryUsageStats(android.app.usage.UsageStatsManager.INTERVAL_DAILY, beginTime, endTime)
            if (usageStats != null && usageStats.isNotEmpty()) {
                val recent = usageStats.maxByOrNull { it.lastTimeUsed }
                return recent?.packageName
            }
        } catch (e: Exception) {
            // Fall back to ActivityManager
            try {
                val am = getSystemService(ACTIVITY_SERVICE) as android.app.ActivityManager
                val tasks = am.runningAppProcesses
                if (tasks != null && tasks.isNotEmpty()) {
                    return tasks[0].processName
                }
            } catch (_: Exception) {
            }
        }
        return null
    }
}
