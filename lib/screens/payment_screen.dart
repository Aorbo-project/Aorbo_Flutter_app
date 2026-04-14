import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sizer/sizer.dart';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/main.dart';
import 'package:arobo_app/utils/booking_constants.dart';
import 'package:arobo_app/utils/common_btn.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:arobo_app/utils/total_fare_modal.dart';
import 'package:arobo_app/widgets/slot_booking_details_modal.dart';

/// Payment screen for trek bookings
/// Handles payment method selection, coupon application, and order processing
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final TrekController _trekControllerC = Get.find<TrekController>();
  final UserController _userC = Get.find<UserController>();

  // Coupon related state
  final TextEditingController _couponController = TextEditingController();
  bool _isCouponValid = false;
  String? _couponError;
  double _discountAmount = 0.0;
  bool _isCouponSectionExpanded = true;

  // UI State
  String? _selectedUPIOption;

  // Data from traveller information screen
  String _totalAmount = '0';
  int _adultCount = BookingConstants.defaultAdultCount;
  String _selectedPaymentOption = BookingConstants.partialPayment;
  String _selectedInsuranceOption = BookingConstants.addInsurance;
  bool _freeCancellation = false;

  // Fare breakdown data (used in calculations)
  double _vendorDiscount = 0.0;
  double _platformFee = BookingConstants.platformFee;
  double _gst = 0.0;

  // Calculated fare components (used in calculations)
  double _totalBaseFare = 0.0;
  double _finalPayable = 0.0;

  // Partial payment amounts
  double _advanceAmount = 0.0;
  double _remainingAmount = 0.0;

  // Payment processing
  late Razorpay _razorpay;

  /// Opens Razorpay payment gateway with calculated amount and order details
  void _openRazorpay() async {
    // Calculate the exact final amount using the same logic as TotalFareModal
    final finalAmount = _calculateExactFinalAmount();

    // Calculate components for debug logging (same logic as _calculateExactFinalAmount)
    final insuranceFee = _selectedInsuranceOption == BookingConstants.addInsurance
        ? (BookingConstants.insuranceFeePerPerson * _adultCount)
        : 0.0;
    final cancellationFee = _freeCancellation
        ? (BookingConstants.cancellationFeePerPerson * _adultCount)
        : 0.0;

    // Calculate NET FARE for GST calculation (per Payment.md COUP-041)
    // Coupon discount applies to both partial and full payment
    double netFare = _totalBaseFare - _vendorDiscount - _discountAmount;
    final calculatedGst = netFare * BookingConstants.gstRate;

    // Get remaining amount for debugging
    final remainingAmount = _calculateRemainingAmount();

    var options = {
      'key': BookingConstants.razorpayKey,
      'order_id': '${_trekControllerC.orderData.value.id}',
      'amount': (finalAmount * 100).toInt(), // Razorpay expects amount in paise
      'name': '${_trekControllerC.trekDetailData.value.title}',
      'description': '${_trekControllerC.trekDetailData.value.description}',
      'prefill': {
        'contact': '${_userC.userProfileData.value.customer?.phone}',
        'email': '${_userC.userProfileData.value.customer?.email}',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      CustomSnackBar.show(context, message: 'Failed to open payment: ${e.toString()}');
    }
  }

  /// Handles successful payment response from Razorpay
  /// Updates trek controller and verifies the order
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _trekControllerC.orderId.value = response.orderId ?? '';
    _trekControllerC.paymentId.value = response.paymentId ?? '';
    _trekControllerC.signature.value = response.signature ?? '';

    // Build fare breakup for API
    final fareBreakup = _buildFareBreakup();

    await _trekControllerC.verifyTrekOrder(
      selectedPaymentOption: _selectedPaymentOption,
      fareBreakup: fareBreakup,
    );
    // CustomSnackBar.show(context, message: 'Payment Successful!');
  }

  /// Handles payment failure and shows error message to user
  void _handlePaymentError(PaymentFailureResponse response) {
    CustomSnackBar.show(
      context,
      message: 'Payment Failed! ${response.message}',
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    CustomSnackBar.show(
      context,
      message: 'You have chosen to pay via ${response.walletName}. It may take some time to reflect.',
    );
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _couponController.addListener(_handleTextChange);

    // Get arguments from previous screen
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      // Basic booking info
      _totalAmount = arguments['totalAmount'] ?? '0';
      _adultCount = arguments['adultCount'] ?? 1;
      _selectedPaymentOption =
          arguments['selectedPaymentOption'] ?? BookingConstants.partialPayment;
      _selectedInsuranceOption =
          arguments['selectedInsuranceOption'] ?? BookingConstants.addInsurance;
      _freeCancellation = arguments['freeCancellation'] ?? false;

      // Calculated fare components (only store what's needed for calculations)
      _totalBaseFare = arguments['totalBaseFare'] ?? 0.0;
      _vendorDiscount = arguments['vendorDiscount'] ?? 0.0;
      _platformFee = arguments['platformFee'] ?? BookingConstants.platformFee;
      _gst = arguments['gst'] ?? 0.0;
      _finalPayable = arguments['finalPayable'] ?? 0.0;

      // Partial payment specific
      _advanceAmount = arguments['advanceAmount'] ?? 0.0;
      _remainingAmount = arguments['remainingAmount'] ?? 0.0;

    } else {
      // Fallback to controller values if no arguments
      _adultCount = _trekControllerC.trekPersonCount.value;
      _totalAmount = _trekControllerC.totalAmount.value.toString();
    }

    // Check if coupon is already applied in controller and restore it to UI
    if (_trekControllerC.appliedCouponCode.value.isNotEmpty) {
      _couponController.text = _trekControllerC.appliedCouponCode.value;
      _isCouponValid = true;
      _couponError = null;
      _discountAmount = _trekControllerC.discountAmount.value;
    }
  }

  @override
  void dispose() {
    _couponController.removeListener(_handleTextChange);
    _couponController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _handleTextChange() {
    setState(() {
      // This will trigger a rebuild
    });
  }

  /// Validates the entered coupon code with the API
  Future<void> _validateCouponWithAPI() async {
    if (_couponController.text.isEmpty) {
      setState(() {
        _couponError = 'Please enter a coupon code';
      });
      return;
    }

    // Get the base amount for validation
    final basePricePerPerson = double.parse(
      _trekControllerC.trekDetailData.value.basePrice ?? "0.0",
    );
    final baseAmount =
        basePricePerPerson * _trekControllerC.trekPersonCount.value;
    final customerId = sp!.getInt(SpUtil.userID) ?? 0;

    if (baseAmount <= 0) {
      setState(() {
        _couponError = 'Unable to validate coupon. Invalid trek amount.';
      });
      return;
    }

    if (customerId <= 0) {
      setState(() {
        _couponError = 'Unable to validate coupon. User not found.';
      });
      return;
    }

    try {
      final isValid = await _trekControllerC.validateCoupon(
        couponCode: _couponController.text,
        customerId: customerId,
        baseAmount: baseAmount,
      );

      setState(() {
        if (isValid) {
          _isCouponValid = true;
          _couponError = null;
          _discountAmount = _trekControllerC.discountAmount.value;
        } else {
          _isCouponValid = false;
          _discountAmount = 0.0;
          _couponError = BookingMessages.invalidCouponCode;
        }
      });
    } catch (e) {
      setState(() {
        _couponError = 'Failed to validate coupon. Please try again.';
        _isCouponValid = false;
        _discountAmount = 0.0;
      });
    }
  }

  /// Removes the currently applied coupon and resets coupon state
  void _removeCoupon() {
    setState(() {
      _couponController.clear();
      _isCouponValid = false;
      _discountAmount = 0.0;
      _couponError = null;
    });
    _trekControllerC.removeCoupon();
  }

  // Coupon section UI
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
              bottom: _isCouponSectionExpanded ? 2.4.h : 2.h,
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
                      "Coupon Code",
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
                          _isCouponSectionExpanded = !_isCouponSectionExpanded;
                        });
                      },
                      child: AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: _isCouponSectionExpanded ? 0 : 0.5,
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
                  crossFadeState: _isCouponSectionExpanded
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
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final result = await Get.toNamed(
                                    '/coupon-code',
                                  );
                                  if (result != null) {
                                    setState(() {
                                      _couponController.text = result
                                          .toString();
                                      // If coupon was validated in coupon screen, mark as valid
                                      if (_trekControllerC
                                              .appliedCouponCode
                                              .value
                                              .isNotEmpty &&
                                          _trekControllerC
                                                  .appliedCouponCode
                                                  .value ==
                                              result.toString()) {
                                        _isCouponValid = true;
                                        _couponError = null;
                                        _discountAmount = _trekControllerC
                                            .discountAmount
                                            .value;
                                      } else {
                                        // Reset coupon state if not validated
                                        _isCouponValid = false;
                                        _discountAmount = 0.0;
                                        _couponError = null;
                                      }
                                    });
                                  }
                                },
                                child: AbsorbPointer(
                                  child: TextField(
                                    controller: _couponController,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    decoration: InputDecoration(
                                      hintText: BookingMessages.enterCouponCode,
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: FontSize.s11,
                                        color: CommonColors.blackColor
                                            .withValues(alpha: 0.3),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                        vertical: 1.5.h,
                                      ),
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s11,
                                      color: CommonColors.blackColor,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        // Reset coupon state when text changes
                                        _isCouponValid = false;
                                        _discountAmount = 0.0;
                                        _couponError = null;
                                        if (value != value.toUpperCase()) {
                                          _couponController.value =
                                              _couponController.value.copyWith(
                                                text: value.toUpperCase(),
                                                selection:
                                                    TextSelection.collapsed(
                                                      offset: value.length,
                                                    ),
                                              );
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: _isCouponValid
                                    ? CommonColors.btnGradient
                                    : (_couponController.text.isNotEmpty
                                          ? CommonColors.btnGradient
                                          : CommonColors.disableBtnGradient),
                                borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(3.w),
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _isCouponValid
                                      ? () {
                                          _removeCoupon();
                                        }
                                      : (_couponController.text.isNotEmpty
                                            ? () async {
                                                await _validateCouponWithAPI();
                                              }
                                            : null),
                                  borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(3.w),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 1.5.h,
                                    ),
                                    child: Text(
                                      _isCouponValid
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
                        ),
                      ),
                      if (_couponError != null) ...[
                        SizedBox(height: 1.h),
                        Padding(
                          padding: EdgeInsets.only(left: 1.w),
                          child: Text(
                            _couponError!,
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
                  secondChild: SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build UPI option
  Widget _buildUPIOption({
    required String icon,
    required String title,
    required bool isSelected,
    required Function() onTap,
  }) {
    Widget iconWidget;

    // Create icon widget based on icon type using SVG from CommonImages
    switch (icon) {
      case PaymentMethods.razorpay:
        iconWidget = Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: Color(0xFF3395FF),
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Center(
            child: Text(
              'R',
              style: GoogleFonts.poppins(
                fontSize: FontSize.s11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
        break;
      case 'phonepe':
        iconWidget = SvgPicture.asset(
          CommonImages.phonePeIcon,
          width: 10.w,
          height: 10.w,
        );
        break;
      case 'paytm':
        iconWidget = SvgPicture.asset(
          CommonImages.paytmIcon,
          width: 10.w,
          height: 10.w,
        );
        break;
      case 'whatsapp':
        iconWidget = SvgPicture.asset(
          CommonImages.whatsappIcon,
          width: 10.w,
          height: 10.w,
        );
        break;
      default:
        iconWidget = Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: CommonColors.greyColor,
            borderRadius: BorderRadius.circular(2.w),
          ),
        );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.w),
        child: Row(
          children: [
            iconWidget,
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s11,
                  fontWeight: FontWeight.w500,
                  color: CommonColors.blackColor,
                ),
              ),
            ),
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? CommonColors.blueColor
                      : CommonColors.greyColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 3.w,
                        height: 3.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CommonColors.blueColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build add new UPI option
  Widget _buildAddNewUPIOption() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.w),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: CommonColors.lightBlueColor,
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Center(
              child: SvgPicture.asset(
                CommonImages.bhimIcon,
                width: 6.w,
                height: 6.w,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New UPI ID',
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s11,
                    fontWeight: FontWeight.w500,
                    color: CommonColors.blackColor,
                  ),
                ),
                Text(
                  'You need to have a registered UPI ID',
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s7,
                    fontWeight: FontWeight.w400,
                    color: CommonColors.blackColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: CommonColors.blackColor,
            size: 6.w,
          ),
        ],
      ),
    );
  }

  // Helper method to build payment option (for cards, wallets, netbanking)
  Widget _buildPaymentOption({required String icon, required String title}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.w),
      child: Row(
        children: [
          SvgPicture.asset(icon, width: 10.w, height: 10.w),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: FontSize.s11,
                fontWeight: FontWeight.w500,
                color: CommonColors.blackColor,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: CommonColors.blackColor, size: 6.w),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final travelData = _trekControllerC.trekDetailData.value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CommonColors.whiteColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: CommonColors.blackColor),
        titleSpacing: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: CommonColors.greyColor, height: 1.5),
        ),
        title: Text(
          'Payment',
          textScaler: const TextScaler.linear(1.0),
          style: GoogleFonts.poppins(
            fontSize: FontSize.s11,
            fontWeight: FontWeight.w600,
            color: CommonColors.blackColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            top: 20,
            bottom: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Review Booking Section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Review booking",
                            textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s14,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.blackColor,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => SlotBookingDetailsModal(
                                trekName: travelData.title ?? '-',
                                adultCount: _adultCount,
                                fromLocation:
                                    _dashboardC.fromController.value.text,
                                toLocation: _dashboardC.toController.value.text,
                                departureDate:
                                    travelData.batchInfo?.startDate ?? '-',
                                duration:
                                    '${travelData.durationDays}D ${travelData.durationNights}N',
                                email:
                                    _userC
                                        .userProfileData
                                        .value
                                        .customer
                                        ?.email ??
                                    '-',
                                phone:
                                    _userC
                                        .userProfileData
                                        .value
                                        .customer
                                        ?.phone ??
                                    '-',
                                travellers: _getTravellerDetails(),
                                baseAmount: _totalBaseFare,
                                discountAmount:
                                    _vendorDiscount + _discountAmount,
                                isInsurance:
                                    _selectedInsuranceOption ==
                                    BookingConstants.addInsurance,
                                isFreeCancellation: _freeCancellation,
                                // Partial payment specific values
                                isPartialPayment:
                                    _selectedPaymentOption ==
                                    BookingConstants.partialPayment,
                                advanceAmount: _advanceAmount,
                                remainingAmount: _calculateRemainingAmount(),
                                finalPayable: _finalPayable,
                                gst: _gst,
                              ),
                            );
                          },
                          child: Text(
                            'View details',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s10,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.blueColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Text(
                          "$_adultCount Traveller:",
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s9,
                            fontWeight: FontWeight.w600,
                            color: CommonColors.blackColor,
                          ),
                        ),
                        Text(
                          " $_adultCount Adults/ From ${_dashboardC.fromController.value.text}",
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s9,
                            fontWeight: FontWeight.w300,
                            color: CommonColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _dashboardC.fromController.value.text,
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s9,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.blackColor,
                              ),
                            ),
                            Text(
                              travelData.batchInfo?.startDate ?? '-',
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s9,
                                fontWeight: FontWeight.w400,
                                color: CommonColors.blackColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 3.w),
                        Icon(
                          Icons.arrow_right_alt,
                          size: 5.w,
                          color: CommonColors.grey_AEAEAE,
                        ),
                        SizedBox(width: 3.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _dashboardC.toController.value.text,
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s9,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.blackColor,
                              ),
                            ),
                            Text(
                              _calculateEndDate(
                                travelData.batchInfo?.startDate,
                                travelData.durationDays,
                              ),
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s9,
                                fontWeight: FontWeight.w400,
                                color: CommonColors.blackColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),

              // Coupon Code Section (Available for both partial and full payment per Payment.md)
              _buildCouponSection(),
              SizedBox(height: 3.h),

              // UPI Payment Section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: 100.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.w),
                  boxShadow: [
                    BoxShadow(
                      color: CommonColors.blackColor.withValues(alpha: 0.2),
                      offset: Offset(2, 2),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                  color: CommonColors.offWhiteColor2,
                ),
                child: Container(
                  width: 100.w,
                  margin: EdgeInsets.only(
                    left: 4.w,
                    right: 4.w,
                    top: 1.8.h,
                    bottom: 1.8.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UPI',
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.alexandria(
                          fontSize: FontSize.s14,
                          fontWeight: FontWeight.w500,
                          color: CommonColors.blackColor,
                        ),
                      ),
                      SizedBox(height: 2.h),

                      // Razorpay
                      _buildUPIOption(
                        icon: PaymentMethods.razorpay,
                        title: 'Razorpay',
                        isSelected:
                            _selectedUPIOption == PaymentMethods.razorpay,
                        onTap: () {
                          setState(() {
                            _selectedUPIOption =
                                _selectedUPIOption == PaymentMethods.razorpay
                                ? null
                                : PaymentMethods.razorpay;
                          });
                        },
                      ),
                      // Separator
                      Container(
                        height: 1,
                        color: CommonColors.greyColor.withValues(alpha: 0.3),
                        margin: EdgeInsets.symmetric(vertical: 1.h),
                      ),

                      // PhonePe UPI (Locked)
                      Stack(
                        children: [
                          Opacity(
                            opacity: 0.5,
                            child: _buildUPIOption(
                              icon: 'phonepe',
                              title: 'Phonepe UPI',
                              isSelected: false,
                              onTap: () {}, // Disabled
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: CommonColors.whiteColor.withValues(
                                  alpha: 0.9,
                                ),
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.lock_outline,
                                  size: 5.w,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Separator
                      Container(
                        height: 1,
                        color: CommonColors.greyColor.withValues(alpha: 0.3),
                        margin: EdgeInsets.symmetric(vertical: 1.h),
                      ),

                      // Paytm UPI (Locked)
                      Stack(
                        children: [
                          Opacity(
                            opacity: 0.5,
                            child: _buildUPIOption(
                              icon: 'paytm',
                              title: 'Paytm UPI',
                              isSelected: false,
                              onTap: () {}, // Disabled
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.lock_outline,
                                  size: 5.w,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Separator
                      Container(
                        height: 1,
                        color: CommonColors.greyColor.withValues(alpha: 0.3),
                        margin: EdgeInsets.symmetric(vertical: 1.h),
                      ),

                      // WhatsApp UPI (Locked)
                      Stack(
                        children: [
                          Opacity(
                            opacity: 0.5,
                            child: _buildUPIOption(
                              icon: 'whatsapp',
                              title: 'WhatsApp UPI',
                              isSelected: false,
                              onTap: () {}, // Disabled
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.lock_outline,
                                  size: 5.w,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Separator
                      Container(
                        height: 1,
                        color: CommonColors.greyColor.withValues(alpha: 0.3),
                        margin: EdgeInsets.symmetric(vertical: 1.h),
                      ),

                      // Add New UPI ID (Locked)
                      Stack(
                        children: [
                          Opacity(opacity: 0.5, child: _buildAddNewUPIOption()),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.lock_outline,
                                  size: 5.w,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 3.h),

              // Other Payment Methods Section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: 100.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.w),
                  boxShadow: [
                    BoxShadow(
                      color: CommonColors.blackColor.withValues(alpha: 0.2),
                      offset: Offset(2, 2),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                  color: CommonColors.offWhiteColor2,
                ),
                child: Container(
                  width: 100.w,
                  margin: EdgeInsets.only(
                    left: 4.w,
                    right: 4.w,
                    top: 1.8.h,
                    bottom: 1.8.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add New Card (Locked)
                      Stack(
                        children: [
                          Opacity(
                            opacity: 0.5,
                            child: _buildPaymentOption(
                              icon: CommonImages.cardIcon,
                              title: 'Add New Card',
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.lock_outline,
                                  size: 5.w,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Separator
                      Container(
                        height: 1,
                        color: CommonColors.greyColor.withValues(alpha: 0.3),
                        margin: EdgeInsets.symmetric(vertical: 1.h),
                      ),

                      // Wallets (Locked)
                      Stack(
                        children: [
                          Opacity(
                            opacity: 0.5,
                            child: _buildPaymentOption(
                              icon: CommonImages.walletIcon,
                              title: 'Wallets',
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.lock_outline,
                                  size: 5.w,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Separator
                      Container(
                        height: 1,
                        color: CommonColors.greyColor.withValues(alpha: 0.3),
                        margin: EdgeInsets.symmetric(vertical: 1.h),
                      ),

                      // Netbanking (Locked)
                      Stack(
                        children: [
                          Opacity(
                            opacity: 0.5,
                            child: _buildPaymentOption(
                              icon: CommonImages.bankIcon,
                              title: 'Netbanking',
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.lock_outline,
                                  size: 5.w,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 2.h),
            // Fare Breakup Modal Button
            Container(
              margin: const EdgeInsets.only(left: 27, right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => TotalFareModal(
                          baseAmount: _totalBaseFare,
                          isPartialPayment:
                              _selectedPaymentOption ==
                              BookingConstants.partialPayment,
                          isInsurance:
                              _selectedInsuranceOption ==
                              BookingConstants.addInsurance,
                          isFreeCancellation: _freeCancellation,
                          adultCount: _adultCount,
                          onClose: () => Navigator.pop(context),
                          vendorDiscount: _vendorDiscount,
                          couponDiscount: _discountAmount,
                          platformFee: _platformFee,
                          gst: _gst,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              BookingMessages.totalFare,
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s9,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.blackColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 24,
                              color: CommonColors.blackColor,
                            ),
                          ],
                        ),
                        Text(
                          BookingMessages.taxIncluded,
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s8,
                            fontWeight: FontWeight.w300,
                            color: CommonColors.blackColor.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        textScaler: const TextScaler.linear(1.0),
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '₹ ',
                              style: GoogleFonts.roboto(
                                fontSize: FontSize.s15,
                                fontWeight: FontWeight.w600,
                                color: CommonColors.softGreen2,
                              ),
                            ),
                            TextSpan(
                              text: _calculateTotalFare(),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s15,
                                fontWeight: FontWeight.w600,
                                color: CommonColors.softGreen2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Padding(
              padding: const EdgeInsets.only(left: 41, right: 41, bottom: 20),
              child: CommonButton(
                text: BookingMessages.payNow,
                fontSize: FontSize.s14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                onPressed: () async {
                  if (_isPaymentValid) {
                    // Calculate values for API
                    final remainingAmount = _calculateRemainingAmount();
                    final finalAmount = _calculateExactFinalAmount();

                    // Set the correct final amount in TrekController before creating order
                    _trekControllerC.totalAmount.value = finalAmount;

                    await _trekControllerC.createTrekOrder(
                      selectedPaymentOption: _selectedPaymentOption,
                      remainingAmount: remainingAmount,
                      finalAmount: finalAmount,
                    );
                    if (_trekControllerC.orderModal.value.success ?? false) {
                      _handlePayment();
                    }
                  }
                },
                gradient: _isPaymentValid
                    ? CommonColors.filterGradient
                    : CommonColors.disableBtnGradient,
                textColor: CommonColors.whiteColor,
                height: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Calculates the exact final amount to be charged to Razorpay
  ///
  /// Per Payment.md Policy:
  /// - PARTIAL PAYMENT: Advance + Platform Fee + GST + Add-ons (Pay Now amount)
  /// - FULL PAYMENT: Complete final amount
  ///
  /// Payment.md BASE-001 Example (1 Adult, ₹5,999 fare, no discounts, partial):
  /// - Net Fare: ₹5,999
  /// - Advance: ₹999
  /// - Platform Fee: ₹15
  /// - GST: ₹299.95 (5% of Net Fare)
  /// - Pay Now: ₹999 + ₹15 + ₹299.95 = ₹1,313.95 ✓
  /// - Balance Later: ₹5,999 - ₹999 = ₹5,000 (paid before trek start)
  ///
  /// Payment.md COUP-041 Example (1 Adult, ₹5,999 fare, ₹500 coupon, partial):
  /// - Net Fare: ₹5,499
  /// - Advance: ₹999
  /// - Platform Fee: ₹15
  /// - GST: ₹274.95 (5% of ₹5,499)
  /// - Pay Now: ₹999 + ₹15 + ₹274.95 = ₹1,288.95 ✓
  /// - Balance Later: ₹5,499 - ₹999 = ₹4,500 (paid before trek start)
  ///
  /// CRITICAL GST COMPLIANCE:
  /// ========================
  /// GST is calculated on NET FARE (taxable base after all discounts) ONLY
  /// NOT on (Net Fare + Platform Fee)
  /// Reference: Payment.md lines 64, 118-119, 134-138
  ///
  /// @returns double - Amount in rupees to charge via Razorpay
  double _calculateExactFinalAmount() {
    // === STEP 1: Calculate Add-on Fees ===
    // Insurance fee (₹80 per person, non-refundable)
    final insuranceFee =
        _selectedInsuranceOption == BookingConstants.addInsurance
        ? (BookingConstants.insuranceFeePerPerson * _adultCount)
        : 0.0;

    // Free Cancellation fee (₹90 per person)
    final cancellationFee = _freeCancellation
        ? (BookingConstants.cancellationFeePerPerson * _adultCount)
        : 0.0;

    // === STEP 2: Calculate Advance Payment Amount ===
    // For partial payment: ₹999 per person
    final totalPartialPayment =
        BookingConstants.partialPaymentPerPerson * _adultCount;

    // === STEP 3: Calculate NET FARE (Taxable Base) ===
    // Following Payment.md legal requirements:
    // GST is calculated on NET FARE (after discounts, BEFORE platform fee)

    // 3a. Start with total base fare
    double netFare = _totalBaseFare;

    // 3b. Subtract vendor discount (always applied)
    netFare -= _vendorDiscount;

    // 3c. Subtract coupon discount (for both partial and full payment per Payment.md COUP-041)
    // Coupon reduces Net Fare, which reduces GST and Balance Later
    netFare -= _discountAmount;

    // === STEP 4: Calculate GST (CRITICAL - Per Payment.md Legal Requirements) ===
    // GST = 5% × Net Fare ONLY
    // NOT: GST = 5% × (Net Fare + Platform Fee)
    //
    // Why? Per Indian GST law and Payment.md policy:
    // - GST is only on the trek service value (Net Fare)
    // - Platform Fee is a separate service charge
    // - Discounts reduce the taxable value before GST
    //
    // Reference: Payment.md lines 64, 118-119, 134-138
    final calculatedGst = netFare * BookingConstants.gstRate;

    // === STEP 5: Calculate Complete Final Amount ===
    // Final Amount = Net Fare + Platform Fee + GST + Insurance + Free Cancellation
    double amount = netFare;
    amount += _platformFee;
    amount += calculatedGst;
    amount += insuranceFee;
    amount += cancellationFee;

    // === STEP 6: Return Amount Based on Payment Option ===
    // Per Payment.md Policy:
    // PARTIAL PAYMENT: Advance + Platform Fee + GST + Add-ons (NOT just advance!)
    // FULL PAYMENT: Complete amount
    final totalAmount =
        _selectedPaymentOption == BookingConstants.partialPayment
        ? (totalPartialPayment + _platformFee + calculatedGst + insuranceFee + cancellationFee)
        : amount;

    return totalAmount;
  }

  /// Calculates the remaining amount to be paid later (for partial payment)
  ///
  /// Per Payment.md Policy:
  /// - FULL PAYMENT: Remaining = 0
  /// - PARTIAL PAYMENT: Remaining = Net Fare - Advance Payment
  ///
  /// Where Net Fare = Base Fare - Vendor Discount - Coupon Discount
  ///
  /// @returns double - Remaining amount in rupees
  double _calculateRemainingAmount() {
    // For full payment, remaining amount is always 0
    if (_selectedPaymentOption != BookingConstants.partialPayment) {
      return 0.0;
    }

    // For partial payment, calculate: Net Fare - Advance
    // Net Fare = Base Fare - All Discounts
    double netFare = _totalBaseFare;
    netFare -= _vendorDiscount;
    netFare -= _discountAmount;

    // Advance payment amount
    final totalPartialPayment =
        BookingConstants.partialPaymentPerPerson * _adultCount;

    // Remaining = Net Fare - Advance
    final remaining = netFare - totalPartialPayment;

    // Ensure remaining is not negative
    return remaining > 0 ? remaining : 0.0;
  }

  /// Builds the complete fare breakup object for API requests
  ///
  /// All values are calculated dynamically based on current state:
  /// - totalBasicCost: Base fare for all travelers
  /// - vendorDiscount: Discount from trek vendor
  /// - couponDiscount: Discount from applied coupon (both partial and full)
  /// - couponId: ID of applied coupon (empty if none)
  /// - platformFees: Fixed platform fee (₹15)
  /// - gst: 5% on Net Fare (after all discounts)
  /// - insurance: ₹80 per person if selected
  /// - freeCancellation: ₹90 per person if selected
  /// - remainingAmount: Balance to pay later (0 for full payment)
  /// - finalAmount: Amount charged to Razorpay
  ///
  /// @returns Map<String, dynamic> - Complete fare breakup for API
  Map<String, dynamic> _buildFareBreakup() {
    // Calculate add-on fees dynamically
    final insuranceFee = _selectedInsuranceOption == BookingConstants.addInsurance
        ? (BookingConstants.insuranceFeePerPerson * _adultCount)
        : 0.0;

    final freeCancellationFee = _freeCancellation
        ? (BookingConstants.cancellationFeePerPerson * _adultCount)
        : 0.0;

    // Calculate Net Fare (after all discounts)
    double netFare = _totalBaseFare - _vendorDiscount - _discountAmount;

    // Calculate GST (5% on Net Fare only, per Payment.md)
    final calculatedGst = netFare * BookingConstants.gstRate;

    // Get remaining amount dynamically
    final remainingAmount = _calculateRemainingAmount();

    // Get final amount (what's charged to Razorpay)
    final finalAmount = _calculateExactFinalAmount();

    return {
      "totalBasicCost": _totalBaseFare,
      "vendorDiscount": _vendorDiscount,
      "couponDiscount": _discountAmount,
      "couponId": _trekControllerC.appliedCouponId.value,
      "platformFees": _platformFee,
      "gst": calculatedGst,
      "insurance": insuranceFee,
      "freeCancellation": freeCancellationFee,
      "remainingAmount": remainingAmount,
      "finalAmount": finalAmount,
    };
  }

  /// Returns the total fare as a formatted string for UI display
  /// This should match the exact final amount calculation
  String _calculateTotalFare() {
    // Use the exact final amount calculation
    return _calculateExactFinalAmount().toStringAsFixed(0);
  }

  // Method to get complete fare breakdown for debugging
  //   String _getFareBreakdownDebug() {
  //     return '''
  // Fare Breakdown Debug:
  // ====================
  // Base Price: $_basePrice
  // Adult Count: $_adultCount
  // Base Fare: $_baseFare
  // Total Base Fare: $_totalBaseFare
  // Has Discount: $_hasDiscount
  // Discount Type: $_discountType
  // Discount Value: $_discountValue
  // Vendor Discount: $_vendorDiscount
  // Fare After Vendor Discount: $_farePriceAfterVendorDiscount
  // Coupon Discount: $_couponDiscount
  // Net Fare: $_netFare
  // Platform Fee: $_platformFee
  // Subtotal: $_subtotal
  // GST: $_gst
  // Insurance Fee: $_insuranceFee
  // Cancellation Fee: $_cancellationFee
  // Final Payable: $_finalPayable
  // Payment Option: $_selectedPaymentOption
  // Advance Amount: $_advanceAmount
  // Remaining Amount: $_remainingAmount
  // Total Amount: $_totalAmount
  // ''';
  //   }

  /// Validates if payment can proceed
  /// Currently requires Razorpay to be selected
  bool get _isPaymentValid {
    // For now, require Razorpay to be selected
    return _selectedUPIOption == PaymentMethods.razorpay;
  }

  /// Gets traveller details from trek controller for display in modals
  /// Returns list of traveller information with controllers for editing
  List<Map<String, dynamic>> _getTravellerDetails() {
    // Get selected travellers from trek controller
    final selectedTravellers = _trekControllerC.travellerDetailList;

    if (selectedTravellers.isNotEmpty) {
      // Return existing travellers
      return selectedTravellers
          .map(
            (traveller) => {
              'nameController': TextEditingController(
                text: traveller.name ?? '',
              ),
              'ageController': TextEditingController(
                text: traveller.age?.toString() ?? '',
              ),
              'gender': traveller.gender ?? '',
            },
          )
          .toList();
    } else {
      // Return default traveller if none selected
      return [
        {
          'nameController': TextEditingController(text: 'Traveller'),
          'ageController': TextEditingController(text: '18'),
          'gender': 'Male',
        },
      ];
    }
  }

  /// Calculates the end date based on start date and duration
  /// Start date is considered Day 0 (travel day)
  /// For 5D/4N trek starting on 10th: Day 0=10th, Days 1-4=11th-14th, ends on 15th
  String _calculateEndDate(String? startDate, int? durationDays) {
    if (startDate == null || startDate.isEmpty || durationDays == null) {
      return '-';
    }

    try {
      // Parse start date (format: YYYY-MM-DD)
      DateTime start = DateTime.parse(startDate);

      // Add duration days to get end date
      // Start date is Day 0, so for 5D trek, we add 5 days
      DateTime end = start.add(Duration(days: durationDays));

      // Format as YYYY-MM-DD to match backend format
      String day = end.day.toString().padLeft(2, '0');
      String month = end.month.toString().padLeft(2, '0');
      String year = end.year.toString();

      return '$year-$month-$day';
    } catch (e) {
      return '-';
    }
  }

  /// Initiates the payment process by opening Razorpay
  void _handlePayment() {
    _openRazorpay();
  }
}
