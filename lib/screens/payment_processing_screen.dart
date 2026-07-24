import 'dart:async';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/freezed_models/booking/booking_data_model.dart';
import 'package:arobo_app/screens/booking_upcoming_screen.dart';
import 'package:arobo_app/screens/dashboard_main.dart';
import 'package:arobo_app/utils/booking_constants.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sizer/sizer.dart';

/// Local design tokens — same values as _TI in traveller_information_screen.dart,
/// duplicated because Dart library privacy (the `_` prefix) is per-file, and
/// every screen in this codebase already follows this same local-token-class
/// convention (see _TI here, _Pay in payment_screen.dart).
class _PP {
  static const bg = CommonColors.offWhiteColor;
  static const cardBg = CommonColors.whiteColor;
  static const ink = CommonColors.blackColor;
  static const inkMid = CommonColors.cFF6B7280;
  static const brand = Color(0xFF2D6A4F);
  static const green = CommonColors.softGreen3;
  static const amber = CommonColors.orangeColor;
  static const red = CommonColors.appRedColor;
  static const divider = CommonColors.trekroutecolorlight;
}

/// Every state here maps to one real, verified signal — never to elapsed
/// time. See the FSM design in the payment-processing-screen plan: Razorpay
/// callback -> S2S verifyTrekOrder -> checkOrderStatus (the authoritative
/// backend source of truth, returning real 'paid'/'refunded'/'expired'/
/// 'pending' states) drive every transition.
enum PaymentFlowState {
  awaitingGateway, // Razorpay open, zero signal yet — the only generic-copy state
  verifying, // Razorpay fired success; confirming with our backend (S2S)
  succeeded,
  refundedAutomatically, // backend's real message, e.g. slot sold out mid-payment
  expiredOrFailed,
  stillPending, // backend confirms genuinely still in flight
  unknownTimeout, // last resort — even backend polling never resolved
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

