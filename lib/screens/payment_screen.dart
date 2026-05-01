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

  String? _couponError = null;

  // Coupon related state
  final TextEditingController _couponController = TextEditingController();
  bool _isCouponSectionExpanded = true;

  // UI State
  String? _selectedUPIOption = PaymentMethods.razorpay;


  static const int _totalTimerSeconds = 5 * 60;
  RxInt _remainingSeconds = _totalTimerSeconds.obs;
  bool _isTimerExpired = false;
  Timer? _timer;

  // Payment processing
  late Razorpay _razorpay;


  /// Starts the countdown timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_remainingSeconds.value > 0) {
          _remainingSeconds.value--;
        }

        if (_remainingSeconds.value == 0) {
          _isTimerExpired = true;
          _timer?.cancel();
          _handleTimerExpired();
        }
      }
    });
  }

  /// Handles timer expiration - navigates back and shows message
  void _handleTimerExpired() {
    if (mounted) {
      // Show a snackbar message
      CustomSnackBar.show(
        context,
        message: 'Payment session timed out. Please start over.',
      );

      Get.back();
    }
  }

  /// Opens Razorpay payment gateway with calculated amount and order details
  void _openRazorpay(BreakDownDataModel? breakdown) async {
    // Calculate the exact final amount using the same logic as TotalFareModal
    final finalAmount = breakdown?.amountToPayNow;
    _razorpay.clear();

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

    print(options);

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

    print("Respose orderId  ${response.orderId ?? ''}");
    print("Respose paymentId  ${response.paymentId ?? ''}");
    print("Respose signature  ${response.signature ?? ''}");



    await _trekControllerC.verifyTrekOrder(
      razorpayOrderId: response.orderId ?? '',
      razorpayPaymentId: response.paymentId ?? '',
      razorpaySignature: response.signature ?? ''
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
    debounce(
      _trekControllerC.calculateFareRequestModel,
          (value) {
        // This will be called after 500ms of no changes
        print('Searching for: $value');
        _trekControllerC.calculateFare();
      },
      time: Duration(milliseconds: 500),
    );
    // _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _couponController.removeListener(_handleTextChange);
    _couponController.dispose();
    _razorpay.clear();
    super.dispose();
  }


  Widget _buildTimerAndProgress() {
    return Center(
      child: Obx((){
        int minutes = _remainingSeconds.value ~/ 60;
        int seconds = _remainingSeconds.value % 60;

        final _formattedTime = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        final _progressValue = _remainingSeconds.value / _totalTimerSeconds;

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
                    _formattedTime,
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
                value: _progressValue,
                backgroundColor: CommonColors.greyColor.withValues(alpha: 0.3),
                color: CommonColors.orangeColor,
                minHeight: 0.1.h,
                borderRadius: BorderRadius.circular(200),
              ),
            ),
          ],
        );
        },
      ),
    );
  }

  void _handleTextChange() {
    setState(() {
      // This will trigger a rebuild
    });
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
                        child: Obx((){
                          final appliedCoupon = _trekControllerC.calculateFareRequestModel.value.couponCode;
                          final appliedCouponResponse = _trekControllerC.calculateFareResponseModel.value.maybeWhen(success: (response) => (response as CalculateFareResponseModel).couponDetails,orElse: () => null);
                          final isCouponValid = appliedCouponResponse != null;

                          return appliedCoupon?.isEmpty == true ? InkWell(
                            onTap: (){
                              Get.to(() => CouponCodeScreen());
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.h),

                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: CommonColors.whiteColor,
                                        borderRadius: BorderRadius.circular(3.w),
                                        border: Border.all(
                                          color: CommonColors.profileColor,
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Enter Coupon Code",
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
                                        color: _couponController.text.isNotEmpty
                                            ? CommonColors.blueColor
                                            : const Color(0xff969696),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ) :
                            Row(
                              children: [
                                Expanded(child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    appliedCoupon ?? "",
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s11,
                                      color: const Color(0xff969696),
                                    ),
                                  ),
                                )),
                                Container(
                                decoration: BoxDecoration(
                                  gradient: isCouponValid
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
                                    onTap:(){
                                      if(isCouponValid == false){
                                        _trekControllerC.calculateFareRequestModel.value = _trekControllerC.calculateFareRequestModel.value.copyWith(couponCode: "");
                                      }
                                      else{
                                        _trekControllerC.calculateFareRequestModel.value = _trekControllerC.calculateFareRequestModel.value.copyWith(couponCode: "");
                                      }
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
                        },
                        ),
                      ),
                      if (_couponError != null) ...[
                        SizedBox(height: 1.h),
                        Padding(
                          padding: EdgeInsets.only(left: 1.w),
                          child: Text(
                            _couponError ?? "",
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
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTimerAndProgress(),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                  Obx(() {
                    final calculateFareRequestModel = _trekControllerC.calculateFareRequestModel.value;
                    BreakDownDataModel? breakdown = _trekControllerC.calculateFareResponseModel.value.maybeWhen(success: (response) => (response as CalculateFareResponseModel).breakdown,orElse: () => null);
                     return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SlotBookingDetailsModal(
                            trekName: travelData.title ?? '-',
                            adultCount: calculateFareRequestModel.travelerCount,
                            fromLocation: _dashboardC.fromController.value.text,
                            toLocation: _dashboardC.toController.value.text,
                            departureDate:
                            travelData?.startDate ?? '-',
                            duration:
                            '${travelData.durationDays}D ${travelData.durationNights}N',
                            email: _userC.userProfileData.value.customer?.email ?? '-',
                            phone: _userC.userProfileData.value.customer?.phone ?? '-',
                            travellers: _getTravellerDetails(),
                            breakdown: breakdown,
                            isPartialPayment:calculateFareRequestModel.cancellationPolicyType == "partial",
                          ),

                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Expanded(
                          //       child: Text(
                          //         "Review booking",
                          //         textScaler: const TextScaler.linear(1.0),
                          //         style: GoogleFonts.poppins(
                          //           fontSize: FontSize.s14,
                          //           fontWeight: FontWeight.w500,
                          //           color: CommonColors.blackColor,
                          //         ),
                          //       ),
                          //     ),
                          //     TextButton(
                          //       onPressed: () {
                          //         showModalBottomSheet(
                          //           context: context,
                          //           backgroundColor: Colors.transparent,
                          //           builder: (context) => SlotBookingDetailsModal(
                          //             trekName: travelData.title ?? '-',
                          //             adultCount: calculateFareRequestModel.travelerCount,
                          //             fromLocation:
                          //             _dashboardC.fromController.value.text,
                          //             toLocation: _dashboardC.toController.value.text,
                          //             departureDate:
                          //             travelData.batchInfo?.startDate ?? '-',
                          //             duration:
                          //             '${travelData.durationDays}D ${travelData.durationNights}N',
                          //             email: _userC.userProfileData.value.customer?.email ?? '-',
                          //             phone: _userC.userProfileData.value.customer?.phone ?? '-',
                          //             travellers: _getTravellerDetails(),
                          //             breakdown: breakdown,
                          //             isPartialPayment:calculateFareRequestModel.cancellationPolicyType == "partial",
                          //           ),
                          //         );
                          //       },
                          //       child: Text(
                          //         'View details',
                          //         style: GoogleFonts.poppins(
                          //           fontSize: FontSize.s10,
                          //           fontWeight: FontWeight.w500,
                          //           color: CommonColors.blueColor,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(height: 0.5.h),
                          // Row(
                          //   children: [
                          //     Text(
                          //       "${calculateFareRequestModel.travelerCount} Traveller:",
                          //       textScaler: const TextScaler.linear(1.0),
                          //       style: GoogleFonts.poppins(
                          //         fontSize: FontSize.s9,
                          //         fontWeight: FontWeight.w600,
                          //         color: CommonColors.blackColor,
                          //       ),
                          //     ),
                          //     Text(
                          //       " ${calculateFareRequestModel.travelerCount} Adults/ From ${_dashboardC.fromController.value.text}",
                          //       textScaler: const TextScaler.linear(1.0),
                          //       style: GoogleFonts.poppins(
                          //         fontSize: FontSize.s9,
                          //         fontWeight: FontWeight.w300,
                          //         color: CommonColors.blackColor,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(height: 2.h),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.start,
                          //   children: [
                          //     Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         Text(
                          //           _dashboardC.fromController.value.text,
                          //           textScaler: const TextScaler.linear(1.0),
                          //           style: GoogleFonts.poppins(
                          //             fontSize: FontSize.s9,
                          //             fontWeight: FontWeight.w500,
                          //             color: CommonColors.blackColor,
                          //           ),
                          //         ),
                          //         Text(
                          //           travelData.batchInfo?.startDate ?? '-',
                          //           textScaler: const TextScaler.linear(1.0),
                          //           style: GoogleFonts.poppins(
                          //             fontSize: FontSize.s9,
                          //             fontWeight: FontWeight.w400,
                          //             color: CommonColors.blackColor,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //     SizedBox(width: 3.w),
                          //     Icon(
                          //       Icons.arrow_right_alt,
                          //       size: 5.w,
                          //       color: CommonColors.grey_AEAEAE,
                          //     ),
                          //     SizedBox(width: 3.w),
                          //     Column(
                          //       crossAxisAlignment: CrossAxisAlignment.end,
                          //       children: [
                          //         Text(
                          //           _dashboardC.toController.value.text,
                          //           textScaler: const TextScaler.linear(1.0),
                          //           style: GoogleFonts.poppins(
                          //             fontSize: FontSize.s9,
                          //             fontWeight: FontWeight.w500,
                          //             color: CommonColors.blackColor,
                          //           ),
                          //         ),
                          //         Text(
                          //           _calculateEndDate(
                          //             travelData.batchInfo?.startDate,
                          //             travelData.durationDays,
                          //           ),
                          //           textScaler: const TextScaler.linear(1.0),
                          //           style: GoogleFonts.poppins(
                          //             fontSize: FontSize.s9,
                          //             fontWeight: FontWeight.w400,
                          //             color: CommonColors.blackColor,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    );
                     },
                  ),
                  SizedBox(height: 3.h),

                  // Coupon Code Section (Available for both partial and full payment per Payment.md)
                  _buildCouponSection(),
                  SizedBox(height: 3.h),

                  // // UPI Payment Section
                  // Container(
                  //   margin: EdgeInsets.symmetric(horizontal: 4.w),
                  //   width: 100.w,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(5.w),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: CommonColors.blackColor.withValues(alpha: 0.2),
                  //         offset: Offset(2, 2),
                  //         blurRadius: 6,
                  //         spreadRadius: 2,
                  //       ),
                  //     ],
                  //     color: CommonColors.offWhiteColor2,
                  //   ),
                  //   child: Container(
                  //     width: 100.w,
                  //     margin: EdgeInsets.only(
                  //       left: 4.w,
                  //       right: 4.w,
                  //       top: 1.8.h,
                  //       bottom: 1.8.h,
                  //     ),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           'UPI',
                  //           textScaler: const TextScaler.linear(1.0),
                  //           style: GoogleFonts.alexandria(
                  //             fontSize: FontSize.s14,
                  //             fontWeight: FontWeight.w500,
                  //             color: CommonColors.blackColor,
                  //           ),
                  //         ),
                  //         SizedBox(height: 2.h),
                  //
                  //         // Razorpay
                  //         _buildUPIOption(
                  //           icon: PaymentMethods.razorpay,
                  //           title: 'Razorpay',
                  //           isSelected:
                  //           _selectedUPIOption == PaymentMethods.razorpay,
                  //           onTap: () {
                  //             setState(() {
                  //               _selectedUPIOption =
                  //               _selectedUPIOption == PaymentMethods.razorpay
                  //                   ? null
                  //                   : PaymentMethods.razorpay;
                  //             });
                  //           },
                  //         ),
                  //         // Separator
                  //         Container(
                  //           height: 1,
                  //           color: CommonColors.greyColor.withValues(alpha: 0.3),
                  //           margin: EdgeInsets.symmetric(vertical: 1.h),
                  //         ),
                  //
                  //         // PhonePe UPI (Locked)
                  //         Stack(
                  //           children: [
                  //             Opacity(
                  //               opacity: 0.5,
                  //               child: _buildUPIOption(
                  //                 icon: 'phonepe',
                  //                 title: 'Phonepe UPI',
                  //                 isSelected: false,
                  //                 onTap: () {}, // Disabled
                  //               ),
                  //             ),
                  //             Positioned.fill(
                  //               child: Container(
                  //                 decoration: BoxDecoration(
                  //                   color: CommonColors.whiteColor.withValues(
                  //                     alpha: 0.9,
                  //                   ),
                  //                   borderRadius: BorderRadius.circular(2.w),
                  //                 ),
                  //                 child: Center(
                  //                   child: Icon(
                  //                     Icons.lock_outline,
                  //                     size: 5.w,
                  //                     color: CommonColors.blackColor,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //         // Separator
                  //         Container(
                  //           height: 1,
                  //           color: CommonColors.greyColor.withValues(alpha: 0.3),
                  //           margin: EdgeInsets.symmetric(vertical: 1.h),
                  //         ),
                  //
                  //         // Paytm UPI (Locked)
                  //         Stack(
                  //           children: [
                  //             Opacity(
                  //               opacity: 0.5,
                  //               child: _buildUPIOption(
                  //                 icon: 'paytm',
                  //                 title: 'Paytm UPI',
                  //                 isSelected: false,
                  //                 onTap: () {}, // Disabled
                  //               ),
                  //             ),
                  //             Positioned.fill(
                  //               child: Container(
                  //                 decoration: BoxDecoration(
                  //                   color: Colors.white.withValues(alpha: 0.7),
                  //                   borderRadius: BorderRadius.circular(2.w),
                  //                 ),
                  //                 child: Center(
                  //                   child: Icon(
                  //                     Icons.lock_outline,
                  //                     size: 5.w,
                  //                     color: CommonColors.blackColor,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //         // Separator
                  //         Container(
                  //           height: 1,
                  //           color: CommonColors.greyColor.withValues(alpha: 0.3),
                  //           margin: EdgeInsets.symmetric(vertical: 1.h),
                  //         ),
                  //
                  //         // WhatsApp UPI (Locked)
                  //         Stack(
                  //           children: [
                  //             Opacity(
                  //               opacity: 0.5,
                  //               child: _buildUPIOption(
                  //                 icon: 'whatsapp',
                  //                 title: 'WhatsApp UPI',
                  //                 isSelected: false,
                  //                 onTap: () {}, // Disabled
                  //               ),
                  //             ),
                  //             Positioned.fill(
                  //               child: Container(
                  //                 decoration: BoxDecoration(
                  //                   color: Colors.white.withValues(alpha: 0.7),
                  //                   borderRadius: BorderRadius.circular(2.w),
                  //                 ),
                  //                 child: Center(
                  //                   child: Icon(
                  //                     Icons.lock_outline,
                  //                     size: 5.w,
                  //                     color: CommonColors.blackColor,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //         // Separator
                  //         Container(
                  //           height: 1,
                  //           color: CommonColors.greyColor.withValues(alpha: 0.3),
                  //           margin: EdgeInsets.symmetric(vertical: 1.h),
                  //         ),
                  //
                  //         // Add New UPI ID (Locked)
                  //         Stack(
                  //           children: [
                  //             Opacity(opacity: 0.5, child: _buildAddNewUPIOption()),
                  //             Positioned.fill(
                  //               child: Container(
                  //                 decoration: BoxDecoration(
                  //                   color: Colors.white.withValues(alpha: 0.7),
                  //                   borderRadius: BorderRadius.circular(2.w),
                  //                 ),
                  //                 child: Center(
                  //                   child: Icon(
                  //                     Icons.lock_outline,
                  //                     size: 5.w,
                  //                     color: CommonColors.blackColor,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 3.h),
                  //
                  // // Other Payment Methods Section
                  // Container(
                  //   margin: EdgeInsets.symmetric(horizontal: 4.w),
                  //   width: 100.w,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(5.w),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: CommonColors.blackColor.withValues(alpha: 0.2),
                  //         offset: Offset(2, 2),
                  //         blurRadius: 6,
                  //         spreadRadius: 2,
                  //       ),
                  //     ],
                  //     color: CommonColors.offWhiteColor2,
                  //   ),
                  //   child: Container(
                  //     width: 100.w,
                  //     margin: EdgeInsets.only(
                  //       left: 4.w,
                  //       right: 4.w,
                  //       top: 1.8.h,
                  //       bottom: 1.8.h,
                  //     ),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         // Add New Card (Locked)
                  //         Stack(
                  //           children: [
                  //             Opacity(
                  //               opacity: 0.5,
                  //               child: _buildPaymentOption(
                  //                 icon: CommonImages.cardIcon,
                  //                 title: 'Add New Card',
                  //               ),
                  //             ),
                  //             Positioned.fill(
                  //               child: Container(
                  //                 decoration: BoxDecoration(
                  //                   color: Colors.white.withValues(alpha: 0.7),
                  //                   borderRadius: BorderRadius.circular(2.w),
                  //                 ),
                  //                 child: Center(
                  //                   child: Icon(
                  //                     Icons.lock_outline,
                  //                     size: 5.w,
                  //                     color: CommonColors.blackColor,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //         // Separator
                  //         Container(
                  //           height: 1,
                  //           color: CommonColors.greyColor.withValues(alpha: 0.3),
                  //           margin: EdgeInsets.symmetric(vertical: 1.h),
                  //         ),
                  //
                  //         // Wallets (Locked)
                  //         Stack(
                  //           children: [
                  //             Opacity(
                  //               opacity: 0.5,
                  //               child: _buildPaymentOption(
                  //                 icon: CommonImages.walletIcon,
                  //                 title: 'Wallets',
                  //               ),
                  //             ),
                  //             Positioned.fill(
                  //               child: Container(
                  //                 decoration: BoxDecoration(
                  //                   color: Colors.white.withValues(alpha: 0.7),
                  //                   borderRadius: BorderRadius.circular(2.w),
                  //                 ),
                  //                 child: Center(
                  //                   child: Icon(
                  //                     Icons.lock_outline,
                  //                     size: 5.w,
                  //                     color: CommonColors.blackColor,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //         // Separator
                  //         Container(
                  //           height: 1,
                  //           color: CommonColors.greyColor.withValues(alpha: 0.3),
                  //           margin: EdgeInsets.symmetric(vertical: 1.h),
                  //         ),
                  //
                  //         // Netbanking (Locked)
                  //         Stack(
                  //           children: [
                  //             Opacity(
                  //               opacity: 0.5,
                  //               child: _buildPaymentOption(
                  //                 icon: CommonImages.bankIcon,
                  //                 title: 'Netbanking',
                  //               ),
                  //             ),
                  //             Positioned.fill(
                  //               child: Container(
                  //                 decoration: BoxDecoration(
                  //                   color: Colors.white.withValues(alpha: 0.7),
                  //                   borderRadius: BorderRadius.circular(2.w),
                  //                 ),
                  //                 child: Center(
                  //                   child: Icon(
                  //                     Icons.lock_outline,
                  //                     size: 5.w,
                  //                     color: CommonColors.blackColor,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ),
          Obx(() => _trekControllerC.calculateFareResponseModel.value.maybeWhen(
            loading: (loadingData) => Container(
              color: CommonColors.grey400,
              child: Center(
                child: CircularProgressIndicator(
                  color: CommonColors.blueColor,
                ),
              ),
            ),
            orElse: () => const SizedBox(),
          ))
        ],
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
        child: Obx(() {

          final calculateFareRequestModel = _trekControllerC.calculateFareRequestModel.value;
          CalculateFareResponseModel? calculateFareResponseModel = _trekControllerC.calculateFareResponseModel.value.maybeWhen(
              success: (response) => response,
              orElse: () => null
          );

          return Column(
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
                            breakDown: calculateFareResponseModel?.breakdown,
                            adultCount: calculateFareRequestModel.travelerCount,
                            onClose: () => Navigator.pop(context),
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
                                text:"${calculateFareResponseModel?.breakdown?.amountToPayNow ?? "--"}",
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

                      await _trekControllerC.createTrekOrder();
                      if (_trekControllerC.orderModal.value.success ?? false) {
                        _handlePayment(calculateFareResponseModel?.breakdown);
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
          );
           }
        ),
      ),
    );
  }


  /// Validates if payment can proceed
  /// Currently requires Razorpay to be selected
  bool get _isPaymentValid {
    final validResponse = _trekControllerC.calculateFareResponseModel.value.maybeWhen(success: (response) => true,orElse: () => false);
    // For now, require Razorpay to be selected
    return _selectedUPIOption == PaymentMethods.razorpay && validResponse;
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
  void _handlePayment(BreakDownDataModel? breakdown) {
    _openRazorpay(breakdown);
  }
}
