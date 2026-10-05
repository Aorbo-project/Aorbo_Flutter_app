import 'dart:async';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/payment_verify_outcome.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/security/screen_security.dart';
import 'package:arobo_app/freezed_models/booking/booking_data_model.dart';
import 'package:arobo_app/screens/booking_upcoming_screen.dart';
import 'package:arobo_app/screens/dashboard_main.dart';
import 'package:arobo_app/utils/booking_constants.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';

class _PP {
  static const bg = CommonColors.offWhiteColor;
  static const cardBg = CommonColors.whiteColor;
  static const ink = CommonColors.blackColor;
  static const inkMid = CommonColors.cFF6B7280;
  static const brand = AppColors.forest;
  static const green = CommonColors.softGreen3;
  static const amber = CommonColors.orangeColor;
  static const red = CommonColors.appRedColor;
  static const divider = CommonColors.trekroutecolorlight;
}

enum PaymentFlowState {
  awaitingGateway,
  verifying,
  succeeded,
  refundedAutomatically,
  expiredOrFailed,
  stillPending,
  unknownTimeout,
}

class PaymentProcessingScreen extends StatefulWidget {
  final BreakDownDataModel? breakdown;
  final String selectedPaymentOption;

  const PaymentProcessingScreen({
    super.key,
    required this.breakdown,
    required this.selectedPaymentOption,
  });

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  final TrekController _trekC = Get.find<TrekController>();
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final UserController _userC = Get.find<UserController>();

  late Razorpay _razorpay;
  PaymentFlowState _state = PaymentFlowState.awaitingGateway;
  String _message = 'Choose a payment option above to continue.';

  Timer? _statusPoll;
  Timer? _watchdog;
  bool _resolved = false;

  // Scan D8 (#2): after a gateway error the bank may still be settling (UPI
  // approved, then the app returned early or the network dropped). While the
  // order reads "pending" we keep checking for [_graceChecks] x
  // [_graceInterval] before showing an error, so RETRY can't open a second
  // checkout on an order that is about to be paid.
  static const Duration _graceInterval = Duration(seconds: 5);
  static const int _graceChecks = 12;
  Timer? _gracePoll;
  bool _inGrace = false;
  int _graceLeft = 0;
  String _graceFallback = '';

  // The success screen's delayed hop to the booking; cancelled on dispose so
  // it can never navigate from a screen that is already gone.
  Timer? _successNav;

  @override
  void initState() {
    super.initState();
    // Scan E10: no screenshots / screen sharing while paying.
    ScreenSecurity.enter();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _openRazorpay();
  }

  @override
  void dispose() {
    ScreenSecurity.leave();
    _statusPoll?.cancel();
    _watchdog?.cancel();
    _gracePoll?.cancel();
    _successNav?.cancel();
    _razorpay.clear();
    super.dispose();
  }

  /// API money fields are dynamic (often Strings). "1234.00" * 100 in Dart
  /// is STRING REPETITION → .toInt() throws. Parse defensively.
  int _toPaise(dynamic v) {
    final n = v is num ? v.toDouble() : double.tryParse('${v ?? 0}') ?? 0.0;
    return (n * 100).round();
  }

  void _openRazorpay() async {
    try {
      final breakdown = widget.breakdown;
      final params = _trekC.orderNextActionParams;
      final options = {
        'key': params['key'] ?? BookingConstants.razorpayKey,
        'order_id': params['order_id'] ?? '${_trekC.orderData.value.id}',
        'amount':
            params['amount'] ??
            _toPaise(
              widget.selectedPaymentOption == 'full'
                  ? breakdown?.finalAmount
                  : breakdown?.amountToPayNow,
            ),
        'currency': params['currency'] ?? 'INR',
        'name': params['name'] ?? '${_trekC.trekDetailData.value.title}',
        'description':
            params['description'] ??
            '${_trekC.trekDetailData.value.description}',
        'prefill': {
          'contact': '${_userC.userProfileData.value.customer?.phone}',
          'email': '${_userC.userProfileData.value.customer?.email}',
        },
        // Close Checkout when the booking session ends (seconds; sent by the
        // server). A payment made after it can only be refunded.
        'timeout': params['timeout'] ?? 900,
      };
      _razorpay.open(options);
      _startWatchingForRealStatus();
    } catch (e) {
      _resolveViaBackendCheck(
        fallbackMessage: 'Could not open the payment page. Please try again.',
      );
    }
  }

