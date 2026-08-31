// PaymentProcessingScreen — full state-machine coverage via the real
// Razorpay plugin code (not a hand-rolled fake): `razorpay_flutter`'s
// `open()`/`on()` both go through a real `MethodChannel('razorpay_flutter')`
// call (confirmed by reading the installed plugin source, v1.4.5). Mocking
// that channel and controlling what it returns for the 'open' call lets the
// REAL plugin parse the response and dispatch through its REAL EventEmitter
// to the screen's real `_handlePaymentSuccess`/`_handlePaymentError`/
// `_handleExternalWallet` handlers — more faithful than mocking Razorpay
// itself would be, and confirmed to resolve fine under plain tester.pump()
// (no tester.runAsync() needed for the channel round-trip itself, since
// TestDefaultBinaryMessengerBinding mocks resolve via Dart microtasks, not
// real OS I/O — verified in isolation). tester.runAsync() IS still needed
// around any pump that also has to let a real (interceptor-resolved) Dio
// call complete, per the root-caused hang in trek_controller_test.dart.
//
// FirebaseCrashlytics.instance.recordError(...) is called unconditionally
// at the top of _handlePaymentError, and AppFeedback (behind
// CustomSnackBar.show, used by _handleExternalWallet) logs every toast to
// Crashlytics too — both go through a real platform-interface chain that
// throws with no Firebase app registered. firebase_test_mocks.dart fakes
// that chain end-to-end; see its own doc comment for why a raw MethodChannel
// mock wasn't enough (an assert deep in
// FirebaseCrashlyticsPlatform.instanceFor requires real plugin-constant
// plumbing that only the Pigeon host-api boundary naturally provides).
//
// Get/Dio/SharedPreferences/connectivity setup is intentionally reused from
// trek_controller_test.dart's setUpPumpedController()/installFakeBackend()
// rather than duplicated — TrekController/DashboardController still aren't
// registered with Get by that helper, so this file adds Get.put for
// TrekController + UserController on top (PaymentProcessingScreen's State
// requires Get.find<T>() for all three).

import 'dart:async';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/freezed_models/booking/booking_data_model.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/screens/payment_processing_screen.dart';
import 'package:dio/dio.dart' show RequestOptions;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sizer/sizer.dart';

import 'package:firebase_crashlytics_platform_interface/firebase_crashlytics_platform_interface.dart';

import 'firebase_test_mocks.dart';
import 'trek_controller_test.dart' show setUpController, installFakeBackend;

const _razorpayChannel = MethodChannel('razorpay_flutter');

/// Installs the razorpay_flutter method channel mock. [onOpen] is invoked
/// for the 'open' call and its return value becomes the plugin's checkout
/// response (i.e. what _handleResult / the success/error/wallet events see).
/// 'resync' always answers null (no lost response) — see razorpay_flutter's
/// own source: .on() triggers a resync call per listener (3x in initState),
/// and a non-null resync response would re-dispatch the same event again.
///
/// If [onOpen] returns null, the 'open' call is left hanging forever (never
/// resolves) rather than answered with null — Razorpay.open()'s internal
/// _handleResult(response) takes a non-nullable Map, so an actual null
/// response throws a real (uncaught, test-failing) TypeError. A never-ending
/// gateway response is exactly what "the gateway never calls back" means
/// anyway (used by the watchdog tests and the payload-inspection tests that
/// don't care what happens after 'open').
List<MethodCall> mockRazorpayChannel(
  Map<String, dynamic>? Function(MethodCall call) onOpen,
) {
  final calls = <MethodCall>[];
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_razorpayChannel, (MethodCall call) async {
    calls.add(call);
    if (call.method == 'resync') return null;
    if (call.method == 'open') {
      final response = onOpen(call);
      if (response == null) return Completer<dynamic>().future; // never resolves
      return response;
    }
    return null;
  });
  return calls;
}

Map<String, dynamic> razorpaySuccess({
  String paymentId = 'pay_1',
  String orderId = 'order_1',
  String signature = 'sig_1',
}) => {
  'type': 0,
  'data': {
    'razorpay_payment_id': paymentId,
    'razorpay_order_id': orderId,
    'razorpay_signature': signature,
  },
};

Map<String, dynamic> razorpayError({
  int code = 2,
  String message = 'Payment cancelled by user',
}) => {
  'type': 1,
  'data': {'code': code, 'message': message},
};

Map<String, dynamic> razorpayExternalWallet(String walletName) => {
  'type': 2,
  'data': {'external_wallet': walletName},
};

