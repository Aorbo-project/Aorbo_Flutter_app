package com.aorbotreks.app

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {

    private var playIntegrity: PlayIntegrityChannel? = null
    private var deviceSecurity: DeviceSecurityChannel? = null
    private var screenSecurity: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        playIntegrity = PlayIntegrityChannel(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
        deviceSecurity = DeviceSecurityChannel(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
        // FLAG_SECURE for the OTP step and payment (lib/security/screen_security.dart).
        screenSecurity = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.aorbotreks.app/screen_security"
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "setSecure" -> {
                        val secure = call.argument<Boolean>("secure") == true
                        runOnUiThread {
                            if (secure) {
                                window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                            } else {
                                window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                            }
                        }
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
        }
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "feedCard",
            NativeAdFactoryImpl(applicationContext)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        playIntegrity?.dispose()
        playIntegrity = null
        deviceSecurity?.dispose()
        deviceSecurity = null
        screenSecurity?.setMethodCallHandler(null)
        screenSecurity = null
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "feedCard")
    }
}
