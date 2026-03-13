import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import '../models/treaks/booking_history_modal.dart';
import '../models/dispute/dispute_detail_modal.dart';
import '../controller/dashboard_controller.dart';
import '../utils/common_colors.dart';
import '../utils/common_booked_details_card.dart';
import '../utils/screen_constants.dart';
import '../utils/custom_snackbar.dart';

class BookingsUpcomingScreen extends StatefulWidget {
  const BookingsUpcomingScreen({super.key});

  @override
  State<BookingsUpcomingScreen> createState() => _BookingsUpcomingScreenState();
}

class _BookingsUpcomingScreenState extends State<BookingsUpcomingScreen> {
  double _currentRating = 0.0;
  final DashboardController _dashboardC = Get.find<DashboardController>();
  bool _isLoading = true;
  final dynamic arguments = Get.arguments;
  BookingHistoryData? booking;

  // Handle both cases: direct BookingHistoryData or Map with 'booking' key

  @override
  void initState() {
    super.initState();
    _currentRating = 0.0;
    // Simulate loading for demonstration
    if (arguments is BookingHistoryData) {
      booking = arguments;
    } else if (arguments is Map<String, dynamic>) {
      booking = arguments['booking'];
    }
    _simulateLoading();
    _dashboardC.getDisputeDetail(bookingId: booking?.id.toString() ?? '0');
  }

