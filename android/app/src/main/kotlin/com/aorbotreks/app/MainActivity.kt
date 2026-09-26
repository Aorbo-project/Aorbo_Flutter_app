package com.aorbotreks.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {

    private var playIntegrity: PlayIntegrityChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        playIntegrity = PlayIntegrityChannel(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
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
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "feedCard")
    }
}