  // Active polling of the real backend order-status while we have no
  // terminal signal yet — resolves the screen the moment real data is
  // available instead of waiting out the full watchdog window (matches the
  // Adyen "poll every 15 min for an hour" pattern, scaled to this app's
  // much shorter payment window).
  Timer? _statusPoll;
  Timer? _watchdog;
  bool _resolved = false; // guards against any double-resolution race

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _openRazorpay();
  }

  @override
  void dispose() {
    _statusPoll?.cancel();
    _watchdog?.cancel();
    _razorpay.clear();
    super.dispose();
  }

  // ── ENTRY POINTS ────────────────────────────────────────────────────────
  void _openRazorpay() async {
    try {
      final breakdown = widget.breakdown;
      final params = _trekC.orderNextActionParams;
      final options = {
        'key': params['key'] ?? BookingConstants.razorpayKey,
        'order_id': params['order_id'] ?? '${_trekC.orderData.value.id}',
        'amount':
            params['amount'] ??
            (((widget.selectedPaymentOption == 'full'
                            ? breakdown?.finalAmount
                            : breakdown?.amountToPayNow) ??
                        0) *
                    100)
                .toInt(),
        'currency': params['currency'] ?? 'INR',
        'name': params['name'] ?? '${_trekC.trekDetailData.value.title}',
        'description':
            params['description'] ??
            '${_trekC.trekDetailData.value.description}',
        'prefill': {
          'contact': '${_userC.userProfileData.value.customer?.phone}',
          'email': '${_userC.userProfileData.value.customer?.email}',
        },
      };
      _razorpay.open(options);
      _startWatchingForRealStatus();
    } catch (e) {
      // _razorpay.open() failing synchronously (e.g. malformed options) must
      // not leave this screen stuck — same class of bug fixed earlier in
      // traveller_information_screen.dart, fixed here at the source instead.
      _resolveViaBackendCheck(
        fallbackMessage: 'Failed to open payment: ${e.toString()}',
      );
    }
  }

  /// Arms both the active poll (resolves fast when the backend already
  /// knows the answer) and the absolute-last-resort watchdog.
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

  // ── RAZORPAY CALLBACKS ──────────────────────────────────────────────────
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
    } else {
      // Razorpay says captured, our S2S verify disagreed — check the real
      // order-status before assuming failure (per Razorpay's own best
      // practice: trust the server-verified state, not a single signal).
      await _pollOrderStatus(force: true);
    }
  }

  Future<void> _handlePaymentError(PaymentFailureResponse r) async {
    if (_resolved) return;
    await _resolveViaBackendCheck(
      fallbackMessage: (r.message?.isNotEmpty ?? false)
          ? r.message!
          : 'Payment was not completed.',
    );
  }

  void _handleExternalWallet(ExternalWalletResponse r) {
    CustomSnackBar.show(
      context,
      message:
          'You have chosen to pay via ${r.walletName}. It may take some time to reflect.',
    );
  }

  // ── REAL BACKEND STATE (the authoritative source of truth) ─────────────
  /// GET /v1/bookings/order-status/:order_id — returns real 'paid' /
  /// 'refunded' / 'expired' / 'pending', with the backend's own real
  /// messages for 'refunded' (e.g. slot sold out mid-payment). This is
  /// what actually drives the screen — never a guess based on elapsed time.
  Future<void> _pollOrderStatus({bool force = false}) async {
    if (_resolved && !force) return;
    final orderId =
        _trekC.orderData.value.id ??
        _trekC.orderNextActionParams['order_id']?.toString() ??
        '';
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
              'Your payment was fully refunded automatically.',
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
        if (mounted && !_resolved) {
          setState(() {
            _state = PaymentFlowState.stillPending;
            _message = 'Still confirming with your bank...';
          });
        }
        break;
    }
  }

  Future<void> _resolveViaBackendCheck({required String fallbackMessage}) async {
    final orderId =
        _trekC.orderData.value.id ??
        _trekC.orderNextActionParams['order_id']?.toString() ??
        '';
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
                  'Your payment was fully refunded automatically.',
            );
            return;
        }
      }
    }
    _resolveTerminal(PaymentFlowState.expiredOrFailed, fallbackMessage);
  }

  void _resolveSucceeded({String? bookingId}) {
    if (_resolved) return;
    _resolved = true;
    _statusPoll?.cancel();
    _watchdog?.cancel();
    if (!mounted) return;
    setState(() => _state = PaymentFlowState.succeeded);

    final String finalBookingId =
        bookingId ??
        (_trekC.verifyOrderModal.value.data?.id ?? _trekC.orderData.value.id ?? '')
            .toString();

    _trekC.clearBookingData();
    _dashboardC.clearSearchAndBookingData();

    // Brief success flourish before navigating — matches industry pattern
    // of showing an explicit success indicator, not an instant cut-away.
    Future.delayed(const Duration(milliseconds: 900), () {
      // Rebuild the stack as Home -> Booking Details, not just Booking
      // Details alone. A completed booking must clear Checkout/Trek
      // Details/Search Results behind it (Get.off alone would leave
      // Checkout in place, landing back on the payment page on back-press)
      // — but wiping the ENTIRE stack down to nothing also removes Home,
      // so a single back-press exits the app outright instead of landing
      // on Home. DashboardMain already owns proper double-back-to-exit
      // handling, so put that back as the root first.
      Get.offAll(() => const DashboardMain());
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
    if (!mounted) return;
    setState(() {
      _state = state;
      _message = message;
    });
  }

  // ── RETRY (fully self-contained — never bounces back to Checkout) ──────
  Future<void> _retry() async {
    if (!mounted) return;
    setState(() {
      _resolved = false;
      _state = PaymentFlowState.awaitingGateway;
      _message = 'Choose a payment option above to continue.';
    });

    final hasCapturedPayment = _trekC.paymentId.value.isNotEmpty;
    final existingOrderId =
        _trekC.orderData.value.id ??
        _trekC.orderNextActionParams['order_id']?.toString();
    final hasExistingOrder = (existingOrderId ?? '').isNotEmpty;

    if (hasCapturedPayment) {
      setState(() => _state = PaymentFlowState.verifying);
      final verified = await _trekC.verifyTrekOrder(
        razorpayOrderId: _trekC.orderId.value,
        razorpayPaymentId: _trekC.paymentId.value,
        razorpaySignature: _trekC.signature.value,
      );
      if (verified) {
        _resolveSucceeded();
      } else {
        _resolveTerminal(
          PaymentFlowState.expiredOrFailed,
          'Still could not confirm your payment. Please try again.',
        );
      }
    } else if (hasExistingOrder) {
      _openRazorpay();
    } else {
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
      await _trekC.createTrekOrder();
      if (_trekC.orderModal.value.success ?? false) {
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
  }

  Future<void> _showCancelDialog() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text(
          'Your payment is still being processed. If any amount was already '
          'deducted, it will never be charged twice — your booking will still '
          'go through safely once confirmed. Are you sure you want to leave?',
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
      Get.back();
    }
  }

  // ── UI ───────────────────────────────────────────────────────────────────
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
          actions: [_primaryAction('BACK TO SEARCH', () => Get.until((r) => r.isFirst))],
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
                    child: Lottie.asset(lottieAsset, repeat: loop, fit: BoxFit.contain),
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
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: titleColor ?? _PP.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.sp,
              color: _PP.inkMid,
              height: 1.4,
            ),
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
