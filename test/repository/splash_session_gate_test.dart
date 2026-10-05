// Scan E8: the splash gate (AuthController.validateSession) must sign the
// user out only when the server really refused the session. With a 30-min
// access token nearly every cold start begins with 401 TOKEN_EXPIRED; if the
// silent refresh then hiccups (timeout, 5xx, 429) the session is still good
// and must survive. Runs the real Repository interceptors over a fake
// transport, like test/app_update/repository_update_required_test.dart.

import 'package:arobo_app/app_update/app_update_gate.dart';
import 'package:arobo_app/controller/auth_controller.dart';
import 'package:arobo_app/main.dart' show sp;
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_test_mocks.dart';
import '../helpers/fake_transport.dart';

const _expired = Step.reply(401, {'success': false, 'code': 'TOKEN_EXPIRED'});
const _profileOk = Step.reply(200, {'success': true, 'data': {'id': 1}});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeTransport transport;
  late AuthController auth;
  final repo = Repository();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sp = await SpUtil.getInstance();
    await setUpFakeFirebase();
    await repo.initRepo();
  });

  setUp(() async {
    Get.testMode = true;
    transport = FakeTransport();
    repo.httpClientAdapterForTesting = transport;
    AppUpdateGate.instance = AppUpdateGate(fetchPolicy: () async => null, present: (_) {});
    await sp!.clear();
    await sp!.putString(SpUtil.accessToken, 'access-1');
    await sp!.putString(SpUtil.refreshToken, 'refresh-1');
    await sp!.putBool(SpUtil.isLoggedIn, true);
    auth = AuthController();
  });

  tearDown(Get.reset);

  void expectSessionKept() {
    expect(sp!.getString(SpUtil.refreshToken), 'refresh-1', reason: 'refresh token must survive');
    expect(sp!.getBool(SpUtil.isLoggedIn), isTrue);
  }

  group('token expired + a refresh hiccup keeps the session (no OTP again)', () {
    for (final entry in <String, Step>{
      'refresh timed out (connect)': const Step.fail(DioExceptionType.connectionTimeout),
      'refresh timed out (receive)': const Step.fail(DioExceptionType.receiveTimeout),
      'no connection during refresh': const Step.fail(DioExceptionType.connectionError),
      'refresh answered 502': const Step.reply(502, '<html>Bad gateway</html>'),
      'refresh answered 503': const Step.reply(503, {'success': false}),
      'refresh answered 429': const Step.reply(429, {'success': false, 'message': 'Too many'}),
    }.entries) {
      test(entry.key, () async {
        transport.steps['customer/auth/profile'] = [_expired];
        transport.steps['customer/auth/refresh'] = [entry.value];

        expect(await auth.validateSession(), isTrue);
        expectSessionKept();
        expect(transport.paths, contains('customer/auth/refresh'));
      });
    }
  });

  test('a stray 403 that is not a session refusal (e.g. an edge block page) keeps the session', () async {
    transport.steps['customer/auth/profile'] = [const Step.reply(403, '<html>blocked</html>')];
    expect(await auth.validateSession(), isTrue);
    expectSessionKept();
  });

  group('a real refusal still signs the user out', () {
    test('refresh token refused (401) -> false, session cleared', () async {
      transport.steps['customer/auth/profile'] = [_expired];
      transport.steps['customer/auth/refresh'] = [
        const Step.reply(401, {'success': false, 'code': 'REFRESH_TOKEN_INVALID'}),
      ];
      expect(await auth.validateSession(), isFalse);
      expect(sp!.getString(SpUtil.refreshToken), isNull);
    });

    test('a non-renewable 401 (session superseded) -> false', () async {
      transport.steps['customer/auth/profile'] = [
        const Step.reply(401, {'success': false, 'code': 'SESSION_INVALID'}),
      ];
      expect(await auth.validateSession(), isFalse);
      expect(sp!.getString(SpUtil.refreshToken), isNull);
    });

    test('403 ACCOUNT_INACTIVE -> false', () async {
      transport.steps['customer/auth/profile'] = [
        const Step.reply(403, {'success': false, 'code': 'ACCOUNT_INACTIVE'}),
      ];
      expect(await auth.validateSession(), isFalse);
    });
  });

  test('control: token expired, refresh works, replay 200 -> true with the new tokens', () async {
    transport.steps['customer/auth/profile'] = [_expired, _profileOk];
    transport.steps['customer/auth/refresh'] = [
      const Step.reply(200, {
        'success': true,
        'data': {'token': 'access-2', 'refreshToken': 'refresh-2'},
      }),
    ];
    expect(await auth.validateSession(), isTrue);
    expect(sp!.getString(SpUtil.accessToken), 'access-2');
  });

  test('control: profile answers 200 -> true', () async {
    transport.steps['customer/auth/profile'] = [_profileOk];
    expect(await auth.validateSession(), isTrue);
  });
}
