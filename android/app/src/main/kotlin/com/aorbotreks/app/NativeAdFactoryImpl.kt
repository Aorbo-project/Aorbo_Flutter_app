package com.aorbotreks.app

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

/**
 * Binds a loaded [NativeAd] into res/layout/native_ad_feed_card.xml.
 * Registered under the id "feedCard" in [MainActivity].
 */
class NativeAdFactoryImpl(private val context: Context) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_feed_card, null) as NativeAdView

        val headline = adView.findViewById<TextView>(R.id.ad_headline)
        headline.text = nativeAd.headline
        adView.headlineView = headline

        val media = adView.findViewById<MediaView>(R.id.ad_media)
        nativeAd.mediaContent?.let { media.mediaContent = it }
        adView.mediaView = media

        val advertiser = adView.findViewById<TextView>(R.id.ad_advertiser)
        val advertiserText = nativeAd.advertiser ?: nativeAd.store
        if (advertiserText.isNullOrBlank()) {
            advertiser.visibility = View.GONE
        } else {
            advertiser.text = advertiserText
            advertiser.visibility = View.VISIBLE
            adView.advertiserView = advertiser
        }

        val body = adView.findViewById<TextView>(R.id.ad_body)
        if (nativeAd.body.isNullOrBlank()) {
            body.visibility = View.GONE
        } else {
            body.text = nativeAd.body
            body.visibility = View.VISIBLE
            adView.bodyView = body
        }

        val cta = adView.findViewById<TextView>(R.id.ad_call_to_action)
        if (nativeAd.callToAction.isNullOrBlank()) {
            cta.visibility = View.GONE
        } else {
            cta.text = nativeAd.callToAction
            cta.visibility = View.VISIBLE
            adView.callToActionView = cta
        }

        // Binds all registered views + records the impression.
        adView.setNativeAd(nativeAd)
        return adView
    }
}
