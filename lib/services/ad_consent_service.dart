import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ad_config.dart';

/// UMP (User Messaging Platform) consent gate.
///
/// Google requires a consent check before requesting ads. For EEA/UK users
/// this shows Google's consent form; for most Indian users no form is
/// required and [canRequestAds] simply becomes true. Nothing in the app
/// should load an ad until [ensureConsent] has completed and
/// [canRequestAds] is true.
class AdConsentService {
  AdConsentService._();
  static final AdConsentService instance = AdConsentService._();

  bool _resolved = false;
  bool _canRequestAds = false;

  /// True once consent is resolved AND ads are allowed.
  bool get canRequestAds => _resolved && _canRequestAds;

  /// Run once at startup (after MobileAds.initialize). Safe to await; never
  /// throws — on any failure ads simply stay disabled for the session.
  Future<void> ensureConsent() async {
    if (_resolved) return;
    try {
      final params = ConsentRequestParameters(
        consentDebugSettings: kDebugMode && AdConfig.testDeviceIds.isNotEmpty
            ? ConsentDebugSettings(
                debugGeography: DebugGeography.debugGeographyEea,
                testIdentifiers: AdConfig.testDeviceIds,
              )
            : null,
      );

      await _requestUpdate(params);
      await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
        if (formError != null) {
          debugPrint('Consent form error: ${formError.message}');
        }
      });

      _canRequestAds = await ConsentInformation.instance.canRequestAds();
    } catch (e) {
      debugPrint('Consent flow failed: $e');
      _canRequestAds = false;
    } finally {
      _resolved = true;
      debugPrint('Ad consent resolved — canRequestAds=$_canRequestAds');
    }
  }

  Future<void> _requestUpdate(ConsentRequestParameters params) {
    return _completerify((onOk, onErr) {
      ConsentInformation.instance.requestConsentInfoUpdate(params, onOk, onErr);
    });
  }

  /// Bridges the SDK's success/error callbacks into a Future.
  Future<void> _completerify(
    void Function(void Function() onOk, void Function(FormError) onErr) run,
  ) {
    final completer = Completer<void>();
    run(
      () {
        if (!completer.isCompleted) completer.complete();
      },
      (error) {
        debugPrint('Consent info update error: ${error.message}');
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  /// For a "Privacy options" / "Ad settings" entry point later.
  Future<void> showPrivacyOptions() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((formError) {
        if (formError != null) {
          debugPrint('Privacy options form error: ${formError.message}');
        }
      });
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
    } catch (e) {
      debugPrint('showPrivacyOptions failed: $e');
    }
  }
}
