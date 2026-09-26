import 'dart:convert';

import 'package:arobo_app/integrity/integrity_interceptor.dart';
import 'package:arobo_app/integrity/play_integrity_service.dart';
import 'package:arobo_app/integrity/request_hash.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// GOLDEN vectors — identical to
/// Backend/tests/__tests__/playIntegrityBindingConfig.test.js. If one side
/// changes the canonical form, both must change together, or every
/// protected request is blocked in enforce mode.
void main() {
  group('computeRequestHash golden vectors (keep in sync with backend)', () {
    final vectors = <List<String>>[
      ['post', '/api/v1/customer/auth/request-otp', '{"phone":"9876543210"}', 'v1.Cm4cDW2xwfHUo4IGRbjX3dafjtFPLgdFbdYYEHPPze8'],
      ['POST', '/api/v1/customer/auth/request-otp', '', 'v1.U1UBRfIzOldzBP2SIAIjzQJdEroWZ7wF-VmBWbbYcJE'],
      ['POST', '/api/v1/bookings/create-order', '{"note":"ట్రెక్ ₹999"}', 'v1.nDYiLEFQItwjLJ2QDngAQYQF3A98pCaY4pfTWdcFGT0'],
    ];
    for (final v in vectors) {
      test('${v[0]} ${v[1]} ${v[2]}', () {
        expect(
          computeRequestHash(method: v[0], path: v[1], bodyBytes: utf8.encode(v[2])),
          v[3],
        );
      });
    }

    test('fits Google\'s 500-byte limit', () {
      final h = computeRequestHash(
        method: 'POST',
        path: '/${'a' * 5000}',
        bodyBytes: utf8.encode('b' * 100000),
      );
      expect(h.length, lessThan(500));
    });
  });

  group('IntegrityProtectedPaths', () {
    test('matches protected endpoints regardless of base URL', () {
      expect(IntegrityProtectedPaths.matches('post', '/api/v1/customer/auth/request-otp'), isTrue);
      expect(IntegrityProtectedPaths.matches('POST', '/staging/api/v1/bookings/create-order'), isTrue);
      expect(IntegrityProtectedPaths.matches('POST', '/api/v1/customer/referral/apply'), isTrue);
    });

    test('ignores other endpoints and methods', () {
      expect(IntegrityProtectedPaths.matches('POST', '/api/v1/bookings/verify-payment'), isFalse);
      expect(IntegrityProtectedPaths.matches('POST', '/api/v1/customer/auth/refresh'), isFalse);
      expect(IntegrityProtectedPaths.matches('GET', '/api/v1/customer/referral/apply'), isFalse);
      expect(IntegrityProtectedPaths.matches('DELETE', '/api/v1/bookings/holds'), isFalse);
    });
  });

  group('IntegrityInterceptor', () {
    test('serialises the body once, sends that exact string, binds the token to it', () async {
      final fake = _FakeService(const IntegrityTokenResult.token('TOKEN'));
      final options = RequestOptions(
        baseUrl: 'https://api.example.com/api/v1/',
        path: 'customer/auth/request-otp',
        method: 'POST',
        data: {'phone': '9876543210'},
      );
      final handler = _CapturingHandler();
      await IntegrityInterceptor(service: fake).onRequest(options, handler);

      expect(handler.passed, isNotNull);
      expect(options.data, '{"phone":"9876543210"}');
      expect(options.headers['X-Play-Integrity'], 'TOKEN');
      expect(options.headers.containsKey('X-Play-Integrity-Error'), isFalse);
      // same hash the backend computes for this request
      expect(fake.lastHash, 'v1.Cm4cDW2xwfHUo4IGRbjX3dafjtFPLgdFbdYYEHPPze8');
    });

    test('already-encoded JSON string bodies are hashed as-is', () async {
      final fake = _FakeService(const IntegrityTokenResult.token('T'));
      final options = RequestOptions(
        baseUrl: 'https://api.example.com/api/v1/',
        path: 'customer/auth/request-otp',
        method: 'POST',
        data: '{"phone":"9876543210"}',
      );
      await IntegrityInterceptor(service: fake).onRequest(options, _CapturingHandler());
      expect(fake.lastHash, 'v1.Cm4cDW2xwfHUo4IGRbjX3dafjtFPLgdFbdYYEHPPze8');
    });

    test('device failure → request still sent with the error code', () async {
      final fake = _FakeService(const IntegrityTokenResult.error('PLAY_SERVICES_NOT_FOUND'));
      final options = RequestOptions(
        baseUrl: 'https://api.example.com/api/v1/',
        path: 'bookings/create-order',
        method: 'POST',
        data: {'a': 1},
      );
      final handler = _CapturingHandler();
      await IntegrityInterceptor(service: fake).onRequest(options, handler);
      expect(handler.passed, isNotNull);
      expect(options.headers['X-Play-Integrity-Error'], 'PLAY_SERVICES_NOT_FOUND');
      expect(options.headers.containsKey('X-Play-Integrity'), isFalse);
    });

    test('unprotected requests are untouched and never ask for a token', () async {
      final fake = _FakeService(const IntegrityTokenResult.token('T'));
      final data = {'x': 1};
      final options = RequestOptions(
        baseUrl: 'https://api.example.com/api/v1/',
        path: 'treks',
        method: 'POST',
        data: data,
      );
      await IntegrityInterceptor(service: fake).onRequest(options, _CapturingHandler());
      expect(options.data, same(data));
      expect(fake.calls, 0);
    });

    test('multipart bodies are never rewritten', () async {
      final fake = _FakeService(const IntegrityTokenResult.token('T'));
      final form = FormData.fromMap({'f': 'v'});
      final options = RequestOptions(
        baseUrl: 'https://api.example.com/api/v1/',
        path: 'customer/referral/apply',
        method: 'POST',
        data: form,
      );
      await IntegrityInterceptor(service: fake).onRequest(options, _CapturingHandler());
      expect(options.data, same(form));
      expect(fake.calls, 0);
    });
  });
}

class _FakeService implements PlayIntegrityService {
  _FakeService(this.result);
  final IntegrityTokenResult result;
  String? lastHash;
  int calls = 0;

  @override
  Future<IntegrityTokenResult> tokenFor(String requestHash) async {
    calls++;
    lastHash = requestHash;
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CapturingHandler extends RequestInterceptorHandler {
  RequestOptions? passed;

  @override
  void next(RequestOptions requestOptions) {
    passed = requestOptions;
  }
}
