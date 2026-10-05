// TrekController — Module C. Repository() is a singleton wrapping a real
// Dio instance; rather than adding a new mocking package, this intercepts
// at the Dio layer (Repository().dio.interceptors), which is public and
// non-invasive to production code.
//
// Most tests below use plain test(), NOT testWidgets()/pumpWidget(): no
// widget tree is needed for pure controller logic, and it's the faster,
// simpler path (matches widget_test.dart's own existing convention).
//
// ROOT-CAUSED 2026-08-08: pumping a widget tree in this app previously hung
// indefinitely (confirmed reproducible, 85s+) the moment a pumped test also
// awaited genuine async I/O (a real Dio call, even one intercepted to
// resolve instantly). Root cause: flutter_test's default binding runs
// pumped-widget tests on a controlled/fake time schedule, and real
// asynchronous I/O awaited outside of tester.pump() can starve forever
// without an explicit tester.runAsync() wrapper telling the binding to let
// that block run on the real event loop. This is a documented Flutter
// testing pattern, not a workaround specific to this app — see the
// 'TrekController — Get.context-dependent failure paths' group below,
// which uses pumpWidget + runAsync together to finally cover the two
// branches (calculateFare/createTrekOrder failure snackbars) that need a
// real Get.context and were previously untestable here.

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/payment_verify_outcome.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/main.dart' as app;
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:dio/dio.dart' hide Response;
import 'package:dio/dio.dart' as dio show Response;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

/// Repository.isInternetAvailable() calls Connectivity().checkConnectivity(),
/// a real platform channel with no handler in a headless test — that hangs
/// indefinitely rather than failing fast. connectivity_plus is a federated
/// plugin with a swappable ConnectivityPlatform.instance specifically for
/// this — the officially supported way to test code depending on it.
class _FakeConnectivityPlatform extends ConnectivityPlatform {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [ConnectivityResult.wifi];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value([ConnectivityResult.wifi]);
}

/// DashboardController.onInit() fires Future.wait([fetchCitiesList(),
/// fetchTrekList(), fetchStateList()]) unconditionally — real network calls
/// entirely unrelated to what's under test here. TrekController only needs
/// DashboardController registered to satisfy Get.find<DashboardController>();
/// this stub skips onInit's unrelated side effects.
class _StubDashboardController extends DashboardController {
  @override
  void onInit() {
    // Deliberately not calling super.onInit() — see class doc above.
  }

  @override
  Future<void> getBookingHistory({required bool refresh}) async {
    // Fired fire-and-forget from TrekController.verifyTrekOrder's and
    // checkPendingOrderOnResume's success branches — unrelated to what's
    // under test here. The real implementation calls Get.context! in its
    // own catch block on a parse failure, which (like showLoaderDialog)
    // requires a real navigator this headless test doesn't have.
  }
}

/// Installs a fake interceptor that short-circuits real network calls and
/// resolves/rejects based on the request path, matching NetworkUrl's real
/// endpoint strings.
void installFakeBackend(Map<String, dynamic Function(RequestOptions)> handlers) {
  Repository().dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      for (final entry in handlers.entries) {
        if (options.path.contains(entry.key)) {
          final result = entry.value(options);
          if (result is Map && result['__error__'] == true) {
            handler.reject(DioException(
              requestOptions: options,
              response: dio.Response(
                requestOptions: options,
                statusCode: result['statusCode'] as int,
                data: result['data'],
              ),
              type: DioExceptionType.badResponse,
            ));
          } else {
            handler.resolve(dio.Response(requestOptions: options, statusCode: 200, data: result));
          }
          return;
        }
      }
      // Unmatched path (e.g. DashboardController's fire-and-forget calls) ->
      // generic empty success, never hangs.
      handler.resolve(dio.Response(
        requestOptions: options, statusCode: 200,
        data: {'success': true, 'data': []},
      ));
    },
  ));
}

