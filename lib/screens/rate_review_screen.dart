import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/models/treaks/booking_history_modal.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:animated_rating_stars/animated_rating_stars.dart';
import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';
import '../utils/common_btn.dart';

class RateReviewScreen extends StatefulWidget {
  const RateReviewScreen({super.key});

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  final TrekController _trekC = Get.find<TrekController>();
  BookingHistoryData? booking;
  final dynamic arguments = Get.arguments;
  double selectedRating = 0;
  List<String> selectedCategories = [];
  final TextEditingController reviewController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Safety and Security',
      'icon': CommonImages.protect,
      'isSelected': false,
    },
    {
      'name': 'Organizer Manner',
      'icon': CommonImages.userAccount,
      'isSelected': false,
    },
    {'name': 'Trek Planning', 'icon': CommonImages.toDo, 'isSelected': false},
    {'name': 'Women Safety', 'icon': CommonImages.female, 'isSelected': false},
  ];

  @override
  void initState() {
    super.initState();

    // Handle pre-selected rating from arguments
    if (arguments is Map<String, dynamic>) {
      booking = arguments['booking'];
      final preSelectedRating = arguments['preSelectedRating'];
      if (preSelectedRating != null) {
        selectedRating = preSelectedRating;
        _trekC.rating.value = selectedRating;
      }
    } else if (arguments is BookingHistoryData) {
      booking = arguments;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Booking is already set in initState, no need to reassign here
    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('No booking data found')),
      );
    }
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GestureDetector(
          // Wrap with GestureDetector
          onTap: () {
            // Dismiss keyboard and unfocus
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: Scaffold(
            backgroundColor: CommonColors.whiteColor,
            appBar: AppBar(
              backgroundColor: CommonColors.whiteColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: true,
              leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(Icons.close),
              ),
              centerTitle: false,
              title: Text(
                'Rate & Review Your Trek',
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s14,
                  fontWeight: FontWeight.w600,
                  color: CommonColors.blackColor,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRatingCard(),
                  SizedBox(height: 2.h),
                  _buildShareWhatYouLovedSection(),
                  SizedBox(height: 4.h),
                  _buildReviewTextArea(),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: SafeArea(
                child: _buildSubmitButton(
                  trekId: booking?.trek?.id ?? 0,
                  bookingId: booking?.travelers?[0].bookingId ?? 0,
                  customerId: booking?.customerId ?? 0,
                  batchId: booking?.batch?.id ?? 0,
                  organizerManner: selectedCategories.contains(
                    'Organizer Manner',
                  ),
                  safetySecurity: selectedCategories.contains(
                    'Safety and Security',
                  ),
                  trekPlanning: selectedCategories.contains('Trek Planning'),
                  womenSafety: selectedCategories.contains('Women Safety'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingCard() {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share your trek experience with Trekking Freaks!',
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s10,
                        fontWeight: FontWeight.w500,
                        color: CommonColors.blackColor,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    AnimatedRatingStars(
                      initialRating: selectedRating,
                      onChanged: (rating) {
                        setState(() {
                          selectedRating = rating;
                          _trekC.rating.value = selectedRating;
                        });
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
              fontSize: FontSize.s9,
              color: CommonColors.greyTextColor2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareWhatYouLovedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share what you loved!',
          style: GoogleFonts.poppins(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w600,
            color: CommonColors.blackColor,
          ),
        ),
        SizedBox(height: 2.h),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2.5.h,
            mainAxisSpacing: 2.5.h,
            childAspectRatio: 2.2,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final categoryName = category['name'] as String;
            final isSelected = selectedCategories.contains(categoryName);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedCategories.remove(categoryName);
                  } else {
                    selectedCategories.add(categoryName);
                  }
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isSelected ? CommonColors.filterGradient : null,
                  color: isSelected ? null : CommonColors.whiteColor,
                  borderRadius: BorderRadius.circular(2.w),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : CommonColors.greyDFDFDF,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      category['icon'],
                      width: 8.5.w,
                      height: 8.5.w,
                      colorFilter: ColorFilter.mode(
                        isSelected
                            ? CommonColors.whiteColor
                            : CommonColors.greyTextColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      category['name'],
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s9,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? CommonColors.whiteColor
                            : CommonColors.greyTextColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewTextArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          height: 18.h,
          decoration: BoxDecoration(
            color: CommonColors.whiteColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: CommonColors.greyDFDFDF, width: 1),
          ),
          child: TextFormField(
            onChanged: (value) {
              setState(() {});
            },
            controller: _trekC.reviewController.value,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: 'Help us improve—write a review!',
              hintStyle: GoogleFonts.poppins(
                fontSize: FontSize.s9,
                color: CommonColors.greyTextColor,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(3.w),
            ),
            style: GoogleFonts.poppins(
              fontSize: FontSize.s9,
              color: CommonColors.blackColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton({
    required int trekId,
    required int customerId,
    required int bookingId,
    required int batchId,

    required bool safetySecurity,
    required bool organizerManner,
    required bool trekPlanning,
    required bool womenSafety,
  }) {


    return CommonButton(
      text: 'Submit Feedback',
      onPressed:
          () {
              _submitFeedback(
                trekId: trekId,
                customerId: customerId,
                bookingId: bookingId,
                batchId: batchId,
                safetySecurity: safetySecurity,
                organizerManner: organizerManner,
                trekPlanning: trekPlanning,
                womenSafety: womenSafety,
              );
            },

      gradient:CommonColors.filterGradient,

      textColor:CommonColors.whiteColor,
      fontSize: FontSize.s11,
      fontWeight: FontWeight.w600,
      borderRadius: 7.w,
      height: 6.h,
    );
  }

  void _submitFeedback({
    required int trekId,
    required int customerId,
    required int bookingId,
    required int batchId,
    required bool safetySecurity,
    required bool organizerManner,
    required bool trekPlanning,
    required bool womenSafety,
  }) {
    _trekC.createReview(
      trekId: trekId,
      customerId: customerId,
      batchId: batchId,
      bookingId: bookingId,
      safetySecurity: safetySecurity,
      organizerManner: organizerManner,
      trekPlanning: trekPlanning,
      womenSafety: womenSafety,
    );
    // _trekC.createReview(bookingId:)
    // print('Rating: $selectedRating');
    // print('Selected Categories: $selectedCategories');
    // print('Review: ${reviewController.text}');
    //
    // Get.snackbar(
    //   'Success',
    //   'Thank you for your ${selectedRating.toString()} star feedback!',
    //   backgroundColor: CommonColors.completedColor2,
    //   colorText: CommonColors.whiteColor,
    //   snackPosition: SnackPosition.TOP,
    // );
    //
    // Get.back();
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }
}
