import 'dart:async';

import 'package:arobo_app/controller/coupon_controller.dart';
import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/screens/trek_details_screen.dart';
import 'package:arobo_app/utils/common_discount_card.dart';
import 'package:arobo_app/utils/common_filter_bar.dart';
import 'package:arobo_app/utils/common_trek_card.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/statefullwrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import 'package:sizer/sizer.dart';

import '../freezed_models/treks/treks_model_data.dart';
import '../models/coupon_code/coupon_code_model.dart';
import '../models/discount_card_model.dart';
import '../utils/common_colors.dart';

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
  static const filterBarBg = Color(0xFFFFFFFF);
}

class _StickyFilterBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _StickyFilterBarDelegate({
    required this.child,
  });

  static const double barHeight = 56.0;

  @override
  double get minExtent => barHeight;

  @override
  double get maxExtent => barHeight;

  @override
  bool shouldRebuild(covariant _StickyFilterBarDelegate oldDelegate) => false;

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _SSC.filterBarBg,
      child: child,
    );
  }
}

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

  bool _isUserInteractingCoupons = false;
  bool _isGroupBooking = false;

  final ScrollController _scrollController = ScrollController();
  final PageController _couponPageController = PageController(
    viewportFraction: 0.80,
    initialPage: 10000,
  );

  Timer? _couponTimer;
  List<String> activeFilters = [];

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

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

  void _startCouponAutoScroll(int totalCoupons) {
    _couponTimer?.cancel();
    if (totalCoupons <= 1) return;

    _couponTimer = Timer.periodic(const Duration(seconds: 5), (_) {
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

  void _applyFilters(List<String> filters) {
    if (mounted) setState(() => activeFilters = List.from(filters));
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _dashboardC.dateController.value.text;
    final fromText = _dashboardC.fromController.value.text;
    final toText = _dashboardC.toController.value.text;

    return StatefulWrapper(
      onInit: () async {
        await _couponC.fetchAdminCoupons(_dashboardC.selectedTrekId.value);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
        });
      },
      child: Scaffold(
        backgroundColor: _SSC.bg,
        appBar: _buildAppBar(fromText, toText, dateText),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 300) {}
              return false;
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildCouponCarousel(),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyFilterBarDelegate(
                    child: _buildFilterBar(),
                  ),
                ),
                _buildTrekList(dateText),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String from, String to, String dateText) {
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
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _SSC.ink,
                    ),
                  ),
                ),
              if (from.isNotEmpty && to.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
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
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _SSC.ink,
                    ),
                  ),
                ),
            ],
          ),
          if (dateText.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 11, color: _SSC.inkLight),
                const SizedBox(width: 4),
                Text(
                  _formattedDate(dateText),
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
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
                    fontSize: 10,
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

  Widget _buildCouponCarousel() {
    return Obx(() {
      final isLoading = _couponC.adminCouponsObserver.value.maybeWhen(
        loading: (_) => true,
        orElse: () => false,
      );

      final coupons = _couponC.adminCouponsObserver.value.maybeWhen(
        success: (data) {
          if (data is CouponCodeModel) return data.data ?? <CouponCardData>[];
          return <CouponCardData>[];
        },
        error: (_) => <CouponCardData>[],
        orElse: () => List.generate(3, (_) => CouponCardData()),
      );

      if (!isLoading && coupons.isEmpty) return const SizedBox.shrink();

      if (!isLoading && coupons.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _startCouponAutoScroll(coupons.length),
        );
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
                  detailedDescription: coupon.detailedDescription,
                  howToApply: coupon.howToApply,
                  termsAndConditions: coupon.termsAndConditions,
                  footerNote: coupon.footerNote,
                  validUntil: coupon.validUntil,
                ).withShimmerAi(loading: isLoading),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: _StickyFilterBarDelegate.barHeight,
      child: CommonFilterBar(
        onFiltersChanged: (filters) {
          _applyFilters(filters);
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
        },
        onGroupBookingChanged: (value) {
          setState(() => _isGroupBooking = value);
        },
      ),
    );
  }

  Widget _buildTrekList(String dateText) {
    return Obx(() {
      final isLoading =
          _trekC.treksResponseObserver.value.data.value.maybeWhen(
        loading: (_) => true,
        orElse: () => false,
      );

     final treks =
    _trekC.treksResponseObserver.value.data.value.maybeWhen(
  success: (data) {
    if (data is FetchTreksResponseModel) {

      List<TrekData> filteredTreks =
          List<TrekData>.from(data.data ?? []);

      // ─────────────────────────────
      // POLICY FILTER
      // ─────────────────────────────
      if (activeFilters.contains('Flexible')) {
        filteredTreks = filteredTreks.where((trek) {
          return trek.cancellationPolicy?.title
                  ?.toLowerCase()
                  .contains('flexible') ==
              true;
        }).toList();
      }

      if (activeFilters.contains('Standard')) {
        filteredTreks = filteredTreks.where((trek) {
          return trek.cancellationPolicy?.title
                  ?.toLowerCase()
                  .contains('standard') ==
              true;
        }).toList();
      }

      if (activeFilters.contains('Strict')) {
        filteredTreks = filteredTreks.where((trek) {
          return trek.cancellationPolicy?.title
                  ?.toLowerCase()
                  .contains('strict') ==
              true;
        }).toList();
      }

      // ─────────────────────────────
      // RATING FILTER
      // ─────────────────────────────
      if (activeFilters.contains('4.5+ Stars')) {
        filteredTreks = filteredTreks.where((t) {
          return (t.rating ?? 0) >= 4.5;
        }).toList();
      }

      if (activeFilters.contains('4+ Stars')) {
        filteredTreks = filteredTreks.where((t) {
          return (t.rating ?? 0) >= 4;
        }).toList();
      }

      if (activeFilters.contains('3.5+ Stars')) {
        filteredTreks = filteredTreks.where((t) {
          return (t.rating ?? 0) >= 3.5;
        }).toList();
      }

      // ─────────────────────────────
      // SORTING
      // ─────────────────────────────
      if (activeFilters.contains('Price: Low → High')) {
        filteredTreks.sort((a, b) {
          final aPrice =
              double.tryParse(a.price ?? '0') ?? 0;
          final bPrice =
              double.tryParse(b.price ?? '0') ?? 0;
          return aPrice.compareTo(bPrice);
        });
      }

      if (activeFilters.contains('Price: High → Low')) {
        filteredTreks.sort((a, b) {
          final aPrice =
              double.tryParse(a.price ?? '0') ?? 0;
          final bPrice =
              double.tryParse(b.price ?? '0') ?? 0;
          return bPrice.compareTo(aPrice);
        });
      }

      if (activeFilters.contains('Top Rated')) {
        filteredTreks.sort((a, b) {
          return (b.rating ?? 0)
              .compareTo(a.rating ?? 0);
        });
      }

      return filteredTreks;
    }

    return <TrekData>[];
  },
        error: (_) => <TrekData>[],
        orElse: () => List.generate(4, (_) => const TrekData()),
      );

      if (!isLoading && treks.isEmpty) {
        return SliverFillRemaining(
          child: _buildEmptyState(dateText),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == treks.length) {
              return const SizedBox(height: 40);
            }

            final trek = treks[index];
            final animDelay = 250 + ((index.clamp(0, 5).toInt()) * 60);

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: animDelay),
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
                  fromLocation: _dashboardC.fromController.value.text,
                  toLocation: _dashboardC.toController.value.text,
                  onTap: () async {
                    _trekC.trekDetailId.value = trek.id ?? 0;
                    await _trekC.trekDetail(batchId: trek.batchInfo?.id ?? 0);
                    Get.to(() => TrekDetailsScreen(trek: trek));
                  },
                ).withShimmerAi(loading: isLoading),
              ),
            );
          },
          childCount: treks.isEmpty ? 0 : treks.length + 1,
        ),
      );
    });
  }

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
                fontSize: 15,
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
                fontSize: 11,
                color: _SSC.inkMid,
              ),
            ),
            SizedBox(height: 0.6.h),
            Text(
              'Try selecting a different date or route',
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9,
                color: _SSC.inkLight,
              ),
            ),
            SizedBox(height: 3.h),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.2.h),
                decoration: BoxDecoration(
                  color: _SSC.accent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _SSC.accent.withOpacity(0.3),
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
                    fontSize: 11,
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