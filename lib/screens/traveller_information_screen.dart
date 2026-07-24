import 'dart:async';
import 'dart:math';
import 'package:arobo_app/freezed_models/booking/booking_data_model.dart';
import 'package:arobo_app/screens/coupon_code_screen.dart';
import 'package:arobo_app/screens/payment_processing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
  // Was CommonColors.trek_route_color (0xff212199, navy indigo) — same
  // fix as Trek Details: that shared token is also used by 7 other
  // screens, so it's overridden locally here rather than recolored
  // globally. Cascades to the duration badge, payment-option selection,
  // coupon CTA, and a few small tags — all forest-green now.
  static const brand = Color(0xFF2D6A4F);
  static const brandDeep = Color(0xFF1B4332);
  static const teal = CommonColors.cFF0F7B6C;
  static const tealSoft = CommonColors.cFFE6F5F3;
  static const iconBadge = CommonColors.cFF111827;
  static const divider = CommonColors.trekroutecolorlight;
  static const ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandDeep, brand],
  );
  // Completed-section treatment
  static const completedBg = Color(0xFFF3FAF8);
  static const sheetBg = Colors.white;
  static const sheetSurface = Colors.white;
  static const sheetBorder = Color(0xFFE2E8F0);
  static const sheetInk = Color(0xFF0F172A);
  static const sheetInkMid = Color(0xFF64748B);
  static const sheetHandle = Color(0xFFD1D5DB);
  static const sheetAccent = Color(0xFF111827);
  static const checkboxBorder = Color(0xFF94A3B8);
}

// ─────────────────────────────────────────────
//  SHARED SHEET STYLING HELPERS
// ─────────────────────────────────────────────
Widget _tiSheetHandle() => Center(
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
Widget _tiSheetHeader(BuildContext context, String title, IconData icon) =>
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
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: _TI.bg,
                shape: BoxShape.circle,
                border: Border.all(color: _TI.sheetBorder),
              ),
              child: Icon(Icons.close, size: 4.w, color: _TI.sheetInkMid),
            ),
          ),
        ],
      ),
    );
