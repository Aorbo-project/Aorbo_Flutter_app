import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';
import '../utils/common_booked_card.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _BkColors {
  static const bg = Color(0xFFF4F7FF);
  static const cardBg = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1A1D2E);
  static const inkMid = Color(0xFF6C7293);
  static const inkLight = Color(0xFFADB5BD);
  static const accent = Color(0xFF3B5BDB);
  static const accentLight = Color(0xFFEEF2FF);
  static const border = Color(0xFFE9ECEF);
  static const badgeBg = Color(0xFF111827);

  static const upcomingBg = Color(0xFFEEF2FF);
  static const upcomingFg = Color(0xFF3B5BDB);
  static const ongoingBg = Color(0xFFE6F5F3);
  static const ongoingFg = Color(0xFF0F7B6C);
  static const completedBg = Color(0xFFF0FDF4);
  static const completedFg = Color(0xFF16A34A);
  static const cancelledBg = Color(0xFFFEF2F2);
  static const cancelledFg = Color(0xFFDC2626);
}

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  // ── ALL ORIGINAL LOGIC UNTOUCHED ─────────────────────────────────────────
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  List<String> get _statusFilters => [
    'All Bookings',
    'upcoming',
    'completed',
    'ongoing',
    'cancelled',
  ];

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _dashboardC.selectedFilter.value = 'All Bookings';
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    _dashboardC.bookingList.clear();
    _dashboardC.getBookingHistory(isRefresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _dashboardC.hasMoreBookings.value) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await _dashboardC.getBookingHistory();
    setState(() => _isLoadingMore = false);
  }

  // ── STATUS HELPERS — ORIGINAL LOGIC ──────────────────────────────────────
  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Color _pillBg(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return _BkColors.upcomingBg;
      case 'ongoing':
        return _BkColors.ongoingBg;
      case 'completed':
        return _BkColors.completedBg;
      case 'cancelled':
        return _BkColors.cancelledBg;
      default:
        return _BkColors.accentLight;
    }
  }

  Color _pillFg(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return _BkColors.upcomingFg;
      case 'ongoing':
        return _BkColors.ongoingFg;
      case 'completed':
        return _BkColors.completedFg;
      case 'cancelled':
        return _BkColors.cancelledFg;
      default:
        return _BkColors.inkMid;
    }
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _BkColors.bg,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fade,
        child: Obx(() {
          if (_dashboardC.isLoadingBookingHistory.value &&
              _dashboardC.bookingList.isEmpty) {
            return _buildShimmerLoading();
          }

          if (_dashboardC.bookingList.isEmpty &&
              !_dashboardC.isLoadingBookingHistory.value) {
            return _buildEmptyState();
          }

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 4.h),
            itemCount:
                _dashboardC.bookingList.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _dashboardC.bookingList.length) {
                return _buildPaginationLoader();
              }
              final booking = _dashboardC.bookingList[index];
              return _buildBookingCard(booking, index);
            },
          );
        }),
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _BkColors.cardBg,
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: true,
      centerTitle: false,
      iconTheme: const IconThemeData(color: _BkColors.ink),
      title: Text(
        'My Bookings',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s15,
          fontWeight: FontWeight.w700,
          color: _BkColors.ink,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _BkColors.border),
      ),
      actions: [
        Obx(
          () => GestureDetector(
            onTap: () => _showFilterBottomSheet(context),
            child: Container(
              margin: EdgeInsets.only(right: 4.w),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
              decoration: BoxDecoration(
                color: _dashboardC.selectedFilter.value == 'All Bookings'
                    ? _BkColors.badgeBg
                    : _pillBg(_dashboardC.selectedFilter.value),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _dashboardC.selectedFilter.value == 'All Bookings'
                        ? 'Filter'
                        : _capitalize(_dashboardC.selectedFilter.value),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s9,
                      fontWeight: FontWeight.w600,
                      color: _dashboardC.selectedFilter.value == 'All Bookings'
                          ? Colors.white
                          : _pillFg(_dashboardC.selectedFilter.value),
                    ),
                  ),
                  SizedBox(width: 1.w),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 4.5.w,
                    color: _dashboardC.selectedFilter.value == 'All Bookings'
                        ? Colors.white
                        : _pillFg(_dashboardC.selectedFilter.value),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── BOOKING CARD ──────────────────────────────────────────────────────────
  Widget _buildBookingCard(dynamic booking, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + index * 50),
      curve: Curves.easeOutCubic,
      builder: (ctx, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: child,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 3.w),
        child: CommonBookedCard(
          booking: booking,
          onViewDetailsTap: () {
            final s = booking.status?.toLowerCase().trim();
            Get.toNamed(
              '/bookingsupcoming',
              arguments: {'booking': booking, 'status': s},
            );
          },
        ),
      ),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    final hasFilter = _dashboardC.selectedFilter.value != 'All Bookings';
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: const BoxDecoration(
                color: _BkColors.accentLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 10.w,
                color: _BkColors.accent,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              hasFilter
                  ? 'No ${_capitalize(_dashboardC.selectedFilter.value)} bookings'
                  : 'No bookings yet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s14,
                fontWeight: FontWeight.w700,
                color: _BkColors.ink,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              hasFilter
                  ? 'Try a different filter to see your bookings'
                  : 'Your upcoming treks will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                color: _BkColors.inkMid,
                height: 1.6,
              ),
            ),
            if (hasFilter) ...[
              SizedBox(height: 2.5.h),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _dashboardC.selectedFilter.value = 'All Bookings';
                    _dashboardC.bookingList.clear();
                  });
                  _dashboardC.getBookingHistory(isRefresh: true);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 1.3.h,
                  ),
                  decoration: BoxDecoration(
                    color: _BkColors.badgeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Clear filter',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── PAGINATION LOADER ─────────────────────────────────────────────────────
  Widget _buildPaginationLoader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: const Center(
        child: CircularProgressIndicator(
          color: _BkColors.accent,
          strokeWidth: 2.5,
        ),
      ),
    );
  }

  // ── SHIMMER LOADING ───────────────────────────────────────────────────────
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 4.h),
      itemCount: 5,
      itemBuilder: (_, i) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      decoration: BoxDecoration(
        color: _BkColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // Status strip shimmer
            Container(
              width: double.infinity,
              height: 4.5.h,
              color: _BkColors.border,
            ).withShimmerAi(loading: true),

            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 3, color: _BkColors.border),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 2.h,
                                  decoration: BoxDecoration(
                                    color: CommonColors.greyColorEBEBEB,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ).withShimmerAi(loading: true),
                              ),
                              SizedBox(width: 3.w),
                              Container(
                                width: 18.w,
                                height: 2.h,
                                decoration: BoxDecoration(
                                  color: CommonColors.greyColorEBEBEB,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ).withShimmerAi(loading: true),
                            ],
                          ),
                          SizedBox(height: 1.5.h),
                          Row(
                            children: [
                              Container(
                                width: 28.w,
                                height: 1.5.h,
                                decoration: BoxDecoration(
                                  color: CommonColors.greyColorEBEBEB,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ).withShimmerAi(loading: true),
                              SizedBox(width: 4.w),
                              Container(
                                width: 18.w,
                                height: 1.5.h,
                                decoration: BoxDecoration(
                                  color: CommonColors.greyColorEBEBEB,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ).withShimmerAi(loading: true),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 22.w,
                                    height: 1.5.h,
                                    decoration: BoxDecoration(
                                      color: CommonColors.greyColorEBEBEB,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ).withShimmerAi(loading: true),
                                  SizedBox(height: 0.5.h),
                                  Container(
                                    width: 14.w,
                                    height: 2.h,
                                    decoration: BoxDecoration(
                                      color: CommonColors.greyColorEBEBEB,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ).withShimmerAi(loading: true),
                                ],
                              ),
                              Container(
                                width: 28.w,
                                height: 4.5.h,
                                decoration: BoxDecoration(
                                  color: CommonColors.greyColorEBEBEB,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ).withShimmerAi(loading: true),
                            ],
                          ),
                        ],
                      ),
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

  // ── FILTER BOTTOM SHEET — ORIGINAL LOGIC ─────────────────────────────────
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: CommonColors.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.only(top: 1.5.h, bottom: 1.h),
              decoration: BoxDecoration(
                color: _BkColors.border,
                borderRadius: BorderRadius.circular(1.w),
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              child: Row(
                children: [
                  Container(
                    width: 9.w,
                    height: 9.w,
                    decoration: BoxDecoration(
                      color: _BkColors.badgeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.filter_list_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Filter Bookings',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.w700,
                      color: _BkColors.ink,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 1,
              color: CommonColors.greyColor.withValues(alpha: 0.2),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _statusFilters.length,
              itemBuilder: (context, index) {
                final filter = _statusFilters[index];
                final isSelected = _dashboardC.selectedFilter.value == filter;
                final dotColor = filter == 'All Bookings'
                    ? _BkColors.badgeBg
                    : _pillFg(filter);
                final rowBg = filter == 'All Bookings'
                    ? _BkColors.badgeBg.withValues(alpha: 0.06)
                    : _pillBg(filter).withValues(alpha: 0.3);

                return InkWell(
                  onTap: () async {
                    setState(() {
                      _dashboardC.selectedFilter.value = filter;
                      _dashboardC.bookingList.clear();
                    });
                    Navigator.pop(context);
                    _dashboardC.getBookingHistory(isRefresh: true);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 1.8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? rowBg : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: CommonColors.greyColor.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 2.5.w,
                          height: 2.5.w,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            filter == 'All Bookings'
                                ? 'All Bookings'
                                : _capitalize(filter),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected ? dotColor : _BkColors.ink,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: dotColor,
                            size: 5.5.w,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }
}
