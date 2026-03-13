import 'package:arobo_app/models/treaks/booking_history_modal.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'common_colors.dart';
import 'screen_constants.dart';
import 'common_images.dart';

class CommonBookedCard extends StatelessWidget {
  final BookingHistoryData booking;
  final VoidCallback? onViewDetailsTap;

  const CommonBookedCard({
    super.key,
    required this.booking,
    this.onViewDetailsTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return CommonColors.upcomingColor.withValues(alpha: 0.8);
      case 'completed':
        return CommonColors.completedColor2.withValues(alpha: 0.8);
      case 'ongoing':
        return CommonColors.blueColor_367FEE;
      case 'cancelled':
        return CommonColors.cancelledColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: GestureDetector(
        onTap: onViewDetailsTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
            height: 18.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.w),
              boxShadow: [
                BoxShadow(
                  color: CommonColors.blackColor.withValues(alpha: 0.2),
                  offset: Offset(2, 2),
                  blurRadius: 6,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 1.8.h,
                  left: 4.w,
                  child: Row(
                    children: [
                      Center(
                        child: Image.asset(
                          CommonImages.logo,
                          width: 12.w,
                          height: 12.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.trek?.title ?? '-',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s11,
                              fontWeight: FontWeight.w600,
                              color: CommonColors.blackColor,
                            ),
                          ),
                          Text(
                            booking.trek?.vendor?.companyInfo?.companyName ??
                                '-',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s9,
                              fontWeight: FontWeight.w400,
                              color: CommonColors.blackColor
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 1.2.h,
                  right: 2.w,
                  child: Text(
                    'TBR ID : ${booking.batch?.tbrId ?? '-'}',
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s8,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff484848),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2.h,
                  left: 4.w,
                  right: 4.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.trek?.duration ?? '-',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s9,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.blackColor.withValues(alpha: 0.5),
                            ),
                          ),
                          Text(
                            booking.batch?.startDate ?? '-',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s9,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.blackColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${booking.batch?.bookedSlots ?? 0} slots booked',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s9,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.blackColor.withValues(alpha: 0.5),
                            ),
                          ),
                          // Text(
                          //   'review done? ${booking.ratingGiven ?? 0}',
                          //   style: GoogleFonts.poppins(
                          //     fontSize: FontSize.s9,
                          //     fontWeight: FontWeight.w500,
                          //     color: CommonColors.red_B52424.withValues(alpha: 0.5),
                          //   ),
                          // ),
                          Text(
                            'View details',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s9,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff4A97FF),
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
          Positioned(
            bottom: -2.h,
            right: 3.w,
            child: Container(
              width: 25.w,
              height: 3.5.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _getStatusColor(booking.trekStatus ?? '-'),
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: Text(
                (booking.trekStatus != null && booking.trekStatus!.isNotEmpty)
                    ? booking.trekStatus![0].toUpperCase() +
                        booking.trekStatus!.substring(1)
                    : '-',
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