// _resolveSucceeded fires generateAndUploadInvoice(...) fire-and-forget on
// success (real getBookingDetail -> InvoicePdfService -> upload chain,
// entirely unrelated to what PaymentProcessingScreen itself is responsible
// for). Even with the Dio interceptor resolving instantly, Dio schedules its
// own internal connect/receive-timeout Timers per request that don't get
// cleanly torn down under FakeAsync, leaving a "Timer still pending after
// dispose" test failure. Stubbed the same way trek_controller_test.dart's
// own _StubDashboardController already stubs getBookingHistory for the same
// class of reason. Registered *before* setUpController() so its own
// Get.isRegistered<DashboardController> guard skips putting its stub instead.
class _PaymentScreenStubDashboardController extends DashboardController {
  @override
  void onInit() {}

  @override
  Future<void> getBookingHistory({required bool refresh}) async {}

  @override
  Future<void> generateAndUploadInvoice(int bookingId) async {}

  // _resolveSucceeded's 900ms-delayed navigation pushes BookingsUpcomingScreen,
  // whose own initState calls these for real — same class of unrelated
  // real-network side effect as the two stubs above, just reached via
  // navigation instead of a direct call.
  @override
  Future<void> getBookingDetail({required dynamic bookingId}) async {}

  @override
  Future<void> fetchDetailScreenAds(String screen) async {}
}

// PaymentProcessingScreen renders through Sizer's .w/.sp extensions, which
// throw LateInitializationError without a real Sizer ancestor (confirmed —
// setUpPumpedController's bare GetMaterialApp(Scaffold) has none, since
// none of trek_controller_test.dart's own pumped tests render this screen).
// So the base app is pumped here directly instead of reusing that helper.
//
// flutter_test's default surface (800x600 logical) is smaller than any real
// phone Sizer is calibrated for, so the reassurance card's two side-by-side
// buttons genuinely overflow at that size (confirmed — not a production bug,
// this screen is phone-only). Setting a realistic phone viewport avoids
// asserting against a synthetic layout no user ever sees.
Future<TrekController> setUpPaymentScreenDeps(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  Get.testMode = true;
  // Must run BEFORE setUpController(): Get.put() is put-if-absent in GetX,
  // not an overwrite (confirmed empirically — putting after left
  // trek_controller_test.dart's own _StubDashboardController in place, whose
  // getBookingDetail/generateAndUploadInvoice are real, silently ignoring
  // this one). Registering first means setUpController()'s own
  // isRegistered guard skips putting its stub instead.
  Get.put<DashboardController>(_PaymentScreenStubDashboardController());
  final trekC = await setUpController();
  Get.put<TrekController>(trekC);
  Get.put<UserController>(UserController());
  await setUpFakeFirebase();
  await tester.pumpWidget(
    Sizer(
      builder: (context, orientation, deviceType) {
        return const GetMaterialApp(home: Scaffold(body: SizedBox()));
      },
    ),
  );
  await tester.pump();
  return trekC;
}

