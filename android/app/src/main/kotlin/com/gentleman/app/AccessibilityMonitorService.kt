package com.gentleman.app

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class AccessibilityMonitorService : AccessibilityService() {
    companion object {
        const val ACTION_PROTECTION_EVENT = "com.gentleman.ACTION_PROTECTION_EVENT"
        const val EXTRA_PACKAGE = "package"
        const val EXTRA_INTERACTION = "interaction"
    }

    private val handler = android.os.Handler(android.os.Looper.getMainLooper())
    private var sarcasmRunnable: Runnable? = null

    private val sarcasmMessages = listOf(
        "Still not texting them? Good. Gentleman is keeping you safe.",
        "Your beloved one's notification drawer is silent. You're welcome.",
        "We just intercepted 0 accidental video calls in the last hour. Success!",
        "Gentleman check-in: Your dignity remains fully intact.",
        "Did you feel an urge to make a random video call? Don't. We've got you covered.",
        "Your fingers are behaving. Keep up the good work.",
        "Accidental call avoided in alternate dimensions. Sleep easy.",
        "Gentleman: Saving you from moving to a remote island out of embarrassment."
    )

    override fun onCreate() {
        super.onCreate()
        createSarcasmNotificationChannel()
        scheduleSarcasmNotification()
    }

    override fun onDestroy() {
        sarcasmRunnable?.let { handler.removeCallbacks(it) }
        super.onDestroy()
    }

    private fun createSarcasmNotificationChannel() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            val channel = android.app.NotificationChannel(
                "sarcasm_notifications",
                "Gentleman Alerts",
                android.app.NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Friendly hourly sarcasm checks to keep your dignity high."
            }
            val nm = getSystemService(android.content.Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    private fun scheduleSarcasmNotification() {
        sarcasmRunnable = object : Runnable {
            override fun run() {
                sendSarcasmNotification()
                // Run every 1 hour (3600000 ms)
                handler.postDelayed(this, 3600000L)
            }
        }
        // Start the first one after 1 hour
        handler.postDelayed(sarcasmRunnable!!, 3600000L)
    }

    private fun sendSarcasmNotification() {
        val message = sarcasmMessages.random()
        val builder = androidx.core.app.NotificationCompat.Builder(this, "sarcasm_notifications")
            .setContentTitle("Gentleman Shield")
            .setContentText(message)
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setPriority(androidx.core.app.NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)

        val nm = getSystemService(android.content.Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        nm.notify((System.currentTimeMillis() % 100000).toInt(), builder.build())
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        // Only consider click events and window changes which may indicate a call UI
        val type = event.eventType
        val pkg = event.packageName?.toString() ?: return

        if (type == AccessibilityEvent.TYPE_VIEW_CLICKED || type == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED || type == AccessibilityEvent.TYPE_VIEW_FOCUSED) {
            // Heuristic: inspect event text and contentDescription for "call" keywords
            val texts = StringBuilder()
            for (t in event.text) {
                texts.append(t).append(' ')
            }

            val desc = event.contentDescription?.toString() ?: ""
            val combined = (texts.toString() + " " + desc).lowercase()

            if (combined.contains("call") || combined.contains("voice") || combined.contains("video")) {
                val interaction = when {
                    combined.contains("video") -> "video"
                    combined.contains("voice") || combined.contains("audio") -> "voice"
                    else -> "voice"
                }

                // Start the overlay to confirm the interaction, and broadcast the detection event.
                try {
                    val prefs = getSharedPreferences("gentleman_settings", android.content.Context.MODE_PRIVATE)
                    val holdMs = prefs.getInt("holdDurationMs", 1000)
                    val svcIntent = Intent(this, OverlayService::class.java)
                    svcIntent.putExtra(OverlayService.EXTRA_PACKAGE, pkg)
                    svcIntent.putExtra(OverlayService.EXTRA_INTERACTION, interaction)
                    svcIntent.putExtra(OverlayService.EXTRA_HOLD_DURATION_MS, holdMs)
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                        startForegroundService(svcIntent)
                    } else {
                        startService(svcIntent)
                    }
                } catch (_: Exception) {
                    // ignore service launch failures
                }

                val intent = Intent(ACTION_PROTECTION_EVENT)
                intent.putExtra(EXTRA_PACKAGE, pkg)
                intent.putExtra(EXTRA_INTERACTION, interaction)
                sendBroadcast(intent)
                return
            }

            // As a fallback, also inspect source node's children for labels containing "call"
            val node: AccessibilityNodeInfo? = event.source
            if (node != null) {
                if (nodeHasCallText(node)) {
                    val intent = Intent(ACTION_PROTECTION_EVENT)
                    intent.putExtra(EXTRA_PACKAGE, pkg)
                    intent.putExtra(EXTRA_INTERACTION, "voice")
                    sendBroadcast(intent)
                }
            }
        }
    }

    private fun nodeHasCallText(node: AccessibilityNodeInfo): Boolean {
        try {
            val desc = node.contentDescription?.toString()?.lowercase()
            if (desc != null && (desc.contains("call") || desc.contains("video"))) return true
            val text = node.text?.toString()?.lowercase()
            if (text != null && (text.contains("call") || text.contains("video"))) return true

            for (i in 0 until node.childCount) {
                val child = node.getChild(i) ?: continue
                if (nodeHasCallText(child)) return true
            }
        } catch (e: Exception) {
            // ignore traversal errors
        }
        return false
    }

    override fun onInterrupt() {}
}
