import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../freezed_models/treks/trek_detail_model.dart';
import '../freezed_models/treks/treks_model_data.dart';
import '../utils/common_colors.dart';
import '../utils/common_images.dart';
import '../utils/common_images_card.dart';
import '../utils/common_trek_details_bar.dart';
import '../utils/common_btn.dart';
import '../widgets/cancellation_policy_widget.dart';
import '../utils/ist_date_utils.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _C {
  static const bg = CommonColors.offWhiteColor;
  static const cardBg = CommonColors.whiteColor;
  static const ink = CommonColors.blackColor;
  static const inkMid = CommonColors.cFF6B7280;
  static const inkLight = CommonColors.grey_AEAEAE;
  static const brand = CommonColors.trek_route_color;
  static const teal = CommonColors.cFF0F7B6C;
  static const tealSoft = CommonColors.cFFE6F5F3;
  static const iconBadge = CommonColors.cFF111827;
  static const divider = CommonColors.trekroutecolorlight;
  static const shadow = CommonColors.c0A000000;
  static const routeLine = CommonColors.trekroutecolorlight;
  static const softTint = Color(0xFFF8F9FF);
  static const danger = CommonColors.cFFDC2626;
}

// ─────────────────────────────────────────────
//  STICKY HEADER DELEGATE
// ─────────────────────────────────────────────
class _StickyTrekDetailsBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyTrekDetailsBarDelegate({required this.child});

  @override
  double get minExtent => 6.5.h;
  @override
  double get maxExtent => 6.5.h;
  @override
  bool shouldRebuild(_StickyTrekDetailsBarDelegate o) => true;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) =>
      child;
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
  final TrekController _trekC = Get.find<TrekController>();
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final UserController _userC = Get.find<UserController>();

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(8, (index) => GlobalKey());
  final GlobalKey _tabBarKey = GlobalKey();

  int _selectedTabIndex = 0;
  bool _showFullItinerary = false;
  bool _showFullFeatures = false;
  bool _showFullActivities = false;
  bool _showFullReviews = false;
  String _selectedSortOption = 'Recent Reviews';
  List<LatestReviews> _sortedReviews = [];
  bool _isUserScrolling = false;

  bool _isFav = false;

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
    return const LinearGradient(colors: [Color(0xFF19FA00), Color(0xFF4EE53D)]);
  }

  @override
  void initState() {
    super.initState();

    // Make sure the tab bar starts highlighted on whichever section is
    // actually rendered first, instead of always assuming "Trek Route".
    final visibility = _sectionVisibilityFlags();
    final firstVisible = visibility.indexWhere((v) => v);
    _selectedTabIndex = firstVisible == -1 ? 0 : firstVisible;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_onScroll);
    });
    _sortedReviews = _sortReviews(
      _trekC.trekDetailData.value.latestReviews ?? [],
      _selectedSortOption,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isFav = !_isFav;
    });
  }

  // ── Bulletproof Scroll Sync Logic ──────────
  void _onScroll() {
    if (!_scrollController.hasClients || _isUserScrolling) return;

    final RenderBox? tabBarBox =
        _tabBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (tabBarBox == null) return;

    final double headerBottom =
        tabBarBox.localToGlobal(Offset.zero).dy + tabBarBox.size.height;
    int activeIndex = _selectedTabIndex;

    for (int i = 0; i < _sectionKeys.length; i++) {
      final key = _sectionKeys[i];
      if (key.currentContext == null) continue;

      final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
      final Offset pos = box.localToGlobal(Offset.zero);

      if (pos.dy <= headerBottom + 10) {
        activeIndex = i;
      } else {
        break;
      }
    }

    if (activeIndex != _selectedTabIndex) {
      setState(() => _selectedTabIndex = activeIndex);
    }
  }

  void _scrollToSection(int index) {
    if (index < 0 || index >= _sectionKeys.length) return;

    // Some tabs correspond to sections that have no data and therefore
    // never get mounted (their GlobalKey has no context). Tapping those
    // used to silently do nothing — instead, redirect to the nearest
    // section that actually exists so the tap always has visible effect.
    int targetIndex = index;
    if (_sectionKeys[targetIndex].currentContext == null) {
      int forward = targetIndex + 1;
      int backward = targetIndex - 1;
      while (forward < _sectionKeys.length || backward >= 0) {
        if (forward < _sectionKeys.length &&
            _sectionKeys[forward].currentContext != null) {
          targetIndex = forward;
          break;
        }
        if (backward >= 0 && _sectionKeys[backward].currentContext != null) {
          targetIndex = backward;
          break;
        }
        forward++;
        backward--;
      }
    }

    if (_sectionKeys[targetIndex].currentContext == null) return;

    _isUserScrolling = true;
    setState(() => _selectedTabIndex = targetIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyContext = _sectionKeys[targetIndex].currentContext;
      final tabBarContext = _tabBarKey.currentContext;

      if (keyContext != null && tabBarContext != null) {
        final RenderBox box = keyContext.findRenderObject() as RenderBox;
        final RenderBox tabBarBox =
            tabBarContext.findRenderObject() as RenderBox;

        final double headerBottom =
            tabBarBox.localToGlobal(Offset.zero).dy + tabBarBox.size.height;
        final double target =
            _scrollController.offset +
            box.localToGlobal(Offset.zero).dy -
            headerBottom;

        final double maxExtent = _scrollController.position.hasContentDimensions
            ? _scrollController.position.maxScrollExtent
            : target.clamp(0.0, double.infinity);

        _scrollController
            .animateTo(
              target.clamp(0.0, maxExtent),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            )
            .then((_) {
              _isUserScrolling = false;
            });
      } else {
        _isUserScrolling = false;
      }
    });
  }

  List<LatestReviews> _sortReviews(List<LatestReviews> src, String option) {
    final list = [...src];
    DateTime parse(String? d) {
      if (d == null || d.isEmpty) return DateTime(1970);
      try {
        return DateTime.parse(d);
      } catch (_) {
        return DateTime(1970);
      }
    }

    switch (option) {
      case 'High to Low Ratings':
        list.sort((a, b) => (b.ratingValue ?? 0).compareTo(a.ratingValue ?? 0));
        break;
      case 'Low to High Ratings':
        list.sort((a, b) => (a.ratingValue ?? 0).compareTo(b.ratingValue ?? 0));
        break;
      case 'Solo Traveller':
        list.sort(
          (a, b) => (a.customerName ?? '').compareTo(b.customerName ?? ''),
        );
        break;
      case 'Recent Reviews':
      default:
        list.sort((a, b) => parse(b.createdAt).compareTo(parse(a.createdAt)));
        break;
    }
    return list;
  }

  IconData _getIconForPolicy(String name) {
    switch (name) {
      case 'Trekking Rules':
        return Icons.terrain_rounded;
      case 'Emergency Protocols':
        return Icons.health_and_safety_rounded;
      case 'Organizer Notes':
        return Icons.notes_rounded;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          if (_trekC.trekDetailData.value.images != null &&
              _trekC.trekDetailData.value.images!.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                width: 100.w,
                margin: EdgeInsets.only(top: 1.h, left: 4.w, bottom: 1.h),
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
                    images:
                        _trekC.trekDetailData.value.images
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
                key: _tabBarKey,
                width: 100.w,
                color: _C.cardBg,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Center(
                    child: CommonTrekDetailsBar(
                      // Keying on the selected index forces this widget to
                      // rebuild fresh whenever the active tab changes, so
                      // its highlighted state always matches scroll
                      // position / taps instead of getting stuck on the
                      // value it was first constructed with.
                      key: ValueKey(_selectedTabIndex),
                      onTabSelected: _scrollToSection,
                      initialIndex: _selectedTabIndex,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(delegate: SliverChildListDelegate(_buildSections())),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ─────────────────────────────────────────────
  //  PERSISTENT APP BAR
  // ─────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    final trek = widget.trek;

    return SliverAppBar(
      backgroundColor: _C.cardBg,
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: 8.h,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Icon(Icons.arrow_back_rounded, color: _C.ink, size: 6.w),
            ),
            SizedBox(width: 3.w),
            Container(
              width: 7.w,
              height: 7.w,
              decoration: const BoxDecoration(
                color: _C.tealSoft,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: trek?.vendorLogo?.isNotEmpty == true
                  ? CustomNetworkImage(
                      accessToken: Repository.token,
                      imageUrl: trek?.vendorLogo ?? "",
                      fit: BoxFit.cover,
                      width: 7.w,
                      height: 7.w,
                    )
                  : Center(
                      child: Text(
                        (trek?.companyName?.isNotEmpty == true
                                ? trek!.companyName![0]
                                : '?')
                            .toUpperCase(),
                        style: const TextStyle(
                          color: _C.teal,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trek?.name ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.0.sp,
                      fontWeight: FontWeight.w700,
                      color: _C.ink,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    trek?.companyName ??
                        trek?.businessName ??
                        trek?.vendor ??
                        '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9.0.sp,
                      fontWeight: FontWeight.w500,
                      color: _C.inkMid,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                final title = trek?.name ?? 'this amazing trek';
                final id = trek?.id ?? '';
                final link = '[aroboapp.com](https://aroboapp.com/trek/$id)';
                await Clipboard.setData(
                  ClipboardData(text: 'Check out $title: $link'),
                );
                Get.snackbar(
                  'Link Copied',
                  'Trek link copied to clipboard!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.black87,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(10),
                  borderRadius: 8,
                  duration: const Duration(seconds: 2),
                );
              },
              child: Icon(Icons.ios_share, color: _C.ink, size: 6.w),
            ),
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: _toggleFavorite,
              child: Icon(
                _isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: _isFav ? _C.teal : _C.ink,
                size: 6.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BOTTOM BAR
  // ─────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 1.5.h, 10.w, 2.5.h),
      decoration: BoxDecoration(
        color: _C.cardBg,
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: CommonButton(
        text: 'Continue',
        onPressed: () async {
          await _userC.getUserProfile();
          _trekC.trekBatchId.value = _trekC.trekDetailData.value.batchId ?? 0;
          Get.toNamed('/traveller-info');
        },
        gradient: CommonColors.filterGradient,
        textColor: CommonColors.whiteColor,
        height: 6.h,
        isFullWidth: false,
        width: 50.w,
        fontSize: 14.0.sp,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SECTION VISIBILITY (single source of truth)
  // ─────────────────────────────────────────────
  // Used by both the section builder and the initial tab selection so the
  // tab bar can never fall out of sync with what's actually rendered.
  List<bool> _sectionVisibilityFlags() {
    final detail = _trekC.trekDetailData.value;
    return [
      detail.trekStages?.isNotEmpty == true, // 0 - Trek Route
      detail.itineraryItems?.isNotEmpty == true, // 1 - Itinerary
      detail.activities?.isNotEmpty == true, // 2 - Activities
      detail.accommodations?.isNotEmpty == true, // 3 - Accommodation
      detail.inclusions?.isNotEmpty == true, // 4 - Inclusions/Exclusions
      detail.latestReviews?.isNotEmpty == true, // 5 - Reviews
      detail.cancellationPolicy?.rules?.isNotEmpty == true, // 6 - Cancellation
      (detail.trekkingRules?.isNotEmpty == true) ||
          (detail.emergencyProtocols?.isNotEmpty == true) ||
          (detail.organizerNotes?.isNotEmpty == true), // 7 - Other Policies
    ];
  }

  // ─────────────────────────────────────────────
  //  SECTIONS BUILDER
  // ─────────────────────────────────────────────
  List<Widget> _buildSections() {
    final detail = _trekC.trekDetailData.value;
    final visibility = _sectionVisibilityFlags();
    final widgets = <Widget>[];

    void addSection(int idx, Widget child) {
      if (!visibility[idx]) return;
      if (widgets.isNotEmpty) widgets.add(SizedBox(height: 1.5.h));
      widgets.add(_sectionWrapper(idx, child: child));
    }

    widgets.add(SizedBox(height: 1.h));

    addSection(0, TrekRouteTab(trek: detail));
    addSection(1, _buildItineraryTab());
    addSection(2, _buildActivitiesTab());
    addSection(3, _buildResortsTab());
    addSection(4, _buildFeaturesTab());
    addSection(5, _buildReviewsTab());
    addSection(6, _buildCancellationPoliciesTab());
    addSection(7, _buildOtherPoliciesTab());

    widgets.add(SizedBox(height: 3.h));
    return widgets;
  }

  Widget _sectionWrapper(int idx, {required Widget child}) {
    return Container(
      key: _sectionKeys[idx],
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: child,
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.07),
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
        Expanded(
          child: Text(
            title,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w700,
              color: _C.ink,
            ),
          ),
        ),
      ],
    );
  }

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
                fontSize: 10.0.sp,
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
            decoration: BoxDecoration(shape: BoxShape.circle, color: _C.brand),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10.0.sp,
                color: _C.ink,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageViewer(
    BuildContext context,
    List<String> images,
    int initial,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SizedBox(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationPoliciesTab() {
    final departure = _trekC.trekDetailData.value.departureDateTimeFromStages;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Cancellation Policy', Icons.gavel_rounded),
          SizedBox(height: 2.h),
          CancellationPolicyWidget(
            policy: _trekC.trekDetailData.value.cancellationPolicy,
            departureDate: departure.toString(),
          ),
        ],
      ),
    );
  }

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
            color: v > 0 ? CommonColors.completedColor2 : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  Widget _buildItineraryTab() {
    final items = _trekC.trekDetailData.value.itineraryItems;
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    final count = (_showFullItinerary || items.length <= 2) ? items.length : 2;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Itinerary', Icons.map_outlined),
          SizedBox(height: 2.h),
          ...List.generate(count, (idx) {
            final day = items[idx];
            final activities = day.activities ?? [];
            return Container(
              margin: EdgeInsets.only(bottom: 2.h),
              decoration: BoxDecoration(
                color: _C.softTint,
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(color: _C.brand.withValues(alpha: 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: _C.brand.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(3.w),
                        topRight: Radius.circular(3.w),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.5.w,
                            vertical: 0.3.h,
                          ),
                          decoration: BoxDecoration(
                            color: _C.brand,
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          child: Text(
                            'Day ${idx + 1}',
                            textScaler: const TextScaler.linear(1.0),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9.0.sp,
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
                              fontSize: 10.0.sp,
                              fontWeight: FontWeight.w500,
                              color: _C.brand,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 1.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...activities
                            .take(_showFullItinerary ? activities.length : 4)
                            .map((a) => _bulletItem(a)),
                        // FIX: this used to be a plain, non-interactive Text
                        // widget, so tapping "+N more activities" (e.g. "+1
                        // more activities") did nothing. It's now wrapped in
                        // an InkWell that expands the itinerary.
                        if (!_showFullItinerary && activities.length > 4)
                          InkWell(
                            onTap: () =>
                                setState(() => _showFullItinerary = true),
                            borderRadius: BorderRadius.circular(2.w),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 3.w,
                                top: 0.3.h,
                                bottom: 0.3.h,
                              ),
                              child: Text(
                                '+ ${activities.length - 4} more '
                                '${activities.length - 4 == 1 ? 'activity' : 'activities'}',
                                textScaler: const TextScaler.linear(1.0),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 9.0.sp,
                                  color: _C.brand,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
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
            _toggleBtn(
              'itinerary',
              _showFullItinerary,
              () => setState(() => _showFullItinerary = !_showFullItinerary),
            ),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab() {
    final acts = _trekC.trekDetailData.value.activities;
    if (acts == null || acts.isEmpty) return const SizedBox.shrink();

    final count = (acts.length > 2 && !_showFullActivities) ? 2 : acts.length;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Activities', Icons.directions_walk_rounded),
          SizedBox(height: 2.h),
          ...List.generate(count, (i) => _bulletItem(acts[i].name ?? '')),
          if (acts.length > 2)
            _toggleBtn(
              'Activities',
              _showFullActivities,
              () => setState(() => _showFullActivities = !_showFullActivities),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesTab() {
    final allInc = _trekC.trekDetailData.value.inclusions;
    final allExc = _trekC.trekDetailData.value.exclusions;

    final inc = (_showFullFeatures || (allInc?.length ?? 0) <= 4)
        ? allInc
        : allInc?.take(4).toList();
    final exc = (_showFullFeatures || (allExc?.length ?? 0) <= 4)
        ? allExc
        : allExc?.take(4).toList();

    String asString(dynamic e) {
      if (e == null) return '-';
      if (e is String) return e;
      try {
        return (e.name ?? '-').toString();
      } catch (_) {
        return e.toString();
      }
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Inclusions & Exclusions', Icons.checklist_rounded),
          SizedBox(height: 2.h),
          if (inc != null && inc.isNotEmpty) ...[
            _subLabel('Inclusions', _C.teal),
            SizedBox(height: 1.h),
            ...inc.map((e) => _checkItem(asString(e), included: true)),
            SizedBox(height: 2.h),
          ],
          if (exc != null && exc.isNotEmpty) ...[
            _subLabel('Exclusions', CommonColors.cFFDC2626),
            SizedBox(height: 1.h),
            ...exc.map((e) => _checkItem(asString(e), included: false)),
          ],
          if ((allInc?.length ?? 0) > 4 || (allExc?.length ?? 0) > 4)
            _toggleBtn(
              'Features',
              _showFullFeatures,
              () => setState(() => _showFullFeatures = !_showFullFeatures),
            ),
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
            fontSize: 12.0.sp,
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
              color: included ? _C.tealSoft : CommonColors.cFFFFE4E4,
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
                fontSize: 10.0.sp,
                color: _C.ink,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            final i = entry.key;
            final acc = entry.value;
            final isLast = i == accs.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: _C.brand.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _C.brand.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'D${i + 1}',
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 8.0.sp,
                            fontWeight: FontWeight.w700,
                            color: _C.brand,
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(width: 1.5, height: 5.h, color: _C.divider),
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
                            fontSize: 11.0.sp,
                            fontWeight: FontWeight.w600,
                            color: _C.ink,
                          ),
                        ),
                        SizedBox(height: 0.3.h),
                        Row(
                          children: [
                            Icon(
                              Icons.hotel_rounded,
                              size: 3.5.w,
                              color: _C.inkLight,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              acc.type ?? '-',
                              textScaler: const TextScaler.linear(1.0),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9.0.sp,
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
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    final reviews = _trekC.trekDetailData.value.latestReviews;
    if (reviews == null || reviews.isEmpty) return const SizedBox.shrink();
    final ratings = _trekC.trekDetailData.value.categoryRatings;

    final displayed = _showFullReviews
        ? _sortedReviews
        : _sortedReviews.take(5).toList();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Ratings & Reviews', Icons.star_rounded),
          SizedBox(height: 2.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 18.w,
                height: 18.w,
                decoration: BoxDecoration(
                  gradient: getRatingColor(
                    _trekC.trekDetailData.value.averageRating?.toDouble() ?? 0,
                  ),
                  borderRadius: BorderRadius.circular(3.w),
                ),
                child: Center(
                  child: Text(
                    (_trekC.trekDetailData.value.averageRating ?? 0.0)
                        .toStringAsFixed(1),
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20.0.sp,
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
                      rating:
                          _trekC.trekDetailData.value.averageRating
                              ?.toDouble() ??
                          0.0,
                      size: 5.w,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${_trekC.trekDetailData.value.totalReviews ?? 0} ratings  ·  ${_trekC.trekDetailData.value.reviewCommentsCount ?? 0} reviews',
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9.0.sp,
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
          Text(
            'People like',
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.0.sp,
              fontWeight: FontWeight.w600,
              color: _C.ink,
            ),
          ),
          SizedBox(height: 1.5.h),
          ...[
            {
              'label': 'Safety & Security',
              'value': (ratings?.safetySecurity ?? 0.0).toDouble(),
            },
            {
              'label': 'Organizer Manner',
              'value': (ratings?.organizerManner ?? 0.0).toDouble(),
            },
            {
              'label': 'Trek Planning',
              'value': (ratings?.trekPlanning ?? 0.0).toDouble(),
            },
            {
              'label': 'Women Safety',
              'value': (ratings?.womenSafety ?? 0.0).toDouble(),
            },
          ].map(
            (item) =>
                _ratingBar(item['label'] as String, item['value'] as double),
          ),
          SizedBox(height: 2.h),
          Divider(color: _C.divider, height: 1),
          SizedBox(height: 2.h),
          Text(
            'Sort by',
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.0.sp,
              fontWeight: FontWeight.w600,
              color: _C.ink,
            ),
          ),
          SizedBox(height: 1.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(right: 2.w),
            child: Row(
              children:
                  [
                        'Recent Reviews',
                        'Solo Traveller',
                        'High to Low Ratings',
                        'Low to High Ratings',
                      ]
                      .map((t) => _buildSortButton(t, t == _selectedSortOption))
                      .toList(),
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 20.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: displayed.length,
              itemBuilder: (_, i) => _reviewCard(displayed[i]),
            ),
          ),
          if (_sortedReviews.length > 5)
            _toggleBtn(
              'Reviews',
              _showFullReviews,
              () => setState(() => _showFullReviews = !_showFullReviews),
            ),
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
                fontSize: 9.0.sp,
                color: _C.inkMid,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (value / 5.0).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: _C.divider,
                valueColor: AlwaysStoppedAnimation<Color>(
                  CommonColors.completedColor2,
                ),
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
              fontSize: 9.0.sp,
              fontWeight: FontWeight.w600,
              color: _C.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(LatestReviews review) {
    String dateStr = '-';
    if (review.createdAt != null && review.createdAt!.isNotEmpty) {
      try {
        dateStr = ISTDateUtils.formatDate(review.createdAt!);
      } catch (_) {
        dateStr = review.createdAt!;
      }
    }

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
            color: _C.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: _C.brand.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (review.customerName?.isNotEmpty == true)
                            ? review.customerName![0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.0.sp,
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
                          fontSize: 10.0.sp,
                          fontWeight: FontWeight.w600,
                          color: _C.ink,
                        ),
                      ),
                      Text(
                        dateStr,
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8.0.sp,
                          color: _C.inkLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                decoration: BoxDecoration(
                  gradient: getRatingColor(
                    (review.ratingValue ?? 0.0).toDouble(),
                  ),
                  borderRadius: BorderRadius.circular(1.5.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${review.ratingValue}',
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9.0.sp,
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
                fontSize: 9.0.sp,
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
      onTap: () => setState(() {
        _selectedSortOption = text;
        _sortedReviews = _sortReviews(
          _trekC.trekDetailData.value.latestReviews ?? [],
          text,
        );
      }),
      child: Container(
        margin: EdgeInsets.only(right: 2.w),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: isSelected ? _C.brand.withValues(alpha: 0.1) : _C.cardBg,
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
            fontSize: 9.0.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? _C.brand : _C.ink,
          ),
        ),
      ),
    );
  }

  Widget _buildOtherPoliciesTab() {
    final rules = _trekC.trekDetailData.value.trekkingRules;
    final emergency = _trekC.trekDetailData.value.emergencyProtocols;
    final notes = _trekC.trekDetailData.value.organizerNotes;

    if ((rules == null || rules.isEmpty) &&
        (emergency == null || emergency.isEmpty) &&
        (notes == null || notes.isEmpty)) {
      return const SizedBox.shrink();
    }

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
        color: _C.softTint,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: _C.brand.withValues(alpha: 0.12)),
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
                  fontSize: 11.0.sp,
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
              fontSize: 9.0.sp,
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
//  TREK ROUTE TAB
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

  List<TrekStages> _dedupeStages(List<TrekStages> stages) {
    final seen = <String>{};
    return stages.where((s) {
      if (s.stageName != 'meeting' && s.stageName != 'trek_point') return true;
      final key = '${s.destination ?? ''}|${s.dateTime ?? ''}';
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TrekController>();
    final trek = ctrl.trekDetailData.value;
    final routeList = _dedupeStages(trek.trekStages ?? []);
    final split = _splitRouteList(routeList);
    final visible = split[0];
    final hidden = split[1];

    final boarding = routeList.isNotEmpty
        ? routeList.firstWhere(
            (s) => s.isBoardingPoint == true,
            orElse: () => routeList.first,
          )
        : null;
    final firstName = routeList.isNotEmpty
        ? (routeList.first.isBoardingPoint == true
              ? (routeList.first.city?.cityName ?? '')
              : (routeList.first.destination ?? ''))
        : '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9.w,
                height: 9.w,
                decoration: BoxDecoration(
                  color: _C.iconBadge,
                  borderRadius: BorderRadius.circular(2.5.w),
                ),
                child: Center(
                  child: Icon(
                    Icons.alt_route_rounded,
                    color: Colors.white,
                    size: 4.5.w,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Trek Route',
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w700,
                  color: _C.ink,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (boarding != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
              decoration: BoxDecoration(
                color: _C.brand.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(color: _C.brand.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: _C.brand,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.flag_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
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
                            fontSize: 8.0.sp,
                            fontWeight: FontWeight.w600,
                            color: _C.brand,
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
                            fontSize: 10.0.sp,
                            fontWeight: FontWeight.w500,
                            color: _C.ink,
                          ),
                        ),
                        Text(
                          _formatDateTime(boarding.dateTime)['time'] ?? '-',
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9.0.sp,
                            color: _C.inkMid,
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
          if (visible.isNotEmpty)
            ...visible.asMap().entries.map((entry) {
              final idx = entry.key;
              final stop = entry.value;
              final isLast = idx == visible.length - 1;
              final isSecond = idx == 1;
              final hasDots = !showFullRoute && isSecond && hidden.isNotEmpty;
              return _buildRouteItem(
                stop,
                isLast,
                showDottedLine: hasDots,
                firstRouteName: firstName,
              );
            }),
          if (routeList.length > 3)
            Center(
              child: TextButton(
                onPressed: () => setState(() => showFullRoute = !showFullRoute),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      showFullRoute ? 'Hide trek route' : 'View all trek route',
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.0.sp,
                        fontWeight: FontWeight.w600,
                        color: _C.brand,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      showFullRoute
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: _C.brand,
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
    final fmt = _formatDateTime(stop.dateTime);
    final label = isLast && firstRouteName != null
        ? firstRouteName
        : (stop.isBoardingPoint == true
              ? (stop.city?.cityName ?? '')
              : (stop.destination ?? ''));

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      fontSize: 9.0.sp,
                      color: _C.inkMid,
                    ),
                  ),
                  Text(
                    fmt['date'] ?? '',
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8.0.sp,
                      color: _C.inkLight,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 3.w),
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLast ? CommonColors.materialRed : _C.brand,
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
                      color: _C.routeLine,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 3.w),
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
                            fontSize: 10.0.sp,
                            fontWeight: FontWeight.w600,
                            color: _C.ink,
                          ),
                        ),
                      ),
                      if (stop.meansOfTransport != null &&
                          stop.meansOfTransport!.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.2.h,
                          ),
                          decoration: BoxDecoration(
                            color: _C.tealSoft,
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          child: Text(
                            stop.meansOfTransport!,
                            textScaler: const TextScaler.linear(1.0),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 7.0.sp,
                              color: _C.teal,
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
        if (showDottedLine)
          Padding(
            padding: EdgeInsets.only(left: 21.w),
            child: Column(
              children: List.generate(
                3,
                (i) => Container(
                  width: 2,
                  height: 6,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: _C.routeLine,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