  void _simulateLoading() {
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _resetRating() {
    setState(() {
      _currentRating = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String status =
        booking?.trekStatus?.toLowerCase().trim() ?? 'unknown';

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
            title: Text(
              'My bookings',
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
                              UpcomingBookingCard(booking: booking!),
                              SizedBox(height: 2.h),

                              // Dispute card - show only if dispute data exists
                              Text(
                                "Trek details will be provided on the day of the journey\nvia the following number.",
                                style: TextStyle(
                                  fontSize: FontSize.s9,
                                  color: CommonColors.greyTextColor,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              if (booking?.trek?.captainName != null)
                                Text(
                                  "${booking?.trek?.captainName}",
                                  style: TextStyle(
                                    fontSize: FontSize.s9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              SizedBox(height: 1.h),
                              if (booking?.trek?.captainPhone != null)
                                Text(
                                  "${booking?.trek?.captainPhone}",
                                  style: TextStyle(
                                    fontSize: FontSize.s9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                Text(
                                  "Contact number not available",
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.bold,
                                    color: CommonColors.greyTextColor,
                                  ),
                                ),
                              SizedBox(height: 2.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _iconWithLabel(
                                    Icons.confirmation_num,
                                    "Ticket",
                                    onTap: () {
                                      CustomSnackBar.show(context, message: 'Ticket feature coming soon');
                                    },
                                  ),

                                  // Cancel button
                                  if (status == 'upcoming' ||
                                      status == 'confirmed' ||
                                      status == 'booked')
                                    _iconWithLabel(
                                      Icons.cancel_outlined,
                                      "Cancel",
                                      onTap: () async {
                                        // Get booking ID for refund details
                                        String? bookingId;
                                        if (booking!.travelers?.isNotEmpty == true) {
                                          bookingId = booking
                                              ?.travelers!
                                              .first
                                              .bookingId
                                              ?.toString();
                                        }

                                        if (bookingId != null) {
                                          // Fetch refund details first
                                          await _dashboardC.getRefundDetail(bookingId);

                                          // Check if cancellation is allowed
                                          if (_dashboardC
                                                  .refundDetailData
                                                  .value
                                                  .canCancel ==
                                              false) {
                                            // Show cancellation message as snackbar
                                            final message =
                                                _dashboardC
                                                    .refundDetailData
                                                    .value
                                                    .cancellationMessage ??
                                                'Cancellation is not allowed for this booking';

                                            // Use SchedulerBinding to show snackbar after build
                                            SchedulerBinding.instance.addPostFrameCallback((_) {
                                              CustomSnackBar.show(
                                                context,
                                                message: message,
                                              );
                                            });
                                            return; // Don't navigate to cancel screen
                                          }
                                        }

                                        // Navigate to cancel screen with booking data
                                        // The refund data can be accessed from the controller in the cancel screen
                                        Get.toNamed(
                                          '/bookingscancel',
                                          arguments: booking,
                                        );
                                      },
                                    ),
                                  if (status == 'ongoing' && _dashboardC.disputeDetailDataList.isEmpty)
                                    _iconWithLabel(
                                      Icons.report,
                                      "Refund Process",
                                      onTap: () {
                                        Get.toNamed(
                                          '/issue-report',
                                          arguments: booking,
                                        );
                                      },
                                    ),
                                  _iconWithLabel(
                                    Icons.share,
                                    "Share",
                                    onTap: () {
                                      CustomSnackBar.show(context, message: 'Share feature coming soon');
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              ListTile(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: CommonColors.greyC4C4C4),
                                  borderRadius: BorderRadius.circular(3.w),
                                ),
                                tileColor: CommonColors.whiteColor,
                                leading: Icon(
                                  Icons.help_outline,
                                  size: 8.w,
                                  color: CommonColors.blackColor,
                                ),
                                title: Text(
                                  "Frequently Asked Questions",
                                  style: TextStyle(fontSize: 8.sp),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios, size: 5.w),
                                onTap: () {
                                  CustomSnackBar.show(context, message: 'FAQ coming soon');
                                },
                              ),
                              SizedBox(height: 3.h),
                              if (status == 'completed')
                                GestureDetector(
                                  onTap: !booking!.ratingGiven!
                                      ? () {
                                          Get.toNamed(
                                            '/rate-review',
                                            arguments: booking,
                                          )?.then((_) {
                                            // Reset rating when returning from rate-review screen
                                            _resetRating();
                                          });
                                        }
                                      : null,
                                  child: _buildRatingCard(bookingData: booking!),
                                ),
                              if (_dashboardC.disputeDetailDataList.isNotEmpty)
                                Obx(
                                  () => _buildDisputeCard(
                                    disputeData: _dashboardC.disputeDetailDataList,
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
        );
      },
    );
  }

  Widget _iconWithLabel(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 10.w, color: CommonColors.blueColor_367FEE),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: CommonColors.blueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDisputeCard({required List<Disputes> disputeData}) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: disputeData.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: CommonColors.whiteColor,
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(
              color: CommonColors.appRedColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: CommonColors.blackColor.withValues(alpha: 0.1),
                offset: Offset(0, 2),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: CommonColors.appRedColor,
                    size: 6.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Dispute Details',
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s10,
                      fontWeight: FontWeight.w600,
                      color: CommonColors.blackColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              _buildDisputeInfoRow(
                'Status',
                disputeData[index].status ?? 'N/A',
              ),
              SizedBox(height: 1.h),
              _buildDisputeInfoRow(
                'Disputed Amount',
                '₹${disputeData[index].disputedAmount ?? 0}',
              ),
              SizedBox(height: 1.h),
              _buildDisputeInfoRow(
                'Issue Type',
                disputeData[index].issueType ?? 'N/A',
              ),
              SizedBox(height: 1.h),
              _buildDisputeInfoRow(
                'Priority',
                disputeData[index].priority ?? 'N/A',
              ),
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 1.5.h,horizontal: 2.w),
                decoration: BoxDecoration(
                  color: CommonColors.appRedColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Text(
                  'Your dispute is being reviewed by our support team. We will update you soon.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s8,
                    color: CommonColors.appRedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDisputeInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: FontSize.s9,
            color: CommonColors.greyTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: FontSize.s9,
            color: CommonColors.blackColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingCard({required BookingHistoryData bookingData}) {
    return Container(
      padding: EdgeInsets.fromLTRB(8.w, 4.w, 6.w, 4.w),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.15),
            offset: Offset(2, 2),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookingData.ratingGiven!
                          ? 'Thank you for rating!'
                          : 'Share your trek experience with Trekking Freaks!',
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s8,
                        fontWeight: FontWeight.w500,
                        color: CommonColors.blackColor,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        // This prevents the parent card tap when stars are tapped
                      },
                      child: AnimatedRatingStars(
                        initialRating: bookingData.ratingGiven!
                            ? bookingData.ratingValue ?? 0.0
                            : _currentRating,
                        readOnly: bookingData.ratingGiven!,
                        onChanged: (rating) {
                          if (!bookingData.ratingGiven!) {
                            setState(() {
                              _currentRating = rating;
                            });
                            // Navigate to rate-review screen with pre-selected rating
                            Get.toNamed(
                              '/rate-review',
                              arguments: {
                                'booking': bookingData,
                                'preSelectedRating': rating,
                              },
                            )?.then((_) {
                              // Reset rating when returning from rate-review screen
                              _resetRating();
                            });
                          }
                        },
                        filledColor: CommonColors.completedColor2,
                        displayRatingValue: false,
                        interactiveTooltips: true,
                        customFilledIcon: Icons.star_rounded,
                        customHalfFilledIcon: Icons.star_half_rounded,
                        customEmptyIcon: Icons.star_border_rounded,
                        starSize: 8.w,
                        animationDuration: const Duration(milliseconds: 500),
                        animationCurve: Curves.easeInOut,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              Image.asset(
                'assets/images/img/womanwithplaque.png',
                width: 20.w,
                height: 20.w,
                fit: BoxFit.contain,
              ),
            ],
          ),
          Divider(),
          Text(
            'Help fellow travelers pick the best trek!',
            style: GoogleFonts.poppins(
              fontSize: FontSize.s7,
              color: CommonColors.greyTextColor2,
            ),
          ),
        ],
      ),
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

          // Dispute card shimmer
          Container(
            width: double.infinity,
            height: 20.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(3.w),
            ),
          ).withShimmerAi(loading: true),
          SizedBox(height: 2.h),

          // Text description shimmer
          Container(
            width: double.infinity,
            height: 1.5.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(4),
            ),
          ).withShimmerAi(loading: true),
          SizedBox(height: 0.5.h),
          Container(
            width: 60.w,
            height: 1.5.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(4),
            ),
          ).withShimmerAi(loading: true),
          SizedBox(height: 1.h),

          // Captain name shimmer
          Container(
            width: 40.w,
            height: 1.5.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(4),
            ),
          ).withShimmerAi(loading: true),
          SizedBox(height: 1.h),

          // Phone number shimmer
          Container(
            width: 35.w,
            height: 1.5.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(4),
            ),
          ).withShimmerAi(loading: true),
          SizedBox(height: 2.h),

          // Action buttons row shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Ticket button
              Column(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: CommonColors.greyColorEBEBEB,
                      shape: BoxShape.circle,
                    ),
                  ).withShimmerAi(loading: true),
                  SizedBox(height: 0.5.h),
                  Container(
                    width: 12.w,
                    height: 1.h,
                    decoration: BoxDecoration(
                      color: CommonColors.greyColorEBEBEB,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).withShimmerAi(loading: true),
                ],
              ),
              // Cancel button
              Column(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: CommonColors.greyColorEBEBEB,
                      shape: BoxShape.circle,
                    ),
                  ).withShimmerAi(loading: true),
                  SizedBox(height: 0.5.h),
                  Container(
                    width: 12.w,
                    height: 1.h,
                    decoration: BoxDecoration(
                      color: CommonColors.greyColorEBEBEB,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).withShimmerAi(loading: true),
                ],
              ),
              // Share button
              Column(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: CommonColors.greyColorEBEBEB,
                      shape: BoxShape.circle,
                    ),
                  ).withShimmerAi(loading: true),
                  SizedBox(height: 0.5.h),
                  Container(
                    width: 12.w,
                    height: 1.h,
                    decoration: BoxDecoration(
                      color: CommonColors.greyColorEBEBEB,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).withShimmerAi(loading: true),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // FAQ ListTile shimmer
          Container(
            width: double.infinity,
            height: 7.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(3.w),
            ),
          ).withShimmerAi(loading: true),
          SizedBox(height: 3.h),

          // Rating card shimmer (for completed status)
          Container(
            width: double.infinity,
            height: 20.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(3.w),
            ),
          ).withShimmerAi(loading: true),
        ],
      ),
    );
  }
}
