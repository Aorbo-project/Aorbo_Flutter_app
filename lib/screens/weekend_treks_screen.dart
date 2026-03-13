import 'dart:developer';

import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/models/treaks/treaks_serach_modal.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/common_trek_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

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
  final TrekController _trekControllerC = Get.find<TrekController>();

  List<TrekData> _getAvailableTreks(DateTime date) {
    return _trekControllerC.trekList.where((trek) {
      final startDateStr = trek.batchInfo?.startDate;
      if (startDateStr == null || startDateStr.isEmpty) {
        return false;
      }

      try {
        final trekDate = DateFormat('yyyy-MM-dd').parseStrict(startDateStr);
        return trekDate.year == date.year &&
            trekDate.month == date.month &&
            trekDate.day == date.day;
      } catch (e) {
        log('erorr ${e.toString()}');
        // If parsing fails, exclude this trek
        return false;
      }
    }).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
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
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Text(
                    'From ${widget.city} to ${widget.trek}',
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
                    itemCount: widget.weekendDates.length,
                    itemBuilder: (context, index) {
                      final date = widget.weekendDates[index];
                      final isSelected = _selectedDateIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDateIndex = index;
                          });
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
                                DateFormat('EEE').format(date),
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
                                DateFormat('MMM d').format(date),
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
                // Trek cards
                Builder(
                  builder: (context) {
                    final availableTreks = _getAvailableTreks(
                        widget.weekendDates[_selectedDateIndex]);

                    if (availableTreks.isEmpty) {
                      return Center(
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
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      itemCount: availableTreks.length,
                      itemBuilder: (context, index) {
                        final trek = availableTreks[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: CommonTrekCard(
                            trek: trek,
                            onTap: () {
                              Get.toNamed(
                                '/trek-details',
                                arguments: {
                                  'trek': trek,
                                  'fromLocation': widget.city,
                                  'toLocation': widget.trek,
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
