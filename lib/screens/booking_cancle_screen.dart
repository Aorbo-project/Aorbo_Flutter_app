import 'package:arobo_app/freezed_models/booking/cancellation_data_model.dart';
import 'package:arobo_app/models/treaks/booking_cancelled_modal.dart';
import 'package:arobo_app/screens/booking_cancellation_success_screen.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import '../controller/dashboard_controller.dart';
import '../controller/trek_controller.dart';
import '../freezed_models/booking/booking_history_model.dart';
import '../utils/common_colors.dart';
import '../utils/custom_snackbar.dart';
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
  static const brand = CommonColors.trek_route_color;
  static const teal = CommonColors.cFF0F7B6C;
  static const tealSoft = CommonColors.cFFE6F5F3;
  static const red = CommonColors.cFFDC2626;
  static const redSoft = CommonColors.cFFFFE4E4;
  static const iconBadge = CommonColors.cFF111827;
  static const divider = CommonColors.trekroutecolorlight;
  static const orange = Color(0xFFFF9800);
  static const orangeSoft = Color(0xFFFFF3E0);
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
  late final AnimationController _ctaScaleController;
  late final AnimationController _headerSlideController;

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
    _ctaScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _headerSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _headerSlideController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _entranceController.forward();
        _refundCountController.forward();
      });
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _refundCountController.dispose();
    _ctaScaleController.dispose();
    _headerSlideController.dispose();
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

    return Sizer(
      builder: (context, orientation, deviceType) => Scaffold(
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
              if (!_entranceController.isAnimating) {
                _entranceController.forward(from: 0);
              }
              _refundCountController.forward(from: 0);
            });
          }

          return _buildBody(cancellationDataModel, booking!);
        }),
        bottomNavigationBar: _buildBottomBar(booking!),
      ),
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
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: _TI.ink,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BOTTOM BAR
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
                          'This action cannot be undone',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 8.sp,
                            color: _TI.inkLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    _buildCtaButton(booking, cancellationDataModel),
                  ],
                ),
        );
      }),
    );
  }

  Widget _buildCtaButton(
    BookingHistoryData booking,
    CancellationDataModel? cancellationDataModel,
  ) {
    final isRequesting = _trekC.requestCancellationResponseObserver.value
        .maybeWhen(loading: (_) => true, orElse: () => false);

    final bool isBookingCancelled =
        booking.status == 'cancelled' || booking.trekStatus == 'cancelled';
    final bool canCancel = cancellationDataModel?.canCancel ?? true;

    final bool busy =
        isRequesting || _isCancelling || isBookingCancelled || !canCancel;
    final bool showSpinner = isRequesting || _isCancelling;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _ctaScaleController.forward(),
      onTapUp: (_) => _ctaScaleController.reverse(),
      onTapCancel: () => _ctaScaleController.reverse(),
      onTap: busy
          ? null
          : () => _cancelBookingDirect(booking, cancellationDataModel),
      child: AnimatedBuilder(
        animation: _ctaScaleController,
        builder: (_, child) =>
            Transform.scale(scale: 1 - _ctaScaleController.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 5.5.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: busy
                ? LinearGradient(colors: [_TI.inkLight, _TI.inkLight])
                : CommonColors.filterGradient,
            borderRadius: BorderRadius.circular(3.w),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: ScaleTransition(scale: anim, child: child),
            ),
            child: showSpinner
                ? const Center(
                    key: ValueKey('loading'),
                    child: SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : Row(
                    key: const ValueKey('btn'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cancel_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isBookingCancelled
                            ? 'Already Cancelled'
                            : (!canCancel
                                  ? 'Cannot Cancel'
                                  : 'Confirm Cancellation'),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
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
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Merged Trek & Departure Context Card ──
          _staggered(
            i++,
            _buildTrekAndDepartureCard(booking, cancellationDataModel),
          ),
          SizedBox(height: 2.h),

          // ── Unified Refund Receipt ──
          _staggered(i++, _unifiedRefundCard(cancellationDataModel, booking)),
          SizedBox(height: 2.h),

          // ── Reason ──
          _staggered(i++, _reasonCard(cancellationDataModel)),

          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  MERGED TREK & DEPARTURE CONTEXT CARD
  // ─────────────────────────────────────────────
  Widget _buildTrekAndDepartureCard(
    BookingHistoryData booking,
    CancellationDataModel? data,
  ) {
    final trekTitle =
        data?.trekDetails?.title ?? booking.trek?.title ?? 'Trek Details';
    final vendorName = booking.trek?.vendor?.businessName ?? 'Unknown Vendor';
    final tbrId = data?.batchDetails?.tbrId ?? booking.batch?.tbrId ?? '-';

    final hours = data?.timeRemainingHours?.floor() ?? 0;
    final days = hours ~/ 24;
    final remainingHours = hours % 24;

    // ── FIX: Robust Date Parsing Logic ──
    DateTime? departureDate = data?.boardingDateTime;
    bool isTimeAvailable = departureDate != null;

    // Fallback to batch start date if boarding date time is null
    if (departureDate == null) {
      String? dateStr =
          data?.batchDetails?.startDate ?? booking.batch?.startDate;
      if (dateStr != null) {
        departureDate = DateTime.tryParse(dateStr);
      }
    }

    String formattedDeparture = 'N/A';
    if (departureDate != null) {
      if (isTimeAvailable) {
        formattedDeparture = ISTDateUtils.formatCustom(
          departureDate,
          'EEE, dd MMM yyyy • hh:mm a',
        );
      } else {
        formattedDeparture = ISTDateUtils.formatCustom(
          departureDate,
          'EEE, dd MMM yyyy',
        );
      }
    }

    // Determine urgency color
    Color urgencyColor = _TI.teal;
    if (hours < 72 && hours >= 24) {
      urgencyColor = _TI.orange;
    } else if (hours < 24) {
      urgencyColor = _TI.red;
    }

    double progress = (hours / 72).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _TI.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _TI.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: _TI.iconBadge,
                  borderRadius: BorderRadius.circular(2.5.w),
                ),
                child: Icon(
                  Icons.terrain_rounded,
                  color: Colors.white,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trekTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: _TI.ink,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      vendorName,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.sp,
                        color: _TI.inkMid,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // ── Departure & TBR ID Info Box ──
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
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8.sp,
                          color: _TI.inkMid,
                        ),
                      ),
                      Text(
                        formattedDeparture,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.sp,
                          color: _TI.ink,
                          fontWeight: FontWeight.w700,
                        ),
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
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 8.sp,
                        color: _TI.inkMid,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      tbrId,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.sp,
                        color: _TI.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // ── Time Remaining & Progress Bar ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Time remaining to departure',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9.sp,
                  color: _TI.inkMid,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$days Days $remainingHours Hrs',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.sp,
                  color: urgencyColor,
                  fontWeight: FontWeight.w800,
                ),
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

          SizedBox(height: 2.h),

          // ── Slab Info Explanation (Urgency Box) ──
          if (data?.refundCalculation?.slabInfo != null) ...[
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
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9.sp,
                        color: urgencyColor,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
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
  //  CUSTOM TREK SUMMARY CARD
  // ─────────────────────────────────────────────
  Widget _buildTrekSummaryCard(
    BookingHistoryData booking,
    CancellationDataModel? data,
  ) {
    final trekTitle =
        data?.trekDetails?.title ?? booking.trek?.title ?? 'Trek Details';
    final vendorName = booking.trek?.vendor?.businessName ?? 'Unknown Vendor';
    final tbrId = data?.batchDetails?.tbrId ?? booking.batch?.tbrId ?? '-';
    final startDate =
        data?.batchDetails?.startDate ?? booking.batch?.startDate ?? '-';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _TI.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _TI.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: _TI.iconBadge,
                  borderRadius: BorderRadius.circular(2.5.w),
                ),
                child: Icon(
                  Icons.terrain_rounded,
                  color: Colors.white,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trekTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: _TI.ink,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      vendorName,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.sp,
                        color: _TI.inkMid,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
            decoration: BoxDecoration(
              color: _TI.bg,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(color: _TI.divider, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryChip('TBR ID', tbrId),
                Container(width: 1, height: 4.h, color: _TI.divider),
                _summaryChip('Departure', startDate),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 8.sp,
              color: _TI.inkMid,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.2.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.sp,
              color: _TI.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  DEPARTURE & DEDUCTION CONTEXT CARD
  // ─────────────────────────────────────────────
  Widget _buildDepartureContextCard(CancellationDataModel data) {
    final hours = data.timeRemainingHours?.floor() ?? 0;
    final days = hours ~/ 24;
    final remainingHours = hours % 24;

    final departureDate = data.boardingDateTime;
    String formattedDeparture = 'N/A';
    if (departureDate != null) {
      formattedDeparture = ISTDateUtils.formatCustom(
        departureDate,
        'EEE, dd MMM yyyy • hh:mm a',
      );
    }

    // Determine urgency color
    Color urgencyColor = _TI.teal;
    if (hours < 72 && hours >= 24) {
      urgencyColor = _TI.orange;
    } else if (hours < 24) {
      urgencyColor = _TI.red;
    }

    double progress = (hours / 72).clamp(0.0, 1.0);

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
          _sectionHeader('Departure & Deduction', Icons.schedule_rounded),
          SizedBox(height: 1.5.h),

          // Departure Info
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
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8.sp,
                          color: _TI.inkMid,
                        ),
                      ),
                      Text(
                        formattedDeparture,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.sp,
                          color: _TI.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 1.5.h),

          // Time Remaining Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Time remaining to departure',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9.sp,
                  color: _TI.inkMid,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$days Days $remainingHours Hrs',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.sp,
                  color: urgencyColor,
                  fontWeight: FontWeight.w800,
                ),
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

          SizedBox(height: 1.5.h),

          // Slab Info Explanation
          if (data.refundCalculation?.slabInfo != null) ...[
            Container(
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
                      data.refundCalculation!.slabInfo!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9.sp,
                        color: urgencyColor,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
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
  //  UNIFIED REFUND RECEIPT CARD
  // ─────────────────────────────────────────────
  Widget _unifiedRefundCard(
    CancellationDataModel? data,
    BookingHistoryData booking,
  ) {
    final double paid =
        data?.finalAmount ??
        double.tryParse(booking.finalAmount?.toString() ?? '0') ??
        0;
    final double deduction = data?.refundCalculation?.deduction ?? 0;
    final double refund = data?.refundCalculation?.refund ?? 0;
    final double refundPercent = paid > 0
        ? ((refund / paid) * 100).clamp(0, 100)
        : 0;

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
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 8.sp,
                fontWeight: FontWeight.w700,
                color: _TI.red,
                letterSpacing: 1,
              ),
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
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 8.sp,
                fontWeight: FontWeight.w700,
                color: _TI.teal,
                letterSpacing: 1,
              ),
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
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: _TI.ink,
                ),
              ),
              _animatedRupee(
                refund,
                fontSize: 16.sp,
                color: _TI.teal,
                fontWeight: FontWeight.w800,
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Progress bar
          _refundProgressBar(refundPercent),

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
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9.sp,
                      color: _TI.inkMid,
                      height: 1.4,
                    ),
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
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? _TI.ink : _TI.inkMid,
            ),
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
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10.sp,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _refundProgressBar(double percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                height: 1.h,
                width: double.infinity,
                color: _TI.redSoft,
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: percent / 100),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 1.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_TI.teal, _TI.brand],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 0.6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(100 - percent).toStringAsFixed(0)}% Deducted',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 8.sp,
                color: _TI.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${percent.toStringAsFixed(0)}% Refunded',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 8.sp,
                color: _TI.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Please enter your reason for cancellation...',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.sp,
                  color: _TI.inkLight,
                  height: 1.5,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(3.w),
              ),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10.sp,
                color: _TI.ink,
                height: 1.5,
              ),
            ),
          ),
        ],
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
      setState(() => _isCancelling = false);
      return;
    }

    try {
      final String? message = await _trekC.reqCancellation(bookingId);

      if (!mounted) return;

      if (message != null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          CustomSnackBar.show(context, message: message);
        });

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
    } catch (e) {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    } finally {
      if (!isSuccess && mounted) {
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
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
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
          _shimmerBox(height: 18.h, radius: 4.w),
          SizedBox(height: 1.5.h),
          _shimmerBox(height: 22.h, radius: 4.w),
          SizedBox(height: 1.5.h),
          _shimmerBox(height: 35.h, radius: 4.w),
          SizedBox(height: 1.5.h),
          _shimmerBox(height: 20.h, radius: 4.w),
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