Widget _tiSheetInputContainer({required String label, required Widget child}) =>
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
Widget _tiSheetTextField(
  BuildContext context,
  TextEditingController controller, {
  TextInputType keyboardType = TextInputType.text,
  int? maxLength,
  FocusNode? focusNode,
  bool readOnly = false,
  List<TextInputFormatter>? inputFormatters,
  TextCapitalization textCapitalization = TextCapitalization.none,
}) => MediaQuery(
  data: MediaQuery.of(
    context,
  ).copyWith(textScaler: const TextScaler.linear(1.0)),
  child: TextField(
    controller: controller,
    keyboardType: keyboardType,
    focusNode: focusNode,
    maxLength: maxLength,
    readOnly: readOnly,
    inputFormatters: inputFormatters,
    textCapitalization: textCapitalization,
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
  String _selectedPaymentOption = 'full';
  List<Traveler> selectedTravellers = [];
  bool _isCouponExpanded = true;
  // The actual payment UI/Razorpay/verification/retry logic lives entirely
  // in PaymentProcessingScreen. This flag only exists so the fare-hold
  // countdown below doesn't auto-pop this screen while the user is on that
  // pushed screen actively paying.
  bool _isPaymentInFlight = false;
  static const int _totalTimerSecs = 5 * 60;
  final RxInt _remainingSecs = _totalTimerSecs.obs;
  bool _isTimerExpired = false;
  bool _didExitOnExpiry = false;
  Timer? _timer;
  // GetX workers — must be disposed, otherwise they keep firing after
  // this screen is popped.
  Worker? _fareDebounceWorker;
  Worker? _fareResponseWorker;
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
    // payFull must always reflect the selected option — the option tiles
    // only exist for flexible-policy treks, so without this a non-flexible
    // order could be created with a stale payFull value.
    _trekC.createOrderRequestModel.value = _trekC.createOrderRequestModel.value
        .copyWith(
          payFull: !_isFlexiblePolicy || _selectedPaymentOption == 'full',
        );
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
    _fareDebounceWorker = debounce(_trekC.calculateFareRequestModel, (value) {
      _trekC.calculateFare();
    }, time: const Duration(milliseconds: 500));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncTimerToExpiry(_currentFareResponse()?.expiresAt);
    });
    _fareResponseWorker = ever(_trekC.calculateFareResponseModel, (result) {
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
    // NOTE: never touch UserController's shared controllers here — mutating
    // controllers owned by another lifecycle is what caused the
    // "used after being disposed" red screen.
    _timer?.cancel();
    _hintTimer?.cancel();
    _fareDebounceWorker?.dispose();
    _fareResponseWorker?.dispose();
    _shakeController.dispose();
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

  void _handleTimerExpired({bool userInitiated = false}) {
    // Always record expiry, even while a payment is in flight — we
    // re-check this the moment the user returns from the payment screen.
    _isTimerExpired = true;
    if (!mounted || _isPaymentInFlight) return;
    // _didExitOnExpiry only guards the automatic pop-once behaviour (so the
    // periodic countdown timer / resync don't stack multiple pops). A direct
    // user tap on Pay Now after that must still give feedback — otherwise,
    // once auto-expiry has fired once, every subsequent tap on an already-
    // expired screen silently does nothing at all.
    if (_didExitOnExpiry && !userInitiated) return;
    _didExitOnExpiry = true;
    // Close any bottom sheet / dialog sitting above this screen first,
    // otherwise the pop below would only dismiss the sheet and the user
    // would stay on an expired checkout.
    Navigator.of(context).popUntil((route) => route is PageRoute);
    CustomSnackBar.show(
      context,
      message: 'Payment session timed out. Please start over.',
    );
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _triggerHint(String message, GlobalKey key, int targetIndex) {
    HapticFeedback.mediumImpact();
    setState(() {
      _hintMessage = message;
      _shakeTargetIndex = targetIndex;
    });
    _shakeController.forward(from: 0.0);
    final targetContext = key.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
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
  Future<void> _handlePayNow() async {
    if (_isPaymentInFlight) return;
    if (_isTimerExpired || _remainingSecs.value <= 0) {
      _handleTimerExpired(userInitiated: true);
      return;
    }
    if (!_validateBeforePayment()) return;
    setState(() => _isPaymentInFlight = true);
    _trekC.createOrderRequestModel.value = _trekC.createOrderRequestModel.value
        .copyWith(
          travelers: selectedTravellers.toList(),
          payFull: !_isFlexiblePolicy || _selectedPaymentOption == 'full',
        );
    await _trekC.createTrekOrder();
    if (!mounted) return;
    if (_trekC.orderModal.value.success ?? false) {
      final breakdown = _trekC.calculateFareResponseModel.value.maybeWhen(
        success: (r) => (r as CalculateFareResponseModel).breakdown,
        orElse: () => null,
      );
      await Get.to(
        () => PaymentProcessingScreen(
          breakdown: breakdown,
          selectedPaymentOption: _selectedPaymentOption,
        ),
      );
      if (!mounted) return;
      setState(() => _isPaymentInFlight = false);
      // Session may have expired while the user was on the payment screen.
      if (_isTimerExpired || _remainingSecs.value <= 0) {
        _handleTimerExpired();
      }
    } else {
      setState(() => _isPaymentInFlight = false);
      CustomSnackBar.show(
        context,
        message: _trekC.errorMessage.value.isNotEmpty
            ? _trekC.errorMessage.value
            : 'Could not start payment. Please try again.',
      );
    }
  }

  // ── UI HELPERS ───────────────────────────────────────────────────────────
  BoxDecoration _cardDecoration({bool isCompleted = false}) {
    return BoxDecoration(
      color: isCompleted ? _TI.completedBg : _TI.cardBg,
      borderRadius: BorderRadius.circular(4.w),
      border: Border.all(
        color: isCompleted ? _TI.teal.withValues(alpha: 0.45) : _TI.divider,
        width: isCompleted ? 1.4 : 1,
      ),
    );
  }

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
            color: isCompleted ? _TI.teal : _TI.iconBadge,
            borderRadius: BorderRadius.circular(2.5.w),
          ),
          child: Center(
            child: Icon(
              isCompleted ? Icons.check_rounded : icon,
              color: Colors.white,
              size: 4.5.w,
            ),
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

  void _showSuccessSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CommonColors.completedColor,
      ),
    );
  }

  // ── BOTTOM SHEETS ────────────────────────────────────────────────────────
  Future<void> _showContactDetailsBottomSheet({bool isEdit = false}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ContactDetailsSheet(isEdit: isEdit),
    );
    if (saved != true || !mounted) return;
    setState(() {});
    _showSuccessSnack(
      isEdit ? 'Contact details updated' : 'Contact details saved',
    );
  }

  Future<void> _showTravellerBottomSheet({Traveler? traveller}) async {
    final isEdit = traveller != null;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TravellerFormSheet(traveller: traveller),
    );
    if (saved != true || !mounted) return;
    if (isEdit) {
      // The profile was refreshed by the API call — re-map selected
      // travellers to the fresh objects so edited name/age show up.
      setState(_refreshSelectedTravellers);
    } else {
      _autoSelectNewestTraveller();
    }
    _showSuccessSnack(isEdit ? 'Traveller updated' : 'Traveller added');
  }

  void _refreshSelectedTravellers() {
    final all =
        _userC.userProfileData.value.customer?.travelers ?? const <Traveler>[];
    selectedTravellers = selectedTravellers.map((sel) {
      for (final t in all) {
        if (t.id == sel.id) return t;
      }
      return sel;
    }).toList();
    _trekC.travellerDetailList.value = List.from(selectedTravellers);
  }

  /// After creating a traveller, auto-select them if there is still an
  /// unfilled seat for this booking.
  void _autoSelectNewestTraveller() {
    final adultCount = _trekC.calculateFareRequestModel.value.travelerCount;
    final travelers =
        _userC.userProfileData.value.customer?.travelers ?? const [];
    if (travelers.isEmpty) return;
    final newTraveler = travelers.last;
    final alreadySelected = selectedTravellers.any(
      (t) => t.id == newTraveler.id,
    );
    setState(() {
      if (!alreadySelected && selectedTravellers.length < adultCount) {
        selectedTravellers.add(newTraveler);
        _trekC.travellerDetailList.value = List.from(selectedTravellers);
        _trekC.calculateFareRequestModel.value = _trekC
            .calculateFareRequestModel
            .value
            .copyWith(travelerCount: selectedTravellers.length);
      }
    });
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isPaymentInFlight,
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
                  SizedBox(height: 3.h),
                ],
              ),
            ),
            // Loading overlay
            Obx(
              () => _trekC.calculateFareResponseModel.value.maybeWhen(
                loading: (_) => Container(
                  color: Colors.black.withValues(alpha: 0.2),
                  child: const Center(
                    child: CircularProgressIndicator(color: _TI.brand),
                  ),
                ),
                orElse: () => const SizedBox(),
              ),
            ),
            if (_hintMessage != null) _buildHintPopup(),
          ],
        ),
      ),
    );
  }

  // ── SECTIONS BUILDER ──────────────────────────────────────────────────────
  Widget _buildTripSummary() {
    final vendorName = travelData.vendor?.user?.name ?? 'Aorbo Treks';
    final hasBadge =
        travelData.badge?.name != null && travelData.badge!.name!.isNotEmpty;
    final hasSlots = (travelData.availableSlots ?? 0) > 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: _cardDecoration(),
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
      decoration: _cardDecoration(isCompleted: isCompleted),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _sectionHeader(
                  'Contact Details',
                  Icons.contact_phone_outlined,
                  isCompleted: isCompleted,
                ),
              ),
              SizedBox(width: 2.w),
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
    final adultCountReq = _trekC.calculateFareRequestModel.value.travelerCount;
    final isCompleted = selectedTravellers.length >= adultCountReq;
    final savedTravellers =
        _userC.userProfileData.value.customer?.travelers ?? const [];
    return Container(
      key: _travellerCardKey,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: _cardDecoration(isCompleted: isCompleted),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Traveller Details',
            Icons.badge_outlined,
            isCompleted: isCompleted,
          ),
          SizedBox(height: 1.5.h),
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
                final maxSlots = travelData.availableSlots ?? 0;
                final canIncrement = maxSlots <= 0 || adultCount < maxSlots;
                return Row(
                  children: [
                    _counterBtn(Icons.remove, () {
                      if (adultCount <= 1) return;
                      final newCount = adultCount - 1;
                      setState(() {
                        _trekC.calculateFareRequestModel.value = _trekC
                            .calculateFareRequestModel
                            .value
                            .copyWith(travelerCount: newCount);
                        if (selectedTravellers.length > newCount) {
                          selectedTravellers = selectedTravellers
                              .take(newCount)
                              .toList();
                        }
                      });
                      _trekC.trekPersonCount.value = newCount;
                      _trekC.travellerDetailList.value = List.from(
                        selectedTravellers,
                      );
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
                      final newCount = adultCount + 1;
                      setState(() {
                        _trekC.calculateFareRequestModel.value = _trekC
                            .calculateFareRequestModel
                            .value
                            .copyWith(travelerCount: newCount);
                      });
                      _trekC.trekPersonCount.value = newCount;
                    }, active: canIncrement),
                  ],
                );
              }),
            ],
          ),
          SizedBox(height: 1.5.h),
          if (savedTravellers.isEmpty)
            Text(
              'No travellers added yet. Use "Add New Traveller" below to create one.',
              style: TextStyle(fontSize: 9.sp, color: _TI.inkMid),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: savedTravellers.length,
              separatorBuilder: (_, __) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final traveler = savedTravellers[index];
                final isSelected = selectedTravellers.any(
                  (t) => t.id == traveler.id,
                );
                return _buildExistingTravellerItem(traveler, isSelected);
              },
            ),
          SizedBox(height: 1.5.h),
          // Separate, full-width Add New Traveller button
          GestureDetector(
            onTap: () => _showTravellerBottomSheet(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 1.4.h),
              decoration: BoxDecoration(
                color: _TI.iconBadge,
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Colors.white,
                    size: 4.5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Add New Traveller',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.sp,
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
    );
  }

  Widget _buildPaymentOptionsSection() {
    if (!_isFlexiblePolicy) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: _cardDecoration(),
      child: Obx(() {
        final fareResp = _trekC.calculateFareResponseModel.value.maybeWhen(
          success: (r) => r as CalculateFareResponseModel,
          orElse: () => null,
        );
        final bd = fareResp?.breakdown;
        final advanceText = '₹${bd?.amountToPayNow ?? '--'}';
        final remainingText = '₹${bd?.remainingAmount ?? '--'}';
        final fullText = '₹${bd?.finalAmount ?? '--'}';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Payment Options', Icons.payment_outlined),
            SizedBox(height: 1.5.h),
            _payOptionTile(
              value: 'advance',
              title: 'Pay $advanceText Advance',
              subtitle: 'Pay remaining $remainingText before trek start',
              onTap: () {
                setState(() => _selectedPaymentOption = 'advance');
                _trekC.createOrderRequestModel.value = _trekC
                    .createOrderRequestModel
                    .value
                    .copyWith(payFull: false);
              },
            ),
            SizedBox(height: 1.5.h),
            _payOptionTile(
              value: 'full',
              title: 'Pay $fullText Full Amount',
              subtitle: 'Secure your booking now',
              onTap: () {
                setState(() => _selectedPaymentOption = 'full');
                _trekC.createOrderRequestModel.value = _trekC
                    .createOrderRequestModel
                    .value
                    .copyWith(payFull: true);
              },
            ),
          ],
        );
      }),
    );
  }

  Widget _payOptionTile({
    required String value,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedPaymentOption == value;
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

  Widget _buildCouponSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: _cardDecoration(),
      child: Obx(() {
        final fareReq = _trekC.calculateFareRequestModel.value;
        final fareResponse = _trekC.calculateFareResponseModel.value.maybeWhen(
          success: (r) => r as CalculateFareResponseModel,
          orElse: () => null,
        );
        final appliedCode = fareReq.couponCode ?? '';
        final discount = fareResponse?.breakdown?.discount;
        final isCouponApplied =
            appliedCode.isNotEmpty && discount != null && discount > 0;
        final discountText = discount?.toStringAsFixed(2) ?? '0.00';
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
                            const Icon(
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
                        .maybeWhen(
                          success: (r) => r as CalculateFareResponseModel,
                          orElse: () => null,
                        );
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
                            const Icon(
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
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _TI.brandDeep,
                                ),
                              ),
                              TextSpan(
                                text: '${payableNow ?? "--"}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: _TI.brandDeep,
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
                  isDisabled: _isPaymentInFlight,
                  onPressed: _handlePayNow,
                  gradient: _TI.ctaGradient,
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
                value: (_remainingSecs.value / _totalTimerSecs).clamp(0.0, 1.0),
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
        color: isSelected ? _TI.tealSoft : Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: isSelected ? _TI.teal.withValues(alpha: 0.4) : _TI.divider,
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
              onChanged: (bool? value) {
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
              activeColor: _TI.teal,
              checkColor: Colors.white,
              side: const BorderSide(color: _TI.checkboxBorder, width: 1.5),
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
            onTap: () => _showTravellerBottomSheet(traveller: traveler),
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
    if (startDate == null || startDate.isEmpty || durationDays == null) {
      return '-';
    }
    try {
      final start = DateTime.parse(startDate);
      // A trek's last day is start + (days - 1): a 2D/1N trek starting on
      // the 1st ends on the 2nd, not the 3rd.
      final end = start.add(Duration(days: (durationDays - 1).clamp(0, 365)));
      return '${end.day.toString().padLeft(2, '0')}-${end.month.toString().padLeft(2, '0')}-${end.year}';
    } catch (_) {
      return '-';
    }
  }
}

// ─────────────────────────────────────────────
//  CONTACT DETAILS SHEET
//  Owns its own controllers — created and disposed with the sheet itself,
//  never shared with any GetX controller or parent screen.
// ─────────────────────────────────────────────
class _ContactDetailsSheet extends StatefulWidget {
  const _ContactDetailsSheet({required this.isEdit});
  final bool isEdit;
  @override
  State<_ContactDetailsSheet> createState() => _ContactDetailsSheetState();
}

class _ContactDetailsSheetState extends State<_ContactDetailsSheet> {
  final UserController _userC = Get.find<UserController>();
  final DashboardController _dashboardC = Get.find<DashboardController>();
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  int _stateId = 0;
  String _stateName = BookingConstants.defaultState;
  bool _isSaving = false;
  @override
  void initState() {
    super.initState();
    final customer = _userC.userProfileData.value.customer;
    // Phone is always locked (login identity, never editable here) — so it
    // always shows the customer's actual login number, even on first-time
    // "Add Contact Details".
    _phoneCtrl = TextEditingController(
      text: (customer?.phone ?? '').replaceFirst('+91', ''),
    );
    _emailCtrl = TextEditingController(
      text: widget.isEdit ? (customer?.email ?? '') : '',
    );
    if (customer?.state?.id != null) {
      _stateId = customer!.state!.id!;
      _stateName = customer.state!.name ?? BookingConstants.defaultState;
    } else {
      // No saved state yet — the field displays BookingConstants.defaultState
      // as a convenience default, but that's just text unless backed by a
      // real id from the loaded state list. Without this, _stateId stays 0
      // and _validate() silently blocks Save even though the field already
      // shows "Telangana" as selected.
      final matches = _dashboardC.stateList.where(
        (s) => s.name == BookingConstants.defaultState,
      );
      if (matches.isNotEmpty && matches.first.id != null) {
        _stateId = matches.first.id!;
        _stateName = matches.first.name!;
      }
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    if (phone.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      CustomSnackBar.show(
        context,
        message: 'Please enter a valid 10-digit phone number',
      );
      return false;
    }
    if (email.isEmpty ||
        !RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(email)) {
      CustomSnackBar.show(
        context,
        message: 'Please enter a valid email address',
      );
      return false;
    }
    if (_stateId == 0) {
      CustomSnackBar.show(
        context,
        message: 'Please select your state of residence',
      );
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (_isSaving || !_validate()) return;
    setState(() => _isSaving = true);
    final ok = await _userC.updateProfileDetails(
      email: _emailCtrl.text.trim(),
      stateId: _stateId,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      setState(() => _isSaving = false);
    }
  }

  void _pickState() {
    showStateSelectionBottomSheet(
      context: context,
      stateList: _dashboardC.stateList,
      selectedStateId: _stateId,
      onStateSelected: (state) {
        if (!mounted) return;
        setState(() {
          _stateId = state.id ?? 0;
          _stateName = state.name ?? '';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: _TI.sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tiSheetHandle(),
            _tiSheetHeader(
              context,
              widget.isEdit ? 'Edit Contact Details' : 'Add Contact Details',
              Icons.contact_phone_outlined,
            ),
            _tiSheetInputContainer(
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
                  Container(height: 2.h, width: 1, color: _TI.sheetBorder),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _tiSheetTextField(
                      context,
                      _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      readOnly: true, // Locked — login identity
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
            _tiSheetInputContainer(
              label: 'Email ID',
              child: _tiSheetTextField(
                context,
                _emailCtrl,
                keyboardType: TextInputType.emailAddress,
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
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: InkWell(
                onTap: _pickState,
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
                          _stateName,
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
              gradient: _TI.ctaGradient,
              text: _isSaving
                  ? 'Saving...'
                  : (widget.isEdit ? 'Update' : 'Save'),
              textColor: CommonColors.whiteColor,
              onPressed: _isSaving ? () {} : _save,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TRAVELLER ADD/EDIT SHEET
//  Owns its own controllers and focus node — same lifecycle-safety rule.
// ─────────────────────────────────────────────
class _TravellerFormSheet extends StatefulWidget {
  const _TravellerFormSheet({this.traveller});

  /// null = add mode, non-null = edit mode.
  final Traveler? traveller;
  @override
  State<_TravellerFormSheet> createState() => _TravellerFormSheetState();
}

class _TravellerFormSheetState extends State<_TravellerFormSheet> {
  final UserController _userC = Get.find<UserController>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  final FocusNode _nameFocus = FocusNode();
  String _gender = '';
  bool _isSubmitting = false;
  bool get _isEdit => widget.traveller?.id != null;
  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.traveller?.name ?? '');
    _ageCtrl = TextEditingController(
      text: widget.traveller?.age?.toString() ?? '',
    );
    _gender = widget.traveller?.gender ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    final name = _nameCtrl.text.trim();
    final age = _ageCtrl.text.trim();
    if (name.isEmpty) {
      CustomSnackBar.show(context, message: 'Please enter traveller name');
      return false;
    }
    if (age.isEmpty) {
      CustomSnackBar.show(context, message: 'Please enter traveller age');
      return false;
    }
    final ageVal = int.tryParse(age);
    if (ageVal == null || ageVal <= 0 || ageVal > 120) {
      CustomSnackBar.show(context, message: 'Please enter a valid age');
      return false;
    }
    if (_gender.isEmpty) {
      CustomSnackBar.show(context, message: 'Please select gender');
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_validate()) return;
    setState(() => _isSubmitting = true);
    final ok = _isEdit
        ? await _userC.updateTravelerDetails(
            id: widget.traveller!.id!,
            name: _nameCtrl.text.trim(),
            age: _ageCtrl.text.trim(),
            gender: _gender,
          )
        : await _userC.addTravelerDetails(
            name: _nameCtrl.text.trim(),
            age: _ageCtrl.text.trim(),
            gender: _gender,
          );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _genderButton(String gender) {
    final bool isSelected = _gender.toLowerCase() == gender.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = gender),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: _TI.sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tiSheetHandle(),
            _tiSheetHeader(
              context,
              _isEdit ? 'Edit Traveller' : 'Add New Traveller',
              Icons.badge_outlined,
            ),
            _tiSheetInputContainer(
              label: 'Full Name',
              child: _tiSheetTextField(
                context,
                _nameCtrl,
                focusNode: _nameFocus,
                textCapitalization: TextCapitalization.words,
              ),
            ),
            SizedBox(height: 1.5.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 4,
                  child: _tiSheetInputContainer(
                    label: 'Age',
                    child: _tiSheetTextField(
                      context,
                      _ageCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                          _genderButton('Male'),
                          SizedBox(width: 2.w),
                          _genderButton('Female'),
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
              gradient: _TI.ctaGradient,
              text: _isSubmitting
                  ? (_isEdit ? 'Updating...' : 'Adding...')
                  : (_isEdit ? 'Update Traveller' : 'Add Traveller'),
              textColor: CommonColors.whiteColor,
              onPressed: _isSubmitting ? () {} : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
