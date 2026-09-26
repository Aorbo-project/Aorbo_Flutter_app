import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Request binding for Play Integrity standard requests.
///
/// MUST stay byte-identical to the backend
/// (Backend/services/integrity/requestBinding.js):
///
///   material = METHOD + "\n" + PATH + "\n" + hex(sha256(RAW_BODY_BYTES))
///   hash     = "v1." + base64url_nopad(sha256(material))
///
/// PATH is the URL path only (no host, no query), e.g.
/// `/api/v1/customer/auth/request-otp`. RAW_BODY_BYTES are the exact bytes
/// sent on the wire — the interceptor serialises the body itself and sends
/// that same string, so both sides hash identical bytes.
///
/// Golden vectors shared with the backend test suite live in
/// test/integrity/request_hash_test.dart.
String computeRequestHash({
  required String method,
  required String path,
  required List<int> bodyBytes,
}) {
  final bodyHex = sha256.convert(bodyBytes).toString();
  final material = '${method.toUpperCase()}\n$path\n$bodyHex';
  final digest = sha256.convert(utf8.encode(material)).bytes;
  return 'v1.${base64Url.encode(digest).replaceAll('=', '')}';
}
