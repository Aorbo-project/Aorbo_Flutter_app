import 'package:arobo_app/freezed_models/booking/cancellation_data_model.dart';
import 'package:arobo_app/models/treaks/booking_cancelled_modal.dart';
import 'package:arobo_app/screens/booking_cancellation_success_screen.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import '../controller/dashboard_controller.dart';
import '../controller/trek_controller.dart';
import '../freezed_models/booking/booking_history_model.dart';
import '../utils/common_colors.dart';
import '../utils/common_booked_card.dart';
import '../utils/custom_snackbar.dart';
import '../utils/ist_date_utils.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS — matches TravellerInformationScreen
// ─────────────────────────────────────────────
class _TI {
  static const bg = CommonColors.offWhiteColor;
  static const cardBg = CommonColors.whiteColor;
  static const ink = CommonColors.blackColor;
  static const inkMid = CommonColors.cFF6B7280;
  static const inkLight = CommonColors.grey_AEAEAE;
  static const brand = AppColors.forest;
  static const teal = CommonColors.cFF0F7B6C;
  static const tealSoft = CommonColors.cFFE6F5F3;
  static const red = CommonColors.cFFDC2626;
  static const redSoft = CommonColors.cFFFFE4E4;
  static const iconBadge = CommonColors.cFF111827;
  static const divider = CommonColors.trekroutecolorlight;
  static const orange = Color(0xFFFF9800);
  static const holdFillGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF991B1B), AppColors.danger],
  );
}

class BookingsCancelScreen extends StatefulWidget {
  const BookingsCancelScreen({super.key});
  @override
  State<BookingsCancelScreen> createState() => _BookingsCancelScreenState();
}

