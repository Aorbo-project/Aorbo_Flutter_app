import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:arobo_app/models/seasonal_forecast_data.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/seasonal_forecast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

import '../utils/app_theme.dart';

class SeasonalForecastScreen extends StatelessWidget {
  const SeasonalForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardC = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: CommonColors.offWhiteColor2,
      appBar: AppBar(
        backgroundColor: CommonColors.whiteColor,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: CommonColors.blackColor),
        title: Text(
          'Seasonal Forecast',
          style: GoogleFonts.poppins(
            color: CommonColors.blackColor,
            fontSize: FontSize.s11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Obx(() {
        final seasonalForcastLoading = dashboardC
            .seasonalForcastObserver.value
            .maybeWhen(loading: (data) => true, orElse: () => false);

        List<SeasonalForecastData>? seasonalForecastData = dashboardC
            .seasonalForcastObserver.value
            .maybeWhen(
          success: (seasonalForcastResponse) =>
              (seasonalForcastResponse as SeasonalForecastDataResponseModel).data,
          error: (sc) => [],
          orElse: () => [
            SeasonalForecastData(),
            SeasonalForecastData(),
            SeasonalForecastData(),
            SeasonalForecastData()
          ],
        );

        if (seasonalForecastData?.isEmpty == true) return SizedBox();
         return ListView.builder(
          padding: EdgeInsets.all(2.h),
          itemCount: seasonalForecastData?.length,
          itemBuilder: (context, index) {
            final cardData = seasonalForecastData?[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 3.h),
              child: SizedBox(
                height: 23.h, // Match dashboard height
                child: SeasonalForecast(
                  title: cardData?.title ?? "",
                  description: cardData?.description ?? "",
                  imagePath: cardData?.imagePath ?? "",
                  textColour:AppTheme.hexToColor(cardData?.textColour),
                  gradient:AppTheme.customGradient(
  (cardData?.gradient ?? [])
      .map((e) => e.toString())
      .toList(),
),
                  titleStylingModel: cardData?.styling?.title,
                ).withShimmerAi(loading: seasonalForcastLoading),
              ),
            );
          },
        );},
      ),
    );
  }
}
