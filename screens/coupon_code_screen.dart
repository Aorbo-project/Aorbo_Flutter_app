import 'package:arobo_app/main.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../utils/common_colors.dart';
import '../utils/common_images.dart';
import '../utils/screen_constants.dart';
import '../utils/coupon_card.dart';
import '../models/coupon_code/coupon_code_modal.dart';
import '../controller/trek_controller.dart';
import '../utils/custom_snackbar.dart';

class CouponCodeScreen extends StatefulWidget {
  const CouponCodeScreen({Key? key}) : super(key: key);

  @override
  State<CouponCodeScreen> createState() => _CouponCodeScreenState();
}

class _CouponCodeScreenState extends State<CouponCodeScreen> {
  final TextEditingController _couponController = TextEditingController();
  final TrekController _trekController = Get.find<TrekController>();

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    await _trekController.getCoupons();
  }

  Future<void> _validateAndApplyCoupon(String couponCode) async {
    if (couponCode.isEmpty) return;

    // Get the base amount for validation
    final basePricePerPerson = double.parse(_trekController.trekDetailData.value.basePrice?? "0.0");
    final baseAmount = basePricePerPerson * _trekController.trekPersonCount.value;
    final customerId = sp!.getInt(SpUtil.userID) ?? 0;

    if (baseAmount <= 0) {
      CustomSnackBar.show(
        context,
        message: 'Unable to validate coupon. Invalid trek amount.',
      );
      return;
    }

    if (customerId <= 0) {
      CustomSnackBar.show(
        context,
        message: 'Unable to validate coupon. User not found.',
      );
      return;
    }

    // Show loading state
    setState(() {});

    try {
      final isValid = await _trekController.validateCoupon(
        couponCode: couponCode,
        customerId: customerId,
        baseAmount: baseAmount,
      );

      if (isValid) {
        // Coupon is valid, return to previous screen
        Navigator.pop(context, couponCode);
      }
      // If invalid, the error message is already shown in the validateCoupon function
    } catch (e) {
      CustomSnackBar.show(
        context,
        message: 'Failed to validate coupon. Please try again.',
      );
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  List<CouponCardData> get _filteredCoupons {
    if (_couponController.text.isEmpty) {
      return _trekController.couponsList;
    }
    return _trekController.couponsList
        .where((coupon) =>
            coupon.code?.toLowerCase().contains(_couponController.text.toLowerCase()) ?? false)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.whiteColor,
      appBar: AppBar(
        backgroundColor: CommonColors.whiteColor,
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: CommonColors.transparent,
        title: Row(
          children: [
            SvgPicture.asset(
              CommonImages.couponIcon,
              width: 6.w,
              height: 6.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Coupon Code',
              style: GoogleFonts.poppins(
                fontSize: FontSize.s14,
                fontWeight: FontWeight.w500,
                color: CommonColors.blackColor,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Coupon Input Field
          Container(
            margin: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: CommonColors.whiteColor,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: CommonColors.profileColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: CommonColors.blackColor.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s11,
                      color: CommonColors.blackColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter Coupon Code',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: FontSize.s11,
                        color:   CommonColors.cFF969696,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.5.h,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {}); // Trigger rebuild to update filtered list
                    },
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (_couponController.text.isNotEmpty) {
                      await _validateAndApplyCoupon(_couponController.text);
                    }
                  },
                  child: Text(
                    'Apply',
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w500,
                      color: _couponController.text.isNotEmpty
                          ? CommonColors.materialBlue
                          :   CommonColors.cFF969696,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content based on loading state
          Expanded(
            child: Obx(() {
              if (_trekController.isCouponLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (_trekController.couponErrorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Failed to load coupons',
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s12,
                          color: CommonColors.blackColor,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        _trekController.couponErrorMessage.value,
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s10,
                          color: CommonColors.blackColor.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2.h),
                      ElevatedButton(
                        onPressed: _fetchCoupons,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (_filteredCoupons.isEmpty) {
                return Center(
                  child: Text(
                    'No matching coupons found',
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s10,
                      color: CommonColors.blackColor.withValues(alpha: 0.6),
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                itemCount: _filteredCoupons.length,
                itemBuilder: (context, index) {
                  final coupon = _filteredCoupons[index];
                  return CouponCard(
                    coupon: coupon,
                    onApply: () async {
                      await _validateAndApplyCoupon(coupon.code ?? '');
                    },
                    isApplied: false,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
