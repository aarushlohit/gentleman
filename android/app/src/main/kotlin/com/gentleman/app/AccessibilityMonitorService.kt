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

        val type = event.eventType
        val pkg = event.packageName?.toString() ?: return

        // We only care about WhatsApp and Instagram!
        if (pkg != "com.whatsapp" && pkg != "com.instagram.android") return

        // Intercept view clicked events representing call button taps
        if (type == AccessibilityEvent.TYPE_VIEW_CLICKED) {
            val node = event.source ?: return
            val interaction = isCallButtonClicked(node) ?: return // Not a call button click

            // Before drawing the overlay, make sure we have overlay drawing permission!
            if (!android.provider.Settings.canDrawOverlays(this)) return

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
        }
    }

    private fun isCallButtonClicked(node: AccessibilityNodeInfo): String? {
        val resId = node.viewIdResourceName?.lowercase() ?: ""
        val desc = node.contentDescription?.toString()?.lowercase() ?: ""
        val text = node.text?.toString()?.lowercase() ?: ""

        // Exclude text inputs, search fields, chat list items, status updates
        if (resId.contains("search") || resId.contains("input") || resId.contains("edit") || resId.contains("entry") || resId.contains("message")) {
            return null
        }
        if (desc.contains("search") || desc.contains("message") || desc.contains("type") || desc.contains("text")) {
            return null
        }

        // Match video call
        if (resId.contains("video_call") || resId.contains("video") || 
            desc.contains("video call") || desc.contains("start video") ||
            text.contains("video call") || text.contains("video")) {
            return "video"
        }

        // Match voice call
        if (resId.contains("menu_item_call") || resId.contains("voice_call") || resId.contains("audio_call") ||
            desc.contains("voice call") || desc.contains("start voice") || desc.contains("audio call") ||
            desc.contains("start call") || desc.contains("make a call") || desc.contains("call") ||
            text.contains("voice call") || text.contains("audio call") || text.contains("call")) {
            return "voice"
        }

        // Traversal of children (since call icons are often inside a parent button layout)
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            val result = isCallButtonClicked(child)
            if (result != null) return result
        }

        // Check if any parent indicates it is a call button container
        var parent = node.parent
        while (parent != null) {
            val parentResId = parent.viewIdResourceName?.lowercase() ?: ""
            if (parentResId.contains("search") || parentResId.contains("input") || parentResId.contains("edit")) {
                return null
            }
            if (parentResId.contains("video_call") || parentResId.contains("menu_item_call") || parentResId.contains("audio_call")) {
                return if (parentResId.contains("video")) "video" else "voice"
            }
            parent = parent.parent
        }

        return null
    }

    override fun onInterrupt() {}
}
