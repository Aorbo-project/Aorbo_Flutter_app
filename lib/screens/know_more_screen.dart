import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/know_more_card.dart';
import 'package:arobo_app/models/know_more_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

import '../utils/app_theme.dart';

class KnowMoreScreen extends StatefulWidget {
  const KnowMoreScreen({super.key});

  @override
  State<KnowMoreScreen> createState() => _KnowMoreScreenState();
}

class _KnowMoreScreenState extends State<KnowMoreScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final _dashboardC  = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: CommonColors.offWhiteColor2,
      appBar: AppBar(
        backgroundColor: CommonColors.whiteColor,
        elevation: 2,
        shadowColor: CommonColors.shadowColor.withValues(alpha: 0.25),
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: CommonColors.blackColor),
        title: Text(
          "What's New",
          textScaler: const TextScaler.linear(1.0),
          style: GoogleFonts.poppins(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w500,
            color: CommonColors.blackColor,
          ),
        ),
      ),
      body: Obx(() {
        List<KnowMoreData>? knowMoreCardsData = _dashboardC.whatsNewObserver.value.maybeWhen(success: (whatsNewResponse) => (whatsNewResponse as WhatsNewDataResponseModel).data,error: (sc) => [],orElse: () => [KnowMoreData(),KnowMoreData(),KnowMoreData(),KnowMoreData()]);

         return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          itemCount: knowMoreCardsData?.length,
          itemBuilder: (context, index) {
            final cardData = knowMoreCardsData?[index];
            return Container(
              margin: EdgeInsets.only(
                left: 4.w,
                // right: 8.w,
                bottom: 2.h,
              ),
              height: 22.h,
              child: KnowMoreCard(
                customGradient: AppTheme.customGradient(cardData?.customGradient ?? []),
                imagePath: cardData?.imagePath ?? "",
                title: cardData?.title ?? "",
                subtitle: cardData?.subtitle ?? "",
                onKnowMoreTap: cardData?.hasKnowMore == false
                    ? null
                    : () {
                  Get.toNamed(
                    '/know-more-details',
                    arguments: {
                      'knowMoreData': cardData,
                    },
                  );
                },
                // width: MediaQuery.of(context).size.width * 0.8,
                // height: MediaQuery.of(context).size.height * 0.20,
                textColor: AppTheme.hexToColor(cardData?.textColor),
              ),
            );
          },
        );
         },
      ),
    );
  }
}
