import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/models/treaks/treak_detail_modal.dart';
import 'package:arobo_app/models/user_profile/user_profile_modal.dart';
import 'package:arobo_app/utils/booking_constants.dart';
import 'package:arobo_app/utils/common_btn.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/total_fare_modal.dart';

/// Screen for collecting traveller information and managing booking details
/// Handles user contact details, traveller selection, and payment options
class TravellerInformationScreen extends StatefulWidget {
  const TravellerInformationScreen({Key? key}) : super(key: key);

  @override
  State<TravellerInformationScreen> createState() =>
      _TravellerInformationScreenState();
}

class _TravellerInformationScreenState extends State<TravellerInformationScreen>
    with SingleTickerProviderStateMixin {
  final TrekController _trekControllerC = Get.find<TrekController>();
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final UserController _userC = Get.find<UserController>();
  late TrekDetailData travelData;
  final nameNode = FocusNode();
  int _adultCount = 0;
  String _selectedState = BookingConstants.defaultState;
  List<String> filteredStates = [];
  bool _whatsappUpdates = false;
  String _selectedPaymentOption = BookingConstants.fullPayment;
  bool _freeCancellation = false;
  String _selectedInsuranceOption = BookingConstants.addInsurance;
  final GlobalKey _checkboxKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _showOverlay = false;
  String _selectedGender = BookingConstants.defaultGender;

  // List to store selected traveller data
  List<Travelers> selectedTravellers = [];

  bool isShowContactUpdate = false;
  bool isTravellerUpdate = false;
  bool isShowTravellerForm = false; // New state to control form visibility

  // Add state variable for coupon section visibility
  bool _isCouponSectionExpanded = true;

  @override
  void initState() {
    super.initState();
    filteredStates = _dashboardC.stateList
        .map((element) => element.name!)
        .toList();

    // Add listeners to update state when text changes
    travelData = _trekControllerC.trekDetailData.value;

    // Ensure payment option is 'full' if cancellation policy is not Flexible
    if (travelData.cancellationPolicy?.id != 1) {
      _selectedPaymentOption = BookingConstants.fullPayment;
    }

    // Show traveller form if no existing travellers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_userC.userProfileData.value.customer?.travelers?.isEmpty ?? true) {
        setState(() {
          isShowTravellerForm = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    nameNode.dispose();
    _userC.nameControllerTraveller.value.clear();
    _userC.ageControllerTraveller.value.clear();
    _userC.selectedGender.value = '';
    isShowTravellerForm = false;

    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _showOverlay = false;
  }

  // Method to format date from "2025-09-05" to "05-09-2025"
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '-';
    }

    try {
      // Split the date string by '-'
      List<String> dateParts = dateString.split('-');
      if (dateParts.length == 3) {
        // Reorder from YYYY-MM-DD to DD-MM-YYYY
        return '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';
      }
      return dateString; // Return original if format is unexpected
    } catch (e) {
      return dateString; // Return original if parsing fails
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

      // Format as DD-MM-YYYY
      String day = end.day.toString().padLeft(2, '0');
      String month = end.month.toString().padLeft(2, '0');
      String year = end.year.toString();

      return '$day-$month-$year';
    } catch (e) {
      return '-';
    }
  }

  void _showTickOverlay(BuildContext context) {
    _removeOverlay();

    final RenderBox? checkbox =
        _checkboxKey.currentContext?.findRenderObject() as RenderBox?;
    if (checkbox == null) return;

    final position = checkbox.localToGlobal(Offset.zero);
    final size = checkbox.size;

    final checkboxCenterX = position.dx + (size.width / 2);
    final checkboxCenterY = position.dy + (size.height / 2);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Starburst rays
          ...List.generate(12, (index) {
            final angle = (index * (360 / 12)) * (pi / 180);
            return Positioned(
              left: checkboxCenterX - 2,
              top: checkboxCenterY - 2,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(
                      cos(angle) * (40 * value),
                      sin(angle) * (40 * value),
                    ),
                    child: Opacity(
                      opacity: 1 - value,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: CommonColors.lightBlueColor2,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          // Floating checks with scale effect
          ...List.generate(6, (index) {
            final angle = (index * (360 / 6)) * (pi / 180);
            final delay = (index * 100);

            return Positioned(
              left: checkboxCenterX - 15,
              top: checkboxCenterY - 15,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  // Add a delay to each check
                  final delayedValue = value == 0
                      ? 0.0
                      : ((value * 1000 - delay) / (800 - delay)).clamp(
                          0.0,
                          1.0,
                        );

                  // Floating motion
                  final yOffset = sin(value * pi * 2) * 20;
                  final distance = 60 * delayedValue;

                  return Transform.translate(
                    offset: Offset(
                      cos(angle) * distance,
                      (sin(angle) * distance) + yOffset,
                    ),
                    child: Transform.scale(
                      scale: delayedValue * (1 - delayedValue * 0.5),
                      child: Opacity(
                        opacity: 1 - delayedValue,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: CommonColors.whiteColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: CommonColors.lightBlueColor2.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check,
                            color: CommonColors.lightBlueColor2,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                onEnd: index == 0 ? _removeOverlay : null,
              ),
            );
          }),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _showOverlay = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CommonColors.whiteColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: CommonColors.transparent,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: CommonColors.blackColor),
        titleSpacing: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: CommonColors.greyColor, height: 1.5),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              textScaler: const TextScaler.linear(1.0),
              'Traveller Information',
              style: GoogleFonts.poppins(
                fontSize: FontSize.s11,
                fontWeight: FontWeight.w600,
                color: CommonColors.blackColor,
              ),
            ),
            Row(
              children: [
                Text(
                  _dashboardC.fromController.value.text,
                  textScaler: const TextScaler.linear(1.0),
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s9,
                    fontWeight: FontWeight.w400,
                    color: CommonColors.blackColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.arrow_forward_outlined,
                    color: CommonColors.grey_AEAEAE,
                    size: 16,
                  ),
                ),
                Text(
                  _dashboardC.toController.value.text,
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
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 8, right: 8, top: 9, bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Slot Booking Details Section
              Container(
                width: 99.w,
                height: 15.h,
                decoration: BoxDecoration(
                  color: CommonColors.materialLightBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 99.w,
                      // height: 1.9.h,
                      margin: const EdgeInsets.only(top: 14),
                      child: Column(
                        children: [
                          Text(
                            'A round-trip trek covering',
                            textScaler: const TextScaler.linear(1.0),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s9,
                              fontWeight: FontWeight.w400,
                              color: CommonColors.blackColor,
                            ),
                          ),
                          Text(
                            travelData.title ?? '-',
                            textScaler: const TextScaler.linear(1.0),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s9,
                              fontWeight: FontWeight.w700,
                              color: CommonColors.blackColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      width: 99.w,
                      height: 5.8.h,
                      decoration: BoxDecoration(),
                      margin: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        bottom: 14,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  textScaler: const TextScaler.linear(1.0),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _formatDate(
                                        travelData.batchInfo?.startDate,
                                      ),
                                      // '${_getDayAndDate(travelData.batchInfo?.startDate ?? '-')} ',
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s9,
                                        fontWeight: FontWeight.w500,
                                        color: CommonColors.blackColor,
                                      ),
                                    ),
                                    // Text(
                                    //   _getTime(
                                    //       travelData.batchInfo?.startDate ??
                                    //           '-'),
                                    //   style: GoogleFonts.poppins(
                                    //     fontSize: FontSize.s9,
                                    //     fontWeight: FontWeight.w400,
                                    //     color: CommonColors.blackColor,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              Text(
                                _dashboardC.fromController.value.text,
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s8,
                                  fontWeight: FontWeight.w400,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 14, right: 14),
                            padding: const EdgeInsets.only(
                              left: 8,
                              right: 8,
                              top: 4,
                              bottom: 4,
                            ),
                            decoration: BoxDecoration(
                              color: CommonColors.whiteColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${travelData.durationDays}D|${travelData.durationNights}N',
                              textAlign: TextAlign.center,
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s9,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.blackColor,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  textScaler: const TextScaler.linear(1.0),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _calculateEndDate(
                                        travelData.batchInfo?.startDate,
                                        travelData.durationDays,
                                      ),
                                      textScaler: const TextScaler.linear(1.0),
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s9,
                                        fontWeight: FontWeight.w500,
                                        color: CommonColors.blackColor,
                                      ),
                                    ),
                                    // Text(
                                    //   _getTime(_calculateEndDate(
                                    //       widget.trek.departureDate,
                                    //       widget.trek.duration)),
                                    //   textScaler: const TextScaler.linear(1.0),
                                    //   style: GoogleFonts.poppins(
                                    //     fontSize: FontSize.s9,
                                    //     fontWeight: FontWeight.w500,
                                    //     color: CommonColors.blackColor,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              Text(
                                _dashboardC.toController.value.text,
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s8,
                                  fontWeight: FontWeight.w400,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: CommonColors.whiteColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: CommonColors.blackColor.withValues(alpha: 0.2),
                        offset: Offset(2, 2),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Text(
                            'Travellers',
                            textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s14,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.blackColor,
                            ),
                          ),
                        ),
                      ),
                      Container(height: 1.5, color: CommonColors.greyColor),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 46.0,
                          right: 28.0,
                          top: 15.0,
                          bottom: 13.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Adults',
                                  textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s11,
                                    fontWeight: FontWeight.w600,
                                    color: CommonColors.blackColor,
                                  ),
                                ),
                                Text(
                                  '18+ years',
                                  textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s9,
                                    fontWeight: FontWeight.w400,
                                    color: CommonColors.blackColor.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (_adultCount > 0) {
                                        _adultCount--;
                                        // Clear selected travellers if they exceed the new count
                                        if (selectedTravellers.length >
                                            _adultCount) {
                                          selectedTravellers =
                                              selectedTravellers
                                                  .take(_adultCount)
                                                  .toList();
                                        }
                                      }
                                    });
                                    _trekControllerC.trekPersonCount.value =
                                        _adultCount;
                                    _trekControllerC.travellerDetailList.value =
                                        selectedTravellers;
                                  },
                                  child: Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _adultCount > 0
                                            ? CommonColors.blackColor
                                            : CommonColors.grey_AEAEAE,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.remove,
                                        size: 20,
                                        color: _adultCount > 0
                                            ? CommonColors.blackColor
                                            : CommonColors.grey_AEAEAE,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: Text(
                                    '$_adultCount',
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s14,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.blackColor,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (_adultCount <
                                        (travelData.batchInfo?.availableSlots ??
                                            0)) {
                                      setState(() {
                                        _adultCount++;
                                      });
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Maximum available slots reached (${(travelData.batchInfo?.availableSlots ?? 0)})',
                                            textScaler: const TextScaler.linear(
                                              1.0,
                                            ),
                                          ),
                                          backgroundColor:
                                              CommonColors.appRedColor,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                    _trekControllerC.trekPersonCount.value =
                                        _adultCount;
                                  },
                                  child: Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            _adultCount <
                                                (travelData
                                                        .batchInfo
                                                        ?.availableSlots ??
                                                    0)
                                            ? CommonColors.materialBlue
                                            : CommonColors.grey_AEAEAE,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.add,
                                        size: 20,
                                        color:
                                            _adultCount <
                                                (travelData
                                                        .batchInfo
                                                        ?.availableSlots ??
                                                    0)
                                            ? CommonColors.materialBlue
                                            : CommonColors.grey_AEAEAE,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              //If contact details is there in userprofile then show it
              if (_userC.userProfileData.value.customer?.email != null &&
                  _userC.userProfileData.value.customer?.phone != null)
                SizedBox(
                  width: 100.w,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                    child: Container(
                      // elevation: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.w),
                        boxShadow: [
                          BoxShadow(
                            color: CommonColors.blackColor.withValues(
                              alpha: 0.2,
                            ),
                            offset: Offset(2, 2),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                        color: CommonColors.whiteColor,
                      ),
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(5.w),
                      // ),
                      child: Container(
                        width: 100.w,
                        margin: EdgeInsets.only(
                          left: 6.w,
                          right: 6.w,
                          top: 1.5.h,
                          bottom: 1.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Contact Details',
                                  textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.alexandria(
                                    fontSize: FontSize.s14,
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.blackColor,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isShowContactUpdate =
                                          !isShowContactUpdate;
                                      _userC.phoneNumberController.value.text =
                                          (_userC
                                                      .userProfileData
                                                      .value
                                                      .customer
                                                      ?.phone ??
                                                  '-')
                                              .replaceFirst('+91', '');
                                      _userC.emailController.value.text =
                                          _userC
                                              .userProfileData
                                              .value
                                              .customer
                                              ?.email ??
                                          '-';
                                      _userC.stateUpdateId.value = _userC
                                          .userProfileData
                                          .value
                                          .customer!
                                          .state!
                                          .id!;
                                      _selectedState =
                                          _userC
                                              .userProfileData
                                              .value
                                              .customer
                                              ?.state
                                              ?.name ??
                                          '-';
                                    });
                                  },
                                  child: Text(
                                    'Edit',
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.alexandria(
                                      fontSize: FontSize.s10,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.materialBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 0.3.h),
                            Text(
                              'Trip ticket details will be provided to',
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s8,
                                color: CommonColors.blackColor.withValues(
                                  alpha: 0.6,
                                ),
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            SizedBox(height: 2.h),
                            // Phone Row for the existing user data
                            Container(
                              color: CommonColors.whiteColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: 1.w,
                                vertical: 1.h,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: SvgPicture.asset(CommonImages.phone),
                                  ),
                                  SizedBox(width: 3.w),
                                  // Phone Number and Label
                                  Expanded(
                                    child: Text(
                                      _userC
                                              .userProfileData
                                              .value
                                              .customer
                                              ?.phone ??
                                          '-',
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s11,
                                        color: CommonColors.blackColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Email Row for the existing user data
                            Container(
                              color: CommonColors.whiteColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: 1.w,
                                vertical: 1.h,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: SvgPicture.asset(CommonImages.email),
                                  ),
                                  SizedBox(width: 3.w),
                                  // Phone Number and Label
                                  Expanded(
                                    child: Text(
                                      _userC
                                              .userProfileData
                                              .value
                                              .customer
                                              ?.email ??
                                          '-',
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s11,
                                        color: CommonColors.blackColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //
                            // State of Residence for user data
                            Container(
                              color: CommonColors.whiteColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: 1.w,
                                vertical: 1.h,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: SvgPicture.asset(
                                      CommonImages.location4,
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  // Phone Number and Label
                                  Expanded(
                                    child: Text(
                                      _userC
                                                  .userProfileData
                                                  .value
                                                  .customer
                                                  ?.state
                                                  ?.id !=
                                              null
                                          ? _dashboardC
                                                    .stateList[_dashboardC
                                                        .stateList
                                                        .indexWhere(
                                                          (element) =>
                                                              element.id ==
                                                              _userC
                                                                  .userProfileData
                                                                  .value
                                                                  .customer
                                                                  ?.state
                                                                  ?.id,
                                                        )]
                                                    .name ??
                                                '-'
                                          : '-',
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s11,
                                        color: CommonColors.blackColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // WhatsApp row for the existing user data
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (isShowContactUpdate ||
                  _userC.userProfileData.value.customer?.email == null ||
                  _userC.userProfileData.value.customer?.phone == null ||
                  _userC.userProfileData.value.customer?.state?.id == null)
                SizedBox(height: 2.h),
              if (isShowContactUpdate ||
                  _userC.userProfileData.value.customer?.email == null ||
                  _userC.userProfileData.value.customer?.phone == null ||
                  _userC.userProfileData.value.customer?.state?.id == null)
                SizedBox(
                  width: 100.w,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                    child: Container(
                      // elevation: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.w),
                        boxShadow: [
                          BoxShadow(
                            color: CommonColors.blackColor.withValues(
                              alpha: 0.2,
                            ),
                            offset: Offset(2, 2),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                        color: CommonColors.whiteColor,
                      ),
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(5.w),
                      // ),
                      child: Container(
                        width: 100.w,
                        margin: EdgeInsets.only(
                          left: 6.w,
                          right: 6.w,
                          top: 1.5.h,
                          bottom: 1.5.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Contact Details',
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.alexandria(
                                      fontSize: FontSize.s14,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.blackColor,
                                    ),
                                  ),
                                ),
                                if (isShowContactUpdate)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isShowContactUpdate =
                                            !isShowContactUpdate;
                                      });
                                    },
                                    icon: Icon(Icons.cancel_outlined),
                                  ),
                              ],
                            ),
                            SizedBox(height: 0.3.h),
                            Text(
                              'Trip ticket details will be provided to',
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s8,
                                color: CommonColors.blackColor.withValues(
                                  alpha: 0.6,
                                ),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            // Phone Row
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: CommonColors.greyColor878787),
                                borderRadius: BorderRadius.circular(2.w),
                                color: CommonColors.whiteColor,
                              ),
                              child: Row(
                                children: [
                                  // Country code
                                  Container(
                                    width: 27.w,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 1.2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: CommonColors.greyColor878787,
                                          width: 0.25.w,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Country Code',
                                          textScaler: const TextScaler.linear(
                                            1.0,
                                          ),
                                          style: GoogleFonts.poppins(
                                            fontSize: FontSize.s7,
                                            color: CommonColors.blackColor,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        SizedBox(height: 0.4.h),
                                        Text(
                                          '+91(IND)',
                                          textScaler: const TextScaler.linear(
                                            1.0,
                                          ),
                                          style: GoogleFonts.poppins(
                                            fontSize: FontSize.s10,
                                            fontWeight: FontWeight.w400,
                                            color: CommonColors.blackColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Phone number
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 3.w,
                                        right: 3.w,
                                        top: 0.8.h,
                                        bottom: 0.8.h,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Phone Number',
                                            textScaler: const TextScaler.linear(
                                              1.0,
                                            ),
                                            style: GoogleFonts.poppins(
                                              fontSize: FontSize.s7,
                                              color: CommonColors.blackColor,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          MediaQuery(
                                            data: MediaQuery.of(context)
                                                .copyWith(
                                                  textScaler: TextScaler.linear(
                                                    1.0,
                                                  ),
                                                ),
                                            child: TextField(
                                              enabled: false,
                                              controller: _userC
                                                  .phoneNumberController
                                                  .value,
                                              keyboardType: TextInputType.phone,
                                              maxLength: 10,
                                              style: GoogleFonts.poppins(
                                                fontSize: FontSize.s10,
                                                color: CommonColors.blackColor,
                                              ),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                counterText: '',
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 1.8.h),
                            // Email
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: CommonColors.greyColor878787),
                                borderRadius: BorderRadius.circular(2.w),
                                color: CommonColors.whiteColor,
                              ),
                              padding: EdgeInsets.only(
                                left: 4.w,
                                top: 0.8.h,
                                bottom: 0.8.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email ID',
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s7,
                                      color: CommonColors.blackColor,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  MediaQuery(
                                    data: MediaQuery.of(context).copyWith(
                                      textScaler: TextScaler.linear(1.0),
                                    ),
                                    child: TextField(
                                      controller: _userC.emailController.value,
                                      keyboardType: TextInputType.emailAddress,
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s10,
                                        fontWeight: FontWeight.w400,
                                        color: CommonColors.blackColor,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 1.8.h),
                            // State
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: CommonColors.greyColor878787),
                                borderRadius: BorderRadius.circular(2.w),
                                color: CommonColors.whiteColor,
                              ),
                              child: Material(
                                color: CommonColors.transparent,
                                child: InkWell(
                                  onTap: _showStateSelectionBottomSheet,
                                  borderRadius: BorderRadius.circular(2.w),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 1.h,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'State of Residence',
                                              textScaler:
                                                  const TextScaler.linear(1.0),
                                              style: GoogleFonts.poppins(
                                                fontSize: FontSize.s7,
                                                color: CommonColors.blackColor,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                            SizedBox(height: 0.25.h),
                                            Text(
                                              _selectedState,
                                              textScaler:
                                                  const TextScaler.linear(1.0),
                                              style: GoogleFonts.poppins(
                                                fontSize: FontSize.s10,
                                                fontWeight: FontWeight.w400,
                                                color: CommonColors.blackColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          color: CommonColors.blackColor,
                                          size: 6.w,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            // WhatsApp row
                            // Row(
                            //   crossAxisAlignment: CrossAxisAlignment.center,
                            //   children: [
                            //     SvgPicture.asset(
                            //       CommonImages.whatsappIcon,
                            //       width: 9.w,
                            //       height: 9.w,
                            //     ),
                            //     SizedBox(width: 2.5.w),
                            //     Expanded(
                            //       child: Text(
                            //         'Share booking details and trek updates via WhatsApp',
                            //         textScaler: const TextScaler.linear(1.0),
                            //         style: GoogleFonts.poppins(
                            //           fontSize: FontSize.s8,
                            //           fontWeight: FontWeight.w300,
                            //           color: CommonColors.blackColor
                            //               .withValues(alpha: 0.7),
                            //         ),
                            //       ),
                            //     ),
                            //     Transform.scale(
                            //       scale: 0.8,
                            //       child: Switch.adaptive(
                            //         activeColor: CommonColors.whiteColor,
                            //         activeTrackColor: CommonColors
                            //             .completedColor
                            //             .withValues(alpha: 0.8),
                            //         inactiveTrackColor:
                            //             CommonColors.shimmerBaseColor,
                            //         inactiveThumbColor: CommonColors.blackColor,
                            //         value: _whatsappUpdates,
                            //         onChanged: (value) {
                            //           setState(() {
                            //             _whatsappUpdates = value;
                            //           });
                            //         },
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            CommonButton(
                              height: 48,
                              gradient: CommonColors.filterGradient,
                              text: 'Save',
                              textColor: CommonColors.whiteColor,
                              onPressed: () async {
                                await _userC.updateUserProfile();
                                setState(() {
                                  isShowContactUpdate = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 2.h),

              // Existing Travellers Section - Only show when there are existing travellers
              if (_userC
                      .userProfileData
                      .value
                      .customer
                      ?.travelers
                      ?.isNotEmpty ??
                  false)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: CommonColors.whiteColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: CommonColors.blackColor.withValues(alpha: 0.2),
                          offset: Offset(2, 2),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Traveller Details',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s14,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.blackColor,
                            ),
                          ),
                          if (_adultCount > 0) ...[
                            SizedBox(height: 1.h),
                            Text(
                              'Select up to $_adultCount traveller${_adultCount > 1 ? 's' : ''} (${selectedTravellers.length}/$_adultCount selected)',
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s9,
                                fontWeight: FontWeight.w400,
                                color: CommonColors.blackColor.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                          SizedBox(height: 2.h),
                          // Static traveller list
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount:
                                _userC
                                    .userProfileData
                                    .value
                                    .customer
                                    ?.travelers
                                    ?.length ??
                                0,
                            itemBuilder: (context, index) {
                              final traveler = _userC
                                  .userProfileData
                                  .value
                                  .customer
                                  ?.travelers?[index];
                              return Column(
                                children: [
                                  _buildExistingTravellerItem(
                                    travelData: traveler!,
                                    isSelected:
                                        selectedTravellers.any(
                                          (traveller) =>
                                              traveller.id == traveler.id,
                                        ) ??
                                        false,
                                  ),
                                  if (index !=
                                      (_userC
                                                  .userProfileData
                                                  .value
                                                  .customer
                                                  ?.travelers
                                                  ?.length ??
                                              0) -
                                          1)
                                    SizedBox(height: 1.h),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (isShowTravellerForm) SizedBox(height: 2.h),

              // Single Traveller Detail Section - Only show when needed
              if (isShowTravellerForm ||
                  (_userC.userProfileData.value.customer?.travelers?.isEmpty ??
                      true))
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: CommonColors.whiteColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: CommonColors.blackColor.withValues(alpha: 0.2),
                          offset: Offset(2, 2),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(
                        left: 33,
                        right: 33,
                        top: 23,
                        bottom: 23,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Traveller Details',
                                  textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.alexandria(
                                    fontSize: FontSize.s14,
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.blackColor,
                                  ),
                                ),
                              ),
                              if (isTravellerUpdate || isShowTravellerForm)
                                IconButton(
                                  onPressed: () {
                                    isTravellerUpdate = false;
                                    isShowTravellerForm = false;
                                    FocusScope.of(context).unfocus();
                                    _userC.nameControllerTraveller.value
                                        .clear();
                                    _userC.ageControllerTraveller.value.clear();
                                    _userC.selectedGender.value = '';
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.cancel_outlined),
                                ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          _buildTextField(
                            _userC.nameControllerTraveller.value,
                            'Name',
                            focusNode: nameNode,
                          ),
                          SizedBox(height: 2.h),
                          _buildTextField(
                            _userC.ageControllerTraveller.value,
                            'Age',
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 1.7.h),
                          Text(
                            'Gender',
                            textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s11,
                              fontWeight: FontWeight.w300,
                              color: CommonColors.blackColor.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              _buildGenderButton('Male'),
                              SizedBox(width: 2.w),
                              _buildGenderButton('Female'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 2.5.h),

              // Add New Traveller Button
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                width: 100.w,
                decoration: BoxDecoration(
                  color: CommonColors.whiteColor,
                  borderRadius: BorderRadius.circular(6.w),
                  boxShadow: [
                    BoxShadow(
                      color: CommonColors.blackColor.withValues(alpha: 0.2),
                      offset: Offset(2, 2),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Material(
                  color: CommonColors.transparent,
                  child: InkWell(
                    onTap: () async {
                      // If form is not visible and we have existing travellers, show the form
                      if (!isShowTravellerForm &&
                          (_userC
                                  .userProfileData
                                  .value
                                  .customer
                                  ?.travelers
                                  ?.isNotEmpty ??
                              false)) {
                        setState(() {
                          isShowTravellerForm = true;
                        });
                        return;
                      }

                      // If form is visible or no existing travellers, proceed with add/update
                      if (isTravellerUpdate) {
                        await _userC.updateTraveler();
                        setState(() {
                          isTravellerUpdate = false;
                          isShowTravellerForm = false;
                        });
                      } else {
                        await _userC.addTraveler();
                        setState(() {
                          isShowTravellerForm = false;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(6.w),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 1.2.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            CommonImages.adduser,
                            width: 7.5.w,
                            height: 7.5.w,
                          ),
                          SizedBox(width: 2.5.w),
                          Text(
                            isTravellerUpdate
                                ? 'Update Traveller'
                                : isShowTravellerForm
                                ? 'Add Traveller'
                                : 'Add New Traveller',
                            textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s14,
                              fontWeight: FontWeight.w600,
                              color: CommonColors.blackColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              // Payment Details
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: CommonColors.whiteColor,
                    borderRadius: BorderRadius.circular(5.w),
                    boxShadow: [
                      BoxShadow(
                        color: CommonColors.blackColor.withValues(alpha: 0.2),
                        offset: Offset(2, 2),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  // margin: EdgeInsets.symmetric(horizontal: 5.75.w),
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lock your spot. Pay now.',
                                  // textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s9,
                                    fontWeight: FontWeight.w400,
                                    color: CommonColors.blackColor,
                                  ),
                                ),
                                Text(
                                  'Adventure\'s calling!',
                                  // textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s14,
                                    fontWeight: FontWeight.w600,
                                    color: CommonColors.blackColor,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.5.h),
                      // Pay ₹999 Section - Only show for Flexible cancellation policy (ID = 1)
                      if (travelData.cancellationPolicy?.id == 1) ...[
                        Container(
                          width: 100.w,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedPaymentOption == 'partial'
                                  ? CommonColors.materialBlue
                                  : CommonColors.greyColor878787,
                            ),
                            borderRadius: BorderRadius.circular(2.w),
                            color: CommonColors.whiteColor,
                          ),
                          child: Material(
                            color: CommonColors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedPaymentOption = 'partial';
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: 7.5.w,
                                  right: 6.25.w,
                                  top: 2.1.h,
                                  bottom: 1.5.h,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MediaQuery(
                                          data: MediaQuery.of(context).copyWith(
                                            textScaler: const TextScaler.linear(
                                              1.0,
                                            ),
                                          ),
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Pay ₹',
                                                  style: GoogleFonts.roboto(
                                                    fontSize: FontSize.s11,
                                                    fontWeight: FontWeight.w400,
                                                    color:
                                                        CommonColors.blackColor,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '999',
                                                  style: GoogleFonts.roboto(
                                                    fontSize: FontSize.s11,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        CommonColors.blackColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _getTotalFareSubtitleText(),
                                          textScaler: const TextScaler.linear(
                                            1.0,
                                          ),
                                          style: GoogleFonts.roboto(
                                            fontSize: FontSize.s7,
                                            fontWeight: FontWeight.w400,
                                            color: CommonColors.blackColor
                                                .withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 6.w,
                                      height: 6.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient:
                                            _selectedPaymentOption == 'partial'
                                            ? CommonColors.radioBtnGradient
                                            : null,
                                        border:
                                            _selectedPaymentOption == 'partial'
                                            ? null
                                            : Border.all(
                                                color:
                                                    CommonColors.greyColor585858,
                                                width: 0.5.w,
                                              ),
                                        color: CommonColors.whiteColor,
                                      ),
                                      child: _selectedPaymentOption == 'partial'
                                          ? Center(
                                              child: Container(
                                                width: 2.w,
                                                height: 2.w,
                                                decoration: const BoxDecoration(
                                                  color: CommonColors.whiteColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.5.h),
                      ],
                      Container(
                        width: 100.w,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedPaymentOption == 'full'
                                ? CommonColors.materialBlue
                                : CommonColors.greyColor878787,
                          ),
                          borderRadius: BorderRadius.circular(2.w),
                          color: CommonColors.whiteColor,
                        ),
                        child: Material(
                          color: CommonColors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPaymentOption = 'full';
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                left: 7.5.w,
                                right: 6.25.w,
                                top: 2.1.h,
                                bottom: 1.5.h,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                          textScaler: const TextScaler.linear(
                                            1.0,
                                          ),
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Pay Full ',
                                                style: GoogleFonts.roboto(
                                                  fontSize: FontSize.s11,
                                                  fontWeight: FontWeight.w400,
                                                  color:
                                                      CommonColors.blackColor,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'Payment',
                                                style: GoogleFonts.roboto(
                                                  fontSize: FontSize.s11,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      CommonColors.blackColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Secure your booking with full payment',
                                        textScaler: const TextScaler.linear(
                                          1.0,
                                        ),
                                        style: GoogleFonts.roboto(
                                          fontSize: FontSize.s7,
                                          fontWeight: FontWeight.w400,
                                          color: CommonColors.blackColor
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 6.w,
                                    height: 6.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: _selectedPaymentOption == 'full'
                                          ? CommonColors.radioBtnGradient
                                          : null,
                                      border: _selectedPaymentOption == 'full'
                                          ? null
                                          : Border.all(
                                              color:
                                                  CommonColors.greyColor585858,
                                              width: 0.5.w,
                                            ),
                                      color: CommonColors.whiteColor,
                                    ),
                                    child: _selectedPaymentOption == 'full'
                                        ? Center(
                                            child: Container(
                                              width: 2.w,
                                              height: 2.w,
                                              decoration: const BoxDecoration(
                                                color: CommonColors.whiteColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.5.h),

              // Free Cancellation
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                child: Container(
                  // margin: EdgeInsets.symmetric(horizontal: 6.5.w),
                  decoration: BoxDecoration(
                    gradient: CommonColors.filterGradient2,
                    boxShadow: [
                      BoxShadow(
                        color: CommonColors.blackColor.withValues(alpha: 0.2),
                        offset: Offset(2, 2),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(5.w),
                  ),
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 6.w,
                      right: 3.w,
                      top: 2.h,
                      bottom: 2.5.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Free Cancellation',
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s15,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.blackColor,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        RichText(
                          textScaler: const TextScaler.linear(1.0),
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    'A fee of ₹90 per person will be charged for a full refund on ticket cancellations made ',
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s8,
                                  fontWeight: FontWeight.w300,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                              TextSpan(
                                text: 'T&C',
                                style: GoogleFonts.roboto(
                                  fontSize: FontSize.s8,
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.materialBlue,
                                ),
                              ),
                              TextSpan(
                                text: ' at least 24 hours prior to departure',
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s8,
                                  fontWeight: FontWeight.w300,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _freeCancellation = !_freeCancellation;
                              if (_freeCancellation) {
                                _showTickOverlay(context);
                              }
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                key: _checkboxKey,
                                width: 6.25.w,
                                height: 6.25.w,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: CommonColors.lightBlueColor2
                                        .withValues(alpha: 0.7),
                                    width: 0.5.w,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                  color: _freeCancellation
                                      ? CommonColors.lightBlueColor2
                                      : CommonColors.whiteColor,
                                ),
                                child: _freeCancellation
                                    ? Icon(
                                        Icons.check,
                                        size: 5.w,
                                        color: CommonColors.whiteColor,
                                      )
                                    : null,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'I would like to choose the free\ncancellation option',
                                // textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.roboto(
                                  fontSize: FontSize.s7,
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.5.h),

              // Travel Insurance Container
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                child: Container(
                  // margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: CommonColors.whiteColor,
                    borderRadius: BorderRadius.circular(5.w),
                    boxShadow: [
                      BoxShadow(
                        color: CommonColors.blackColor.withValues(alpha: 0.2),
                        offset: Offset(2, 2),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Container(
                    width: 100.w,
                    margin: EdgeInsets.only(
                      left: 6.w,
                      right: 6.w,
                      top: 2.2.h,
                      bottom: 2.8.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Center(
                              child: Image.asset(
                                CommonImages.logo,
                                width: 12.5.w,
                                height: 12.5.w,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Travel Insurance',
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s14,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.blackColor,
                                    ),
                                  ),
                                  Text(
                                    'Secure your trek, enjoy the adventure',
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s7,
                                      fontWeight: FontWeight.w400,
                                      color: CommonColors.blackColor.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  GestureDetector(
                                    onTap: () {
                                      // Handle view covers navigation
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          'View covers',
                                          textScaler: const TextScaler.linear(
                                            1.0,
                                          ),
                                          style: GoogleFonts.poppins(
                                            fontSize: FontSize.s7,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.materialBlue,
                                          ),
                                        ),
                                        SizedBox(width: 1.w),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 3.5.w,
                                          color: CommonColors.materialBlue,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.5.h),
                        // Insurance Options
                        Container(
                          width: 100.w,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedInsuranceOption == 'add'
                                  ? CommonColors.materialBlue
                                  : CommonColors.greyColor878787,
                            ),
                            borderRadius: BorderRadius.circular(2.w),
                            color: CommonColors.whiteColor,
                          ),
                          child: Material(
                            color: CommonColors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedInsuranceOption = 'add';
                                });
                              },
                              borderRadius: BorderRadius.circular(2.w),
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: 6.25.w,
                                  right: 5.w,
                                  top: 1.25.h,
                                  bottom: 1.5.h,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Add Travel Insurance',
                                          textScaler: const TextScaler.linear(
                                            1.0,
                                          ),
                                          style: GoogleFonts.roboto(
                                            fontSize: FontSize.s11,
                                            fontWeight: FontWeight.w400,
                                            color: CommonColors.blackColor,
                                          ),
                                        ),
                                        Text(
                                          '₹80 for 1 Traveller',
                                          textScaler: const TextScaler.linear(
                                            1.0,
                                          ),
                                          style: GoogleFonts.roboto(
                                            fontSize: FontSize.s7,
                                            fontWeight: FontWeight.w400,
                                            color: CommonColors.blackColor
                                                .withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 6.w,
                                      height: 6.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient:
                                            _selectedInsuranceOption == 'add'
                                            ? CommonColors.radioBtnGradient
                                            : null,
                                        border:
                                            _selectedInsuranceOption == 'add'
                                            ? null
                                            : Border.all(
                                                color: CommonColors
                                                    .greyColor585858,
                                                width: 0.5.w,
                                              ),
                                        color: CommonColors.whiteColor,
                                      ),
                                      child: _selectedInsuranceOption == 'add'
                                          ? Center(
                                              child: Container(
                                                width: 2.w,
                                                height: 2.w,
                                                decoration: const BoxDecoration(
                                                  color: CommonColors.whiteColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.875.h),
                        Container(
                          width: 100.w,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedInsuranceOption == 'dont_add'
                                  ? CommonColors.materialBlue
                                  : CommonColors.greyColor878787,
                            ),
                            borderRadius: BorderRadius.circular(2.w),
                            color: CommonColors.whiteColor,
                          ),
                          child: Material(
                            color: CommonColors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedInsuranceOption = 'dont_add';
                                });
                              },
                              borderRadius: BorderRadius.circular(2.w),
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: 6.25.w,
                                  right: 5.w,
                                  top: 1.25.h,
                                  bottom: 1.5.h,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Don't add Travel Insurance",
                                      textScaler: const TextScaler.linear(1.0),
                                      style: GoogleFonts.roboto(
                                        fontSize: FontSize.s11,
                                        fontWeight: FontWeight.w400,
                                        color: CommonColors.blackColor,
                                      ),
                                    ),
                                    Container(
                                      width: 6.w,
                                      height: 6.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient:
                                            _selectedInsuranceOption ==
                                                'dont_add'
                                            ? CommonColors.radioBtnGradient
                                            : null,
                                        border:
                                            _selectedInsuranceOption ==
                                                'dont_add'
                                            ? null
                                            : Border.all(
                                                color: CommonColors
                                                    .greyColor585858,
                                                width: 0.5.w,
                                              ),
                                        color: CommonColors.whiteColor,
                                      ),
                                      child:
                                          _selectedInsuranceOption == 'dont_add'
                                          ? Center(
                                              child: Container(
                                                width: 2.w,
                                                height: 2.w,
                                                decoration: const BoxDecoration(
                                                  color: CommonColors.whiteColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 3.75.h),

              // Review Booking Section
              // Container(
              //   margin: EdgeInsets.symmetric(horizontal: 4.w),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text(
              //             "Review booking",
              //             textScaler: const TextScaler.linear(1.0),
              //             style: GoogleFonts.poppins(
              //               fontSize: FontSize.s14,
              //               fontWeight: FontWeight.w500,
              //               color: CommonColors.blackColor,
              //             ),
              //           ),
              //           // GestureDetector(
              //           //   onTap: () {
              //           //     // TODO: Navigate to slot booking details
              //           //     showModalBottomSheet(
              //           //       context: context,
              //           //       isScrollControlled: true,
              //           //       backgroundColor: CommonColors.transparent,
              //           //       builder: (context) => SlotBookingDetailsModal(
              //           //         trekName: widget.trek.name,
              //           //         adultCount: _adultCount,
              //           //         fromLocation: widget.fromLocation,
              //           //         toLocation: widget.toLocation,
              //           //         departureDate: widget.trek.departureDate,
              //           //         duration: widget.trek.duration,
              //           //         email: _emailController.text,
              //           //         phone: _phoneController.text,
              //           //         travellers: _travellers,
              //           //         // Pass the list of traveller data
              //           //         baseAmount: double.parse(
              //           //             widget.trek.price.replaceAll(',', '')),
              //           //         // Pass base amount
              //           //         discountAmount: _discountAmount,
              //           //         // Pass discount amount
              //           //         isInsurance: _selectedInsuranceOption == 'add',
              //           //         // Pass insurance status
              //           //         isFreeCancellation:
              //           //             _freeCancellation, // Pass free cancellation status
              //           //       ),
              //           //     );
              //           //   },
              //           //   child: Text(
              //           //     "View details",
              //           //     textScaler: const TextScaler.linear(1.0),
              //           //     style: GoogleFonts.roboto(
              //           //       fontSize: FontSize.s11,
              //           //       fontWeight: FontWeight.w500,
              //           //       color: CommonColors.materialBlue,
              //           //     ),
              //           //   ),
              //           // ),
              //         ],
              //       ),
              //       SizedBox(height: 0.5.h),
              //       Row(
              //         children: [
              //           Text(
              //             "$_adultCount Traveller:",
              //             textScaler: const TextScaler.linear(1.0),
              //             style: GoogleFonts.poppins(
              //               fontSize: FontSize.s9,
              //               fontWeight: FontWeight.w600,
              //               color: CommonColors.blackColor,
              //             ),
              //           ),
              //           Text(
              //             " $_adultCount Adults/ From ${_dashboardC.fromController.value.text}",
              //             textScaler: const TextScaler.linear(1.0),
              //             style: GoogleFonts.poppins(
              //               fontSize: FontSize.s9,
              //               fontWeight: FontWeight.w300,
              //               color: CommonColors.blackColor,
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 2.h),
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.start,
              //         children: [
              //           Text(
              //             _dashboardC.fromController.value.text,
              //             textScaler: const TextScaler.linear(1.0),
              //             style: GoogleFonts.poppins(
              //               fontSize: FontSize.s9,
              //               fontWeight: FontWeight.w500,
              //               color: CommonColors.blackColor,
              //             ),
              //           ),
              //           SizedBox(width: 3.w),
              //           Icon(
              //             Icons.arrow_right_alt,
              //             size: 5.w,
              //             color: CommonColors.grey_AEAEAE,
              //           ),
              //           SizedBox(width: 3.w),
              //           Text(
              //             _dashboardC.toController.value.text,
              //             textScaler: const TextScaler.linear(1.0),
              //             style: GoogleFonts.poppins(
              //               fontSize: FontSize.s9,
              //               fontWeight: FontWeight.w500,
              //               color: CommonColors.blackColor,
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 0.5.h),
              //       Row(
              //         children: [
              //           Text(
              //             travelData.batchInfo?.startDate ?? '-',
              //             // _getDayAndDate(
              //             //     travelData.batchInfo?.startDate ?? '-'),
              //             textScaler: const TextScaler.linear(1.0),
              //             style: GoogleFonts.poppins(
              //               fontSize: FontSize.s9,
              //               fontWeight: FontWeight.w400,
              //               color: CommonColors.blackColor,
              //             ),
              //           ),
              //           SizedBox(width: 1.5.w),
              //           // Text(
              //           //   _getTime(widget.trek.departureDate),
              //           //   textScaler: const TextScaler.linear(1.0),
              //           //   style: GoogleFonts.poppins(
              //           //     fontSize: FontSize.s9,
              //           //     fontWeight: FontWeight.w400,
              //           //     color: CommonColors.blackColor,
              //           //   ),
              //           // ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(height: 2.h),

              // Coupon Code Section
              // _buildCouponSection(),

              // SizedBox(height: 3.75.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: CommonColors.whiteColor,
          boxShadow: [
            BoxShadow(
              color: CommonColors.blackColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 27, right: 25, top: 10),
              child: _adultCount > 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: CommonColors.transparent,
                              builder: (context) => TotalFareModal(
                                baseAmount:
                                    (double.tryParse(
                                          (travelData.basePrice ?? '0.00'),
                                        ) ??
                                        0.00) *
                                    _adultCount,
                                isPartialPayment:
                                    _selectedPaymentOption == 'partial',
                                isInsurance: _selectedInsuranceOption == 'add',
                                isFreeCancellation: _freeCancellation,
                                adultCount: _adultCount,
                                onClose: () => Navigator.pop(context),
                                vendorDiscount: _calculateVendorDiscount(),
                                couponDiscount: _calculateCouponDiscount(
                                  _calculateFarePriceAfterVendorDiscount(),
                                ),
                                platformFee: BookingConstants.platformFee,
                                gst: _calculateGST(),
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
                                    'Total Fare',
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
                                'Tax Included',
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
                        Obx(() => RichText(
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
                        )),
                      ],
                    )
                  : SizedBox.shrink(),
            ),
            if (_adultCount > 0) SizedBox(height: 2.h),
            Padding(
              padding: const EdgeInsets.only(left: 41, right: 41, bottom: 20),
              child: CommonButton(
                text: 'Pay Now',
                fontSize: FontSize.s14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                onPressed: () {
                  if (_isFormValid) {
                    _handlePayment();
                  }
                },
                gradient: _isFormValid
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

  // String _extractDuration(String duration) {
  //   // Extract just the "3D/2N" part from "3 Days, 2 Nights"
  //   final days = duration.split(' ')[0];
  //   final nights = int.parse(days) - 1;
  //   return '${days}D/${nights}N';
  // }

  // String _calculateEndDate(String startDate, String duration) {
  //   // Parse the start date
  //   final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
  //   final DateTime start = inputFormat.parse(startDate);

  //   // Extract number of days from duration
  //   final int days = int.parse(duration.split(' ')[0]);

  //   // Calculate end date
  //   final DateTime end = start.add(Duration(days: days));

  //   // Format the end date with time
  //   return '${DateFormat('dd/MM/yyyy').format(end)} 01:00 PM';
  // }

  // String _getDayAndDate(String dateTime) {
  //   final parts = dateTime.split(' ');
  //   final date = parts[0];
  //
  //   final parsedDate = DateFormat('dd/MM/yyyy').parse(date);
  //   final dayName = DateFormat('E').format(parsedDate);
  //   final dayNum = DateFormat('dd').format(parsedDate);
  //   final month = DateFormat('MMM').format(parsedDate);
  //
  //   return '$dayName, $dayNum $month';
  // }

  // String _getTime(String dateTime) {
  //   final parts = dateTime.split(' ');
  //   if (parts.length > 1) {
  //     return '${parts[1]} ${parts[2]}';
  //   }
  //   return '';
  // }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    FocusNode? focusNode,
  }) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        focusNode: focusNode,
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: FontSize.s11,
            fontWeight: FontWeight.w300,
            color: CommonColors.blackColor.withAlpha(153), // ~0.6 alpha
          ),
          counterText: '',
          contentPadding: const EdgeInsets.only(left: 21, top: 13, bottom: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: CommonColors.greyColor878787),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: CommonColors.greyColor878787),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: CommonColors.cFF90CAF9),
          ),
          filled: true,
          fillColor: CommonColors.whiteColor,
        ),
        style: GoogleFonts.poppins(
          fontSize: FontSize.s10,
          color: CommonColors.blackColor,
        ),
      ),
    );
  }

  Widget _buildGenderButton(String gender) {
    final bool isSelected =
        _userC.selectedGender.value.toLowerCase() == gender.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _userC.selectedGender.value = gender;
          });
        },
        child: Container(
          height: 5.5.h,
          decoration: BoxDecoration(
            border: Border.all(
              color: _userC.selectedGender.value == gender
                  ? CommonColors.materialBlue
                  : CommonColors.greyColor878787,
            ),
            borderRadius: BorderRadius.circular(8),
            color: CommonColors.whiteColor,
          ),
          child: Container(
            margin: EdgeInsets.only(
              left: 4.5.w,
              right: 2.5.w,
              top: 1.h,
              bottom: 1.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  gender,
                  textScaler: const TextScaler.linear(1.0),
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s10,
                    fontWeight: FontWeight.w500,
                    color: CommonColors.blackColor.withValues(alpha: 0.6),
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected ? CommonColors.radioBtnGradient : null,
                    border: isSelected
                        ? null
                        : Border.all(
                            color: CommonColors.greyColor585858,
                            width: 2,
                          ),
                    color: CommonColors.whiteColor,
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: CommonColors.whiteColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _isFormValid {
    // First check if adult count is greater than 0
    if (_adultCount <= 0) {
      return false;
    }

    // Contact Details Validation
    bool isContactValid = false;

    // Check if user has existing contact details or if they've filled the form
    if (_userC.userProfileData.value.customer?.email != null &&
        _userC.userProfileData.value.customer?.phone != null &&
        _userC.userProfileData.value.customer?.state?.id != null &&
        !isShowContactUpdate) {
      // User has existing contact details and is not editing
      isContactValid = true;
    } else {
      // User is editing or doesn't have existing contact details
      // Check if the contact update form is filled correctly
      if (isShowContactUpdate ||
          _userC.userProfileData.value.customer?.email == null ||
          _userC.userProfileData.value.customer?.phone == null ||
          _userC.userProfileData.value.customer?.state?.id == null) {
        isContactValid =
            _userC.phoneNumberController.value.text.length == 10 &&
            RegExp(
              r'^[0-9]{10}$',
            ).hasMatch(_userC.phoneNumberController.value.text) &&
            _userC.emailController.value.text.isNotEmpty &&
            RegExp(
              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
            ).hasMatch(_userC.emailController.value.text) &&
            _userC.stateUpdateId.value != 0;
      } else {
        // Fallback to basic controllers (shouldn't happen in current flow)
        isContactValid =
            _userC.phoneNumberController.value.text.length == 10 &&
            RegExp(
              r'^[0-9]{10}$',
            ).hasMatch(_userC.phoneNumberController.value.text) &&
            _userC.emailController.value.text.isNotEmpty &&
            RegExp(
              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
            ).hasMatch(_userC.emailController.value.text) &&
            _selectedState.isNotEmpty;
      }
    }

    // Traveller validation - Check if we have enough travellers
    int totalValidTravellers = 0;

    // Count selected existing travellers
    totalValidTravellers += selectedTravellers.length;

    // Check if new traveller form is filled and valid (only if form is visible)
    bool isNewTravellerValid =
        isShowTravellerForm &&
        _userC.nameControllerTraveller.value.text.trim().isNotEmpty &&
        _userC.ageControllerTraveller.value.text.trim().isNotEmpty &&
        _userC.selectedGender.value.isNotEmpty &&
        int.tryParse(_userC.ageControllerTraveller.value.text.trim()) != null &&
        int.parse(_userC.ageControllerTraveller.value.text.trim()) > 0;

    if (isNewTravellerValid) {
      totalValidTravellers += 1;
    }

    // Must have at least the required number of adults (_adultCount)
    bool isTravellerValid = totalValidTravellers >= _adultCount;

    return isContactValid && isTravellerValid;
  }

  /// Handles the payment flow when user clicks "Continue to Payment"
  ///
  /// CALCULATION FLOW (Per Payment.md Policy):
  /// ==========================================
  /// 1. Base Fare (BF) = Trek price × Adult count
  /// 2. Vendor Discount (VD) = Discount set by vendor at trek creation
  /// 3. Fare After Vendor Discount = BF - VD
  /// 4. Coupon Discount (CD) = Discount from coupon code applied at booking
  /// 5. Net Fare (NF) = Fare After Vendor Discount - CD
  /// 6. Platform Fee (PF) = Fixed ₹15
  /// 7. **GST = 5% × Net Fare ONLY** (NOT on Net Fare + Platform Fee)
  /// 8. Insurance = ₹80 per person (if selected)
  /// 9. Free Cancellation = ₹90 per person (if selected)
  /// 10. Final Payable = NF + PF + GST + Insurance + Free Cancellation
  ///
  /// For PARTIAL PAYMENT:
  /// - Pay Now = ₹999 × Adult Count
  /// - Remaining = Final Payable - Pay Now
  ///
  /// For FULL PAYMENT:
  /// - Pay Now = Final Payable
  /// - Remaining = 0
  void _handlePayment() {
    // Calculate total amount to display to user (advance or full amount)
    String totalAmount = _calculateTotalFare();

    // IMPORTANT: Calculate final payable amount using the exact same logic as _calculateFullFareAmount
    // This is the TOTAL amount user will eventually pay (either now or later)
    double finalPayable = _calculateFullFareAmount();

    // === FARE CALCULATION BREAKDOWN ===
    // Get all the raw values and calculated components using the SAME logic as _calculateFullFareAmount

    // 1. Base Fare = Trek price per person
    double baseFare = double.tryParse((travelData.basePrice ?? '0.00')) ?? 0.00;

    // 2. Total Base Fare = Base Fare × Number of Adults
    double totalBaseFare = baseFare * _adultCount;

    // 3. Vendor Discount = Discount applied by vendor (% or flat)
    double vendorDiscount = _calculateVendorDiscount();

    // 4. Fare After Vendor Discount = Total Base Fare - Vendor Discount
    double farePriceAfterVendorDiscount = totalBaseFare - vendorDiscount;
    if (farePriceAfterVendorDiscount < 0) farePriceAfterVendorDiscount = 0;

    // 5. Coupon Discount = Discount from coupon code (applied after vendor discount)
    double couponDiscount = _calculateCouponDiscount(
      farePriceAfterVendorDiscount,
    );

    // 6. Net Fare = Fare After All Discounts (this is the TAXABLE BASE per Payment.md)
    double netFare = farePriceAfterVendorDiscount - couponDiscount;
    if (netFare < 0) netFare = 0;

    // 7. Platform Fee = Fixed ₹15 (non-refundable, part of platform revenue)
    double platformFee = BookingConstants.platformFee;

    // 8. GST CALCULATION (CRITICAL - Per Payment.md Legal Requirements):
    // ================================================================
    // GST is calculated on Net Fare ONLY (the taxable base after all discounts)
    // NOT on (Net Fare + Platform Fee)
    // This ensures proper tax compliance and correct GST reporting
    // Reference: Payment.md lines 64, 118-119, 134-138
    double gst = double.parse(
      (netFare * BookingConstants.gstRate).toStringAsFixed(2),
    ); // Round GST to 2 decimal places

    // 9. Subtotal = Net Fare + Platform Fee
    // Note: This is for reference/display only - NOT used in GST calculation
    double subtotal = netFare + platformFee;

    // 10. Add-on Fees (non-refundable, passed to insurers)
    double insuranceFee = _selectedInsuranceOption == BookingConstants.addInsurance
        ? (BookingConstants.insuranceFeePerPerson * _adultCount)
        : 0.0;
    double cancellationFee = _freeCancellation
        ? (BookingConstants.cancellationFeePerPerson * _adultCount)
        : 0.0;

    // 11. Partial Payment Amounts
    double advanceAmount = BookingConstants.partialPaymentPerPerson * _adultCount;
    double remainingAmount = _calculateRemainingAmount();

    // IMPORTANT: Always set the controller's totalAmount to the final payable amount
    // This ensures that the verify-payment API receives the correct final amount
    // regardless of whether the user chose partial or full payment
    _trekControllerC.totalAmount.value = finalPayable;

    Get.toNamed(
      BookingRoutes.payment,
      arguments: {
        // Basic booking info
        'totalAmount': totalAmount,
        'adultCount': _adultCount,
        'selectedPaymentOption': _selectedPaymentOption,
        'selectedInsuranceOption': _selectedInsuranceOption,
        'freeCancellation': _freeCancellation,

        // Raw trek data
        'basePrice': travelData.basePrice ?? '0.00',
        'hasDiscount': travelData.hasDiscount ?? false,
        'discountType': travelData.discountType ?? '',
        'discountValue': travelData.discountValue ?? '',

        // Calculated fare components
        'baseFare': baseFare,
        'totalBaseFare': totalBaseFare,
        'vendorDiscount': vendorDiscount,
        'farePriceAfterVendorDiscount': farePriceAfterVendorDiscount,
        'couponDiscount': couponDiscount,
        'netFare': netFare,
        'platformFee': platformFee,
        'subtotal': subtotal,
        'gst': gst,
        'insuranceFee': insuranceFee,
        'cancellationFee': cancellationFee,
        'finalPayable': finalPayable,

        // Partial payment specific
        'advanceAmount': advanceAmount,
        'remainingAmount': remainingAmount,

        // Final amounts
        'fullFareAmount': finalPayable,
      },
    );
  }

  /// Calculates the total fare amount to display to user
  ///
  /// Per Payment.md Policy:
  /// - PARTIAL PAYMENT: Advance + Platform Fee + GST + Add-ons (Pay Now amount)
  /// - FULL PAYMENT: Complete final amount
  ///
  /// Payment.md BASE-001 Example (1 Adult, ₹5,999 fare, no discounts, partial):
  /// - Pay Now: ₹999 + ₹15 + ₹299.95 = ₹1,313.95 ✓
  /// - Balance Later: ₹5,000 (paid before trek start)
  ///
  /// Payment.md COUP-041 Example (1 Adult, ₹5,999 fare, ₹500 coupon, partial):
  /// - Pay Now: ₹999 + ₹15 + ₹274.95 = ₹1,288.95 ✓
  /// - Balance Later: ₹4,500 (paid before trek start)
  String _calculateTotalFare() {
    if (_selectedPaymentOption == BookingConstants.partialPayment) {
      // For PARTIAL PAYMENT:
      // Pay Now = Advance + Platform Fee + GST + Add-ons

      // Calculate all components
      double baseFare = double.tryParse(travelData.basePrice ?? '0.00') ?? 0.0;
      double totalBaseFare = baseFare * _adultCount;
      double vendorDiscount = _calculateVendorDiscount();
      double farePrice = totalBaseFare - vendorDiscount;
      if (farePrice < 0) farePrice = 0;
      double couponDiscount = _calculateCouponDiscount(farePrice);
      double netFare = farePrice - couponDiscount;
      if (netFare < 0) netFare = 0;

      // Calculate fees
      double platformFee = BookingConstants.platformFee;
      double gst = netFare * BookingConstants.gstRate;
      double insuranceFee = _selectedInsuranceOption == BookingConstants.addInsurance
          ? (BookingConstants.insuranceFeePerPerson * _adultCount)
          : 0.0;
      double cancellationFee = _freeCancellation
          ? (BookingConstants.cancellationFeePerPerson * _adultCount)
          : 0.0;
      double advanceAmount = BookingConstants.partialPaymentPerPerson * _adultCount;

      // Pay Now = Advance + Platform Fee + GST + Add-ons
      double payNow = advanceAmount + platformFee + gst + insuranceFee + cancellationFee;

      // Calculate remaining (Balance Later = Net Fare - Advance)
      double remaining = netFare - advanceAmount;

      return payNow.toStringAsFixed(0);
    } else {
      // For FULL PAYMENT: Show complete final amount
      double finalPayable = _calculateFullFareAmount();

      return finalPayable.toStringAsFixed(0);
    }
  }

  /// Calculates the complete final payable amount including all fees and discounts
  ///
  /// This is the TOTAL amount the user will eventually pay (either upfront or split into advance + remaining)
  ///
  /// FORMULA (Per Payment.md Policy):
  /// =================================
  /// Final Payable = Net Fare + Platform Fee + GST + Insurance + Free Cancellation
  ///
  /// Where:
  /// - Net Fare = (Base Fare × Adults) - Vendor Discount - Coupon Discount
  /// - Platform Fee = ₹15 (fixed, non-refundable)
  /// - GST = 5% × Net Fare ONLY (NOT on Net Fare + Platform Fee)
  /// - Insurance = ₹80 × Adults (if selected)
  /// - Free Cancellation = ₹90 × Adults (if selected)
  ///
  /// IMPORTANT GST COMPLIANCE:
  /// ========================
  /// GST is calculated on the TAXABLE BASE (Net Fare after all discounts) ONLY.
  /// Platform Fee is NOT included in GST calculation per Payment.md legal requirements.
  /// Reference: Payment.md lines 64, 118-119, 134-138
  ///
  /// EXAMPLE (1 Adult, ₹5,999 fare, no discounts):
  /// - Net Fare: ₹5,999
  /// - Platform Fee: ₹15
  /// - GST (5% of ₹5,999): ₹299.95
  /// - Final Payable: ₹5,999 + ₹15 + ₹299.95 = ₹6,313.95
  ///
  /// EXAMPLE WITH COUPON (1 Adult, ₹5,999 fare, ₹500 coupon):
  /// - Net Fare: ₹5,499
  /// - Platform Fee: ₹15
  /// - GST (5% of ₹5,499): ₹274.95
  /// - Final Payable: ₹5,499 + ₹15 + ₹274.95 = ₹5,788.95
  double _calculateFullFareAmount() {
    // STEP 1: Base Fare (BF) = Price set by vendor per person
    double baseFare = double.tryParse((travelData.basePrice ?? '0.00')) ?? 0.00;

    // STEP 2: Total Base Fare = Base Fare × Number of Adults
    double totalBaseFare = baseFare * _adultCount;

    // STEP 3: Vendor Discount (VD) = % or flat discount defined at trek creation
    double vendorDiscount = _calculateVendorDiscount();

    // STEP 4: Fare After Vendor Discount = Total Base Fare - Vendor Discount
    double farePrice = totalBaseFare - vendorDiscount;
    if (farePrice < 0) farePrice = 0;

    // STEP 5: Coupon Discount (CD) = Applied at booking (flat / % with cap / conditional)
    double couponDiscount = _calculateCouponDiscount(farePrice);

    // STEP 6: Net Fare (NF) = Fare After All Discounts
    // This is the TAXABLE BASE for GST calculation per Payment.md
    double netFare = farePrice - couponDiscount;
    if (netFare < 0) netFare = 0;

    // STEP 7: Platform Fee (PF) = Fixed ₹15 (non-refundable, part of platform revenue)
    double platformFee = BookingConstants.platformFee;

    // STEP 8: GST CALCULATION (CRITICAL - Per Payment.md Legal Requirements)
    // =======================================================================
    // GST is calculated on Net Fare ONLY (the taxable base after all discounts)
    // Formula: GST = Net Fare × 5%
    // NOT: GST = (Net Fare + Platform Fee) × 5%
    //
    // Why? Per Indian GST law and Payment.md policy:
    // - Discounts reduce the taxable value
    // - Platform Fee is a separate service charge (not part of trek fare)
    // - GST is only on the actual trek service value (Net Fare)
    //
    // Reference: Payment.md lines 64, 118-119, 134-138
    double gst = (netFare * BookingConstants.gstRate);

    // STEP 9: Calculate Base Final Payable = Net Fare + Platform Fee + GST
    double basePayable = netFare + platformFee + gst;

    // STEP 10: Add Insurance fee if selected (₹80 per person, non-refundable)
    double insuranceFee = _selectedInsuranceOption == BookingConstants.addInsurance
        ? (BookingConstants.insuranceFeePerPerson * _adultCount)
        : 0.0;
    basePayable += insuranceFee;

    // STEP 11: Add Free Cancellation fee if selected (₹90 per person)
    // Note: This allows advance refund if cancelled >24h before trek
    double cancellationFee = _freeCancellation
        ? (BookingConstants.cancellationFeePerPerson * _adultCount)
        : 0.0;
    basePayable += cancellationFee;

    // STEP 12: Round to 2 decimal places for currency consistency
    // This ensures the displayed amount matches what's charged
    return double.parse(basePayable.toStringAsFixed(2));
  }

  /// Calculates the remaining amount to be paid after advance payment
  ///
  /// Used for PARTIAL PAYMENT option where user pays advance now and rest later
  ///
  /// FORMULA PER PAYMENT.MD POLICY:
  /// ================================
  /// Balance Later (Remaining) = Net Fare - Advance Payment
  ///
  /// Why NOT (Final Payable - Advance)?
  /// Because Platform Fee, GST, and Add-ons are already paid upfront with advance!
  ///
  /// Payment.md BASE-001 Example (1 Adult, ₹5,999 fare, no discounts):
  /// - Net Fare: ₹5,999
  /// - Advance: ₹999
  /// - Platform Fee: ₹15
  /// - GST: ₹299.95 (5% of Net Fare)
  /// - Pay Now: ₹999 + ₹15 + ₹299.95 = ₹1,313.95
  /// - Balance Later: ₹5,999 - ₹999 = ₹5,000 ✓ CORRECT
  ///
  /// Payment.md COUP-041 Example (1 Adult, ₹5,999 fare, ₹500 coupon):
  /// - Net Fare: ₹5,999 - ₹500 = ₹5,499
  /// - Advance: ₹999
  /// - Platform Fee: ₹15
  /// - GST: ₹274.95 (5% of ₹5,499)
  /// - Pay Now: ₹999 + ₹15 + ₹274.95 = ₹1,288.95
  /// - Balance Later: ₹5,499 - ₹999 = ₹4,500 ✓ CORRECT
  ///
  /// This remaining amount is:
  /// 1. Sent to backend API (createTrekOrder, verifyTrekOrder)
  /// 2. Displayed to user in booking confirmation
  /// 3. Due before trek start date
  /// 4. Does NOT include Platform Fee, GST, or Add-ons (already paid upfront)
  double _calculateRemainingAmount() {
    // STEP 1: Base Fare (BF) = Original trek price per person from API
    double baseFare = double.tryParse(travelData.basePrice ?? '0.00') ?? 0.0;

    // STEP 2: Total Base Fare = Base Fare × Number of Adults
    double totalBaseFare = baseFare * _adultCount;

    // STEP 3: Vendor Discount (VD) = % or flat discount defined at trek creation
    double vendorDiscount = _calculateVendorDiscount();

    // STEP 4: Fare After Vendor Discount
    double farePrice = totalBaseFare - vendorDiscount;
    if (farePrice < 0) farePrice = 0;

    // STEP 5: Coupon Discount (CD) = Applied at booking (flat / % with cap / conditional)
    double couponDiscount = _calculateCouponDiscount(farePrice);

    // STEP 6: Net Fare (NF) = Fare After All Discounts
    // This is the taxable base per Payment.md
    double netFare = farePrice - couponDiscount;
    if (netFare < 0) netFare = 0;

    // STEP 7: Calculate Advance Payment (₹999 per adult)
    double advanceAmount = BookingConstants.partialPaymentPerPerson * _adultCount;

    // STEP 8: Calculate Balance Later (Remaining Amount)
    // Formula: Balance Later = Net Fare - Advance
    // This is what user will pay before trek (does NOT include Platform Fee, GST, Add-ons)
    double remaining = netFare - advanceAmount;

    // Ensure remaining is never negative (edge case protection)
    // Round to 2 decimal places
    return remaining > 0 ? double.parse(remaining.toStringAsFixed(2)) : 0;
  }

  // Method to get the subtitle text for total fare
  String _getTotalFareSubtitleText() {
    if (_selectedPaymentOption == BookingConstants.partialPayment) {
      double remaining = _calculateRemainingAmount();
      return 'Advance Paid ₹999, Pay ₹${remaining.toStringAsFixed(0)} before trek start';
    } else {
      return 'Secure your booking with full payment';
    }
  }

  Future<void> _showStateSelectionBottomSheet() async {
    TextEditingController searchController = TextEditingController();

    // Reset filtered states to show all states initially
    setState(() {
      filteredStates = _dashboardC.stateList
          .map((element) => element.name!)
          .toList();
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CommonColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 2.5.h,
                  left: 5.w,
                  right: 5.w,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Select state of residence",
                      textScaler: const TextScaler.linear(1.0),
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s14,
                        fontWeight: FontWeight.w600,
                        color: CommonColors.blackColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      height: 6.h,
                      padding: EdgeInsets.symmetric(horizontal: 2.5.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [CommonColors.whiteColor, CommonColors.cFFF8FBFF],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(3.75.w),
                        border: Border.all(
                          color: CommonColors.cFFD5D5D5,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: CommonColors.grey500, size: 6.w),
                          SizedBox(width: 2.5.w),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: "Search State",
                                border: InputBorder.none,
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: FontSize.s10,
                                  color: CommonColors.blackColor.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s10,
                                color: CommonColors.blackColor,
                              ),
                              onChanged: (value) {
                                setModalState(() {
                                  filteredStates = _dashboardC.stateList
                                      .map((element) => element.name!)
                                      .toList()
                                      .where(
                                        (state) => state.toLowerCase().contains(
                                          value.toLowerCase(),
                                        ),
                                      )
                                      .toList();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.25.h),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredStates.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              filteredStates[index],
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s10,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.blackColor,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _userC.stateUpdateId.value = _dashboardC
                                    .stateList[_dashboardC.stateList.indexWhere(
                                      (element) =>
                                          element.name == filteredStates[index],
                                    )]
                                    .id!;
                                _selectedState = filteredStates[index];
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      // Reset filtered states when modal is closed
      setState(() {
        filteredStates = _dashboardC.stateList
            .map((element) => element.name!)
            .toList();
      });
    });
  }

  // Add method to handle coupon application
  // void _applyCoupon() {
  //   setState(() {
  //     if (_couponController.text.isEmpty) {
  //       _couponError = 'Please enter a coupon code';
  //       return;
  //     }
  //
  //     // Find the coupon from our predefined list
  //     final coupon = CouponData.coupons.firstWhere(
  //       (c) => c.code == _couponController.text,
  //       orElse: () => Coupon(
  //         code: '',
  //         discount: '',
  //         description: '',
  //         sideText: '',
  //         isValid: false,
  //       ),
  //     );
  //
  //     if (coupon.isValid) {
  //       _appliedCoupon = coupon;
  //       _isCouponValid = true;
  //       _couponError = null;
  //
  //       // Calculate discount based on coupon type
  //       double baseAmount =
  //           double.tryParse((travelData.price ?? '0.00')) ?? 0.00;
  //       if (coupon.code == 'TREK100') {
  //         _discountAmount = 100.0;
  //       } else if (coupon.code == 'EXPLORE50') {
  //         _discountAmount = min(baseAmount * 0.5, 500.0); // 50% up to ₹500
  //       } else if (coupon.code == 'ADVENTURE250') {
  //         _discountAmount = baseAmount >= 5000 ? 250.0 : 0.0;
  //       } else if (coupon.code == 'WEEKENDTREK') {
  //         _discountAmount = 150.0;
  //       }
  //     } else {
  //       _appliedCoupon = null;
  //       _isCouponValid = false;
  //       _discountAmount = 0.0;
  //       _couponError = 'Invalid coupon code';
  //     }
  //   });
  // }

  // Update the coupon code section UI
  // Widget _buildCouponSection() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 4.w),
  //     width: 100.w,
  //     decoration: BoxDecoration(
  //       color: CommonColors.whiteColor,
  //       borderRadius: BorderRadius.circular(4.w),
  //       boxShadow: [
  //         BoxShadow(
  //           color: CommonColors.blackColor.withValues(alpha: 0.1),
  //           blurRadius: 10,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           width: 100.w,
  //           margin: EdgeInsets.only(
  //             left: 4.w,
  //             right: 4.w,
  //             top: 2.4.h,
  //             bottom: _isCouponSectionExpanded ? 2.4.h : 2.h,
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 children: [
  //                   SvgPicture.asset(
  //                     CommonImages.couponIcon,
  //                     width: 6.w,
  //                     height: 6.w,
  //                   ),
  //                   SizedBox(width: 2.w),
  //                   Text(
  //                     "Coupon Code",
  //                     textScaler: const TextScaler.linear(1.0),
  //                     style: GoogleFonts.poppins(
  //                       fontSize: FontSize.s14,
  //                       fontWeight: FontWeight.w500,
  //                       color: CommonColors.blackColor,
  //                     ),
  //                   ),
  //                   const Spacer(),
  //                   GestureDetector(
  //                     onTap: () {
  //                       setState(() {
  //                         _isCouponSectionExpanded = !_isCouponSectionExpanded;
  //                       });
  //                     },
  //                     child: AnimatedRotation(
  //                       duration: const Duration(milliseconds: 300),
  //                       turns: _isCouponSectionExpanded ? 0 : 0.5,
  //                       child: Icon(
  //                         Icons.keyboard_arrow_down,
  //                         size: 7.w,
  //                         color: CommonColors.blackColor,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               AnimatedCrossFade(
  //                 duration: const Duration(milliseconds: 300),
  //                 crossFadeState: _isCouponSectionExpanded
  //                     ? CrossFadeState.showFirst
  //                     : CrossFadeState.showSecond,
  //                 firstChild: Column(
  //                   children: [
  //                     SizedBox(height: 2.h),
  //                     Container(
  //                       decoration: BoxDecoration(
  //                         color: CommonColors.whiteColor,
  //                         borderRadius: BorderRadius.circular(3.w),
  //                         border: Border.all(
  //                           color: CommonColors.greyColor,
  //                           width: 0.3.w,
  //                         ),
  //                       ),
  //                       child: Row(
  //                         children: [
  //                           Expanded(
  //                             child: GestureDetector(
  //                               onTap: () async {
  //                                 final result =
  //                                     await Get.toNamed('/coupon-code');
  //                                 if (result != null) {
  //                                   setState(() {
  //                                     _couponController.text =
  //                                         result.toString();
  //                                     // Reset coupon state when new coupon is selected
  //                                     _isCouponValid = false;
  //                                     _appliedCoupon = null;
  //                                     _discountAmount = 0.0;
  //                                     _couponError = null;
  //                                     _applyCoupon(); // Apply the coupon immediately
  //                                   });
  //                                 }
  //                               },
  //                               child: AbsorbPointer(
  //                                 child: TextField(
  //                                   controller: _couponController,
  //                                   textCapitalization:
  //                                       TextCapitalization.characters,
  //                                   decoration: InputDecoration(
  //                                     hintText: "Enter Coupon Code",
  //                                     hintStyle: GoogleFonts.poppins(
  //                                       fontSize: FontSize.s11,
  //                                       color: CommonColors.blackColor
  //                                           .withValues(alpha: 0.3),
  //                                     ),
  //                                     border: InputBorder.none,
  //                                     contentPadding: EdgeInsets.symmetric(
  //                                       horizontal: 4.w,
  //                                       vertical: 1.5.h,
  //                                     ),
  //                                   ),
  //                                   style: GoogleFonts.poppins(
  //                                     fontSize: FontSize.s11,
  //                                     color: CommonColors.blackColor,
  //                                   ),
  //                                   onChanged: (value) {
  //                                     setState(() {
  //                                       // Reset coupon state when text changes
  //                                       _isCouponValid = false;
  //                                       _appliedCoupon = null;
  //                                       _discountAmount = 0.0;
  //                                       _couponError = null;
  //                                       if (value != value.toUpperCase()) {
  //                                         _couponController.value =
  //                                             _couponController.value.copyWith(
  //                                           text: value.toUpperCase(),
  //                                           selection: TextSelection.collapsed(
  //                                               offset: value.length),
  //                                         );
  //                                       }
  //                                     });
  //                                   },
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           Container(
  //                             decoration: BoxDecoration(
  //                               gradient: _isCouponValid
  //                                   ? CommonColors.btnGradient
  //                                   : (_couponController.text.isNotEmpty
  //                                       ? CommonColors.btnGradient
  //                                       : CommonColors.disableBtnGradient),
  //                               borderRadius: BorderRadius.horizontal(
  //                                 right: Radius.circular(3.w),
  //                               ),
  //                             ),
  //                             child: Material(
  //                               color: CommonColors.transparent,
  //                               child: InkWell(
  //                                 onTap: _isCouponValid
  //                                     ? null // Disable tap when coupon is already applied
  //                                     : (_couponController.text.isNotEmpty
  //                                         ? _applyCoupon
  //                                         : null),
  //                                 borderRadius: BorderRadius.horizontal(
  //                                   right: Radius.circular(3.w),
  //                                 ),
  //                                 child: Padding(
  //                                   padding: EdgeInsets.symmetric(
  //                                     horizontal: 5.w,
  //                                     vertical: 1.5.h,
  //                                   ),
  //                                   child: Text(
  //                                     _isCouponValid ? "Applied" : "Apply",
  //                                     style: GoogleFonts.poppins(
  //                                       fontSize: FontSize.s11,
  //                                       fontWeight: FontWeight.w500,
  //                                       color: CommonColors.whiteColor,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     if (_couponError != null) ...[
  //                       SizedBox(height: 1.h),
  //                       Padding(
  //                         padding: EdgeInsets.only(left: 1.w),
  //                         child: Text(
  //                           _couponError!,
  //                           style: GoogleFonts.poppins(
  //                             fontSize: FontSize.s7,
  //                             color: CommonColors.appRedColor,
  //                             fontWeight: FontWeight.w400,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ],
  //                 ),
  //                 secondChild: SizedBox.shrink(),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Add this method to the class
  Widget _buildExistingTravellerItem({
    required Travelers travelData,
    required bool isSelected,
  }) {
    // Check if this traveller is currently selected
    bool isTravellerSelected = selectedTravellers.any(
      (traveller) => traveller.id == travelData.id,
    );

    // Check if we can select more travellers
    bool canSelectMore = selectedTravellers.length < _adultCount;

    // Check if new traveller form is filled (this would count as one more traveller)
    bool isNewTravellerValid =
        isShowTravellerForm &&
        _userC.nameControllerTraveller.value.text.trim().isNotEmpty &&
        _userC.ageControllerTraveller.value.text.trim().isNotEmpty &&
        _userC.selectedGender.value.isNotEmpty;

    // If new traveller form is filled, reduce available slots by 1
    int availableSlots = isNewTravellerValid ? _adultCount - 1 : _adultCount;
    bool canSelect =
        isTravellerSelected || selectedTravellers.length < availableSlots;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: CommonColors.grey300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isTravellerSelected,
                onChanged: canSelect
                    ? (bool? value) {
                        setState(() {
                          if (value ?? false) {
                            // Add to selected travellers if not already present
                            if (!selectedTravellers.any(
                              (traveller) => traveller.id == travelData.id,
                            )) {
                              selectedTravellers.add(travelData);
                            }
                          } else {
                            // Remove from selected travellers
                            selectedTravellers.removeWhere(
                              (traveller) => traveller.id == travelData.id,
                            );
                          }

                          _trekControllerC.travellerDetailList.value =
                              selectedTravellers;
                        });
                      }
                    : null, // Disable checkbox if can't select
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: CommonColors.materialBlue,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    travelData.name ?? '-',
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w500,
                      color: canSelect
                          ? CommonColors.blackColor
                          : CommonColors.blackColor.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    '${travelData.gender}, ${travelData.age}',
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s9,
                      fontWeight: FontWeight.w400,
                      color: canSelect
                          ? CommonColors.blackColor.withValues(alpha: 0.6)
                          : CommonColors.blackColor.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                isTravellerUpdate = true;
                isShowTravellerForm = true;
                _userC.travellerId.value = travelData.id ?? 0;
                _userC.nameControllerTraveller.value.text =
                    travelData.name ?? '-';
                _userC.ageControllerTraveller.value.text =
                    travelData.age.toString() ?? '-';
                _userC.selectedGender.value =
                    travelData.gender?.toLowerCase() ?? '-';
                setState(() {});
                FocusScope.of(context).requestFocus(nameNode);
              },
              child: Text(
                'Edit',
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s9,
                  fontWeight: FontWeight.w500,
                  color: CommonColors.materialBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets the current coupon discount from TrekController
  /// This ensures consistency with payment screen calculations
  double _calculateCouponDiscount(double farePrice) {
    // Get the coupon discount from TrekController if a coupon is applied
    return _trekControllerC.discountAmount.value;
  }

  /// Calculates vendor discount based on trek configuration
  /// Supports both percentage and fixed amount discounts
  double _calculateVendorDiscount() {
    if (travelData.hasDiscount == true && travelData.discountValue != null) {
      double totalBaseFare =
          (double.tryParse((travelData.basePrice ?? '0.00')) ?? 0.00) *
          _adultCount;

      if (travelData.discountType == 'percentage' ||
          travelData.discountType == '%') {
        double discountPercentage =
            double.tryParse(travelData.discountValue ?? '0') ?? 0.0;
        return totalBaseFare * (discountPercentage / 100);
      } else {
        return double.tryParse(travelData.discountValue ?? '0') ?? 0.0;
      }
    }
    return 0.0;
  }

  /// Calculates the fare after applying vendor discount
  /// Used as base amount for further calculations
  double _calculateFarePriceAfterVendorDiscount() {
    double totalBaseFare =
        (double.tryParse((travelData.basePrice ?? '0.00')) ?? 0.00) *
        _adultCount;
    double vendorDiscount = _calculateVendorDiscount();
    return totalBaseFare - vendorDiscount;
  }

  /// Calculates GST (5%) on the net fare amount ONLY
  ///
  /// CRITICAL: Per Payment.md Legal Requirements
  /// ============================================
  /// GST is applied on Net Fare after all discounts (the taxable base)
  /// NOT on (Net Fare + Platform Fee)
  ///
  /// FORMULA:
  /// ========
  /// GST = Net Fare × 5%
  ///
  /// Where Net Fare = (Base Fare × Adults) - Vendor Discount - Coupon Discount
  ///
  /// WHY NOT (Net Fare + Platform Fee)?
  /// ===================================
  /// Per Indian GST law and Payment.md policy (lines 64, 118-119, 134-138):
  /// - GST is calculated on the actual trek service value (Net Fare)
  /// - Platform Fee is a separate service charge, not part of trek fare
  /// - Discounts reduce the taxable value before GST calculation
  ///
  /// EXAMPLE (₹5,999 fare, no discounts):
  /// - Net Fare: ₹5,999
  /// - GST: ₹5,999 × 5% = ₹299.95
  /// - NOT: (₹5,999 + ₹15) × 5% = ₹300.70 ❌ WRONG
  ///
  /// EXAMPLE (₹5,999 fare, ₹500 coupon):
  /// - Net Fare: ₹5,499
  /// - GST: ₹5,499 × 5% = ₹274.95
  double _calculateGST() {
    // Step 1: Calculate fare after vendor discount
    double farePriceAfterVendorDiscount =
        _calculateFarePriceAfterVendorDiscount();

    // Step 2: Calculate coupon discount (if any)
    double couponDiscount = _calculateCouponDiscount(
      farePriceAfterVendorDiscount,
    );

    // Step 3: Calculate Net Fare (taxable base)
    double netFare = farePriceAfterVendorDiscount - couponDiscount;
    if (netFare < 0) netFare = 0;

    // Step 4: Calculate GST on Net Fare ONLY (as per Payment.md)
    // NOT on (Net Fare + Platform Fee)
    double gst = (netFare * BookingConstants.gstRate);

    // Step 5: Round to 2 decimal places for currency consistency
    return double.parse(gst.toStringAsFixed(2));
  }
}