class _BookingsCancelScreenState extends State<BookingsCancelScreen>
    with TickerProviderStateMixin {
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final TrekController _trekC = Get.find<TrekController>();
  late final AnimationController _entranceController;
  late final AnimationController _refundCountController;
  late final AnimationController _headerSlideController;
  // ── Hold-to-cancel ──
  static const int _holdSeconds = 5;
  late final AnimationController _holdController;
  bool _holdFired = false;
  int _lastTickSecond = -1;
  BookingHistoryData? _pendingBooking;
  CancellationDataModel? _pendingData;
  bool _isCancelling = false;
  bool _hasAnimatedRefund = false;
  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _refundCountController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _headerSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _holdController =
        AnimationController(
            vsync: this,
            duration: const Duration(seconds: _holdSeconds),
            reverseDuration: const Duration(milliseconds: 350),
          )
          ..addListener(_onHoldTick)
          ..addStatusListener(_onHoldStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _headerSlideController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        _entranceController.forward();
        _refundCountController.forward();
      });
    });
  }

  void _onHoldTick() {
    if (_holdController.status != AnimationStatus.forward) return;
    final sec = (_holdController.value * _holdSeconds).floor();
    if (sec != _lastTickSecond) {
      _lastTickSecond = sec;
      HapticFeedback.selectionClick();
    }
    // setState removed — the button already repaints via AnimatedBuilder.
  }

  void _onHoldStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_holdFired) {
      _holdFired = true;
      HapticFeedback.heavyImpact();
      final booking = _pendingBooking;
      if (booking != null) {
        _cancelBookingDirect(booking, _pendingData);
      } else {
        _resetHold();
      }
    }
    if (status == AnimationStatus.dismissed) {
      _lastTickSecond = -1;
    }
  }

  void _resetHold() {
    _holdFired = false;
    _lastTickSecond = -1;
    if (mounted) _holdController.value = 0;
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _refundCountController.dispose();
    _headerSlideController.dispose();
    _holdController.dispose();
    super.dispose();
  }

  Widget _staggered(int index, Widget child, {double slideDistance = 24}) {
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
    final dynamic arguments = Get.arguments;
    BookingHistoryData? booking;
    if (arguments is BookingHistoryData) {
      booking = arguments;
    } else if (arguments is Map<String, dynamic>) {
      booking = arguments['booking'] as BookingHistoryData?;
    }
    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No booking data found')),
      );
    }
    // No nested Sizer here — main.dart already wraps the whole app in one at
    // the root, so a second instance was redundant.
    return Scaffold(
      backgroundColor: _TI.bg,
      appBar: _buildAppBar(),
      body: Obx(() {
        final isLoading = _trekC.cancellationDetailsResponseObserver.value
            .maybeWhen(loading: (_) => true, orElse: () => false);
        final CancellationDataModel? cancellationDataModel = _trekC
            .cancellationDetailsResponseObserver
            .value
            .maybeWhen(
              success: (r) => (r as CancellationDetailsResponseModel).data,
              orElse: () => null,
            );
        if (isLoading) return _buildShimmerLoading();
        if (!_hasAnimatedRefund && cancellationDataModel != null) {
          _hasAnimatedRefund = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (!_entranceController.isAnimating) {
              _entranceController.forward(from: 0);
            }
            _refundCountController.forward(from: 0);
          });
        }
        return _buildBody(cancellationDataModel, booking!);
      }),
      bottomNavigationBar: _buildBottomBar(booking),
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
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: _TI.ink),
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _TI.divider),
      ),
      title: AnimatedBuilder(
        animation: _headerSlideController,
        builder: (_, child) {
          final t = Curves.easeOutCubic.transform(_headerSlideController.value);
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * 12),
              child: child,
            ),
          );
        },
        child: Text(
          'Cancel Booking',
          style: AppType.style(13.sp, w: FontWeight.w700, color: _TI.ink),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  MAIN BODY
  // ─────────────────────────────────────────────
  Widget _buildBody(
    CancellationDataModel? cancellationDataModel,
    BookingHistoryData booking,
  ) {
    int i = 0;
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Shared booking card (same card as My Bookings) ──
          _staggered(i++, CommonBookedCard(booking: booking)),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _staggered(
                  i++,
                  _buildDepartureCard(booking, cancellationDataModel),
                ),
                SizedBox(height: 2.h),
                _staggered(
                  i++,
                  _unifiedRefundCard(cancellationDataModel, booking),
                ),
                SizedBox(height: 2.h),
                _staggered(i++, _reasonCard(cancellationDataModel)),
              ],
            ),
          ),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  DEPARTURE & DEDUCTION CARD
  // ─────────────────────────────────────────────
  Widget _buildDepartureCard(
    BookingHistoryData booking,
    CancellationDataModel? data,
  ) {
    final tbrId = data?.batchDetails?.tbrId ?? booking.batch?.tbrId ?? '-';
    final hours = data?.timeRemainingHours?.floor() ?? 0;
    final days = hours ~/ 24;
    final remainingHours = hours % 24;
    // Robust date parsing: boarding datetime first, batch start date fallback.
    DateTime? departureDate = data?.boardingDateTime;
    final bool isTimeAvailable = departureDate != null;
    if (departureDate == null) {
      final String? dateStr =
          data?.batchDetails?.startDate ?? booking.batch?.startDate;
      if (dateStr != null) departureDate = DateTime.tryParse(dateStr);
    }
    String formattedDeparture = 'N/A';
    if (departureDate != null) {
      formattedDeparture = ISTDateUtils.formatCustom(
        departureDate,
        isTimeAvailable ? 'EEE, dd MMM yyyy • hh:mm a' : 'EEE, dd MMM yyyy',
      );
    }
    Color urgencyColor = _TI.teal;
    if (hours < 72 && hours >= 24) {
      urgencyColor = _TI.orange;
    } else if (hours < 24) {
      urgencyColor = _TI.red;
    }
    final double progress = (hours / 72).clamp(0.0, 1.0);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _TI.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _TI.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Departure Details', Icons.schedule_rounded),
          SizedBox(height: 1.5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
            decoration: BoxDecoration(
              color: _TI.bg,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(color: _TI.divider, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.event_rounded, size: 4.w, color: _TI.brand),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your trek departs on',
                        style: AppType.style(8.sp, color: _TI.inkMid),
                      ),
                      Text(
                        formattedDeparture,
                        style: AppType.style(10.sp, w: FontWeight.w700, color: _TI.ink),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 4.h, color: _TI.divider),
                SizedBox(width: 3.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TBR ID',
                      style: AppType.style(8.sp, w: FontWeight.w600, color: _TI.inkMid),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      tbrId,
                      style: AppType.style(10.sp, w: FontWeight.w700, color: _TI.ink),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Time remaining to departure',
                style: AppType.style(9.sp, w: FontWeight.w500, color: _TI.inkMid),
              ),
              Text(
                '$days Days $remainingHours Hrs',
                style: AppType.style(10.sp, w: FontWeight.w800, color: urgencyColor),
              ),
            ],
          ),
          SizedBox(height: 0.8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 0.8.h,
              backgroundColor: _TI.divider,
              valueColor: AlwaysStoppedAnimation<Color>(urgencyColor),
            ),
          ),
          if (data?.refundCalculation?.slabInfo != null) ...[
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
              decoration: BoxDecoration(
                color: urgencyColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(color: urgencyColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.gavel_outlined, size: 3.8.w, color: urgencyColor),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      data!.refundCalculation!.slabInfo!,
                      style: AppType.style(9.sp, w: FontWeight.w600, color: urgencyColor, height: 1.4),
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
  //  UNIFIED REFUND RECEIPT CARD
  // ─────────────────────────────────────────────
  Widget _unifiedRefundCard(
    CancellationDataModel? data,
    BookingHistoryData booking,
  ) {
    // "Total Amount Paid" must be what the customer actually paid so far —
    // breakdown.totalPaid is the real amount collected.
    final double paid =
        data?.refundCalculation?.breakdown?.totalPaid ??
        data?.finalAmount ??
        double.tryParse(booking.finalAmount?.toString() ?? '0') ??
        0;
    final double refund = data?.refundCalculation?.refund ?? 0;
    final loseItems = data?.refundCalculation?.loseItems ?? [];
    final refundItems = data?.refundCalculation?.refundItems ?? [];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _TI.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _TI.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Refund Summary',
            Icons.account_balance_wallet_outlined,
          ),
          SizedBox(height: 2.h),
          _summaryRow(
            label: 'Total Amount Paid',
            amount: paid,
            color: _TI.ink,
            isBold: false,
          ),
          SizedBox(height: 1.5.h),
          const DottedLine(
            dashColor: _TI.divider,
            dashGapLength: 4,
            dashLength: 4,
          ),
          SizedBox(height: 1.5.h),
          if (loseItems.isNotEmpty) ...[
            Text(
              'CANCELLATION CHARGES',
              style: AppType.style(8.sp, w: FontWeight.w700, color: _TI.red, letterSpacing: 1),
            ),
            SizedBox(height: 1.h),
            ...loseItems.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 0.8.h),
                child: _summaryRow(
                  label: item.item ?? 'Charge',
                  amount: -(item.amount ?? 0),
                  color: _TI.red,
                  isBold: false,
                ),
              ),
            ),
            SizedBox(height: 1.5.h),
            const DottedLine(
              dashColor: _TI.divider,
              dashGapLength: 4,
              dashLength: 4,
            ),
            SizedBox(height: 1.5.h),
          ],
          if (refundItems.isNotEmpty) ...[
            Text(
              'YOU WILL RECEIVE',
              style: AppType.style(8.sp, w: FontWeight.w700, color: _TI.teal, letterSpacing: 1),
            ),
            SizedBox(height: 1.h),
            ...refundItems.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 0.8.h),
                child: _summaryRow(
                  label: item.item ?? 'Refund',
                  amount: item.amount ?? 0,
                  color: _TI.teal,
                  isBold: false,
                ),
              ),
            ),
            SizedBox(height: 1.5.h),
            const DottedLine(
              dashColor: _TI.divider,
              dashGapLength: 4,
              dashLength: 4,
            ),
            SizedBox(height: 1.5.h),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Refund Amount',
                style: AppType.style(12.sp, w: FontWeight.w700, color: _TI.ink),
              ),
              _animatedRupee(
                refund,
                fontSize: 16.sp,
                color: _TI.teal,
                fontWeight: FontWeight.w800,
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
            decoration: BoxDecoration(
              color: _TI.bg,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(color: _TI.divider, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 3.5.w, color: _TI.brand),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Refund will be processed to your original payment method within 5-7 business days.',
                    style: AppType.style(9.sp, color: _TI.inkMid, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required String label,
    required double amount,
    required Color color,
    required bool isBold,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppType.style(10.sp, w: isBold ? FontWeight.w700 : FontWeight.w500, color: isBold ? _TI.ink : _TI.inkMid),
          ),
        ),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: amount.abs()),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (_, val, __) {
            final display = amount < 0
                ? "- ₹ ${val.toStringAsFixed(2)}"
                : "₹ ${val.toStringAsFixed(2)}";
            return Text(
              display,
              style: AppType.style(10.sp, w: isBold ? FontWeight.w800 : FontWeight.w600, color: color),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  REASON CARD
  // ─────────────────────────────────────────────
  Widget _reasonCard(CancellationDataModel? cancellationDataModel) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _TI.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _TI.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Reason for Cancellation', Icons.edit_note_rounded),
          SizedBox(height: 2.h),
          Container(
            decoration: BoxDecoration(
              color: _TI.bg,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(color: _TI.divider, width: 1),
            ),
            child: TextFormField(
              controller: _trekC.cancellationReasonController.value,
              maxLines: 4,
              minLines: 3,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'Please enter your reason for cancellation...',
                hintStyle: AppType.style(10.sp, color: _TI.inkLight, height: 1.5),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(3.w),
              ),
              style: AppType.style(10.sp, color: _TI.ink, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BOTTOM BAR — HOLD TO CANCEL
  // ─────────────────────────────────────────────
  Widget _buildBottomBar(BookingHistoryData booking) {
    return SafeArea(
      top: false,
      child: Obx(() {
        final isLoading = _trekC.cancellationDetailsResponseObserver.value
            .maybeWhen(loading: (_) => true, orElse: () => false);
        final CancellationDataModel? cancellationDataModel = _trekC
            .cancellationDetailsResponseObserver
            .value
            .maybeWhen(
              success: (r) => (r as CancellationDetailsResponseModel).data,
              orElse: () => null,
            );
        return Container(
          padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 1.5.h),
          decoration: BoxDecoration(
            color: _TI.cardBg,
            border: Border(top: BorderSide(color: _TI.divider, width: 1)),
          ),
          child: isLoading
              ? SizedBox(
                  height: 5.5.h,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: _TI.brand,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 3.w,
                          color: _TI.inkLight,
                        ),
                        SizedBox(width: 1.5.w),
                        Text(
                          'Hold for $_holdSeconds seconds — this action cannot be undone',
                          style: AppType.style(8.sp, w: FontWeight.w500, color: _TI.inkLight),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    _buildHoldToCancelButton(booking, cancellationDataModel),
                  ],
                ),
        );
      }),
    );
  }

  Widget _buildHoldToCancelButton(
    BookingHistoryData booking,
    CancellationDataModel? cancellationDataModel,
  ) {
    // Capture the latest data for the hold-completion callback.
    _pendingBooking = booking;
    _pendingData = cancellationDataModel;
    final isRequesting = _trekC.requestCancellationResponseObserver.value
        .maybeWhen(loading: (_) => true, orElse: () => false);
    final bool isBookingCancelled =
        booking.status == 'cancelled' || booking.trekStatus == 'cancelled';
    final bool canCancel = cancellationDataModel?.canCancel ?? true;
    final bool showSpinner = isRequesting || _isCancelling;
    final bool disabled =
        showSpinner || isBookingCancelled || !canCancel || _holdFired;
    return Listener(
      onPointerDown: (_) {
        if (disabled) return;
        HapticFeedback.mediumImpact();
        _holdController.forward();
      },
      onPointerUp: (_) {
        if (!_holdFired) _holdController.reverse();
      },
      onPointerCancel: (_) {
        if (!_holdFired) _holdController.reverse();
      },
      child: AnimatedBuilder(
        animation: _holdController,
        builder: (_, __) {
          final double p = _holdController.value;
          final bool holding = p > 0 && !showSpinner && !disabled;
          final int secondsLeft = (_holdSeconds - p * _holdSeconds)
              .ceil()
              .clamp(1, _holdSeconds);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 6.h,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: (isBookingCancelled || !canCancel)
                  ? _TI.inkLight
                  : _TI.iconBadge,
              borderRadius: BorderRadius.circular(3.w),
              boxShadow: holding
                  ? [
                      BoxShadow(
                        color: _TI.red.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: _TI.ink.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Progress fill sweeping left → right.
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: p.clamp(0.0, 1.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: _TI.holdFillGradient,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: showSpinner
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 6.w,
                              height: 6.w,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: p,
                                    strokeWidth: 2,
                                    color: Colors.white,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.25,
                                    ),
                                  ),
                                  Icon(
                                    holding
                                        ? Icons.hourglass_top_rounded
                                        : Icons.cancel_outlined,
                                    color: Colors.white,
                                    size: 3.5.w,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 2.5.w),
                            Text(
                              isBookingCancelled
                                  ? 'Already Cancelled'
                                  : !canCancel
                                  ? 'Cannot Cancel'
                                  : holding
                                  ? 'Keep Holding · ${secondsLeft}s'
                                  : 'Hold to Cancel Booking',
                              style: AppType.style(12.sp, w: FontWeight.w700, color: Colors.white, letterSpacing: 0.3),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  CANCEL LOGIC
  // ─────────────────────────────────────────────
  Future<void> _cancelBookingDirect(
    BookingHistoryData booking,
    CancellationDataModel? cancellationDataModel,
  ) async {
    if (_isCancelling) return;
    setState(() => _isCancelling = true);
    bool isSuccess = false;
    final String? bookingId = booking.id?.toString();
    if (bookingId == null) {
      _resetHold();
      setState(() => _isCancelling = false);
      return;
    }
    try {
      final String? message = await _trekC.reqCancellation(bookingId);
      if (!mounted) return;
      if (message != null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) CustomSnackBar.show(context, message: message);
        });
        _resetHold();
        setState(() => _isCancelling = false);
        return;
      }
      isSuccess = true;
      await _dashboardC.getBookingDetail(bookingId: bookingId);
      await _dashboardC.getBookingHistory(refresh: true);
      final updatedBooking = _dashboardC.bookingHistoryModal.value;
      final displayBooking =
          (updatedBooking != null && updatedBooking.batch != null)
          ? updatedBooking
          : booking;
      final refundFromServer = _trekC.cancelNextActionParams['refund_amount'];
      final refundStr = refundFromServer != null
          ? double.tryParse(refundFromServer.toString())?.toStringAsFixed(2) ??
                '0'
          : cancellationDataModel?.refundCalculation?.refund?.toStringAsFixed(
                  2,
                ) ??
                '0';
      BookingCancelledData? cancelledData;
      _trekC.requestCancellationResponseObserver.value.maybeWhen(
        success: (modal) => cancelledData = modal?.data,
        orElse: () => {},
      );
      Get.off(
        () => BookingCancellationSuccessScreen(
          refund: refundStr,
          booking: displayBooking,
          cancelledData: cancelledData,
        ),
      );
    } catch (_) {
      if (mounted) {
        _resetHold();
        setState(() => _isCancelling = false);
      }
    } finally {
      if (!isSuccess && mounted) {
        _resetHold();
        setState(() => _isCancelling = false);
      }
    }
  }

  // ─────────────────────────────────────────────
  //  SHARED PRIMITIVES
  // ─────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9.w,
          height: 9.w,
          decoration: BoxDecoration(
            color: _TI.iconBadge,
            borderRadius: BorderRadius.circular(2.5.w),
          ),
          child: Center(
            child: Icon(icon, color: Colors.white, size: 4.5.w),
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

  Widget _animatedRupee(
    double value, {
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return AnimatedBuilder(
      animation: _refundCountController,
      builder: (_, __) {
        final t = Curves.easeOutCubic.transform(_refundCountController.value);
        return Text(
          "₹ ${(value * t).toStringAsFixed(2)}",
          style: AppType.style(fontSize, w: fontWeight, color: color),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  SHIMMER
  // ─────────────────────────────────────────────
  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          _shimmerBox(height: 22.h, radius: 4.w),
          SizedBox(height: 1.5.h),
          _shimmerBox(height: 20.h, radius: 4.w),
          SizedBox(height: 1.5.h),
          _shimmerBox(height: 32.h, radius: 4.w),
          SizedBox(height: 1.5.h),
          _shimmerBox(height: 18.h, radius: 4.w),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _shimmerBox({required double height, required double radius}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: _TI.cardBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _TI.divider, width: 1),
      ),
    ).withShimmerAi(loading: true);
  }
}
