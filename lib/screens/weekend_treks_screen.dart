import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/screens/trek_details_screen.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_trek_card.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import 'package:sizer/sizer.dart';

import '../freezed_models/treks/treks_model_data.dart';

class _W {
  static const bg        = Color(0xFFF4F7FF);
  static const cardBg    = CommonColors.whiteColor;
  static const ink       = CommonColors.cFF111827;
  static const inkMid    = CommonColors.cFF6B7280;
  static const inkLight  = CommonColors.grey_AEAEAE;
  static const teal      = CommonColors.appBgColor;
  static const tealSoft  = Color(0xFFE6F7F6);
  static const iconBadge = CommonColors.cFF111827;
  static const divider   = CommonColors.trekroutecolorlight;
  static const shadow    = CommonColors.c0A000000;
  static const brand     = CommonColors.lightBlueColor3;
}

class WeekendTreksScreen extends StatefulWidget {
  final String city;
  final String trek;
  final String date;
  final List<DateTime> weekendDates;

  const WeekendTreksScreen({
    super.key,
    required this.city,
    required this.trek,
    required this.date,
    required this.weekendDates,
  });

  @override
  State<WeekendTreksScreen> createState() => _WeekendTreksScreenState();
}

class _WeekendTreksScreenState extends State<WeekendTreksScreen>
    with SingleTickerProviderStateMixin {

  final ScrollController    _scrollController = ScrollController();
  final TrekController      _trekC            = Get.find<TrekController>();
  final DashboardController _dashboardC       = Get.find<DashboardController>();

  late final AnimationController _fadeCtrl;
  late final Animation<double>   _fadeAnim;

  // ── Local selected date — never touched by Obx ──
  String? _selectedDate;

  @override
  void initState() {
    super.initState();

    // Convert the initial date to yyyy-MM-dd so it matches
    // what the chip displays (same format as DateFormat output below)
    _selectedDate = TrekController.convertDateYYYYMMDD(widget.date);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _addData() async {
    final obs = _trekC.weekendTreksResponseObserver;
    if (obs.value.isPaginationCompleted || obs.value.isLoading) return;
    _trekC.fetchWeekendTreks(
      cityId:  widget.city,
      trekId:  widget.trek,
      date:    widget.date,
      refresh: false,
    );
  }

  // ── Converts a DateTime to the string the API expects ──
  String _fmt(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);

    return Scaffold(
      backgroundColor: _W.bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
              _addData();
            }
            return false;
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [

              // ── App bar ──────────────────────────────────────
              _buildAppBar(),

              // ── STABLE HEADER (outside Obx) ──────────────────
              // Date chips live here so they are NEVER rebuilt
              // by GetX and never disappear during loading.
              SliverToBoxAdapter(
                child: _buildStableDateChips(),
              ),

              // ── REACTIVE BODY (inside Obx) ───────────────────
              // Only the trek list + route strip rebuild on API changes.
              Obx(() {
                final state = _trekC
                    .weekendTreksResponseObserver.value.data.value;

                final isLoading = state.maybeWhen(
                  loading: (_) => true,
                  orElse:  ()  => false,
                );

                final treks = state.maybeWhen(
                  success: (r) =>
                      (r as FetchTreksResponseModel).data ?? <TrekData>[],
                  error:   (_) => <TrekData>[],
                  orElse:  ()  => [TrekData(), TrekData(), TrekData()],
                );

                final ctx = state.maybeWhen(
                  success: (r) =>
                      (r as FetchTreksResponseModel).searchContext,
                  orElse: () => null,
                );

                final isPaginating =
                    _trekC.weekendTreksResponseObserver.value.isLoading;

                return SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Route strip (only when data is ready)
                      if (ctx?.from != null || ctx?.to != null)
                        _buildRouteStrip(ctx),

                      // Section label
                      _buildSectionLabel(
                        'Available Treks',
                        treks.isEmpty && !isLoading ? 0 : treks.length,
                      ),

                      // Trek list
                      if (treks.isEmpty && !isLoading)
                        _buildEmptyState()
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
                          itemCount: treks.length,
                          itemBuilder: (_, i) {
                            final trek = treks[i];
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(
                                  milliseconds: 250 + (i.clamp(0, 5) * 60)),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, child) => Opacity(
                                opacity: v,
                                child: Transform.translate(
                                  offset: Offset(0, 16 * (1 - v)),
                                  child: child,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 2.h),
                                child: CommonTrekCard(
                                  trek: trek,
                                  fromLocation:
                                      _dashboardC.fromController.value.text,
                                  toLocation:
                                      _dashboardC.toController.value.text,
                                  onTap: () async {
                                    _trekC.trekDetailId.value = trek.id ?? 0;
                                    await _trekC.trekDetail(
                                        batchId: trek.batchInfo?.id ?? 0);
                                    Get.to(() =>
                                        TrekDetailsScreen(trek: trek));
                                  },
                                ).withShimmerAi(loading: isLoading),
                              ),
                            );
                          },
                        ),

                      // Pagination shimmer
                      if (isPaginating)
                        Padding(
                          padding: EdgeInsets.fromLTRB(1.w, 0, 1.w, 1.h),
                          child: CommonTrekCard(
                            trek: null,
                            onTap: () {},
                          ).withShimmerAi(loading: true),
                        ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  STABLE DATE CHIPS
  //  Driven by widget.weekendDates (constructor arg, immutable)
  //  and _selectedDate (local setState) — zero dependency on Obx
  // ─────────────────────────────────────────────────────────
  Widget _buildStableDateChips() {
    if (widget.weekendDates.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
          child: Text(
            'SELECT WEEKEND',
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s8,
              fontWeight: FontWeight.w700,
              color: _W.inkLight,
              letterSpacing: 1.0,
            ),
          ),
        ),
        SizedBox(
          height: 6.5.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: widget.weekendDates.length,
            itemBuilder: (_, i) {
              final dateStr = _fmt(widget.weekendDates[i]);
              // ── This is the only thing that drives highlight ──
              final isSel = _selectedDate == dateStr;

              return GestureDetector(
                onTap: () async {
                  // 1. Update highlight instantly via setState
                  setState(() => _selectedDate = dateStr);
                  // 2. Then fire the API
                  _dashboardC.dateController.value.text = dateStr;
                  await _trekC.fetchWeekendTreks(
                    cityId:  widget.city,
                    trekId:  widget.trek,
                    date:    dateStr,
                    refresh: true,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: 3.w),
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSel ? _W.teal : _W.cardBg,
                    borderRadius: BorderRadius.circular(3.w),
                    border: Border.all(
                      color: isSel ? _W.teal : _W.divider,
                      width: isSel ? 1.5 : 1,
                    ),
                    boxShadow: isSel
                        ? [
                            BoxShadow(
                              color: _W.teal.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: _W.shadow,
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Text(
                      dateStr,
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s10,
                        fontWeight: FontWeight.w600,
                        color: isSel ? Colors.white : _W.ink,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  APP BAR
  // ─────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: _W.cardBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: true,
      automaticallyImplyLeading: true,
      expandedHeight: 0,
      collapsedHeight: kToolbarHeight,
      iconTheme: const IconThemeData(color: _W.ink),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _W.divider),
      ),
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekend Treks',
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s13,
                  fontWeight: FontWeight.w700,
                  color: _W.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  ROUTE STRIP
  // ─────────────────────────────────────────────
  Widget _buildRouteStrip(SearchContextModel? ctx) {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: _W.cardBg,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: _W.divider),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, size: 4.w, color: _W.inkMid),
          SizedBox(width: 1.5.w),
          Expanded(
            child: RichText(
              textScaler: const TextScaler.linear(1.0),
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s10,
                  color: _W.inkMid,
                ),
                children: [
                  TextSpan(
                    text: ctx?.from ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: _W.ink),
                  ),
                  if (ctx?.to != null) ...[
                    const TextSpan(text: '  →  '),
                    TextSpan(
                      text: ctx?.to ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: _W.ink),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SECTION LABEL
  // ─────────────────────────────────────────────
  Widget _buildSectionLabel(String title, int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
      child: Row(
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(
              color: _W.iconBadge,
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: const Center(
              child: Icon(Icons.terrain_rounded, color: Colors.white, size: 13),
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            title,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s13,
              fontWeight: FontWeight.w700,
              color: _W.ink,
            ),
          ),
          const Spacer(),
          if (count > 0)
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.3.h),
              decoration: BoxDecoration(
                color: _W.tealSoft,
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Text(
                '$count found',
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s8,
                  fontWeight: FontWeight.w600,
                  color: _W.teal,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  EMPTY STATE
  // ─────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                  color: _W.tealSoft, shape: BoxShape.circle),
              child:
                  Icon(Icons.hiking_rounded, size: 10.w, color: _W.teal),
            ),
            SizedBox(height: 2.h),
            Text(
              'No treks this weekend',
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s14,
                fontWeight: FontWeight.w700,
                color: _W.ink,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              'Try a different date or route',
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                color: _W.inkMid,
              ),
            ),
            SizedBox(height: 3.h),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 6.w, vertical: 1.2.h),
                decoration: BoxDecoration(
                  color: _W.teal,
                  borderRadius: BorderRadius.circular(3.w),
                  boxShadow: [
                    BoxShadow(
                      color: _W.teal.withValues(alpha: 0.3),
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