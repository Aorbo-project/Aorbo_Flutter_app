import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import '../controller/dashboard_controller.dart';
import '../controller/trek_controller.dart';
import '../freezed_models/booking/booking_history_model.dart';
import '../models/refund/refund_status_model.dart';
import '../models/treaks/booking_cancelled_modal.dart';
import '../utils/common_colors.dart';
import '../utils/common_booked_card.dart';
import '../utils/ist_date_utils.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS — matches app-wide standards
// ─────────────────────────────────────────────
class _TI {
  static const bg = AppColors.bg;
  static const cardBg = AppColors.surface;
  static const ink = AppColors.ink;
  static const inkMid = AppColors.inkMid;
  static const inkLight = AppColors.inkLight;
  static const brand = AppColors.forest;
  static const brandDeep = AppColors.forestDeep;
  static const teal = AppColors.teal;
  static const tealSoft = AppColors.tealSoft;
  static const red = AppColors.danger;
  static const redSoft = AppColors.dangerSoft;
  static const orange = AppColors.warning;
  static const orangeSoft = AppColors.warningSoft;
  static const iconBadge = AppColors.iconBadge;
  static const divider = AppColors.divider;
  static const elevated = AppColors.elevated;

  static const ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandDeep, brand],
  );

  static const sheetBg = Colors.white;
  static const sheetBorder = AppColors.divider;
  static const sheetHandle = Color(0xFFD1D5DB);
  static const sheetInk = AppColors.inkStrong;
  static const sheetInkMid = Color(0xFF64748B);
}

class BookingCancellationSuccessScreen extends StatefulWidget {
  final BookingHistoryData? booking;
  final String refund;
  final BookingCancelledData? cancelledData;

  const BookingCancellationSuccessScreen({
    super.key,
    required this.booking,
    required this.refund,
    this.cancelledData,
  });

  @override
  State<BookingCancellationSuccessScreen> createState() =>
      _BookingCancellationSuccessScreenState();
}

