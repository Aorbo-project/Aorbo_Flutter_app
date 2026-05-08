import 'dart:async';

import 'package:arobo_app/freezed_models/booking/booking_data_model.dart';
import 'package:arobo_app/screens/coupon_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/utils/booking_constants.dart';
import 'package:arobo_app/utils/common_btn.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/total_fare_modal.dart';
import 'package:arobo_app/widgets/slot_booking_details_modal.dart';

// ─────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────
class _Pay {
  static const bg = Color(0xFFF4F7FF);
  static const cardBg = Color(0xFFFFFFFF);
  static const ink = Color(0xFF0F172A);
  static const inkMid = Color(0xFF64748B);
  static const inkLight = Color(0xFFADB5BD);
  static const accent = Color(0xFF3B5BDB);
  static const accentLight = Color(0xFFEEF2FF);
  static const border = Color(0xFFE9ECEF);
  static const divider = Color(0xFFF1F5F9);
  static const green = Color(0xFF0F7B6C);
  static const greenLight = Color(0xFFE6F5F3);
  static const orange = Color(0xFFE67700);
  static const orangeLight = Color(0xFFFFF3BF);
  static const red = Color(0xFFE03131);
  static const redLight = Color(0xFFFFF5F5);
  static const shadow = Color(0x08000000);
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final TrekController _trekC = Get.find<TrekController>();
  final UserController _userC = Get.find<UserController>();

  String? _couponError;
  final TextEditingController _couponCtrl = TextEditingController();

  bool _isCouponExpanded = true;
  String? _selectedUPI = PaymentMethods.razorpay;

  static const int _totalTimerSecs = 5 * 60;
  final RxInt _remainingSecs = _totalTimerSecs.obs;
  bool _isTimerExpired = false;
  Timer? _timer;

  late Razorpay _razorpay;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _couponCtrl.addListener(_handleTextChange);

    debounce(
      _trekC.calculateFareRequestModel,
      (_) => _trekC.calculateFare(),
      time: const Duration(milliseconds: 500),
    );

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _couponCtrl.removeListener(_handleTextChange);
    _couponCtrl.dispose();
    _razorpay.clear();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    if (mounted) setState(() {});
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  String? _extractAppliedCouponCode() {
    final code = _trekC.calculateFareRequestModel.value.couponCode;
    if (code == null) return null;
    final cleaned = code.trim();
    return cleaned.isEmpty ? null : cleaned;
  }

