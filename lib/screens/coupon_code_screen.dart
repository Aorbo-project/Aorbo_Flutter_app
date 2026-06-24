import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../utils/common_colors.dart';
import '../utils/common_images.dart';
import '../utils/screen_constants.dart';
import '../utils/coupon_card.dart';
import '../models/coupon_code/coupon_code_model.dart';
import '../controller/trek_controller.dart';

class CouponCodeScreen extends StatefulWidget {
  const CouponCodeScreen({super.key});

  @override
  State<CouponCodeScreen> createState() => _CouponCodeScreenState();
}

class _CouponCodeScreenState extends State<CouponCodeScreen> {
  final TextEditingController _couponController = TextEditingController();
  final TrekController _trekController = Get.find<TrekController>();
  RxString searchQuery = "".obs;

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    await _trekController.fetchVendorCoupons();
  }



  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
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
        surfaceTintColor: Colors.transparent,
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
      body: Stack(
        children: [
          Column(
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
                      color: Colors.black.withValues(alpha: 0.05),
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
                            color: const Color(0xff969696),
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
                          _trekController.validateCoupon(_couponController.text);
                        }
                      },
                      child: Text(
                        'Apply',
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s11,
                          fontWeight: FontWeight.w500,
                          color: _couponController.text.isNotEmpty
                              ? CommonColors.blueColor
                              : const Color(0xff969696),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content based on loading state
              Expanded(
                child: Obx(() {
                  final isCouponLoading = _trekController.vendorCouponsObserver.value.maybeWhen(loading: (data) => true,orElse: () => false);
                  List<CouponCardData>? couponsList = _trekController.vendorCouponsObserver.value.maybeWhen(success: (couponsResponse) => (couponsResponse as CouponCodeModel).data,error: (sc) => [],orElse: () => [CouponCardData(),CouponCardData(),CouponCardData(),CouponCardData()]);
                  final couponErrorMessage = _trekController.vendorCouponsObserver.value.maybeWhen(error: (errorMsg) => errorMsg,orElse: () => "");
                  if(couponsList?.isEmpty == true) return SizedBox();


                  // final filteredCoupons =  _couponController.text.isEmpty ? couponsList : couponsList?.where((coupon) =>
                  //           coupon.code?.toLowerCase().contains(_couponController.text.toLowerCase()) ?? false)
                  //       .toList();

                  if (isCouponLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (couponErrorMessage.isNotEmpty) {
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
                            couponErrorMessage,
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

                  if (couponsList?.isEmpty == true) {
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
                    itemCount: couponsList?.length,
                    itemBuilder: (context, index) {
                      final coupon = couponsList?[index];
                      return CouponCard(
                        coupon: coupon,
                        onApply: () {
                          _trekController.validateCoupon(coupon?.code ?? "");
                        },
                        isApplied: false,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
          Obx(() => _trekController.validateCouponObserver.value.maybeWhen(
            loading: (loadingData) => Container(
              color: CommonColors.grey400,
              child: Center(
                child: CircularProgressIndicator(
                  color: CommonColors.blueColor,
                ),
              ),
            ),
            orElse: () => const SizedBox(),
          ))
        ],
      ),
    );
  }
}