class _BookingCancellationSuccessScreenState
    extends State<BookingCancellationSuccessScreen>
    with TickerProviderStateMixin {
  final DashboardController dashboardC = Get.find<DashboardController>();
  final TrekController _trekC = Get.find<TrekController>();

  bool _isLoading = true;
  bool get _hasRefund => (widget.cancelledData?.totalRefundableAmount ?? 0) > 0;
  bool get _isAdvanceOnly => widget.cancelledData?.isAdvanceOnly == true;
  bool get _creditNoteEligible =>
      widget.cancelledData?.creditNoteEligible == true;

  late final AnimationController _entranceController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _simulateLoading();

    if (_hasRefund && widget.cancelledData?.bookingId != null) {
      _trekC.startRefundPolling(widget.cancelledData!.bookingId!.toString());
    }
  }

  void _simulateLoading() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      HapticFeedback.lightImpact();
      _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _trekC.stopRefundPolling();
    _entranceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _staggered(int index, Widget child, {double slideDistance = 24}) {
    final start = (index * 0.1).clamp(0.0, 0.5);
    final end = (start + 0.3).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curve,
      builder: (_, __) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(0, (1 - curve.value) * slideDistance),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _TI.bg,
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildShimmerLoading()
          : SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSuccessHero(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _staggered(0, _buildCancellationStatusCard()),
                        SizedBox(height: 1.5.h),
                        _staggered(1, _buildBookingDetailsCard()),
                        SizedBox(height: 1.5.h),
                        _staggered(2, _buildNextStepsCard()),
                        SizedBox(height: 3.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ─────────────────────────────────────────────
  //  APP BAR — Clean, solid, and distinct
  // ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _TI.cardBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: _TI.ink),
      title: Text(
        'Cancellation Status',
        style: AppType.style(16.sp, w: FontWeight.w700, color: _TI.ink),
      ),
      centerTitle: true,
    );
  }

  // ─────────────────────────────────────────────
  //  HERO — Separate, decreased-size, beautifully
  //  animated banner with subtle background details
  // ─────────────────────────────────────────────
  Widget _buildSuccessHero() {
    return Container(
      height: 26.h, // Decreased, elegant size
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _TI.ctaGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(6.w)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle decorative background circles for premium feel
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Animated Checkmark (Elastic pop)
              AnimatedBuilder(
                animation: _entranceController,
                builder: (context, child) {
                  final value = Curves.elasticOut.transform(
                    (_entranceController.value * 2.0).clamp(0.0, 1.0),
                  );
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: _TI.brandDeep,
                    size: 8.w,
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              // 2. Animated Title (Slide up + fade)
              AnimatedBuilder(
                animation: _entranceController,
                builder: (context, child) {
                  final t =
                      (_entranceController.value - 0.2).clamp(0.0, 1.0) / 0.8;
                  final value = Curves.easeOutCubic.transform(t);
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  'Booking Cancelled',
                  style: AppType.style(
                    14.sp,
                    w: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 1.h),

              // 3. Animated Subtitle (Slide up + fade, slightly delayed)
              AnimatedBuilder(
                animation: _entranceController,
                builder: (context, child) {
                  final t =
                      (_entranceController.value - 0.4).clamp(0.0, 1.0) / 0.6;
                  final value = Curves.easeOutCubic.transform(t);
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Text(
                    'Your cancellation request has been processed successfully.',
                    textAlign: TextAlign.center,
                    style: AppType.style(
                      9.sp,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  CANCELLATION STATUS & REFUND CARD
  // ─────────────────────────────────────────────
  Widget _buildCancellationStatusCard() {
    final double refundValue = double.tryParse(widget.refund) ?? 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _TI.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _TI.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Refund Details',
            Icons.account_balance_wallet_outlined,
          ),
          SizedBox(height: 1.5.h),
          if (widget.cancelledData?.cancellationNumber != null) ...[
            _detailRow(
              'Cancellation ID',
              widget.cancelledData!.cancellationNumber!,
            ),
            SizedBox(height: 1.2.h),
          ],
          _detailRow('Cancelled On', _formatDate(DateTime.now())),
          SizedBox(height: 1.5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: _TI.elevated,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(color: _TI.divider, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 4.5.w, color: _TI.brand),
                SizedBox(width: 2.5.w),
                Expanded(
                  child: Text(
                    _creditNoteEligible
                        ? 'Your advance amount is non-refundable. A credit note will be issued for GST reversal.'
                        : _isAdvanceOnly
                        ? 'Your advance amount, including GST, is non-refundable.'
                        : _hasRefund
                        ? 'Your refund will be processed to your original payment method.'
                        : 'No refund is applicable for this cancellation.',
                    style: AppType.style(
                      9.5.sp,
                      color: _TI.inkMid,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_hasRefund) ...[
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Refund Amount',
                      style: AppType.style(
                        9.5.sp,
                        w: FontWeight.w500,
                        color: _TI.inkMid,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: refundValue),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (_, val, __) => Text(
                        '₹ ${val.toStringAsFixed(2)}',
                        style: AppType.style(
                          16.sp,
                          w: FontWeight.w800,
                          color: _TI.teal,
                        ),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showRefundStatusSheet(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.5.w,
                      vertical: 1.2.h,
                    ),
                    decoration: BoxDecoration(
                      color: _TI.tealSoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _TI.teal.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.track_changes, size: 4.w, color: _TI.teal),
                        SizedBox(width: 1.5.w),
                        Text(
                          'Track Refund',
                          style: AppType.style(
                            9.5.sp,
                            w: FontWeight.w700,
                            color: _TI.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (_creditNoteEligible) ...[
            SizedBox(height: 1.5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
              decoration: BoxDecoration(
                color: _TI.orangeSoft,
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(color: _TI.orange.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 4.5.w,
                    color: _TI.orange,
                  ),
                  SizedBox(width: 2.5.w),
                  Expanded(
                    child: Text(
                      'A credit note for GST reversal will be shared to your registered email.',
                      style: AppType.style(
                        9.sp,
                        color: _TI.orange,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BOOKING RECAP
  // ─────────────────────────────────────────────
  Widget _buildBookingDetailsCard() {
    if (widget.booking == null) return const SizedBox.shrink();
    return CommonBookedCard(booking: widget.booking!);
  }

  // ─────────────────────────────────────────────
  //  WHAT HAPPENS NEXT TIMELINE
  // ─────────────────────────────────────────────
  Widget _buildNextStepsCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _TI.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _TI.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('What Happens Next?', Icons.timeline_outlined),
          SizedBox(height: 2.h),
          _buildTimelineItem(
            'Cancellation Confirmed',
            'Your booking is officially cancelled and slots are released.',
            true,
            Icons.check_circle,
          ),
          _buildTimelineLine(isDone: true),
          _buildTimelineItem(
            'Refund Initiated',
            _hasRefund
                ? 'We have initiated the refund process from our end.'
                : 'No refund applicable for this booking.',
            _hasRefund,
            _hasRefund ? Icons.currency_rupee : Icons.cancel,
          ),
          if (_hasRefund) ...[
            _buildTimelineLine(isDone: false),
            _buildTimelineItem(
              'Credited to Bank',
              'Amount will reflect in your original payment method in 5-7 business days.',
              false,
              Icons.account_balance,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    bool done,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7.w,
          height: 7.w,
          decoration: BoxDecoration(
            color: done ? _TI.teal : _TI.elevated,
            shape: BoxShape.circle,
            border: Border.all(
              color: done ? _TI.teal : _TI.divider,
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: done ? Colors.white : _TI.inkLight,
            size: 3.5.w,
          ),
        ),
        SizedBox(width: 3.5.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: 0.5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppType.style(
                    11.sp,
                    w: FontWeight.w700,
                    color: _TI.ink,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  subtitle,
                  style: AppType.style(9.5.sp, color: _TI.inkMid, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine({bool isDone = false}) {
    return Padding(
      padding: EdgeInsets.only(left: 3.35.w),
      child: Container(
        height: 2.5.h,
        width: 1.5,
        color: isDone ? _TI.teal : _TI.divider,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BOTTOM BAR
  // ─────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 2.h),
      decoration: BoxDecoration(
        color: _TI.cardBg,
        border: Border(top: BorderSide(color: _TI.divider, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () {
            dashboardC.selectedScreen.value = 1;
            Get.offAllNamed('/dashboard');
          },
          child: Container(
            height: 6.5.h,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: _TI.ctaGradient,
              borderRadius: BorderRadius.circular(3.w),
              boxShadow: [
                BoxShadow(
                  color: _TI.brand.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Back to My Bookings',
                style: AppType.style(
                  12.sp,
                  w: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  REFUND STATUS BOTTOM SHEET
  // ─────────────────────────────────────────────
  void _showRefundStatusSheet(BuildContext context) {
    FirebaseCrashlytics.instance.log(
      'Popup: Refund status sheet (cancellation success)',
    );
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: _TI.sheetBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
        ),
        padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 4.h),
        child: Obx(() {
          final result = _trekC.refundStatusObserver.value;
          RefundStatusData? statusData;
          result.maybeWhen(success: (m) => statusData = m?.data, orElse: () {});
          final isPolling = result.maybeWhen(
            loading: (_) => true,
            orElse: () => false,
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 10.w,
                  height: 0.5.h,
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                    color: _TI.sheetHandle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              _sheetHeader('Refund Status', Icons.track_changes),
              SizedBox(height: 2.h),
              if (isPolling && statusData == null)
                const Center(child: CircularProgressIndicator(color: _TI.brand))
              else if (statusData == null)
                Text(
                  'Refund status is not available yet. Please check again shortly.',
                  style: AppType.style(10.sp, color: _TI.sheetInkMid),
                )
              else ...[
                _buildStatusStep(
                  'Cancellation Confirmed',
                  true,
                  Icons.check_circle,
                ),
                _buildStatusStep(
                  'Refund Initiated',
                  statusData?.refundStatus != null,
                  Icons.currency_rupee,
                ),
                _buildStatusStep(
                  'Being Processed by Bank',
                  statusData?.refundStatus == 'processing' ||
                      statusData?.refundStatus == 'processed',
                  Icons.account_balance,
                ),
                _buildStatusStep(
                  (statusData?.isProcessed ?? false)
                      ? 'Credited — ${_formatSettledAt(statusData?.refundProcessedAt)}'
                      : (statusData?.isFailed ?? false)
                      ? 'Failed — Contact Support'
                      : 'Awaiting Credit',
                  statusData?.isProcessed ?? false,
                  (statusData?.isFailed ?? false)
                      ? Icons.error_outline
                      : Icons.done_all,
                  isFailed: statusData?.isFailed ?? false,
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: _TI.elevated,
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(color: _TI.sheetBorder),
                  ),
                  child: Text(
                    statusData?.statusMessage ?? 'Checking refund status...',
                    style: AppType.style(9.5.sp, color: _TI.sheetInkMid),
                  ),
                ),
                if (statusData?.refundSpeed != null) ...[
                  SizedBox(height: 1.h),
                  Text(
                    'Speed: ${statusData?.refundSpeed == 'instant' ? 'Instant (within minutes)' : 'Normal (3–5 business days)'}',
                    style: AppType.style(8.5.sp, color: _TI.inkLight),
                  ),
                ],
              ],
              SizedBox(height: 3.h),
            ],
          );
        }),
      ),
    );
  }

  Widget _sheetHeader(String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: _TI.iconBadge,
                borderRadius: BorderRadius.circular(2.5.w),
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 4.w),
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              title,
              style: AppType.style(
                13.sp,
                w: FontWeight.w700,
                color: _TI.sheetInk,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: _TI.elevated,
              shape: BoxShape.circle,
              border: Border.all(color: _TI.sheetBorder),
            ),
            child: Icon(Icons.close, size: 4.w, color: _TI.sheetInkMid),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusStep(
    String label,
    bool done,
    IconData icon, {
    bool isFailed = false,
  }) {
    final color = isFailed ? _TI.red : (done ? _TI.teal : _TI.inkLight);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        children: [
          Icon(icon, size: 5.w, color: color),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Text(
              label,
              style: AppType.style(
                10.sp,
                w: done ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SHARED WIDGETS
  // ─────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: _TI.iconBadge,
            borderRadius: BorderRadius.circular(2.5.w),
          ),
          child: Center(
            child: Icon(icon, color: Colors.white, size: 4.w),
          ),
        ),
        SizedBox(width: 3.w),
        Flexible(
          child: Text(
            title,
            style: AppType.style(13.sp, w: FontWeight.w700, color: _TI.ink),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppType.style(10.sp, color: _TI.inkMid)),
        Text(
          value,
          style: AppType.style(10.sp, w: FontWeight.w600, color: _TI.ink),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  UTILS
  // ─────────────────────────────────────────────
  String _formatSettledAt(String? iso) {
    if (iso == null) return '';
    final ist = ISTDateUtils.toIST(iso);
    if (ist == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[ist.month - 1]} ${ist.day}, ${ist.year}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final int h12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final String period = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, '
        '${date.year}, ${h12.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')} $period';
  }

  // ─────────────────────────────────────────────
  //  SHIMMER LOADING
  // ─────────────────────────────────────────────
  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 26.h,
            color: _TI.brand.withValues(alpha: 0.1),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ).withShimmerAi(loading: true),
                  SizedBox(height: 2.h),
                  Container(
                    height: 2.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).withShimmerAi(loading: true),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              children: [
                _shimmerCard(),
                SizedBox(height: 1.5.h),
                _shimmerCard(),
                SizedBox(height: 1.5.h),
                _shimmerCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _TI.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _TI.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.w,
            height: 2.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(4),
            ),
          ).withShimmerAi(loading: true),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            height: 1.5.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(4),
            ),
          ).withShimmerAi(loading: true),
          SizedBox(height: 1.h),
          Container(
            width: 80.w,
            height: 1.5.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(4),
            ),
          ).withShimmerAi(loading: true),
        ],
      ),
    );
  }
}
