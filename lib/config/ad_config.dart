import 'dart:io';

import 'package:flutter/foundation.dart';

/// AdMob configuration.
///
/// Right now every id below is a **Google test id** — real ads never
/// render, no revenue, and clicking is safe. When the real AdMob account
/// + ad units exist, flip [useRealAds] to true and fill the `_real*`
/// maps. The App ID also lives in AndroidManifest.xml / Info.plist and
/// must be swapped there too.
class AdConfig {
  AdConfig._();

  /// Master switch. While false the app always serves Google test ads.
  static const bool useRealAds = false;

  /// AdMob App ID — also declared in the native manifest.
  static String get appId => Platform.isAndroid
      ? (useRealAds ? _realAppIdAndroid : _testAppIdAndroid)
      : (useRealAds ? _realAppIdIos : _testAppIdIos);

  /// Native ad unit for the in-feed sponsored card (dashboard + search).
  static String get nativeFeedUnitId => Platform.isAndroid
      ? (useRealAds ? _realNativeAndroid : _testNativeAndroid)
      : (useRealAds ? _realNativeIos : _testNativeIos);

  // ── Google's public test ids (do not change) ──────────────────────────
  static const _testAppIdAndroid = 'ca-app-pub-3940256099942544~3347511713';
  static const _testAppIdIos = 'ca-app-pub-3940256099942544~1458002511';
  // native advanced (video-capable) test unit
  static const _testNativeAndroid = 'ca-app-pub-3940256099942544/2247696110';
  static const _testNativeIos = 'ca-app-pub-3940256099942544/3986624511';

  // ── Real ids — fill when the AdMob account is set up ──────────────────
  static const _realAppIdAndroid = '';
  static const _realAppIdIos = '';
  static const _realNativeAndroid = '';
  static const _realNativeIos = '';

  /// Test-device ids so real ads (once live) never count our own taps.
  /// Add each dev/QA device's id (printed in logcat on first ad request).
  static const List<String> testDeviceIds = <String>[];

  static bool get isDebug => kDebugMode;
}
