import 'dart:math' as math;
import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../freezed_models/treks/trek_detail_model.dart';
import '../freezed_models/treks/treks_model_data.dart';
import '../utils/common_colors.dart';
import '../utils/common_images.dart';
import '../utils/common_trek_card.dart';
import '../utils/common_images_card.dart';
import '../utils/common_trek_details_bar.dart';
import '../utils/common_btn.dart';
import '../utils/screen_constants.dart';
import '../widgets/cancellation_policy_widget.dart';
import '../widgets/custom_network_image.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _C {
  static const bg          = CommonColors.offWhiteColor;
  static const cardBg      = CommonColors.whiteColor;
  static const ink         = CommonColors.blackColor;
  static const inkMid      = CommonColors.cFF6B7280;
  static const inkLight    = CommonColors.grey_AEAEAE;
  static const brand       = CommonColors.trek_route_color;    // deep blue #212199
  static const teal        = CommonColors.cFF0F7B6C;
  static const tealSoft    = CommonColors.cFFE6F5F3;
  static const iconBadge   = CommonColors.cFF111827;           // dark black badge
  static const divider     = CommonColors.trekroutecolorlight;
  static const shadow      = CommonColors.c0A000000;
  static const routeLine   = CommonColors.trekroutecolorlight;
}

// ─────────────────────────────────────────────
//  STICKY HEADER DELEGATE — unchanged
// ─────────────────────────────────────────────
class _StickyTrekDetailsBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyTrekDetailsBarDelegate({required this.child});

  @override double get minExtent => 6.5.h;
  @override double get maxExtent => 6.5.h;
  @override bool shouldRebuild(_StickyTrekDetailsBarDelegate o) => true;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlaps) => child;
}

// ─────────────────────────────────────────────
//  TREK DETAILS SCREEN
// ─────────────────────────────────────────────
class TrekDetailsScreen extends StatefulWidget {
  final TrekData? trek;
  const TrekDetailsScreen({super.key, required this.trek});

  @override
  State<TrekDetailsScreen> createState() => _TrekDetailsScreenState();
}

class _TrekDetailsScreenState extends State<TrekDetailsScreen> {

  final TrekController     _trekC      = Get.find<TrekController>();
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final UserController      _userC      = Get.find<UserController>();

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys =
      List.generate(8, (index) => GlobalKey());

  int  _selectedTabIndex        = 0;
  bool _showFullItinerary       = false;
  bool _showFullFeatures        = false;
  bool _showFullActivities      = false;
  bool _showFullOtherPolicies   = false;
  bool _showFullReviews         = false;
  String _selectedSortOption    = 'Recent Reviews';
  List<LatestReviews> _sortedReviews = [];
  bool _isUserScrolling         = false;

