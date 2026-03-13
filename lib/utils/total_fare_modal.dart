import 'package:arobo_app/utils/booking_constants.dart';
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
  final double baseAmount;
  final bool isPartialPayment;
  final bool isInsurance;
  final bool isFreeCancellation;
  final int adultCount;
  final VoidCallback onClose;
  final double vendorDiscount;
  final double couponDiscount;
  final double platformFee;
  final double gst;

  const TotalFareModal({
    Key? key,
    required this.baseAmount,
    required this.isPartialPayment,
    required this.isInsurance,
    required this.isFreeCancellation,
    required this.adultCount,
    required this.onClose,
    required this.vendorDiscount,
    required this.couponDiscount,
    required this.platformFee,
    required this.gst,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // === CONSTANTS ===
    final insuranceFeePerPerson = 80.0;
    final cancellationFeePerPerson = 90.0;
    final partialPaymentPerPerson = 999.0;

    // === STEP 1: Calculate Add-on Fees ===
    // Insurance: ₹80 per person (non-refundable)
    final insuranceFee = isInsurance ? (insuranceFeePerPerson * adultCount) : 0.0;

    // Free Cancellation: ₹90 per person (allows advance refund if cancelled >24h)
    final cancellationFee = isFreeCancellation ? (cancellationFeePerPerson * adultCount) : 0.0;

    // Advance Payment: ₹999 per person (for partial payment option)
    final totalPartialPayment = partialPaymentPerPerson * adultCount;

    // === STEP 2: Calculate NET FARE (Taxable Base) ===
    // Following Payment.md legal requirements:
    // GST is calculated on NET FARE (after all discounts, BEFORE platform fee)
    //
    // Formula: Net Fare = Base Amount - Vendor Discount - Coupon Discount
    //
    // Why this order?
    // 1. Start with base amount (total base fare for all adults)
    // 2. Apply vendor discount (set at trek creation time)
    // 3. Apply coupon discount (applied at booking time)
    // 4. Result is the NET FARE = taxable base for GST calculation

    // 2a. Start with base amount
    double netFare = baseAmount;

    // 2b. Subtract vendor discount from net fare
    netFare -= vendorDiscount;

    // 2c. Subtract coupon discount from net fare
    netFare -= couponDiscount;

    // === STEP 3: Calculate GST (CRITICAL - Per Payment.md Legal Requirements) ===
    // GST = 5% × Net Fare ONLY
    // NOT: GST = 5% × (Net Fare + Platform Fee)
    //
    // Why? Per Indian GST law and Payment.md policy:
    // - GST is calculated on the taxable base (Net Fare after all discounts)
    // - Platform Fee is a separate service charge, not part of trek fare
    // - This ensures proper tax compliance and correct GST reporting
    //
    // Reference: Payment.md lines 64, 118-119, 134-138
    //
    // Example:
    // - Net Fare: ₹5,999
    // - GST: ₹5,999 × 5% = ₹299.95 ✓ CORRECT
    // - NOT: (₹5,999 + ₹15) × 5% = ₹300.70 ✗ WRONG
    final calculatedGst = netFare * BookingConstants.gstRate;

    // === STEP 4: Calculate Final Payable Amount ===
    // Final Amount = Net Fare + Platform Fee + GST + Insurance + Free Cancellation
    //
    // Breakdown:
    // - Net Fare: Trek price after all discounts (taxable base)
    // - Platform Fee: ₹15 (fixed, non-refundable)
    // - GST: 5% of Net Fare (refundable if trek not delivered)
    // - Insurance: ₹80 × Adults (if selected, non-refundable)
    // - Free Cancellation: ₹90 × Adults (if selected)
    double amount = netFare;
    amount += platformFee;
    amount += calculatedGst;
    amount += insuranceFee;
    amount += cancellationFee;

    final finalPayable = amount;

    // === STEP 5: Calculate Remaining Amount (for Partial Payment) ===
    // Per Payment.md Policy:
    // Balance Later = Net Fare - Advance (NOT Final Payable - Advance)
    //
    // Why? Because Platform Fee, GST, and Add-ons are paid upfront with advance!
    //
    // Payment.md BASE-001 Example:
    // - Net Fare: ₹5,999
    // - Advance: ₹999
    // - Balance Later: ₹5,999 - ₹999 = ₹5,000 ✓
    // - Pay Now: ₹999 + ₹15 + ₹299.95 = ₹1,313.95 (includes Platform Fee + GST)
    //
    // Payment.md COUP-041 Example (with ₹500 coupon):
    // - Net Fare: ₹5,499
    // - Advance: ₹999
    // - Balance Later: ₹5,499 - ₹999 = ₹4,500 ✓
    // - Pay Now: ₹999 + ₹15 + ₹274.95 = ₹1,288.95 (includes Platform Fee + GST)
    final remainingAmount = netFare - totalPartialPayment;

    // === STEP 6: Determine Amount to Display (Pay Now) ===
    // For PARTIAL PAYMENT: Advance + Platform Fee + GST + Add-ons
    // For FULL PAYMENT: Complete final amount
    //
    // Per Payment.md BASE-001:
    // Pay Now = ₹999 + ₹15 + ₹299.95 = ₹1,313.95
    final totalAmount = isPartialPayment
        ? (totalPartialPayment + platformFee + calculatedGst + insuranceFee + cancellationFee)
        : finalPayable;

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
                  '₹${baseAmount.toStringAsFixed(2)}',
                  isTotal: false,
                ),
                SizedBox(height: 12),

                // Vendor Discount (if any)
                if (vendorDiscount > 0) ...[
                  _buildFareRow(
                    'Vendor Discount',
                    '-₹${vendorDiscount.toStringAsFixed(2)}',
                    textColor: CommonColors.greyColor2,
                    isTotal: false,
                  ),
                  SizedBox(height: 12),
                ],

                // Coupon Discount (if any)
                if (couponDiscount > 0) ...[
                  _buildFareRow(
                    'Coupon Discount',
                    '-₹${couponDiscount.toStringAsFixed(2)}',
                    textColor: CommonColors.greyColor2,
                    isTotal: false,
                  ),
                  SizedBox(height: 12),
                ],

                // Platform Fees
                _buildFareRow(
                  'Platform Fees',
                  '₹${platformFee.toStringAsFixed(2)}',
                  textColor: CommonColors.greyColor2,
                  isTotal: false,
                ),
                SizedBox(height: 12),

                // GST (always show)
                _buildFareRow(
                  'GST (5%)',
                  '₹${calculatedGst.toStringAsFixed(2)}',
                  textColor: CommonColors.greyColor2,
                  isTotal: false,
                ),
                SizedBox(height: 12),

                // Insurance (if selected)
                if (isInsurance) ...[
                  _buildFareRow(
                    'Insurance (₹${insuranceFeePerPerson.toStringAsFixed(0)} × $adultCount person${adultCount > 1 ? 's' : ''})',
                    '₹${insuranceFee.toStringAsFixed(2)}',
                    textColor: CommonColors.greyColor2,
                    isTotal: false,
                  ),
                  SizedBox(height: 12),
                ],

                // Free Cancellation (if selected)
                if (isFreeCancellation) ...[
                  _buildFareRow(
                    'Free Cancellation (₹${cancellationFeePerPerson.toStringAsFixed(0)} × $adultCount person${adultCount > 1 ? 's' : ''})',
                    '₹${cancellationFee.toStringAsFixed(2)}',
                    textColor: CommonColors.greyColor2,
                    isTotal: false,
                  ),
                  SizedBox(height: 12),
                ],

                // For partial payment: Show advance and remaining
                if (isPartialPayment) ...[
                  Container(height: 1, color: CommonColors.greyColor2),
                  SizedBox(height: 12),
                  _buildFareRow(
                    'Advance Payment (₹999 per person)',
                    '₹${totalPartialPayment.toStringAsFixed(2)}',
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

                SizedBox(height: 20),
                Container(height: 1, color: Colors.grey[300]),
                SizedBox(height: 20),
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
