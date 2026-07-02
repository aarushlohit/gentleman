package com.gentleman.app

import android.app.Service
import android.content.Intent
import android.os.IBinder

class OverlayService : Service() {
    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Overlay drawing logic to show Hold-to-Confirm UI would go here.
        return START_STICKY
    }
}
