// Scan E3 (Logout) + E2 (forced sign-out) on a shared phone.
//
// E3: Logout called the server on a separate Dio with no refresh handling, so
// with the 30-min access token it usually got 401 TOKEN_EXPIRED and the
// server never cleared the account's push token; the app never called
// FirebaseMessaging.deleteToken(). The previous customer's booking / refund
// pushes kept arriving after they signed out.
//
// E2: a forced sign-out only cleared the stored session. The permanent
// controllers (bookings "fresh" for 3 min, profile, coupons) survived, so the
// next person to sign in was served the previous customer's data.
//
// Runs the real Repository interceptors over a fake transport.

import 'package:arobo_app/app_update/app_update_gate.dart';
import 'package:arobo_app/app_update/app_version_info.dart';
import 'package:arobo_app/controller/auth_controller.dart';
import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/main.dart' show sp;
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/utils/common_logics.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_test_mocks.dart';
import '../helpers/fake_transport.dart';

class _Online extends ConnectivityPlatform {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [ConnectivityResult.wifi];
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => Stream.value([ConnectivityResult.wifi]);
}

class _StubDashboardController extends DashboardController {
  // Skips the real onInit's network fetches.
  @override
  // ignore: must_call_super
  void onInit() {}
}

const _expired = Step.reply(401, {'success': false, 'code': 'TOKEN_EXPIRED'});
const _ok = Step.reply(200, {'success': true, 'message': 'ok'});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeTransport transport;
  late FakeMessagingPlatform messaging;
  final repo = Repository();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sp = await SpUtil.getInstance();
    await setUpFakeFirebase();
    messaging = setUpFakeMessaging();
    await repo.initRepo();
  });

  setUp(() async {
    Get.testMode = true;
    ConnectivityPlatform.instance = _Online();
    await setUpFakeFirebase();
    messaging = setUpFakeMessaging();
    transport = FakeTransport();
    repo.httpClientAdapterForTesting = transport;
    AppUpdateGate.instance = AppUpdateGate(fetchPolicy: () async => null, present: (_) {});
    AppVersionInfo.current = null;
    await sp!.clear();
    await sp!.putString(SpUtil.accessToken, 'access-1');
    await sp!.putString(SpUtil.refreshToken, 'refresh-1');
    await sp!.putBool(SpUtil.isLoggedIn, true);
    await sp!.putString(SpUtil.fcmTokenSynced, 'fake-fcm-token');
    // A trek link tapped on this phone, not yet opened: belongs to the phone.
    await sp!.putString('pending_trek_link_code', 'Ab3dEf7h');
    await sp!.putBool('giveaway_install_referrer_checked', true);
  });

  tearDown(Get.reset);

  void expectSignedOutLocally() {
    expect(sp!.getString(SpUtil.accessToken), isNull);
    expect(sp!.getString(SpUtil.refreshToken), isNull);
    expect(sp!.getBool(SpUtil.isLoggedIn), isNull);
    expect(sp!.getString(SpUtil.fcmTokenSynced), isNull);
    expect(Repository.token, isEmpty);
  }

  void expectPhoneLevelKeysKept() {
    expect(sp!.getString('pending_trek_link_code'), 'Ab3dEf7h');
    expect(sp!.getBool('giveaway_install_referrer_checked'), isTrue);
  }

  group('E3: Logout', () {
    test('expired access token: refreshed, server sign-out replayed with the new token, FCM token deleted', () async {
      transport.steps['customer/auth/logout'] = [_expired, _ok];
      transport.steps['customer/auth/refresh'] = [
        const Step.reply(200, {
          'success': true,
          'data': {'token': 'access-2', 'refreshToken': 'refresh-2'},
        }),
      ];

      await CommonLogics.logOut();

      final logouts = transport.requests.where((r) => r.path.endsWith('customer/auth/logout')).toList();
      expect(logouts, hasLength(2), reason: 'the 401 TOKEN_EXPIRED call is replayed after the refresh');
      expect(logouts.last.headers['Authorization'], 'Bearer access-2');
      expect(transport.paths, contains('customer/auth/refresh'));
      expect(messaging.deleteTokenCalls, 1);
      expectSignedOutLocally();
      expectPhoneLevelKeysKept();
    });

    test('offline / server down: the local session is still cleared and the FCM token deleted', () async {
      transport.steps['customer/auth/logout'] = [const Step.fail(DioExceptionType.connectionError)];

      await CommonLogics.logOut();

      expect(messaging.deleteTokenCalls, 1);
      expectSignedOutLocally();
    });

    test('refresh refused during logout: still signed out locally, FCM token deleted', () async {
      transport.steps['customer/auth/logout'] = [_expired];
      transport.steps['customer/auth/refresh'] = [
        const Step.reply(401, {'success': false, 'code': 'REFRESH_TOKEN_INVALID'}),
      ];

      await CommonLogics.logOut();

      expect(messaging.deleteTokenCalls, greaterThanOrEqualTo(1));
      expectSignedOutLocally();
    });
  });

  group('E2: the server ends the session (forced sign-out)', () {
    test('401 SESSION_INVALID on any call: stored session cleared, FCM token deleted, phone-level keys kept', () async {
      transport.steps['treks/1'] = [
        const Step.reply(401, {'success': false, 'code': 'SESSION_INVALID'}),
      ];
      try {
        await repo.dio.get('treks/1');
      } on DioException catch (_) {}

      expectSignedOutLocally();
      expect(messaging.deleteTokenCalls, 1);
      expectPhoneLevelKeysKept();
    });

    test('the next sign-in drops the previous person\'s permanent controllers (no stale bookings/profile)', () async {
      PackageInfo.setMockInitialValues(
        appName: 'Aorbo',
        packageName: 'com.aorbotreks.app',
        version: '1.0.0',
        buildNumber: '24',
        buildSignature: '',
      );
      // What a forced sign-out leaves behind: user A's controllers.
      Get.put<DashboardController>(_StubDashboardController(), permanent: true);
      Get.put<UserController>(UserController(), permanent: true);
      transport.steps['treks/1'] = [
        const Step.reply(401, {'success': false, 'code': 'SESSION_INVALID'}),
      ];
      try {
        await repo.dio.get('treks/1');
      } on DioException catch (_) {}

      // User B signs in on the same phone.
      transport.steps['customer/auth/verify-otp'] = [
        const Step.reply(200, {
          'success': true,
          'data': {
            'token': 'access-B',
            'refreshToken': 'refresh-B',
            'customer': {'id': 2002, 'phone': '9000000002'},
          },
        }),
      ];
      transport.steps['customer/device-token'] = [_ok];
      final auth = AuthController();
      final ok = await auth.verifyOtp('9000000002', '123456');

      expect(ok, isTrue);
      expect(Get.isRegistered<DashboardController>(), isFalse,
          reason: 'DashboardMain must build a fresh one for user B');
      expect(Get.isRegistered<UserController>(), isFalse);
      expect(sp!.getString(SpUtil.accessToken), 'access-B');
    });
  });
}
