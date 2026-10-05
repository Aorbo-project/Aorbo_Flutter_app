// Scan D9: opening a booking offline (including the hop right after paying)
// showed a shimmer that never ended, with no way to retry.

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/screens/booking_upcoming_screen.dart';
// ignore: depend_on_referenced_packages
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'responsive/screen_responsive_harness.dart';

class _Connectivity extends ConnectivityPlatform {
  _Connectivity(this.online);
  bool online;
  List<ConnectivityResult> get _now => [online ? ConnectivityResult.wifi : ConnectivityResult.none];
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _now;
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => Stream.value(_now);
}

/// Only the booking-detail call is under test: the screen's other loads
/// (booking list, ads) would each raise their own offline toast.
class _QuietDashboardController extends DashboardController {
  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> getBookingHistory({required bool refresh}) async {}

  @override
  Future<void> fetchDetailScreenAds(String screen) async {}
}

bool _isLoading(DashboardController c) =>
    c.bookingDetailsObserver.value.maybeWhen(loading: (_) => true, orElse: () => false);
String? _error(DashboardController c) =>
    c.bookingDetailsObserver.value.maybeWhen(error: (m) => m, orElse: () => null);

void main() {
  late _Connectivity net;
  late int detailCalls;

  setUp(() async {
    Get.testMode = true;
    Get.put<DashboardController>(_QuietDashboardController(), permanent: true);
    await installScreenTestEnv();
    net = _Connectivity(false);
    ConnectivityPlatform.instance = net;
    detailCalls = 0;
    Repository().dio.interceptors.insert(
      0,
      dio.InterceptorsWrapper(onRequest: (o, h) {
        if (o.path.contains(NetworkUrl.bookingDetails(1))) {
          detailCalls++;
          return h.resolve(dio.Response(requestOptions: o, statusCode: 200, data: {
            'success': true,
            'data': {'id': 1, 'booking_number': 'BI1', 'status': 'confirmed'},
          }));
        }
        h.next(o);
      }),
    );
  });

  tearDown(teardownScreenTestEnv);

  testWidgets('offline: the booking detail ends in an error (not an endless loading state)', (tester) async {
    // A real app: getApiCall shows its own "check your internet" toast.
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
    final c = Get.find<DashboardController>();
    await tester.runAsync(() => c.getBookingDetail(bookingId: 1));
    await tester.pump();
    expect(_isLoading(c), isFalse);
    expect(_error(c), 'No internet connection. Please try again.');
    expect(detailCalls, 0);
    await tester.pump(const Duration(seconds: 5)); // let the toast go
  });

  testWidgets('the screen shows the reason and Retry; Retry loads the booking once back online', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    // The test font is wider than real fonts; overflow is covered by
    // test/responsive, not here.
    final previous = FlutterError.onError;
    FlutterError.onError = (d) {
      if (d.exceptionAsString().contains('overflowed')) return;
      previous?.call(d);
    };
    try {
      Future<void> settle() async {
        for (var i = 0; i < 5; i++) {
          await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      await tester.pumpWidget(Sizer(
        builder: (context, orientation, deviceType) =>
            const GetMaterialApp(home: BookingsUpcomingScreen(bookingId: 1)),
      ));
      await settle();

      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('No internet connection. Please try again.'), findsOneWidget);

      net.online = true;
      await tester.runAsync(() async {
        await tester.tap(find.text('Retry'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await settle();

      expect(detailCalls, 1);
      expect(find.text('Retry'), findsNothing);
      expect(_error(Get.find<DashboardController>()), isNull);

      await tester.pump(const Duration(seconds: 5)); // let the toast go
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    } finally {
      FlutterError.onError = previous;
    }
  });
}
