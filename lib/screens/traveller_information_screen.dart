import 'dart:math';
import 'dart:async';

import 'package:arobo_app/freezed_models/booking/booking_data_model.dart';
import 'package:arobo_app/screens/booking_upcoming_screen.dart';
import 'package:arobo_app/screens/coupon_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:arobo_app/utils/state_selection_bottom_sheet.dart';
import 'package:arobo_app/utils/total_fare_modal.dart';

import '../freezed_models/profile/user_profile_model.dart';
import '../freezed_models/treks/trek_detail_model.dart';
import '../utils/traveller_selection_utils.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
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
  static const iconBadge = CommonColors.cFF111827;
  static const divider = CommonColors.trekroutecolorlight;

  static const sheetBg = Colors.white;
  static const sheetSurface = Colors.white;
  static const sheetBorder = Color(0xFFE2E8F0);
  static const sheetInk = Color(0xFF0F172A);
  static const sheetInkMid = Color(0xFF64748B);
  static const sheetHandle = Color(0xFFD1D5DB);
  static const sheetAccent = Color(0xFF111827);
}

// ─────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────
class TravellerInformationScreen extends StatefulWidget {
  const TravellerInformationScreen({super.key});

  @override
  State<TravellerInformationScreen> createState() =>
      _TravellerInformationScreenState();
}