  // ── rating gradient — same as original ──────
  LinearGradient getRatingColor(double rating) {
    if (rating >= 3.0 && rating <= 3.8) {
      return const LinearGradient(
        colors: [Color(0xFFFFFA5F), Color(0xFFFFFA5F)],
      );
    } else if (rating < 3.0) {
      return const LinearGradient(
        colors: [Color(0xFFFF6B3A), Color(0xFFFF6B3A)],
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF19FA00), Color(0xFF4EE53D)],
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_onScroll);
    });
    _sortedReviews =
        _trekC.trekDetailData.value.latestReviews ?? [];
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ── All scroll logic unchanged ───────────────
  void _onScroll() {
    if (!_scrollController.hasClients || _isUserScrolling) return;
    final position    = _scrollController.position;
    final vpHeight    = position.viewportDimension;
    int  mostVisible  = _selectedTabIndex;
    double maxVis     = 0;
    const topBuffer   = 0.0;

    for (int i = 0; i < _sectionKeys.length; i++) {
      final key = _sectionKeys[i];
      if (key.currentContext == null) continue;
      final box  = key.currentContext!.findRenderObject() as RenderBox;
      final pos  = box.localToGlobal(Offset.zero);
      final top  = pos.dy - topBuffer;
      final h    = box.size.height;
      final visT = math.max(0.0, top);
      final visB = math.min(vpHeight, top + h);
      double vis = visB - visT;
      if (top < vpHeight * 0.5) vis *= 1.5;
      if (vis > maxVis) { maxVis = vis; mostVisible = i; }
    }
    if (mostVisible != _selectedTabIndex) {
      setState(() => _selectedTabIndex = mostVisible);
    }
  }

  void _scrollToSection(int index) {
    if (index >= _sectionKeys.length) return;
    _isUserScrolling = true;
    setState(() => _selectedTabIndex = index);
    _scrollToSectionWithRendering(index);
  }

  void _scrollToSectionWithRendering(int index) {
    final offsets = [0, 45.h, 90.h, 135.h, 180.h, 225.h, 270.h, 315.h];
    final target  = (index < offsets.length ? offsets[index] : index * 45.h)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController
        .animateTo(target.toDouble(),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut)
        .then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _attemptPreciseScroll(index, 0);
      });
    });
  }

  void _attemptPreciseScroll(int index, int attempts) {
    if (attempts >= 3) { _isUserScrolling = false; return; }
    final key = _sectionKeys[index];
    if (key.currentContext != null) {
      try {
        final box    = key.currentContext!.findRenderObject() as RenderBox;
        final pos    = box.localToGlobal(Offset.zero);
        final target = (_scrollController.offset + pos.dy - 18.h)
            .clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController
            .animateTo(target.toDouble(),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut)
            .then((_) => _isUserScrolling = false);
      } catch (_) {
        Future.delayed(const Duration(milliseconds: 100), () =>
            _attemptPreciseScroll(index, attempts + 1));
      }
    } else {
      Future.delayed(const Duration(milliseconds: 100), () =>
          _attemptPreciseScroll(index, attempts + 1));
    }
  }

  String _formatReviewDate(String date) {
    final d = DateFormat('dd/MM/yyyy').parse(date);
    return DateFormat('dd MMM yyyy').format(d);
  }

  IconData _getIconForPolicy(String name) {
    switch (name) {
      case 'no_drinks':            return Icons.no_drinks;
      case 'schedule':             return Icons.schedule;
      case 'cancel_schedule_send': return Icons.cancel_schedule_send;
      case 'attach_money':         return Icons.attach_money;
      case 'phone_in_talk':        return Icons.phone_in_talk;
      case 'person_pin_circle':    return Icons.person_pin_circle;
      default:                     return Icons.info_outline;
    }
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomBar(),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        slivers: [
          // ── Trek card ───────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(bottom: 0.5.h),
              decoration: BoxDecoration(
                color: _C.cardBg,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(3.w),
                  bottomRight: Radius.circular(3.w),
                ),
                boxShadow: [
                  BoxShadow(
                    color: CommonColors.shadowColor.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                width: 100.w,
                margin: EdgeInsets.only(top: 1.5.h, bottom: 1.2.h),
                child: CommonTrekCard(
                  trek: widget.trek,
                  showShare: true,
                ),
              ),
            ),
          ),

          // ── Photo gallery ───────────────────
          if (_trekC.trekDetailData.value.images != null &&
              _trekC.trekDetailData.value.images!.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                width: 100.w,
                margin: EdgeInsets.only(
                    top: 2.h, left: 4.w, bottom: 1.5.h),
                child: GestureDetector(
                  onTap: () => _showImageViewer(
                    context,
                    _trekC.trekDetailData.value.images
                            ?.map((e) => e.url ?? '')
                            .toList() ??
                        [],
                    0,
                  ),
                  child: CommonImageCard(
                    images: _trekC.trekDetailData.value.images
                            ?.map((e) => e.url ?? '')
                            .toList() ??
                        [],
                  ),
                ),
              ),
            ),

          // ── Sticky tab bar ──────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTrekDetailsBarDelegate(
              child: Container(
                width: 100.w,
                color: _C.cardBg,
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

          // ── Section list ────────────────────
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 1.h),
              _sectionWrapper(0,
                  visible: _trekC.trekDetailData.value.trekStages?.isNotEmpty == true,
                  child: TrekRouteTab(trek: _trekC.trekDetailData.value)),
              SizedBox(height: 1.5.h),
              _sectionWrapper(1,
                  visible: _trekC.trekDetailData.value.itineraryItems?.isNotEmpty == true,
                  child: _buildItineraryTab()),
              SizedBox(height: 1.5.h),
              _sectionWrapper(2,
                  visible: _trekC.trekDetailData.value.activities?.isNotEmpty == true,
                  child: _buildActivitiesTab()),
              SizedBox(height: 1.5.h),
              _sectionWrapper(3,
                  visible: _trekC.trekDetailData.value.accommodations?.isNotEmpty == true,
                  child: _buildResortsTab()),
              SizedBox(height: 1.5.h),
              _sectionWrapper(4,
                  visible: _trekC.trekDetailData.value.inclusions?.isNotEmpty == true,
                  child: _buildFeaturesTab()),
              SizedBox(height: 1.5.h),
              _sectionWrapper(5,
                  visible: _trekC.trekDetailData.value.latestReviews?.isNotEmpty == true,
                  child: _buildReviewsTab()),
              SizedBox(height: 1.5.h),
              _sectionWrapper(6,
                  visible: _trekC.trekDetailData.value.cancellationPolicy?.rules?.isNotEmpty == true,
                  child: _buildCancellationPoliciesTab()),
              SizedBox(height: 1.5.h),
              _sectionWrapper(7,
                  visible: (_trekC.trekDetailData.value.trekkingRules?.isNotEmpty == true) ||
                      (_trekC.trekDetailData.value.emergencyProtocols?.isNotEmpty == true) ||
                      (_trekC.trekDetailData.value.organizerNotes?.isNotEmpty == true),
                  child: _buildOtherPoliciesTab()),
              SizedBox(height: 3.h),
            ]),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  APP BAR
  // ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _C.cardBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: _C.ink),
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _C.divider),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _trekC.trekDetailData.value.title ?? '--',
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s12,
              fontWeight: FontWeight.w600,
              color: _C.ink,
            ),
          ),
          Row(
            children: [
              Text(
                _dashboardC.fromController.value.text,
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s9,
                  color: _C.inkMid,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                child: Icon(Icons.arrow_forward_rounded,
                    color: _C.inkLight, size: 3.5.w),
              ),
              Text(
                _dashboardC.toController.value.text,
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s9,
                  color: _C.inkMid,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BOTTOM BAR — same logic
  // ─────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 1.5.h, 10.w, 2.5.h),
      decoration: BoxDecoration(
        color: _C.cardBg,
        boxShadow: [
          BoxShadow(
              color: _C.shadow, blurRadius: 12, offset: const Offset(0, -3)),
        ],
      ),
      child: CommonButton(
        text: 'Continue',
        onPressed: () async {
          await _userC.getUserProfile();
          _trekC.trekBatchId.value =
              _trekC.trekDetailData.value.batchId ?? 0;
          Get.toNamed('/traveller-info');
        },
        gradient: CommonColors.filterGradient,
        textColor: CommonColors.whiteColor,
        height: 6.h,
        isFullWidth: false,
        width: 50.w,
        fontSize: FontSize.s14,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SECTION WRAPPER
  //  Handles visibility + attaches section key
  // ─────────────────────────────────────────────
  Widget _sectionWrapper(int idx,
      {required bool visible, required Widget child}) {
    if (!visible) return const SizedBox.shrink();
    return Container(
      key: _sectionKeys[idx],
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: child,
    );
  }

  // ─────────────────────────────────────────────
  //  SHARED CARD SHELL
  //  White rounded card used by every section
  // ─────────────────────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withOpacity(0.07),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: child,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SHARED SECTION HEADER
  //  Dark icon badge + title — matches app-wide style
  // ─────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 9.w,
          height: 9.w,
          decoration: BoxDecoration(
            color: _C.iconBadge,
            borderRadius: BorderRadius.circular(2.5.w),
          ),
          child: Center(
            child: Icon(icon, color: Colors.white, size: 4.5.w),
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          title,
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w700,
            color: _C.ink,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  SHOW MORE / LESS BUTTON
  // ─────────────────────────────────────────────
  Widget _toggleBtn(String label, bool expanded, VoidCallback onTap) {
    return Center(
      child: TextButton(
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              expanded ? 'Hide $label' : 'View all $label',
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                fontWeight: FontWeight.w600,
                color: _C.brand,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: _C.brand,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BULLET ITEM
  //  Used in inclusions, exclusions, activities
  // ─────────────────────────────────────────────
  Widget _bulletItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _C.brand,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                color: _C.ink,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  IMAGE VIEWER — same as original
  // ─────────────────────────────────────────────
  void _showImageViewer(
      BuildContext context, List<String> images, int initial) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: 100.h,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: images.length,
              controller: PageController(initialPage: initial),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: CustomNetworkImage(
                      imageUrl: images[i],
                      fit: BoxFit.contain,
                      width: 100.w,
                      height: 100.h,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
//
    Widget _buildCancellationPoliciesTab() {
  final departure = _trekC.trekDetailData.value.departureDateTimeFromStages;
  return CancellationPolicyWidget(policy: _trekC.trekDetailData.value.cancellationPolicy,departureDate: departure.toString());
  // return CancellationPolicyCard(
  //   departureDate: departure?.toIso8601String(),
  //   basePrice: _trekC.trekDetailData.value.basePrice,
  //   bookingType: (_trekC.trekDetailData.value.cancellationPolicy?.id ?? 0) == 1 ? "standard" :"flexible",
  // );
}

  // Widget _buildOtherPoliciesTab() {
  //   final rules = _trekC.trekDetailData.value.trekkingRules;
  //   final emergency = _trekC.trekDetailData.value.emergencyProtocols;
  //   final notes = _trekC.trekDetailData.value.organizerNotes;
  //
  //   if ((rules == null || rules.isEmpty) &&
  //       (emergency == null || emergency.isEmpty) &&
  //       (notes == null || notes.isEmpty)) {
  //     return Container();
  //   }
  //
  //   return Container(
  //     width: 95.w,
  //     decoration: BoxDecoration(
  //       color: CommonColors.whiteColor,
  //       borderRadius: BorderRadius.circular(3.8.w),
  //       boxShadow: [
  //         BoxShadow(
  //           color: CommonColors.blackColor.withAlpha(25),
  //           spreadRadius: 0,
  //           blurRadius: 2.w,
  //           offset: Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Container(
  //       width: 85.w,
  //       margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Other Policies',
  //             style: GoogleFonts.poppins(
  //               fontSize: FontSize.s17,
  //               fontWeight: FontWeight.w600,
  //               color: CommonColors.trek_route_color,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // ─────────────────────────────────────────────
  //  STAR RATING — same as original
  // ─────────────────────────────────────────────
  Widget _buildStarRating({required double rating, required double size}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final v = rating - i;
        return Padding(
          padding: EdgeInsets.only(right: i < 4 ? 1.w : 0),
          child: Icon(
            v >= 1.0
                ? Icons.star
                : v >= 0.5
                    ? Icons.star_half
                    : Icons.star_border,
            size: size,
            color: v > 0
                ? CommonColors.completedColor2
                : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────
  //  ITINERARY TAB
  // ─────────────────────────────────────────────
  Widget _buildItineraryTab() {
    final items = _trekC.trekDetailData.value.itineraryItems;
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    final count = (_showFullItinerary || items.length <= 2)
        ? items.length
        : 2;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Itinerary', Icons.map_outlined),
          SizedBox(height: 2.h),
          ...List.generate(count, (idx) {
            final day        = items[idx];
            final activities = day.activities ?? [];
            return Container(
              margin: EdgeInsets.only(bottom: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(color: _C.brand.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day header strip
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 4.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: _C.brand.withOpacity(0.08),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(3.w),
                        topRight: Radius.circular(3.w),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.5.w, vertical: 0.3.h),
                          decoration: BoxDecoration(
                            color: _C.brand,
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          child: Text(
                            'Day ${idx + 1}',
                            textScaler: const TextScaler.linear(1.0),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'Day ${idx + 1} Activities',
                            textScaler: const TextScaler.linear(1.0),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s10,
                              fontWeight: FontWeight.w500,
                              color: _C.brand,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Activity list
                  Padding(
                    padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 1.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...activities
                            .take(_showFullItinerary ? activities.length : 4)
                            .map((a) => _bulletItem(a)),
                        if (!_showFullItinerary && activities.length > 4)
                          Padding(
                            padding: EdgeInsets.only(left: 3.w),
                            child: Text(
                              '+ ${activities.length - 4} more activities',
                              textScaler: const TextScaler.linear(1.0),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s9,
                                color: _C.brand,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          if (items.length > 2)
            _toggleBtn('itinerary', _showFullItinerary,
                () => setState(() => _showFullItinerary = !_showFullItinerary)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  ACTIVITIES TAB
  // ─────────────────────────────────────────────
  Widget _buildActivitiesTab() {
    final acts = _trekC.trekDetailData.value.activities;
    if (acts == null) return const SizedBox.shrink();

    final count = (acts.length > 2 && !_showFullActivities) ? 2 : acts.length;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Activities', Icons.directions_walk_rounded),
          SizedBox(height: 2.h),
          ...List.generate(count,
              (i) => _bulletItem(acts[i]?.name ?? '')),
          if (acts.length > 4)
            _toggleBtn('Activities', _showFullActivities,
                () => setState(() => _showFullActivities = !_showFullActivities)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  FEATURES / INCLUSIONS-EXCLUSIONS TAB
  // ─────────────────────────────────────────────
  Widget _buildFeaturesTab() {
    final inc = _showFullFeatures
        ? _trekC.trekDetailData.value.inclusions
        : _trekC.trekDetailData.value.inclusions?.take(4).toList();
    final exc = _showFullFeatures
        ? _trekC.trekDetailData.value.exclusions
        : _trekC.trekDetailData.value.exclusions?.take(4).toList();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Inclusions & Exclusions', Icons.checklist_rounded),
          SizedBox(height: 2.h),

          // Inclusions
          if (inc != null && inc.isNotEmpty) ...[
            _subLabel('Inclusions', _C.teal),
            SizedBox(height: 1.h),
            ...inc.map((e) => _checkItem(e.name ?? '-', included: true)),
            SizedBox(height: 2.h),
          ],

          // Exclusions
          if (exc != null && exc.isNotEmpty) ...[
            _subLabel('Exclusions', CommonColors.cFFDC2626),
            SizedBox(height: 1.h),
            ...exc.map((e) => _checkItem(e, included: false)),
          ],

          if ((_trekC.trekDetailData.value.inclusions?.length ?? 0) > 4 ||
              (_trekC.trekDetailData.value.exclusions?.length ?? 0) > 4)
            _toggleBtn('Features', _showFullFeatures,
                () => setState(() => _showFullFeatures = !_showFullFeatures)),
        ],
      ),
    );
  }

  Widget _subLabel(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 2.w),
        Text(
          text,
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _checkItem(String text, {required bool included}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 5.5.w,
            height: 5.5.w,
            decoration: BoxDecoration(
              color: included
                  ? _C.tealSoft
                  : CommonColors.cFFFFE4E4,
              shape: BoxShape.circle,
            ),
            child: Icon(
              included ? Icons.check_rounded : Icons.close_rounded,
              size: 3.w,
              color: included ? _C.teal : CommonColors.cFFDC2626,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                color: _C.ink,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  RESORTS / ACCOMMODATION TAB
  // ─────────────────────────────────────────────
  Widget _buildResortsTab() {
    final accs = _trekC.trekDetailData.value.accommodations;
    if (accs == null || accs.isEmpty) return const SizedBox.shrink();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Accommodation', Icons.hotel_rounded),
          SizedBox(height: 2.h),
          ...accs.asMap().entries.map((entry) {
            final i   = entry.key;
            final acc = entry.value;
            final isLast = i == accs.length - 1;
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline
                    Column(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: _C.brand.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: _C.brand.withOpacity(0.3)),
                          ),
                          child: Center(
                            child: Text(
                              'D${i + 1}',
                              textScaler: const TextScaler.linear(1.0),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s8,
                                fontWeight: FontWeight.w700,
                                color: _C.brand,
                              ),
                            ),
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 1.5,
                            height: 5.h,
                            color: _C.divider,
                          ),
                      ],
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 2.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check in to ${acc.details?.location ?? '-'}',
                              textScaler: const TextScaler.linear(1.0),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s11,
                                fontWeight: FontWeight.w600,
                                color: _C.ink,
                              ),
                            ),
                            SizedBox(height: 0.3.h),
                            Row(
                              children: [
                                Icon(Icons.hotel_rounded,
                                    size: 3.5.w, color: _C.inkLight),
                                SizedBox(width: 1.w),
                                Text(
                                  acc.type ?? '-',
                                  textScaler: const TextScaler.linear(1.0),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: FontSize.s9,
                                    color: _C.inkMid,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  REVIEWS TAB
  // ─────────────────────────────────────────────
  Widget _buildReviewsTab() {
    final reviews = _trekC.trekDetailData.value.latestReviews;
    if (reviews == null) return const SizedBox.shrink();
    final ratings = _trekC.trekDetailData.value.categoryRatings;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Ratings & Reviews', Icons.star_rounded),
          SizedBox(height: 2.h),

          // Summary row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Big rating number
              Container(
                width: 18.w,
                height: 18.w,
                decoration: BoxDecoration(
                  gradient: getRatingColor(
                    _trekC.trekDetailData.value.averageRating?.toDouble() ?? 0),
                  borderRadius: BorderRadius.circular(3.w),
                ),
                child: Center(
                  child: Text(
                    (_trekC.trekDetailData.value.averageRating ?? 0.0)
                        .toStringAsFixed(1),
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStarRating(
                      rating: _trekC.trekDetailData.value.averageRating?.toDouble() ?? 0.0,
                      size: 5.w,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${_trekC.trekDetailData.value.totalReviews ?? 0} ratings  ·  ${_trekC.trekDetailData.value.reviewCommentsCount ?? 0} reviews',
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s9,
                        color: _C.inkMid,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),
          Divider(color: _C.divider, height: 1),
          SizedBox(height: 2.h),

          // Category ratings
          Text(
            'People like',
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s12,
              fontWeight: FontWeight.w600,
              color: _C.ink,
            ),
          ),
          SizedBox(height: 1.5.h),
          ...([
            {'label': 'Safety & Security', 'value': ratings?.safetySecurity ?? 0.0},
            {'label': 'Organizer Manner',  'value': ratings?.organizerManner ?? 0.0},
            {'label': 'Trek Planning',     'value': ratings?.trekPlanning ?? 0.0},
            {'label': 'Women Safety',      'value': ratings?.womenSafety ?? 0.0},
          ].map((item) => _ratingBar(
              item['label'] as String, (item['value'] as double)))),

          SizedBox(height: 2.h),
          Divider(color: _C.divider, height: 1),
          SizedBox(height: 2.h),

          // Sort chips
          Text(
            'Sort by',
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s11,
              fontWeight: FontWeight.w600,
              color: _C.ink,
            ),
          ),
          SizedBox(height: 1.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'Recent Reviews',
                'Solo Traveller',
                'High to Low Ratings',
                'Low to High Ratings',
                'Organizer Manner',
              ].map((t) => _buildSortButton(t, t == _selectedSortOption)).toList(),
            ),
          ),

          SizedBox(height: 2.h),

          // Review cards — horizontal scroll
          SizedBox(
            height: 20.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: (_showFullReviews ? reviews : reviews.take(5)).length,
              itemBuilder: (_, i) {
                final r = (_showFullReviews
                    ? reviews
                    : reviews.take(5).toList())[i];
                return _reviewCard(r);
              },
            ),
          ),

          if (reviews.length > 5)
            _toggleBtn('Reviews', _showFullReviews,
                () => setState(() => _showFullReviews = !_showFullReviews)),
        ],
      ),
    );
  }

  Widget _ratingBar(String label, double value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.2.h),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                color: _C.inkMid,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 5.0,
                minHeight: 6,
                backgroundColor: _C.divider,
                valueColor:
                    AlwaysStoppedAnimation<Color>(CommonColors.completedColor2),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          SvgPicture.asset(CommonImages.yellowstar, width: 3.w, height: 3.w),
          SizedBox(width: 1.w),
          Text(
            value.toStringAsFixed(1),
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s9,
              fontWeight: FontWeight.w600,
              color: _C.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(LatestReviews review) {
    return Container(
      width: 75.w,
      margin: EdgeInsets.only(right: 3.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: _C.divider),
        boxShadow: [
          BoxShadow(
              color: _C.shadow, blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar + name
              Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: _C.brand.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (review.customerName?.isNotEmpty == true)
                            ? review.customerName![0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s12,
                          fontWeight: FontWeight.w700,
                          color: _C.brand,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.customerName ?? '-',
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s10,
                          fontWeight: FontWeight.w600,
                          color: _C.ink,
                        ),
                      ),
                      Text(
                        review.createdAt != null
                            ? DateFormat('d MMM yyyy')
                                .format(DateTime.parse(review.createdAt!))
                            : '-',
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s8,
                          color: _C.inkLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Rating badge
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 2.w, vertical: 0.3.h),
                decoration: BoxDecoration(
                  gradient: getRatingColor(
                      (review.ratingValue ?? 0.0).toDouble()),
                  borderRadius: BorderRadius.circular(1.5.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.white, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      '${review.ratingValue}',
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Expanded(
            child: Text(
              review.content ?? '-',
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                color: _C.inkMid,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedSortOption = text),
      child: Container(
        margin: EdgeInsets.only(right: 2.w),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: isSelected ? _C.brand.withOpacity(0.1) : _C.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _C.brand : _C.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          text,
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s9,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? _C.brand : _C.ink,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  CANCELLATION POLICIES TAB — same logic
  // ─────────────────────────────────────────────
  // Widget _buildCancellationPoliciesTab() {
  //   final departure =
  //       _trekC.trekDetailData.value.departureDateTimeFromStages;
  //   return CancellationPolicyCard(
  //     departureDate: departure?.toIso8601String(),
  //     basePrice: _trekC.trekDetailData.value.basePrice,
  //     bookingType:
  //         (_trekC.trekDetailData.value.cancellationPolicy?.id ?? 0) == 1
  //             ? 'standard'
  //             : 'flexible',
  //   );
  // }
  //
  // // ─────────────────────────────────────────────
  // //  OTHER POLICIES TAB
  // // ─────────────────────────────────────────────
  Widget _buildOtherPoliciesTab() {
    final rules     = _trekC.trekDetailData.value.trekkingRules;
    final emergency = _trekC.trekDetailData.value.emergencyProtocols;
    final notes     = _trekC.trekDetailData.value.organizerNotes;

    if ((rules == null || rules.isEmpty) &&
        (emergency == null || emergency.isEmpty) &&
        (notes == null || notes.isEmpty)) return const SizedBox.shrink();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Other Policies', Icons.policy_outlined),
          SizedBox(height: 2.h),
          if (rules != null && rules.isNotEmpty)
            _buildPolicyBlock('Trekking Rules', rules),
          if (emergency != null && emergency.isNotEmpty)
            _buildPolicyBlock('Emergency Protocols', emergency),
          if (notes != null && notes.isNotEmpty)
            _buildPolicyBlock('Organizer Notes', notes),
        ],
      ),
    );
  }

  Widget _buildPolicyBlock(String title, String content) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: _C.brand.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getIconForPolicy(title), size: 4.5.w, color: _C.brand),
              SizedBox(width: 2.w),
              Text(
                title,
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s11,
                  fontWeight: FontWeight.w600,
                  color: _C.brand,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            content,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s9,
              color: _C.inkMid,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TREK ROUTE TAB — same logic, upgraded UI
// ─────────────────────────────────────────────
class TrekRouteTab extends StatefulWidget {
  final TrekDetailData trek;
  const TrekRouteTab({super.key, required this.trek});

  @override
  State<TrekRouteTab> createState() => _TrekRouteTabState();
}

class _TrekRouteTabState extends State<TrekRouteTab> {

  bool showFullRoute = false;

  Map<String, String> _formatDateTime(String? dt) {
    if (dt == null || dt.isEmpty) return {'time': '', 'date': ''};
    try {
      final d = DateFormat('yyyy-MM-dd hh:mm a').parse(dt);
      return {
        'time': DateFormat('hh:mm a').format(d),
        'date': DateFormat('dd/MM').format(d),
      };
    } catch (_) {
      return {'time': dt, 'date': ''};
    }
  }

  List<List<TrekStages>> _splitRouteList(List<TrekStages> list) {
    if (list.isEmpty) return [[], []];
    if (!showFullRoute) {
      if (list.length <= 3) return [list, []];
      return [
        [list[0], list[1], list.last],
        list.sublist(2, list.length - 1),
      ];
    }
    return [list, []];
  }

  @override
  Widget build(BuildContext context) {
    final ctrl       = Get.find<TrekController>();
    final trek       = ctrl.trekDetailData.value;
    final routeList  = trek.trekStages ?? [];
    final split      = _splitRouteList(routeList);
    final visible    = split[0];
    final hidden     = split[1];

    // find boarding point
    final boarding = routeList.isNotEmpty
        ? routeList.firstWhere(
            (s) => s.isBoardingPoint == true,
            orElse: () => routeList.first)
        : null;
    final firstName = routeList.isNotEmpty
        ? (routeList.first.isBoardingPoint == true
            ? (routeList.first.city?.cityName ?? '')
            : (routeList.first.destination ?? ''))
        : '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          Row(
            children: [
              Container(
                width: 9.w,
                height: 9.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(2.5.w),
                ),
                child: const Center(
                  child: Icon(Icons.alt_route_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Trek Route',
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s14,
                  fontWeight: FontWeight.w700,
                  color: CommonColors.blackColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Boarding point card
          if (boarding != null) ...[
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 4.w, vertical: 1.2.h),
              decoration: BoxDecoration(
                color: CommonColors.trek_route_color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                    color: CommonColors.trek_route_color.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: CommonColors.trek_route_color,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.flag_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Boarding Point',
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s8,
                            fontWeight: FontWeight.w600,
                            color: CommonColors.trek_route_color,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          boarding.city?.cityName != null &&
                                  boarding.city!.cityName!.isNotEmpty
                              ? '${boarding.city?.cityName} — ${boarding.destination ?? '-'}'
                              : boarding.destination ?? '-',
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s10,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.blackColor,
                          ),
                        ),
                        Text(
                          _formatDateTime(boarding.dateTime)['time'] ?? '-',
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s9,
                            color: CommonColors.cFF6B7280,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
          ],

          // Route items
          if (visible.isNotEmpty)
            ...visible.asMap().entries.map((entry) {
              final idx       = entry.key;
              final stop      = entry.value;
              final isLast    = idx == visible.length - 1;
              final isSecond  = idx == 1;
              final hasDots   = !showFullRoute && isSecond && hidden.isNotEmpty;
              return _buildRouteItem(
                stop, isLast,
                showDottedLine: hasDots,
                firstRouteName: firstName,
              );
            }),

          // Toggle
          if (routeList.length > 3)
            Center(
              child: TextButton(
                onPressed: () => setState(() => showFullRoute = !showFullRoute),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      showFullRoute
                          ? 'Hide trek route'
                          : 'View all trek route',
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s10,
                        fontWeight: FontWeight.w600,
                        color: CommonColors.trek_route_color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      showFullRoute
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: CommonColors.trek_route_color,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRouteItem(
    TrekStages stop,
    bool isLast, {
    bool showDottedLine = false,
    String? firstRouteName,
  }) {
    final fmt    = _formatDateTime(stop.dateTime);
    final label  = isLast && firstRouteName != null
        ? firstRouteName
        : (stop.isBoardingPoint == true
            ? (stop.city?.cityName ?? '')
            : (stop.destination ?? ''));

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time column
            SizedBox(
              width: 18.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fmt['time'] ?? '',
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s9,
                      color: CommonColors.cFF6B7280,
                    ),
                  ),
                  Text(
                    fmt['date'] ?? '',
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s8,
                      color: CommonColors.grey_AEAEAE,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 3.w),
            // Dot + line
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLast
                        ? CommonColors.materialRed
                        : CommonColors.trek_route_color,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 48,
                    decoration: BoxDecoration(
                      color: CommonColors.trekroutecolorlight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 3.w),
            // Label + transport
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s10,
                            fontWeight: FontWeight.w600,
                            color: CommonColors.blackColor,
                          ),
                        ),
                      ),
                      if (stop.meansOfTransport != null &&
                          stop.meansOfTransport!.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.2.h),
                          decoration: BoxDecoration(
                            color: CommonColors.cFFE6F5F3,
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          child: Text(
                            stop.meansOfTransport!,
                            textScaler: const TextScaler.linear(1.0),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s7,
                              color: CommonColors.cFF0F7B6C,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: isLast ? 0 : 1.h),
                ],
              ),
            ),
          ],
        ),
        // Dotted gap
        if (showDottedLine)
          Row(
            children: [
              SizedBox(width: 21.w + 6),
              Column(
                children: List.generate(
                  3,
                  (i) => Container(
                    width: 2,
                    height: 6,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: CommonColors.trekroutecolorlight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

