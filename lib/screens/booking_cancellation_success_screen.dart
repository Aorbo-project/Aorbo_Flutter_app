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

class BookingCancellationSuccessScreen extends StatefulWidget {
  const BookingCancellationSuccessScreen({super.key});

  @override
  State<BookingCancellationSuccessScreen> createState() =>
      _BookingCancellationSuccessScreenState();
}

class _BookingCancellationSuccessScreenState
    extends State<BookingCancellationSuccessScreen> {
  final BookingHistoryData? booking = Get.arguments;
  final DashboardController dashboardC = Get.find<DashboardController>();
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (booking == null) {
    //   return Scaffold(
    //     appBar: AppBar(title: Text('Error')),
    //     body: Center(child: Text('No booking data found')),
    //   );
    // }

    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: CommonColors.lightBlueColor3.withValues(alpha: 0.2),
            scrolledUnderElevation: 0,
            elevation: 0,
            automaticallyImplyLeading: true,
            centerTitle: false,
            leading: BackButton(
              onPressed: () {
                Get.offAllNamed('/dashboard');
                dashboardC.selectedScreen.value = 1;
                setState(() {});
              },
            ),
            title: Text(
              'Your ticket details',
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
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Trek Details Card
                              UpcomingBookingCard(booking: booking!),
                              SizedBox(height: 2.h),

                              // Traveler Details Table
                              _buildTravelerDetailsTable(booking!),
                              SizedBox(height: 2.h),

                              // Cancellation Status Card
                              _buildCancellationStatusCard(booking!, dashboardC),
                              SizedBox(height: 2.h),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTravelerDetailsTable(BookingHistoryData booking) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.1),
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableRow(
            '${booking.travelers?.length ?? 0} Slots',
            booking.travelers
                    ?.map((t) => t.traveler?.name ?? 'Unknown')
                    .join(', ') ??
                'Unknown',
            isHeader: false,
          ),
          Divider(height: 2.h),
          _buildTableRow(
            'Ticket No',
            booking.travelers
                    ?.map((t) => booking.batch?.tbrId ?? 'N/A')
                    .join(', ') ??
                'N/A',
            isHeader: false,
          ),
          Divider(height: 2.h),
          _buildTableRow(
            'Fare',
            '₹ ${booking.finalAmount ?? booking.totalAmount ?? '0'}',
            isHeader: false,
            valueColor: CommonColors.blackColor,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    String label,
    String value, {
    bool isHeader = false,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: FontSize.s10,
              fontWeight: isHeader ? FontWeight.w600 : FontWeight.w400,
              color: CommonColors.greyTextColor,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: FontSize.s10,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: valueColor ?? CommonColors.blackColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancellationStatusCard(
    BookingHistoryData booking,
    DashboardController dashboardC,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.1),
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Section - Light Blue Background
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Color(0xFFE8F4F8), // Light blue background
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.w),
                topRight: Radius.circular(4.w),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ticket Cancelled',
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s14,
                          fontWeight: FontWeight.w600,
                          color: CommonColors.blackColor,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'on ${_formatDate(DateTime.now())}',
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s10,
                          color: CommonColors.greyTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Ticket Icon
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Stack(
                    children: [
                      // Background ticket
                      Positioned(
                        right: 1.w,
                        child: Container(
                          width: 8.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade300,
                            borderRadius: BorderRadius.circular(1.w),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 2.w,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(1.w),
                                    topRight: Radius.circular(1.w),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade300,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(1.w),
                                      bottomRight: Radius.circular(1.w),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Front ticket with X
                      Positioned(
                        child: Container(
                          width: 8.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade400,
                            borderRadius: BorderRadius.circular(1.w),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 0.5,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 3.w,
                              height: 3.w,
                              decoration: BoxDecoration(
                                color: Colors.pink.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 2.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Section - White Background
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: CommonColors.whiteColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(4.w),
                bottomRight: Radius.circular(4.w),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Refund Message
                Text(
                  'The refund will be processed to your payment method shortly.',
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s10,
                    color: CommonColors.blackColor,
                  ),
                ),
                SizedBox(height: 2.h),

                // Refund Amount and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Total refund ',
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s10,
                            color: CommonColors.greyTextColor,
                          ),
                        ),
                        Obx(
                          () => Text(
                            '₹ ${dashboardC.refundDetailData.value.refundCalculation?.refund?.toStringAsFixed(0) ?? '0'}',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // Handle refund status
                      },
                      child: Text(
                        'Refund Status',
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s10,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
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
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
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

          // Traveler details table shimmer
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: CommonColors.whiteColor,
              borderRadius: BorderRadius.circular(4.w),
              boxShadow: [
                BoxShadow(
                  color: CommonColors.blackColor.withValues(alpha: 0.1),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                // Slots row shimmer
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).withShimmerAi(loading: true),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).withShimmerAi(loading: true),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                // Ticket No row shimmer
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).withShimmerAi(loading: true),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).withShimmerAi(loading: true),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                // Fare row shimmer
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).withShimmerAi(loading: true),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).withShimmerAi(loading: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),

          // Cancellation status card shimmer
          Container(
            decoration: BoxDecoration(
              color: CommonColors.whiteColor,
              borderRadius: BorderRadius.circular(4.w),
              boxShadow: [
                BoxShadow(
                  color: CommonColors.blackColor.withValues(alpha: 0.1),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                // Top section shimmer (light blue background)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F4F8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.w),
                      topRight: Radius.circular(4.w),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 30.w,
                              height: 2.h,
                              decoration: BoxDecoration(
                                color: CommonColors.greyColorEBEBEB,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ).withShimmerAi(loading: true),
                            SizedBox(height: 0.5.h),
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
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                      ).withShimmerAi(loading: true),
                    ],
                  ),
                ),

                // Bottom section shimmer (white background)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: CommonColors.whiteColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(4.w),
                      bottomRight: Radius.circular(4.w),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Refund message shimmer
                      Container(
                        width: double.infinity,
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).withShimmerAi(loading: true),
                      SizedBox(height: 2.h),

                      // Refund amount and status row shimmer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 35.w,
                            height: 1.5.h,
                            decoration: BoxDecoration(
                              color: CommonColors.greyColorEBEBEB,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ).withShimmerAi(loading: true),
                          Container(
                            width: 25.w,
                            height: 1.5.h,
                            decoration: BoxDecoration(
                              color: CommonColors.greyColorEBEBEB,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ).withShimmerAi(loading: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
