package com.gentleman.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat

class OverlayService : Service() {
    companion object {
        const val EXTRA_PACKAGE = "package"
        const val EXTRA_INTERACTION = "interaction"
        const val EXTRA_HOLD_DURATION_MS = "holdDurationMs"
        const val ACTION_PROTECTION_DECISION = "com.gentleman.ACTION_PROTECTION_DECISION"
        const val EXTRA_RESULT = "result" // "allowed" | "blocked"

        private const val NOTIFICATION_CHANNEL_ID = "gentleman_overlay"
        private const val NOTIFICATION_ID = 1001
    }

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        // Start as a foreground service immediately so Android 8+ does not
        // kill the service before it can show the overlay window.
        val notification = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle("Gentleman")
            .setContentText("Hold-to-confirm overlay active")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setSilent(true)
            .build()
        startForeground(NOTIFICATION_ID, notification)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val pkg = intent?.getStringExtra(EXTRA_PACKAGE) ?: run { stopSelf(); return START_NOT_STICKY }
        val interaction = intent.getStringExtra(EXTRA_INTERACTION) ?: "voice"
        val holdDurationMs = intent.getIntExtra(EXTRA_HOLD_DURATION_MS, 1000).toLong()

        showOverlay(pkg, interaction, holdDurationMs)
        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Gentleman Protection",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows while the hold-to-confirm overlay is active"
                setShowBadge(false)
            }
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    private fun showOverlay(pkg: String, interaction: String, requiredMs: Long) {
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else @Suppress("DEPRECATION") WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )
        layoutParams.gravity = Gravity.CENTER

        val container = FrameLayout(this)
        container.setBackgroundColor(0x7F000000) // translucent dark overlay

        val info = TextView(this)
        info.text = "Hold to confirm ${interaction} call\n(${requiredMs}ms)"
        info.setTextColor(0xFFFFFFFF.toInt())
        info.textSize = 18f
        info.setPadding(40, 40, 40, 40)
        info.setBackgroundColor(0x55000000)
        val params = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.WRAP_CONTENT,
            FrameLayout.LayoutParams.WRAP_CONTENT
        )
        params.gravity = Gravity.CENTER
        container.addView(info, params)

        var downTime = 0L

        container.setOnTouchListener { _, ev ->
            when (ev.action) {
                MotionEvent.ACTION_DOWN -> {
                    downTime = System.currentTimeMillis()
                    true
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    val held = System.currentTimeMillis() - downTime >= requiredMs
                    sendDecision(pkg, interaction, if (held) "allowed" else "blocked")
                    removeOverlay()
                    stopSelf()
                    true
                }
                else -> true
            }
        }

        overlayView = container
        try {
            windowManager?.addView(container, layoutParams)
        } catch (e: Exception) {
            // ignore inability to show overlay
            stopSelf()
        }
    }

    private fun sendDecision(pkg: String, interaction: String, result: String) {
        val intent = Intent(ACTION_PROTECTION_DECISION)
        intent.putExtra(EXTRA_PACKAGE, pkg)
        intent.putExtra(EXTRA_INTERACTION, interaction)
        intent.putExtra(EXTRA_RESULT, result)
        sendBroadcast(intent)
    }

    private fun removeOverlay() {
        try {
            overlayView?.let { windowManager?.removeView(it) }
            overlayView = null
        } catch (_: Exception) {}
    }

    override fun onDestroy() {
        removeOverlay()
        super.onDestroy()
    }
}
