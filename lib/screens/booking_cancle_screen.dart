import 'package:arobo_app/freezed_models/booking/cancellation_data_model.dart';
import 'package:arobo_app/screens/booking_cancellation_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import '../controller/dashboard_controller.dart';
import '../controller/trek_controller.dart';
import '../freezed_models/booking/booking_history_model.dart';
import '../utils/common_colors.dart';
import '../utils/common_booked_details_card.dart';
import '../utils/custom_snackbar.dart';
import '../utils/screen_constants.dart';

class BookingsCancelScreen extends StatefulWidget {
  const BookingsCancelScreen({super.key});

  @override
  State<BookingsCancelScreen> createState() => _BookingsCancelScreenState();
}

class _BookingsCancelScreenState extends State<BookingsCancelScreen>
    with TickerProviderStateMixin {
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final TrekController _trekC = Get.find<TrekController>();

  // ─────────────────────────────────────────────
  //  DESIGN TOKENS
  // ─────────────────────────────────────────────
  static const _bg = CommonColors.offWhiteColor;
  static const _cardBg = CommonColors.whiteColor;
  static const _ink = CommonColors.blackColor;
  static const _inkMid = CommonColors.cFF6B7280;
  static const _inkLight = CommonColors.grey_AEAEAE;
  static const _brand = CommonColors.trek_route_color;
  static const _teal = CommonColors.cFF0F7B6C;
  static const _tealSoft = CommonColors.cFFE6F5F3;
  static const _red = CommonColors.cFFDC2626;
  static const _redSoft = CommonColors.cFFFFE4E4;
  static const _iconBadge = CommonColors.cFF111827;
  static const _divider = CommonColors.trekroutecolorlight;
  static const _shadow = CommonColors.c0A000000;
  static const _orange = Color(0xFFFF9800);
  static const _orangeSoft = Color(0xFFFFF3E0);

  // ─────────────────────────────────────────────
  //  ANIMATION CONTROLLERS
  // ─────────────────────────────────────────────
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _refundCountController;
  late final AnimationController _ctaScaleController;
  late final AnimationController _warningShakeController;
  late final AnimationController _headerSlideController;
  late final AnimationController _cardFlipController;

  bool _isCancelling = false;
  bool _hasAnimatedRefund = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

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

    _warningShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _cardFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _headerSlideController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _entranceController.forward();
        _refundCountController.forward();
        _cardFlipController.forward();
      });
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _refundCountController.dispose();
    _ctaScaleController.dispose();
    _warningShakeController.dispose();
    _headerSlideController.dispose();
    _cardFlipController.dispose();
    super.dispose();
  }

  // Staggered slide + fade entrance
  Widget _staggered(int index, Widget child, {double slideDistance = 28}) {
    final start = (index * 0.07).clamp(0.0, 0.65);
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
        backgroundColor: _bg,
        extendBodyBehindAppBar: false,
        appBar: _buildAppBar(),
        body: Obx(() {
          final isLoading = _trekC.cancellationDetailsResponseObserver.value
              .maybeWhen(loading: (_) => true, orElse: () => false);

          final CancellationDataModel? cancellationDataModel =
              _trekC.cancellationDetailsResponseObserver.value.maybeWhen(
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
      backgroundColor: _cardBg,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: _ink),
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _divider),
      ),
      title: AnimatedBuilder(
        animation: _headerSlideController,
        builder: (_, child) {
          final t = Curves.easeOutCubic.transform(_headerSlideController.value);
          return Opacity(
            opacity: t,
            child: Transform.translate(offset: Offset(0, (1 - t) * 12), child: child),
          );
        },
        child: Row(
          children: [
            Container(
              width: 7.w,
              height: 7.w,
              decoration: BoxDecoration(
                color: _redSoft,
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Icon(Icons.cancel_outlined, color: _red, size: 4.w),
            ),
            SizedBox(width: 2.5.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cancel Booking',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s14,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                Text(
                  'Review before confirming',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s9,
                    fontWeight: FontWeight.w400,
                    color: _inkLight,
                  ),
                ),
              ],
            ),
          ],
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

        final CancellationDataModel? cancellationDataModel =
            _trekC.cancellationDetailsResponseObserver.value.maybeWhen(
          success: (r) => (r as CancellationDetailsResponseModel).data,
          orElse: () => null,
        );

        return Container(
          padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 1.2.h),
          decoration: BoxDecoration(
            color: _cardBg,
            boxShadow: [
              BoxShadow(
                color: _shadow,
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: isLoading
              ? SizedBox(
                  height: 5.5.h,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: CommonColors.appColor,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : _buildCtaButton(booking, cancellationDataModel),
        );
      }),
    );
  }

  Widget _buildCtaButton(
      BookingHistoryData booking, CancellationDataModel? cancellationDataModel) {
    final isRequesting = _trekC.requestCancellationResponseObserver.value
        .maybeWhen(loading: (_) => true, orElse: () => false);

    final bool alreadyCancelled =
    cancellationDataModel?.canCancel == false;

final bool busy =
    isRequesting ||
    _isCancelling ||
    alreadyCancelled;

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
        builder: (_, child) => Transform.scale(
          scale: 1 - _ctaScaleController.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 5.5.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: busy
                ? LinearGradient(
                    colors: [_inkLight, _inkLight],
                  )
                : CommonColors.filterGradient,
            borderRadius: BorderRadius.circular(3.w),
            boxShadow: busy
                ? []
                : [
                    BoxShadow(
                      color: _brand.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: ScaleTransition(scale: anim, child: child),
            ),
            child: busy
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
                      const Icon(Icons.cancel_outlined,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        alreadyCancelled
    ? 'Already Cancelled'
    : 'Confirm Cancellation',
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s13,
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
      CancellationDataModel? cancellationDataModel, BookingHistoryData booking) {
    int i = 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero warning banner ──
          // _staggered(i++, _heroWarningBanner()),

          // ── Policy chip ──
          if (cancellationDataModel?.cancellationPolicyName != null)
            _staggered(i++, _policyChipRow(cancellationDataModel!)),

          SizedBox(height: 1.h),

          // ── Booking card ──
          _staggered(
            i++,
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(4.w),
                boxShadow: _cardShadow(),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.w),
                child: UpcomingBookingCard(booking: booking),
              ),
            ),
          ),

          SizedBox(height: 2.h),


                    // ── Time remaining ──

           if (cancellationDataModel?.timeRemainingHours != null)
            _staggered(i++, _timeRemainingCard(cancellationDataModel!)),
             SizedBox(height: 2.h),


          // ── Refund hero card ──
          _staggered(i++, _refundHeroCard(cancellationDataModel)),

          if (cancellationDataModel?.timeRemainingHours != null)
            SizedBox(height: 2.h),

          // ── Refund items ──
          if (cancellationDataModel?.refundCalculation?.refundItems != null &&
              cancellationDataModel!.refundCalculation!.refundItems!.isNotEmpty)
            _staggered(i++, _refundItemsCard(cancellationDataModel)),

          if (cancellationDataModel?.refundCalculation?.refundItems != null &&
              cancellationDataModel!.refundCalculation!.refundItems!.isNotEmpty)
            SizedBox(height: 2.h),

          // ── Loss items ──
          if (cancellationDataModel?.refundCalculation?.loseItems != null &&
              cancellationDataModel!.refundCalculation!.loseItems!.isNotEmpty)
            _staggered(i++, _lossItemsCard(cancellationDataModel)),

          if (cancellationDataModel?.refundCalculation?.loseItems != null &&
              cancellationDataModel!.refundCalculation!.loseItems!.isNotEmpty)
            SizedBox(height: 2.h),

          // ── Fare breakup ──
          _staggered(i++, _fareBreakupCard(cancellationDataModel, booking)),

          SizedBox(height: 2.h),

          // ── Reason ──
          _staggered(i++, _reasonCard(cancellationDataModel)),

          SizedBox(height: 3.5.h),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HERO WARNING BANNER
  // ─────────────────────────────────────────────
  Widget _heroWarningBanner() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, child) {
        final t = _pulseController.value;
        return Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 0),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
          decoration: BoxDecoration(
            color: _redSoft,
            borderRadius: BorderRadius.circular(4.w),
            border: Border.all(
              color: _red.withValues(alpha: 0.18 + t * 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _red.withValues(alpha: 0.06 + t * 0.06),
                blurRadius: 14 + t * 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, child) => Transform.scale(
              scale: 1.0 + _pulseController.value * 0.1,
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _red.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: _red, size: 5.w),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This action cannot be undone',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s12,
                    fontWeight: FontWeight.w700,
                    color: _red,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  'Please review the refund details carefully before confirming your cancellation.',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s9,
                    fontWeight: FontWeight.w400,
                    color: _inkMid,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  POLICY CHIP ROW
  // ─────────────────────────────────────────────
  Widget _policyChipRow(CancellationDataModel data) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 0),
      child: Row(
        children: [
          _chip(
            label:
                '${data.cancellationPolicyName?.toUpperCase() ?? 'FLEXIBLE'} ',
            icon: Icons.policy_outlined,
            bg: _orangeSoft,
            color: _orange,
          ),
          SizedBox(width: 2.w),
          // _chip(
          //   label: 'Partial Refund',
          //   icon: Icons.currency_rupee,
          //   bg: _tealSoft,
          //   color: _teal,
          // ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required IconData icon,
    required Color bg,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.w),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 3.5.w),
          SizedBox(width: 1.5.w),
          Text(
            label,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s8,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  REFUND HERO CARD
  // ─────────────────────────────────────────────
  Widget _refundHeroCard(CancellationDataModel? data) {
    final double refund = data?.refundCalculation?.refund ?? 0;
    final double paid = data?.finalAmount ?? 0;
    final double deduction = data?.refundCalculation?.deduction ?? 0;
    final double refundPercent =
        paid > 0 ? ((refund / paid) * 100).clamp(0, 100) : 0;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Refund Summary', Icons.account_balance_wallet_outlined),
          SizedBox(height: 2.5.h),

          // Big refund amount
          Center(
            child: Column(
              children: [
                Text(
                  'You will receive',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s10,
                    fontWeight: FontWeight.w400,
                    color: _inkMid,
                  ),
                ),
                SizedBox(height: 0.8.h),
                _animatedRupee(
                  refund,
                  fontSize: FontSize.s28,
                  color: _teal,
                  fontWeight: FontWeight.w800,
                ),
                SizedBox(height: 0.5.h),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: _tealSoft,
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  child: Text(
                    '${refundPercent.toStringAsFixed(0)}% of total paid',
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s8,
                      fontWeight: FontWeight.w600,
                      color: _teal,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Animated progress bar
          _refundProgressBar(refundPercent),

          SizedBox(height: 1.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStat(
                  'Paid', paid, _ink, Icons.payments_outlined),
              _miniStatDivider(),
              _miniStat(
                  'Deduction', deduction, _red, Icons.remove_circle_outline),
              _miniStatDivider(),
              _miniStat(
                  'Refund', refund, _teal, Icons.arrow_upward_rounded),
            ],
          ),

          SizedBox(height: 2.h),

          // GestureDetector(
          //   onTap: () => _showPolicyDetails(data),
          //   child: Container(
          //     padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          //     decoration: BoxDecoration(
          //       color: _brand.withValues(alpha: 0.06),
          //       borderRadius: BorderRadius.circular(2.w),
          //       border: Border.all(color: _brand.withValues(alpha: 0.15)),
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(Icons.info_outline, color: _brand, size: 3.5.w),
          //         SizedBox(width: 2.w),
          //         Text(
          //           'View cancellation policy',
          //           textScaler: const TextScaler.linear(1.0),
          //           style: TextStyle(
          //             fontFamily: 'Poppins',
          //             fontSize: FontSize.s9,
          //             fontWeight: FontWeight.w600,
          //             color: _brand,
          //           ),
          //         ),
          //         SizedBox(width: 1.w),
          //         Icon(Icons.keyboard_arrow_right_rounded,
          //             color: _brand, size: 4.w),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _refundProgressBar(double percent) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percent / 100),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      builder: (_, value, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Container(
                    height: 1.2.h,
                    width: double.infinity,
                    color: _redSoft,
                  ),
                  FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 1.2.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_teal, _brand],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 0.6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deducted',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s7,
                    color: _red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Refunded',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s7,
                    color: _teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _miniStat(String label, double value, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 4.w),
          ),
          SizedBox(height: 0.5.h),
          _animatedRupee(value,
              fontSize: FontSize.s10,
              color: color,
              fontWeight: FontWeight.w700),
          Text(
            label,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s8,
              color: _inkLight,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStatDivider() {
    return Container(
      height: 5.h,
      width: 1,
      color: _divider,
    );
  }

  // ─────────────────────────────────────────────
  //  TIME REMAINING CARD
  // ─────────────────────────────────────────────
  Widget _timeRemainingCard(CancellationDataModel data) {
    final int hours = data.timeRemainingHours!.floor();
    final int days = hours ~/ 24;
    final int remainingHours = hours % 24;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, child) {
        final t = _pulseController.value;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _brand.withValues(alpha: 0.10 + t * 0.05),
                _brand.withValues(alpha: 0.04 + t * 0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(4.w),
            border: Border.all(
              color: _brand.withValues(alpha: 0.15 + t * 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: _brand.withValues(alpha: 0.06 + t * 0.08),
                blurRadius: 12 + t * 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, child) => Transform.rotate(
              angle: _pulseController.value * 0.3,
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _brand.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.access_time_rounded, color: _brand, size: 5.w),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time remaining for best refund',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s8,
                    fontWeight: FontWeight.w500,
                    color: _inkMid,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Row(
                  children: [
                    _timeUnit('$days', 'days'),
                    SizedBox(width: 2.w),
                    Text(
                      ':',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s16,
                        fontWeight: FontWeight.w800,
                        color: _brand,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    _timeUnit('$remainingHours', 'hrs'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
            decoration: BoxDecoration(
              color: _brand.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Text(
                'LIVE',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s7,
                  fontWeight: FontWeight.w800,
                  color: _brand.withValues(alpha: 0.6 + _pulseController.value * 0.4),
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeUnit(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s18,
            fontWeight: FontWeight.w800,
            color: _brand,
          ),
        ),
        Text(
          label,
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s7,
            fontWeight: FontWeight.w500,
            color: _inkMid,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  REFUND ITEMS CARD
  // ─────────────────────────────────────────────
  Widget _refundItemsCard(CancellationDataModel data) {
    final items = data.refundCalculation!.refundItems!;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("What You'll Get Back", Icons.arrow_upward_rounded),
          SizedBox(height: 2.h),
          ...List.generate(items.length, (idx) {
            return _animatedListItem(
              index: idx,
              child: Padding(
                padding: EdgeInsets.only(bottom: 1.2.h),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: _tealSoft,
                    borderRadius: BorderRadius.circular(2.5.w),
                    border: Border.all(color: _teal.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: _teal.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_rounded,
                            color: _teal, size: 3.5.w),
                      ),
                      SizedBox(width: 2.5.w),
                      Expanded(
                        child: Text(
                          items[idx].item ?? 'Unknown',
                          textScaler: const TextScaler.linear(1.0),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s10,
                            fontWeight: FontWeight.w500,
                            color: _ink,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        "₹ ${items[idx].amount?.toStringAsFixed(2) ?? '0'}",
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s10,
                          fontWeight: FontWeight.w700,
                          color: _teal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Divider(color: _divider, height: 1),
          SizedBox(height: 1.2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Refund',
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              _animatedRupee(
                data.refundCalculation?.refund ?? 0,
                fontSize: FontSize.s14,
                color: _teal,
                fontWeight: FontWeight.w800,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  LOSS ITEMS CARD
  // ─────────────────────────────────────────────
  Widget _lossItemsCard(CancellationDataModel data) {
    final items = data.refundCalculation!.loseItems!;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("What You'll Lose", Icons.arrow_downward_rounded),
          SizedBox(height: 2.h),
          ...List.generate(items.length, (idx) {
            return _animatedListItem(
              index: idx,
              child: Padding(
                padding: EdgeInsets.only(bottom: 1.2.h),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: _redSoft,
                    borderRadius: BorderRadius.circular(2.5.w),
                    border: Border.all(color: _red.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: _red.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded,
                            color: _red, size: 3.5.w),
                      ),
                      SizedBox(width: 2.5.w),
                      Expanded(
                        child: Text(
                          items[idx].item ?? 'Unknown',
                          textScaler: const TextScaler.linear(1.0),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s10,
                            fontWeight: FontWeight.w500,
                            color: _ink,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        "- ₹ ${items[idx].amount?.toStringAsFixed(2) ?? '0'}",
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s10,
                          fontWeight: FontWeight.w700,
                          color: _red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Divider(color: _divider, height: 1),
          SizedBox(height: 1.2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Deduction',
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              _animatedRupee(
                data.refundCalculation?.deduction ?? 0,
                fontSize: FontSize.s14,
                color: _red,
                fontWeight: FontWeight.w800,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  FARE BREAKUP CARD
  // ─────────────────────────────────────────────
  Widget _fareBreakupCard(
      CancellationDataModel? data, BookingHistoryData booking) {
    final double paid = data?.finalAmount ??
        double.tryParse(booking.finalAmount?.toString() ?? '0') ??
        0;
    final double deduction = data?.refundCalculation?.deduction ?? 0;
    final double refund = data?.refundCalculation?.refund ?? 0;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Fare Breakup', Icons.receipt_long_outlined),
          SizedBox(height: 2.h),
          _breakupRow(
            label: 'Total Amount Paid',
            amount: paid,
            icon: Icons.payments_outlined,
            iconColor: _ink,
            amountColor: _ink,
          ),
          _breakupDividerLine(),
          if (deduction > 0) ...[
            _breakupRow(
              label: 'Cancellation Charges',
              amount: -deduction,
              icon: Icons.remove_circle_outline,
              iconColor: _red,
              amountColor: _red,
              isDeduction: true,
            ),
            _breakupDividerLine(),
          ],
          _breakupRow(
            label: 'Total Refund Amount',
            amount: refund,
            icon: Icons.account_balance_wallet_outlined,
            iconColor: _teal,
            amountColor: _teal,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _breakupRow({
    required String label,
    required double amount,
    required IconData icon,
    required Color iconColor,
    required Color amountColor,
    bool isDeduction = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Container(
            width: 7.5.w,
            height: 7.5.w,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Icon(icon, color: iconColor, size: 3.8.w),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              label,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: isTotal ? FontSize.s11 : FontSize.s10,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                color: isTotal ? _ink : _inkMid,
              ),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: amount.abs()),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (_, val, __) {
              final display = isDeduction
                  ? "- ₹ ${val.toStringAsFixed(2)}"
                  : "₹ ${val.toStringAsFixed(2)}";
              return Text(
                display,
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: isTotal ? FontSize.s13 : FontSize.s10,
                  fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
                  color: amountColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _breakupDividerLine() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.3.h),
      child: Row(
        children: [
          SizedBox(width: 10.5.w),
          Expanded(child: Divider(color: _divider, height: 1, thickness: 1)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  REASON CARD
  // ─────────────────────────────────────────────
  Widget _reasonCard(CancellationDataModel? cancellationDataModel) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Reason for Cancellation', Icons.edit_note_rounded),
          SizedBox(height: 2.h),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FF),
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(color: _brand.withValues(alpha: 0.15)),
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
                  fontSize: FontSize.s10,
                  color: _inkLight,
                  height: 1.5,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(3.w),
              ),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                color: _ink,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          _infoCard(
            icon: Icons.schedule_outlined,
            text:
                'Refund will be processed to the original payment method within 5–7 business days.',
            color: _teal,
            bg: _tealSoft,
          ),
          SizedBox(height: 1.h),
          _infoCard(
            icon: Icons.lock_outline_rounded,
            text: 'Cancellation charges are non-negotiable once confirmed.',
            color: _red,
            bg: _redSoft,
          ),
          SizedBox(height: 1.h),
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          //   decoration: BoxDecoration(
          //     color: _orangeSoft,
          //     borderRadius: BorderRadius.circular(2.w),
          //     border: Border.all(color: _orange.withValues(alpha: 0.2)),
          //   ),
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Icon(Icons.gavel_outlined, color: _orange, size: 3.5.w),
          //       SizedBox(width: 2.w),
          //       Expanded(
          //         child: RichText(
          //           text: TextSpan(
          //             style: TextStyle(
          //               fontFamily: 'Poppins',
          //               fontSize: FontSize.s9,
          //               color: _inkMid,
          //               height: 1.5,
          //             ),
          //             children: [
          //               const TextSpan(
          //                   text: 'Deductions are as per the '),
          //               TextSpan(
          //                 text: 'cancellation policy',
          //                 style: TextStyle(
          //                   color: _brand,
          //                   fontWeight: FontWeight.w700,
          //                 ),
          //                 recognizer: TapGestureRecognizer()
          //                   ..onTap = () =>
          //                       _showPolicyDetails(cancellationDataModel),
          //               ),
          //               const TextSpan(text: '. Tap to view.'),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String text,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 3.5.w),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              text,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                color: _inkMid,
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

    final String? message =
        await _trekC.reqCancellation(bookingId);

    if (!mounted) return;

    if (message != null) {

      SchedulerBinding.instance.addPostFrameCallback((_) {
        CustomSnackBar.show(
          context,
          message: message,
        );
      });

      setState(() => _isCancelling = false);

      return;
    }

    // SUCCESS
    isSuccess = true;

    // refresh booking detail
    await _dashboardC.getBookingDetail(
      bookingId: bookingId,
    );

    // navigate
    Get.off(() => BookingCancellationSuccessScreen(
          refund: cancellationDataModel
                  ?.refundCalculation
                  ?.refund
                  ?.toStringAsFixed(2) ??
              '0',
          booking: _dashboardC.bookingHistoryModal.value,
        ));

  } catch (e) {

    if (mounted) {
      setState(() => _isCancelling = false);
    }

  } finally {

    // ONLY reset if failed
    if (!isSuccess && mounted) {
      setState(() => _isCancelling = false);
    }
  }
}

  // ─────────────────────────────────────────────
  //  SHARED PRIMITIVES
  // ─────────────────────────────────────────────
  List<BoxShadow> _cardShadow() => [
        BoxShadow(
          color: CommonColors.blackColor.withValues(alpha: 0.07),
          blurRadius: 14,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: _cardShadow(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: child,
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.6, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (_, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Container(
            width: 9.w,
            height: 9.w,
            decoration: BoxDecoration(
              color: _iconBadge,
              borderRadius: BorderRadius.circular(2.5.w),
            ),
            child: Center(
              child: Icon(icon, color: Colors.white, size: 4.5.w),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          title,
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w700,
            color: _ink,
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
        final t =
            Curves.easeOutCubic.transform(_refundCountController.value);
        return Text(
          "₹ ${(value * t).toStringAsFixed(2)}",
          textScaler: const TextScaler.linear(1.0),
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

  Widget _animatedListItem({required int index, required Widget child}) {
    final start = (0.2 + index * 0.06).clamp(0.0, 0.75);
    final end = (start + 0.35).clamp(0.0, 1.0);
    final curved = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curved,
      builder: (_, __) => Opacity(
        opacity: curved.value,
        child: Transform.translate(
          offset: Offset((1 - curved.value) * 20, 0),
          child: child,
        ),
      ),
    );
  }

  Widget _infoNote(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: _brand, size: 3.5.w),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              text,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                color: _inkLight,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPolicyDetails(CancellationDataModel? data) {
    if (data == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: _inkLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: _orangeSoft,
                    borderRadius: BorderRadius.circular(2.5.w),
                  ),
                  child: Icon(Icons.policy_outlined,
                      color: _orange, size: 5.w),
                ),
                SizedBox(width: 3.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.cancellationPolicyName ?? 'Cancellation Policy',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s15,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    Text(
                      data.cancellationPolicyType?.toUpperCase() ?? 'N/A',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s9,
                        fontWeight: FontWeight.w600,
                        color: _brand,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Divider(color: _divider),
            SizedBox(height: 2.h),
            _infoCard(
              icon: Icons.schedule_outlined,
              text: 'Refund will be processed as per the policy terms.',
              color: _teal,
              bg: _tealSoft,
            ),
            SizedBox(height: 1.h),
            _infoCard(
              icon: Icons.support_agent_outlined,
              text: 'For any queries, please contact the support team.',
              color: _brand,
              bg: _brand.withValues(alpha: 0.07),
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              height: 5.h,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _brand.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.5.w),
                  ),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s12,
                    fontWeight: FontWeight.w600,
                    color: _brand,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SHIMMER
  // ─────────────────────────────────────────────
  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Column(
        children: [
          _shimmerBox(height: 12.h, radius: 4.w),
          SizedBox(height: 1.5.h),
          _shimmerBox(height: 4.h, radius: 10.w, isChips: true),
          SizedBox(height: 1.5.h),
          _shimmerBox(height: 22.h, radius: 4.w),
          SizedBox(height: 1.5.h),
          _shimmerBox(height: 28.h, radius: 4.w),
          SizedBox(height: 1.5.h),
          _shimmerBox(height: 8.h, radius: 4.w),
          SizedBox(height: 1.5.h),
          _shimmerBox(height: 20.h, radius: 4.w),
          SizedBox(height: 1.5.h),
          _shimmerBox(height: 20.h, radius: 4.w),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _shimmerBox(
      {required double height,
      required double radius,
      bool isChips = false}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isChips ? 4.w : 4.w),
      height: height,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(radius),
      ),
    ).withShimmerAi(loading: true);
  }
}
