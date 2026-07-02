package com.gentleman.app

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent

class AccessibilityMonitorService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // TODO: Implement detection of call button presses and forward to Flutter via MethodChannel or broadcasts.
    }

    override fun onInterrupt() {}
}
