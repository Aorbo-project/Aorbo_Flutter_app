import 'dart:convert';
import 'dart:io';

import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/security/pinned_roots.dart';
import 'package:arobo_app/security/security_config.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

/// TLS policy for the API client: trust ONLY the root CAs Cloudflare may use
/// for our edge certificate ([pinnedRootsPem]), not every CA on the phone.
///
/// Why roots, not our leaf certificate: Cloudflare re-issues the edge cert
/// every ~90 days and may switch between Google Trust Services, Let's
/// Encrypt and SSL.com at any renewal — pinning the leaf (or one CA) would
/// break every installed app on some future renewal. Pinning the set of
/// roots still defeats interception proxies (Burp/Charles/mitmproxy) whose
/// CA is not one of them, even on phones where that CA was installed into
/// the system store.
///
/// Three safety valves so pinning can never permanently brick the app:
///  1. Remote kill switch — Remote Config `api_tls_pinning_enabled`
///     (fetched from Google, unaffected by our pinning).
///  2. [pinningExpiry] — after this date the app falls back to the system
///     store by itself (same idea as Android's pin-set expiration), so a
///     forgotten build can't break years later. Refresh the root list and
///     push this date forward in each release.
///  3. Every rejected certificate is reported (over a separate, unpinned
///     connection) to POST /device-security/report, which e-mails a
///     security alert — many at once means "Cloudflare changed CA: flip
///     the switch", a single one means "someone intercepted a phone".
class PinnedHttp {
  PinnedHttp._();

  static final DateTime pinningExpiry = DateTime.utc(2027, 6, 30);

  static bool get isEnforced =>
      SecurityConfig.pinningEnabled && DateTime.now().toUtc().isBefore(pinningExpiry);

  static SecurityContext? _context;

  static SecurityContext _pinnedContext() {
    return _context ??= SecurityContext(withTrustedRoots: false)
      ..setTrustedCertificatesBytes(utf8.encode(pinnedRootsPem));
  }

  /// HttpClient factory for Dio's IOHttpClientAdapter.
  static HttpClient createClient() {
    if (!isEnforced) return HttpClient();
    final client = HttpClient(context: _pinnedContext());
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      _reportMismatch(host, cert.issuer);
      return false; // never accept a certificate outside the pinned roots
    };
    return client;
  }

  /// Point a Dio instance at the pinned client factory.
  static void apply(Dio dio) {
    dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: createClient);
  }

  static bool _reported = false;

  static void _reportMismatch(String host, String issuer) {
    if (_reported) return; // once per app run is enough to raise the alarm
    _reported = true;
    debugPrint('TLS pin mismatch for $host (issuer: $issuer)');
    // Deliberately a plain, UNPINNED client: the pinned one is what just
    // failed. The report carries no secrets.
    () async {
      try {
        await Dio(BaseOptions(
          baseUrl: NetworkUrl.baseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: {'Content-Type': 'application/json'},
        )).post('device-security/report', data: {
          'event': 'tls_pin_mismatch',
          'host': host,
          'issuer': issuer,
        });
      } catch (_) {}
    }();
  }
}