Future<void> pushPaymentScreen(
  WidgetTester tester, {
  required BreakDownDataModel? breakdown,
  String selectedPaymentOption = 'full',
}) async {
  Get.to(
    () => PaymentProcessingScreen(
      breakdown: breakdown,
      selectedPaymentOption: selectedPaymentOption,
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    Repository().dio.interceptors.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_razorpayChannel, null);
    Get.reset();
  });

  group('_openRazorpay / _toPaise payload construction', () {
    testWidgets('full payment: a plain-number final_amount converts to paise directly', (tester) async {
      final trekC = await setUpPaymentScreenDeps(tester);
      final calls = mockRazorpayChannel((_) => null); // never resolves; only inspecting the 'open' call args

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
        selectedPaymentOption: 'full',
      );

      final openCall = calls.firstWhere((c) => c.method == 'open');
      final args = openCall.arguments as Map;
      expect(args['amount'], 1051000); // 10510.00 * 100
      expect(args['currency'], 'INR');
      expect(trekC.orderNextActionParams, isEmpty); // confirms amount truly came from _toPaise, not next_action_params
    });

    testWidgets('full payment: a String final_amount ("1234.00", as real API responses send money fields) is parsed defensively, not string-repeated', (tester) async {
      await setUpPaymentScreenDeps(tester);
      final calls = mockRazorpayChannel((_) => null);

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: '1234.00', amountToPayNow: '500.00'),
        selectedPaymentOption: 'full',
      );

      final args = calls.firstWhere((c) => c.method == 'open').arguments as Map;
      // Dart's String * int is repetition ("1234.00" * 100 would be garbage,
      // not throw) — asserting the real numeric value, not just "didn't crash".
      expect(args['amount'], 123400);
    });

    testWidgets('advance payment: uses amount_to_pay_now, not final_amount', (tester) async {
      await setUpPaymentScreenDeps(tester);
      final calls = mockRazorpayChannel((_) => null);

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: '2000.50'),
        selectedPaymentOption: 'advance',
      );

      final args = calls.firstWhere((c) => c.method == 'open').arguments as Map;
      expect(args['amount'], 200050);
    });

    testWidgets('next_action_params amount from the server overrides the locally computed one', (tester) async {
      final trekC = await setUpPaymentScreenDeps(tester);
      trekC.orderNextActionParams.value = {
        'key': 'rzp_live_server_key',
        'order_id': 'order_from_server',
        'amount': 999900,
        'currency': 'INR',
      };
      final calls = mockRazorpayChannel((_) => null);

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
      );

      final args = calls.firstWhere((c) => c.method == 'open').arguments as Map;
      expect(args['amount'], 999900);
      expect(args['key'], 'rzp_live_server_key');
      expect(args['order_id'], 'order_from_server');
    });
  });

  group('Payment success', () {
    testWidgets('signature verifies immediately -> succeeded state, "Payment Confirmed!"', (tester) async {
      await setUpPaymentScreenDeps(tester);
      RequestOptions? verifyRequest;
      mockRazorpayChannel((_) => razorpaySuccess(orderId: 'order_xyz'));
      installFakeBackend({
        NetworkUrl.verifyBooking: (opts) {
          verifyRequest = opts;
          return {
            'success': true,
            'data': {'id': 501, 'booking_number': 'BI501'},
            'next_action': 'SHOW_BOOKING_CONFIRMED',
          };
        },
      });

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      await tester.pump();

      expect(find.text('Payment Confirmed!'), findsOneWidget);
      // orderId/paymentId are read here rather than off the controller
      // afterwards: _resolveSucceeded calls clearBookingData() as part of
      // resolving, which wipes trekC.orderId/paymentId/signature back to ''
      // by design (the booking is done, nothing left to resume) — asserting
      // them post-resolution would be asserting deliberately-cleared state.
      expect(verifyRequest?.data, contains('order_xyz'));
      expect(verifyRequest?.data, contains('pay_1'));

      await tester.pump(const Duration(seconds: 1)); // flush the 900ms delayed-navigation timer before teardown
    });

    testWidgets('verification returns false (e.g. webhook not yet landed) -> falls back to a forced order-status poll, which finds it paid', (tester) async {
      final trekC = await setUpPaymentScreenDeps(tester);
      // _pollOrderStatus resolves the order id from trekC.orderData.value.id
      // (falling back to orderNextActionParams['order_id']) — without this,
      // orderId is empty, checkOrderStatus is never called, and the screen
      // just sits in "verifying" forever (confirmed empirically: the poll
      // silently no-ops rather than erroring, so it looked like a hang).
      trekC.orderData.value = const Order(id: 'order_slow');
      mockRazorpayChannel((_) => razorpaySuccess(orderId: 'order_slow'));
      installFakeBackend({
        // NOTE: an empty `{}` map literal here infers as Map<dynamic,dynamic>
        // (no contextual type to pin it to Map<String,dynamic>), which makes
        // VerifyOrderModal.fromJson throw internally — caught by
        // verifyTrekOrder's own try/catch, which happens to also return
        // false, so this would "accidentally" test the exception path
        // instead of the real next_action-mismatch path it's meant to
        // exercise. A non-empty map sidesteps the inference quirk.
        NetworkUrl.verifyBooking: (_) => {'success': true, 'data': {'id': 0}, 'next_action': 'SOMETHING_ELSE'},
        'order-status': (_) => {
          'success': true,
          'data': {'status': 'paid', 'booking_id': 777},
        },
      });

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
      );
      // Two sequential real Dio round-trips here (verify, then the forced
      // order-status poll) — give both enough real time to settle.
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 500));
      });
      await tester.pump();
      await tester.pump();

      expect(find.text('Payment Confirmed!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1)); // flush the 900ms delayed-navigation timer before teardown
    });

    testWidgets('verification returns false and the order-status poll still says pending -> stays on a waiting screen, does not falsely resolve', (tester) async {
      final trekC = await setUpPaymentScreenDeps(tester);
      trekC.orderData.value = const Order(id: 'order_pending');
      mockRazorpayChannel((_) => razorpaySuccess(orderId: 'order_pending'));
      installFakeBackend({
        // NOTE: an empty `{}` map literal here infers as Map<dynamic,dynamic>
        // (no contextual type to pin it to Map<String,dynamic>), which makes
        // VerifyOrderModal.fromJson throw internally — caught by
        // verifyTrekOrder's own try/catch, which happens to also return
        // false, so this would "accidentally" test the exception path
        // instead of the real next_action-mismatch path it's meant to
        // exercise. A non-empty map sidesteps the inference quirk.
        NetworkUrl.verifyBooking: (_) => {'success': true, 'data': {'id': 0}, 'next_action': 'SOMETHING_ELSE'},
        'order-status': (_) => {
          'success': true,
          'data': {'status': 'pending'},
        },
      });

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
      );
      // Two sequential real Dio round-trips here (verify, then the forced
      // order-status poll) — give both enough real time to settle.
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 500));
      });
      await tester.pump();
      await tester.pump();

      expect(find.text('Payment Confirmed!'), findsNothing);
      expect(find.text('Still confirming with your bank...'), findsOneWidget);
    });
  });

  group('Payment error', () {
    testWidgets('failure with no order id anywhere -> resolves straight to the real client-side error message, and records it to Crashlytics', (tester) async {
      await setUpPaymentScreenDeps(tester);
      mockRazorpayChannel((_) => razorpayError(message: 'Payment cancelled by user'));

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Payment cancelled by user'), findsOneWidget);
      expect(find.text('GO BACK'), findsOneWidget);
      expect(find.text('RETRY'), findsOneWidget);

      final fake = FirebaseCrashlyticsPlatform.instance as FakeCrashlyticsPlatform;
      expect(fake.recordedExceptions, hasLength(1));
      expect(fake.recordedExceptions.first, contains('Payment cancelled by user'));
    });

    testWidgets('failure but the backend independently confirms the amount was refunded -> overrides the client-side failure with the real outcome', (tester) async {
      final trekC = await setUpPaymentScreenDeps(tester);
      trekC.orderData.value = const Order(id: 'order_refunded');
      mockRazorpayChannel((_) => razorpayError(message: 'Network error'));
      installFakeBackend({
        'order-status': (_) => {
          'success': true,
          'data': {'status': 'refunded', 'message': 'Fully refunded to your UPI within 5-7 days.'},
        },
      });

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      await tester.pump();

      expect(find.text('Payment Refunded'), findsOneWidget);
      expect(find.text('Fully refunded to your UPI within 5-7 days.'), findsOneWidget);
      expect(find.text('BACK TO SEARCH'), findsOneWidget);
    });

    testWidgets('failure, backend check finds the order still pending (not paid, not refunded) -> falls back to the client error message', (tester) async {
      final trekC = await setUpPaymentScreenDeps(tester);
      trekC.orderData.value = const Order(id: 'order_ambiguous');
      mockRazorpayChannel((_) => razorpayError(message: 'TLS handshake failed'));
      installFakeBackend({
        'order-status': (_) => {
          'success': true,
          'data': {'status': 'pending'},
        },
      });

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('TLS handshake failed'), findsOneWidget);
    });

    testWidgets('failure with an empty message from the gateway falls back to a generic message, never shows a blank card', (tester) async {
      await setUpPaymentScreenDeps(tester);
      mockRazorpayChannel((_) => razorpayError(message: ''));

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      await tester.pump();

      expect(find.text('Payment was not completed.'), findsOneWidget);
    });
  });

  group('External wallet', () {
    testWidgets('shows a toast naming the wallet and does not resolve the flow (still awaiting the real result)', (tester) async {
      await setUpPaymentScreenDeps(tester);
      mockRazorpayChannel((_) => razorpayExternalWallet('paytm'));

      // AppFeedback._drain() resolves Get.overlayContext to null in this
      // headless test setup (falls back to its own debugPrint rather than
      // rendering — a resilience path it deliberately has for exactly this
      // "app not ready" case) even with a real GetMaterialApp mounted, so
      // asserting on rendered toast text is asserting a codepath this test
      // harness can't reach. Its own debugPrint fallback still carries the
      // real message, which is what actually proves _handleExternalWallet
      // built the right text.
      // addTearDown() defers restoration past this test's own
      // _verifyInvariants check ("foundation debug variable changed by the
      // test"), so debugPrint is restored synchronously via try/finally
      // instead, before the test body returns.
      final logs = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) logs.add(message);
      };
      try {
        await pushPaymentScreen(
          tester,
          breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 350));
      } finally {
        debugPrint = originalDebugPrint;
      }

      expect(
        logs.any((l) => l.contains('You have chosen to pay via paytm')),
        true,
        reason: 'expected _handleExternalWallet to feed the wallet name into AppFeedback: $logs',
      );
      // Still on the awaiting/verifying screen — external wallet is not a resolution.
      expect(find.text('Complete Your Payment'), findsOneWidget);
    });
  });

  group('Watchdog timeout', () {
    testWidgets('unresolved for 3 minutes -> switches to the reassurance screen with retry/cancel actions', (tester) async {
      await setUpPaymentScreenDeps(tester);
      mockRazorpayChannel((_) => null); // never resolves — simulates the gateway never calling back

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
      );

      await tester.pump(const Duration(minutes: 3) + const Duration(seconds: 1));

      expect(find.text('Still working on it...'), findsOneWidget);
      expect(find.textContaining('taking longer than usual'), findsOneWidget);
      expect(find.text('CANCEL & CHECK LATER'), findsOneWidget);
      expect(find.text('RETRY NOW'), findsOneWidget);
    });

    testWidgets('the 15s status poll runs before the watchdog and can resolve the flow early as paid', (tester) async {
      await setUpPaymentScreenDeps(tester);
      final trekC = Get.find<TrekController>();
      trekC.orderData.value = const Order(id: 'order_late_webhook');
      mockRazorpayChannel((_) => null); // gateway never calls back at all
      installFakeBackend({
        'order-status': (_) => {
          'success': true,
          'data': {'status': 'paid', 'booking_id': 42},
        },
      });

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
      );

      // First poll fires at 15s. Real Dio round-trip inside a Timer callback
      // still needs runAsync to actually settle the interceptor-resolved Future.
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump(const Duration(seconds: 15) + const Duration(milliseconds: 500));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
      await tester.pump();

      expect(find.text('Payment Confirmed!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1)); // flush the 900ms delayed-navigation timer before teardown
    });
  });

  group('Cancel dialog / PopScope', () {
    testWidgets('back gesture while awaiting the gateway is blocked and opens the cancel-confirmation dialog', (tester) async {
      await setUpPaymentScreenDeps(tester);
      mockRazorpayChannel((_) => null);

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
      );

      // PaymentProcessingScreen has no AppBar/back button — tester.pageBack()
      // requires one and throws. Simulating the OS back gesture directly is
      // the standard way to exercise PopScope/WillPopScope without one.
      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(find.text('Cancel Payment?'), findsOneWidget);
      expect(find.text('Payment Confirmed!'), findsNothing); // still on the processing screen underneath
    });

    testWidgets('"Stay" dismisses the dialog and leaves the payment flow running untouched', (tester) async {
      await setUpPaymentScreenDeps(tester);
      mockRazorpayChannel((_) => null);

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
      );
      // PaymentProcessingScreen has no AppBar/back button — tester.pageBack()
      // requires one and throws. Simulating the OS back gesture directly is
      // the standard way to exercise PopScope/WillPopScope without one.
      await tester.binding.handlePopRoute();
      await tester.pump();

      await tester.tap(find.text('Stay'));
      await tester.pump();

      expect(find.text('Cancel Payment?'), findsNothing);
      expect(find.text('Complete Your Payment'), findsOneWidget);
    });

    testWidgets('"Leave Anyway" pops back to the screen underneath, without waiting for a real payment result', (tester) async {
      await setUpPaymentScreenDeps(tester);
      mockRazorpayChannel((_) => null);

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
      );
      // PaymentProcessingScreen has no AppBar/back button — tester.pageBack()
      // requires one and throws. Simulating the OS back gesture directly is
      // the standard way to exercise PopScope/WillPopScope without one.
      await tester.binding.handlePopRoute();
      await tester.pump();

      await tester.tap(find.text('Leave Anyway'));
      await tester.pump(); // lets the dialog's own Navigator.pop(ctx, true) Future resolve
      await tester.pump(); // Get.back()'s pop transition start
      await tester.pump(const Duration(milliseconds: 350)); // let the pop transition finish

      expect(find.byType(PaymentProcessingScreen), findsNothing);
    });

    testWidgets('once resolved (succeeded), back navigation is no longer blocked by the dialog', (tester) async {
      await setUpPaymentScreenDeps(tester);
      mockRazorpayChannel((_) => razorpaySuccess());
      installFakeBackend({
        NetworkUrl.verifyBooking: (_) => {
          'success': true,
          'data': {'id': 1},
          'next_action': 'SHOW_BOOKING_CONFIRMED',
        },
      });

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      await tester.pump();
      expect(find.text('Payment Confirmed!'), findsOneWidget);

      // PaymentProcessingScreen has no AppBar/back button — tester.pageBack()
      // requires one and throws. Simulating the OS back gesture directly is
      // the standard way to exercise PopScope/WillPopScope without one.
      await tester.binding.handlePopRoute();
      await tester.pump();

      // canPop is true once succeeded, so PopScope lets it through instead
      // of invoking _showCancelDialog.
      expect(find.text('Cancel Payment?'), findsNothing);
      await tester.pump(const Duration(seconds: 1)); // flush the 900ms delayed-navigation timer before teardown
    });
  });

  group('Retry', () {
    testWidgets('a captured payment id (verification failed, not the gateway) retries verification directly, without reopening Razorpay', (tester) async {
      final trekC = await setUpPaymentScreenDeps(tester);
      mockRazorpayChannel((_) => razorpayError(message: 'Verification timed out'));

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      await tester.pump();
      expect(find.text('Something went wrong'), findsOneWidget);

      // Simulate a payment id already captured from an earlier attempt.
      trekC.paymentId.value = 'pay_captured_earlier';
      trekC.orderId.value = 'order_captured_earlier';
      trekC.signature.value = 'sig_captured_earlier';
      installFakeBackend({
        NetworkUrl.verifyBooking: (_) => {
          'success': true,
          'data': {'id': 9},
          'next_action': 'SHOW_BOOKING_CONFIRMED',
        },
      });

      // The tap must happen *inside* runAsync, not just be followed by one:
      // _retry()'s async continuation (the real verifyTrekOrder Dio call)
      // otherwise keeps running under FakeAsync's zone from the tap that
      // started it, and a runAsync() called only afterwards doesn't pull an
      // already-in-flight Future onto the real event loop retroactively
      // (confirmed — the screen stayed on "verifying" indefinitely with a
      // trailing-delay-only version of this test).
      await tester.runAsync(() async {
        await tester.tap(find.text('RETRY'));
        await Future.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      await tester.pump();

      expect(find.text('Payment Confirmed!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1)); // flush the 900ms delayed-navigation timer before teardown
    });

    testWidgets('an existing order but no captured payment reopens Razorpay directly, skipping fare recalculation', (tester) async {
      final trekC = await setUpPaymentScreenDeps(tester);
      final calls = mockRazorpayChannel((_) => razorpayError(message: 'User dismissed checkout'));

      trekC.orderData.value = const Order(id: 'order_existing');
      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      await tester.pump();
      expect(find.text('Something went wrong'), findsOneWidget);

      final openCallsBefore = calls.where((c) => c.method == 'open').length;
      await tester.tap(find.text('RETRY'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final openCallsAfter = calls.where((c) => c.method == 'open').length;
      expect(openCallsAfter, openCallsBefore + 1);
    });

    testWidgets('no captured payment and no existing order re-fetches fare and creates a fresh order before reopening Razorpay', (tester) async {
      final trekC = await setUpPaymentScreenDeps(tester);
      mockRazorpayChannel((_) => razorpayError(message: 'Order expired'));

      await pushPaymentScreen(
        tester,
        breakdown: BreakDownDataModel(finalAmount: 10510, amountToPayNow: 5000),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      await tester.pump();
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(trekC.orderData.value.id, isNull); // confirms this exercises the "no existing order" branch

      installFakeBackend({
        NetworkUrl.calculateFare: (_) => {
          'success': true,
          'fareToken': 'tok-retry',
          'breakdown': {'final_amount': 10510, 'amount_to_pay_now': 10510},
        },
        NetworkUrl.addBooking: (_) => {
          'success': true,
          'order': {'id': 'order_fresh', 'amount': 1051000, 'currency': 'INR'},
          'next_action_params': {},
        },
      });
      final calls = mockRazorpayChannel((_) => razorpayError(message: 'still testing'));

      await tester.runAsync(() async {
        await tester.tap(find.text('RETRY'));
        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      await tester.pump();

      expect(trekC.orderData.value.id, 'order_fresh');
      expect(calls.any((c) => c.method == 'open'), true);
    });
  });
}
