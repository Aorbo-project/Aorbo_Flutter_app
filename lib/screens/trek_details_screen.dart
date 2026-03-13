import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/models/treaks/treak_detail_modal.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:animated_rating_stars/animated_rating_stars.dart';
import '../utils/common_colors.dart';
import '../utils/common_images.dart';
import '../utils/common_trek_card.dart';
import '../utils/common_images_card.dart';
import '../utils/common_trek_details_bar.dart';
import '../utils/common_btn.dart';
import '../utils/screen_constants.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class _StickyTrekDetailsBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTrekDetailsBarDelegate({required this.child});

  @override
  double get minExtent => 6.5.h;

  @override
  double get maxExtent => 6.5.h;

  @override
  bool shouldRebuild(_StickyTrekDetailsBarDelegate oldDelegate) => true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }
}

class TrekDetailsScreen extends StatefulWidget {
  // final Trek trek;
  // final String fromLocation;
  // final String toLocation;

  const TrekDetailsScreen({
    super.key,
    // required this.trek,
    // required this.fromLocation,
    // required this.toLocation,
  });

  @override
  State<TrekDetailsScreen> createState() => _TrekDetailsScreenState();
}

class _TrekDetailsScreenState extends State<TrekDetailsScreen> {
  final TrekController _trekControllerC = Get.find<TrekController>();
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final UserController _userC = Get.find<UserController>();

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(8, (index) => GlobalKey());
  int _selectedTabIndex = 0;
  bool _showFullItinerary = false;
  bool _showFullFeatures = false;
  bool _showFullActivities = false;
  bool _showFullOtherPolicies = false;
  bool _showFullReviews = false;
  String _selectedSortOption = 'Recent Reviews';

  List<LatestReviews> _sortedReviews = [];
  bool _isUserScrolling = false;

