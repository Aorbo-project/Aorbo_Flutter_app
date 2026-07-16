import 'package:arobo_app/freezed_models/booking/booking_data_model.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class TotalFareModal extends StatelessWidget {
  final BreakDownDataModel? breakDown;
  final int adultCount;
  final VoidCallback onClose;
  final bool isPayingAdvance; // NEW: Tells the modal what the user selected

  const TotalFareModal({
    super.key,
    required this.breakDown,
    required this.adultCount,
    required this.onClose,
    this.isPayingAdvance = false, // Defaults to false (Standard)
  });

  String _format(dynamic value) {
    if (value == null) return '0.00';
    final num? val = num.tryParse(value.toString());
    return val?.toStringAsFixed(2) ?? '0.00';
  }

  bool _isGreaterThanZero(dynamic value) {
    if (value == null) return false;
    final num? val = num.tryParse(value.toString());
    return val != null && val > 0;
  }

  @override
  Widget build(BuildContext context) {
    final String policyType = (breakDown?.cancellationPolicyType ?? 'standard')
        .toString()
        .toLowerCase();
    final bool isFlexiblePolicy = policyType == 'flexible';

    // Show the green split-payment container ONLY IF the policy is flexible
    // AND the user actually selected the "Pay Advance" option.
    final bool showFlexiblePlan = isFlexiblePolicy && isPayingAdvance;

    // ---------- Parse all numeric values ----------
    double baseTotal = double.tryParse(_format(breakDown?.baseTotal)) ?? 0.0;
    double operatorDiscount =
        double.tryParse(_format(breakDown?.vendorDiscount)) ?? 0.0;
    double couponDiscount =
        double.tryParse(
          _format(breakDown?.couponDiscount ?? breakDown?.discount),
        ) ??
        0.0;
    double platformFee =
        double.tryParse(_format(breakDown?.platformFee)) ?? 0.0;
    double gst = double.tryParse(_format(breakDown?.gst)) ?? 0.0;
    double finalAmount =
        double.tryParse(_format(breakDown?.finalAmount)) ?? 0.0;

    // If paying the full amount, the amount to pay now is the final total.
    double amountToPayNow = isPayingAdvance
        ? (double.tryParse(_format(breakDown?.amountToPayNow)) ?? 0.0)
        : finalAmount;

    double remainingAmount = isPayingAdvance
        ? (double.tryParse(_format(breakDown?.remainingAmount)) ?? 0.0)
        : 0.0;

    double advanceTotal =
        double.tryParse(_format(breakDown?.advanceAmount)) ?? 0.0;

    // ---------- Per-person breakdowns ----------
    double perPersonBase = adultCount > 0 ? (baseTotal / adultCount) : 0.0;
    double perPersonOperatorDiscount = adultCount > 0
        ? (operatorDiscount / adultCount)
        : 0.0;
    double perPersonGst = adultCount > 0 ? (gst / adultCount) : 0.0;
    double perPersonAdvance = adultCount > 0
        ? (advanceTotal / adultCount)
        : 0.0;

    // For flexible plan
    double taxesAndFees = amountToPayNow - advanceTotal;
    if (taxesAndFees < 0) taxesAndFees = 0;

    final String travellerLabel = 'Traveller${adultCount > 1 ? 's' : ''}';

    return Container(
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 2.h, bottom: 1.5.h),
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fare Breakup',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      GestureDetector(
                        onTap: onClose,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: CommonColors.whiteColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  _buildFareRow(
                    'Base Fare (₹${perPersonBase.toStringAsFixed(0)} x $adultCount $travellerLabel)',
                    '₹${_format(baseTotal)}',
                  ),
                  SizedBox(height: 1.2.h),

                  if (_isGreaterThanZero(operatorDiscount)) ...[
                    _buildFareRow(
                      'Operator Discount (₹${perPersonOperatorDiscount.toStringAsFixed(0)} x $adultCount $travellerLabel)',
                      '-₹${_format(operatorDiscount)}',
                      valueColor: CommonColors.cFF0F7B6C,
                    ),
                    SizedBox(height: 1.2.h),
                  ],

                  if (_isGreaterThanZero(couponDiscount)) ...[
                    _buildFareRow(
                      'Coupon Discount',
                      '-₹${_format(couponDiscount)}',
                      valueColor: CommonColors.cFF0F7B6C,
                    ),
                    SizedBox(height: 1.2.h),
                  ],

                  if (_isGreaterThanZero(gst)) ...[
                    _buildFareRow(
                      'GST (₹${perPersonGst.toStringAsFixed(0)} x $adultCount $travellerLabel)',
                      '₹${_format(gst)}',
                      isSub: true,
                    ),
                    SizedBox(height: 1.2.h),
                  ],

                  _buildFareRow(
                    'Platform Fees',
                    '₹${_format(platformFee)}',
                    isSub: true,
                  ),
                  SizedBox(height: 1.2.h),

                  Divider(color: CommonColors.trekroutecolorlight, height: 2.h),
                  _buildFareRow(
                    'Total Trek Amount',
                    '₹${_format(finalAmount)}',
                    isTotal: true,
                  ),
                  SizedBox(height: 2.h),

                  // --- CONDITIONAL CONTAINER ---
                  if (showFlexiblePlan) ...[
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: CommonColors.cFFE6F5F3,
                        borderRadius: BorderRadius.circular(2.w),
                        border: Border.all(
                          color: CommonColors.cFF0F7B6C.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Flexible Payment Plan Selected',
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: CommonColors.cFF0F7B6C,
                            ),
                          ),
                          SizedBox(height: 1.5.h),
                          _buildFareRow(
                            'Advance Payment (₹${perPersonAdvance.toStringAsFixed(0)} x $adultCount $travellerLabel)',
                            '₹${_format(advanceTotal)}',
                          ),
                          SizedBox(height: 1.2.h),
                          _buildFareRow(
                            'Taxes & Fees',
                            '₹${_format(taxesAndFees)}',
                            isSub: true,
                          ),
                          SizedBox(height: 1.2.h),
                          Divider(
                            color: CommonColors.cFF0F7B6C.withOpacity(0.3),
                            height: 1.h,
                          ),
                          SizedBox(height: 1.2.h),
                          _buildFareRow(
                            'Amount Payable Now',
                            '₹${_format(amountToPayNow)}',
                            isTotal: true,
                            valueColor: CommonColors.trek_route_color,
                          ),
                          SizedBox(height: 1.2.h),
                          _buildFareRow(
                            'Remaining Amount (Pay later)',
                            '₹${_format(remainingAmount)}',
                            isSub: true,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Shows for Standard Policy OR Flexible Policy with "Pay Full Amount"
                    _buildFareRow(
                      'Amount Payable Now',
                      '₹${_format(amountToPayNow)}',
                      isTotal: true,
                      valueColor: CommonColors.trek_route_color,
                    ),
                  ],

                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareRow(
    String label,
    String amount, {
    bool isTotal = false,
    bool isSub = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 13.sp : 10.sp,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal
                  ? const Color(0xFF0F172A)
                  : (isSub ? const Color(0xFF64748B) : CommonColors.blackColor),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 13.sp : 10.sp,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color:
                valueColor ??
                (isTotal
                    ? CommonColors.trek_route_color
                    : (isSub
                          ? const Color(0xFF64748B)
                          : CommonColors.blackColor)),
          ),
        ),
      ],
    );
  }
}
