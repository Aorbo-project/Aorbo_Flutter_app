import 'dart:async';
import 'package:arobo_app/controller/coupon_controller.dart';
import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/screens/trek_details_screen.dart';
import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/common_trek_card.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/statefullwrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:arobo_app/models/discount_card_model.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_discount_card.dart';
import 'package:arobo_app/utils/common_filter_bar.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import 'package:sizer/sizer.dart';
import '../freezed_models/treks/treks_model_data.dart';
import '../models/coupon_code/coupon_code_model.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS — matches app-wide pattern
// ─────────────────────────────────────────────
class _SSC {
  static const bg = Color(0xFFF4F7FF);
  static const cardBg = Color(0xFFFFFFFF);
  static const ink = Color(0xFF0F172A);
  static const inkMid = Color(0xFF64748B);
  static const inkLight = Color(0xFFADB5BD);
  static const accent = Color(0xFF3B5BDB);
  static const accentLight = Color(0xFFEEF2FF);
  static const border = Color(0xFFE9ECEF);
  static const shadow = Color(0x08000000);
  static const groupBorder = Color(0xFFE2E8F0);
  static const filterBarBg = Color(0xFFFFFFFF);
}

// ─────────────────────────────────────────────
//  STICKY FILTER BAR DELEGATE
//  FIX: shouldRebuild uses list equality not reference equality
// ─────────────────────────────────────────────
class _StickyFilterBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final List<String> activeFilters;
  final Function(String) onFilterRemoved;
  final double screenHeight;

  const _StickyFilterBarDelegate({
    required this.child,
    required this.activeFilters,
    required this.onFilterRemoved,
    required this.screenHeight,
  });

  double get _filterBarH => (screenHeight * 0.04) + 18;
  static const double _chipBarH = 44;

  @override
  double get minExtent => _filterBarH;

  @override
  double get maxExtent =>
      activeFilters.isEmpty ? _filterBarH : _filterBarH + _chipBarH;

  @override
  // FIX: was comparing list references — now compares contents
  bool shouldRebuild(_StickyFilterBarDelegate old) =>
      old.activeFilters.length != activeFilters.length ||
      old.screenHeight != screenHeight ||
      !_listsEqual(old.activeFilters, activeFilters);

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlaps) {
    return Container(
      color: _SSC.filterBarBg,
      child: Column(
        children: [
          child,
          if (activeFilters.isNotEmpty)
            Container(
              height: _chipBarH,
              decoration: BoxDecoration(
                color: _SSC.filterBarBg,
                border: Border(
                  bottom: BorderSide(color: _SSC.border, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: activeFilters.length,
                      separatorBuilder: (_, __) => SizedBox(width: 2.w),
                      itemBuilder: (_, i) {
                        return GestureDetector(
                          onTap: () => onFilterRemoved(activeFilters[i]),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _SSC.accentLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _SSC.accent.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  activeFilters[i],
                                  textScaler: const TextScaler.linear(1.0),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: FontSize.s9,
                                    fontWeight: FontWeight.w500,
                                    color: _SSC.accent,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.close_rounded,
                                    size: 13, color: _SSC.accent),
                              ],
                            ),
                          ),
                        );
                      },
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

// ─────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────
class SearchSummaryScreen extends StatefulWidget {
  const SearchSummaryScreen({super.key});

  @override
  State<SearchSummaryScreen> createState() => _SearchSummaryScreenState();
}

class _SearchSummaryScreenState extends State<SearchSummaryScreen>
    with SingleTickerProviderStateMixin {
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final TrekController _trekC = Get.find<TrekController>();
  final CouponController _couponC = Get.find<CouponController>();

  int _selectedNavIndex = 0;
  bool _isGroupBooking = false;
  bool _isUserInteractingCoupons = false;

  // FIX: single scroll controller — original had TWO controllers passed to
  // nested scrollables which caused jumpy/conflicting scroll behaviour
  final ScrollController _scrollController = ScrollController();

  // FIX: separate PageController with stable initial page
  final PageController _couponPageController = PageController(
    viewportFraction: 0.80,
    initialPage: 10000, // large offset so left-scroll is always possible
  );

  Timer? _couponTimer;

  List<String> activeFilters = [];

  final GlobalKey<CommonFilterBarState> _filterBarKey =
      GlobalKey<CommonFilterBarState>();

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // ── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void deactivate() {
    _couponTimer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _couponTimer?.cancel();
    _couponPageController.dispose();
    _scrollController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Coupon auto-scroll ──────────────────────────────────────────────────

  void _startCouponAutoScroll(int totalCoupons) {
    _couponTimer?.cancel();
    if (totalCoupons <= 1) return;
    _couponTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      // FIX: guard mounted + hasClients before animating
      if (!_isUserInteractingCoupons &&
          mounted &&
          _couponPageController.hasClients) {
        final next = (_couponPageController.page?.round() ?? 0) + 1;
        _couponPageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // ── Date helpers ────────────────────────────────────────────────────────

  DateTime? _parseDate(String? date) {
    if (date == null || date.trim().isEmpty) return null;
    try {
      if (date.contains('/')) return DateFormat('dd/MM/yyyy').parse(date);
      if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(date)) {
        return DateTime.parse(date);
      }
      return DateFormat('dd MMM yyyy').parse(date);
    } catch (_) {
      return null;
    }
  }

  String _formattedDate(String raw) {
    final d = _parseDate(raw);
    if (d == null) return raw;
    return '${DateFormat('d').format(d)} ${DateFormat('MMM').format(d)}';
  }

  String _formattedWeekday(String raw) {
    final d = _parseDate(raw);
    if (d == null) return '';
    return DateFormat('EEE').format(d).toLowerCase();
  }

  // ── Filter logic ────────────────────────────────────────────────────────

  void _applyFilters(List<String> filters) {
    // FIX: update local state so chip bar rebuilds
    if (mounted) setState(() => activeFilters = List.from(filters));
  }

  void _removeFilter(String filter) {
    if (!activeFilters.contains(filter)) return;
    setState(() => activeFilters.remove(filter));
    // FIX: only call updateFilters if state is still mounted
    final barState = _filterBarKey.currentState;
    if (barState != null) barState.updateFilters(activeFilters);
  }

  // ── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dateText = _dashboardC.dateController.value.text;
    final fromText = _dashboardC.fromController.value.text;
    final toText = _dashboardC.toController.value.text;

    return StatefulWrapper(
      onInit: () async {
        // FIX: fetch coupons with actual trek ID
        await _couponC.fetchAdminCoupons(
            _dashboardC.selectedTrekId.value);

        // Scroll to top after init
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) _scrollController.jumpTo(0);
        });
      },
      child: Scaffold(
        backgroundColor: _SSC.bg,
        appBar: _buildAppBar(fromText, toText, dateText),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              // FIX: pagination trigger — was using print, now extensible
              if (n.metrics.pixels >=
                  n.metrics.maxScrollExtent - 300) {
                // TODO: trigger next page load here
              }
              return false;
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Non-sticky header content ───────────────────────
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildGroupBookingBanner(),
                      const SizedBox(height: 12),
                      _buildCouponCarousel(),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),

                // ── Sticky filter bar ───────────────────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyFilterBarDelegate(
                    activeFilters: activeFilters,
                    onFilterRemoved: _removeFilter,
                    screenHeight: MediaQuery.of(context).size.height,
                    child: _buildFilterBar(),
                  ),
                ),

                // ── Trek list ───────────────────────────────────────
                _buildTrekList(dateText),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
      String from, String to, String dateText) {
    return AppBar(
      backgroundColor: _SSC.cardBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: _SSC.ink),
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _SSC.border),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // From → To
          Row(
            children: [
              if (from.isNotEmpty)
                Flexible(
                  child: Text(
                    from,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.w700,
                      color: _SSC.ink,
                    ),
                  ),
                ),
              if (from.isNotEmpty && to.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward_rounded,
                      color: _SSC.inkLight, size: 16),
                ),
              if (to.isNotEmpty)
                Flexible(
                  child: Text(
                    to,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.w700,
                      color: _SSC.ink,
                    ),
                  ),
                ),
            ],
          ),
          // Date subtitle
          if (dateText.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 11, color: _SSC.inkLight),
                const SizedBox(width: 4),
                Text(
                  _formattedDate(dateText),
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s10,
                    fontWeight: FontWeight.w400,
                    color: _SSC.inkMid,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${_formattedWeekday(dateText)})',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s10,
                    color: _SSC.inkLight,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Group booking banner ─────────────────────────────────────────────────
  Widget _buildGroupBookingBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
        decoration: BoxDecoration(
          color: _SSC.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _SSC.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: _SSC.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.only(left: 4.w, right: 2.w, top: 1.h, bottom: 1.h),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _SSC.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SvgPicture.asset(
                  CommonImages.group,
                  width: 18,
                  height: 18,
                  // FIX: colorFilter instead of deprecated color param
                  colorFilter: ColorFilter.mode(
                      _SSC.accent, BlendMode.srcIn),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking for Groups',
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w600,
                      color: _SSC.ink,
                    ),
                  ),
                  Text(
                    'Get exclusive deals for 4+ members',
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s8,
                      color: _SSC.inkMid,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                // TODO: view more group booking info
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'View more',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: _SSC.accent,
                    fontSize: FontSize.s9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch.adaptive(
                // ORIGINAL LOGIC
                activeColor: CommonColors.whiteColor,
                activeTrackColor: _SSC.accent,
                inactiveTrackColor: _SSC.border,
                inactiveThumbColor: _SSC.inkLight,
                value: _isGroupBooking,
                onChanged: (val) => setState(() => _isGroupBooking = val),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Coupon carousel ──────────────────────────────────────────────────────
  Widget _buildCouponCarousel() {
    return Obx(() {
      final isLoading = _couponC.adminCouponsObserver.value.maybeWhen(
        loading: (_) => true,
        orElse: () => false,
      );

      // FIX: proper null-safe extraction — original had wrong cast pattern
      final coupons = _couponC.adminCouponsObserver.value.maybeWhen(
        success: (data) {
          if (data is CouponCodeModel) return data.data ?? <CouponCardData>[];
          return <CouponCardData>[];
        },
        error: (_) => <CouponCardData>[],
        orElse: () => List.generate(3, (_) => CouponCardData()),
      );

      // FIX: don't show carousel if no coupons and not loading
      if (!isLoading && coupons.isEmpty) return const SizedBox.shrink();

      // Start auto-scroll once we know the count
      if (!isLoading && coupons.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => _startCouponAutoScroll(coupons.length));
      }

      return SizedBox(
        height: 18.h,
        child: Listener(
          onPointerDown: (_) {
            _isUserInteractingCoupons = true;
            _couponTimer?.cancel();
          },
          onPointerUp: (_) {
            _isUserInteractingCoupons = false;
            _startCouponAutoScroll(coupons.length);
          },
          onPointerCancel: (_) {
            _isUserInteractingCoupons = false;
            _startCouponAutoScroll(coupons.length);
          },
          child: PageView.builder(
            controller: _couponPageController,
            // FIX: null itemCount = infinite; when loading show fixed 3
            itemCount: isLoading ? 3 : null,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final coupon = isLoading
                  ? CouponCardData()
                  : coupons[index % coupons.length];

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                child: CommonDiscountCard(
                  title: coupon.title ?? '',
                  subtitle: coupon.description ?? '',
                  gradient: coupon.gradient,
                  textColour: coupon.textColour ?? '#3B5BDB',
                  code: coupon.code ?? '',
                  offerAmount: coupon.discountValue ?? '',
                  imagePath: coupon.imagePath ??
                      'https://i.pinimg.com/originals/86/b5/3d/86b53d90fbd279ea28d04099ff7518f0.png',
                  imageHeight: 30,
                  detailedDescription: coupon.description ?? '',
                  howToApply: '',
                  termsAndConditions:
                      coupon.termsAndConditions?.join('\n'),
                  footerNote: '',
                ).withShimmerAi(loading: isLoading),
              );
            },
          ),
        ),
      );
    });
  }

  // ── Filter bar ──────────────────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _SSC.filterBarBg,
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          height: 4.h,
          child: CommonFilterBar(
            key: _filterBarKey,
            onFiltersChanged: (filters) {
              _applyFilters(filters);
              // FIX: only jump if controller is attached
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(0);
              }
            },
          ),
        ),
      ),
    );
  }

  // ── Trek list sliver ────────────────────────────────────────────────────
  Widget _buildTrekList(String dateText) {
    return Obx(() {
      final isLoading =
          _trekC.treksResponseObserver.value.data.value.maybeWhen(
        loading: (_) => true,
        orElse: () => false,
      );

      // FIX: safe extraction from nested observer
      final treks =
          _trekC.treksResponseObserver.value.data.value.maybeWhen(
        success: (data) {
          if (data is FetchTreksResponseModel) return data.data ?? <TrekData>[];
          return <TrekData>[];
        },
        error: (_) => <TrekData>[],
        // Show 4 shimmer placeholders while loading
        orElse: () => List.generate(4, (_) => const TrekData()),
      );

      // Empty state — not loading and no treks
      if (!isLoading && treks.isEmpty) {
        return SliverFillRemaining(
          child: _buildEmptyState(dateText),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Bottom padding after last item
            if (index == treks.length) {
              return const SizedBox(height: 40);
            }

            final trek = treks[index];

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              // FIX: stagger first 6 items only to avoid rebuild cost
              duration: Duration(
                  milliseconds: 250 + (index.clamp(0, 5) * 60)),
              curve: Curves.easeOutCubic,
              builder: (ctx, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 16 * (1 - value)),
                  child: child,
                ),
              ),
              child: Container(
                margin: EdgeInsets.only(
                  top: index == 0 ? 2.h : 1.5.h,
                  left: 0,
                  right: 0,
                ),
                child: CommonTrekCard(
                  trek: trek,
                  // Pass route from DashboardController
                  fromLocation:
                      _dashboardC.fromController.value.text,
                  toLocation:
                      _dashboardC.toController.value.text,
                  onTap: () async {
                    // ORIGINAL LOGIC
                    _trekC.trekDetailId.value = trek.id ?? 0;
                    await _trekC.trekDetail(
                        batchId: trek.batchInfo?.id ?? 0);
                    Get.to(() => TrekDetailsScreen(trek: trek));
                  },
                ).withShimmerAi(loading: isLoading),
              ),
            );
          },
          // +1 for bottom spacing item
          childCount: treks.isEmpty ? 0 : treks.length + 1,
        ),
      );
    });
  }

  // ── Empty state ─────────────────────────────────────────────────────────
  Widget _buildEmptyState(String dateText) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: _SSC.accentLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.hiking_rounded,
                  size: 10.w, color: _SSC.accent),
            ),
            SizedBox(height: 2.h),
            Text(
              'No treks available',
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s15,
                fontWeight: FontWeight.w700,
                color: _SSC.ink,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              dateText.isNotEmpty
                  ? 'for ${_formattedDate(dateText)}'
                  : 'for this route',
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s11,
                color: _SSC.inkMid,
              ),
            ),
            SizedBox(height: 0.6.h),
            Text(
              'Try selecting a different date or route',
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                color: _SSC.inkLight,
              ),
            ),
            SizedBox(height: 3.h),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 6.w, vertical: 1.2.h),
                decoration: BoxDecoration(
                  color: _SSC.accent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _SSC.accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Change search',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}