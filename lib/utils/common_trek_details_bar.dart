import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/utils/arobo_theme.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

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
  final TrekController _trekC = Get.find<TrekController>();

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

  late final List<bool> _tabVisibility;

  @override
  void initState() {
    super.initState();
    _tabVisibility = [
      _trekC.trekDetailData.value.trekStages?.isNotEmpty == true,
      _trekC.trekDetailData.value.itineraryItems?.isNotEmpty == true,
      _trekC.trekDetailData.value.activities?.isNotEmpty == true,
      _trekC.trekDetailData.value.accommodations?.isNotEmpty == true,
      _trekC.trekDetailData.value.inclusions?.isNotEmpty == true,
      _trekC.trekDetailData.value.latestReviews?.isNotEmpty == true,
      _trekC.trekDetailData.value.cancellationPolicy?.rules?.isNotEmpty == true,
      (_trekC.trekDetailData.value.trekkingRules?.isNotEmpty == true) ||
          (_trekC.trekDetailData.value.emergencyProtocols?.isNotEmpty ==
              true) ||
          (_trekC.trekDetailData.value.organizerNotes?.isNotEmpty == true),
    ];
    selectedIndex = widget.initialIndex;
    _tabKeys = List.generate(_tabs.length, (_) => GlobalKey());

    // Scroll to the initial tab after first frame so the bar starts
    // in sync with whatever section is actually at the top.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedTab();
    });
  }

  @override
  void didUpdateWidget(covariant CommonTrekDetailsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the parent's initialIndex changes (e.g. because the user
    // scrolled the main screen and a new section became active),
    // update our highlight and scroll this horizontal bar so the
    // active pill stays visible / centered.
    if (oldWidget.initialIndex != widget.initialIndex &&
        selectedIndex != widget.initialIndex) {
      selectedIndex = widget.initialIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedTab();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scrolls the horizontal tab list so the currently-selected tab
  /// is centred in the viewport. Uses real RenderBox measurements
  /// instead of a fixed-width estimate.
  void _scrollToSelectedTab() {
    if (!_scrollController.hasClients) return;
    if (selectedIndex < 0 || selectedIndex >= _tabKeys.length) return;

    final keyContext = _tabKeys[selectedIndex].currentContext;
    if (keyContext == null) return;

    final renderBox = keyContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return;

    final double tabWidth = renderBox.size.width;
    final double viewportWidth = _scrollController.position.viewportDimension;
    final double currentOffset = _scrollController.offset;

    // Tab's left edge in screen coordinates.
    final double tabScreenLeft = renderBox.localToGlobal(Offset.zero).dx;

    // Find the scroll viewport's left edge in screen coordinates by
    // walking up from the scroll position's context.
    final scrollContext = _scrollController.position.context.storageContext;
    final scrollRenderBox = scrollContext.findRenderObject() as RenderBox?;
    if (scrollRenderBox == null) return;
    final double viewportScreenLeft = scrollRenderBox
        .localToGlobal(Offset.zero)
        .dx;

    // Convert to content-space coordinate.
    final double tabContentLeft =
        currentOffset + (tabScreenLeft - viewportScreenLeft);

    // Target offset that centres the tab.
    final double target = tabContentLeft - (viewportWidth - tabWidth) / 2;

    _scrollController.animateTo(
      target.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AroboTheme.cardBg,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: SizedBox(
        height: 5.5.h,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _tabs.length,
          itemBuilder: (_, index) {
            if (!_tabVisibility[index]) return const SizedBox.shrink();

            final isSelected = selectedIndex == index;

            return GestureDetector(
              key: _tabKeys[index],
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => selectedIndex = index);
                widget.onTabSelected(index);
                _scrollToSelectedTab();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                margin: EdgeInsets.only(
                  left: index == 0 ? 4.w : 2.w,
                  right: 2.w,
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.9.h),
                decoration: BoxDecoration(
                  color: isSelected ? AroboTheme.primary : AroboTheme.elevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AroboTheme.primary : AroboTheme.border,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AroboTheme.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    _tabs[index],
                    textScaler: const TextScaler.linear(1.0),
                    style: AroboTheme.label(
                      size: FontSize.s11,
                      weight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AroboTheme.ink400,
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
