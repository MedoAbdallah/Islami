package com.example.islami

import android.hardware.GeomagneticField
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "islami/qibla",
        ).setMethodCallHandler { call, result ->
            if (call.method != "magneticDeclination") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val latitude = call.argument<Number>("latitude")?.toFloat()
            val longitude = call.argument<Number>("longitude")?.toFloat()
            if (latitude == null || longitude == null ||
                latitude !in -90f..90f || longitude !in -180f..180f
            ) {
                result.error("INVALID_COORDINATES", "Valid coordinates are required.", null)
                return@setMethodCallHandler
            }

            val field = GeomagneticField(
                latitude,
                longitude,
                0f,
                System.currentTimeMillis(),
            )
            result.success(field.declination.toDouble())
        }
    }
}
