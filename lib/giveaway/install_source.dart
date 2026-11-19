import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../repository/network_url.dart';
import '../repository/repository.dart';
import '../utils/shared_preferences.dart';

/// Where this install came from (SEO plan phase 2, 19 Nov 2026: "did Google bring bookings?").
///
/// The Play install referrer carries utm_* values: the website tags its Play Store links
/// `utm_source=aorbotreks.com & utm_medium=(search engine) & utm_campaign=(page kind)`
/// (React-web src/utils/visitSource.js); shared trek / referral links add their own; a plain
/// Play Store install reports utm_source=google-play & utm_medium=organic.
/// Read once with the referrer (ReferralLinkCapture), kept on the phone, and sent once after
/// sign-in to POST /api/v1/customer/acquisition (the backend keeps the first one per customer).
/// Only short lowercase tokens are kept, so nothing personal leaves the phone.
class InstallSource {
  InstallSource._();

  static const String savedKey = 'install_source_v1';
  static const String sentKey = 'install_source_sent_v1';
  static final RegExp _token = RegExp(r'^[a-z0-9][a-z0-9._-]{0,39}$');

  static String? _clean(String? v) {
    final s = (v ?? '').trim().toLowerCase();
    return _token.hasMatch(s) ? s : null;
  }

  /// {source, medium, campaign} from an install referrer string, or null without a valid source.
  static Map<String, String>? parse(String? referrer) {
    if (referrer == null || referrer.isEmpty || referrer.length > 1024) return null;
    try {
      final q = Uri.splitQueryString(referrer);
      final source = _clean(q['utm_source']);
      if (source == null) return null;
      final medium = _clean(q['utm_medium']);
      final campaign = _clean(q['utm_campaign']);
      return {
        'source': source,
        if (medium != null) 'medium': medium,
        if (campaign != null) 'campaign': campaign,
      };
    } catch (_) {
      return null;
    }
  }

  /// Keeps the referrer's source on the phone (first one only).
  static Future<void> saveFromReferrer(String? referrer) async {
    final parsed = parse(referrer);
    if (parsed == null) return;
    final sp = await SpUtil.getInstance();
    if (sp.getString(savedKey) != null) return;
    await sp.putString(savedKey, json.encode(parsed));
  }

  /// Sends the saved source once, when signed in. A network failure leaves it for next time.
  static Future<void> sendOnce({Repository? repository}) async {
    try {
      final sp = await SpUtil.getInstance();
      if (sp.getBool(sentKey) == true) return;
      final saved = sp.getString(savedKey);
      if (saved is! String || saved.isEmpty) return;
      final response = await (repository ?? Repository()).postApiCall(url: NetworkUrl.customerAcquisition, body: saved);
      if (response != null) await sp.putBool(sentKey, true);
    } catch (e) {
      // 4xx (Repository throws): the server refused this value; do not retry it forever.
      if ('$e'.contains('valid source')) {
        final sp = await SpUtil.getInstance();
        await sp.putBool(sentKey, true);
      }
      debugPrint('InstallSource: not sent: $e');
    }
  }
}
