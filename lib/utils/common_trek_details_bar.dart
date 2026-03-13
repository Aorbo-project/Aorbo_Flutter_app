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
  State<CommonTrekDetailsBar> createState() => _CommonTrekDetailsBarState();
}

class _CommonTrekDetailsBarState extends State<CommonTrekDetailsBar> {
  final TrekController _trekControllerC = Get.find<TrekController>();

  late int selectedIndex;
  final ScrollController _scrollController = ScrollController();
  late final List<GlobalKey> _tabKeys;

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
    _trekControllerC.trekDetailData.value.trekStages != null &&
        _trekControllerC.trekDetailData.value.trekStages!.isNotEmpty,
    _trekControllerC.trekDetailData.value.itineraryItems != null &&
        _trekControllerC.trekDetailData.value.itineraryItems!.isNotEmpty,
    _trekControllerC.trekDetailData.value.activities != null &&
        _trekControllerC.trekDetailData.value.activities!.isNotEmpty,
    _trekControllerC.trekDetailData.value.accommodations != null &&
        _trekControllerC.trekDetailData.value.accommodations!.isNotEmpty,
    _trekControllerC.trekDetailData.value.inclusions != null &&
        _trekControllerC.trekDetailData.value.inclusions!.isNotEmpty,
    _trekControllerC.trekDetailData.value.latestReviews != null &&
        _trekControllerC.trekDetailData.value.latestReviews!.isNotEmpty,
    _trekControllerC.trekDetailData.value.cancellationPolicy != null &&
        _trekControllerC.trekDetailData.value.cancellationPolicy!.rules!.isNotEmpty,
    (_trekControllerC.trekDetailData.value.trekkingRules != null &&
            _trekControllerC.trekDetailData.value.trekkingRules!.isNotEmpty) ||
        (_trekControllerC.trekDetailData.value.emergencyProtocols != null &&
            _trekControllerC
                .trekDetailData.value.emergencyProtocols!.isNotEmpty) ||
        (_trekControllerC.trekDetailData.value.organizerNotes != null &&
            _trekControllerC.trekDetailData.value.organizerNotes!.isNotEmpty)
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    _tabKeys = List.generate(_tabs.length, (_) => GlobalKey());
    // _tabVisibility = List.filled(_tabs.length, true); // Default: all visible
  }

  @override
  void didUpdateWidget(CommonTrekDetailsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != selectedIndex) {
      setState(() {
        selectedIndex = widget.initialIndex;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedTab();
      });
    }
  }

  void _scrollToSelectedTab() {
    if (!_scrollController.hasClients) return;
    if (selectedIndex >= _tabs.length) return;

    double tabWidth = 25.w;
    double targetOffset = selectedIndex * tabWidth;

    double scrollViewWidth = _scrollController.position.viewportDimension;
    double centeredOffset =
        targetOffset - (scrollViewWidth / 2) + (tabWidth / 2);

    double clampedOffset =
        centeredOffset.clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(
          _tabs.length,
          (index) => Visibility(
            visible: _tabVisibility[index],
            child: Container(
              key: _tabKeys[index],
              padding: EdgeInsets.only(
                left: index == 0 ? 5.w : 0,
                right: index != _tabs.length - 1 ? 8.w : 5.w,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                  widget.onTabSelected(index);
                  _scrollToSelectedTab();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _tabs[index],
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontSize: FontSize.s10,
                        fontWeight: FontWeight.w500,
                        color: selectedIndex == index
                            ? CommonColors.blueColor
                            : CommonColors.blackColor,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: selectedIndex == index ? 10.w : 0,
                      height: 0.3.h,
                      decoration: BoxDecoration(
                        color: CommonColors.blueColor,
                        borderRadius: BorderRadius.circular(0.5.h),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