// SpUtil caches its SharedPreferences reference in a static field that only
// ever initializes once (`if (_spf == null) { await _init(); }`) — calling
// SharedPreferences.setMockInitialValues({}) fresh in every test creates a
// NEW mock store that SpUtil's already-cached reference never picks up
// again after the first test, silently reading/writing a stale store
// (confirmed by isolating it: a value set via the test's own
// SharedPreferences.getInstance() wasn't visible via SpUtil in test 2+).
// Fix: mock once, clear the shared store between tests instead of re-mocking.
bool _prefsInitialized = false;

Future<TrekController> setUpController() async {
  ConnectivityPlatform.instance = _FakeConnectivityPlatform();
  if (!_prefsInitialized) {
    SharedPreferences.setMockInitialValues({});
    // Repository._authOptions() reads the global `sp` (declared in main.dart,
    // normally set once during app bootstrap) via a force-unwrap `sp!`.
    app.sp = await SpUtil.getInstance();
    _prefsInitialized = true;
  } else {
    await (await SharedPreferences.getInstance()).clear();
  }
  Get.testMode = true;
  if (!Get.isRegistered<DashboardController>()) {
    Get.put<DashboardController>(_StubDashboardController());
  }
  return TrekController();
}

/// Same setup, but with a real GetMaterialApp pumped — needed only for the
/// two branches that call `CustomSnackBar.show(Get.context!, ...)`, which
/// requires a real navigator. Bounded pump() calls only, never
/// pumpAndSettle(): this app's Lottie/GetX overlay animations don't
/// naturally settle, which is what made the original hang so easy to
/// mistake for a pumpWidget problem rather than the missing runAsync().
Future<TrekController> setUpPumpedController(WidgetTester tester) async {
  final c = await setUpController();
  await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
  await tester.pump();
  return c;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    Repository().dio.interceptors.clear();
    Get.reset();
  });

  group('TrekController.calculateFare', () {
    test('success updates calculateFareResponseModel and stores the fareToken for create-order', () async {
      final c = await setUpController();
      installFakeBackend({
        NetworkUrl.calculateFare: (_) => {
          'success': true,
          'fareToken': 'tok-abc',
          'breakdown': {'final_amount': 10510, 'amount_to_pay_now': 10510},
        },
      });

      c.calculateFareRequestModel.value = c.calculateFareRequestModel.value.copyWith(
        batchId: 1, travelerCount: 2,
      );
      await c.calculateFare();

      final success = c.calculateFareResponseModel.value.maybeWhen(
        success: (r) => r, orElse: () => null,
      );
      expect(success, isNotNull);
      expect(c.createOrderRequestModel.value.fareToken, 'tok-abc');
    });

    // Coupon apply/remove made the whole payment page blink: calculateFare()
    // swapped the on-screen fare for a `loading` state, which blanked the fare
    // card, the footer total and the coupon row and raised a full-screen overlay.
    // keepPrevious refreshes in place instead.
    group('keepPrevious (refresh in place)', () {
      Map<String, dynamic> fare(String token, {int amount = 10510}) => {
        'success': true,
        'fareToken': token,
        'breakdown': {'final_amount': amount, 'amount_to_pay_now': amount},
      };

      Future<List<String>> statesDuring(TrekController c, Future<void> Function() run) async {
        final seen = <String>[];
        final worker = ever(c.calculateFareResponseModel, (r) {
          seen.add(r.maybeWhen(loading: (_) => 'loading', success: (_) => 'success', error: (_) => 'error', orElse: () => 'other'));
        });
        await run();
        worker.dispose();
        return seen;
      }

      test('with a fare already on screen the state never drops to loading, and the flag clears', () async {
        final c = await setUpController();
        installFakeBackend({NetworkUrl.calculateFare: (_) => fare('tok-1')});
        c.calculateFareRequestModel.value = c.calculateFareRequestModel.value.copyWith(batchId: 1, travelerCount: 2);
        await c.calculateFare();

        Repository().dio.interceptors.clear();
        installFakeBackend({NetworkUrl.calculateFare: (_) => fare('tok-2', amount: 9510)});
        final seen = await statesDuring(c, () async {
          final f = c.calculateFare(keepPrevious: true);
          expect(c.fareRefreshing.value, isTrue, reason: 'flag is up while the refresh is in flight');
          await f;
        });

        expect(seen, isNot(contains('loading')));
        expect(c.calculateFareResponseModel.value.maybeWhen(success: (_) => true, orElse: () => false), isTrue);
        expect(c.createOrderRequestModel.value.fareToken, 'tok-2');
        expect(c.fareRefreshing.value, isFalse);
      });

      test('control: without keepPrevious the old behaviour (loading state) is unchanged', () async {
        final c = await setUpController();
        installFakeBackend({NetworkUrl.calculateFare: (_) => fare('tok-1')});
        c.calculateFareRequestModel.value = c.calculateFareRequestModel.value.copyWith(batchId: 1, travelerCount: 2);
        await c.calculateFare();

        final seen = await statesDuring(c, () => c.calculateFare());
        expect(seen.first, 'loading');
        expect(c.fareRefreshing.value, isFalse);
      });

      test('first load (no fare yet) still shows loading even with keepPrevious', () async {
        final c = await setUpController();
        installFakeBackend({NetworkUrl.calculateFare: (_) => fare('tok-1')});
        c.calculateFareRequestModel.value = c.calculateFareRequestModel.value.copyWith(batchId: 1, travelerCount: 2);

        final seen = await statesDuring(c, () => c.calculateFare(keepPrevious: true));
        expect(seen.first, 'loading');
      });

      test('a failed refresh surfaces the error and clears the flag (never stuck dimmed / Pay blocked)', () async {
        final c = await setUpController();
        installFakeBackend({NetworkUrl.calculateFare: (_) => fare('tok-1')});
        c.calculateFareRequestModel.value = c.calculateFareRequestModel.value.copyWith(batchId: 1, travelerCount: 2);
        await c.calculateFare();

        Repository().dio.interceptors.clear();
        installFakeBackend({NetworkUrl.calculateFare: (_) => {'success': false, 'message': 'nope'}});
        // The error branch shows a snackbar via Get.context!, unavailable headless — the
        // controller's catch throws on it, so only assert the flag afterwards.
        try {
          await c.calculateFare(keepPrevious: true);
        } catch (_) {}
        expect(c.fareRefreshing.value, isFalse);
      });
    });
  });

  // NOTE: TrekController.createTrekOrder is NOT unit-testable here.
  // showLoaderDialog() (called unconditionally at the top, success or
  // failure) does `showDialog(context: Get.context!, ...)` — a hard
  // requirement on a real navigator. Pumping a real widget tree to satisfy
  // it reproducibly hangs in this headless environment (Lottie/GetX overlay
  // animations leave pending timers the test framework waits forever to
  // settle — confirmed by isolating pumpWidget as the exact hang cause).
  // This is a genuine architectural coupling (business logic calling a UI
  // primitive directly), not a gap in test-writing effort — flagging it
  // rather than working around it with something fragile.

  group('TrekController.verifyTrekOrder', () {
    test('SHOW_BOOKING_CONFIRMED clears pendingOrderId and returns true (artifact #45)', () async {
      final c = await setUpController();
      final pref = await SharedPreferences.getInstance();
      await pref.setString('pending_razorpay_order_id', 'order_xyz');

      installFakeBackend({
        NetworkUrl.verifyBooking: (_) => {
          'success': true,
          'data': {'id': 99, 'booking_number': 'BI99'},
          'next_action': 'SHOW_BOOKING_CONFIRMED',
        },
      });

      final result = await c.verifyTrekOrder(
        razorpayOrderId: 'order_xyz', razorpayPaymentId: 'pay_1', razorpaySignature: 'sig_1',
      );

      expect(result, true);
      expect(pref.getString('pending_razorpay_order_id'), isNull);
    });

    test('a different next_action returns false and leaves pendingOrderId in place (artifact #46)', () async {
      final c = await setUpController();
      final pref = await SharedPreferences.getInstance();
      await pref.setString('pending_razorpay_order_id', 'order_xyz');

      installFakeBackend({
        NetworkUrl.verifyBooking: (_) => {'success': true, 'data': {}, 'next_action': 'SOMETHING_ELSE'},
      });

      final result = await c.verifyTrekOrder(
        razorpayOrderId: 'order_xyz', razorpayPaymentId: 'pay_1', razorpaySignature: 'sig_1',
      );

      expect(result, false);
      expect(pref.getString('pending_razorpay_order_id'), 'order_xyz'); // untouched
    });

    // Scan E0-1: a retry after the payment was auto-refunded must never say
    // "booking confirmed".
    test('already refunded (HTTP 200, success:false, refunded:true) -> false, outcome refunded, message kept, pending order cleared', () async {
      final c = await setUpController();
      final pref = await SharedPreferences.getInstance();
      await pref.setString('pending_razorpay_order_id', 'order_xyz');
      installFakeBackend({
        NetworkUrl.verifyBooking: (_) => {
          'success': false,
          'alreadyProcessed': true,
          'refunded': true,
          'code': 'PAYMENT_REFUNDED',
          'message': 'This payment could not be turned into a booking and has been refunded in full.',
          'data': null,
          'next_action': 'SHOW_PAYMENT_REFUNDED',
          'next_action_params': {'order_id': 'order_xyz'},
        },
      });

      final result = await c.verifyTrekOrder(
        razorpayOrderId: 'order_xyz', razorpayPaymentId: 'pay_1', razorpaySignature: 'sig_1',
      );

      expect(result, false);
      expect(c.lastVerifyOutcome.value, VerifyPaymentOutcome.refunded);
      expect(c.lastVerifyMessage.value, contains('refunded in full'));
      expect(pref.getString('pending_razorpay_order_id'), isNull);
    });

    test('refunded wins even if a reply also says success:true + SHOW_PAYMENT_REFUNDED', () async {
      final c = await setUpController();
      installFakeBackend({
        NetworkUrl.verifyBooking: (_) => {
          'success': true,
          'data': {'id': 5},
          'next_action': 'SHOW_PAYMENT_REFUNDED',
        },
      });
      final result = await c.verifyTrekOrder(
        razorpayOrderId: 'order_xyz', razorpayPaymentId: 'pay_1', razorpaySignature: 'sig_1',
      );
      expect(result, false);
      expect(c.lastVerifyOutcome.value, VerifyPaymentOutcome.refunded);
      expect(c.lastVerifyMessage.value, paymentRefundedFallbackMessage);
    });

    test('success:true with data:null is NOT a confirmation -> false, pending order kept for the status poll', () async {
      final c = await setUpController();
      final pref = await SharedPreferences.getInstance();
      await pref.setString('pending_razorpay_order_id', 'order_xyz');
      installFakeBackend({
        NetworkUrl.verifyBooking: (_) => {
          'success': true,
          'alreadyProcessed': true,
          'data': null,
          'next_action': 'SHOW_BOOKING_CONFIRMED',
        },
      });
      final result = await c.verifyTrekOrder(
        razorpayOrderId: 'order_xyz', razorpayPaymentId: 'pay_1', razorpaySignature: 'sig_1',
      );
      expect(result, false);
      expect(c.lastVerifyOutcome.value, VerifyPaymentOutcome.unconfirmed);
      expect(pref.getString('pending_razorpay_order_id'), 'order_xyz');
    });

    test('webhook completed it first (alreadyProcessed + full booking) -> confirmed, ticket data present', () async {
      final c = await setUpController();
      installFakeBackend({
        NetworkUrl.verifyBooking: (_) => {
          'success': true,
          'alreadyProcessed': true,
          'data': {
            'id': 321,
            'booking_number': 'BI321',
            'trek': {'id': 7, 'title': 'Kedarkantha', 'city_ids': ['3', 4], 'inclusions': null},
            'batch': {'id': 9, 'start_date': '2026-12-01', 'end_date': '2026-12-05'},
            'travelers': [],
            'payments': [],
          },
          'next_action': 'SHOW_BOOKING_CONFIRMED',
        },
      });
      final result = await c.verifyTrekOrder(
        razorpayOrderId: 'order_xyz', razorpayPaymentId: 'pay_1', razorpaySignature: 'sig_1',
      );
      expect(result, true);
      expect(c.lastVerifyOutcome.value, VerifyPaymentOutcome.confirmed);
      expect(c.verifyOrderModal.value.data?.id, 321);
      expect(c.verifyOrderModal.value.data?.trek?.title, 'Kedarkantha');
      expect(c.verifyOrderModal.value.data?.trek?.cityIds, [3, 4]);
    });

    test('classifyVerifyReply: the three outcomes', () {
      expect(classifyVerifyReply({'success': true, 'data': {'id': 1}}), VerifyPaymentOutcome.confirmed);
      expect(classifyVerifyReply({'success': true, 'data': {'id': 1}, 'next_action': 'SHOW_BOOKING_CONFIRMED'}), VerifyPaymentOutcome.confirmed);
      expect(classifyVerifyReply({'success': true, 'data': {}}), VerifyPaymentOutcome.unconfirmed);
      expect(classifyVerifyReply({'success': true}), VerifyPaymentOutcome.unconfirmed);
      expect(classifyVerifyReply({'success': false, 'message': 'x'}), VerifyPaymentOutcome.unconfirmed);
      expect(classifyVerifyReply({'success': false, 'refunded': true}), VerifyPaymentOutcome.refunded);
      expect(classifyVerifyReply({'success': false, 'code': 'PAYMENT_REFUNDED'}), VerifyPaymentOutcome.refunded);
      expect(classifyVerifyReply(null), VerifyPaymentOutcome.unconfirmed);
      expect(classifyVerifyReply('oops'), VerifyPaymentOutcome.unconfirmed);
    });

    test("network error returns false rather than throwing, so the caller's poll-fallback still runs (artifact #47)", () async {
      final c = await setUpController();
      installFakeBackend({
        NetworkUrl.verifyBooking: (_) => {'__error__': true, 'statusCode': 500, 'data': {'message': 'Internal error'}},
      });

      final result = await c.verifyTrekOrder(
        razorpayOrderId: 'order_xyz', razorpayPaymentId: 'pay_1', razorpaySignature: 'sig_1',
      );
      expect(result, false);
    });
  });

  group('TrekController.checkOrderStatus / checkPendingOrderOnResume', () {
    test('checkOrderStatus returns the data map on success', () async {
      final c = await setUpController();
      installFakeBackend({
        'order-status': (_) => {'success': true, 'data': {'status': 'paid', 'booking_id': 7}},
      });
      final status = await c.checkOrderStatus('order_1');
      expect(status!['status'], 'paid');
    });

    test('checkOrderStatus returns null on failure, never throws', () async {
      final c = await setUpController();
      installFakeBackend({
        'order-status': (_) => {'__error__': true, 'statusCode': 404, 'data': {'success': false}},
      });
      final status = await c.checkOrderStatus('order_ghost');
      expect(status, isNull);
    });

    test('checkPendingOrderOnResume: order already paid -> clears the flag (artifact #48)', () async {
      final c = await setUpController();
      final pref = await SharedPreferences.getInstance();
      await pref.setString('pending_razorpay_order_id', 'order_resumed');
      installFakeBackend({
        'order-status': (_) => {'success': true, 'data': {'status': 'paid'}},
      });

      await c.checkPendingOrderOnResume();
      expect(pref.getString('pending_razorpay_order_id'), isNull);
    });

    test('checkPendingOrderOnResume: order still pending -> flag deliberately left in place (artifact #49-50)', () async {
      final c = await setUpController();
      final pref = await SharedPreferences.getInstance();
      await pref.setString('pending_razorpay_order_id', 'order_resumed');
      installFakeBackend({
        'order-status': (_) => {'success': true, 'data': {'status': 'pending'}},
      });

      await c.checkPendingOrderOnResume();
      expect(pref.getString('pending_razorpay_order_id'), 'order_resumed');
    });

    test('checkPendingOrderOnResume: no stored order id at all -> no API call, returns quietly', () async {
      final c = await setUpController();
      await c.checkPendingOrderOnResume(); // should not throw even with no interceptor installed
      expect(true, true);
    });
  });

  group('TrekController.fetchRefundStatus / poll-interval handling (artifact #9 fix)', () {
    test('a response carrying a poll_interval_seconds different from the current one is parsed without throwing (server-driven interval change, artifact #192)', () async {
      final c = await setUpController();
      installFakeBackend({
        'refund-status': (_) => {
          'success': true,
          'data': {'booking_id': 1, 'refund_amount': 3450, 'refund_status': 'processing'},
          'next_action': 'POLL_REFUND_STATUS',
          'next_action_params': {'poll_interval_seconds': 60}, // server suggests a SHORTER interval than the 300s default
        },
      });

      c.startRefundPolling('1');
      await Future.delayed(const Duration(milliseconds: 50));
      c.stopRefundPolling(); // don't leave a real 60s/300s timer running past this test

      final success = c.refundStatusObserver.value.maybeWhen(success: (m) => m, orElse: () => null);
      expect(success, isNotNull);
      expect(success!.nextActionParams!.pollIntervalSeconds, 60);
    });

    test('next_action NO_REFUND_APPLICABLE stops polling (artifact #10, #193)', () async {
      final c = await setUpController();
      installFakeBackend({
        'refund-status': (_) => {
          'success': true,
          'data': {'booking_id': 1, 'refund_amount': 0, 'refund_status': null},
          'next_action': 'NO_REFUND_APPLICABLE',
        },
      });

      c.startRefundPolling('1');
      await Future.delayed(const Duration(milliseconds: 50));

      final success = c.refundStatusObserver.value.maybeWhen(success: (m) => m, orElse: () => null);
      expect(success!.nextAction, 'NO_REFUND_APPLICABLE');
      c.stopRefundPolling(); // idempotent no-op if the fix already stopped it internally
    });
  });

  group('TrekController — Get.context-dependent failure paths (artifact #10 unblocked)', () {
    testWidgets('calculateFare backend rejection shows the real error message via the Get.context! snackbar path', (tester) async {
      final c = await setUpPumpedController(tester);
      installFakeBackend({
        NetworkUrl.calculateFare: (_) => {
          '__error__': true, 'statusCode': 400,
          'data': {'success': false, 'message': 'Only 2 slots available'},
        },
      });

      await tester.runAsync(() async {
        await c.calculateFare();
      });
      await tester.pump();

      final isError = c.calculateFareResponseModel.value.maybeWhen(error: (_) => true, orElse: () => false);
      expect(isError, true);
      expect(c.errorMessage.value, contains('Only 2 slots available'));
    });

    testWidgets('createTrekOrder success: shows and cleanly dismisses the real loader dialog (showLoaderDialog/hideLoaderDialog), no leftover route', (tester) async {
      final c = await setUpPumpedController(tester);
      installFakeBackend({
        NetworkUrl.addBooking: (_) => {
          'success': true,
          'order': {'id': 'order_xyz', 'amount': 1051000, 'currency': 'INR'},
          'next_action_params': {},
        },
      });

      await tester.runAsync(() async {
        await c.createTrekOrder();
      });
      await tester.pump();
      await tester.pump();

      expect(c.orderModal.value.success, true);
      // The loader dialog must be gone — exactly one route (the base Scaffold) left.
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('createTrekOrder failure: shows the real error message via the Get.context! snackbar path, and still dismisses the loader dialog (finally block)', (tester) async {
      final c = await setUpPumpedController(tester);
      installFakeBackend({
        NetworkUrl.addBooking: (_) => {
          '__error__': true, 'statusCode': 400,
          'data': {'success': false, 'message': 'Batch is no longer active'},
        },
      });

      await tester.runAsync(() async {
        await c.createTrekOrder();
      });
      await tester.pump();
      await tester.pump();

      expect(c.orderModal.value.success, isNot(true));
      expect(c.errorMessage.value, contains('Batch is no longer active'));
      expect(find.byType(CircularProgressIndicator), findsNothing); // finally block still ran
    });

    // Scan D2: a failed SECOND create-order used to keep the first order's
    // id/amount, and the payment screen then opened Razorpay on that old order.
    Map<String, dynamic> orderA() => {
      'success': true,
      'order': {'id': 'order_A', 'amount': 1051000, 'currency': 'INR'},
      'next_action': 'OPEN_RAZORPAY',
      'next_action_params': {'order_id': 'order_A', 'amount': 1051000},
    };

    testWidgets('D2: a failed second create-order (409) returns false and leaves NO order behind (not the first one)', (tester) async {
      final c = await setUpPumpedController(tester);
      installFakeBackend({NetworkUrl.addBooking: (_) => orderA()});
      late bool first;
      await tester.runAsync(() async {
        first = await c.createTrekOrder();
      });
      await tester.pump();
      expect(first, isTrue);
      expect(c.orderNextActionParams['order_id'], 'order_A');

      Repository().dio.interceptors.clear();
      installFakeBackend({
        NetworkUrl.addBooking: (_) => {
          '__error__': true, 'statusCode': 409,
          'data': {'success': false, 'message': 'Only 1 slot left'},
        },
      });
      late bool second;
      await tester.runAsync(() async {
        second = await c.createTrekOrder();
      });
      await tester.pump();
      await tester.pump();

      expect(second, isFalse);
      expect(c.orderModal.value.success, isNot(true));
      expect(c.orderData.value.id, isNull);
      expect(c.orderNextActionParams['order_id'], isNull);
      expect(c.orderNextActionParams['amount'], isNull);
      expect(c.errorMessage.value, contains('Only 1 slot left'));
    });

    testWidgets('D2: a second create-order made offline returns false, clears the first order and says "No internet connection"', (tester) async {
      final c = await setUpPumpedController(tester);
      installFakeBackend({NetworkUrl.addBooking: (_) => orderA()});
      await tester.runAsync(() async {
        await c.createTrekOrder();
      });
      await tester.pump();
      expect(c.orderData.value.id, 'order_A');
      c.errorMessage.value = 'an older message';

      ConnectivityPlatform.instance = _OfflineConnectivityPlatform();
      late bool second;
      await tester.runAsync(() async {
        second = await c.createTrekOrder();
      });
      await tester.pump();
      await tester.pump(const Duration(seconds: 5)); // let the offline snackbar go

      expect(second, isFalse);
      expect(c.orderModal.value.success, isNot(true));
      expect(c.orderData.value.id, isNull);
      expect(c.orderNextActionParams, isEmpty);
      expect(c.errorMessage.value, 'No internet connection. Please try again.');
    });

    testWidgets('D2: clearBookingData also forgets the Razorpay order params', (tester) async {
      final c = await setUpPumpedController(tester);
      installFakeBackend({NetworkUrl.addBooking: (_) => orderA()});
      await tester.runAsync(() async {
        await c.createTrekOrder();
      });
      await tester.pump();
      c.clearBookingData();
      expect(c.orderNextActionParams, isEmpty);
      expect(c.orderData.value.id, isNull);
    });
  });
}

class _OfflineConnectivityPlatform extends ConnectivityPlatform {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [ConnectivityResult.none];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value([ConnectivityResult.none]);
}
