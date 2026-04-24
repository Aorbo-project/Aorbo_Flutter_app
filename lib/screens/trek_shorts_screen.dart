import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arobo_app/models/shorts_treks_data.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

class TrekShortsScreen extends StatelessWidget {
  const TrekShortsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _dashboardC = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: CommonColors.offWhiteColor2,
      appBar: AppBar(
        backgroundColor: CommonColors.whiteColor,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: CommonColors.blackColor),
        title: Text(
          'Trek Shorts',
          style: GoogleFonts.poppins(
            color: CommonColors.blackColor,
            fontSize: FontSize.s11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Obx(() {
        final shortsLoading = _dashboardC.shortsTreksObserver.value
            .maybeWhen(loading: (data) => true, orElse: () => false);
        List<ShortsTreksData>? shortsTreksCardsData = _dashboardC
            .shortsTreksObserver.value
            .maybeWhen(
          success: (shortsTreksResponse) =>
          (shortsTreksResponse as ShortsTreksDataResponseModel)
              .data,
          error: (sc) => [],
          orElse: () => [
            ShortsTreksData(),
            ShortsTreksData(),
            ShortsTreksData(),
            ShortsTreksData()
          ],
        );
        if (shortsTreksCardsData?.isEmpty == true) return SizedBox();
         return Padding(
          padding: EdgeInsets.all(2.h),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 0.7,
            ),
            itemCount: shortsTreksCardsData?.length,
            itemBuilder: (context, index) {
              final cardData = shortsTreksCardsData?[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.5.h),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.5.h),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image
                      CustomNetworkImage(
                        imageUrl: cardData?.imagePath ?? "",
                        fit: BoxFit.cover,
                      ),
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                            stops: [0.5, 1.0],
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: EdgeInsets.all(1.5.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cardData?.description ??
                                  'Lorem ipsum | Sit amet | consectetur adipiscing elit..',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 6.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              '${cardData?.title ?? '4M'}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 6.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );},
      ),
    );
  }
}
