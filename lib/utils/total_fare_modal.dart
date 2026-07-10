import 'package:arobo_app/freezed_models/booking/booking_data_model.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';

/// Total Fare Modal - Displays detailed fare breakdown for trek bookings
///
/// This modal shows a complete breakdown of the fare calculation to the user,
/// including all discounts, fees, taxes, and add-ons.
///
/// LEGAL COMPLIANCE NOTES (as per Payment.md):
/// ============================================
/// 1. GST Calculation: GST (5%) is calculated on NET FARE only (base price after discounts)
///    NOT on (fare + platform fee). This ensures proper tax compliance.
///    Reference: Payment.md lines 64, 118-119, 134-138
///
/// 2. Platform Fee: ₹15 (fixed)
///    - Non-refundable in all scenarios
///    - Part of platform revenue
///    - Taxable separately (not included in trek fare GST calculation)
///
/// 3. Add-ons (Insurance/Free Cancellation):
///    - Insurance: ₹80 per person (non-refundable, passed to insurer)
///    - Free Cancellation: ₹90 per person (allows advance refund if cancelled >24h)
///    - Both charged per person
///
/// 4. Refund Policy: GST is refundable if trek is not delivered (customer cancels before departure)
///    Company must adjust GST returns accordingly.
///
/// CALCULATION FORMULA (Per Payment.md Policy):
/// =============================================
/// Step 1: NET FARE = Base Price - Vendor Discount - Coupon Discount
/// Step 2: **GST = NET FARE × 5%** (NOT on Net Fare + Platform Fee)
/// Step 3: FINAL AMOUNT = NET FARE + Platform Fee + GST + Insurance + Free Cancellation
///
/// For PARTIAL PAYMENT:
/// ====================
/// - Advance Payment: ₹999 per person
/// - Remaining Amount: FINAL AMOUNT - Advance Payment
/// - User pays advance now, remaining amount due before trek start
///
/// For FULL PAYMENT:
/// =================
/// - Pay Now: FINAL AMOUNT (complete amount)
/// - Remaining: ₹0
///
/// EXAMPLE CALCULATION (1 Adult, ₹5,999 fare, no discounts):
/// ==========================================================
/// - Base Fare: ₹5,999
/// - Vendor Discount: ₹0
/// - Coupon Discount: ₹0
/// - Net Fare: ₹5,999
/// - Platform Fee: ₹15
/// - GST (5% of ₹5,999): ₹299.95
/// - Final Amount: ₹6,313.95
/// - If Partial: Advance ₹999, Remaining ₹5,314.95
/// - If Full: Pay Now ₹6,313.95
///
/// EXAMPLE WITH COUPON (1 Adult, ₹5,999 fare, ₹500 coupon):
/// ==========================================================
/// - Base Fare: ₹5,999
/// - Coupon Discount: ₹500
/// - Net Fare: ₹5,499
/// - Platform Fee: ₹15
/// - GST (5% of ₹5,499): ₹274.95
/// - Final Amount: ₹5,788.95
class TotalFareModal extends StatelessWidget {
  final BreakDownDataModel? breakDown;
  final int adultCount;
  final VoidCallback onClose;


  const TotalFareModal({
    super.key,
    required this.breakDown,
    required this.adultCount,
    required this.onClose
  });

