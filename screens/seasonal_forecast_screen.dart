import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:arobo_app/models/seasonal_forecast_data.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/seasonal_forecast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class SeasonalForecastScreen extends StatelessWidget {
  const SeasonalForecastScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      body: ListView.builder(
        padding: EdgeInsets.all(2.h),
        itemCount: seasonalForecastData.length,
        itemBuilder: (context, index) {
          final cardData = seasonalForecastData[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 3.h),
            child: SizedBox(
              height: 23.h, // Match dashboard height
              child: SeasonalForecast(
                title: cardData['title'],
                description: cardData['description'],
                imagePath: cardData['imagePath'],
                gradientColors: cardData['color'],
              ),
            ),
          );
        },
      ),
    );
  }
}
