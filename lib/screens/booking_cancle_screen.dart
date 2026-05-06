import 'package:arobo_app/utils/common_btn.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import '../controller/dashboard_controller.dart';
import '../freezed_models/booking/booking_history_model.dart';
import '../utils/common_colors.dart';
import '../utils/common_booked_details_card.dart';
import '../utils/screen_constants.dart';

class BookingsCancelScreen extends StatefulWidget {
  const BookingsCancelScreen({super.key});

  @override
  State<BookingsCancelScreen> createState() => _BookingsCancelScreenState();
}

class _BookingsCancelScreenState extends State<BookingsCancelScreen> {
  bool _isLoading = true;

  // ─────────────────────────────────────────────
  //  DESIGN TOKENS (Strictly matching TrekDetailsScreen)
  // ─────────────────────────────────────────────
  static const _bg        = CommonColors.offWhiteColor;
  static const _cardBg    = CommonColors.whiteColor;
  static const _ink       = CommonColors.blackColor;
  static const _inkMid    = CommonColors.cFF6B7280;
  static const _inkLight  = CommonColors.grey_AEAEAE;
  static const _brand     = CommonColors.trek_route_color;
  static const _teal      = CommonColors.cFF0F7B6C;
  static const _tealSoft  = CommonColors.cFFE6F5F3;
  static const _red       = CommonColors.cFFDC2626;
  static const _redSoft   = CommonColors.cFFFFE4E4;
  static const _iconBadge = CommonColors.cFF111827;
  static const _divider   = CommonColors.trekroutecolorlight;
  static const _shadow    = CommonColors.c0A000000;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() {
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dynamic arguments = Get.arguments;
    BookingHistoryData? booking;
    final DashboardController dashboardC = Get.find<DashboardController>();

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
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: _bg,
          appBar: _buildAppBar(),
          body: _isLoading
              ? _buildShimmerLoading()
              : _buildBody(dashboardC, booking!),
          bottomNavigationBar:
              _buildBottomBar(dashboardC, booking!),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  APP BAR (Matching TrekDetailsScreen exactly)
  // ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _cardBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: _ink),
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _divider),
      ),
      title: Text(
        'View refund details',
        textScaler: const TextScaler.linear(1.0),
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s14,
          fontWeight: FontWeight.w600,
          color: _ink,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BODY CONTENT
  // ─────────────────────────────────────────────
  Widget _buildBody(
      DashboardController dashboardC, BookingHistoryData booking) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 0.h),
      child: Column(
        children: [
          // Booking Card
          Container(
            margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(4.w),
              boxShadow: [
                BoxShadow(
                  color: CommonColors.blackColor.withOpacity(0.07),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: UpcomingBookingCard(booking: booking),
          ),

          SizedBox(height: 1.5.h),

          // Refund Details Card
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('Refund Summary',
                    Icons.account_balance_wallet_outlined),
                SizedBox(height: 2.h),

                // Refund Amount Block
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: _brand.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(3.w),
                    border: Border.all(color: _brand.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total refund amount',
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s10,
                          fontWeight: FontWeight.w500,
                          color: _inkMid,
                        ),
                      ),
                      Obx(
                        () => Text(
                          "₹ ${dashboardC.refundDetailData.value.refundCalculation?.refund?.toStringAsFixed(0) ?? '0'}",
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s14,
                            fontWeight: FontWeight.w700,
                            color: _brand,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.5.h),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'View cancellation policy',
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s9,
                          fontWeight: FontWeight.w600,
                          color: _brand,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_right_rounded,
                          color: _brand, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 1.5.h),

          // Ticket Card
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(
                    'Trek Ticket', Icons.confirmation_num_outlined),
                SizedBox(height: 2.h),
                _buildRow(
                  'Total amount paid (excl discounts)',
                  Obx(
                    () => Text(
                      "₹ ${dashboardC.refundDetailData.value.finalAmount?.toStringAsFixed(0) ?? booking.finalAmount ?? booking.totalAmount ?? '0'}",
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s10,
                        fontWeight: FontWeight.w500,
                        color: _ink,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 1.5.h),
                Divider(color: _divider, height: 1),
                SizedBox(height: 1.5.h),
                _buildRow(
                  'Refundable amount',
                  Obx(
                    () => Text(
                      "₹ ${dashboardC.refundDetailData.value.refundCalculation?.refund?.toStringAsFixed(0) ?? '0'}",
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w700,
                        color: _teal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 1.5.h),

          // Fare Breakup Card
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(
                    'Fare Breakup', Icons.receipt_long_outlined),
                SizedBox(height: 2.h),
                _buildRow(
                  'Amount paid (excl discount)',
                  Obx(
                    () => Text(
                      "₹ ${dashboardC.refundDetailData.value.finalAmount?.toStringAsFixed(0) ?? booking.finalAmount ?? booking.totalAmount ?? '0'}",
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s10,
                        fontWeight: FontWeight.w500,
                        color: _ink,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 1.5.h),
                _buildRow(
                  'Cancellation Charges',
                  Obx(
                    () => Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.5.w, vertical: 0.4.h),
                      decoration: BoxDecoration(
                        color: _redSoft,
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      child: Text(
                        "- ₹ ${dashboardC.refundDetailData.value.refundCalculation?.deduction?.toStringAsFixed(0) ?? '0'}",
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s10,
                          fontWeight: FontWeight.w600,
                          color: _red,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 1.5.h),
                Divider(color: _divider, height: 1),
                SizedBox(height: 1.5.h),
                _buildRow(
                  'Total refund amount',
                  Obx(
                    () => Text(
                      "₹ ${dashboardC.refundDetailData.value.refundCalculation?.refund?.toStringAsFixed(0) ?? '0'}",
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 1.5.h),

          // Cancellation Reason Card
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(
                    'Reason for Cancellation', Icons.edit_note_rounded),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 4.w, vertical: 1.2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FF),
                    borderRadius: BorderRadius.circular(3.w),
                    border: Border.all(color: _brand.withOpacity(0.12)),
                  ),
                  child: TextFormField(
                    controller: dashboardC
                        .cancellationReasonController.value,
                    maxLines: 4,
                    minLines: 3,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText:
                          'Please enter your reason for cancellation...',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s10,
                        color: _inkLight,
                        height: 1.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s10,
                      color: _ink,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 1.5.h),
                _bulletItem(
                    'Certain fees are non-refundable, as stated'),
                SizedBox(height: 0.5.h),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s10,
                      color: _inkLight,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                          text: 'Deductions are as per the '),
                      TextSpan(
                        text: 'cancellation policy',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s10,
                          color: _brand,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BOTTOM BAR (Matching TrekDetailsScreen exactly)
  // ─────────────────────────────────────────────
  Widget _buildBottomBar(
      DashboardController dashboardC, BookingHistoryData booking) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 1.5.h, 10.w, 2.5.h),
      decoration: BoxDecoration(
        color: _cardBg,
        boxShadow: [
          BoxShadow(
              color: _shadow,
              blurRadius: 12,
              offset: const Offset(0, -3)),
        ],
      ),
      child: CommonButton(
        text: 'Confirm Cancellation',
        onPressed: () =>
            _showCancellationDialog(context, booking),
        gradient: CommonColors.filterGradient,
        textColor: CommonColors.whiteColor,
        height: 6.h,
        isFullWidth: false,
        width: 50.w,
        fontSize: FontSize.s14,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SHARED WIDGETS (Exact mappings)
  // ─────────────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withOpacity(0.07),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
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
        Container(
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

  Widget _buildRow(String label, Widget valueWidget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s10,
              color: _inkMid,
              height: 1.4,
            ),
          ),
        ),
        valueWidget,
      ],
    );
  }

  Widget _bulletItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _brand,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                color: _ink,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  DIALOG (Themed natively)
  // ─────────────────────────────────────────────
  void _showCancellationDialog(
      BuildContext context, BookingHistoryData booking) {
    final DashboardController dashboardC =
        Get.find<DashboardController>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.w)),
          backgroundColor: _cardBg,
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: const BoxDecoration(
                    color: _redSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.warning_amber_rounded,
                        color: _red, size: 8.w),
                  ),
                ),
                SizedBox(height: 2.5.h),
                Text(
                  'Confirm Cancellation',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s16,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 1.5.h),
                Text(
                  'Are you sure you want to cancel this booking?',
                  textAlign: TextAlign.center,
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s10,
                    color: _inkMid,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 2.5.h),

                // Summary Block
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FF),
                    borderRadius: BorderRadius.circular(3.w),
                    border:
                        Border.all(color: _brand.withOpacity(0.12)),
                  ),
                  child: Column(
                    children: [
                      _dialogRow('Trek',
                          booking.trek?.title ?? 'Unknown Trek'),
                      Divider(
                          color: _divider.withOpacity(0.5),
                          height: 1),
                      _dialogRow(
                          'TBR ID', booking.batch?.tbrId ?? 'N/A'),
                      Divider(
                          color: _divider.withOpacity(0.5),
                          height: 1),
                      _dialogRow(
                          'Reason',
                          dashboardC
                                  .cancellationReasonController
                                  .value
                                  .text
                                  .isEmpty
                              ? 'No reason provided'
                              : dashboardC
                                  .cancellationReasonController
                                  .value
                                  .text),
                      Divider(
                          color: _divider.withOpacity(0.5),
                          height: 1),
                      _dialogRow(
                          'Refund Amount',
                          '₹${dashboardC.refundDetailData.value.refundCalculation?.refund?.toStringAsFixed(0) ?? '0'}',
                          valueColor: _teal,
                          isBold: true),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFF0F2F5),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(3.w)),
                        ),
                        child: Text(
                          'Cancel',
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s12,
                            fontWeight: FontWeight.w600,
                            color: _inkMid,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      flex: 2,
                      child: TextButton(
                        onPressed: () async {
                          await dashboardC.reqCancellation(
                            bookingId: booking.id!,
                            bookingData: booking,
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: _red,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(3.w)),
                        ),
                        child: Text(
                          'Yes, Cancel',
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dialogRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s10,
              fontWeight: FontWeight.w500,
              color: _inkMid,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                fontWeight:
                    isBold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? _ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SHIMMER LOADING
  // ─────────────────────────────────────────────
  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Column(
        children: [
          _shimmerBox(height: 25.h, radius: 4.w),
          SizedBox(height: 1.5.h),
          _shimmerBox(height: 18.h, radius: 4.w),
          SizedBox(height: 1.5.h),
          _shimmerBox(height: 15.h, radius: 4.w),
          SizedBox(height: 1.5.h),
          _shimmerBox(height: 18.h, radius: 4.w),
          SizedBox(height: 1.5.h),
          _shimmerBox(height: 20.h, radius: 4.w),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _shimmerBox(
      {required double height, required double radius}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: height,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(radius),
      ),
    ).withShimmerAi(loading: true);
  }
}