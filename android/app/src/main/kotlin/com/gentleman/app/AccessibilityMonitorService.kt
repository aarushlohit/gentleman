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

                // Broadcast the event locally for MainActivity to pick up and forward to Flutter.
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
