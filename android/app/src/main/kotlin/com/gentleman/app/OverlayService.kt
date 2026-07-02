package com.gentleman.app

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

class OverlayService : Service() {
    companion object {
        const val EXTRA_PACKAGE = "package"
        const val EXTRA_INTERACTION = "interaction"
        const val ACTION_PROTECTION_DECISION = "com.gentleman.ACTION_PROTECTION_DECISION"
        const val EXTRA_RESULT = "result" // "allowed" | "blocked"
    }

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val pkg = intent?.getStringExtra(EXTRA_PACKAGE) ?: return START_NOT_STICKY
        val interaction = intent.getStringExtra(EXTRA_INTERACTION) ?: "voice"

        showOverlay(pkg, interaction)
        return START_STICKY
    }

    private fun showOverlay(pkg: String, interaction: String) {
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )
        layoutParams.gravity = Gravity.CENTER

        val container = FrameLayout(this)
        container.setBackgroundColor(0x7F000000) // translucent dark overlay

        val info = TextView(this)
        info.text = "Hold to confirm $interaction"
        info.setTextColor(0xFFFFFFFF.toInt())
        info.textSize = 18f
        info.setPadding(40, 40, 40, 40)
        info.setBackgroundColor(0x55000000)
        val params = FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT)
        params.gravity = Gravity.CENTER
        container.addView(info, params)

        var downTime = 0L
        val requiredMs = 1000L

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
