package com.example.tagmyid

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.tagmyid.device/api"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeDevice" -> {
                    try {
                        // TODO: Initialize your DeviceAPI .aar classes here
                        // Example: DeviceAPI.getInstance(context).init()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INIT_FAILED", e.message, null)
                    }
                }
                "scanData" -> {
                    try {
                        // TODO: Call your hardware scanning/reading methods from .aar here
                        val scannedData = "RFID_TAG_PRO_00123"
                        result.success(scannedData)
                    } catch (e: Exception) {
                        result.error("SCAN_FAILED", e.message, null)
                    }
                }
                "releaseDevice" -> {
                    try {
                        // TODO: Release hardware resources
                        result.success(null)
                    } catch (e: Exception) {
                        result.success(null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
