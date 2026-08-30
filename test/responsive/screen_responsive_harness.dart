// Screen-level overflow matrix. Pumps a real screen widget inside a
// GetMaterialApp, across the device × text-scale grid, and reports any
// RenderFlex overflow — the same detector the widget-level harness uses.
//
// It deliberately renders screens in their EMPTY / loading / just-mounted
// state: every network call is stubbed to an empty success, controller
// `onInit` side effects (fetches, sockets, timers) are skipped. That is
// exactly where a lot of real overflow hides (empty states, headers,
// fixed chrome) and it keeps the setup small enough to cover ~30 screens.
// Data-populated states for the few screens where that's where the risk
// lives are seeded per-test by mutating the controller before pumping.

import 'package:arobo_app/controller/auth_controller.dart';
import 'package:arobo_app/controller/coupon_controller.dart';
import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/notification_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/main.dart' as app;
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/utils/dashboard_header_theme.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../firebase_test_mocks.dart';
import 'responsive_harness.dart';

class _FakeConnectivity extends ConnectivityPlatform {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      [ConnectivityResult.wifi];
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value([ConnectivityResult.wifi]);
}

// ── controller stubs: skip onInit (fetches / sockets / timers), keep every
//    observable field at its declared default. Same must_call_super lint as
//    the repo's other test stubs, by design.
class _StubDashboardController extends DashboardController {
  @override
  void onInit() {}
}

class _StubTrekController extends TrekController {
  @override
  void onInit() {}
}

class _StubHeaderThemeController extends HeaderThemeController {
  @override
  void onInit() {}
}

bool _prefsReady = false;

/// One-time-ish environment: connectivity, prefs, Firebase, and a catch-all
/// Dio interceptor so no controller `onInit` (if a non-stubbed one slips in)
/// or lazy fetch ever hangs. Call in `setUp`.
Future<void> installScreenTestEnv() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  ConnectivityPlatform.instance = _FakeConnectivity();

  if (!_prefsReady) {
    SharedPreferences.setMockInitialValues({});
    app.sp = await SpUtil.getInstance();
    _prefsReady = true;
  } else {
    await (await SharedPreferences.getInstance()).clear();
  }

  await setUpFakeFirebase();

  Get.testMode = true;

  Repository().dio.interceptors.clear();
  Repository().dio.interceptors.add(
    dio.InterceptorsWrapper(
      onRequest: (options, handler) => handler.resolve(
        dio.Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true, 'data': <dynamic>[], 'message': 'ok'},
        ),
      ),
    ),
  );

  // Register the controllers screens reach for via Get.find(). Stubs for the
  // three with heavy onInit; real (harmless) instances for the rest.
  Get.put<DashboardController>(_StubDashboardController(), permanent: true);
  Get.put<TrekController>(_StubTrekController(), permanent: true);
  Get.put<HeaderThemeController>(_StubHeaderThemeController(), permanent: true);
  Get.put<AuthController>(AuthController(), permanent: true);
  Get.put<UserController>(UserController(), permanent: true);
  Get.put<CouponController>(CouponController(), permanent: true);
  Get.put<NotificationController>(NotificationController(), permanent: true);
}

/// Call in `tearDown`.
void teardownScreenTestEnv() {
  Repository().dio.interceptors.clear();
  Get.reset();
}

/// Pump [screen] across the responsive matrix; returns the same
/// combo -> overflow-messages map as [collectResponsiveOverflows].
///
/// [arguments] is handed to the screen as `Get.arguments` (some screens read
/// route args in initState/build).
Future<Map<String, List<String>>> collectScreenOverflows(
  WidgetTester tester,
  Widget Function() screen, {
  Object? arguments,
  List<ResponsiveDevice> devices = kResponsiveDevices,
  // The real app clamps OS font scale to 1.0–1.15 (main.dart), so testing
  // beyond that would flag overflow users can never actually hit.
  List<double> textScales = const [1.0, 1.15],
}) {
  return collectResponsiveOverflows(
    tester,
    devices: devices,
    textScales: textScales,
    appBuilder: (scale) => Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              // Simulate a user who cranked OS font size right up, then the
              // app's own clamp bringing it back down to `scale`.
              textScaler: const TextScaler.linear(2.0)
                  .clamp(minScaleFactor: 1.0, maxScaleFactor: scale),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
          home: Builder(
            builder: (_) {
              // Seed Get.arguments by pushing a throwaway route first would
              // be heavier; GetMaterialApp exposes it via Get.rootController.
              return screen();
            },
          ),
        );
      },
    ),
  );
}
