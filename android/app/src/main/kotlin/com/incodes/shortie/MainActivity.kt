package com.incodes.shortie
import io.flutter.embedding.android.FlutterFragmentActivity

// <<< Code Start *** >>> Google Ad Code <<< ***

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

// *** >>> Google Ad Code <<< *** Code End >>>

class MainActivity: FlutterFragmentActivity() {

    // <<< Code Start *** >>> Google Ad Code <<< ***

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val context: Context = applicationContext

        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "medium", MediumNativeAdFactory(context))
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "large", LargeNativeAdFactory(context))
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "full", FullNativeAdFactory(context))
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)

        val context: Context = applicationContext

        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "medium")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "large")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "full")
    }

    // *** >>> Google Ad Code <<< *** Code End >>>

}