  String? _extractCouponDiscountText(CalculateFareResponseModel? response) {
    final details = _asMap(response?.couponDetails);
    if (details == null) return null;

    final raw = details['discountAmount'] ??
        details['discount_amount'] ??
        details['discount'] ??
        details['amount'] ??
        details['value'];

    if (raw == null) return null;

    final text = raw.toString().trim();
    if (text.isEmpty || text == 'null') return null;
    return text;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

      if (_remainingSecs.value > 0) {
        _remainingSecs.value--;
      }

      if (_remainingSecs.value == 0) {
        _isTimerExpired = true;
        t.cancel();
        _handleTimerExpired();
      }
    });
  }

  void _handleTimerExpired() {
    if (!mounted) return;
    CustomSnackBar.show(
      context,
      message: 'Payment session timed out. Please start over.',
    );
    Get.back();
  }

  void _openRazorpay(BreakDownDataModel? breakdown) async {
    try {
      final finalAmount = breakdown?.amountToPayNow ?? 0;

      final options = {
        'key': BookingConstants.razorpayKey,
        'order_id': '${_trekC.orderData.value.id}',
        'amount': (finalAmount * 100).toInt(),
        'name': '${_trekC.trekDetailData.value.title}',
        'description': '${_trekC.trekDetailData.value.description}',
        'prefill': {
          'contact': '${_userC.userProfileData.value.customer?.phone}',
          'email': '${_userC.userProfileData.value.customer?.email}',
        },
      };

      _razorpay.open(options);
    } catch (e) {
      CustomSnackBar.show(
        context,
        message: 'Failed to open payment: ${e.toString()}',
      );
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse r) async {
    _trekC.orderId.value = r.orderId ?? '';
    _trekC.paymentId.value = r.paymentId ?? '';
    _trekC.signature.value = r.signature ?? '';

    await _trekC.verifyTrekOrder(
      razorpayOrderId: r.orderId ?? '',
      razorpayPaymentId: r.paymentId ?? '',
      razorpaySignature: r.signature ?? '',
    );
  }

  void _handlePaymentError(PaymentFailureResponse r) {
    CustomSnackBar.show(context, message: 'Payment Failed! ${r.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse r) {
    CustomSnackBar.show(
      context,
      message:
          'You have chosen to pay via ${r.walletName}. It may take some time to reflect.',
    );
  }

  bool get _isPaymentValid {
    final valid = _trekC.calculateFareResponseModel.value.maybeWhen(
      success: (_) => true,
      orElse: () => false,
    );
    return _selectedUPI == PaymentMethods.razorpay && valid;
  }

  List<Map<String, dynamic>> _getTravellerDetails() {
    final list = _trekC.travellerDetailList;
    if (list.isNotEmpty) {
      return list
          .map(
            (t) => {
              'nameController': TextEditingController(text: t.name ?? ''),
              'ageController': TextEditingController(text: t.age?.toString() ?? ''),
              'gender': t.gender ?? '',
            },
          )
          .toList();
    }

    return [
      {
        'nameController': TextEditingController(text: 'Traveller'),
        'ageController': TextEditingController(text: '18'),
        'gender': 'Male',
      }
    ];
  }

  String _calculateEndDate(String? startDate, int? durationDays) {
    if (startDate == null || startDate.isEmpty || durationDays == null) {
      return '-';
    }

    try {
      final start = DateTime.parse(startDate);
      final end = start.add(Duration(days: durationDays));
      return '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return '-';
    }
  }

  Widget _buildTimerAndProgress() {
    return Center(
      child: Obx(() {
        final minutes = _remainingSecs.value ~/ 60;
        final seconds = _remainingSecs.value % 60;

        final formattedTime =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        final progressValue = _remainingSecs.value / _totalTimerSecs;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 17.w,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 4.w,
                    color: CommonColors.orangeColor,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    formattedTime,
                    textScaler: const TextScaler.linear(1.0),
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w600,
                      color: CommonColors.orangeColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 0.5.h),
            SizedBox(
              width: 17.w,
              height: 0.5.h,
              child: LinearProgressIndicator(
                value: progressValue,
                backgroundColor: CommonColors.greyColor.withValues(alpha: 0.3),
                color: CommonColors.orangeColor,
                minHeight: 0.1.h,
                borderRadius: BorderRadius.circular(200),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCouponSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      width: 100.w,
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100.w,
            margin: EdgeInsets.only(
              left: 4.w,
              right: 4.w,
              top: 2.4.h,
              bottom: _isCouponExpanded ? 2.4.h : 2.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      CommonImages.couponIcon,
                      width: 6.w,
                      height: 6.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Coupon Code',
                      textScaler: const TextScaler.linear(1.0),
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s14,
                        fontWeight: FontWeight.w500,
                        color: CommonColors.blackColor,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isCouponExpanded = !_isCouponExpanded;
                        });
                      },
                      child: AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: _isCouponExpanded ? 0 : 0.5,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 7.w,
                          color: CommonColors.blackColor,
                        ),
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _isCouponExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Column(
                    children: [
                      SizedBox(height: 2.h),
                      Container(
                        decoration: BoxDecoration(
                          color: CommonColors.whiteColor,
                          borderRadius: BorderRadius.circular(3.w),
                          border: Border.all(
                            color: CommonColors.greyColor,
                            width: 0.3.w,
                          ),
                        ),
                        child: Obx(() {
                          final fareResponse =
                              _trekC.calculateFareResponseModel.value.maybeWhen(
                            success: (response) =>
                                response as CalculateFareResponseModel,
                            orElse: () => null,
                          );

                          final appliedCoupon = _extractAppliedCouponCode();
                          final discountText =
                              _extractCouponDiscountText(fareResponse);
                          final isCouponValid = discountText != null;

                          if (appliedCoupon == null) {
                            return InkWell(
                              onTap: () {
                                Get.to(() => CouponCodeScreen());
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 7.w,
                                  vertical: 1.h,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: CommonColors.whiteColor,
                                          borderRadius:
                                              BorderRadius.circular(3.w),
                                          border: Border.all(
                                            color: CommonColors.profileColor,
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Enter Coupon Code',
                                            style: GoogleFonts.poppins(
                                              fontSize: FontSize.s11,
                                              color: const Color(0xff969696),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Get.to(() => CouponCodeScreen());
                                      },
                                      child: Text(
                                        'Apply',
                                        style: GoogleFonts.poppins(
                                          fontSize: FontSize.s11,
                                          fontWeight: FontWeight.w500,
                                          color: _couponCtrl.text.isNotEmpty
                                              ? CommonColors.blueColor
                                              : const Color(0xff969696),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    appliedCoupon,
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s11,
                                      color: const Color(0xff969696),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: isCouponValid
                                      ? CommonColors.btnGradient
                                      : (_couponCtrl.text.isNotEmpty
                                          ? CommonColors.btnGradient
                                          : CommonColors.disableBtnGradient),
                                  borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(3.w),
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      _trekC.calculateFareRequestModel.value =
                                          _trekC.calculateFareRequestModel.value
                                              .copyWith(couponCode: '');
                                    },
                                    borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(3.w),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5.w,
                                        vertical: 1.5.h,
                                      ),
                                      child: Text(
                                        isCouponValid
                                            ? BookingMessages.remove
                                            : BookingMessages.apply,
                                        style: GoogleFonts.poppins(
                                          fontSize: FontSize.s11,
                                          fontWeight: FontWeight.w500,
                                          color: CommonColors.whiteColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                      if (_couponError != null) ...[
                        SizedBox(height: 1.h),
                        Padding(
                          padding: EdgeInsets.only(left: 1.w),
                          child: Text(
                            _couponError ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s7,
                              color: CommonColors.appRedColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(icon: Icons.payment_rounded, label: 'Payment Method'),
          const SizedBox(height: 14),
          _paymentOption(
            icon: _razorpayLogo(),
            label: 'Razorpay',
            subtitle: 'Credit card, Debit card, UPI, Wallets & more',
            isSelected: _selectedUPI == PaymentMethods.razorpay,
            onTap: () => setState(() => _selectedUPI = PaymentMethods.razorpay),
          ),
          const SizedBox(height: 10),
          Divider(color: _Pay.divider, height: 1),
          const SizedBox(height: 10),
          Opacity(
            opacity: 0.45,
            child: _paymentOption(
              icon: _lockedIcon(CommonImages.phonePeIcon),
              label: 'PhonePe UPI',
              subtitle: 'Coming soon',
              isSelected: false,
              isLocked: true,
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          Opacity(
            opacity: 0.45,
            child: _paymentOption(
              icon: _lockedIcon(CommonImages.paytmIcon),
              label: 'Paytm UPI',
              subtitle: 'Coming soon',
              isSelected: false,
              isLocked: true,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOption({
    required Widget icon,
    required String label,
    required String subtitle,
    required bool isSelected,
    bool isLocked = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _Pay.accentLight : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? _Pay.accent.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w600,
                      color: _Pay.ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s8,
                      color: _Pay.inkMid,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              Icon(Icons.lock_outline_rounded, size: 16, color: _Pay.inkLight)
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? _Pay.accent : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? _Pay.accent : _Pay.inkLight,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        size: 13, color: Colors.white)
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _razorpayLogo() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF3395FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'R',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _lockedIcon(String svgPath) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _Pay.divider,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: SvgPicture.asset(svgPath, width: 22, height: 22),
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline_rounded, size: 12, color: _Pay.green),
        const SizedBox(width: 5),
        Text(
          '256-bit SSL encrypted payment · 100% secure',
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s8,
            color: _Pay.inkMid,
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _Pay.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Pay.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: _Pay.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader({required IconData icon, required String label}) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _Pay.accentLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: _Pay.accent),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s13,
            fontWeight: FontWeight.w700,
            color: _Pay.ink,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: _Pay.inkLight),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s10,
              color: _Pay.inkMid,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrekSummaryCard(
    dynamic trek,
    dynamic fareReq,
    CalculateFareResponseModel? fareResponse,
  ) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(icon: Icons.landscape_outlined, label: 'Trek Summary'),
          const SizedBox(height: 14),
          Text(
            trek.title ?? '-',
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s14,
              fontWeight: FontWeight.w700,
              color: _Pay.ink,
            ),
          ),
          const SizedBox(height: 10),
          _infoRow(
            Icons.place_outlined,
            '${_dashboardC.fromController.value.text}  →  ${_dashboardC.toController.value.text}',
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _infoRow(
                  Icons.calendar_today_outlined,
                  trek.startDate ?? '-',
                ),
              ),
              Expanded(
                child: _infoRow(
                  Icons.access_time_rounded,
                  '${trek.durationDays ?? '-'}D / ${trek.durationNights ?? '-'}N',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _infoRow(
            Icons.person_outline_rounded,
            '${fareReq.travelerCount} Traveller${fareReq.travelerCount > 1 ? 's' : ''}',
          ),
          if (fareResponse?.couponDetails != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _Pay.greenLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_offer_outlined, size: 13, color: _Pay.green),
                  const SizedBox(width: 5),
                  Text(
                    'Coupon applied — ${fareReq.couponCode}',
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s9,
                      fontWeight: FontWeight.w600,
                      color: _Pay.green,
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

  Widget _buildTravellerDetailsCard() {
    final travellers = _getTravellerDetails();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.people_outline_rounded,
            label: 'Traveller Details',
          ),
          const SizedBox(height: 14),
          ...travellers.asMap().entries.map((e) {
            final i = e.key;
            final t = e.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (travellers.length > 1) ...[
                  Text(
                    'Traveller ${i + 1}',
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s10,
                      fontWeight: FontWeight.w700,
                      color: _Pay.accent,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _travRow(
                        'Name',
                        (t['nameController'] as TextEditingController).text,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _travRow(
                        'Age',
                        (t['ageController'] as TextEditingController).text,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _travRow('Gender', t['gender'] ?? '-'),
                    ),
                  ],
                ),
                if (i < travellers.length - 1) ...[
                  const SizedBox(height: 10),
                  Divider(color: _Pay.divider, height: 1),
                  const SizedBox(height: 10),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _travRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s8,
            color: _Pay.inkLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value.isEmpty ? '-' : value,
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s11,
            fontWeight: FontWeight.w600,
            color: _Pay.ink,
          ),
        ),
      ],
    );
  }

  Widget _buildFareBreakdownCard(BreakDownDataModel? bd, dynamic fareReq) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _sectionHeader(
                  icon: Icons.receipt_long_outlined,
                  label: 'Fare Breakdown',
                ),
              ),
              GestureDetector(
                onTap: () {
                  final fareResp = _trekC.calculateFareResponseModel.value.maybeWhen(
                    success: (r) => r as CalculateFareResponseModel,
                    orElse: () => null,
                  );
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => TotalFareModal(
                      breakDown: fareResp?.breakdown,
                      adultCount: fareReq.travelerCount,
                      onClose: () => Navigator.pop(context),
                    ),
                  );
                },
                child: Text(
                  'View full',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s9,
                    fontWeight: FontWeight.w600,
                    color: _Pay.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (bd == null)
            Center(
              child: Text(
                'Loading fare…',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s10,
                  color: _Pay.inkMid,
                ),
              ),
            )
          else ...[
            _fareRow('Base fare', '₹${bd.baseTotal ?? '--'}'),
            _fareRow('GST & taxes', '₹${bd.gst ?? '--'}'),
            if ((bd.discount ?? 0) != 0)
              _fareRow(
                'Coupon discount',
                '− ₹${bd.discount ?? '--'}',
                valueColor: _Pay.green,
              ),
            if ((bd.platformFee ?? 0) != 0)
              _fareRow('Platform fee', '₹${bd.platformFee ?? '--'}'),
            const SizedBox(height: 8),
            Container(height: 0.5, color: _Pay.border),
            const SizedBox(height: 8),
            _fareRow(
              fareReq.cancellationPolicyType == 'partial'
                  ? 'Amount to pay now'
                  : 'Total amount',
              '₹${bd.amountToPayNow ?? '--'}',
              isBold: true,
              valueColor: _Pay.accent,
            ),
            if (fareReq.cancellationPolicyType == 'partial') ...[
              const SizedBox(height: 4),
              _fareRow(
                'Remaining amount',
                '₹${bd.remainingAmount ?? '--'}',
                valueColor: _Pay.inkMid,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _fareRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s10,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: isBold ? _Pay.ink : _Pay.inkMid,
            ),
          ),
          Text(
            value,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: isBold ? FontSize.s13 : FontSize.s10,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? _Pay.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(
    dynamic fareReq,
    CalculateFareResponseModel? fareResponse,
  ) {
    final appliedCode = fareReq.couponCode ?? '';
    final discountText = _extractCouponDiscountText(fareResponse);
    final isCouponApplied = discountText != null;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _Pay.accentLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    CommonImages.couponIcon,
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      _Pay.accent,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Coupon Code',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w700,
                    color: _Pay.ink,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    setState(() => _isCouponExpanded = !_isCouponExpanded),
                child: AnimatedRotation(
                  turns: _isCouponExpanded ? 0 : 0.5,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: _Pay.inkMid,
                  ),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState: _isCouponExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                if (appliedCode.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isCouponApplied ? _Pay.greenLight : _Pay.redLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCouponApplied
                            ? _Pay.green.withValues(alpha: 0.3)
                            : _Pay.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCouponApplied
                              ? Icons.check_circle_outline_rounded
                              : Icons.cancel_outlined,
                          size: 18,
                          color: isCouponApplied ? _Pay.green : _Pay.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appliedCode,
                                textScaler: const TextScaler.linear(1.0),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: FontSize.s12,
                                  fontWeight: FontWeight.w700,
                                  color: isCouponApplied ? _Pay.green : _Pay.red,
                                ),
                              ),
                              if (isCouponApplied)
                                Text(
                                  'You save ₹$discountText',
                                  textScaler: const TextScaler.linear(1.0),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: FontSize.s9,
                                    color: _Pay.green,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _trekC.calculateFareRequestModel.value =
                                _trekC.calculateFareRequestModel.value
                                    .copyWith(couponCode: '');
                          },
                          child: Text(
                            'Remove',
                            textScaler: const TextScaler.linear(1.0),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s9,
                              fontWeight: FontWeight.w600,
                              color: _Pay.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => Get.to(() => CouponCodeScreen()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _Pay.bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _Pay.accent.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_offer_outlined,
                              size: 16, color: _Pay.accent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Browse & apply coupon codes',
                              textScaler: const TextScaler.linear(1.0),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s11,
                                color: _Pay.accent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 12, color: _Pay.accent),
                        ],
                      ),
                    ),
                  ),
                if (_couponError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _couponError!,
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s8,
                      color: _Pay.red,
                    ),
                  ),
                ],
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: _Pay.cardBg,
        border: Border(top: BorderSide(color: _Pay.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() {
        final fareReq = _trekC.calculateFareRequestModel.value;
        final fareResp = _trekC.calculateFareResponseModel.value.maybeWhen(
          success: (r) => r as CalculateFareResponseModel,
          orElse: () => null,
        );
        final bd = fareResp?.breakdown;

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 1.5.h),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (_) => TotalFareModal(
                          breakDown: bd,
                          adultCount: fareReq.travelerCount,
                          onClose: () => Navigator.pop(context),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              BookingMessages.totalFare,
                              textScaler: const TextScaler.linear(1.0),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s9,
                                color: _Pay.inkMid,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down_rounded,
                                size: 16, color: _Pay.inkMid),
                          ],
                        ),
                        Text(
                          bd?.amountToPayNow != null
                              ? '₹${bd?.amountToPayNow}'
                              : '--',
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s18,
                            fontWeight: FontWeight.w800,
                            color: _Pay.accent,
                          ),
                        ),
                        Text(
                          BookingMessages.taxIncluded,
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s8,
                            color: _Pay.inkLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                CommonButton(
                  text: BookingMessages.payNow,
                  fontSize: FontSize.s13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  onPressed: () async {
                    if (_isPaymentValid) {
                      await _trekC.createTrekOrder();
                      if (_trekC.orderModal.value.success ?? false) {
                        _openRazorpay(bd);
                      }
                    }
                  },
                  gradient: _isPaymentValid
                      ? CommonColors.filterGradient
                      : CommonColors.disableBtnGradient,
                  textColor: CommonColors.whiteColor,
                  height: 52,
                  width: 44.w,
                  isFullWidth: false,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trek = _trekC.trekDetailData.value;

    return Scaffold(
      backgroundColor: _Pay.bg,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Obx(() {
          final isCalcLoading = _trekC.calculateFareResponseModel.value.maybeWhen(
            loading: (_) => true,
            orElse: () => false,
          );

          final breakdown = _trekC.calculateFareResponseModel.value.maybeWhen(
            success: (r) => (r as CalculateFareResponseModel).breakdown,
            orElse: () => null,
          );

          final fareResponse = _trekC.calculateFareResponseModel.value.maybeWhen(
            success: (r) => r as CalculateFareResponseModel,
            orElse: () => null,
          );

          final fareReq = _trekC.calculateFareRequestModel.value;

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 4.w,
                  right: 4.w,
                  top: 2.h,
                  bottom: 16.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTrekSummaryCard(trek, fareReq, fareResponse),
                    SizedBox(height: 2.h),
                    _buildTravellerDetailsCard(),
                    SizedBox(height: 2.h),
                    _buildFareBreakdownCard(breakdown, fareReq),
                    SizedBox(height: 2.h),
                    _buildCouponCard(fareReq, fareResponse),
                    SizedBox(height: 2.h),
                    _buildPaymentMethodCard(),
                    SizedBox(height: 2.h),
                    _buildSecurityNote(),
                  ],
                ),
              ),
              if (isCalcLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.18),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _Pay.cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: _Pay.accent,
                              strokeWidth: 2.5,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Calculating fare…',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s11,
                                color: _Pay.inkMid,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _Pay.cardBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: _Pay.ink),
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _Pay.border),
      ),
      title: Text(
        'Payment',
        textScaler: const TextScaler.linear(1.0),
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s14,
          fontWeight: FontWeight.w700,
          color: _Pay.ink,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: _buildTimerAndProgress(),
        ),
      ],
    );
  }
}