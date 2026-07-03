package com.gentleman.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.res.ColorStateList
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.TextView
import androidx.core.app.NotificationCompat

class OverlayService : Service() {
    companion object {
        const val EXTRA_PACKAGE = "package"
        const val EXTRA_INTERACTION = "interaction"
        const val EXTRA_HOLD_DURATION_MS = "holdDurationMs"
        const val ACTION_PROTECTION_DECISION = "com.gentleman.ACTION_PROTECTION_DECISION"
        const val EXTRA_RESULT = "result" // "allowed" | "blocked"

        private const val NOTIFICATION_CHANNEL_ID = "protection_service"
        private const val NOTIFICATION_ID = 8888
    }

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private val handler = Handler(Looper.getMainLooper())
    private var decisionTimeoutRunnable: Runnable? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        val notification = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle("Gentleman Shield Active")
            .setContentText("Hold to confirm call overlay is showing")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
        startForeground(NOTIFICATION_ID, notification)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val pkg = intent?.getStringExtra(EXTRA_PACKAGE) ?: run {
            android.util.Log.d("Gentleman", "OverlayService: package was null, stopping")
            stopSelf()
            return START_NOT_STICKY
        }
        val interaction = intent.getStringExtra(EXTRA_INTERACTION) ?: "voice"
        val holdDurationMs = intent.getIntExtra(EXTRA_HOLD_DURATION_MS, 1000).toLong()

        android.util.Log.d("Gentleman", "OverlayService started for pkg = $pkg, interaction = $interaction, holdDurationMs = $holdDurationMs")
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
        if (overlayView != null) {
            android.util.Log.d("Gentleman", "Overlay already showing, ignoring show request.")
            return
        }
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

        // Main overlay container (full screen dark blur background)
        val container = FrameLayout(this)
        container.setBackgroundColor(0x99000000.toInt()) // Translucent black

        // Apple-inspired card in the center
        val card = LinearLayout(this)
        card.orientation = LinearLayout.VERTICAL
        card.gravity = Gravity.CENTER

        val bgDrawable = GradientDrawable().apply {
            setColor(Color.parseColor("#1C1C1E")) // iOS system background
            cornerRadius = 48f
            setStroke(2, Color.parseColor("#38383A")) // subtle border
        }
        card.background = bgDrawable
        card.setPadding(64, 80, 64, 80)

        // Title icon / emoji
        val emojiIcon = TextView(this).apply {
            text = if (interaction == "video") "📹" else "📞"
            textSize = 44f
            gravity = Gravity.CENTER
        }
        card.addView(emojiIcon)

        // Space
        card.addView(View(this), LinearLayout.LayoutParams(1, 24))

        // Title
        val titleText = TextView(this).apply {
            text = "Hold to Confirm Call"
            setTextColor(Color.WHITE)
            textSize = 20f
            setTypeface(null, android.graphics.Typeface.BOLD)
            gravity = Gravity.CENTER
        }
        card.addView(titleText)

        // Space
        card.addView(View(this), LinearLayout.LayoutParams(1, 8))

        // Subtitle text details
        val appName = if (pkg.contains("whatsapp")) "WhatsApp" else "Instagram"
        val subtitleText = TextView(this).apply {
            text = "Preventing accidental call inside $appName.\nKeep holding the screen to unlock call."
            setTextColor(Color.parseColor("#AEAEB2"))
            textSize = 13f
            gravity = Gravity.CENTER
        }
        card.addView(subtitleText)

        // Space
        card.addView(View(this), LinearLayout.LayoutParams(1, 48))

