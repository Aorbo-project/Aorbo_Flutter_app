import 'dart:convert';
import 'dart:io';

import 'package:arobo_app/integrity/integrity_interceptor.dart';
import 'package:arobo_app/integrity/play_integrity_service.dart';
import 'package:arobo_app/security/device_key_service.dart';
import 'package:arobo_app/security/pinned_http_client.dart';
import 'package:arobo_app/security/pinned_roots.dart';
import 'package:arobo_app/security/security_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('device binding proof message', () {
    test('byte-identical to Backend services/deviceBinding.refreshProofMessage', () {
      // node -e "require('./services/deviceBinding').refreshProofMessage('rt-1')"
      expect(
        utf8.decode(DeviceKeyService.refreshProofMessage('rt-1')),
        'aorbo-refresh-v1\na33d8c625833429df4658aa6f6940675ca829051a620ed398517039d4a1fc7ec',
      );
    });
  });

  group('TLS pinning', () {
    test('every pinned root parses in Dart\'s TLS stack', () {
      expect(RegExp('BEGIN CERTIFICATE').allMatches(pinnedRootsPem).length, 16);
      final ctx = SecurityContext(withTrustedRoots: false);
      expect(() => ctx.setTrustedCertificatesBytes(utf8.encode(pinnedRootsPem)), returnsNormally);
    });

    test('pins the CA families Cloudflare uses', () {
      for (final root in ['GTS Root R4', 'GlobalSign Root CA', 'ISRG Root X1', 'SSL.com TLS ECC Root CA 2022', 'Certum Trusted Network CA']) {
        expect(pinnedRootsPem, contains('# $root\n'));
      }
    });

    test('remote kill switch turns enforcement off', () {
      SecurityConfig.overrideForTest(pinning: true);
      expect(PinnedHttp.isEnforced, DateTime.now().toUtc().isBefore(PinnedHttp.pinningExpiry));
      SecurityConfig.overrideForTest(pinning: false);
      expect(PinnedHttp.isEnforced, isFalse);
      SecurityConfig.overrideForTest(pinning: true);
    });

    test('expiry is in the future for this release (bump it when refreshing roots)', () {
      expect(PinnedHttp.pinningExpiry.isAfter(DateTime.utc(2026, 12, 31)), isTrue);
    });
  });

  group('X-Device-Risk on protected requests', () {
    RequestOptions protectedRequest() => RequestOptions(
          baseUrl: 'https://api.example.com/api/v1/',
          path: 'bookings/create-order',
          method: 'POST',
          data: {'a': 1},
        );

    test('flags are attached when present', () async {
      final options = protectedRequest();
      await IntegrityInterceptor(
        service: _TokenService(),
        riskFlags: () async => ['hook', 'root'],
      ).onRequest(options, _Handler());
      expect(options.headers['X-Device-Risk'], 'hook,root');
    });

    test('no header when the device is clean', () async {
      final options = protectedRequest();
      await IntegrityInterceptor(service: _TokenService(), riskFlags: () async => [])
          .onRequest(options, _Handler());
      expect(options.headers.containsKey('X-Device-Risk'), isFalse);
    });
  });
}

class _TokenService implements PlayIntegrityService {
  @override
  Future<IntegrityTokenResult> tokenFor(String requestHash) async =>
      const IntegrityTokenResult.token('T');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Handler extends RequestInterceptorHandler {
  @override
  void next(RequestOptions requestOptions) {}
}