  @override
  Widget build(BuildContext context) {


    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar at top
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fare Breakup',
                      textScaler: const TextScaler.linear(1.0),
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s15,
                        fontWeight: FontWeight.w500,
                        color: CommonColors.blackColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: SvgPicture.asset(
                        CommonImages.close,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Base Amount (Total Basic Cost)
                _buildFareRow(
                  'Total Basic Cost',
                  '₹${breakDown?.baseTotal.toStringAsFixed(2)}',
                  isTotal: false,
                ),
                SizedBox(height: 12),

                // Vendor Discount (if any)
                if ((breakDown?.vendorDiscount ?? 0) > 0) ...[
                  _buildFareRow(
                    'Vendor Discount',
                    '-₹${breakDown?.vendorDiscount.toStringAsFixed(2)}',
                    textColor: CommonColors.greyColor2,
                    isTotal: false,
                  ),
                  SizedBox(height: 12),
                ],

                // Coupon Discount (if any)
                if ((breakDown?.discount ?? 0) > 0) ...[
                  _buildFareRow(
                    'Coupon Discount',
                    '-₹${breakDown?.discount.toStringAsFixed(2)}',
                    textColor: CommonColors.greyColor2,
                    isTotal: false,
                  ),
                  SizedBox(height: 12),
                ],

                // Platform Fees
                _buildFareRow(
                  'Platform Fees',
                  '₹${breakDown?.platformFee.toStringAsFixed(2)}',
                  textColor: CommonColors.greyColor2,
                  isTotal: false,
                ),
                SizedBox(height: 12),

                // GST (always show)
                _buildFareRow(
                  'GST (5%)',
                  '₹${breakDown?.gst.toStringAsFixed(2)}',
                  textColor: CommonColors.greyColor2,
                  isTotal: false,
                ),
                SizedBox(height: 12),

                // Insurance (if selected)
                if ((breakDown?.insuranceFee ?? 0) > 0) ...[
                  _buildFareRow(
                    'Insurance (₹${breakDown?.insuranceFee.toStringAsFixed(0)} × $adultCount person${adultCount > 1 ? 's' : ''})',
                    '₹${breakDown?.insuranceFee.toStringAsFixed(2)}',
                    textColor: CommonColors.greyColor2,
                    isTotal: false,
                  ),
                  SizedBox(height: 12),
                ],

                // Free Cancellation (if selected)
                if ((breakDown?.cancellationFee ?? 0) > 0) ...[
                  _buildFareRow(
                    'Free Cancellation (₹${breakDown?.cancellationFee.toStringAsFixed(0)} × $adultCount person${adultCount > 1 ? 's' : ''})',
                    '₹${breakDown?.cancellationFee.toStringAsFixed(2)}',
                    textColor: CommonColors.greyColor2,
                    isTotal: false,
                  ),
                  SizedBox(height: 12),
                ],

                // For partial payment: Show advance and remaining
                if (breakDown?.cancellationPolicyType == 'flexible') ...[
                  Container(height: 1, color: CommonColors.greyColor2),
                  SizedBox(height: 12),
                  _buildFareRow(
                    'Advance Payment (₹999 per person)',
                    '₹${breakDown?.amountToPayNow.toStringAsFixed(2)}',
                    textColor: CommonColors.greyColor2,
                    isTotal: false,
                  ),
                  SizedBox(height: 12),
                  _buildFareRow(
                    'Remaining Amount',
                    '₹${breakDown?.remainingAmount.toStringAsFixed(2)}',
                    textColor: CommonColors.greyColor2,
                    isTotal: false,
                  ),
                  SizedBox(height: 12),
                ],

                SizedBox(height: 20),
                Container(height: 1, color: Colors.grey[300]),
                SizedBox(height: 20),
                _buildFareRow(
                  breakDown?.cancellationPolicyType == 'flexible' ? 'Amount Payable Now' : 'Total Amount',
                  '₹${breakDown?.amountToPayNow.toStringAsFixed(2)}',
                  isTotal: true,
                  textColor: CommonColors.greyColor2,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFareRow(
    String label,
    String amount, {
    String? subtext,
    bool isTotal = false,
    Color? textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              textScaler: const TextScaler.linear(1.0),
              style: GoogleFonts.poppins(
                fontSize: isTotal ? FontSize.s10 : FontSize.s9,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
                color: textColor ?? CommonColors.blackColor,
              ),
            ),
            Text(
              amount,
              textScaler: const TextScaler.linear(1.0),
              style: GoogleFonts.poppins(
                fontSize: isTotal ? FontSize.s10 : FontSize.s9,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
                color: textColor ?? CommonColors.blackColor,
              ),
            ),
          ],
        ),
        if (subtext != null) ...[
          SizedBox(height: 4),
          Text(
            subtext,
            textScaler: const TextScaler.linear(1.0),
            style: GoogleFonts.poppins(
              fontSize: FontSize.s7,
              fontWeight: FontWeight.w400,
              color: CommonColors.greyColor,
            ),
          ),
        ],
      ],
    );
  }
}
