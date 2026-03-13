import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../utils/booking_constants.dart';
import '../utils/common_colors.dart';
import '../utils/common_images.dart';
import '../utils/screen_constants.dart';
import 'package:intl/intl.dart';

class SlotBookingDetailsModal extends StatelessWidget {
  // Add parameters to receive booking details
  final String trekName;
  final int adultCount;
  final String fromLocation;
  final String toLocation;
  final String departureDate;
  final String duration;
  final String email;
  final String phone;
  final List<Map<String, dynamic>> travellers;
  final double baseAmount;
  final double discountAmount;
  final bool isInsurance;
  final bool isFreeCancellation;

  // Partial payment specific parameters
  final bool isPartialPayment;
  final double advanceAmount;
  final double remainingAmount;
  final double finalPayable;
  final double gst;

  const SlotBookingDetailsModal({
    Key? key,
    required this.trekName,
    required this.adultCount,
    required this.fromLocation,
    required this.toLocation,
    required this.departureDate,
    required this.duration,
    required this.email,
    required this.phone,
    required this.travellers,
    required this.baseAmount,
    required this.discountAmount,
    required this.isInsurance,
    required this.isFreeCancellation,
    required this.isPartialPayment,
    required this.advanceAmount,
    required this.remainingAmount,
    required this.finalPayable,
    required this.gst,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the values from BookingConstants to ensure consistency
    // This matches the traveller information screen and Payment.md policy
    final platformFee = BookingConstants.platformFee; // ₹15 (per Payment.md policy)
    final insuranceFee = isInsurance ? BookingConstants.insuranceFeePerPerson : 0.0;
    final cancellationFee = isFreeCancellation
        ? (BookingConstants.cancellationFeePerPerson * adultCount)
        : 0.0;

    // For partial payment, show advance and remaining amounts
    // For full payment, show the complete breakdown
    final totalAmount = isPartialPayment ? advanceAmount : finalPayable;

    // Helper method for calculating end date
    String _calculateEndDate(String startDate, String duration) {
      try {
        // Parse the start date - handle different date formats
        DateTime start;
        if (startDate.contains('-')) {
          // Handle "2025-09-04" format
          start = DateFormat('yyyy-MM-dd').parse(startDate);
        } else {
          // Handle "dd/MM/yyyy" format
          start = DateFormat('dd/MM/yyyy').parse(startDate);
        }

        // Extract number of days from duration
        // Handle both "3D 2N" and "3D|2N" formats
        String daysStr = duration.split(' ')[0];
        if (daysStr.contains('D')) {
          daysStr = daysStr.replaceAll('D', '');
        }
        final int days = int.parse(daysStr);

        // Calculate end date
        final DateTime end = start.add(Duration(days: days));

        // Format the end date
        return DateFormat('yyyy-MM-dd').format(end);
      } catch (e) {
        // Return original date if parsing fails
        return startDate;
      }
    }

    // Helper method to format duration like traveller information screen
    String _formatDuration(String duration) {
      try {
        // Handle "3D 2N" format and convert to "3D|2N"
        if (duration.contains(' ')) {
          return duration.replaceAll(' ', '|');
        }
        return duration;
      } catch (e) {
        return duration;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4.w),
          topRight: Radius.circular(4.w),
        ),
      ),
      padding: EdgeInsets.all(5.w),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slot Booking Details Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Slot Booking Details',
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s15,
                    fontWeight: FontWeight.w500,
                    color: CommonColors.blackColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset(
                    CommonImages.close,
                    width: 6.w,
                    height: 6.w,
                  ), // Close icon
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // SizedBox(height: 2.h),

            // Trek Details
            Text(
              'Trekking Freaks Limited',
              style: GoogleFonts.poppins(
                fontSize: FontSize.s14,
                fontWeight: FontWeight.w600,
                color: CommonColors.blackColor,
              ),
            ),
            SizedBox(height: 0.5.h),
            RichText(
              textScaler: const TextScaler.linear(1.0),
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s9,
                  color: CommonColors.blackColor.withValues(alpha: 0.7),
                ),
                children: <TextSpan>[
                  TextSpan(
                    text:
                        '$adultCount ${adultCount == 1 ? 'Trekker' : 'Trekkers'}: ',
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s9,
                      fontWeight: FontWeight.w500,
                      color: CommonColors.blackColor,
                    ), // Apply different weight here
                  ),
                  TextSpan(
                    text: '$adultCount Adults/ From $fromLocation',
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s9,
                      fontWeight: FontWeight.w300,
                      color: CommonColors.blackColor,
                    ), // Keep original weight
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            // Replicated section from TravellerInformationScreen
            Container(
              width: 99.w,
              height: 5.8.h,
              decoration: BoxDecoration(),
              margin: const EdgeInsets.only(
                // left: 10,
                right: 10,
                // bottom: 14,
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
                              departureDate,
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.roboto(
                                fontSize: FontSize.s9,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.blackColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        fromLocation,
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.roboto(
                          fontSize: FontSize.s9,
                          fontWeight: FontWeight.w300,
                          color: CommonColors.blackColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 14,
                      right: 14,
                    ),
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      top: 4,
                      bottom: 4,
                    ),
                    decoration: BoxDecoration(
                      color: CommonColors.greyColorEBEBEB,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      textAlign: TextAlign.center,
                      textScaler: const TextScaler.linear(1.0),
                      _formatDuration(duration),
                      style: GoogleFonts.roboto(
                        fontSize: FontSize.s10,
                        fontWeight: FontWeight.w300,
                        color: CommonColors.blackColor,
                      ),
                    ),
                  ),
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
                              _calculateEndDate(departureDate, duration),
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.roboto(
                                fontSize: FontSize.s9,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.blackColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        toLocation,
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.roboto(
                          fontSize: FontSize.s9,
                          fontWeight: FontWeight.w300,
                          color: CommonColors.blackColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // SizedBox(height: 2.h),
            Divider(
              color: CommonColors.greyColor,
              thickness: 1,
            ),
            SizedBox(height: 1.h),

            // Traveller Details
            Text(
              'Traveller Details',
              style: GoogleFonts.poppins(
                fontSize: FontSize.s14,
                fontWeight: FontWeight.w600,
                color: CommonColors.blackColor,
              ),
            ),
            SizedBox(height: 1.h),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              separatorBuilder: (context, index) => SizedBox(height: 1.h),
              itemCount: travellers.length,
              itemBuilder: (context, index) {
                final traveller = travellers[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      traveller['nameController'].text,
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s11,
                        fontWeight: FontWeight.w500,
                        color: CommonColors.blackColor,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      '${traveller['gender']}, ${traveller['ageController'].text} Years',
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s9,
                        fontWeight: FontWeight.w400,
                        color: CommonColors.blackColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 1.h),
            Divider(color: CommonColors.greyColor, thickness: 1),
            SizedBox(height: 1.h),

            // Tickets will be sent to
            Text(
              'Your tickets will be sent to',
              style: GoogleFonts.poppins(
                fontSize: FontSize.s14,
                fontWeight: FontWeight.w600,
                color: CommonColors.blackColor,
              ),
            ),
            SizedBox(height: 1.5.h),
            Text(
              email,
              style: GoogleFonts.poppins(
                fontSize: FontSize.s11,
                fontWeight: FontWeight.w400,
                color: CommonColors.blackColor,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              phone,
              style: GoogleFonts.poppins(
                fontSize: FontSize.s11,
                fontWeight: FontWeight.w400,
                color: CommonColors.blackColor,
              ),
            ),
            SizedBox(height: 1.h),
            Divider(color: CommonColors.greyColor, thickness: 1),
            SizedBox(height: 1.h),

            // Fare Breakup
            Text(
              'Fare Breakup',
              style: GoogleFonts.poppins(
                fontSize: FontSize.s15,
                fontWeight: FontWeight.w500,
                color: CommonColors.blackColor,
              ),
            ),
            SizedBox(height: 20),

            // Base Amount (Total Basic Cost)
            _buildFareRow(
              'Total Basic Cost',
              '₹${baseAmount.toStringAsFixed(2)}',
              isTotal: false,
            ),
            SizedBox(height: 12),

            // Vendor Discount (if any)
            if (discountAmount > 0) ...[
              _buildFareRow(
                'Vendor Discount',
                '-₹${discountAmount.toStringAsFixed(2)}',
                textColor: CommonColors.greyColor2,
                isTotal: false,
              ),
              SizedBox(height: 12),
            ],

            // Fare Price After Vendor Discount

            // Platform Fee
            _buildFareRow(
              'Platform Fees',
              '₹${platformFee.toStringAsFixed(2)}',
              textColor: CommonColors.greyColor2,
              isTotal: false,
            ),
            SizedBox(height: 12),

            // GST
            _buildFareRow(
              'GST (5%)',
              '₹${gst.toStringAsFixed(2)}',
              textColor: CommonColors.greyColor2,
              isTotal: false,
            ),
            SizedBox(height: 12),

            // Insurance (if selected)
            if (isInsurance) ...[
              _buildFareRow(
                'Insurance',
                '₹${insuranceFee.toStringAsFixed(2)}',
                textColor: CommonColors.greyColor2,
                isTotal: false,
              ),
              SizedBox(height: 12),
            ],

            // Free Cancellation (if selected)
            if (isFreeCancellation) ...[
              _buildFareRow(
                'Free Cancellation',
                '₹${cancellationFee.toStringAsFixed(2)}',
                textColor: CommonColors.greyColor2,
                isTotal: false,
              ),
              SizedBox(height: 12),
            ],

            // Divider before total
            Container(
              height: 1,
              color: Colors.grey[300],
            ),
            SizedBox(height: 20),

            // For partial payment: Show advance and remaining
            if (isPartialPayment) ...[
              // Divider before partial payment details
              Container(
                height: 1,
                color: Colors.grey[300],
              ),
              SizedBox(height: 20),

              _buildFareRow(
                'Advance Payment (₹999 per person)',
                '₹${advanceAmount.toStringAsFixed(2)}',
                textColor: CommonColors.greyColor2,
                isTotal: false,
              ),
              SizedBox(height: 12),

              _buildFareRow(
                'Remaining Amount',
                '₹${remainingAmount.toStringAsFixed(2)}',
                textColor: CommonColors.greyColor2,
                isTotal: false,
              ),
              SizedBox(height: 12),
            ],

            // Divider before total
            Container(
              height: 1,
              color: Colors.grey[300],
            ),
            SizedBox(height: 20),

            // Total Amount (Advance for partial, Full amount for complete)
            _buildFareRow(
              isPartialPayment ? 'Amount Payable Now' : 'Total Amount',
              '₹${totalAmount.toStringAsFixed(2)}',
              isTotal: true,
              textColor: CommonColors.greyColor2,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper method for fare rows
  Widget _buildFareRow(String label, String amount,
      {Color? textColor, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? FontSize.s10 : FontSize.s9,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: textColor ?? CommonColors.blackColor.withValues(alpha: 0.7),
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? FontSize.s10 : FontSize.s9,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: textColor ?? CommonColors.blackColor,
          ),
        ),
      ],
    );
  }
}
