import 'package:arobo_app/controller/trek_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'common_colors.dart';
import 'screen_constants.dart';

class CommonTrekDetailsBar extends StatefulWidget {
  final Function(int) onTabSelected;
  final int initialIndex;

  const CommonTrekDetailsBar({
    super.key,
    required this.onTabSelected,
    this.initialIndex = 0,
  });

  @override
  State<CommonTrekDetailsBar> createState() =>
      _CommonTrekDetailsBarState();
}

class _CommonTrekDetailsBarState
    extends State<CommonTrekDetailsBar> {
  final TrekController _trekC =
      Get.find<TrekController>();

  late int selectedIndex;
  final ScrollController _scrollController = ScrollController();

  final List<String> _tabs = [
    'Trek Route',
    'Itinerary',
    'Activities',
    'Resorts',
    'Features',
    'Reviews',
    'Cancellation',
    'Other Policies',
  ];

  late final List<bool> _tabVisibility = [
    _trekC.trekDetailData.value.trekStages?.isNotEmpty == true,
    _trekC.trekDetailData.value.itineraryItems?.isNotEmpty == true,
    _trekC.trekDetailData.value.activities?.isNotEmpty == true,
    _trekC.trekDetailData.value.accommodations?.isNotEmpty == true,
    _trekC.trekDetailData.value.inclusions?.isNotEmpty == true,
    _trekC.trekDetailData.value.latestReviews?.isNotEmpty == true,
    _trekC.trekDetailData.value.cancellationPolicy?.rules?.isNotEmpty == true,
    (_trekC.trekDetailData.value.trekkingRules?.isNotEmpty == true) ||
        (_trekC.trekDetailData.value.emergencyProtocols?.isNotEmpty == true) ||
        (_trekC.trekDetailData.value.organizerNotes?.isNotEmpty == true),
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  void _scrollToSelectedTab() {
    if (!_scrollController.hasClients) return;

    double offset = selectedIndex * 30.w;

    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: SizedBox(
        height: 5.5.h,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: _tabs.length,
          itemBuilder: (_, index) {
            if (!_tabVisibility[index]) return const SizedBox();

            final isSelected = selectedIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() => selectedIndex = index);
                widget.onTabSelected(index);
                _scrollToSelectedTab();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.only(
                  left: index == 0 ? 4.w : 2.w,
                  right: 2.w,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 0.9.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CommonColors.blueColor
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(3.w),
                ),
                child: Center(
                  child: Text(
                    _tabs[index],
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s10,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}