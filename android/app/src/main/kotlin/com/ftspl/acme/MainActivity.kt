package com.example.acme

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {

    private val CHANNEL = "pm_scanner"
    private var receiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "startScanner") {
                    registerScanner()
                    result.success(null)
                }
            }
    }

    private fun registerScanner() {
        if (receiver != null) return

        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent == null) return

                val extras = intent.extras ?: return

                // Decode barcode value (PM75 sends byte[])
                val rawData = extras.get("EXTRA_EVENT_DECODE_VALUE")

                val barcode = when (rawData) {
                    is ByteArray -> String(rawData, Charsets.UTF_8)
                    is String -> rawData
                    else -> null
                }

                android.util.Log.d("PM75", "DECODED BARCODE: $barcode")

                if (!barcode.isNullOrEmpty()) {
                    MethodChannel(
                        flutterEngine!!.dartExecutor.binaryMessenger,
                        "pm_scanner"
                    ).invokeMethod("onScan", barcode)
                }
            }
        }

        val filter = IntentFilter("device.scanner.EVENT")
        registerReceiver(receiver, filter)
    }

    override fun onDestroy() {
        receiver?.let { unregisterReceiver(it) }
        receiver = null
        super.onDestroy()
    }
}
