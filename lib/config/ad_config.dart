import 'dart:io';

import 'package:flutter/foundation.dart';

/// AdMob configuration.
///
/// REAL ads since 1.0.0+45 (20 Nov 2026; owner: AdMob account "Ready"). Debug builds and the
/// test devices below still get Google's test ads, so our own taps never count (invalid
/// clicks can close the AdMob account). The server sends the Google fallback only to builds
/// >= 45 (Backend utils/realAdsRule.js): older builds carry the test ids.
class AdConfig {
  AdConfig._();

  /// Master switch. While false the app always serves Google test ads.
  static const bool useRealAds = !kDebugMode;

  /// AdMob App ID — also declared in the native manifest.
  static String get appId => Platform.isAndroid
      ? (useRealAds ? _realAppIdAndroid : _testAppIdAndroid)
      : (useRealAds && _realAppIdIos.isNotEmpty ? _realAppIdIos : _testAppIdIos);

  /// Native ad unit for the in-feed sponsored card (dashboard + search).
  static String get nativeFeedUnitId => Platform.isAndroid
      ? (useRealAds ? _realNativeAndroid : _testNativeAndroid)
      : (useRealAds && _realNativeIos.isNotEmpty ? _realNativeIos : _testNativeIos);

  // ── Google's public test ids (do not change) ──────────────────────────
  static const _testAppIdAndroid = 'ca-app-pub-3940256099942544~3347511713';
  static const _testAppIdIos = 'ca-app-pub-3940256099942544~1458002511';
  // native advanced (video-capable) test unit
  static const _testNativeAndroid = 'ca-app-pub-3940256099942544/2247696110';
  static const _testNativeIos = 'ca-app-pub-3940256099942544/3986624511';

  // ── Real ids — AdMob account created 2026-09-12. iOS app not set up yet,
  // so those stay blank until an iOS AdMob app + ad unit exist. ───────────
  static const _realAppIdAndroid = 'ca-app-pub-1409410183966075~2943255858';
  static const _realAppIdIos = '';
  static const _realNativeAndroid = 'ca-app-pub-1409410183966075/1490573383';
  static const _realNativeIos = '';

  /// Test-device ids so real ads (once live) never count our own taps, and
  /// so the UMP consent form can be forced for QA. Each device's id is
  /// printed in logcat on first ad request ("Use ... addTestDeviceHashedId").
  static const List<String> testDeviceIds = <String>[
    'B5ED45CBAF02C4155865CC9C2B16B280', // Galaxy A03 (SM-A035F) — dev device
  ];

  static bool get isDebug => kDebugMode;
}
