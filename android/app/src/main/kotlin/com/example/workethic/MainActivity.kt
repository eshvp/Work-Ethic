package com.example.workethic

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import android.os.Build
import com.pravera.flutter_foreground_task.service.ForegroundService

class MainActivity : FlutterActivity() {
    override fun onPause() {
        super.onPause()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val intent = Intent(this, ForegroundService::class.java)
            startForegroundService(intent)
        }
    }

    override fun onResume() {
        super.onResume()
        val intent = Intent(this, ForegroundService::class.java)
        stopService(intent)
    }
}
