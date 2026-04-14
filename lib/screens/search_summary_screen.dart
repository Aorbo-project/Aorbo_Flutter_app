import 'package:arobo_app/controller/coupon_controller.dart';
import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/models/treaks/treaks_serach_modal.dart';
import 'package:arobo_app/models/trek_model.dart';
import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/common_bottom_nav.dart';
import 'package:arobo_app/utils/common_trek_card.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/statefullwrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:arobo_app/models/discount_card_model.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_discount_card.dart';
import 'package:arobo_app/utils/common_filter_bar.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/coupon_code/coupon_code_model.dart';

class _StickyFilterBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final List<String> activeFilters;
  final Function(String) onFilterRemoved;
  final double screenHeight;

  _StickyFilterBarDelegate({
    required this.child,
    required this.activeFilters,
    required this.onFilterRemoved,
    required this.screenHeight,
  });

  double get _heightOfFilterBarContainer => (screenHeight * 0.04) + 18;

  double get _heightOfActiveFiltersChipBar => 40;

  @override
  double get minExtent => _heightOfFilterBarContainer;

  @override
  double get maxExtent => activeFilters.isEmpty
      ? _heightOfFilterBarContainer
      : _heightOfFilterBarContainer + _heightOfActiveFiltersChipBar;

  @override
  bool shouldRebuild(_StickyFilterBarDelegate oldDelegate) =>
      oldDelegate.activeFilters != activeFilters ||
      oldDelegate.screenHeight != screenHeight;





  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          child,
          if (activeFilters.isNotEmpty)
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(width: 2.w),
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: activeFilters.map((filter) {
                          return Padding(
                            padding: EdgeInsets.only(right: 2.w),
                            child: Chip(
                              label: Text(
                                filter,
                                textAlign: TextAlign.center,
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s10,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                              onDeleted: () => onFilterRemoved(filter),
                              backgroundColor: CommonColors.whiteColor,
                              deleteIconColor: CommonColors.greyColor2,
                              padding: EdgeInsets.symmetric(horizontal: 1.w),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SearchSummaryScreen extends StatefulWidget {
  const SearchSummaryScreen({
    super.key,
  });

  @override
  State<SearchSummaryScreen> createState() => _SearchSummaryScreenState();
}

class _SearchSummaryScreenState extends State<SearchSummaryScreen> {
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final TrekController _trekControllerC = Get.find<TrekController>();
  final CouponController couponController = Get.find<CouponController>();

  int selectedIndex = 0;
  bool isGroupBooking = false;
  final ScrollController _scrollController = ScrollController();
  List<TrekData> filteredTreks = [];
  List<String> activeFilters = [];
  bool _isDiscountCardsUserInteracting = false;
  Timer? _discountCardsTimer;
  final PageController _discountCardsPageController = PageController(
    viewportFraction: 0.75,
    initialPage: discountCards.length * 100,
  );

  final GlobalKey<CommonFilterBarState> _commonFilterBarKey =
      GlobalKey<CommonFilterBarState>();

  @override
  void initState(){
    super.initState();

  }




  @override
  void deactivate() {
    // Cancel timer when widget is deactivated (e.g. during navigation)
    _discountCardsTimer?.cancel();
    super.deactivate();
  }

  DateTime? _parseDate(String? date) {
    if (date == null || date.trim().isEmpty) {
      return null;
    }

    try {
      // dd/MM/yyyy
      if (date.contains('/')) {
        return DateFormat('dd/MM/yyyy').parse(date);
      }
      // yyyy-MM-dd or yyyy-MM-ddTHH:mm:ssZ
      else if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(date)) {
        return DateTime.parse(date);
      }
      // dd MMM yyyy (e.g., 08 Jul 2025)
      else {
        return DateFormat('dd MMM yyyy').parse(date);
      }
    } catch (e) {
      return null;
    }
  }

  void _applyFilters(List<String> filters) {
    setState(() {
      activeFilters = List.from(filters);

      // Start with date-filtered treks from all treks
      filteredTreks = _trekControllerC.trekList.where((trek) {
        // First apply date filter
        DateTime? searchDate =
            _parseDate(_dashboardC.dateController.value.text);
        DateTime? trekDate = _parseDate(trek.batchInfo?.startDate ?? '');
        if (searchDate == null || trekDate == null) return true;
        if (!trekDate.isAtSameMomentAs(searchDate)) return false;

        // Then apply other filters
        bool matchesFilters = true;

        for (String filter in filters) {
          // Handle rating filters
          if (filter == 'High Rated Treks') {
            if ((trek.rating ?? 0) < 4.0) {
              // Assuming 4.0 is the threshold for high rated treks
              matchesFilters = false;
              break;
            }
          } else if (filter.contains('+ Rated')) {
            double requiredRating = double.parse(filter.split('+ ')[0]);
            if ((trek.rating ?? 0) < requiredRating) {
              matchesFilters = false;
              break;
            }
          }

          // Handle duration filters
          // if (filter.contains('D/')) {
          //   // Extract the number of days from trek duration (assuming format like "3 Days")
          //   String trekDurationStr = trek.duration.split(' ')[0];
          //   int trekDays = int.parse(trekDurationStr);
          //
          //   if (filter == 'More') {
          //     if (trekDays <= 6) {
          //       // If trek days is less than or equal to 6, it doesn't match 'More'
          //       matchesFilters = false;
          //       break;
          //     }
          //   } else {
          //     // Extract days from filter (format: "XD/YN")
          //     int filterDays = int.parse(filter.split('D/')[0]);
          //     if (trekDays != filterDays) {
          //       matchesFilters = false;
          //       break;
          //     }
          //   }
          // }

          // Handle offers
          if (filter == 'Special Offers' && !trek.hasDiscount!) {
            matchesFilters = false;
            break;
          }
        }

        return matchesFilters;
      }).toList();

      // Apply sorting if needed
      if (filters.contains('Price - Low to high')) {
        filteredTreks.sort((a, b) {
          double priceA = double.parse(a.price ?? '0.0');
          double priceB = double.parse(b.price ?? '0.0');
          return priceA.compareTo(priceB);
        });
      } else if (filters.contains('Price - High to low')) {
        filteredTreks.sort((a, b) {
          double priceA = double.parse(a.price ?? '0.0');
          double priceB = double.parse(b.price ?? '0.0');
          return priceB.compareTo(priceA);
        });
      }

      // If no filters are active, show all treks for the selected date
      if (filters.isEmpty) {
        filteredTreks = _trekControllerC.trekList.where((trek) {
          DateTime? searchDate =
              _parseDate(_dashboardC.dateController.value.text);
          DateTime? trekDate = _parseDate(trek.batchInfo?.startDate ?? '');
          if (searchDate == null || trekDate == null) return true;
          return trekDate.isAtSameMomentAs(searchDate);
        }).toList();
      }
    });
  }

  void _removeFilter(String filter) {
    if (activeFilters.contains(filter)) {
      setState(() {
        activeFilters.remove(filter);
        _applyFilters(
            List.from(activeFilters)); // Create a new list to trigger update
      });

      // Find and update the CommonFilterBar
      if (_commonFilterBarKey.currentState != null) {
        _commonFilterBarKey.currentState!.updateFilters(activeFilters);
      }
    }
  }

  @override
  void dispose() {
    _discountCardsTimer?.cancel();
    _discountCardsPageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startDiscountCardsAutoScroll() {
    _discountCardsTimer?.cancel();
    _discountCardsTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isDiscountCardsUserInteracting &&
          mounted &&
          discountCards.length > 1) {
        _discountCardsPageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  String getFormattedDate(String dateStr) {
    final parsed = _parseDate(dateStr);
    if (parsed == null) return dateStr;
    final day = DateFormat('d').format(parsed);
    final month = DateFormat('MMM').format(parsed);
    return '$day $month';
  }

  String getFormattedWeekday(String dateStr) {
    final parsed = _parseDate(dateStr);
    if (parsed == null) return '';
    return DateFormat('EEE').format(parsed).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        getFormattedDate(_dashboardC.dateController.value.text);
    final formattedWeekday =
        getFormattedWeekday(_dashboardC.dateController.value.text);
    return StatefulWrapper(
      onInit: ()  async {
         await couponController.fetchAdminCoupons(_dashboardC.selectedTrekId.value);


        _startDiscountCardsAutoScroll();
        // Initial filtering based on date using all treks
        filteredTreks = List.from(_trekControllerC.trekList.where((trek) {
          // Convert both dates to comparable format
          DateTime? searchDate = _parseDate(_dashboardC.dateController.value.text);
          DateTime? trekDate = _parseDate(trek.batchInfo?.startDate ?? '');

          if (searchDate == null || trekDate == null) return true;
          return trekDate.isAtSameMomentAs(searchDate);
        }).toList());

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
        });
      },
      child: Scaffold(
        // bottomNavigationBar: CommonBottomNav(
        //   selectedIndex: selectedIndex,
        //   onIndexChanged: (index) {
        //     setState(() {
        //       selectedIndex = index;
        //     });
        //   },
        //   selectedIconColor: CommonColors.appYellowColor,
        //   unselectedIconColor: Colors.black,
        // ),
        appBar: AppBar(
          backgroundColor: CommonColors.whiteColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: CommonColors.blackColor),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_dashboardC.fromController.value.text.isNotEmpty)
                    Text(
                      _dashboardC.fromController.value.text,
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontSize: FontSize.s11,
                        fontWeight: FontWeight.w400,
                        color: CommonColors.blackColor,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.grey[500],
                      size: 25,
                    ),
                  ),
                  if (_dashboardC.toController.value.text.isNotEmpty)
                    Text(
                      _dashboardC.toController.value.text,
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontSize: FontSize.s11,
                        fontWeight: FontWeight.w400,
                        color: CommonColors.blackColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              if (_dashboardC.dateController.value.text.isNotEmpty)
                Row(
                  children: [
                    Text(
                      formattedDate,
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontSize: FontSize.s9,
                        color: CommonColors.blackColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($formattedWeekday)',
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontSize: FontSize.s9,
                        color: CommonColors.grey_AEAEAE,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        body: SafeArea(
          child: Container(
            color: CommonColors.whiteColor,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Non-sticky content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // 📌 Booking for Groups Section
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: CommonColors.whiteColor,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: CommonColors.shimmerBaseColor,
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.only(left: 15, right: 6),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                CommonImages.group,
                                width: 21,
                                height: 21,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Booking for Groups',
                                  textScaler: const TextScaler.linear(1.0),
                                  style: TextStyle(
                                    fontSize: FontSize.s10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                'View more',
                                textScaler: const TextScaler.linear(1.0),
                                style: TextStyle(
                                  color: CommonColors.blueColor,
                                  fontSize: FontSize.s9,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Transform.scale(
                                scale: 0.8,
                                child: Switch.adaptive(
                                  activeColor: CommonColors.whiteColor,
                                  activeTrackColor: CommonColors.blackColor,
                                  inactiveTrackColor:
                                      CommonColors.shimmerBaseColor,
                                  inactiveThumbColor: CommonColors.blackColor,
                                  value: isGroupBooking,
                                  onChanged: (value) {
                                    setState(() {
                                      isGroupBooking = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 📌 Discount Cards Section
                      SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        controller: _scrollController,
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.18,
                              width: MediaQuery.of(context).size.width,
                              child: Listener(
                                onPointerDown: (_) {
                                  _isDiscountCardsUserInteracting = true;
                                  _discountCardsTimer?.cancel();
                                },
                                onPointerUp: (_) {
                                  _isDiscountCardsUserInteracting = false;
                                  _startDiscountCardsAutoScroll();
                                },
                                onPointerCancel: (_) {
                                  _isDiscountCardsUserInteracting = false;
                                  _startDiscountCardsAutoScroll();
                                },
                                child: Obx(() => couponController.adminCouponsObserver.value.maybeWhen(
                                  loading: (loadingData){
                                    return PageView.builder(
                                      itemCount: 10,
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return Container(
                                          height: 130,
                                          width: 200,
                                          decoration: BoxDecoration(
                                            color: CommonColors.greyColorEBEBEB,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ).withShimmerAi(loading: true);
                                      },
                                    );
                                  },
                                  success: (response) {
                                    final discountCards = (response as CouponCodeModel).data;
                                    return PageView.builder(
                                      controller: _discountCardsPageController,
                                      itemCount: null,
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final discount = discountCards?[index % (discountCards.length ?? 0)];

                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: CommonDiscountCard(
                                            title: discount?.title ?? "",
                                            subtitle: discount?.description ?? "",
                                            color: AppTheme.hexToColor(discount?.color ?? "#3B82F6"),
                                            code: discount?.code ?? "",
                                            offerAmount: discount?.discountValue ?? "",
                                            imagePath: discount?.imagePath ?? '',
                                            imageHeight: 30,
                                            detailedDescription: discount?.description ?? "",
                                            howToApply: "dcc",
                                            termsAndConditions: discount?.termsAndConditions?.join("\n"),
                                            footerNote: "efr",
                                          ),
                                        );
                                      },
                                    );
                                  },
                                    orElse: () => SizedBox()),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // Sticky Filter Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyFilterBarDelegate(
                    activeFilters: activeFilters,
                    onFilterRemoved: _removeFilter,
                    screenHeight: MediaQuery.of(context).size.height,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color:
                                CommonColors.blackColor.withValues(alpha: 0.13),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: SizedBox(
                          height: 4.h,
                          child: CommonFilterBar(
                            key: _commonFilterBarKey,
                            onFiltersChanged: (filters) {
                              _applyFilters(filters);
                              if (_scrollController.hasClients) {
                                _scrollController.jumpTo(0);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Trek List Section
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (filteredTreks.isEmpty) {
                        return Container(
                          margin: const EdgeInsets.only(top: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.hiking,
                                size: 64,
                                color: CommonColors.grey_AEAEAE,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No treks available for ${getFormattedDate(_dashboardC.dateController.value.text)}',
                                textScaler: const TextScaler.linear(1.0),
                                style: TextStyle(
                                  fontSize: FontSize.s11,
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try selecting a different date',
                                textScaler: const TextScaler.linear(1.0),
                                style: TextStyle(
                                  fontSize: FontSize.s9,
                                  color: CommonColors.grey_AEAEAE,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final trek = filteredTreks[index];
                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              top: 24,
                            ),
                            //CommonTrekCard
                            child: CommonTrekCard(
                              trek: trek,
                              onTap: () async {
                                // Set the trek detail ID
                                _trekControllerC.trekDetailId.value =
                                    trek.id ?? 0;

                                // Call the trek detail API
                                await _trekControllerC.trekDetail(batchId: trek.batchInfo?.id??0);

                                // Navigate to trek details screen
                              },
                            ),
                          ),
                          if (index == filteredTreks.length - 1)
                            const SizedBox(height: 34),
                        ],
                      );
                    },
                    childCount: filteredTreks.isEmpty ? 1 : filteredTreks.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
