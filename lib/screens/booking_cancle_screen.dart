import 'package:arobo_app/utils/common_btn.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import '../models/treaks/booking_history_modal.dart';
import '../controller/dashboard_controller.dart';
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

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() {
    Future.delayed(Duration(milliseconds: 1200), () {
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

    // Handle both cases: direct BookingHistoryData or Map with booking data
    if (arguments is BookingHistoryData) {
      booking = arguments;
    } else if (arguments is Map<String, dynamic>) {
      booking = arguments['booking'] as BookingHistoryData?;
    }

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('No booking data found')),
      );
    }

    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: CommonColors.lightBlueColor3.withValues(
              alpha: 0.2,
            ),
            scrolledUnderElevation: 0,
            elevation: 0,
            automaticallyImplyLeading: true,
            centerTitle: false,
            title: Text(
              'View refund details',
              style: GoogleFonts.poppins(
                fontSize: FontSize.s13,
                fontWeight: FontWeight.w500,
                color: CommonColors.blackColor,
              ),
            ),
          ),
          body: Stack(
            children: [
              // Light blue background extension
              Container(
                height: 8.h,
                color: CommonColors.lightBlueColor3.withValues(alpha: 0.2),
              ),
              // White container with content
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6.w),
                    topRight: Radius.circular(6.w),
                  ),
                ),
                child: _isLoading
                    ? _buildShimmerLoading()
                    : SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UpcomingBookingCard(booking: booking!),
                              SizedBox(height: 2.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total refund amount",
                                    style: TextStyle(
                                      fontSize: FontSize.s13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Obx(
                                    () => Text(
                                      "₹ ${dashboardC.refundDetailData.value.refundCalculation?.refund?.toStringAsFixed(0) ?? '0'}",
                                      style: TextStyle(
                                        fontSize: FontSize.s13,
                                        fontWeight: FontWeight.w500,
                                        color: CommonColors.completedColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.5.h),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  "View cancellation policy",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: CommonColors.lightBlueColor3,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.h),

                              // Ticket Card
                              Card(
                                color: CommonColors.whiteColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.w),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(2.h),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Trek Ticket",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: FontSize.s11,
                                        ),
                                      ),
                                      Divider(),
                                      SizedBox(height: 1.h),
                                      Obx(
                                        () => _rowText(
                                          "Total amount paid (excl discounts & offers)",
                                          "₹ ${dashboardC.refundDetailData.value.finalAmount?.toStringAsFixed(0) ?? booking?.finalAmount ?? booking?.totalAmount ?? '0'}",
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      Obx(
                                        () => _rowTexts(
                                          "Refundable amount",
                                          "₹ ${dashboardC.refundDetailData.value.refundCalculation?.refund?.toStringAsFixed(0) ?? '0'}",
                                          valueColor:
                                              CommonColors.completedColor,
                                          isBold: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 3.h),

                              // Fare Breakup
                              Text(
                                "Fare Breakup",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Obx(
                                () => _rowText(
                                  "Amount paid (excl discount & offers)",
                                  "₹ ${dashboardC.refundDetailData.value.finalAmount?.toStringAsFixed(0) ?? booking?.finalAmount ?? booking?.totalAmount ?? '0'}",
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Obx(
                                () => _rowText(
                                  "Cancellation Charges",
                                  "- ₹ ${dashboardC.refundDetailData.value.refundCalculation?.deduction?.toStringAsFixed(0) ?? '0'}",
                                  valueColor: CommonColors.grey_AEAEAE,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Obx(
                                () => _rowTexts(
                                  "Total refund amount",
                                  "₹ ${dashboardC.refundDetailData.value.refundCalculation?.refund?.toStringAsFixed(0) ?? '0'}",
                                  isBold: true,
                                  valueColor: CommonColors.blackColor,
                                ),
                              ),

                              SizedBox(height: 3.h),

                              // Cancellation Reason Section
                              _buildCancellationReasonField(
                                controller: dashboardC
                                    .cancellationReasonController
                                    .value,
                              ),
                              SizedBox(height: 2.h),

                              // Notes
                              Text(
                                "• Certain fees are non-refundable, as stated",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: CommonColors.grey_AEAEAE,
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: CommonColors.grey_AEAEAE,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: "• Deductions are as per the ",
                                    ),
                                    TextSpan(
                                      text: "cancellation policy",
                                      style: const TextStyle(
                                        color: CommonColors.blueColor,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {},
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 2.h),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: CommonButton(
              text: "Confirm Cancellation",
              onPressed: () =>
                  _showCancellationConfirmDialog(context, booking!),
              gradient: CommonColors.filterGradient,
              textColor: CommonColors.whiteColor,
              fontSize: FontSize.s12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  void _showCancellationConfirmDialog(
    BuildContext context,
    BookingHistoryData booking,
  ) {
    final DashboardController dashboardC = Get.find<DashboardController>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: CommonColors.whiteColor,
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: CommonColors.red_B52424.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: CommonColors.red_B52424,
                    size: 10.w,
                  ),
                ),
                SizedBox(height: 3.h),

                // Title
                Text(
                  'Confirm Cancellation',
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s16,
                    fontWeight: FontWeight.w600,
                    color: CommonColors.blackColor,
                  ),
                ),
                SizedBox(height: 2.h),

                // Confirmation message
                Text(
                  'Are you sure you want to cancel this booking?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s10,
                    color: CommonColors.greyTextColor,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 3.h),

                // Booking Details Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: CommonColors.offWhiteColor,
                    borderRadius: BorderRadius.circular(3.w),
                    border: Border.all(
                      color: CommonColors.greyDFDFDF,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        'Trek',
                        booking.trek?.title ?? 'Unknown Trek',
                      ),
                      SizedBox(height: 1.h),
                      _buildDetailRow('TBR ID', booking.batch?.tbrId ?? 'N/A'),
                      SizedBox(height: 1.h),
                      _buildDetailRow(
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
                                  .text,
                      ),
                      SizedBox(height: 1.h),
                      _buildDetailRow(
                        'Refund Amount',
                        '₹${dashboardC.refundDetailData.value.refundCalculation?.refund?.toStringAsFixed(0) ?? '0'}',
                        valueColor: CommonColors.completedColor,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 6.h,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            backgroundColor: CommonColors.greyColorEBEBEB,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.w),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.greyTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Container(
                        height: 6.h,
                        child: TextButton(
                          onPressed: () async {
                            await dashboardC.reqCancellation(
                              bookingId: booking.id!,
                              bookingData: booking,
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: CommonColors.appRedColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.w),
                            ),
                          ),
                          child: Text(
                            'Confirm',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w600,
                              color: CommonColors.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: GoogleFonts.poppins(
              fontSize: FontSize.s9,
              fontWeight: FontWeight.w500,
              color: CommonColors.greyTextColor,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: FontSize.s9,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: valueColor ?? CommonColors.blackColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancellationReasonField({
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Reason for Cancellation",
          style: TextStyle(
            fontSize: FontSize.s12,
            fontWeight: FontWeight.bold,
            color: CommonColors.blackColor,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(2.w),
          height: 12.h,
          decoration: BoxDecoration(
            color: CommonColors.whiteColor,
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(color: CommonColors.greyDFDFDF, width: 1),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Please enter your reason for cancellation...',
              hintStyle: GoogleFonts.poppins(
                fontSize: FontSize.s9,
                color: CommonColors.greyTextColor,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(2.w),
            ),
            style: GoogleFonts.poppins(
              fontSize: FontSize.s10,
              color: CommonColors.blackColor,
            ),
          ),
        ),
      ],
    );
  }

  // bool _isFormValid() {
  //   return cancellationReasonController.text
  //       .trim()
  //       .isNotEmpty;
  // }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _rowText(
    String title,
    String value, {
    Color valueColor = CommonColors.blackColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: FontSize.s10,
              color: CommonColors.grey_AEAEAE,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: FontSize.s10,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _rowTexts(
    String title,
    String value, {
    Color valueColor = CommonColors.blackColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: FontSize.s10,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: FontSize.s10,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main booking card shimmer
          Container(
            width: double.infinity,
            height: 25.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(3.w),
            ),
          ).withShimmerAi(loading: true),
          SizedBox(height: 2.h),

          // Total refund amount row shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40.w,
                height: 2.h,
                decoration: BoxDecoration(
                  color: CommonColors.greyColorEBEBEB,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).withShimmerAi(loading: true),
              Container(
                width: 20.w,
                height: 2.h,
                decoration: BoxDecoration(
                  color: CommonColors.greyColorEBEBEB,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).withShimmerAi(loading: true),
            ],
          ),
          SizedBox(height: 0.5.h),

          // View cancellation policy shimmer
          Container(
            width: 35.w,
            height: 1.5.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(4),
            ),
          ).withShimmerAi(loading: true),
          SizedBox(height: 2.h),

          // Ticket Card shimmer
          Container(
            width: double.infinity,
            height: 15.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(3.w),
            ),
          ).withShimmerAi(loading: true),
          SizedBox(height: 3.h),

          // Fare Breakup title shimmer
          Container(
            width: 25.w,
            height: 1.5.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(4),
            ),
          ).withShimmerAi(loading: true),
          SizedBox(height: 1.h),

          // Fare breakup rows shimmer
          ...List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50.w,
                    height: 1.5.h,
                    decoration: BoxDecoration(
                      color: CommonColors.greyColorEBEBEB,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).withShimmerAi(loading: true),
                  Container(
                    width: 20.w,
                    height: 1.5.h,
                    decoration: BoxDecoration(
                      color: CommonColors.greyColorEBEBEB,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).withShimmerAi(loading: true),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Cancellation reason field shimmer
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 2.h,
                decoration: BoxDecoration(
                  color: CommonColors.greyColorEBEBEB,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).withShimmerAi(loading: true),
              SizedBox(height: 1.h),
              Container(
                width: double.infinity,
                height: 12.h,
                decoration: BoxDecoration(
                  color: CommonColors.greyColorEBEBEB,
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ).withShimmerAi(loading: true),
            ],
          ),
          SizedBox(height: 2.h),

          // Notes shimmer
          ...List.generate(
            2,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 0.5.h),
              child: Container(
                width: index == 0 ? 80.w : 60.w,
                height: 1.5.h,
                decoration: BoxDecoration(
                  color: CommonColors.greyColorEBEBEB,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).withShimmerAi(loading: true),
            ),
          ),
        ],
      ),
    );
  }
}