class _TravellerInformationScreenState extends State<TravellerInformationScreen>
    with TickerProviderStateMixin {
  final TrekController _trekC = Get.find<TrekController>();
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final UserController _userC = Get.find<UserController>();
  late TrekDetailData travelData;
  final nameNode = FocusNode();

  String _selectedState = BookingConstants.defaultState;
  String _selectedPaymentOption = 'full';
  String? _selectedUPI = PaymentMethods.razorpay;

  List<Traveler> selectedTravellers = [];

  // Payment & Coupon State
  bool _isTripExpanded = false;
  bool _isCouponExpanded = true;
  bool _isProcessingPayment = false;
  bool _showPaymentError = false;
  String _paymentErrorMessage = '';

  static const int _totalTimerSecs = 5 * 60;
  final RxInt _remainingSecs = _totalTimerSecs.obs;
  bool _isTimerExpired = false;
  Timer? _timer;
  late Razorpay _razorpay;

  // Validation & Hints
  final GlobalKey _contactCardKey = GlobalKey();
  final GlobalKey _travellerCardKey = GlobalKey();
  late AnimationController _shakeController;
  int _shakeTargetIndex = -1; // -1: none, 1: contact, 2: travellers
  String? _hintMessage;
  Timer? _hintTimer;

  bool get _isFlexiblePolicy => travelData.cancellationPolicy?.id == 5;

  @override
  void initState() {
    super.initState();
    travelData = _trekC.trekDetailData.value;

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _selectedPaymentOption = _isFlexiblePolicy ? 'advance' : 'full';

    final existingCoupon = _trekC.calculateFareRequestModel.value.couponCode;
    selectedTravellers = List.from(_trekC.travellerDetailList);

    final restoredCount = selectedTravellers.isNotEmpty
        ? selectedTravellers.length
        : 1;

    _trekC.calculateFareRequestModel.value = _trekC
        .calculateFareRequestModel
        .value
        .copyWith(
          batchId: travelData.batchId ?? 1,
          travelerCount: restoredCount,
          addInsurance: false,
          addFreeCancellationProtection: false,
          couponCode: (existingCoupon != null && existingCoupon.isNotEmpty)
              ? existingCoupon
              : '',
        );
    _trekC.calculateFare();

    debounce(_trekC.calculateFareRequestModel, (value) {
      _trekC.calculateFare();
    }, time: const Duration(milliseconds: 500));

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncTimerToExpiry(_currentFareResponse()?.expiresAt);
    });
    ever(_trekC.calculateFareResponseModel, (result) {
      result.maybeWhen(
        success: (r) =>
            _syncTimerToExpiry((r as CalculateFareResponseModel).expiresAt),
        orElse: () {},
      );
    });

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hintTimer?.cancel();
    _shakeController.dispose();
    _razorpay.clear();
    nameNode.dispose();
    _userC.nameControllerTraveller.value.clear();
    _userC.ageControllerTraveller.value.clear();
    _userC.selectedGender.value = '';
    super.dispose();
  }

  CalculateFareResponseModel? _currentFareResponse() {
    return _trekC.calculateFareResponseModel.value.maybeWhen(
      success: (r) => r as CalculateFareResponseModel,
      orElse: () => null,
    );
  }

  void _syncTimerToExpiry(dynamic expiresAtRaw) {
    if (expiresAtRaw == null) return;
    final expiresAt = DateTime.tryParse(expiresAtRaw.toString());
    if (expiresAt == null) return;

    final secsLeft = expiresAt.difference(DateTime.now()).inSeconds;
    _remainingSecs.value = secsLeft.clamp(0, _totalTimerSecs);

    if (_remainingSecs.value <= 0) {
      _timer?.cancel();
      _handleTimerExpired();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remainingSecs.value > 0) {
        _remainingSecs.value--;
      } else {
        t.cancel();
        _handleTimerExpired();
      }
    });
  }

  void _handleTimerExpired() {
    if (!mounted || _isProcessingPayment) return;
    _isTimerExpired = true;
    CustomSnackBar.show(
      context,
      message: 'Payment session timed out. Please start over.',
    );
    Get.back();
  }

  void _triggerHint(String message, GlobalKey key, int targetIndex) {
    HapticFeedback.mediumImpact();
    setState(() {
      _hintMessage = message;
      _shakeTargetIndex = targetIndex;
    });

    _shakeController.forward(from: 0.0);

    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    }

    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _hintMessage = null);
    });
  }

  bool _validateBeforePayment() {
    final customer = _userC.userProfileData.value.customer;

    if (customer?.email == null ||
        customer?.phone == null ||
        customer?.state?.id == null) {
      _triggerHint(
        'Please add your contact details to continue',
        _contactCardKey,
        1,
      );
      return false;
    }

    final adultCount = _trekC.calculateFareRequestModel.value.travelerCount;
    if (selectedTravellers.length < adultCount) {
      final needed = adultCount - selectedTravellers.length;
      _triggerHint(
        'Please select $needed more traveller${needed > 1 ? 's' : ''} for the trip',
        _travellerCardKey,
        2,
      );
      return false;
    }

    return true;
  }

  // ── PAYMENT LOGIC ────────────────────────────────────────────────────────
  void _openRazorpay(BreakDownDataModel? breakdown) async {
    try {
      final params = _trekC.orderNextActionParams;
      final options = {
        'key': params['key'] ?? BookingConstants.razorpayKey,
        'order_id': params['order_id'] ?? '${_trekC.orderData.value.id}',
        'amount':
            params['amount'] ??
            (((_selectedPaymentOption == 'full'
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

    final verified = await _trekC.verifyTrekOrder(
      razorpayOrderId: r.orderId ?? '',
      razorpayPaymentId: r.paymentId ?? '',
      razorpaySignature: r.signature ?? '',
    );

    if (!verified && mounted) {
      setState(() {
        _isProcessingPayment = false;
        _showPaymentError = true;
        _paymentErrorMessage = _trekC.errorMessage.value.isNotEmpty
            ? _trekC.errorMessage.value
            : 'Your payment went through, but we could not confirm it yet. Please retry.';
      });
      return;
    }

    if (verified && mounted) {
      final String bookingId =
          (_trekC.verifyOrderModal.value.data?.id ??
                  _trekC.orderData.value.id ??
                  '')
              .toString();

      setState(() => _isProcessingPayment = false);

      _trekC.clearBookingData();
      _dashboardC.clearSearchAndBookingData();

      Get.off(
        () => BookingsUpcomingScreen(bookingId: bookingId),
        transition: Transition.rightToLeftWithFade,
        duration: const Duration(milliseconds: 350),
      );
    }
  }

  Future<void> _handlePaymentError(PaymentFailureResponse r) async {
    if (!mounted) return;

    final orderId =
        _trekC.orderData.value.id ??
        _trekC.orderNextActionParams['order_id']?.toString() ??
        '';
    if (orderId.isNotEmpty) {
      final status = await _trekC.checkOrderStatus(orderId);
      if (status?['status'] == 'paid' && mounted) {
        setState(() => _isProcessingPayment = false);
        _trekC.clearBookingData();
        Get.offNamedUntil('/my-bookings', ModalRoute.withName('/dashboard'));
        CustomSnackBar.show(
          Get.context!,
          message: 'Good news — your payment actually went through.',
        );
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _isProcessingPayment = false;
      _showPaymentError = true;
      _paymentErrorMessage = (r.message?.isNotEmpty ?? false)
          ? r.message!
          : 'Payment was not completed.';
    });
  }

  Future<void> _handlePayNow() async {
    if (!_validateBeforePayment()) return;

    setState(() {
      _isProcessingPayment = true;
      _showPaymentError = false;
    });

    _trekC.createOrderRequestModel.value = _trekC.createOrderRequestModel.value
        .copyWith(travelers: selectedTravellers.toList());

    await _trekC.createTrekOrder();
    if (_trekC.orderModal.value.success ?? false) {
      _openRazorpay(
        _trekC.calculateFareResponseModel.value.maybeWhen(
          success: (r) => (r as CalculateFareResponseModel).breakdown,
          orElse: () => null,
        ),
      );
    } else if (mounted) {
      setState(() {
        _isProcessingPayment = false;
        _showPaymentError = true;
        _paymentErrorMessage = _trekC.errorMessage.value.isNotEmpty
            ? _trekC.errorMessage.value
            : 'Could not start payment. Please try again.';
      });
    }
  }

  Future<void> _retryPayment() async {
    setState(() {
      _showPaymentError = false;
      _isProcessingPayment = true;
    });

    final hasCapturedPayment = _trekC.paymentId.value.isNotEmpty;
    final existingOrderId =
        _trekC.orderData.value.id ??
        _trekC.orderNextActionParams['order_id']?.toString();
    final hasExistingOrder = (existingOrderId ?? '').isNotEmpty;

    if (hasCapturedPayment) {
      final verified = await _trekC.verifyTrekOrder(
        razorpayOrderId: _trekC.orderId.value,
        razorpayPaymentId: _trekC.paymentId.value,
        razorpaySignature: _trekC.signature.value,
      );
      if (!verified && mounted) {
        setState(() {
          _isProcessingPayment = false;
          _showPaymentError = true;
          _paymentErrorMessage =
              'Still could not confirm your payment. Please try again.';
        });
      }
    } else if (hasExistingOrder) {
      _openRazorpay(
        _trekC.calculateFareResponseModel.value.maybeWhen(
          success: (r) => (r as CalculateFareResponseModel).breakdown,
          orElse: () => null,
        ),
      );
    } else {
      await _trekC.calculateFare();
      final refreshed = _trekC.calculateFareResponseModel.value.maybeWhen(
        success: (_) => true,
        orElse: () => false,
      );
      if (!refreshed) {
        if (mounted) {
          setState(() {
            _isProcessingPayment = false;
            _showPaymentError = true;
            _paymentErrorMessage = 'Could not refresh fare. Please try again.';
          });
        }
        return;
      }
      await _handlePayNow();
    }
  }

  void _handleExternalWallet(ExternalWalletResponse r) {
    CustomSnackBar.show(
      context,
      message:
          'You have chosen to pay via ${r.walletName}. It may take some time to reflect.',
    );
  }

  Future<void> _showCancelPaymentDialog() async {
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
            child: Text(
              'Leave Anyway',
              style: TextStyle(color: CommonColors.appRedColor),
            ),
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      setState(() => _isProcessingPayment = false);
      Get.back();
    }
  }

  // ── UI HELPERS ───────────────────────────────────────────────────────────
  Widget _sectionHeader(
    String title,
    IconData icon, {
    bool isCompleted = false,
  }) {
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
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: _TI.ink,
            ),
          ),
        ),
        if (isCompleted) ...[
          SizedBox(width: 2.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: _TI.tealSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 10.sp, color: _TI.teal),
                SizedBox(width: 1.w),
                Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: _TI.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _shakeBuilder({required int targetIndex, required Widget child}) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, _) {
        final shouldShake =
            _shakeTargetIndex == targetIndex && _shakeController.isAnimating;
        if (!shouldShake) return child;

        final sineValue = sin(_shakeController.value * 3 * pi) * 8;
        return Transform.translate(offset: Offset(sineValue, 0), child: child);
      },
    );
  }

  Widget _infoRow(String svgAsset, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: SvgPicture.asset(svgAsset, width: 4.w, height: 4.w),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: _TI.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetHandle() => Center(
    child: Container(
      width: 10.w,
      height: 0.5.h,
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        color: _TI.sheetHandle,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );

  Widget _sheetHeader(String title, IconData icon, {VoidCallback? onClose}) =>
      Padding(
        padding: EdgeInsets.only(bottom: 2.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: _TI.sheetInk,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: onClose ?? () => Navigator.pop(context),
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: _TI.bg, // Use background to make it blend
                  shape: BoxShape.circle,
                  border: Border.all(color: _TI.sheetBorder),
                ),
                child: Icon(Icons.close, size: 4.w, color: _TI.sheetInkMid),
              ),
            ),
          ],
        ),
      );

  Widget _sheetInputContainer({required String label, required Widget child}) =>
      Container(
        decoration: BoxDecoration(
          color: _TI.sheetSurface,
          border: Border.all(color: _TI.sheetBorder),
          borderRadius: BorderRadius.circular(2.w),
        ),
        padding: EdgeInsets.only(left: 4.w, right: 3.w, top: 1.h, bottom: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 8.sp,
                color: _TI.sheetInkMid,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 0.5.h),
            child,
          ],
        ),
      );

  Widget _sheetTextField(
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    FocusNode? focusNode,
    VoidCallback? onChanged,
    bool readOnly = false,
  }) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      focusNode: focusNode,
      maxLength: maxLength,
      onChanged: (_) => onChanged?.call(),
      readOnly: readOnly,
      style: GoogleFonts.poppins(
        fontSize: 12.sp,
        color: readOnly ? _TI.sheetInkMid : _TI.sheetInk,
      ),
      cursorColor: _TI.sheetAccent,
      decoration: const InputDecoration(
        border: InputBorder.none,
        counterText: '',
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    ),
  );

  // ── BOTTOM SHEETS ────────────────────────────────────────────────────────
  void _showStateSelectionBottomSheet(StateSetter setModalState) {
    showStateSelectionBottomSheet(
      context: context,
      stateList: _dashboardC.stateList,
      selectedStateId: _userC.stateUpdateId.value,
      onStateSelected: (state) {
        setModalState(() {
          _userC.stateUpdateId.value = state.id ?? 0;
          _selectedState = state.name ?? '';
        });
      },
    );
  }

  void _showContactDetailsBottomSheet({bool isEdit = false}) {
    _userC.phoneNumberController.value.text =
        (isEdit && _userC.userProfileData.value.customer?.phone != null)
        ? _userC.userProfileData.value.customer!.phone!.replaceFirst('+91', '')
        : '';
    _userC.emailController.value.text =
        (isEdit && _userC.userProfileData.value.customer?.email != null)
        ? _userC.userProfileData.value.customer!.email!
        : '';

    if (isEdit && _userC.userProfileData.value.customer?.state != null) {
      _userC.stateUpdateId.value =
          _userC.userProfileData.value.customer!.state!.id!;
      _selectedState =
          _userC.userProfileData.value.customer!.state!.name ?? '-';
    } else {
      _userC.stateUpdateId.value = 0;
      _selectedState = BookingConstants.defaultState;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: _TI.sheetBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sheetHandle(),
                  _sheetHeader(
                    isEdit ? 'Edit Contact Details' : 'Add Contact Details',
                    Icons.contact_phone_outlined,
                  ),
                  _sheetInputContainer(
                    label: 'Phone Number',
                    child: Row(
                      children: [
                        Text(
                          '+91',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: _TI.sheetInk,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Container(
                          height: 2.h,
                          width: 1,
                          color: _TI.sheetBorder,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: _sheetTextField(
                            _userC.phoneNumberController.value,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            readOnly: true, // Blocked for editing
                            onChanged: () {},
                          ),
                        ),
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 4.w,
                          color: _TI.sheetInkMid,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  _sheetInputContainer(
                    label: 'Email ID',
                    child: _sheetTextField(
                      _userC.emailController.value,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: () {},
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _TI.sheetSurface,
                      border: Border.all(color: _TI.sheetBorder),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    child: InkWell(
                      onTap: () =>
                          _showStateSelectionBottomSheet(setModalState),
                      borderRadius: BorderRadius.circular(2.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'State of Residence',
                                style: GoogleFonts.poppins(
                                  fontSize: 8.sp,
                                  color: _TI.sheetInkMid,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 0.25.h),
                              Text(
                                _selectedState,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: _TI.sheetInk,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: _TI.sheetInkMid,
                            size: 6.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  CommonButton(
                    height: 48,
                    gradient: CommonColors.filterGradient,
                    text: isEdit ? 'Update' : 'Save',
                    textColor: CommonColors.whiteColor,
                    onPressed: () async {
                      if (_validateContactDetails()) {
                        await _userC.updateUserProfile();
                        if (!context.mounted) return;
                        setState(() {});
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEdit
                                  ? 'Contact details updated'
                                  : 'Contact details saved',
                            ),
                            backgroundColor: CommonColors.completedColor,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showTravellerBottomSheet({Traveler? traveller, bool isEdit = false}) {
    if (isEdit && traveller != null) {
      _userC.travellerId.value = traveller.id ?? 0;
      _userC.nameControllerTraveller.value.text = traveller.name ?? '';
      _userC.ageControllerTraveller.value.text = traveller.age.toString();
      _userC.selectedGender.value = traveller.gender ?? '';
    } else {
      _userC.travellerId.value = 0;
      _userC.nameControllerTraveller.value.clear();
      _userC.ageControllerTraveller.value.clear();
      _userC.selectedGender.value = '';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: _TI.sheetBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sheetHandle(),
                  _sheetHeader(
                    isEdit ? 'Edit Traveller' : 'Add New Traveller',
                    Icons.badge_outlined,
                  ),
                  _sheetInputContainer(
                    label: 'Full Name',
                    child: _sheetTextField(
                      _userC.nameControllerTraveller.value,
                      focusNode: nameNode,
                      onChanged: () {},
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 4,
                        child: _sheetInputContainer(
                          label: 'Age',
                          child: _sheetTextField(
                            _userC.ageControllerTraveller.value,
                            keyboardType: TextInputType.number,
                            onChanged: () {},
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gender',
                              style: GoogleFonts.poppins(
                                fontSize: 8.sp,
                                color: _TI.sheetInkMid,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                _buildGenderButtonInSheet(
                                  'Male',
                                  setModalState,
                                ),
                                SizedBox(width: 2.w),
                                _buildGenderButtonInSheet(
                                  'Female',
                                  setModalState,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  CommonButton(
                    height: 48,
                    gradient: CommonColors.filterGradient,
                    text: isEdit ? 'Update Traveller' : 'Add Traveller',
                    textColor: CommonColors.whiteColor,
                    onPressed: () async {
                      if (_validateTravellerDetails()) {
                        if (isEdit) {
                          await _userC.updateTraveler();
                        } else {
                          await _userC.addTraveler();
                        }

                      if (!isEdit) {
                        final adultCount = _trekC
                            .calculateFareRequestModel
                            .value
                            .travelerCount;
                        final travelers =
                            _userC.userProfileData.value.customer?.travelers ??
                            [];
                        if (travelers.isNotEmpty) {
                          final newTraveler = travelers.last;
                          final alreadySelected = selectedTravellers.any(
                            (t) => t.id == newTraveler.id,
                          );
                          if (!alreadySelected &&
                              selectedTravellers.length < adultCount) {
                            setState(() {
                              selectedTravellers.add(newTraveler);
                              _trekC.travellerDetailList.value = List.from(
                                selectedTravellers,
                              );
                              _trekC.calculateFareRequestModel.value = _trekC
                                  .calculateFareRequestModel
                                  .value
                                  .copyWith(
                                    travelerCount: selectedTravellers.length,
                                  );
                            });
                          }
                        }
                      } else {
                        setState(() {});
                      }

                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEdit ? 'Traveller updated' : 'Traveller added',
                            ),
                            backgroundColor: CommonColors.completedColor,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGenderButtonInSheet(String gender, StateSetter setModalState) {
    final bool isSelected =
        _userC.selectedGender.value.toLowerCase() == gender.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () => setModalState(() => _userC.selectedGender.value = gender),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 5.5.h,
          decoration: BoxDecoration(
            color: isSelected ? _TI.tealSoft : Colors.white,
            border: Border.all(
              color: isSelected ? _TI.teal : _TI.sheetBorder,
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(3.w),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                gender,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? _TI.sheetInk : _TI.sheetInkMid,
                ),
              ),
              SizedBox(width: 2.w),
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 4.w,
                color: isSelected ? _TI.teal : _TI.sheetInkMid,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateContactDetails() {
    final phone = _userC.phoneNumberController.value.text.trim();
    final email = _userC.emailController.value.text.trim();

    if (phone.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      CustomSnackBar.show(
        context,
        message: 'Please enter a valid 10-digit phone number',
      );
      return false;
    }
    if (email.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      CustomSnackBar.show(
        context,
        message: 'Please enter a valid email address',
      );
      return false;
    }
    if (_userC.stateUpdateId.value == 0 ||
        _selectedState.isEmpty ||
        _selectedState == '-') {
      CustomSnackBar.show(
        context,
        message: 'Please select your state of residence',
      );
      return false;
    }
    return true;
  }

  bool _validateTravellerDetails() {
    final name = _userC.nameControllerTraveller.value.text.trim();
    final age = _userC.ageControllerTraveller.value.text.trim();
    final gender = _userC.selectedGender.value;

    if (name.isEmpty) {
      CustomSnackBar.show(context, message: 'Please enter traveller name');
      return false;
    }
    if (age.isEmpty) {
      CustomSnackBar.show(context, message: 'Please enter traveller age');
      return false;
    }
    final ageVal = int.tryParse(age);
    if (ageVal == null || ageVal <= 0) {
      CustomSnackBar.show(context, message: 'Please enter a valid age');
      return false;
    }
    if (gender.isEmpty) {
      CustomSnackBar.show(context, message: 'Please select gender');
      return false;
    }
    return true;
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isProcessingPayment,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showCancelPaymentDialog();
      },
      child: Scaffold(
        backgroundColor: _TI.bg,
        appBar: _buildAppBar(),
        bottomNavigationBar: _buildBottomBar(),
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTripSummary(),
                  SizedBox(height: 2.h),
                  _shakeBuilder(targetIndex: 1, child: _buildContactSection()),
                  SizedBox(height: 2.h),
                  _shakeBuilder(
                    targetIndex: 2,
                    child: _buildTravellerSection(),
                  ),
                  SizedBox(height: 2.h),
                  _buildPaymentOptionsSection(),
                  SizedBox(height: 2.h),
                  _buildCouponSection(),
                  SizedBox(height: 2.h),
                  _buildPaymentMethodSection(),
                  SizedBox(height: 3.h),
                ],
              ),
            ),

            // Loading overlay
            Obx(
              () => _trekC.calculateFareResponseModel.value.maybeWhen(
                loading: (_) => Container(
                  color: Colors.black.withValues(alpha: 0.2),
                  child: Center(
                    child: CircularProgressIndicator(color: _TI.brand),
                  ),
                ),
                orElse: () => const SizedBox(),
              ),
            ),

            // Processing Payment Overlay
            if (_isProcessingPayment && !_showPaymentError)
              Positioned.fill(
                child: Container(
                  // Use a completely opaque color (white or _TI.bg)
                  // so the underlying TravellerInformationScreen is 100% hidden.
                  color: _TI.bg,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _TI.cardBg,
                        borderRadius: BorderRadius.circular(4.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: _TI.brand,
                            strokeWidth: 2.5,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Confirming your payment...',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.sp,
                              color: _TI.inkMid,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            if (_showPaymentError) _buildPaymentErrorOverlay(),
            if (_hintMessage != null) _buildHintPopup(),
          ],
        ),
      ),
    );
  }

  // ── SECTIONS BUILDER ──────────────────────────────────────────────────────

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'A';
    final parts = name.split(' ').where((e) => e.trim().isNotEmpty).toList();
    if (parts.isEmpty) return 'A';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _buildTripSummary() {
    final vendorName = travelData.vendor?.user?.name ?? 'Aorbo Treks';
    final hasBadge =
        travelData.badge?.name != null && travelData.badge!.name!.isNotEmpty;
    final hasSlots = (travelData.availableSlots ?? 0) > 0;

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                travelData.title ?? 'Trek',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: _TI.ink,
                ),
              ),
              Text(
                vendorName,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.sp,
                  color: _TI.inkMid,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Divider(color: _TI.divider, height: 3.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FROM',
                      style: TextStyle(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                        color: _TI.inkLight,
                      ),
                    ),
                    Text(
                      _formatDate(travelData.startDate),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: _TI.ink,
                      ),
                    ),
                    Text(
                      _dashboardC.fromController.value.text,
                      style: TextStyle(fontSize: 9.sp, color: _TI.inkMid),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: _TI.brand,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${travelData.durationDays ?? 0}D | ${travelData.durationNights ?? 0}N',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TO',
                      style: TextStyle(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                        color: _TI.inkLight,
                      ),
                    ),
                    Text(
                      _calculateEndDate(
                        travelData.startDate,
                        travelData.durationDays,
                      ),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: _TI.ink,
                      ),
                    ),
                    Text(
                      _dashboardC.toController.value.text,
                      style: TextStyle(fontSize: 9.sp, color: _TI.inkMid),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasBadge || hasSlots) ...[
            SizedBox(height: 1.5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (hasBadge)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.5.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: _TI.tealSoft,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _TI.teal.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      travelData.badge!.name!.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w800,
                        color: _TI.teal,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                if (hasSlots)
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 4.w,
                        color: CommonColors.appRedColor,
                      ),
                      SizedBox(width: 1.5.w),
                      Text(
                        '${travelData.availableSlots} slots left',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: CommonColors.appRedColor,
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    final customer = _userC.userProfileData.value.customer;
    final isCompleted =
        customer?.email != null &&
        customer?.phone != null &&
        customer?.state?.id != null;

    return Container(
      key: _contactCardKey,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _TI.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _TI.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader(
                'Contact Details',
                Icons.contact_phone_outlined,
                isCompleted: isCompleted,
              ),
              GestureDetector(
                onTap: () =>
                    _showContactDetailsBottomSheet(isEdit: isCompleted),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: _TI.brand.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _TI.brand.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    isCompleted ? 'Edit' : 'Add',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: _TI.brand,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Ticket details will be sent to this contact information',
            style: TextStyle(
              fontSize: 8.sp,
              color: _TI.inkMid,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 1.h),
          if (!isCompleted)
            Text(
              'Tap "Add" to enter your phone, email and state.',
              style: TextStyle(fontSize: 9.sp, color: _TI.inkMid),
            )
          else ...[
            _infoRow(CommonImages.phone, customer?.phone ?? '-'),
            _infoRow(CommonImages.email, customer?.email ?? '-'),
            _infoRow(CommonImages.location4, customer?.state?.name ?? '-'),
          ],
        ],
      ),
    );
  }

  Widget _buildTravellerSection() {
    final isCompleted =
        selectedTravellers.length >=
        _trekC.calculateFareRequestModel.value.travelerCount;

    return Container(
      key: _travellerCardKey,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _TI.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _TI.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _sectionHeader(
                  'Traveller Details',
                  Icons.badge_outlined,
                  isCompleted: isCompleted,
                ),
              ),
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: () => _showTravellerBottomSheet(isEdit: false),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: _TI.iconBadge,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 3.5.w),
                      SizedBox(width: 1.w),
                      Text(
                        'Add New',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Adults (18+ years)',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: _TI.ink,
                ),
              ),
              Obx(() {
                final adultCount =
                    _trekC.calculateFareRequestModel.value.travelerCount;
                return Row(
                  children: [
                    _counterBtn(Icons.remove, () {
                      setState(() {
                        if (adultCount > 1) {
                          _trekC.calculateFareRequestModel.value = _trekC
                              .calculateFareRequestModel
                              .value
                              .copyWith(travelerCount: adultCount - 1);
                          if (selectedTravellers.length > adultCount - 1) {
                            selectedTravellers = selectedTravellers
                                .take(adultCount - 1)
                                .toList();
                          }
                        }
                      });
                      _trekC.trekPersonCount.value = adultCount;
                      _trekC.travellerDetailList.value = selectedTravellers;
                    }, active: adultCount > 1),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        '$adultCount',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: _TI.ink,
                        ),
                      ),
                    ),
                    _counterBtn(Icons.add, () {
                      setState(() {
                        _trekC.calculateFareRequestModel.value = _trekC
                            .calculateFareRequestModel
                            .value
                            .copyWith(travelerCount: adultCount + 1);
                      });
                      _trekC.trekPersonCount.value = adultCount;
                    }, active: true),
                  ],
                );
              }),
            ],
          ),
          SizedBox(height: 1.5.h),
          if (_userC.userProfileData.value.customer?.travelers?.isEmpty ?? true)
            Text(
              'No travellers added yet. Tap "Add New" to create one.',
              style: TextStyle(fontSize: 9.sp, color: _TI.inkMid),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  _userC.userProfileData.value.customer!.travelers!.length,
              separatorBuilder: (_, __) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final traveler =
                    _userC.userProfileData.value.customer!.travelers![index];
                final isSelected = selectedTravellers.any(
                  (t) => t.id == traveler.id,
                );
                return _buildExistingTravellerItem(traveler, isSelected);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionsSection() {
    if (!_isFlexiblePolicy) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _TI.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _TI.divider, width: 1),
      ),
      child: Obx(() {
        final fareResp = _trekC.calculateFareResponseModel.value.maybeWhen(
          success: (r) => r as CalculateFareResponseModel,
          orElse: () => null,
        );
        final bd = fareResp?.breakdown;

        String advanceText = '₹${bd?.amountToPayNow ?? '--'}';
        String remainingText = '₹${bd?.remainingAmount ?? '--'}';
        String fullText = '₹${bd?.finalAmount ?? '--'}';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Payment Options', Icons.payment_outlined),
            SizedBox(height: 1.5.h),
            GestureDetector(
              onTap: () {
                setState(() => _selectedPaymentOption = 'advance');
                _trekC.createOrderRequestModel.value = _trekC
                    .createOrderRequestModel
                    .value
                    .copyWith(payFull: false);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: _selectedPaymentOption == 'advance'
                      ? _TI.tealSoft
                      : _TI.bg,
                  borderRadius: BorderRadius.circular(3.w),
                  border: Border.all(
                    color: _selectedPaymentOption == 'advance'
                        ? _TI.brand.withValues(alpha: 0.4)
                        : _TI.divider,
                    width: _selectedPaymentOption == 'advance' ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedPaymentOption == 'advance'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color: _selectedPaymentOption == 'advance'
                          ? _TI.brand
                          : _TI.inkLight,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pay $advanceText Advance',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: _TI.ink,
                            ),
                          ),
                          Text(
                            'Pay remaining $remainingText before trek start',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9.sp,
                              color: _TI.inkMid,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 1.5.h),
            GestureDetector(
              onTap: () {
                setState(() => _selectedPaymentOption = 'full');
                _trekC.createOrderRequestModel.value = _trekC
                    .createOrderRequestModel
                    .value
                    .copyWith(payFull: true);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: _selectedPaymentOption == 'full'
                      ? _TI.tealSoft
                      : _TI.bg,
                  borderRadius: BorderRadius.circular(3.w),
                  border: Border.all(
                    color: _selectedPaymentOption == 'full'
                        ? _TI.brand.withValues(alpha: 0.4)
                        : _TI.divider,
                    width: _selectedPaymentOption == 'full' ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedPaymentOption == 'full'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color: _selectedPaymentOption == 'full'
                          ? _TI.brand
                          : _TI.inkLight,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pay $fullText Full Amount',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: _TI.ink,
                            ),
                          ),
                          Text(
                            'Secure your booking now',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9.sp,
                              color: _TI.inkMid,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCouponSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _TI.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _TI.divider, width: 1),
      ),
      child: Obx(() {
        final fareReq = _trekC.calculateFareRequestModel.value;
        final fareResponse = _trekC.calculateFareResponseModel.value.maybeWhen(
          success: (r) => r as CalculateFareResponseModel,
          orElse: () => null,
        );

        final appliedCode = fareReq.couponCode ?? '';
        final discountText = fareResponse?.breakdown?.discount?.toStringAsFixed(
          2,
        );
        final isCouponApplied = discountText != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_offer_outlined, size: 5.w, color: _TI.ink),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Coupon Code',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _TI.ink,
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
                      size: 6.w,
                      color: _TI.inkMid,
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
                  SizedBox(height: 1.5.h),
                  if (appliedCode.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.2.h,
                      ),
                      decoration: BoxDecoration(
                        color: isCouponApplied
                            ? _TI.tealSoft
                            : CommonColors.appRedColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3.w),
                        border: Border.all(
                          color: isCouponApplied
                              ? _TI.teal.withValues(alpha: 0.3)
                              : CommonColors.appRedColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCouponApplied
                                ? Icons.check_circle_outline_rounded
                                : Icons.cancel_outlined,
                            size: 18,
                            color: isCouponApplied
                                ? _TI.teal
                                : CommonColors.appRedColor,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appliedCode,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isCouponApplied
                                        ? _TI.teal
                                        : CommonColors.appRedColor,
                                  ),
                                ),
                                if (isCouponApplied)
                                  Text(
                                    'You save ₹$discountText',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: _TI.teal,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _trekC.calculateFareRequestModel.value = _trekC
                                  .calculateFareRequestModel
                                  .value
                                  .copyWith(couponCode: '');
                            },
                            child: Text(
                              'Remove',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: CommonColors.appRedColor,
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: _TI.bg,
                          borderRadius: BorderRadius.circular(3.w),
                          border: Border.all(
                            color: _TI.brand.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 16,
                              color: _TI.brand,
                            ),
                            SizedBox(width: 2.5.w),
                            Expanded(
                              child: Text(
                                'Browse & apply coupon codes',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: _TI.brand,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPaymentMethodSection() {
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
          _sectionHeader('Payment Method', Icons.payment_rounded),
          SizedBox(height: 1.5.h),
          _paymentMethodOption(
            icon: _razorpayLogo(),
            label: 'Razorpay',
            subtitle: 'Credit card, Debit card, UPI, Wallets & more',
            isSelected: _selectedUPI == PaymentMethods.razorpay,
            onTap: () => setState(() => _selectedUPI = PaymentMethods.razorpay),
          ),
          Divider(color: _TI.divider, height: 2.h),
          Opacity(
            opacity: 0.45,
            child: _paymentMethodOption(
              icon: _lockedIcon(CommonImages.phonePeIcon),
              label: 'PhonePe UPI',
              subtitle: 'Coming soon',
              isSelected: false,
              isLocked: true,
              onTap: () {},
            ),
          ),
          SizedBox(height: 1.h),
          Opacity(
            opacity: 0.45,
            child: _paymentMethodOption(
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

  // ── BOTTOM BAR & OVERLAYS ─────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final fareReq = _trekC.calculateFareRequestModel.value;
                    final fareResp = _trekC.calculateFareResponseModel.value
                        .maybeWhen(
                          success: (r) => r as CalculateFareResponseModel,
                          orElse: () => null,
                        );

                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => TotalFareModal(
                        breakDown: fareResp?.breakdown,
                        adultCount: fareReq.travelerCount,
                        onClose: () => Navigator.pop(context),
                        isPayingAdvance:
                            _isFlexiblePolicy &&
                            _selectedPaymentOption == 'advance',
                      ),
                    );
                  },
                  child: Obx(() {
                    final fareRespModel = _trekC
                        .calculateFareResponseModel
                        .value
                        .maybeWhen(success: (r) => r, orElse: () => null);
                    final isFlexible = _isFlexiblePolicy;
                    final isPayingFull =
                        !isFlexible || _selectedPaymentOption == 'full';
                    final payableNow = isPayingFull
                        ? fareRespModel?.breakdown?.finalAmount
                        : fareRespModel?.breakdown?.amountToPayNow;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Total Payable',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: _TI.inkMid,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 14,
                              color: _TI.inkMid,
                            ),
                          ],
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '₹ ',
                                style: GoogleFonts.roboto(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: CommonColors.softGreen2,
                                ),
                              ),
                              TextSpan(
                                text: '${payableNow ?? "--"}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: CommonColors.softGreen2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isPayingFull)
                          Text(
                            'Advance Payment',
                            style: TextStyle(
                              fontSize: 8.sp,
                              color: CommonColors.orangeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ),
              SizedBox(width: 4.w),
              SizedBox(
                width: 42.w,
                child: CommonButton(
                  text: 'Pay Now',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  isDisabled: _isProcessingPayment,
                  onPressed: _handlePayNow,
                  gradient: CommonColors.filterGradient,
                  textColor: CommonColors.whiteColor,
                  height: 52,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHintPopup() {
    return Positioned(
      bottom: 18.h,
      left: 4.w,
      right: 4.w,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 16,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  _hintMessage!,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentErrorOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _TI.cardBg,
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: CommonColors.appRedColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: _TI.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _paymentErrorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10.sp,
                    color: _TI.inkMid,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _TI.inkMid,
                          side: BorderSide(color: _TI.divider),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('GO BACK'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isProcessingPayment ? null : _retryPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _TI.brand,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('RETRY'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
      title: Text(
        'Checkout',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: _TI.ink,
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

  Widget _buildTimerAndProgress() {
    return Center(
      child: Obx(() {
        final minutes = _remainingSecs.value ~/ 60;
        final seconds = _remainingSecs.value % 60;
        final formattedTime =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
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
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: CommonColors.orangeColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.5.h),
            SizedBox(
              width: 17.w,
              height: 0.5.h,
              child: LinearProgressIndicator(
                value: _remainingSecs.value / _totalTimerSecs,
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

  // ── SMALL UI COMPONENTS ───────────────────────────────────────────────────
  Widget _counterBtn(IconData icon, VoidCallback onTap, {bool active = true}) {
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? _TI.iconBadge : const Color(0xFFF1F5F9),
        ),
        child: Icon(
          icon,
          size: 4.w,
          color: active ? Colors.white : _TI.inkLight,
        ),
      ),
    );
  }

  Widget _buildExistingTravellerItem(Traveler traveler, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isSelected
            ? _TI.brand.withValues(alpha: 0.04)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: isSelected ? _TI.brand.withValues(alpha: 0.3) : _TI.divider,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isSelected,
              onChanged: (bool? value) async {
                HapticFeedback.selectionClick();
                setState(() {
                  if (value ?? false) {
                    if (!selectedTravellers.any((t) => t.id == traveler.id)) {
                      selectedTravellers.add(traveler);
                    }
                  } else {
                    selectedTravellers.removeWhere((t) => t.id == traveler.id);
                  }
                  _trekC.travellerDetailList.value = List.from(
                    selectedTravellers,
                  );
                  _trekC.calculateFareRequestModel.value = _trekC
                      .calculateFareRequestModel
                      .value
                      .copyWith(
                        travelerCount: resolveRequiredTravelerCount(
                          currentRequiredCount: _trekC
                              .calculateFareRequestModel
                              .value
                              .travelerCount,
                          selectedCount: selectedTravellers.length,
                        ),
                      );
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              activeColor: _TI.brand,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  traveler.name ?? '-',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: _TI.ink,
                  ),
                ),
                Text(
                  '${traveler.gender ?? '-'} • ${traveler.age ?? '-'} yrs',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9.sp,
                    color: _TI.inkMid,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: () =>
                _showTravellerBottomSheet(traveller: traveler, isEdit: true),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
              decoration: BoxDecoration(
                color: _TI.brand.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _TI.brand.withValues(alpha: 0.2)),
              ),
              child: Text(
                'Edit',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: _TI.brand,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected ? _TI.tealSoft : _TI.bg,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color: isSelected ? _TI.brand.withValues(alpha: 0.4) : _TI.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 18,
              color: isSelected ? _TI.brand : _TI.inkLight,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _TI.ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9.sp,
                      color: _TI.inkMid,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: isBold ? _TI.ink : _TI.inkMid,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: isBold ? 13.sp : 10.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? _TI.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodOption({
    required Widget icon,
    required String label,
    required String subtitle,
    required bool isSelected,
    bool isLocked = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? _TI.tealSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(3.w),
        ),
        child: Row(
          children: [
            icon,
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: _TI.ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8.sp,
                      color: _TI.inkMid,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              Icon(Icons.lock_outline_rounded, size: 16, color: _TI.inkLight)
            else
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 18,
                color: isSelected ? _TI.brand : _TI.inkLight,
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
            fontSize: 14.sp,
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
        color: _TI.divider,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: SvgPicture.asset(svgPath, width: 22, height: 22)),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) return '${parts[2]}-${parts[1]}-${parts[0]}';
      return dateString;
    } catch (_) {
      return dateString;
    }
  }

  String _calculateEndDate(String? startDate, int? durationDays) {
    if (startDate == null || startDate.isEmpty || durationDays == null)
      return '-';
    try {
      final start = DateTime.parse(startDate);
      final end = start.add(Duration(days: durationDays));
      return '${end.day.toString().padLeft(2, '0')}-${end.month.toString().padLeft(2, '0')}-${end.year}';
    } catch (_) {
      return '-';
    }
  }
}
