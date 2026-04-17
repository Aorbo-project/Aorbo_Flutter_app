import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/top_treks_card.dart';
import 'package:arobo_app/models/trek_model.dart';
import 'package:arobo_app/models/top_treks_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../utils/app_theme.dart';

class PopularTreksScreen extends StatefulWidget {
  const PopularTreksScreen({super.key});

  @override
  State<PopularTreksScreen> createState() => _PopularTreksScreenState();
}

class _PopularTreksScreenState extends State<PopularTreksScreen> {
  final ScrollController _scrollController = ScrollController();
  Map<String, bool> _favoriteTreks = {};

  final _dashboardC = Get.find<DashboardController>();

  LinearGradient _getGradientByName(String name) {
    switch (name) {
      case 'gradientYellow':
        return CommonColors.gradientYellow;
      case 'gradientDarkRed':
        return CommonColors.gradientDarkRed;
      case 'gradientTeal':
        return CommonColors.gradientTeal;
      case 'gradientOrange':
        return CommonColors.gradientOrange;
      case 'gradientBlue':
        return CommonColors.gradientBlue;
      case 'gradientGreen':
        return CommonColors.gradientGreen;
      default:
        return CommonColors.gradientYellow;
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize favorite state from topTreksCardsData
    for (var trek in topTreksCardsData) {
      _favoriteTreks[trek['title']] = trek['isFavorite'] ?? false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleFavorite(String trekTitle) {
    setState(() {
      _favoriteTreks[trekTitle] = !(_favoriteTreks[trekTitle] ?? false);

      // Update the topTreksCardsData list
      final trekIndex =
          topTreksCardsData.indexWhere((trek) => trek['title'] == trekTitle);
      if (trekIndex != -1) {
        topTreksCardsData[trekIndex]['isFavorite'] = _favoriteTreks[trekTitle];
      }
    });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: CommonColors.offWhiteColor2,
      appBar: AppBar(
        backgroundColor: CommonColors.whiteColor,
        elevation: 2,
        shadowColor: CommonColors.shadowColor.withValues(alpha: 0.25),
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: CommonColors.blackColor),
        title: Text(
          'Popular Treks',
          textScaler: const TextScaler.linear(1.0),
          style: GoogleFonts.poppins(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w500,
            color: CommonColors.blackColor,
          ),
        ),
      ),
      body: Obx((){
        List<TopTreksData>? topTreksCardsData = _dashboardC.topTreksObserver.value.maybeWhen(success: (topTreksResponse) => (topTreksResponse as TopTreksDataResponseModel).data,error: (sc) => [],orElse: () => [TopTreksData(),TopTreksData(),TopTreksData(),TopTreksData()]);

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          itemCount: topTreksCardsData?.length,
          itemBuilder: (context, index) {
            final trekData = topTreksCardsData?[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 2.h, left: 4.w, right: 4.w),
              child:
              TopTreksCard(
                gradientEndColor: Colors.transparent,
                imagePath: trekData?.imagePath ?? "",
                title: trekData?.title ?? "",
                description: trekData?.description ?? "",
                customGradient: AppTheme.customGradient(trekData?.gradient),
                textColor: CommonColors.blackColor,
                isFavorite: trekData?.isFavorite ?? false,
                onFavoriteTap: () => _toggleFavorite(trekData?.title ?? ""),
                width: 100.w,
                height: 25.h,
              ),

            );
          },
        );
      },
      ),
    );
  }
}
