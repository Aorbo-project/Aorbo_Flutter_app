import 'package:arobo_app/freezed_models/booking/cancellation_data_model.dart';
import 'package:arobo_app/screens/booking_cancellation_success_screen.dart';
import 'package:arobo_app/utils/common_btn.dart';
import 'package:flutter/gestures.dart';
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

class _BookingsCancelScreenState extends State<BookingsCancelScreen> {
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
  static const _purple = Color(0xFF9C27B0);
  static const _purpleSoft = Color(0xFFF3E5F5);

  @override
  void initState() {
    super.initState();
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
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: _bg,
          appBar: _buildAppBar(),
          body: Obx(() {
            final isLoading = _trekC.cancellationDetailsResponseObserver.value
                .maybeWhen(loading: (df) => true, orElse: () => false);
            CancellationDataModel? cancellationDataModel =
            _trekC.cancellationDetailsResponseObserver.value.maybeWhen(
                success: (response) =>
                (response as CancellationDetailsResponseModel).data,
                orElse: () => null);
            if (isLoading) {
              return _buildShimmerLoading();
            }
            return _buildBody(cancellationDataModel, booking!);
          }),
          bottomNavigationBar: _buildBottomBar(booking!),
        );
      },
    );
  }

  Widget _buildBottomBar(BookingHistoryData booking) {
    return Obx(() {
      final isLoading = _trekC.cancellationDetailsResponseObserver.value
          .maybeWhen(loading: (df) => true, orElse: () => false);
      CancellationDataModel? cancellationDataModel =
      _trekC.cancellationDetailsResponseObserver.value.maybeWhen(
          success: (response) =>
          (response as CancellationDetailsResponseModel).data,
          orElse: () => null);

      if (isLoading) {
        return Container(
          padding: EdgeInsets.fromLTRB(10.w, 1.5.h, 10.w, 2.5.h),
          decoration: BoxDecoration(
            color: _cardBg,
            boxShadow: [
              BoxShadow(
                  color: _shadow, blurRadius: 12, offset: const Offset(0, -3)),
            ],
          ),
          child: Center(
            child: CircularProgressIndicator(color: CommonColors.appColor),
          ),
        );
      }

      return Container(
        padding: EdgeInsets.fromLTRB(10.w, 1.5.h, 10.w, 2.5.h),
        decoration: BoxDecoration(
          color: _cardBg,
          boxShadow: [
            BoxShadow(
                color: _shadow, blurRadius: 12, offset: const Offset(0, -3)),
          ],
        ),
        child: CommonButton(
          text: 'Confirm Cancellation',
          onPressed: () => _showCancellationDialog(
              context, booking, cancellationDataModel),
          gradient: CommonColors.filterGradient,
          textColor: CommonColors.whiteColor,
          height: 6.h,
          isFullWidth: false,
          width: 50.w,
          fontSize: FontSize.s14,
        ),
      );
    });
  }

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
        'Cancel Booking',
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

  Widget _buildBody(CancellationDataModel? cancellationDataModel,
      BookingHistoryData booking) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 0.h),
      child: Column(
        children: [
          // Policy Information Banner
          if (cancellationDataModel?.cancellationPolicyName != null)
            _policyBanner(cancellationDataModel!),

          SizedBox(height: 1.h),

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

          // Refund Summary Card
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(
                    'Refund Summary', Icons.account_balance_wallet_outlined),
                SizedBox(height: 2.h),

                // Time Remaining Info
                if (cancellationDataModel?.timeRemainingHours != null)
                  _timeRemainingWidget(cancellationDataModel!),

                SizedBox(height: 1.5.h),

                // Refund Amount Block
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: _brand.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(3.w),
                    border: Border.all(color: _brand.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Refund Amount',
                            textScaler: const TextScaler.linear(1.0),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s9,
                              fontWeight: FontWeight.w500,
                              color: _inkMid,
                            ),
                          ),
                          // if (cancellationDataModel?.freeCancellation == true)
                          //   Container(
                          //     margin: EdgeInsets.only(top: 0.5.h),
                          //     padding: EdgeInsets.symmetric(
                          //         horizontal: 2.w, vertical: 0.2.h),
                          //     decoration: BoxDecoration(
                          //       color: _tealSoft,
                          //       borderRadius: BorderRadius.circular(1.w),
                          //     ),
                          //     child: Text(
                          //       'Free Cancellation',
                          //       textScaler: const TextScaler.linear(1.0),
                          //       style: TextStyle(
                          //         fontFamily: 'Poppins',
                          //         fontSize: FontSize.s8,
                          //         fontWeight: FontWeight.w600,
                          //         color: _teal,
                          //       ),
                          //     ),
                          //   ),
                        ],
                      ),
                      Text(
                        "₹ ${cancellationDataModel?.refundCalculation?.refund?.toStringAsFixed(2) ?? '0'}",
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s18,
                          fontWeight: FontWeight.w800,
                          color: _brand,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 1.5.h),

                // View Policy Link
                GestureDetector(
                  onTap: () => _showPolicyDetails(cancellationDataModel),
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

          // Refund Items Details Card
          if (cancellationDataModel?.refundCalculation?.refundItems != null &&
              cancellationDataModel!.refundCalculation!.refundItems!.isNotEmpty)
            _refundItemsCard(cancellationDataModel),

          SizedBox(height: 1.5.h),

          // Loss Items Card (What you lose)
          if (cancellationDataModel?.refundCalculation?.loseItems != null &&
              cancellationDataModel!.refundCalculation!.loseItems!.isNotEmpty)
            _lossItemsCard(cancellationDataModel),

          SizedBox(height: 1.5.h),

          // Fare Breakup Card
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('Fare Breakup', Icons.receipt_long_outlined),
                SizedBox(height: 2.h),

                // Original Amount
                _buildBreakupRow(
                  'Total Amount Paid',
                  cancellationDataModel?.finalAmount ??
                      double.parse(booking.finalAmount?.toString() ?? '0'),
                  isTotal: false,
                ),

                SizedBox(height: 1.5.h),

                // Cancellation Charges
                if (cancellationDataModel?.refundCalculation?.deduction != null &&
                    cancellationDataModel!.refundCalculation!.deduction! > 0)
                  _buildBreakupRow(
                    'Cancellation Charges',
                    -cancellationDataModel.refundCalculation!.deduction!,
                    isDeduction: true,
                  ),

                // if (cancellationDataModel?.within24Hours == true)
                //   Container(
                //     margin: EdgeInsets.only(top: 1.h),
                //     padding:
                //     EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                //     decoration: BoxDecoration(
                //       color: _redSoft,
                //       borderRadius: BorderRadius.circular(2.w),
                //     ),
                //     child: Row(
                //       children: [
                //         Icon(Icons.warning_amber_rounded,
                //             color: _red, size: 4.w),
                //         SizedBox(width: 2.w),
                //         Expanded(
                //           child: Text(
                //             'Cancellation initiated within 24 hours of departure',
                //             textScaler: const TextScaler.linear(1.0),
                //             style: TextStyle(
                //               fontFamily: 'Poppins',
                //               fontSize: FontSize.s8,
                //               fontWeight: FontWeight.w500,
                //               color: _red,
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),

                SizedBox(height: 1.5.h),
                Divider(color: _divider, height: 1),
                SizedBox(height: 1.5.h),

                // Total Refund
                _buildBreakupRow(
                  'Total Refund Amount',
                  cancellationDataModel?.refundCalculation?.refund ?? 0,
                  isTotal: true,
                  isBold: true,
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
                  padding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FF),
                    borderRadius: BorderRadius.circular(3.w),
                    border: Border.all(color: _brand.withOpacity(0.12)),
                  ),
                  child: TextFormField(
                    controller: _trekC.cancellationReasonController.value,
                    maxLines: 4,
                    minLines: 3,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Please enter your reason for cancellation...',
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
                SizedBox(height: 2.h),

                // Important Notes
                _infoNote(
                    '• Refund will be processed to the original payment method within 5-7 business days'),
                SizedBox(height: 1.h),
                _infoNote(
                    '• Cancellation charges are non-negotiable once confirmed'),
                SizedBox(height: 1.h),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s9,
                      color: _inkLight,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(text: '• '),
                      TextSpan(
                          text: 'Deductions are as per the ',
                          style: TextStyle(color: _inkLight)),
                      TextSpan(
                        text: 'cancellation policy',
                        style: TextStyle(
                          color: _brand,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showPolicyDetails(cancellationDataModel),
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
  //  NEW WIDGETS FOR ENHANCED DETAILS
  // ─────────────────────────────────────────────

  Widget _policyBanner(CancellationDataModel data) {
    Color bannerColor;
    IconData bannerIcon;
    String bannerText;

    // if (data.freeCancellation == true) {
    //   bannerColor = _tealSoft;
    //   bannerIcon = Icons.verified_outlined;
    //   bannerText = 'FREE CANCELLATION • No charges applicable';
    // } else if (data.within24Hours == true) {
    //   bannerColor = _redSoft;
    //   bannerIcon = Icons.timer_outlined;
    //   bannerText = '⚠️ WITHIN 24 HOURS • Higher cancellation charges apply';
    // } else {
      bannerColor = _orangeSoft;
      bannerIcon = Icons.info_outline;
      bannerText =
      '${data.cancellationPolicyName?.toUpperCase() ?? 'FLEXIBLE'} POLICY • Partial refund applicable';
    //}

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: bannerColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(bannerIcon, color: _teal, size: 5.w),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              bannerText,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                fontWeight: FontWeight.w600,
                color: _ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeRemainingWidget(CancellationDataModel data) {
    int hours = data.timeRemainingHours!.floor();
    int days = hours ~/ 24;
    int remainingHours = hours % 24;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_brand.withOpacity(0.1), _brand.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: _brand, size: 5.w),
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
                Text(
                  '$days days $remainingHours hours',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s12,
                    fontWeight: FontWeight.w700,
                    color: _brand,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _refundItemsCard(CancellationDataModel data) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('What You\'ll Get Back', Icons.arrow_upward_rounded),
          SizedBox(height: 2.h),
          ...data.refundCalculation!.refundItems!.map((item) => Padding(
            padding: EdgeInsets.only(bottom: 1.2.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    item.item ?? 'Unknown',
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
                  "₹ ${item.amount?.toStringAsFixed(2) ?? '0'}",
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s10,
                    fontWeight: FontWeight.w600,
                    color: _teal,
                  ),
                ),
              ],
            ),
          )),
          Divider(color: _divider, height: 1),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Refund',
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s11,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              Text(
                "₹ ${data.refundCalculation?.refund?.toStringAsFixed(2) ?? '0'}",
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s14,
                  fontWeight: FontWeight.w800,
                  color: _teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _lossItemsCard(CancellationDataModel data) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('What You\'ll Lose', Icons.arrow_downward_rounded),
          SizedBox(height: 2.h),
          ...data.refundCalculation!.loseItems!.map((item) => Padding(
            padding: EdgeInsets.only(bottom: 1.2.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Icon(Icons.remove_circle_outline,
                          color: _red, size: 4.w),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          item.item ?? 'Unknown',
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
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  "- ₹ ${item.amount?.toStringAsFixed(2) ?? '0'}",
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s10,
                    fontWeight: FontWeight.w600,
                    color: _red,
                  ),
                ),
              ],
            ),
          )),
          Divider(color: _divider, height: 1),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Deduction',
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s11,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              Text(
                "₹ ${data.refundCalculation?.deduction?.toStringAsFixed(2) ?? '0'}",
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s14,
                  fontWeight: FontWeight.w800,
                  color: _red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakupRow(String label, double amount,
      {bool isTotal = false, bool isDeduction = false, bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              textScaler: const TextScaler.linear(1.0),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: isTotal ? FontSize.s11 : FontSize.s10,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
                color: isTotal ? _ink : _inkMid,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            amount >= 0
                ? "₹ ${amount.toStringAsFixed(2)}"
                : "- ₹ ${(-amount).toStringAsFixed(2)}",
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: isTotal ? FontSize.s12 : FontSize.s10,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: isDeduction
                  ? _red
                  : isTotal
                  ? _brand
                  : _ink,
            ),
          ),
        ],
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

  // ─────────────────────────────────────────────
  //  SHARED WIDGETS
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


  void _showPolicyDetails(CancellationDataModel? data) {
    if (data == null) return;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.cancellationPolicyName ?? 'Cancellation Policy',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s16,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Policy Type: ${data.cancellationPolicyType?.toUpperCase() ?? 'N/A'}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s12,
                fontWeight: FontWeight.w600,
                color: _brand,
              ),
            ),
            SizedBox(height: 2.h),
            // if (data.freeCancellation == true)
            //   _infoNote('✓ Free cancellation available'),
            // if (data.within24Hours == true)
            //   _infoNote('⚠️ This cancellation is within 24 hours of departure'),
            _infoNote(
                '• Refund will be processed as per the policy terms'),
            _infoNote(
                '• For any queries, please contact support team'),
            SizedBox(height: 2.h),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancellationDialog(BuildContext context,
      BookingHistoryData booking, CancellationDataModel? cancellationDataModel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.w)),
          backgroundColor: _cardBg,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
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
                    border: Border.all(color: _brand.withOpacity(0.12)),
                  ),
                  child: Column(
                    children: [
                      _dialogRow('Trek',
                          booking.trek?.title ?? 'Unknown Trek'),
                      Divider(
                          color: _divider.withOpacity(0.5), height: 1),
                      _dialogRow(
                          'TBR ID', booking.batch?.tbrId ?? 'N/A'),
                      Divider(
                          color: _divider.withOpacity(0.5), height: 1),
                      _dialogRow(
                          'Reason',
                          _trekC.cancellationReasonController.value.text.isEmpty
                              ? 'No reason provided'
                              : _trekC.cancellationReasonController.value.text),
                      Divider(
                          color: _divider.withOpacity(0.5), height: 1),
                      _dialogRow(
                          'Refund Amount',
                          '₹${cancellationDataModel?.refundCalculation?.refund?.toStringAsFixed(2) ?? '0'}',
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
                          backgroundColor: const Color(0xFFF0F2F5),
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
                      child: Obx(() => _trekC
                          .requestCancellationResponseObserver.value
                          .maybeWhen(
                        loading: (rs) => Center(
                            child: CircularProgressIndicator(
                                color: CommonColors.appColor)),
                        orElse: () => TextButton(
                          onPressed: () async {
                            String? bookingId =
                            booking.id?.toString();
                            if (bookingId != null) {
                              final message = await _trekC
                                  .reqCancellation(bookingId);
                              if (message != null) {
                                Get.close(1);
                                SchedulerBinding.instance
                                    .addPostFrameCallback((_) {
                                  CustomSnackBar.show(context,
                                      message: message);
                                });
                                return;
                              } else {
                                Get.close(1);
                                _dashboardC.getBookingDetail(bookingId: bookingId);
                                Get.to(() => BookingCancellationSuccessScreen(refund: cancellationDataModel?.refundCalculation?.refund?.toStringAsFixed(2) ?? '0', booking: _dashboardC.bookingHistoryModal.value));
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: _red,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(3.w)),
                          ),
                          child: Text(
                            'Yes, Cancel',
                            textScaler:
                            const TextScaler.linear(1.0),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )),
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
          SizedBox(
            width: 30.w, // Fixed width for label
            child: Text(
              label,
              textScaler: const TextScaler.linear(1.0),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                fontWeight: FontWeight.w500,
                color: _inkMid,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              textScaler: const TextScaler.linear(1.0),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? _ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _shimmerBox({required double height, required double radius}) {
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