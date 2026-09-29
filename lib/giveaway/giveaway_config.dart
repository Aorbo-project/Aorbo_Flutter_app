import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Aorbo Trek Giveaway — where the campaign pages live and whether the
/// app shows the campaign at all.
///
/// The campaign's content (questions, rules text, draw page, states) is a web
/// page on Aorbo's own server so it can change without an app release. The
/// app only hosts it in a locked-down in-app browser (GiveawayScreen) and
/// carries the actions the page asks for (submit an entry, share, open the
/// rules) to the backend with its own login + Play Integrity token.
///
/// Switch: Firebase Remote Config `giveaway_enabled` (false when unset), so
/// the banner and screen can be turned off without an app release.
/// Test builds can force it on:
///   --dart-define=GIVEAWAY_PREVIEW=true    sample data everywhere (design review)
///   --dart-define=GIVEAWAY_FORCE_ON=true   real backend, before Remote Config is set
class GiveawayConfig {
  GiveawayConfig._();

  /// The only origin the in-app browser will load and accept messages from.
  static const String webHost = 'api.aorbotreks.co.in';
  static final Uri webOrigin = Uri.parse('https://$webHost');

  /// Campaign pages live under this path on [webHost].
  static const String pathPrefix = '/giveaway';

  /// Hosts whose `https://<host>/r/<CODE>` links carry a referral code. Must
  /// match the App Links intent filter in AndroidManifest.xml. EVERY host
  /// listed there must serve /.well-known/assetlinks.json with the Play App
  /// Signing certificate: on Android 11 and lower one failing host stops
  /// all of them from opening the app.
  static const Set<String> referralLinkHosts = {'aorbotreks.co.in', 'api.aorbotreks.co.in'};

  /// Host used in the links people share.
  static const String shareLinkHost = 'aorbotreks.co.in';

  /// Public share link for a referral code.
  static String referralLink(String code) => 'https://$shareLinkHost/r/$code';

  static const bool isPreview = bool.fromEnvironment('GIVEAWAY_PREVIEW');
  static const bool _forceOn = bool.fromEnvironment('GIVEAWAY_FORCE_ON');

  static const String _enabledKey = 'giveaway_enabled';

  /// Whether the campaign is visible in the app. Reads the last activated
  /// Remote Config value (local, synchronous); unset → off.
  static bool get enabled {
    if (isPreview || _forceOn) return true;
    try {
      final value = FirebaseRemoteConfig.instance.getValue(_enabledKey);
      if (value.source == ValueSource.valueStatic) return false;
      return value.asBool();
    } catch (_) {
      return false;
    }
  }

  /// The giveaway page. [code] is the one-time web login code from
  /// POST giveaway/web-code. It rides in the URL FRAGMENT (#c=…), which is
  /// never sent to a server — so it can't land in access logs or a Referer
  /// — and the page removes it from the address bar. Preview builds also
  /// turn on the page's design switcher.
  static Uri pageUri({String? code}) {
    return webOrigin.replace(
      path: '$pathPrefix/',
      queryParameters: isPreview ? {'preview': '1'} : null,
      fragment: code == null ? null : 'c=$code',
    );
  }
}