  LinearGradient getRatingColor(double rating) {
    if (rating >= 3.0 && rating <= 3.8) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFA5F), Color(0xFFFFFA5F)],
      );
    } else if (rating < 3.0) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF6B3A), Color(0xFFFF6B3A)],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF19FA00), Color(0xFF4EE53D)],
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_onScroll);
    });
    // _trekControllerC.trekDetail();
    _sortedReviews = _trekControllerC.trekDetailData.value.latestReviews ?? [];
    // _sortReviews(_selectedSortOption);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isUserScrolling) return;

    final ScrollPosition position = _scrollController.position;
    final double viewportHeight = position.viewportDimension;

    int mostVisibleSection = _selectedTabIndex;
    double maxVisibility = 0;

    final double topBuffer = 18.h;

    for (int i = 0; i < _sectionKeys.length; i++) {
      final key = _sectionKeys[i];
      if (key.currentContext == null) continue;

      final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
      final Offset position = box.localToGlobal(Offset.zero);

      final double sectionTop = position.dy - topBuffer;
      final double sectionHeight = box.size.height;
      final double sectionBottom = sectionTop + sectionHeight;

      final double visibleTop = math.max(0, sectionTop);
      final double visibleBottom = math.min(viewportHeight, sectionBottom);
      double visibleHeight = visibleBottom - visibleTop;

      if (sectionTop < viewportHeight * 0.5) {
        visibleHeight *= 1.5;
      }

      if (visibleHeight > maxVisibility) {
        maxVisibility = visibleHeight;
        mostVisibleSection = i;
      }
    }

    if (mostVisibleSection != _selectedTabIndex) {
      setState(() {
        _selectedTabIndex = mostVisibleSection;
      });
    }
  }

  void _scrollToSection(int index) {
    if (index >= _sectionKeys.length) return;

    _isUserScrolling = true;

    setState(() {
      _selectedTabIndex = index;
    });

    // Use a more direct approach - scroll to approximate position first
    _scrollToSectionWithRendering(index);
  }

  void _scrollToSectionWithRendering(int index) {
    // Calculate approximate positions based on section index
    // These are rough estimates based on typical section heights
    final List<double> sectionOffsets = [
      0, // Trek Route
      45.h, // Itinerary
      90.h, // Activities
      135.h, // Resorts
      180.h, // Features
      225.h, // Reviews
      270.h, // Cancellation
      315.h, // Other Policies
    ];

    double targetOffset = index < sectionOffsets.length
        ? sectionOffsets[index]
        : index * 45.h; // Fallback calculation

    // First scroll to approximate position to ensure content is rendered
    _scrollController
        .animateTo(
          targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        )
        .then((_) {
          // Wait a bit for content to render, then try precise positioning
          Future.delayed(const Duration(milliseconds: 200), () {
            _attemptPreciseScrollToSection(index, 0);
          });
        });
  }

  void _attemptPreciseScrollToSection(int index, int attempts) {
    if (attempts >= 3) {
      _isUserScrolling = false;
      return;
    }

    final key = _sectionKeys[index];
    if (key.currentContext != null) {
      try {
        final RenderBox box =
            key.currentContext!.findRenderObject() as RenderBox;
        final Offset position = box.localToGlobal(Offset.zero);
        final double targetOffset =
            _scrollController.offset + position.dy - 18.h;

        _scrollController
            .animateTo(
              targetOffset.clamp(
                0.0,
                _scrollController.position.maxScrollExtent,
              ),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            )
            .then((_) {
              _isUserScrolling = false;
            });
      } catch (e) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _attemptPreciseScrollToSection(index, attempts + 1);
        });
      }
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        _attemptPreciseScrollToSection(index, attempts + 1);
      });
    }
  }

  // void _sortReviews(String sortOption) {
  //   setState(() {
  //     _selectedSortOption = sortOption;
  //     _sortedReviews =  _trekControllerC.trekDetailData.value.reviews ?? [];
  //
  //     switch (sortOption) {
  //       case 'Recent Reviews':
  //         _sortedReviews.sort((a, b) {
  //           DateTime dateA = DateFormat('dd/MM/yyyy').parse(a.date);
  //           DateTime dateB = DateFormat('dd/MM/yyyy').parse(b.date);
  //           return dateB.compareTo(dateA);
  //         });
  //         break;
  //       case 'Solo Traveller':
  //         // Assuming we want to show solo traveller reviews first
  //         // You might want to add a 'type' field to Review model to properly implement this
  //         break;
  //       case 'High to Low Ratings':
  //         _sortedReviews.sort((a, b) => b.rating.compareTo(a.rating));
  //         break;
  //       case 'Low to High Ratings':
  //         _sortedReviews.sort((a, b) => a.rating.compareTo(b.rating));
  //         break;
  //       case 'Organizer Manner':
  //         // Add organizer manner specific sorting if needed
  //         break;
  //     }
  //   });
  // }

  String _formatReviewDate(String date) {
    final DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(date);
    return DateFormat('dd MMM yyyy').format(parsedDate);
  }

  IconData _getIconForPolicy(String iconName) {
    switch (iconName) {
      case 'no_drinks':
        return Icons.no_drinks;
      case 'schedule':
        return Icons.schedule;
      case 'cancel_schedule_send':
        return Icons.cancel_schedule_send;
      case 'attach_money':
        return Icons.attach_money;
      case 'phone_in_talk':
        return Icons.phone_in_talk;
      case 'person_pin_circle':
        return Icons.person_pin_circle;
      default:
        return Icons.info_outline; // Default icon if not found
    }
  }

  Widget _buildCustomStarRating({
    required double rating,
    required double starSize,
    int maxStars = 5,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        double starValue = rating - index;
        Widget starIcon;

        if (starValue >= 1.0) {
          // Full star
          starIcon = Icon(
            Icons.star,
            size: starSize,
            color: CommonColors.completedColor2,
          );
        } else if (starValue >= 0.5) {
          // Half star
          starIcon = Icon(
            Icons.star_half,
            size: starSize,
            color: CommonColors.completedColor2,
          );
        } else {
          // Empty star
          starIcon = Icon(
            Icons.star_border,
            size: starSize,
            color: Colors.grey.shade300,
          );
        }

        return Padding(
          padding: EdgeInsets.only(right: index < maxStars - 1 ? 2.w : 0),
          child: starIcon,
        );
      }),
    );
  }

  void _showImageViewer(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 100.h,
        decoration: BoxDecoration(color: Colors.transparent),
        child: Stack(
          children: [
            // PageView for images
            PageView.builder(
              itemCount: images.length,
              controller: PageController(initialPage: initialIndex),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: CachedNetworkImage(
                        imageUrl:
                            '${NetworkUrl.imageUrl}${images[index].startsWith('/') ? images[index].substring(1) : images[index]}',
                        fit: BoxFit.contain,
                        width: 100.w,
                        height: 100.h,
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Close button
            Positioned(
              top: 5.h,
              right: 5.w,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: CommonColors.whiteColor,
                  size: 3.h,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Text(
              _trekControllerC.trekDetailData.value.title ?? '--',
              textScaler: const TextScaler.linear(1.0),
              style: GoogleFonts.poppins(
                fontSize: FontSize.s12,
                fontWeight: FontWeight.w500,
                color: CommonColors.blackColor,
              ),
            ),
            Row(
              children: [
                Text(
                  _dashboardC.fromController.value.text,
                  textScaler: const TextScaler.linear(1.0),
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s9,
                    fontWeight: FontWeight.w400,
                    color: CommonColors.blackColor,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.5.w),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.grey[400],
                    size: 4.w,
                  ),
                ),
                Text(
                  _dashboardC.toController.value.text,
                  textScaler: const TextScaler.linear(1.0),
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s9,
                    fontWeight: FontWeight.w400,
                    color: CommonColors.blackColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 10.w,
          right: 10.w,
          top: 2.h,
          bottom: 2.5.h,
        ),
        child: CommonButton(
          text: 'Continue',
          onPressed: () async {
            await _userC.getUserProfile();
            _trekControllerC.trekBatchId.value =
                _trekControllerC.trekDetailData.value.batchInfo?.id ?? 0;
            Get.toNamed('/traveller-info');
          },
          gradient: CommonColors.filterGradient,
          textColor: CommonColors.whiteColor,
          height: 6.h,
          isFullWidth: false,
          width: 50.w,
          fontSize: FontSize.s14,
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Card(
              elevation: 4,
              shadowColor: CommonColors.shadowColor.withValues(alpha: 0.25),
              color: CommonColors.offWhiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(2.5.w),
                  bottomRight: Radius.circular(2.5.w),
                ),
              ),
              child: Container(
                width: 100.w,
                margin: EdgeInsets.only(top: 2.h, bottom: 1.2.h),
                child: CommonTrekCard(
                  trek:
                      _trekControllerC.trekList[_trekControllerC.trekList
                          .indexWhere((p0) {
                            return p0.id == _trekControllerC.trekDetailId.value;
                          })],
                  showShare: true,
                ),
              ),
            ),
          ),
          if (_trekControllerC.trekDetailData.value.images != null &&
              _trekControllerC.trekDetailData.value.images!.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                width: 100.w,
                margin: EdgeInsets.only(top: 2.5.h, left: 4.w, bottom: 2.5.h),
                child: GestureDetector(
                  onTap: () => _showImageViewer(
                    context,
                    _trekControllerC.trekDetailData.value.images
                            ?.map((e) => e.url ?? '')
                            .toList() ??
                        [],
                    0,
                  ),
                  child: CommonImageCard(
                    images:
                        _trekControllerC.trekDetailData.value.images
                            ?.map((e) => e.url ?? '')
                            .toList() ??
                        [],
                  ),
                ),
              ),
            ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTrekDetailsBarDelegate(
              child: Container(
                width: 100.w,
                decoration: BoxDecoration(color: CommonColors.offWhiteColor3),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Center(
                    child: CommonTrekDetailsBar(
                      onTabSelected: _scrollToSection,
                      initialIndex: _selectedTabIndex,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 1.h),
              Visibility(
                visible:
                    _trekControllerC.trekDetailData.value.trekStages != null &&
                    _trekControllerC
                        .trekDetailData
                        .value
                        .trekStages!
                        .isNotEmpty,
                child: Container(
                  key: _sectionKeys[0],
                  child: TrekRouteTab(
                    trek: _trekControllerC.trekDetailData.value,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Visibility(
                visible:
                    _trekControllerC.trekDetailData.value.itineraryItems !=
                        null &&
                    _trekControllerC
                        .trekDetailData
                        .value
                        .itineraryItems!
                        .isNotEmpty,
                child: Container(
                  key: _sectionKeys[1],
                  child: _buildItineraryTab(),
                ),
              ),
              SizedBox(height: 1.h),
              Visibility(
                visible:
                    _trekControllerC.trekDetailData.value.activities != null &&
                    _trekControllerC
                        .trekDetailData
                        .value
                        .activities!
                        .isNotEmpty,
                child: Container(
                  key: _sectionKeys[2],
                  child: _buildActivitiesTab(),
                ),
              ),
              SizedBox(height: 1.h),
              Visibility(
                visible:
                    _trekControllerC.trekDetailData.value.accommodations !=
                        null &&
                    _trekControllerC
                        .trekDetailData
                        .value
                        .accommodations!
                        .isNotEmpty,
                child: Container(
                  key: _sectionKeys[3],
                  child: _buildResortsTab(),
                ),
              ),
              SizedBox(height: 1.h),
              Visibility(
                visible:
                    _trekControllerC.trekDetailData.value.inclusions != null &&
                    _trekControllerC
                        .trekDetailData
                        .value
                        .inclusions!
                        .isNotEmpty,
                child: Container(
                  key: _sectionKeys[4],
                  child: _buildFeaturesTab(),
                ),
              ),
              SizedBox(height: 1.h),
              Visibility(
                visible:
                    _trekControllerC.trekDetailData.value.latestReviews !=
                        null &&
                    _trekControllerC
                        .trekDetailData
                        .value
                        .latestReviews!
                        .isNotEmpty,
                child: Container(
                  key: _sectionKeys[5],
                  child: _buildReviewsTab(),
                ),
              ),
              SizedBox(height: 1.h),
              Visibility(
                visible:
                    _trekControllerC.trekDetailData.value.cancellationPolicy !=
                        null &&
                    _trekControllerC
                        .trekDetailData
                        .value
                        .cancellationPolicy!
                        .rules!
                        .isNotEmpty,
                child: Container(
                  key: _sectionKeys[6],
                  child: _buildCancellationPoliciesTab(),
                ),
              ),
              SizedBox(height: 1.h),
              Visibility(
                visible:
                    (_trekControllerC.trekDetailData.value.trekkingRules !=
                            null &&
                        _trekControllerC
                            .trekDetailData
                            .value
                            .trekkingRules!
                            .isNotEmpty) ||
                    (_trekControllerC.trekDetailData.value.emergencyProtocols !=
                            null &&
                        _trekControllerC
                            .trekDetailData
                            .value
                            .emergencyProtocols!
                            .isNotEmpty) ||
                    (_trekControllerC.trekDetailData.value.organizerNotes !=
                            null &&
                        _trekControllerC
                            .trekDetailData
                            .value
                            .organizerNotes!
                            .isNotEmpty),
                child: Container(
                  key: _sectionKeys[7],
                  child: _buildOtherPoliciesTab(),
                ),
              ),
              SizedBox(height: 2.5.h),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesTab() {
    final displayedInclusions = _showFullFeatures
        ? _trekControllerC.trekDetailData.value.inclusions
        : _trekControllerC.trekDetailData.value.inclusions?.take(4).toList();

    final displayedExclusions = _showFullFeatures
        ? _trekControllerC.trekDetailData.value.exclusions
        : _trekControllerC.trekDetailData.value.exclusions?.take(4).toList();

    return Container(
      width: 95.w,
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(3.8.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 2.w,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        width: 85.w,
        margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.2.h, bottom: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // if (displayedInclusions != null && displayedInclusions.isNotEmpty)
            //   Container(
            //     margin: EdgeInsets.only(top: 2.4.h),
            //     child: Column(
            //       children: displayedInclusions
            //           .map((inclusion) => Padding(
            //                 padding: EdgeInsets.only(bottom: 1.5.h),
            //                 child: Row(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Container(
            //                       margin: EdgeInsets.only(top: 1.h),
            //                       width: 1.w,
            //                       height: 1.w,
            //                       decoration: BoxDecoration(
            //                         shape: BoxShape.circle,
            //                         color: CommonColors.blackColor,
            //                       ),
            //                     ),
            //                     SizedBox(width: 3.w),
            //                     Expanded(
            //                       child: Text(
            //                         inclusion,
            //                         textScaler: const TextScaler.linear(1.0),
            //                         style: GoogleFonts.poppins(
            //                           fontSize: FontSize.s10,
            //                           color: CommonColors.blackColor,
            //                           height: 1.5,
            //                         ),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ))
            //           .toList(),
            //     ),
            //   ),
            Text(
              'Inclusions',
              textScaler: const TextScaler.linear(1.0),
              style: GoogleFonts.poppins(
                fontSize: FontSize.s15,
                fontWeight: FontWeight.w600,
                color: CommonColors.trek_route_color,
              ),
            ),
            if (displayedInclusions != null && displayedInclusions.isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 2.4.h),
                child: Column(
                  children: displayedInclusions
                      .map(
                        (inclusion) => Padding(
                          padding: EdgeInsets.only(bottom: 1.5.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 1.h),
                                width: 1.w,
                                height: 1.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  inclusion.name ?? '-',
                                  textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s10,
                                    color: CommonColors.blackColor,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            if (displayedExclusions != null && displayedExclusions.isNotEmpty)
              SizedBox(height: 3.h),
            if (displayedExclusions != null && displayedExclusions.isNotEmpty)
              Text(
                'Exclusions',
                textScaler: const TextScaler.linear(1.0),
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s15,
                  fontWeight: FontWeight.w600,
                  color: CommonColors.trek_route_color,
                ),
              ),
            if (_trekControllerC.trekDetailData.value.exclusions != null)
              Container(
                margin: EdgeInsets.only(top: 2.4.h),
                child: Column(
                  children: displayedExclusions!
                      .map(
                        (exclusion) => Padding(
                          padding: EdgeInsets.only(bottom: 1.5.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 1.h),
                                width: 1.w,
                                height: 1.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  exclusion,
                                  textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s10,
                                    color: CommonColors.blackColor,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            if ((_trekControllerC.trekDetailData.value.inclusions?.length ??
                        0) >
                    4 ||
                (_trekControllerC.trekDetailData.value.exclusions?.length ??
                        0) >
                    4)
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showFullFeatures = !_showFullFeatures;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _showFullFeatures
                            ? 'Hide Features'
                            : 'View all Features',
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s10,
                          fontWeight: FontWeight.w600,
                          color: CommonColors.trek_route_color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _showFullFeatures
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: CommonColors.trek_route_color,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationPoliciesTab() {
    if (_trekControllerC.trekDetailData.value.cancellationPolicy != null &&
        _trekControllerC
            .trekDetailData
            .value
            .cancellationPolicy!
            .rules!
            .isNotEmpty) {
      return Container(
        width: 95.w,
        decoration: BoxDecoration(
          color: CommonColors.whiteColor,
          borderRadius: BorderRadius.circular(3.8.w),
          boxShadow: [
            BoxShadow(
              color: CommonColors.blackColor.withValues(alpha: 0.1),
              spreadRadius: 0,
              blurRadius: 2.w,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          width: 85.w,
          margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h, bottom: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cancellation Policy',
                textScaler: const TextScaler.linear(1.0),
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s17,
                  fontWeight: FontWeight.w600,
                  color: CommonColors.trek_route_color,
                ),
              ),
              const SizedBox(height: 25),

              // Headers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Before departure',
                    textScaler: const TextScaler.linear(1.0),
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s10,
                      fontWeight: FontWeight.w600,
                      color: CommonColors.blackColor,
                    ),
                  ),
                  Text(
                    'Deduction',
                    textScaler: const TextScaler.linear(1.0),
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s10,
                      fontWeight: FontWeight.w600,
                      color: CommonColors.blackColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 21),

              // Caifncellation time windows
              ListView.builder(
                shrinkWrap: true,
                itemCount: _trekControllerC
                    .trekDetailData
                    .value
                    .cancellationPolicy
                    ?.rules
                    ?.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _trekControllerC
                                    .trekDetailData
                                    .value
                                    .cancellationPolicy
                                    ?.rules?[index]
                                    .rule ??
                                '-',
                            textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s9,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.greyTextColor,
                            ),
                          ),
                        ),
                        Text(
                          '${_trekControllerC.trekDetailData.value.cancellationPolicy?.rules?[index].deductionType == 'fixed' ? '₹' : ''}${_trekControllerC.trekDetailData.value.cancellationPolicy?.rules?[index].deduction}${_trekControllerC.trekDetailData.value.cancellationPolicy?.rules?[index].deductionType == 'percentage' ? '%' : ''}',
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s9,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.greyTextColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),

              // Notes section
              // ..._trekControllerC.trekDetailData.value.cancellationPolicies!
              //     .map((note) =>
              //     .toList(),
              // if (_trekControllerC.trekDetailData.value.cancellationPolicies !=
              //         null &&
              //     _trekControllerC
              //         .trekDetailData.value.cancellationPolicies!.isNotEmpty)
              ListView.builder(
                itemCount: _trekControllerC
                    .trekDetailData
                    .value
                    .cancellationPolicy!
                    .descriptionPoints!
                    .length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.star,
                            size: 10,
                            color: CommonColors.blackColor.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            _trekControllerC
                                    .trekDetailData
                                    .value
                                    .cancellationPolicy!
                                    .descriptionPoints?[index]
                                    .toString() ??
                                '-',
                            textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s7,
                              fontWeight: FontWeight.w400,
                              color: CommonColors.blackColor.withValues(
                                alpha: 0.7,
                              ),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  Widget _buildOtherPoliciesTab() {
    final rules = _trekControllerC.trekDetailData.value.trekkingRules;
    final emergency = _trekControllerC.trekDetailData.value.emergencyProtocols;
    final notes = _trekControllerC.trekDetailData.value.organizerNotes;

    if ((rules == null || rules.isEmpty) &&
        (emergency == null || emergency.isEmpty) &&
        (notes == null || notes.isEmpty)) {
      return Container();
    }

    return Container(
      width: 95.w,
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(3.8.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withAlpha(25),
            spreadRadius: 0,
            blurRadius: 2.w,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        width: 85.w,
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Other Policies',
              style: GoogleFonts.poppins(
                fontSize: FontSize.s17,
                fontWeight: FontWeight.w600,
                color: CommonColors.trek_route_color,
              ),
            ),
            const SizedBox(height: 25),
            if (rules != null && rules.isNotEmpty)
              _buildPolicyBlock('Trekking Rules', rules),
            if (emergency != null && emergency.isNotEmpty)
              _buildPolicyBlock('Emergency Protocols', emergency),
            if (notes != null && notes.isNotEmpty)
              _buildPolicyBlock('Organizer Notes', notes),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyBlock(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIconForPolicy(title),
                size: 25,
                color: CommonColors.blackColor,
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w500,
                  color: CommonColors.blackColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: FontSize.s8,
                fontWeight: FontWeight.w400,
                color: CommonColors.blackColor.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryTab() {
    final itineraryItems = _trekControllerC.trekDetailData.value.itineraryItems;

    if (itineraryItems != null && itineraryItems.isNotEmpty) {
      return Container(
        width: 95.w,
        decoration: BoxDecoration(
          color: CommonColors.whiteColor,
          borderRadius: BorderRadius.circular(3.8.w),
          boxShadow: [
            BoxShadow(
              color: CommonColors.blackColor.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 2.w,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          width: 85.w,
          margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h, bottom: 1.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Itinerary',
                textScaler: const TextScaler.linear(1.0),
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s15,
                  fontWeight: FontWeight.w600,
                  color: CommonColors.trek_route_color,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 2.h),
                child: Column(
                  children: List.generate(
                    (_showFullItinerary || itineraryItems.length <= 2)
                        ? itineraryItems.length
                        : 2,
                    (index) {
                      final day = itineraryItems[index];
                      final activities = day.activities ?? [];

                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Day ${index + 1}',
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s12,
                                fontWeight: FontWeight.w600,
                                color: CommonColors.blackColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...activities
                                .take(
                                  _showFullItinerary ? activities.length : 4,
                                )
                                .map(
                                  (activity) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 8),
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: CommonColors.blackColor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            activity,
                                            textScaler: const TextScaler.linear(
                                              1.0,
                                            ),
                                            style: GoogleFonts.poppins(
                                              fontSize: FontSize.s10,
                                              color: CommonColors.blackColor,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            if (!_showFullItinerary && activities.length > 4)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  top: 8,
                                ),
                                child: Text(
                                  '+ ${activities.length - 4} more activities',
                                  textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s9,
                                    color: CommonColors.trek_route_color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // View All / Hide Button
              if (itineraryItems.length > 2)
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showFullItinerary = !_showFullItinerary;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showFullItinerary
                              ? 'Hide itinerary'
                              : 'View all itinerary',
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s10,
                            fontWeight: FontWeight.w600,
                            color: CommonColors.trek_route_color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _showFullItinerary
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: CommonColors.trek_route_color,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Container();
  }

  Widget _buildActivitiesTab() {
    // final displayedActivities = _showFullActivities
    //     ? _trekControllerC.trekDetailData.value.activities
    //     : _trekControllerC.trekDetailData.value.activities?.take(4).toList();
    if (_trekControllerC.trekDetailData.value.activities != null) {
      return Container(
        width: 95.w,
        decoration: BoxDecoration(
          color: CommonColors.whiteColor,
          borderRadius: BorderRadius.circular(3.8.w),
          boxShadow: [
            BoxShadow(
              color: CommonColors.blackColor.withValues(alpha: 0.1),
              spreadRadius: 0,
              blurRadius: 2.w,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          width: 85.w,
          margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h, bottom: 1.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activities',
                textScaler: const TextScaler.linear(1.0),
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s15,
                  fontWeight: FontWeight.w600,
                  color: CommonColors.trek_route_color,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 2.h),
                child: Column(
                  children: [
                    ...List.generate(
                      (_trekControllerC
                                          .trekDetailData
                                          .value
                                          .activities
                                          ?.length ??
                                      0) >
                                  2 &&
                              !_showFullActivities
                          ? 2
                          : _trekControllerC
                                    .trekDetailData
                                    .value
                                    .activities
                                    ?.length ??
                                0,
                      (index) {
                        final activity = _trekControllerC
                            .trekDetailData
                            .value
                            .activities?[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  activity?.name ?? '',
                                  textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s10,
                                    fontWeight: FontWeight.w400,
                                    color: CommonColors.blackColor,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if ((_trekControllerC.trekDetailData.value.activities?.length ??
                      0) >
                  4)
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showFullActivities = !_showFullActivities;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showFullActivities
                              ? 'Hide Activities'
                              : 'View all Activities',
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s10,
                            fontWeight: FontWeight.w600,
                            color: CommonColors.trek_route_color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _showFullActivities
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: CommonColors.trek_route_color,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  Widget _buildReviewsTab() {
    final displayedReviews = _showFullReviews
        ? _trekControllerC.trekDetailData.value.latestReviews
        : _trekControllerC.trekDetailData.value.latestReviews?.take(5).toList();
    if (_trekControllerC.trekDetailData.value.latestReviews != null) {
      return Container(
        width: 95.w,
        decoration: BoxDecoration(
          color: CommonColors.whiteColor,
          borderRadius: BorderRadius.circular(3.8.w),
          boxShadow: [
            BoxShadow(
              color: CommonColors.blackColor.withValues(alpha: 0.1),
              spreadRadius: 0,
              blurRadius: 2.w,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          width: 85.w,
          margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h, bottom: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Ratings & Reviews',
                textScaler: const TextScaler.linear(1.0),
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s15,
                  fontWeight: FontWeight.w600,
                  color: CommonColors.trek_route_color,
                ),
              ),
              const SizedBox(height: 5),

              // Star Rating
              _buildCustomStarRating(
                rating: _trekControllerC.trekDetailData.value.averageRating?.toDouble() ?? 0.0,
                // rating: 3.2,
                starSize: 8.w,
              ),
              const SizedBox(height: 10),
              // Number of ratings and customerRatingAndReview
              Text(
                '${_trekControllerC.trekDetailData.value.totalReviews} ratings and ${_trekControllerC.trekDetailData.value.reviewCommentsCount} reviews',
                textScaler: const TextScaler.linear(1.0),
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s9,
                  fontWeight: FontWeight.w400,
                  color: CommonColors.hintColor,
                ),
              ),
              const SizedBox(height: 39),

              // People like section
              Text(
                'People like',
                textScaler: const TextScaler.linear(1.0),
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s14,
                  fontWeight: FontWeight.w500,
                  color: CommonColors.blackColor,
                ),
              ),
              const SizedBox(height: 10),

              // People like ratings
              Builder(
                builder: (context) {
                  final ratings =
                      _trekControllerC.trekDetailData.value.categoryRatings;

                  final ratingList = [
                    {
                      'label': 'Safety and Security',
                      'value': ratings?.safetySecurity ?? 0.0,
                    },
                    {
                      'label': 'Organizer Manner',
                      'value': ratings?.organizerManner ?? 0.0,
                    },
                    {
                      'label': 'Trek Planning',
                      'value': ratings?.trekPlanning ?? 0.0,
                    },
                    {
                      'label': 'Women Safety',
                      'value': ratings?.womenSafety ?? 0.0,
                    },
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...ratingList.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12, right: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Label
                              Expanded(
                                child: Text(
                                  item['label'].toString(),
                                  textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s10,
                                    fontWeight: FontWeight.w400,
                                    color: CommonColors.blackColor.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    CommonImages.yellowstar,
                                    width: 2.w,
                                    height: 2.h,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    (item['value'] as double).toStringAsFixed(
                                      1,
                                    ),
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s10,
                                      fontWeight: FontWeight.w400,
                                      color: CommonColors.blackColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Sort by section
              if (displayedReviews != null && displayedReviews.isNotEmpty) ...[
                Text(
                  'Sort by',
                  textScaler: const TextScaler.linear(1.0),
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s14,
                    fontWeight: FontWeight.w500,
                    color: CommonColors.blackColor,
                  ),
                ),
                const SizedBox(height: 15),

                // Sort buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSortButton('Recent Reviews', true),
                      const SizedBox(width: 10),
                      _buildSortButton('Solo Traveller', false),
                      const SizedBox(width: 10),
                      _buildSortButton('High to Low Ratings', false),
                      const SizedBox(width: 10),
                      _buildSortButton('Low to High Ratings', false),
                      const SizedBox(width: 10),
                      _buildSortButton('Organizer Manner', false),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Individual Reviews
                SizedBox(
                  height: 180,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 2,
                        top: 2,
                        bottom: 2,
                      ),
                      child: Row(
                        children: [
                          ...?(_showFullReviews
                                  ? _trekControllerC
                                        .trekDetailData
                                        .value
                                        .latestReviews
                                  : _trekControllerC
                                        .trekDetailData
                                        .value
                                        .latestReviews
                                        ?.take(5))
                              ?.map(
                                (review) => Container(
                                  margin: const EdgeInsets.only(right: 20),
                                  width: 80.w,
                                  height: 25.h,
                                  decoration: BoxDecoration(
                                    color: CommonColors.whiteColor,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: CommonColors.shadowColor
                                            .withValues(alpha: 0.2),
                                        spreadRadius: 0,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.only(
                                    left: 18,
                                    right: 18,
                                    top: 12,
                                    bottom: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            review.customerName ?? '-',
                                            textScaler: const TextScaler.linear(
                                              1.0,
                                            ),
                                            style: GoogleFonts.poppins(
                                              fontSize: FontSize.s11,
                                              fontWeight: FontWeight.w500,
                                              color: CommonColors.blackColor,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: getRatingColor(
                                                (review.ratingValue ?? 0.0)
                                                    .toDouble(),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color:
                                                      CommonColors.whiteColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${review.ratingValue}',
                                                  textScaler:
                                                      const TextScaler.linear(
                                                        1.0,
                                                      ),
                                                  maxLines: 3,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: FontSize.s9,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        CommonColors.whiteColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat("d MMM yyyy").format(DateTime.parse(review.createdAt ?? '-')),
                                        textScaler: const TextScaler.linear(1.0),
                                        style: GoogleFonts.poppins(
                                          fontSize: FontSize.s9,
                                          color: CommonColors.blackColor.withValues(alpha: 0.6),
                                        ),
                                      ),

                                      SizedBox(height: 1.h),
                                      Expanded(
                                        child: Text(
                                          review.content ?? '-',
                                          textScaler: const TextScaler.linear(
                                            1.0,
                                          ),
                                          style: GoogleFonts.poppins(
                                            fontSize: FontSize.s10,
                                            color: CommonColors.blackColor,
                                          ),
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          const SizedBox(width: 21),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // View all customerRatingAndReview button
                if ((_trekControllerC
                            .trekDetailData
                            .value
                            .latestReviews
                            ?.length ??
                        0) >
                    5)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _showFullReviews = !_showFullReviews;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _showFullReviews
                                ? 'Hide Reviews'
                                : 'View all Reviews',
                            textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s10,
                              fontWeight: FontWeight.w600,
                              color: CommonColors.trek_route_color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _showFullReviews
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: CommonColors.trek_route_color,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      );
    }
    return Container();
  }

  Widget _buildSortButton(String text, bool isSelected) {
    return InkWell(
      // onTap: () => _sortReviews(text),
      child: Container(
        padding: const EdgeInsets.only(left: 6, right: 6, top: 7, bottom: 7),
        decoration: BoxDecoration(
          color: text == _selectedSortOption
              ? CommonColors.blueColor.withValues(alpha: 0.1)
              : CommonColors.whiteColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: text == _selectedSortOption
                ? CommonColors.blueColor
                : CommonColors.grey_AEAEAE,
            width: 1,
          ),
        ),
        child: Text(
          text,
          textScaler: const TextScaler.linear(1.0),
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: text == _selectedSortOption
                ? CommonColors.blueColor
                : CommonColors.blackColor,
            fontWeight: text == _selectedSortOption
                ? FontWeight.w500
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildResortsTab() {
    return Container(
      width: 95.w,
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(3.8.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 2.w,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        width: 85.w,
        margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.2.h, bottom: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accommodation',
              textScaler: const TextScaler.linear(1.0),
              style: GoogleFonts.poppins(
                fontSize: FontSize.s15,
                fontWeight: FontWeight.w600,
                color: CommonColors.trek_route_color,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 2.h),
              child: Column(
                children: [
                  // Trek Name in Pink Container
                  Container(
                    width: 90.w,
                    height: 44,
                    decoration: BoxDecoration(
                      color: CommonColors.tableHeaderColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.2),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _trekControllerC.trekDetailData.value.title ?? '-',
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s11,
                          fontWeight: FontWeight.w500,
                          color: CommonColors.blackColor,
                        ),
                      ),
                    ),
                  ),
                  // Resort Details Table
                  Container(
                    padding: const EdgeInsets.only(
                      top: 12,
                      left: 12,
                      right: 24,
                      bottom: 17,
                    ),
                    decoration: BoxDecoration(
                      color: CommonColors.tableColor2,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.2),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Single Vertical Line
                        Positioned(
                          left: 95,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 1,
                            color: CommonColors.blackColor,
                          ),
                        ),
                        // Content
                        Column(
                          children: [
                            if (_trekControllerC
                                        .trekDetailData
                                        .value
                                        .accommodations !=
                                    null &&
                                _trekControllerC
                                    .trekDetailData
                                    .value
                                    .accommodations!
                                    .isNotEmpty)
                              ..._trekControllerC.trekDetailData.value.accommodations!.map((
                                acc,
                              ) {
                                bool isLastItem =
                                    _trekControllerC
                                        .trekDetailData
                                        .value
                                        .accommodations!
                                        .last ==
                                    acc;
                                int index = _trekControllerC
                                    .trekDetailData
                                    .value
                                    .accommodations!
                                    .indexOf(acc);

                                return Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Day Column
                                        SizedBox(
                                          width: 22.w,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10.0,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Day ${index + 1}',
                                                  textScaler:
                                                      const TextScaler.linear(
                                                        1.0,
                                                      ),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: FontSize.s10,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        CommonColors.blackColor,
                                                  ),
                                                ),
                                                // Text(
                                                //   '${acc.date != null ? DateFormat('dd MMM').format(DateTime.parse(acc.date!)) : '-'} (${(acc.dayName != null && acc.dayName!.length >= 3) ? acc.dayName!.substring(0, 3) : '-'})',
                                                //   textScaler:
                                                //       const TextScaler.linear(
                                                //           1.0),
                                                //   style: GoogleFonts.poppins(
                                                //     fontSize: FontSize.s8,
                                                //     fontWeight: FontWeight.w400,
                                                //     color:
                                                //         CommonColors.blackColor,
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Check in to ${acc.details?.location}, ${acc.type}',
                                                textScaler:
                                                    const TextScaler.linear(
                                                      1.0,
                                                    ),
                                                style: GoogleFonts.poppins(
                                                  fontSize: FontSize.s9,
                                                  fontWeight: FontWeight.w400,
                                                  color:
                                                      CommonColors.blackColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (!isLastItem)
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        height: 1,
                                        color: CommonColors.blackColor,
                                      ),
                                  ],
                                );
                              }).toList(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrekRouteTab extends StatefulWidget {
  final TrekDetailData trek;

  const TrekRouteTab({super.key, required this.trek});

  @override
  State<TrekRouteTab> createState() => _TrekRouteTabState();
}

class _TrekRouteTabState extends State<TrekRouteTab> {
  bool showFullRoute = false;

  // Method to format date and time
  Map<String, String> _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return {'time': '', 'date': ''};
    }

    try {
      // Parse the date string "2025-09-04 12:00 PM"
      final DateTime dateTime = DateFormat(
        'yyyy-MM-dd hh:mm a',
      ).parse(dateTimeString);

      // Format time as "03:50 PM"
      final String formattedTime = DateFormat('hh:mm a').format(dateTime);

      // Format date as "22/12"
      final String formattedDate = DateFormat('dd/MM').format(dateTime);

      return {'time': formattedTime, 'date': formattedDate};
    } catch (e) {
      return {'time': dateTimeString, 'date': ''};
    }
  }

  Widget _buildRouteItem(
    TrekStages stop,
    bool isLast, {
    bool showDottedLine = false,
    String? firstRouteName,
  }) {
    // Format the date and time
    final formattedDateTime = _formatDateTime(stop.dateTime);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time & Date
            SizedBox(
              width: 85,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedDateTime['time'] ?? '',
                      textScaler: const TextScaler.linear(1.0),
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s9,
                        fontWeight: FontWeight.w400,
                        color: CommonColors.blackColor.withValues(alpha: 0.6),
                      ),
                    ),
                    // date
                    Text(
                      formattedDateTime['date'] ?? '',
                      textScaler: const TextScaler.linear(1.0),
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s9,
                        fontWeight: FontWeight.w400,
                        color: CommonColors.blackColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Dot and timeline
            SizedBox(
              width: 20,
              child: Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CommonColors.blackColor,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 9,
                      height: 51,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: CommonColors.trekroutecolorlight,
                      ),
                    ),
                ],
              ),
            ),
            // Location and Transport
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isLast && firstRouteName != null
                              ? firstRouteName
                              : (stop.isBoardingPoint == true
                                  ? (stop.city?.cityName ?? '')
                                  : (stop.destination ?? '')),
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s10,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.blackColor,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 29),
                        child: Text(
                          stop.meansOfTransport ?? '',
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s8,
                            fontWeight: FontWeight.w400,
                            color: CommonColors.blackColor.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
        // Add dotted line if needed
        if (showDottedLine)
          Row(
            children: [
              const SizedBox(width: 85),
              SizedBox(
                width: 20,
                child: Column(
                  children: [
                    for (int i = 0; i < 3; i++) ...[
                      Container(
                        width: 6,
                        height: 8,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: CommonColors.trekroutecolorlight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  List<List<TrekStages>> _splitRouteList(List<TrekStages> routeList) {
    if (routeList.isEmpty) {
      return [[], []];
    }

    // If showing partial route, return first, second and last points
    if (!showFullRoute) {
      if (routeList.length <= 3) {
        return [routeList, []];
      }
      return [
        [
          routeList[0], // First point
          routeList[1], // Second point
          routeList.last, // Last point
        ],
        routeList.sublist(2, routeList.length - 1), // Rest of the points
      ];
    }

    // If showing full route, return all points
    return [routeList, []];
  }

  @override
  Widget build(BuildContext context) {
    final TrekController _trekControllerC = Get.find<TrekController>();

    final trek = _trekControllerC.trekDetailData.value;
    final routeList = trek.trekStages;

    final [visiblePoints, hiddenPoints] = _splitRouteList(routeList ?? []);

    return Container(
      width: 95.w,
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(3.8.w),
        boxShadow: [
          BoxShadow(
            // color: Colors.grey.withValues(alpha: 0.1),
            color: CommonColors.blackColor.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 2.w,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        width: 85.w,
        margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 3.h, bottom: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Trek Route',
              textScaler: const TextScaler.linear(1.0),
              style: GoogleFonts.poppins(
                fontSize: FontSize.s15,
                fontWeight: FontWeight.w500,
                color: CommonColors.trek_route_color,
              ),
            ),
            const SizedBox(height: 5),

            // Boarding Point
            if (routeList != null && routeList.isNotEmpty)
              Builder(
                builder: (context) {
                  // Find the boarding point stage
                  final boardingStage = routeList.firstWhere(
                    (stage) => stage.isBoardingPoint == true,
                    orElse: () => routeList.first,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Boarding Point',
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s14,
                          fontWeight: FontWeight.w500,
                          color: CommonColors.blackColor,
                        ),
                      ),
                      Text(
                        boardingStage.city?.cityName != null &&
                                boardingStage.city!.cityName!.isNotEmpty
                            ? '${boardingStage.city?.cityName} - ${boardingStage.destination ?? '-'}'
                            : boardingStage.destination ?? '-',
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s9,
                          fontWeight: FontWeight.w400,
                          color: CommonColors.blackColor.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        _formatDateTime(boardingStage.dateTime)['time'] ?? '-',
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s9,
                          color: CommonColors.blackColor.withValues(alpha: 0.6),
                        ),
                      ),
                      // Text(
                      //   _formatDateTime(boardingStage.dateTime)['date'] ?? '-',
                      //   textScaler: const TextScaler.linear(1.0),
                      //   style: GoogleFonts.poppins(
                      //     fontSize: FontSize.s9,
                      //     color: CommonColors.blackColor.withValues(alpha: 0.6),
                      //   ),
                      // ),
                      const SizedBox(height: 30),
                    ],
                  );
                },
              ),

            // Visible points
            if (visiblePoints.isNotEmpty)
              ...visiblePoints.asMap().entries.map((entry) {
                final index = entry.key;
                final stop = entry.value;
                final isLastVisible = index == visiblePoints.length - 1;
                final isSecondPoint = index == 1;
                final hasHiddenPoints = hiddenPoints.isNotEmpty;

                // Get the first route name to display at the last route
                String? firstRouteName;
                if (routeList != null && routeList.isNotEmpty) {
                  final firstRoute = routeList.first;
                  firstRouteName = firstRoute.isBoardingPoint == true
                      ? (firstRoute.city?.cityName ?? '')
                      : (firstRoute.destination ?? '');
                }

                return _buildRouteItem(
                  stop,
                  isLastVisible,
                  showDottedLine:
                      !showFullRoute && isSecondPoint && hasHiddenPoints,
                  firstRouteName: firstRouteName,
                );
              }),

            // Toggle view button
            //handle view all trek route
            if ((routeList?.length ?? 0) > 3)
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      showFullRoute = !showFullRoute;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    // Ensures the row doesn't take up unnecessary space
                    children: [
                      Text(
                        showFullRoute
                            ? 'Hide trek route'
                            : 'View all trek route',
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s10,
                          fontWeight: FontWeight.w600,
                          color: CommonColors.trek_route_color,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ), // Adds space between the text and the icon
                      Icon(
                        showFullRoute
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: CommonColors.trek_route_color,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
