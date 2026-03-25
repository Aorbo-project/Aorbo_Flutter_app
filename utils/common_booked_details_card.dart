import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../models/treaks/booking_history_modal.dart';
import 'common_colors.dart';
import 'common_images.dart';

class UpcomingBookingCard extends StatelessWidget {
  final BookingHistoryData booking;
  final VoidCallback? onViewMoreTap;

  const UpcomingBookingCard({
    super.key,
    required this.booking,
    this.onViewMoreTap,
  });

  String? _getOriginCity() {
    // You can implement logic to determine origin city based on booking data
    // For now, returning a default or trying to extract from batch/city info
    if (booking.city?.id != null) {
      // You might want to map cityId to actual city names
      return booking.city?.cityName; // Replace with actual city mapping logic
    }
    return 'Origin City';
  }

  String _getDestinationCity() {
    // You can implement logic to determine destination city based on trek data
    if (booking.trek?.title != null) {
      // Extract destination from trek title or use trek destination info
      return booking.trek!.title!;
    }
    return 'Destination';
  }

  String _getDurationText() {
    if (booking.trek?.duration != null) {
      // return booking.trek!.duration!;

      if (booking.trek?.durationDays != null &&
          booking.trek?.durationNights != null) {
        return '${booking.trek!.durationDays}D | ${booking.trek!.durationNights}N';
      }
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row - Icon + Title + PNR
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // logo
              Center(
                child: Image.asset(
                  CommonImages.logo,
                  width: 12.w,
                  height: 5.h,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.trek?.title ?? 'Unknown Trek',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: CommonColors.blackColor,
                      ),
                      maxLines: 1, // show only one line
                      overflow: TextOverflow.ellipsis, // add "..."
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      booking.trek?.vendor?.companyInfo?.companyName ??
                          'Unknown Organiser',
                      style: TextStyle(
                        fontSize: FontSize.s10,
                        color: CommonColors.greyTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "TRB ID : ${booking.batch?.tbrId ?? '00'}",
                style: TextStyle(
                  fontSize: 10.sp,
                  color: CommonColors.greyTextColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.5.h),

          /// Route Row - From, Duration, To
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _getOriginCity() ?? 'N/A',
                    style: TextStyle(
                      fontSize: FontSize.s10,
                      fontWeight: FontWeight.w500,
                      color: CommonColors.blackColor,
                    ),
                    maxLines: 1, // show only one line
                    overflow: TextOverflow.ellipsis, // add "..."
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: CommonColors.greyColor,
                    borderRadius: BorderRadius.circular(2.h),
                  ),
                  child: Text(
                    _getDurationText(),
                    style: TextStyle(
                      fontSize:FontSize.s9,
                      color: CommonColors.whiteColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _getDestinationCity(),
                    style: TextStyle(
                      fontSize: FontSize.s10,
                      fontWeight: FontWeight.w500,
                      color: CommonColors.blackColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 1.5.h),

          /// Slots
          Text(
            "Slots : ${booking.totalTravelers ?? 0} Travellers",
            style: TextStyle(
              fontSize: FontSize.s10,
              color: CommonColors.blackColor,
            ),
          ),

          SizedBox(height: 1.h),

          /// Description
          Text(
            booking.trek?.description ?? 'No description available',
            style: TextStyle(
              fontSize: FontSize.s10,
              color: CommonColors.blackColor,
            ),
          ),
          SizedBox(height: 0.5.h),

          /// View More
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onViewMoreTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "View more",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: CommonColors.materialBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
