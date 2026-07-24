import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import '../controller/dashboard_controller.dart';
import '../controller/trek_controller.dart';
import '../freezed_models/booking/booking_history_model.dart';
import '../models/refund/refund_status_model.dart';
import '../models/treaks/booking_cancelled_modal.dart';
import '../utils/common_colors.dart';
import '../utils/common_booked_details_card.dart';
import '../utils/ist_date_utils.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS — matches TravellerInformationScreen
// ─────────────────────────────────────────────
class _TI {
  static const bg = CommonColors.offWhiteColor;
  static const cardBg = CommonColors.whiteColor;
  static const ink = CommonColors.blackColor;
  static const inkMid = CommonColors.cFF6B7280;
  static const inkLight = CommonColors.grey_AEAEAE;
  static const brand = Color(0xFF2D6A4F);
  static const teal = CommonColors.cFF0F7B6C;
  static const tealSoft = CommonColors.cFFE6F5F3;
  static const red = CommonColors.cFFDC2626;
  static const redSoft = CommonColors.cFFFFE4E4;
  static const iconBadge = CommonColors.cFF111827;
  static const divider = CommonColors.trekroutecolorlight;
  static const orange = Color(0xFFFF9800);
  static const orangeSoft = Color(0xFFFFF3E0);
  static const ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
  );

  // Sheet tokens
  static const sheetBg = Colors.white;
  static const sheetSurface = Colors.white;
  static const sheetBorder = Color(0xFFE2E8F0);
  static const sheetInk = Color(0xFF0F172A);
  static const sheetInkMid = Color(0xFF64748B);
  static const sheetHandle = Color(0xFFD1D5DB);
  static const sheetAccent = Color(0xFF111827);
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

  // Animations
  late final AnimationController _checkController;
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _simulateLoading();

    // Start polling if a cash refund was issued
    if (_hasRefund && widget.cancelledData?.bookingId != null) {
      _trekC.startRefundPolling(widget.cancelledData!.bookingId!.toString());
    }
  }

  void _simulateLoading() {
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _checkController.forward();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _entranceController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _trekC.stopRefundPolling();
    _checkController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Widget _staggered(int index, Widget child, {double slideDistance = 28}) {
    final start = (index * 0.08).clamp(0.0, 0.65);
    final end = (start + 0.40).clamp(0.0, 1.0);
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
    // No nested Sizer here — main.dart already wraps the whole app in one at
    // the root, so a second instance here was redundant and this screen is
    // the only one of its siblings that carried it this way.
    return Scaffold(
      backgroundColor: _TI.bg,
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildShimmerLoading()
          : SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSuccessHero(),
                  SizedBox(height: 1.5.h),

                  _staggered(0, _buildCancellationStatusCard()),
                  SizedBox(height: 1.5.h),

                  _staggered(1, _buildBookingDetailsCard()),
                  SizedBox(height: 1.5.h),

                  _staggered(2, _buildNextStepsCard()),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ─────────────────────────────────────────────
  //  APP BAR
  // ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _TI.cardBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      iconTheme: const IconThemeData(color: _TI.ink),
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _TI.divider),
      ),
      title: Text(
        'Cancellation Status',
        textScaler: const TextScaler.linear(1.0),
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: _TI.ink,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HERO SUCCESS ANIMATION
  // ─────────────────────────────────────────────
  Widget _buildSuccessHero() {
    return Column(
      children: [
        ScaleTransition(
          scale: CurvedAnimation(
            parent: _checkController,
            curve: Curves.elasticOut,
          ),
          child: Container(
            width: 13.w,
            height: 13.w,
            decoration: BoxDecoration(
              color: _TI.teal,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _TI.teal.withValues(alpha: 0.25),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(Icons.check_rounded, color: Colors.white, size: 7.w),
          ),
        ),
        SizedBox(height: 1.5.h),
        Text(
          'Booking Cancelled',
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: _TI.ink,
          ),
        ),
        SizedBox(height: 0.4.h),
        Text(
          'Your cancellation request has been processed successfully.',
          textAlign: TextAlign.center,
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10.sp,
            color: _TI.inkMid,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  CANCELLATION STATUS & REFUND CARD
  // ─────────────────────────────────────────────
  Widget _buildCancellationStatusCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: _TI.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _TI.divider, width: 1),
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

          // Context-aware message
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: _TI.bg,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(color: _TI.divider, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 4.w, color: _TI.brand),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    _creditNoteEligible
                        ? 'Your advance amount is non-refundable. A credit note will be issued for GST reversal.'
                        : _isAdvanceOnly
                        ? 'Your advance amount, including GST, is non-refundable.'
                        : _hasRefund
                        ? 'Your refund will be processed to your original payment method.'
                        : 'No refund is applicable for this cancellation.',
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9.sp,
                      color: _TI.inkMid,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_hasRefund) ...[
            SizedBox(height: 1.5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Refund Amount',
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9.sp,
                        color: _TI.inkMid,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '₹ ${widget.refund}',
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: _TI.teal,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showRefundStatusSheet(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
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
                        Icon(Icons.track_changes, size: 3.5.w, color: _TI.teal),
                        SizedBox(width: 1.5.w),
                        Text(
                          'Track Refund',
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
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

          // Credit note notice
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
                    size: 4.w,
                    color: _TI.orange,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'A credit note for GST reversal will be shared to your registered email.',
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 8.sp,
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
  //  BOOKING DETAILS RECAP
  // ─────────────────────────────────────────────
  Widget _buildBookingDetailsCard() {
    if (widget.booking == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: _TI.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _TI.divider, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.w),
        child: UpcomingBookingCard(booking: widget.booking!),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  WHAT HAPPENS NEXT TIMELINE
  // ─────────────────────────────────────────────
  Widget _buildNextStepsCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: _TI.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _TI.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('What Happens Next?', Icons.timeline_outlined),
          SizedBox(height: 1.5.h),
          _buildTimelineItem(
            'Cancellation Confirmed',
            'Your booking is officially cancelled and slots are released.',
            true,
            Icons.check_circle,
          ),
          _buildTimelineLine(),
          _buildTimelineItem(
            'Refund Initiated',
            _hasRefund
                ? 'We have initiated the refund process from our end.'
                : 'No refund applicable for this booking.',
            _hasRefund,
            _hasRefund ? Icons.currency_rupee : Icons.cancel,
          ),
          if (_hasRefund) _buildTimelineLine(),
          if (_hasRefund)
            _buildTimelineItem(
              'Credited to Bank',
              'Amount will reflect in your original payment method in 5-7 business days.',
              false,
              Icons.account_balance,
            ),
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
          width: 6.5.w,
          height: 6.5.w,
          decoration: BoxDecoration(
            color: done ? _TI.teal : _TI.bg,
            shape: BoxShape.circle,
            border: Border.all(
              color: done ? _TI.teal : _TI.divider,
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: done ? Colors.white : _TI.inkLight,
            size: 3.3.w,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: _TI.ink,
                ),
              ),
              SizedBox(height: 0.3.h),
              Text(
                subtitle,
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9.sp,
                  color: _TI.inkMid,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine() {
    return Padding(
      padding: EdgeInsets.only(left: 3.15.w),
      child: Container(height: 2.h, width: 1.5, color: _TI.divider),
    );
  }

  // ─────────────────────────────────────────────
  //  BOTTOM BAR
  // ─────────────────────────────────────────────
  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 1.5.h),
        decoration: BoxDecoration(
          color: _TI.cardBg,
          border: Border(top: BorderSide(color: _TI.divider, width: 1)),
        ),
        child: GestureDetector(
          onTap: () {
            Get.offAllNamed('/dashboard');
            dashboardC.selectedScreen.value = 1;
          },
          child: Container(
            height: 5.5.h,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: _TI.ctaGradient,
              borderRadius: BorderRadius.circular(3.w),
              boxShadow: [
                BoxShadow(
                  color: _TI.brand.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Back to My Bookings',
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
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
              if (isPolling || statusData == null)
                const Center(child: CircularProgressIndicator(color: _TI.brand))
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
                    color: _TI.bg,
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(color: _TI.sheetBorder),
                  ),
                  child: Text(
                    statusData?.statusMessage ?? 'Checking refund status...',
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9.sp,
                      color: _TI.inkMid,
                    ),
                  ),
                ),
                if (statusData?.refundSpeed != null) ...[
                  SizedBox(height: 1.h),
                  Text(
                    'Speed: ${statusData?.refundSpeed == 'instant' ? 'Instant (within minutes)' : 'Normal (3–5 business days)'}',
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8.sp,
                      color: _TI.inkLight,
                    ),
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
              width: 7.w,
              height: 7.w,
              decoration: BoxDecoration(
                color: _TI.iconBadge,
                borderRadius: BorderRadius.circular(2.5.w),
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 3.5.w),
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              title,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: _TI.ink,
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
              color: _TI.bg,
              shape: BoxShape.circle,
              border: Border.all(color: _TI.sheetBorder),
            ),
            child: Icon(Icons.close, size: 4.w, color: _TI.inkMid),
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
    final color = isFailed
        ? _TI.red
        : done
        ? _TI.teal
        : _TI.inkLight;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        children: [
          Icon(icon, size: 5.w, color: color),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              label,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10.sp,
                color: color,
                fontWeight: done ? FontWeight.w600 : FontWeight.w400,
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
          width: 7.w,
          height: 7.w,
          decoration: BoxDecoration(
            color: _TI.iconBadge,
            borderRadius: BorderRadius.circular(2.5.w),
          ),
          child: Center(
            child: Icon(icon, color: Colors.white, size: 3.5.w),
          ),
        ),
        SizedBox(width: 3.w),
        Flexible(
          child: Text(
            title,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: _TI.ink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10.sp,
            color: _TI.inkMid,
          ),
        ),
        Text(
          value,
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: _TI.ink,
          ),
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
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
  }

  // ─────────────────────────────────────────────
  //  SHIMMER LOADING
  // ─────────────────────────────────────────────
  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          SizedBox(height: 3.h),
          // Hero shimmer
          Center(
            child: Column(
              children: [
                Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: const BoxDecoration(
                    color: CommonColors.greyColorEBEBEB,
                    shape: BoxShape.circle,
                  ),
                ).withShimmerAi(loading: true),
                SizedBox(height: 2.h),
                Container(
                  height: 2.h,
                  width: 40.w,
                  decoration: BoxDecoration(
                    color: CommonColors.greyColorEBEBEB,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).withShimmerAi(loading: true),
                SizedBox(height: 1.h),
                Container(
                  height: 1.5.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: CommonColors.greyColorEBEBEB,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).withShimmerAi(loading: true),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          // Card 1
          _shimmerCard(),
          SizedBox(height: 2.h),
          // Card 2
          _shimmerCard(),
          SizedBox(height: 2.h),
          // Card 3
          _shimmerCard(),
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
