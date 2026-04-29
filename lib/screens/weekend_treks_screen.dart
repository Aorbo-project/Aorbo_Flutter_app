import 'dart:developer';

import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/screens/trek_details_screen.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/common_trek_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import 'package:sizer/sizer.dart';

import '../freezed_models/treks/treks_model_data.dart';

class WeekendTreksScreen extends StatefulWidget {
  final String city;
  final String trek;
  final String date;
  final List<DateTime> weekendDates;

  const WeekendTreksScreen({
    super.key,
    required this.city,
    required this.trek,
    required this.date,
    required this.weekendDates,
  });

  @override
  State<WeekendTreksScreen> createState() => _WeekendTreksScreenState();
}

class _WeekendTreksScreenState extends State<WeekendTreksScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedDateIndex = 0;
  final TrekController _trekC = Get.find<TrekController>();




  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener(
        onNotification: (ScrollNotification scrollNotification) {
          if (scrollNotification.metrics.pixels >= scrollNotification.metrics.maxScrollExtent - 200) {
            print("Paginatiing");
            // _addData();
          }
          return false;
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              backgroundColor: CommonColors.whiteColor,
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: true,
              expandedHeight: 0,
              collapsedHeight: kToolbarHeight,
              centerTitle: false,
              title: Text(
                'Weekend Treks',
                textScaler: const TextScaler.linear(1.0),
                style: GoogleFonts.poppins(
                  color: CommonColors.blackColor,
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: CommonColors.whiteColor,
                ),
              ),
            ),
            Obx(() {
              final treksLoading = _trekC.weekendTreksResponseObserver.value.data.value.maybeWhen(loading: (data) => true,orElse: () => false);
              List<TrekData>? availableTreks = _trekC.weekendTreksResponseObserver.value.data.value.maybeWhen(success: (treksResponse) => (treksResponse as FetchTreksResponseModel).data,error: (sc) => [],orElse: () => [TrekData(),TrekData(),TrekData(),TrekData()]);
              SearchContextModel? searchContext = _trekC.weekendTreksResponseObserver.value.data.value.maybeWhen(success: (treksResponse) => (treksResponse as FetchTreksResponseModel).searchContext,orElse: () => null);

              final paginating = _trekC.weekendTreksResponseObserver.value.isLoading;

              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      child: Text(
                        'From ${searchContext?.from} to ${searchContext?.to}',
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s10,
                          fontWeight: FontWeight.w500,
                          color: CommonColors.blackColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    // Weekend dates selector
                    Container(
                      height: 7.h,
                      margin: EdgeInsets.symmetric(vertical: 2.h),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        itemCount: searchContext?.weekendDates?.length,
                        itemBuilder: (context, index) {
                          final date = searchContext?.weekendDates?[index];
                          final isSelected = _selectedDateIndex == index;

                          return GestureDetector(
                            onTap: () {
                              // setState(() {
                              //   _selectedDateIndex = index;
                              // });
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 3.w),
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? CommonColors.appBgColor
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? CommonColors.appBgColor
                                      : CommonColors.grey_AEAEAE,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    date ?? "",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : CommonColors.blackColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: FontSize.s10,
                                    ),
                                  ),
                                  Text(
                                    date ?? "",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : CommonColors.grey_AEAEAE,
                                      fontSize: FontSize.s9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Available treks
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      child: Text(
                        'Available Treks',
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(child:
              (availableTreks?.isEmpty == true) ?
                           Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.hiking,
                                  size: 64,
                                  color: CommonColors.grey_AEAEAE,
                                ),
                                Text(
                                  'No treks available for this date',
                                  textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s11,
                                    color: CommonColors.grey_AEAEAE,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ) : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        itemCount: availableTreks?.length,
                        itemBuilder: (context, index) {
                          final trek = availableTreks?[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: CommonTrekCard(
                              trek: trek,
                              onTap: () async {
                                _trekC.trekDetailId.value = trek?.id ?? 0;

                                // Call the trek detail API
                                await _trekC.trekDetail(batchId: trek?.batchInfo?.id ?? 0);

                                Get.to(() => TrekDetailsScreen(trek:trek));
                              },
                            ).withShimmerAi(loading: treksLoading),
                          );
                        }
                        )
                    ),
                    Visibility(
                      visible:paginating,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: CommonTrekCard(
                          trek: null,
                          onTap: ()  {
                          },
                        ).withShimmerAi(loading: true),
                      ),
                    )
                  ],
                ),
              );},
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _addData() async {
    final observer = _trekC.weekendTreksResponseObserver;
    if( observer.value.isPaginationCompleted || observer.value.isLoading ) return;
    _trekC.fetchWeekendTreks(cityId:widget.city, trekId: widget.trek, date: widget.date,refresh: false);
  }

}