  void _startWatchingForRealStatus() {
    _statusPoll?.cancel();
    _statusPoll = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!_resolved) _pollOrderStatus();
    });

    _watchdog?.cancel();
    _watchdog = Timer(const Duration(minutes: 3), () {
      if (!_resolved && mounted) {
        setState(() {
          _state = PaymentFlowState.unknownTimeout;
          _message =
              'This is taking longer than usual. No need to worry — most '
              'payments complete within 2–5 minutes. If it doesn\'t go '
              'through, any amount already deducted is automatically '
              'refunded to your original payment method.';
        });
      }
    });
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse r) async {
    if (_resolved) return;
    if (mounted) setState(() => _state = PaymentFlowState.verifying);

    _trekC.orderId.value = r.orderId ?? '';
    _trekC.paymentId.value = r.paymentId ?? '';
    _trekC.signature.value = r.signature ?? '';

    final verified = await _trekC.verifyTrekOrder(
      razorpayOrderId: r.orderId ?? '',
      razorpayPaymentId: r.paymentId ?? '',
      razorpaySignature: r.signature ?? '',
    );

    if (verified) {
      _resolveSucceeded();
    } else if (_resolveIfRefunded()) {
      return;
    } else {
      await _pollOrderStatus(force: true);
    }
  }

  /// The verify reply said the payment was already refunded: show
  /// that straight away (no order-status poll, never "confirmed").
  bool _resolveIfRefunded() {
    if (_trekC.lastVerifyOutcome.value != VerifyPaymentOutcome.refunded) {
      return false;
    }
    final message = _trekC.lastVerifyMessage.value;
    _resolveTerminal(
      PaymentFlowState.refundedAutomatically,
      message.isNotEmpty ? message : paymentRefundedFallbackMessage,
    );
    return true;
  }

  Future<void> _handlePaymentError(PaymentFailureResponse r) async {
    FirebaseCrashlytics.instance.recordError(
      'Razorpay payment failed: code=${r.code} message=${r.message}',
      null,
      reason: 'Razorpay EVENT_PAYMENT_ERROR (payment_processing_screen)',
      fatal: false,
    );
    if (_resolved) return;
    await _resolveViaBackendCheck(
      fallbackMessage: (r.message?.isNotEmpty ?? false)
          ? r.message!
          : 'Payment was not completed.',
      // Review C-M1: the customer closed the checkout sheet. No payment
      // exists, so the order stays "pending" until it expires; the grace poll
      // would show "Checking with your bank..." for a minute with no RETRY.
      // One check, then the error card + RETRY at once (RETRY re-checks the
      // order first and reuses it while pending, so no double charge).
      cancelledByCustomer: r.code == Razorpay.PAYMENT_CANCELLED,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse r) {
    CustomSnackBar.show(
      context,
      message:
          'You have chosen to pay via ${r.walletName}. It may take some time to reflect.',
    );
  }

  /// The Razorpay order this screen is about: the created order, else the
  /// one Checkout reported back with the captured payment.
  String get _currentOrderId {
    final created = _trekC.orderData.value.id ??
        _trekC.orderNextActionParams['order_id']?.toString();
    if (created != null && created.isNotEmpty) return created;
    return _trekC.orderId.value;
  }

  // One order-status check at a time (the 15 s poll and the grace checks
  // join a check that is still running instead of starting another).
  Future<void>? _statusCheck;

  Future<void> _pollOrderStatus({bool force = false}) {
    if (_resolved && !force) return Future.value();
    return _statusCheck ??= _checkOrderStatusOnce().whenComplete(() {
      _statusCheck = null;
    });
  }

  Future<void> _checkOrderStatusOnce() async {
    final orderId = _currentOrderId;
    if (orderId.isEmpty) return;

    final status = await _trekC.checkOrderStatus(orderId);
    if (!mounted || status == null) return;

    switch (status['status']) {
      case 'paid':
        _resolveSucceeded(bookingId: status['booking_id']?.toString());
        break;
      case 'refunded':
        _resolveTerminal(
          PaymentFlowState.refundedAutomatically,
          status['message']?.toString() ??
              paymentRefundedFallbackMessage,
        );
        break;
      case 'expired':
        _resolveTerminal(
          PaymentFlowState.expiredOrFailed,
          status['message']?.toString() ??
              'This order has expired or the payment failed.',
        );
        break;
      case 'pending':
        // During the grace checks the screen already says "Checking with
        // your bank..." — keep it (review C L8).
        if (mounted && !_resolved && !_inGrace) {
          setState(() {
            _state = PaymentFlowState.stillPending;
            _message = 'Still confirming with your bank...';
          });
        }
        break;
    }
  }

  Future<void> _resolveViaBackendCheck({
    required String fallbackMessage,
    bool cancelledByCustomer = false,
  }) async {
    final orderId = _currentOrderId;
    if (orderId.isNotEmpty) {
      final status = await _trekC.checkOrderStatus(orderId);
      if (status != null) {
        switch (status['status']) {
          case 'paid':
            _resolveSucceeded(bookingId: status['booking_id']?.toString());
            return;
          case 'refunded':
            _resolveTerminal(
              PaymentFlowState.refundedAutomatically,
              status['message']?.toString() ??
                  paymentRefundedFallbackMessage,
            );
            return;
          case 'pending':
            if (cancelledByCustomer) break; // straight to the error card + RETRY
            _startGracePoll(fallbackMessage);
            return;
        }
      }
    }
    _resolveTerminal(PaymentFlowState.expiredOrFailed, fallbackMessage);
  }

  /// The order is still "pending" after a gateway error: keep checking with
  /// the server for a short while instead of declaring a failure.
  void _startGracePoll(String fallbackMessage) {
    if (_resolved || !mounted) return;
    _graceFallback = fallbackMessage;
    _graceLeft = _graceChecks;
    setState(() {
      _state = PaymentFlowState.stillPending;
      _message = 'Checking with your bank...';
    });
    _gracePoll?.cancel();
    _inGrace = true;
    _scheduleGraceCheck();
  }

  // Review C L8: the next check is scheduled only after the previous one
  // has answered. A periodic timer started a new check every 5 s even while
  // a slow one was still running, so checks overlapped and the grace period
  // ran out early on exactly the slow networks it is for.
  void _scheduleGraceCheck() {
    _gracePoll = Timer(_graceInterval, _gracePollTick);
  }

  Future<void> _gracePollTick() async {
    if (_resolved || !mounted) return;
    _graceLeft--;
    await _pollOrderStatus();
    if (_resolved || !mounted) return;
    if (_graceLeft <= 0) {
      _resolveTerminal(PaymentFlowState.expiredOrFailed, _graceFallback);
      return;
    }
    _scheduleGraceCheck();
  }

  void _resolveSucceeded({String? bookingId}) {
    if (_resolved) return;
    _resolved = true;
    _statusPoll?.cancel();
    _watchdog?.cancel();
    _gracePoll?.cancel();
    _inGrace = false;
    if (!mounted) return;
    setState(() => _state = PaymentFlowState.succeeded);

    final String finalBookingId =
        bookingId ??
        (_trekC.verifyOrderModal.value.data?.id ??
                _trekC.orderData.value.id ??
                '')
            .toString();

    final int? invoiceBookingId = int.tryParse(finalBookingId);
    if (invoiceBookingId != null) {
      // Fire-and-forget — the booking succeeded regardless.
      _dashboardC.generateAndUploadInvoice(invoiceBookingId);
    }

    _trekC.clearBookingData();
    _dashboardC.clearSearchAndBookingData();

    // ← FIXED: replaced Get.offAll (which destroyed & recreated
    //    DashboardMain, re-triggering initState → rate popup)
    //    with Get.until (pops back to the EXISTING DashboardMain)
    //    + Get.to (pushes booking detail on top).
    _successNav?.cancel();
    _successNav = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      // Pop every route above the first one (DashboardMain).
      // This removes TravellerInformationScreen and
      // PaymentProcessingScreen from the stack.
      Get.until((route) => route.isFirst);

      // Push the booking-detail screen on top of the still-alive
      // DashboardMain. No new DashboardMain is created, so its
      // initState (and the rate popup) will NOT re-fire.
      Get.to(
        () => BookingsUpcomingScreen(bookingId: finalBookingId),
        transition: Transition.rightToLeftWithFade,
        duration: const Duration(milliseconds: 350),
      );
    });
  }

  void _resolveTerminal(PaymentFlowState state, String message) {
    if (_resolved) return;
    _resolved = true;
    _statusPoll?.cancel();
    _watchdog?.cancel();
    _gracePoll?.cancel();
    _inGrace = false;
    if (!mounted) return;
    setState(() {
      _state = state;
      _message = message;
    });
  }

  Future<void> _retry() async {
    if (!mounted) return;
    setState(() {
      _resolved = false;
      _state = PaymentFlowState.awaitingGateway;
      _message = 'Choose a payment option above to continue.';
    });

    final hasCapturedPayment = _trekC.paymentId.value.isNotEmpty;
    final existingOrderId = _currentOrderId;
    final hasExistingOrder = existingOrderId.isNotEmpty;

    if (hasCapturedPayment) {
      setState(() => _state = PaymentFlowState.verifying);
      final verified = await _trekC.verifyTrekOrder(
        razorpayOrderId: _trekC.orderId.value,
        razorpayPaymentId: _trekC.paymentId.value,
        razorpaySignature: _trekC.signature.value,
      );
      if (verified) {
        _resolveSucceeded();
      } else if (!_resolveIfRefunded()) {
        // Review C L9: the verify call can come back unconfirmed although the
        // booking exists (the webhook completed it, a reply the app could
        // not read, a 409 after an automatic refund ...). Ask the server for
        // the order's state before calling it a failure.
        await _resolveViaBackendCheck(
          fallbackMessage:
              'Still could not confirm your payment. Please try again.',
        );
      }
    } else if (hasExistingOrder) {
      // Scan D8 (#2): ask the server first — reopening checkout on an order
      // that was paid meanwhile is how a customer gets charged twice.
      setState(() => _state = PaymentFlowState.verifying);
      final status = await _trekC.checkOrderStatus(existingOrderId);
      if (!mounted) return;
      switch (status?['status']) {
        case 'paid':
          _resolveSucceeded(bookingId: status?['booking_id']?.toString());
          return;
        case 'refunded':
          _resolveTerminal(
            PaymentFlowState.refundedAutomatically,
            status?['message']?.toString() ??
                paymentRefundedFallbackMessage,
          );
          return;
        case 'expired':
          // Review C-M2: "expired" also covers an order whose attempt was only
          // declined; it can still be paid (and a UPI attempt can still be
          // authorised late) until expires_at. A second order next to it is a
          // double-charge risk, so reuse it while the server says retryable.
          if (status?['retryable'] == true) {
            setState(() => _state = PaymentFlowState.awaitingGateway);
            _openRazorpay();
          } else {
            await _startFreshOrder();
          }
          return;
        default:
          // pending (its grace period is over) or unknown: same order.
          setState(() => _state = PaymentFlowState.awaitingGateway);
          _openRazorpay();
      }
    } else {
      await _startFreshOrder();
    }
  }

  /// No usable order: refresh the fare, create a new order, open checkout.
  Future<void> _startFreshOrder() async {
    await _trekC.calculateFare();
    final refreshed = _trekC.calculateFareResponseModel.value.maybeWhen(
      success: (_) => true,
      orElse: () => false,
    );
    if (!refreshed) {
      _resolveTerminal(
        PaymentFlowState.expiredOrFailed,
        'Could not refresh fare. Please try again.',
      );
      return;
    }
    final created = await _trekC.createTrekOrder();
    if (!mounted) return;
    if (created) {
      _openRazorpay();
    } else {
      _resolveTerminal(
        PaymentFlowState.expiredOrFailed,
        _trekC.errorMessage.value.isNotEmpty
            ? _trekC.errorMessage.value
            : 'Could not start payment. Please try again.',
      );
    }
  }

  Future<void> _showCancelDialog() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text(
          'Your payment is still being processed. If it goes through, your '
          'booking will appear in My Bookings. If money was deducted but no '
          'booking is made, it is refunded to your original payment method; '
          'refunds usually take 5–7 business days. Are you sure you want to '
          'leave?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Leave Anyway', style: TextStyle(color: _PP.red)),
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      _resolved = true;
      _statusPoll?.cancel();
      _watchdog?.cancel();
      _gracePoll?.cancel();
      _inGrace = false;
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final blockPop =
        _state == PaymentFlowState.awaitingGateway ||
        _state == PaymentFlowState.verifying ||
        _state == PaymentFlowState.stillPending;

    return PopScope(
      canPop: !blockPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showCancelDialog();
      },
      child: Scaffold(
        backgroundColor: _PP.bg,
        body: SafeArea(child: Center(child: _buildForState())),
      ),
    );
  }

  Widget _buildForState() {
    switch (_state) {
      case PaymentFlowState.succeeded:
        return _statusCard(
          lottieAsset: 'assets/animations/tick_animation.json',
          loop: false,
          title: 'Payment Confirmed!',
          message: 'Redirecting to your booking...',
          titleColor: _PP.green,
        );
      case PaymentFlowState.refundedAutomatically:
        return _statusCard(
          icon: Icons.replay_circle_filled_rounded,
          iconColor: _PP.amber,
          title: 'Payment Refunded',
          message: _message,
          actions: [
            _primaryAction('BACK TO SEARCH', () => Get.until((r) => r.isFirst)),
          ],
        );
      case PaymentFlowState.expiredOrFailed:
        return _statusCard(
          icon: Icons.error_outline_rounded,
          iconColor: _PP.red,
          title: 'Something went wrong',
          message: _message,
          actions: [
            _secondaryAction('GO BACK', () => Get.back()),
            _primaryAction('RETRY', _retry),
          ],
        );
      case PaymentFlowState.unknownTimeout:
        return _statusCard(
          lottieAsset: 'assets/animations/hiking_animation.json',
          loop: true,
          softened: true,
          title: 'Still working on it...',
          message: _message,
          actions: [
            _secondaryAction('CANCEL & CHECK LATER', _showCancelDialog),
            _primaryAction('RETRY NOW', _retry),
          ],
        );
      case PaymentFlowState.awaitingGateway:
        return _statusCard(
          lottieAsset: 'assets/animations/hiking_animation.json',
          loop: true,
          title: 'Complete Your Payment',
          message: _message,
        );
      case PaymentFlowState.verifying:
      case PaymentFlowState.stillPending:
        return _statusCard(
          lottieAsset: 'assets/animations/hiking_animation.json',
          loop: true,
          title: 'Confirming your payment',
          message: _state == PaymentFlowState.verifying
              ? 'Verifying with your bank...'
              : _message,
        );
    }
  }

  Widget _statusCard({
    String? lottieAsset,
    bool loop = false,
    bool softened = false,
    IconData? icon,
    Color? iconColor,
    required String title,
    required String message,
    Color? titleColor,
    List<Widget>? actions,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _PP.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lottieAsset != null)
            Opacity(
              opacity: softened ? 0.55 : 1.0,
              child: Container(
                width: 46.w,
                height: 46.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _PP.brand.withValues(alpha: 0.08),
                ),
                child: ClipOval(
                  child: SizedBox(
                    width: 34.w,
                    height: 34.w,
                    child: Lottie.asset(
                      lottieAsset,
                      repeat: loop,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            )
          else if (icon != null)
            Icon(icon, size: 56, color: iconColor ?? _PP.ink),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppType.style(
              16.sp,
              w: FontWeight.w700,
              color: titleColor ?? _PP.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppType.style(11.sp, color: _PP.inkMid, height: 1.4),
          ),
          if (actions != null) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                for (int i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: actions[i]),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _primaryAction(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _PP.brand,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label),
    );
  }

  Widget _secondaryAction(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _PP.inkMid,
        side: BorderSide(color: _PP.divider),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label),
    );
  }
}