        // Premium Progress bar
        val progressBar = ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal).apply {
            max = 100
            progress = 0
            progressTintList = ColorStateList.valueOf(Color.parseColor("#FFCC00")) // Apple yellow/gold
            progressBackgroundTintList = ColorStateList.valueOf(Color.parseColor("#38383A"))
        }
        val progressParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            16
        )
        card.addView(progressBar, progressParams)

        // Space
        card.addView(View(this), LinearLayout.LayoutParams(1, 32))

        // Timer/Status indicator
        val statusText = TextView(this).apply {
            text = "0% (Hold for ${requiredMs}ms)"
            setTextColor(Color.parseColor("#FFCC00"))
            textSize = 14f
            setTypeface(null, android.graphics.Typeface.BOLD)
            gravity = Gravity.CENTER
        }
        card.addView(statusText)

        val cardParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.WRAP_CONTENT
        ).apply {
            gravity = Gravity.CENTER
            leftMargin = 80
            rightMargin = 80
        }
        container.addView(card, cardParams)

        var downTime = 0L
        var updateRunnable: Runnable? = null
        var isConfirmed = false
        val decisionTimeoutMs = maxOf(requiredMs + 500L, 1500L)

        decisionTimeoutRunnable = Runnable {
            if (!isConfirmed) {
                android.util.Log.d("Gentleman", "Overlay timed out without successful hold. Blocking call.")
                sendDecision(pkg, interaction, "blocked")
                removeOverlay()
                stopSelf()
            }
        }
        handler.postDelayed(decisionTimeoutRunnable!!, decisionTimeoutMs)

        container.setOnTouchListener { _, ev ->
            when (ev.action) {
                MotionEvent.ACTION_DOWN -> {
                    downTime = System.currentTimeMillis()
                    isConfirmed = false
                    progressBar.progress = 0
                    progressBar.progressTintList = ColorStateList.valueOf(Color.parseColor("#FFCC00"))
                    statusText.setTextColor(Color.parseColor("#FFCC00"))

                    updateRunnable = object : Runnable {
                        override fun run() {
                            val elapsed = System.currentTimeMillis() - downTime
                            val progress = ((elapsed.toFloat() / requiredMs) * 100).toInt()

                            if (progress >= 100) {
                                progressBar.progress = 100
                                statusText.text = "Dignity Confirmed!"
                                progressBar.progressTintList = ColorStateList.valueOf(Color.GREEN)
                                statusText.setTextColor(Color.GREEN)

                                if (!isConfirmed) {
                                    isConfirmed = true
                                    decisionTimeoutRunnable?.let { handler.removeCallbacks(it) }
                                    triggerVibration()
                                    sendDecision(pkg, interaction, "allowed")
                                    // Auto-dismiss after 300ms so they can see the completed progress bar
                                    handler.postDelayed({
                                        removeOverlay()
                                        stopSelf()
                                    }, 300)
                                }
                            } else {
                                progressBar.progress = progress
                                statusText.text = "$progress% (Keep holding...)"
                                handler.postDelayed(this, 16)
                            }
                        }
                    }
                    handler.post(updateRunnable!!)
                    true
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    updateRunnable?.let { handler.removeCallbacks(it) }
                    if (!isConfirmed) {
                        decisionTimeoutRunnable?.let { handler.removeCallbacks(it) }
                        sendDecision(pkg, interaction, "blocked")
                        removeOverlay()
                        stopSelf()
                    }
                    true
                }
                else -> true
            }
        }

        overlayView = container
        try {
            android.util.Log.d("Gentleman", "Attempting to add overlay view to WindowManager")
            windowManager?.addView(container, layoutParams)
            android.util.Log.d("Gentleman", "Overlay view successfully added to WindowManager")
        } catch (e: Exception) {
            android.util.Log.e("Gentleman", "Failed to add overlay view to WindowManager", e)
            stopSelf()
        }
    }

    private fun sendDecision(pkg: String, interaction: String, result: String) {
        val intent = Intent(ACTION_PROTECTION_DECISION)
        intent.setPackage(packageName) // Comply with Android 14+ RECEIVER_NOT_EXPORTED requirement
        intent.putExtra(EXTRA_PACKAGE, pkg)
        intent.putExtra(EXTRA_INTERACTION, interaction)
        intent.putExtra(EXTRA_RESULT, result)
        sendBroadcast(intent)
    }

    private fun removeOverlay() {
        try {
            decisionTimeoutRunnable?.let { handler.removeCallbacks(it) }
            decisionTimeoutRunnable = null
            overlayView?.let { windowManager?.removeView(it) }
            overlayView = null
        } catch (_: Exception) {}
    }

    private fun triggerVibration() {
        try {
            val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vm = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as android.os.VibratorManager
                vm.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(VibrationEffect.createOneShot(80, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(80)
            }
        } catch (_: Exception) {}
    }

    override fun onDestroy() {
        removeOverlay()
        super.onDestroy()
    }
}
