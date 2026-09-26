import 'dart:convert';

import 'package:arobo_app/integrity/play_integrity_service.dart';
import 'package:arobo_app/integrity/request_hash.dart';
import 'package:arobo_app/security/device_risk_service.dart';
import 'package:dio/dio.dart';

/// Endpoints the backend gates with requirePlayIntegrity (keep in sync with
/// Backend/routes/v1/*: customerAuthRoutes, secureBookingRoutes,
/// referralRoutes). Matched on the END of the URL path so the base URL /
/// environment doesn't matter.
class IntegrityProtectedPaths {
  IntegrityProtectedPaths._();

  static const Map<String, String> _pathToMethod = {
    '/customer/auth/request-otp': 'POST',
    '/customer/auth/resend-otp': 'POST',
    '/customer/auth/verify-otp': 'POST',
    '/bookings/holds': 'POST',
    '/bookings/create-order': 'POST',
    '/customer/referral/apply': 'POST',
  };

  static bool matches(String method, String path) {
    final m = method.toUpperCase();
    for (final entry in _pathToMethod.entries) {
      if (entry.value == m && path.endsWith(entry.key)) return true;
    }
    return false;
  }
}

/// Attaches a Play Integrity token to protected requests.
///
/// The token is bound to the exact request: this interceptor serialises the
/// body ITSELF, sends that exact string, and hashes those same bytes — so the
/// server's hash of what it received matches what Google signed. If the
/// device can't produce a token, the request still goes out with
/// `X-Play-Integrity-Error: <code>` and the backend decides.
///
/// Must run before anything else re-serialises `options.data`.
class IntegrityInterceptor extends Interceptor {
  IntegrityInterceptor({
    PlayIntegrityService? service,
    Future<List<String>> Function()? riskFlags,
  })  : _service = service ?? PlayIntegrityService.instance,
        _risk = riskFlags ?? DeviceRiskService.instance.current;

  final PlayIntegrityService _service;
  final Future<List<String>> Function() _risk;

  static const String tokenHeader = 'X-Play-Integrity';
  static const String errorHeader = 'X-Play-Integrity-Error';

  /// The exact body string that will go on the wire, or null for "leave the
  /// request alone" (multipart uploads are never protected endpoints).
  static String? canonicalBody(Object? data) {
    if (data == null) return '';
    if (data is String) return data;
    if (data is Map || data is List) return jsonEncode(data);
    return null;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.uri.path;
    if (!IntegrityProtectedPaths.matches(options.method, path)) {
      return handler.next(options);
    }

    final body = canonicalBody(options.data);
    if (body == null) return handler.next(options);

    // Send exactly the bytes we hash.
    options.data = body.isEmpty ? null : body;
    options.headers.remove(tokenHeader);
    options.headers.remove(errorHeader);

    final hash = computeRequestHash(
      method: options.method,
      path: path,
      bodyBytes: utf8.encode(body),
    );
    final result = await _service.tokenFor(hash);
    final risk = await _risk();
    if (risk.isNotEmpty) {
      options.headers[DeviceRiskService.riskHeader] = risk.join(',');
    }
    if (result.token != null) {
      options.headers[tokenHeader] = result.token;
    } else {
      options.headers[errorHeader] = result.error;
    }
    return handler.next(options);
  }
}
