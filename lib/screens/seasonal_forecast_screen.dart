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
  const SeasonalForecastScreen({Key? key}) : super(key: key);

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
          'Seasonal Forecast',
          style: GoogleFonts.poppins(
            color: CommonColors.blackColor,
            fontSize: FontSize.s11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Obx(() {
        final seasonalForcastLoading = _dashboardC
            .seasonalForcastObserver.value
            .maybeWhen(loading: (data) => true, orElse: () => false);

        List<SeasonalForecastData>? seasonalForecastData = _dashboardC
            .seasonalForcastObserver.value
            .maybeWhen(
          success: (seasonalForcastResponse) {
            return [
              SeasonalForecastData(title:"Puri SUMMER",description: "From Serene trails to thrilling climbs, find treksthat match your vibes !",imagePath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/man%20in%20front%20of%20the%20house%20in%20winter%20forest%20(1).png?alt=media&token=f889af68-4355-4dae-9289-138db1dfb67b", textColour: "#35323b",gradient: ["#F7EB68","#FFEF3E","#FFEF3E"],styling: StylingModel(title: TitleStylingModel(icon:"https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/Winter.png?alt=media&token=e0098e5c-ba45-4af2-8a54-f1eb8d41874f" ,textColour: "#ffffff",gradient: ["#9f88e0","#9e87e1","#7a56e1"]))),
              SeasonalForecastData(title:"Munnar",description: "From Serene trails to thrilling climbs, find treksthat match your vibes !",imagePath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/man%20in%20front%20of%20the%20house%20in%20winter%20forest%20(1).png?alt=media&token=f889af68-4355-4dae-9289-138db1dfb67b",textColour: "#000000",gradient: ["#9f88e0","#9e87e1","#7a56e1"],styling: StylingModel(title: TitleStylingModel(icon: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/Winter.png?alt=media&token=e0098e5c-ba45-4af2-8a54-f1eb8d41874f", textColour: "#35323b",gradient: ["#F7EB68","#FFEF3E","#FFEF3E"]))),
            ];
          return (seasonalForcastResponse as SeasonalForecastDataResponseModel).data;
          },
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
                  gradient: AppTheme.customGradient(cardData?.gradient),
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
