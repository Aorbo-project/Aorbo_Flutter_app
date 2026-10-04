// The network layer's side of force update: a 426, or a 403 with code
// APP_UPDATE_REQUIRED, from any request — including /customer/auth/refresh —
// opens the update screen once, and is never a logout, a retry or a
// Crashlytics report. Runs the real Repository interceptors over a fake
// transport.

import 'dart:convert';
import 'dart:typed_data';

import 'package:arobo_app/app_update/app_update_gate.dart';
import 'package:arobo_app/app_update/app_update_policy.dart'
    show AppUpdateBlock;
import 'package:arobo_app/app_update/app_version_info.dart';
import 'package:arobo_app/main.dart' show sp;
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/services/app_feedback.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_test_mocks.dart';

typedef _Reply = ({int status, Object body});

/// Answers by path suffix, in order for repeated calls; records every request.
class _FakeTransport implements HttpClientAdapter {
  final Map<String, List<_Reply>> replies = {};
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    for (final entry in replies.entries) {
      if (options.path.endsWith(entry.key) && entry.value.isNotEmpty) {
        final r = entry.value.length > 1
            ? entry.value.removeAt(0)
            : entry.value.first;
        return ResponseBody.fromString(
          jsonEncode(r.body),
          r.status,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
    }
    return ResponseBody.fromString(
      '{"success":false}',
      404,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _storeUrl =
    'https://play.google.com/store/apps/details?id=com.aorbotreks.app';
const _block426 = {
  'success': false,
  'code': 'APP_UPDATE_REQUIRED',
  'message': 'A plain message to show the user',
  'store_url': _storeUrl,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeCrashlyticsPlatform crashlytics;
  late _FakeTransport transport;
  late List<AppUpdateBlock> presented;
  late AppUpdateGate gate;
  final repo = Repository();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sp = await SpUtil.getInstance();
    // Once: FirebaseCrashlytics.instance keeps the first platform it sees.
    crashlytics = await setUpFakeFirebase();
    await repo.initRepo();
  });

  setUp(() async {
    Get.testMode = true;
    crashlytics.recordedExceptions.clear();
    transport = _FakeTransport();
    repo.httpClientAdapterForTesting = transport;
    presented = [];
    gate = AppUpdateGate(fetchPolicy: () async => null, present: presented.add);
    AppUpdateGate.instance = gate;
    AppVersionInfo.current = AppVersionInfo.from(
      version: '1.1.0',
      buildNumber: '24',
      platform: 'android',
    );
    await sp!.clear();
    await sp!.putString(SpUtil.accessToken, 'access-1');
    await sp!.putString(SpUtil.refreshToken, 'refresh-1');
    await sp!.putBool(SpUtil.isLoggedIn, true);
  });

  tearDown(() {
    gate.dispose();
    AppFeedback.muted = false;
    AppVersionInfo.current = null;
    Get.reset();
  });

  Future<DioException> getFails(String path) async {
    try {
      await repo.dio.get(path);
    } on DioException catch (e) {
      return e;
    }
    fail('expected $path to fail');
  }

  void expectStillSignedIn() {
    expect(
      sp!.getString(SpUtil.accessToken),
      isNotNull,
      reason: 'no forced logout',
    );
    expect(sp!.getBool(SpUtil.isLoggedIn), isTrue);
  }

  test(
    '426 on any request: update screen once; no logout, no Crashlytics',
    () async {
      transport.replies['treks/1'] = [(status: 426, body: _block426)];

      final e = await getFails('treks/1');
      expect(
        e.response?.statusCode,
        426,
        reason: 'the caller still gets the error',
      );
      expect(gate.isBlocked, isTrue);
      expect(presented, hasLength(1));
      expect(presented.single.message, 'A plain message to show the user');
      expect(presented.single.storeUrl, _storeUrl);
      expect(crashlytics.recordedExceptions, isEmpty);
      expectStillSignedIn();
      expect(transport.requests, hasLength(1), reason: 'no retry');

      // Every request carried the version headers.
      expect(transport.requests.single.headers['X-App-Build'], '24');
      expect(transport.requests.single.headers['X-App-Version'], '1.1.0');
      expect(transport.requests.single.headers['X-App-Platform'], 'android');

      // More refusals don't stack screens.
      await getFails('treks/1');
      expect(presented, hasLength(1));
    },
  );

  test(
    '403 APP_UPDATE_REQUIRED (Play Integrity floor) is the same — not ACCOUNT_INACTIVE',
    () async {
      transport.replies['customer/profile'] = [
        (
          status: 403,
          body: {
            'success': false,
            'code': 'APP_UPDATE_REQUIRED',
            'message': 'Update Aorbo',
          },
        ),
      ];
      await getFails('customer/profile');
      expect(presented.single.message, 'Update Aorbo');
      expect(presented.single.storeUrl, isNull);
      expect(crashlytics.recordedExceptions, isEmpty);
      expectStillSignedIn();
    },
  );

  test(
    'token expired, then /customer/auth/refresh answers 426: blocked, never logged out',
    () async {
      transport.replies['treks/1'] = [
        (status: 401, body: {'success': false, 'code': 'TOKEN_EXPIRED'}),
      ];
      transport.replies['customer/auth/refresh'] = [
        (status: 426, body: _block426),
      ];

      final e = await getFails('treks/1');
      expect(e.response?.statusCode, 401);
      expect(gate.isBlocked, isTrue);
      expect(presented, hasLength(1));
      expectStillSignedIn();
      expect(sp!.getString(SpUtil.refreshToken), 'refresh-1');

      final paths = transport.requests.map((r) => r.path).toList();
      expect(paths, [
        'treks/1',
        'customer/auth/refresh',
      ], reason: 'no replay after a refused refresh');
      expect(
        transport.requests.last.headers['X-App-Build'],
        '24',
        reason: 'refresh client sends the headers too',
      );
    },
  );

  test(
    'token expired, refresh 403 APP_UPDATE_REQUIRED: not mistaken for a dead refresh token',
    () async {
      transport.replies['treks/1'] = [
        (status: 401, body: {'success': false, 'code': 'TOKEN_EXPIRED'}),
      ];
      transport.replies['customer/auth/refresh'] = [
        (status: 403, body: {'success': false, 'code': 'APP_UPDATE_REQUIRED'}),
      ];
      await getFails('treks/1');
      expect(gate.isBlocked, isTrue);
      expectStillSignedIn();
    },
  );

  test(
    'refresh works but the replay answers 426: blocked, new tokens kept',
    () async {
      transport.replies['treks/1'] = [
        (status: 401, body: {'success': false, 'code': 'TOKEN_EXPIRED'}),
        (status: 426, body: _block426),
      ];
      transport.replies['customer/auth/refresh'] = [
        (
          status: 200,
          body: {
            'success': true,
            'data': {'token': 'access-2', 'refreshToken': 'refresh-2'},
          },
        ),
      ];
      final e = await getFails('treks/1');
      expect(e.response?.statusCode, 426);
      expect(gate.isBlocked, isTrue);
      expect(sp!.getString(SpUtil.accessToken), 'access-2');
      expect(sp!.getBool(SpUtil.isLoggedIn), isTrue);
    },
  );

  test(
    'a caller that accepts 4xx replies (like postForReply) still triggers the block',
    () async {
      transport.replies['legal/accept'] = [(status: 426, body: _block426)];
      final response = await repo.dio.post(
        'legal/accept',
        data: {'x': 1},
        // postForReply's validateStatus: a 426 arrives as a response.
        options: Options(
          validateStatus: (s) => s != null && s < 500 && s != 401,
        ),
      );
      expect(response.statusCode, 426);
      expect(gate.isBlocked, isTrue);
      expect(presented.single.storeUrl, _storeUrl);
    },
  );

  test(
    'control: other errors behave as before (a 500 is reported, nothing blocks)',
    () async {
      transport.replies['treks/2'] = [
        (status: 500, body: {'success': false}),
      ];
      await getFails('treks/2');
      expect(crashlytics.recordedExceptions, isNotEmpty);
      expect(gate.isBlocked, isFalse);
      expect(presented, isEmpty);
    },
  );
}
