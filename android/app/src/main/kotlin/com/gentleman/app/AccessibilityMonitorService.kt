package com.gentleman.app

import android.accessibilityservice.AccessibilityService
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Rect
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.widget.FrameLayout

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

    private var decisionReceiver: BroadcastReceiver? = null
    
    // Blocker overlays targeting physical call button coordinates
    private val activeBlockers = mutableListOf<Pair<View, AccessibilityNodeInfo>>()
    private var blockersEnabled = true
    private val blockersHandler = android.os.Handler(android.os.Looper.getMainLooper())
    private var pendingCallType = ""

    private var currentPackageName = ""
    private var currentClassName = ""

    private fun hasMessageInput(node: AccessibilityNodeInfo?): Boolean {
        if (node == null) return false
        try {
            val resId = node.viewIdResourceName?.lowercase() ?: ""
            val desc = node.contentDescription?.toString()?.lowercase() ?: ""
            val text = node.text?.toString()?.lowercase() ?: ""

            // Exclude search bars
            if (resId.contains("search") || desc.contains("search") || text.contains("search")) {
                return false
            }

            // Message box matches
            if (resId.contains("entry") || resId.contains("message_box") || resId.contains("input")) {
                return true
            }
            if (desc.contains("message") || desc.contains("type a message")) {
                return true
            }
            if (text.contains("message") || text.contains("type a message")) {
                return true
            }

            for (i in 0 until node.childCount) {
                if (hasMessageInput(node.getChild(i))) return true
            }
        } catch (_: Exception) {}
        return false
    }

    private fun isChatScreen(pkg: String, className: String, root: AccessibilityNodeInfo?): Boolean {
        android.util.Log.d("Gentleman", "Checking isChatScreen for pkg = $pkg, class = $className")
        if (className.contains("HomeActivity", ignoreCase = true) || 
            className.contains("MainActivity", ignoreCase = true) || 
            className.contains("TabActivity", ignoreCase = true)) {
            return false
        }
        val hasInput = hasMessageInput(root)
        android.util.Log.d("Gentleman", "isChatScreen check hasMessageInput = $hasInput")
        return hasInput
    }

    private val scanRunnable = Runnable {
        if (!blockersEnabled) {
            android.util.Log.d("Gentleman", "scanRunnable: blockers are currently disabled (unlock cooldown)")
            return@Runnable
        }
        val root = rootInActiveWindow
        android.util.Log.d("Gentleman", "scanRunnable running: package = $currentPackageName, class = $currentClassName, hasRoot = ${root != null}")
        if (!isChatScreen(currentPackageName, currentClassName, root)) {
            android.util.Log.d("Gentleman", "scanRunnable: NOT a chat screen, clearing blockers.")
            updateBlockerOverlay(emptyList())
            return@Runnable
        }
        val callButtons = mutableListOf<Pair<AccessibilityNodeInfo, String>>()
        root?.let { r ->
            findCallButtons(r, callButtons)
        }
        android.util.Log.d("Gentleman", "scanRunnable: found ${callButtons.size} call buttons")
        updateBlockerOverlay(callButtons)
    }

    override fun onCreate() {
        super.onCreate()
        createSarcasmNotificationChannel()
        scheduleSarcasmNotification()

        decisionReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent == null) return
                val result = intent.getStringExtra("result")
                android.util.Log.d("Gentleman", "Received decision result: $result")
                
                if (result == "allowed") {
                    // Temporarily disable blockers to allow programmatic click to pass through
                    blockersEnabled = false
                    removeAllBlockers()
                    
                    // Poll rootInActiveWindow to click the call button as soon as the overlay window fully dismisses
                    var attempts = 0
                    val runClick = object : Runnable {
                        override fun run() {
                            val root = rootInActiveWindow
                            val freshButtons = mutableListOf<Pair<AccessibilityNodeInfo, String>>()
                            findCallButtons(root, freshButtons)
                            
                            val target = freshButtons.find { it.second == pendingCallType }?.first
                            if (target != null) {
                                android.util.Log.d("Gentleman", "Found fresh call node on attempt $attempts, clicking!")
                                clickNodeRecursively(target)
                                
                                // Re-enable blockers after 8 seconds
                                blockersHandler.removeCallbacksAndMessages(null)
                                blockersHandler.postDelayed({
                                    blockersEnabled = true
                                }, 8000)
                                return
                            }
                            
                            attempts++
                            if (attempts < 10) {
                                handler.postDelayed(this, 80)
                            } else {
                                android.util.Log.e("Gentleman", "Failed to find fresh call node after 10 attempts.")
                                blockersEnabled = true
                            }
                        }
                    }
                    handler.postDelayed(runClick, 50)
                } else if (result == "blocked") {
                    android.util.Log.d("Gentleman", "Call blocked by user - no action taken.")
                }
            }
        }
        val filter = IntentFilter("com.gentleman.ACTION_PROTECTION_DECISION")
        if (android.os.Build.VERSION.SDK_INT >= 33) {
            registerReceiver(decisionReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(decisionReceiver, filter)
        }
    }

    override fun onDestroy() {
        sarcasmRunnable?.let { handler.removeCallbacks(it) }
        decisionReceiver?.let { unregisterReceiver(it) }
        blockersHandler.removeCallbacksAndMessages(null)
        removeAllBlockers()
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
                handler.postDelayed(this, 3600000L)
            }
        }
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
        val pkg = event.packageName?.toString() ?: ""

        if (type == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            currentPackageName = pkg
            currentClassName = event.className?.toString() ?: ""
            android.util.Log.d("Gentleman", "Active screen changed: package = $currentPackageName, class = $currentClassName")
        }

        // Print debug info for every window content change or state change to help solve layout bugs
        if (pkg == "com.whatsapp" || pkg == "com.instagram.android") {
            android.util.Log.d("Gentleman", "onAccessibilityEvent: type = ${AccessibilityEvent.eventTypeToString(type)}, pkg = $pkg, class = ${event.className}")
        }

        if (type == AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED || type == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            // Debounce scanning to avoid blocking the main thread during typing/scrolling
            handler.removeCallbacks(scanRunnable)
            handler.postDelayed(scanRunnable, 50)
        }
    }

    private fun findCallButtons(node: AccessibilityNodeInfo?, list: MutableList<Pair<AccessibilityNodeInfo, String>>) {
        if (node == null) return
        val type = isCallButtonClicked(node)
        if (type != null) {
            // Traverse up to find the clickable ancestor if this node isn't directly clickable
            var clickableNode = node
            while (clickableNode != null && !clickableNode.isClickable) {
                clickableNode = clickableNode.parent
            }
            if (clickableNode != null) {
                // Check if we already have it in the list to avoid duplicate bounds overlay
                if (list.none { it.first == clickableNode }) {
                    list.add(Pair(clickableNode, type))
                }
                return
            }
        }
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            findCallButtons(child, list)
        }
    }

    private fun isCallButtonClicked(node: AccessibilityNodeInfo): String? {
        val desc = node.contentDescription?.toString()?.lowercase() ?: ""
        val text = node.text?.toString()?.lowercase() ?: ""

        // EXTREMELY STRICT MATCHING FOR HEADER BUTTONS ONLY:
        // Must have description containing exactly voice/video call and MUST have empty/null text!
        if (text.isNotEmpty()) return null

        val isVideo = desc == "video call" || desc == "start video call"
        val isVoice = desc == "voice call" || desc == "start voice call" || desc == "audio call" || desc == "start audio call"

        if (isVideo) return "video"
        if (isVoice) return "voice"

        return null
    }

    private fun clickNodeRecursively(node: AccessibilityNodeInfo?): Boolean {
        var temp = node
        while (temp != null) {
            if (temp.isClickable) {
                val clicked = temp.performAction(AccessibilityNodeInfo.ACTION_CLICK)
                if (clicked) {
                    android.util.Log.d("Gentleman", "Successfully clicked call node: ${temp.viewIdResourceName}")
                    return true
                }
            }
            temp = temp.parent
        }
        return false
    }

    @Synchronized
    private fun updateBlockerOverlay(buttons: List<Pair<AccessibilityNodeInfo, String>>) {
        if (!blockersEnabled) {
            removeAllBlockers()
            return
        }

        val wm = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        
        // Remove old blockers to prevent duplicates and follow screen changes/rotations
        removeAllBlockers()

        val screenHeight = resources.displayMetrics.heightPixels
        for (pair in buttons) {
            val node = pair.first
            val type = pair.second
            val rect = Rect()
            node.getBoundsInScreen(rect)

            if (rect.isEmpty || rect.left < 0 || rect.top < 0) continue

            // Bulletproof coordinate filter: call buttons in header are ALWAYS between y = 60 and y = 520 pixels
            if (rect.top < 60 || rect.bottom > 520) {
                android.util.Log.d("Gentleman", "Ignoring matched node outside header bounds (y = 60 to 520): $rect")
                continue
            }

            try {
                val blocker = createBlockerView(rect, node, type)
                val params = WindowManager.LayoutParams(
                    rect.width(),
                    rect.height(),
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O)
                        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                    else
                        @Suppress("DEPRECATION") WindowManager.LayoutParams.TYPE_PHONE,
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                    PixelFormat.TRANSLUCENT
                )
                params.gravity = Gravity.TOP or Gravity.LEFT
                params.x = rect.left
                params.y = rect.top

                wm.addView(blocker, params)
                activeBlockers.add(Pair(blocker, node))
                android.util.Log.d("Gentleman", "Added blocker view at: $rect for type: $type")
            } catch (e: Exception) {
                android.util.Log.e("Gentleman", "Failed to add blocker view", e)
            }
        }
    }

    @Synchronized
    private fun removeAllBlockers() {
        val wm = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        for (pair in activeBlockers) {
            try {
                wm.removeView(pair.first)
            } catch (_: Exception) {}
        }
        activeBlockers.clear()
    }

    private fun createBlockerView(rect: Rect, targetNode: AccessibilityNodeInfo, type: String): View {
        val context = this
        val view = FrameLayout(context)

        // Draw a small indicator badge (red dot inside a black ring - our app logo design)
        val indicator = View(context)
        val size = (18 * resources.displayMetrics.density).toInt()
        val params = FrameLayout.LayoutParams(size, size, Gravity.CENTER)
        indicator.layoutParams = params

        val shape = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(Color.parseColor("#FF3B30")) // red dot
            setStroke((2 * resources.displayMetrics.density).toInt(), Color.BLACK) // black ring
        }
        indicator.background = shape
        view.addView(indicator)

        view.setOnTouchListener { _, event ->
            if (event.action == MotionEvent.ACTION_DOWN) {
                android.util.Log.d("Gentleman", "Blocker view touched! Rect: $rect, Type: $type")
                pendingCallType = type
                
                if (!android.provider.Settings.canDrawOverlays(context)) {
                    android.util.Log.d("Gentleman", "Cannot show overlay: overlay permission not granted!")
                    return@setOnTouchListener true
                }

                try {
                    val prefs = getSharedPreferences("gentleman_settings", android.content.Context.MODE_PRIVATE)
                    val holdMs = prefs.getInt("holdDurationMs", 1000)
                    val svcIntent = Intent(context, OverlayService::class.java).apply {
                        putExtra(OverlayService.EXTRA_PACKAGE, "com.whatsapp")
                        putExtra(OverlayService.EXTRA_INTERACTION, type)
                        putExtra(OverlayService.EXTRA_HOLD_DURATION_MS, holdMs)
                    }
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                        startForegroundService(svcIntent)
                    } else {
                        startService(svcIntent)
                    }
                } catch (e: Exception) {
                    android.util.Log.e("Gentleman", "Failed to start OverlayService from blocker", e)
                }
            }
            true
        }
        return view
    }

    private fun dumpNodeHierarchy(node: AccessibilityNodeInfo?, depth: Int) {
        if (node == null) return
        try {
            val indent = " ".repeat(depth * 2)
            val resId = node.viewIdResourceName ?: "null"
            val desc = node.contentDescription ?: "null"
            val text = node.text ?: "null"
            val clickable = node.isClickable
            android.util.Log.d("GentlemanDump", "$indent[$depth] ResId: $resId, Desc: $desc, Text: $text, Clickable: $clickable")
            
            for (i in 0 until node.childCount) {
                dumpNodeHierarchy(node.getChild(i), depth + 1)
            }
        } catch (_: Exception) {}
    }

    override fun onInterrupt() {}
}
