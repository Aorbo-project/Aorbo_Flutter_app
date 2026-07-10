import 'dart:async';

import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

/// Backend-authoritative fallback for payment confirmation.
///
/// Reached whenever the app resumes after a Razorpay checkout attempt —
/// regardless of whether Razorpay's own success/error callback ever fires
/// back to Dart. That callback is treated as a best-effort fast path only;
/// it can be silently dropped by the Android OS (Activity recreation under
/// memory pressure detaches the plugin's ActivityResultListener — confirmed
/// via razorpay_flutter's own source). This screen doesn't depend on it at
/// all: it polls the backend's own order-status endpoint, which reflects
/// whatever already resolved the payment server-side — the client's own
/// verify-payment call, the Razorpay webhook, or the reconciliation cron —
/// so booking confirmation completes correctly even when Flutter never
/// heard from the Razorpay SDK.
class ProcessingBookingScreen extends StatefulWidget {
  const ProcessingBookingScreen({super.key});

  @override
  State<ProcessingBookingScreen> createState() => _ProcessingBookingScreenState();
}

class _ProcessingBookingScreenState extends State<ProcessingBookingScreen> {
  final TrekController _trekC = Get.find<TrekController>();

  Timer? _pollTimer;
  int _pollCount = 0;
  static const int _maxPolls = 40; // ~2 minutes before giving up
  static const Duration _pollInterval = Duration(seconds: 3);

  bool _timedOut = false;
  String? _orderId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    _orderId = args is Map ? args['orderId']?.toString() : null;
    WidgetsBinding.instance.addPostFrameCallback((_) => _startPolling());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    if (_orderId == null || _orderId!.isEmpty) {
      _giveUp('Something went wrong resuming your payment. Please check My Bookings.');
      return;
    }
    _poll(); // check immediately — don't make the user wait a full interval first
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  Future<void> _poll() async {
    _pollCount++;
    final status = await _trekC.checkOrderStatus(_orderId!);
    if (!mounted) return;

    if (status == null) {
      // Inconclusive (network blip, or genuinely not found yet) — never
      // guess; keep polling until the max, matching the conservative rule
      // used everywhere else in this payment flow.
      if (_pollCount >= _maxPolls) _giveUp(null);
      return;
    }

    switch (status['status']) {
      case 'paid':
        await _resolvePaid(status);
        break;
      case 'expired':
      case 'refunded':
        await _resolveDead(status['status'] as String);
        break;
      case 'pending':
      default:
        if (_pollCount >= _maxPolls) _giveUp(null);
        break;
    }
  }

  Future<void> _resolvePaid(Map<String, dynamic> status) async {
    _pollTimer?.cancel();
    final pref = await SpUtil.getInstance();
    await pref.remove(SpUtil.pendingOrderId);
    await pref.remove(SpUtil.pendingCorrelationId);
    if (!mounted) return;

    final rawBookingId = status['booking_id'];
    final bookingId = rawBookingId is int
        ? rawBookingId
        : int.tryParse(rawBookingId?.toString() ?? '');
    if (bookingId != null) {
      await _trekC.fetchAndPopulateTicketData(bookingId);
    }
    if (!mounted) return;

    // Payment → Processing → Booking Confirmed → Ticket. PaymentSuccessPage
    // already combines the confirmation animation and the ticket view, so
    // this single navigation covers both remaining steps. offNamed replaces
    // this screen (and, transitively, Payment before it) — no path back.
    Get.offNamed('/payment-success');
  }

  Future<void> _resolveDead(String status) async {
    _pollTimer?.cancel();
    final pref = await SpUtil.getInstance();
    await pref.remove(SpUtil.pendingOrderId);
    await pref.remove(SpUtil.pendingCorrelationId);
    if (!mounted) return;

    final message = status == 'refunded'
        ? 'Your payment could not be confirmed in time and has been automatically refunded within 5-7 business days.'
        : 'This booking session expired before payment could be confirmed.';

    Get.offAllNamed('/dashboard');
    if (Get.context != null) {
      CustomSnackBar.show(Get.context!, message: message);
    }
  }

  void _giveUp(String? message) {
    _pollTimer?.cancel();
    if (!mounted) return;
    setState(() => _timedOut = true);
    if (message != null && Get.context != null) {
      CustomSnackBar.show(Get.context!, message: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Block back navigation while actively confirming — there is nowhere
      // sensible to go back TO (Payment is already gone) until this
      // resolves or times out.
      canPop: _timedOut,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FF),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _timedOut ? _buildTimedOut() : _buildPolling(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPolling() {
    return [
      const CircularProgressIndicator(color: Color(0xFF3B5BDB)),
      SizedBox(height: 3.h),
      Text(
        'Confirming your booking...',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s16,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
      SizedBox(height: 1.h),
      Text(
        "This can take a few moments — please don't close the app.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s10,
          color: const Color(0xFF64748B),
        ),
      ),
    ];
  }

  List<Widget> _buildTimedOut() {
    return [
      Icon(Icons.hourglass_bottom_rounded, size: 12.w, color: const Color(0xFF64748B)),
      SizedBox(height: 2.h),
      Text(
        'Still confirming your booking',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s16,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
      SizedBox(height: 1.h),
      Text(
        'This is taking longer than usual. If your payment went through, it will '
        'appear in My Bookings shortly — you will not be charged twice.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s10,
          color: const Color(0xFF64748B),
        ),
      ),
      SizedBox(height: 3.h),
      ElevatedButton(
        onPressed: () => Get.offAllNamed('/my-bookings'),
        child: const Text('Check My Bookings'),
      ),
      SizedBox(height: 1.h),
      TextButton(
        onPressed: () => Get.offAllNamed('/dashboard'),
        child: const Text('Back to Home'),
      ),
    ];
  }
}
