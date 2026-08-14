import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../freezed_models/booking/booking_history_model.dart';
import '../utils/common_btn.dart';
import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS — FOREST THEME
// ─────────────────────────────────────────────
class _R {
  static const bg = Color(0xFFF7F9F4); // Soft sage white
  static const cardBg = CommonColors.whiteColor;
  static const ink = CommonColors.cFF111827;
  static const inkMid = CommonColors.cFF6B7280;
  static const inkLight = CommonColors.grey_AEAEAE;
  static const iconBadge = CommonColors.cFF111827;
  static const brand = AppColors.forest;
  static const brandDeep = AppColors.forestDeep;
  static const teal = CommonColors.cFF0F7B6C;
  static const tealSoft = CommonColors.cFFE6F5F3;
  static const divider = CommonColors.trekroutecolorlight;
  static const shadow = CommonColors.c0A000000;

  // Category accent colors — all tinted to feel cohesive with forest
  static const emerald = Color(0xFF10B981);
  static const sage = Color(0xFF84CC16);
  static const amber = Color(0xFFD97706);
  static const rose = Color(0xFFE11D48);

  static const softSage = Color(0xFFF0F9F4);
  static const softMoss = Color(0xFFF1F5E9);
  static const softAmber = Color(0xFFFEF3E2);
  static const softRose = Color(0xFFFDF2F8);

  static const ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandDeep, brand],
  );

  static const Map<int, Color> ratingColor = {
    1: Color(0xFFDC2626), // poor — red
    2: Color(0xFFEA580C), // fair — orange
    3: Color(0xFFD97706), // good — amber
    4: Color(0xFF65A30D), // great — lime
    5: Color(0xFF16A34A), // excellent — forest
  };

  static const Map<int, String> ratingLabel = {
    1: 'Poor',
    2: 'Fair',
    3: 'Good',
    4: 'Great',
    5: 'Excellent',
  };

  static const Map<int, IconData> ratingIcon = {
    1: Icons.sentiment_very_dissatisfied_rounded,
    2: Icons.sentiment_dissatisfied_rounded,
    3: Icons.sentiment_satisfied_rounded,
    4: Icons.sentiment_satisfied_alt_rounded,
    5: Icons.sentiment_very_satisfied_rounded,
  };
}

// ─────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────
class RateReviewScreen extends StatefulWidget {
  const RateReviewScreen({super.key});

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen>
    with TickerProviderStateMixin {
  final TrekController _trekC = Get.find<TrekController>();

  BookingHistoryData? booking;
  final dynamic arguments = Get.arguments;

  double selectedRating = 0;
  List<String> selectedCategories = [];

  final List<_CategoryItem> categories = const [
    _CategoryItem(
      name: 'Safety & Security',
      subtitle: 'Felt safe and well-protected',
      icon: Icons.shield_outlined,
      tint: _R.softSage,
      accent: _R.brand,
    ),
    _CategoryItem(
      name: 'Organizer Manner',
      subtitle: 'Helpful, respectful, professional',
      icon: Icons.support_agent_rounded,
      tint: _R.tealSoft,
      accent: _R.teal,
    ),
    _CategoryItem(
      name: 'Trek Planning',
      subtitle: 'Well-organized route and schedule',
      icon: Icons.map_outlined,
      tint: _R.softMoss,
      accent: _R.sage,
    ),
    _CategoryItem(
      name: 'Women Safety',
      subtitle: 'Comfortable and secure experience',
      icon: Icons.female_rounded,
      tint: _R.softRose,
      accent: _R.rose,
    ),
  ];

  late final List<AnimationController> _staggerCtrl;
  late final List<Animation<double>> _staggerFade;
  late final List<Animation<Offset>> _staggerSlide;

  static const int _sections = 3;

  late final List<AnimationController> _optionCtrl;
  late final List<Animation<double>> _optionScale;

  late final AnimationController _bottomCtrl;
  late final Animation<Offset> _bottomSlide;
  late final AnimationController _preRatingCtrl;

  @override
  void initState() {
    super.initState();

    double? preSelected;

    if (arguments is Map<String, dynamic>) {
      final argBooking = arguments['booking'];
      if (argBooking is BookingHistoryData) booking = argBooking;
      final pre = arguments['preSelectedRating'];
      if (pre is num) preSelected = pre.toDouble().clamp(1.0, 5.0);
    } else if (arguments is BookingHistoryData) {
      booking = arguments as BookingHistoryData;
    }

    _staggerCtrl = List.generate(
      _sections,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 480),
      ),
    );

    _staggerFade = _staggerCtrl
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();

    _staggerSlide = _staggerCtrl
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)),
        )
        .toList();

    for (int i = 0; i < _sections; i++) {
      Future.delayed(Duration(milliseconds: 80 + i * 80), () {
        if (mounted) _staggerCtrl[i].forward();
      });
    }

    _optionCtrl = List.generate(
      categories.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 140),
        lowerBound: 0,
        upperBound: 1,
      ),
    );

    _optionScale = _optionCtrl
        .map(
          (c) => Tween<double>(
            begin: 1.0,
            end: 0.97,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
        )
        .toList();

    _bottomCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _bottomSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _bottomCtrl, curve: Curves.easeOutCubic));

    _preRatingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    Future.delayed(const Duration(milliseconds: 360), () {
      if (mounted) _bottomCtrl.forward();
    });

    if (preSelected != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 320), () {
          if (!mounted) return;
          HapticFeedback.selectionClick();
          setState(() {
            selectedRating = preSelected!;
            _trekC.rating.value = selectedRating;
          });
          _preRatingCtrl.forward();
        });
      });
    }
  }

  @override
  void dispose() {
    for (final c in _staggerCtrl) c.dispose();
    for (final c in _optionCtrl) c.dispose();
    _bottomCtrl.dispose();
    _preRatingCtrl.dispose();
    super.dispose();
  }

  void _setRating(double value) {
    final rounded = value.clamp(1.0, 5.0).roundToDouble();
    if (rounded == selectedRating) return;
    HapticFeedback.selectionClick();
    setState(() {
      selectedRating = rounded;
      _trekC.rating.value = selectedRating;
    });
  }

  Widget _staggered(int index, Widget child) {
    if (index < 0 || index >= _staggerCtrl.length) return child;
    return FadeTransition(
      opacity: _staggerFade[index],
      child: SlideTransition(position: _staggerSlide[index], child: child),
    );
  }

  bool get _canSubmit => selectedRating > 0;

  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);

    if (booking == null) {
      return Scaffold(
        backgroundColor: _R.bg,
        appBar: AppBar(
          backgroundColor: _R.cardBg,
          elevation: 0,
          title: const Text(
            'Rate & Review',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: _R.ink,
            ),
          ),
        ),
        body: const Center(child: Text('No booking data found.')),
      );
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: _R.bg,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 1.5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _staggered(0, _buildRatingCard()),
              SizedBox(height: 1.5.h),
              _staggered(1, _buildCategoriesSection()),
              SizedBox(height: 1.5.h),
              _staggered(2, _buildReviewTextArea()),
              SizedBox(height: 1.h),
            ],
          ),
        ),
        bottomNavigationBar: SlideTransition(
          position: _bottomSlide,
          child: _buildBottomBar(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  APP BAR
  // ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _R.cardBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: 7.h,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _R.divider),
      ),
      leading: IconButton(
        onPressed: Get.back,
        icon: const Icon(Icons.close_rounded, color: _R.ink),
      ),
      title: Row(
        children: [
          Container(
            width: 7.2.w,
            height: 7.2.w,
            decoration: BoxDecoration(
              gradient: _R.ctaGradient,
              borderRadius: BorderRadius.circular(2.w),
              boxShadow: [
                BoxShadow(
                  color: _R.brand.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.rate_review_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
          SizedBox(width: 2.5.w),
          Text(
            'Rate & Review',
            textScaler: const TextScaler.linear(1.0),
            style: AppType.style(14.0.sp, w: FontWeight.w700, color: _R.ink),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  RATING CARD
  // ─────────────────────────────────────────────
  Widget _buildRatingCard() {
    final int intRating = selectedRating.round();
    final Color ratingColor = intRating > 0
        ? (_R.ratingColor[intRating] ?? _R.brand)
        : _R.inkLight;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _R.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _R.divider.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: _R.shadow.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gradient top accent
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              height: 0.5.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: intRating > 0
                      ? [ratingColor.withValues(alpha: 0.6), ratingColor]
                      : [_R.divider, _R.divider],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(4.5.w, 2.h, 4.5.w, 1.5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (booking?.trek?.title != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.5.w,
                      vertical: 0.5.h,
                    ),
                    margin: EdgeInsets.only(bottom: 1.2.h),
                    decoration: BoxDecoration(
                      color: _R.tealSoft,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: _R.teal.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      booking!.trek!.title!,
                      textScaler: const TextScaler.linear(1.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.style(
                        9.0.sp,
                        w: FontWeight.w600,
                        color: _R.teal,
                      ),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How was your experience?',
                            textScaler: const TextScaler.linear(1.0),
                            style: AppType.style(
                              14.0.sp,
                              w: FontWeight.w700,
                              color: _R.ink,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Your feedback helps shape better treks for everyone.',
                            textScaler: const TextScaler.linear(1.0),
                            maxLines: 2,
                            style: AppType.style(
                              9.5.sp,
                              w: FontWeight.w400,
                              color: _R.inkMid,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 3.w),
                    _RatingRing(
                      rating: selectedRating,
                      color: ratingColor,
                      size: 16.w,
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                _StarRow(
                  rating: selectedRating,
                  onChanged: _setRating,
                  activeColor: ratingColor,
                ),
                SizedBox(height: 1.3.h),
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: intRating > 0
                        ? _SentimentPill(
                            key: ValueKey(intRating),
                            label: _R.ratingLabel[intRating]!,
                            icon: _R.ratingIcon[intRating]!,
                            color: ratingColor,
                          )
                        : Padding(
                            key: const ValueKey(0),
                            padding: EdgeInsets.symmetric(vertical: 0.4.h),
                            child: Text(
                              'Tap a star to rate',
                              textScaler: const TextScaler.linear(1.0),
                              style: AppType.style(9.5.sp, color: _R.inkLight),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: _R.divider, height: 1),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 3.5.w,
                  color: _R.brand,
                ),
                SizedBox(width: 1.5.w),
                Flexible(
                  child: Text(
                    'Verified review from a completed booking',
                    textScaler: const TextScaler.linear(1.0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.style(
                      9.0.sp,
                      w: FontWeight.w500,
                      color: _R.brand,
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

  // ─────────────────────────────────────────────
  //  CATEGORIES SECTION
  // ─────────────────────────────────────────────
  Widget _buildCategoriesSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _R.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _R.divider.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: _R.shadow.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: _R.iconBadge,
                  borderRadius: BorderRadius.circular(2.2.w),
                  boxShadow: [
                    BoxShadow(
                      color: _R.ink.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              SizedBox(width: 2.5.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What stood out?',
                      textScaler: const TextScaler.linear(1.0),
                      style: AppType.style(
                        13.0.sp,
                        w: FontWeight.w700,
                        color: _R.ink,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      'Highlight the parts that impressed you most.',
                      textScaler: const TextScaler.linear(1.0),
                      maxLines: 2,
                      style: AppType.style(
                        9.0.sp,
                        w: FontWeight.w400,
                        color: _R.inkMid,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              _SelectionCounter(
                selected: selectedCategories.length,
                total: categories.length,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Column(
            children: List.generate(categories.length, (i) {
              final item = categories[i];
              final selected = selectedCategories.contains(item.name);

              return Padding(
                padding: EdgeInsets.only(
                  bottom: i == categories.length - 1 ? 0 : 1.h,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => _optionCtrl[i].forward(),
                  onTapUp: (_) {
                    _optionCtrl[i].reverse();
                    _toggleCategory(item.name);
                  },
                  onTapCancel: () => _optionCtrl[i].reverse(),
                  child: ScaleTransition(
                    scale: _optionScale[i],
                    child: _CategoryTile(item: item, selected: selected),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _toggleCategory(String name) {
    HapticFeedback.lightImpact();
    setState(() {
      if (selectedCategories.contains(name)) {
        selectedCategories.remove(name);
      } else {
        selectedCategories.add(name);
      }
    });
  }

  // ─────────────────────────────────────────────
  //  REVIEW TEXT AREA
  // ─────────────────────────────────────────────
  Widget _buildReviewTextArea() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _R.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _R.divider.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: _R.shadow.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: _R.iconBadge,
                  borderRadius: BorderRadius.circular(2.2.w),
                  boxShadow: [
                    BoxShadow(
                      color: _R.ink.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              SizedBox(width: 2.5.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your review (optional)',
                      textScaler: const TextScaler.linear(1.0),
                      style: AppType.style(
                        13.0.sp,
                        w: FontWeight.w700,
                        color: _R.ink,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      'Share details that help other trekkers.',
                      textScaler: const TextScaler.linear(1.0),
                      style: AppType.style(
                        9.0.sp,
                        w: FontWeight.w400,
                        color: _R.inkMid,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          _ReviewTextField(controller: _trekC.reviewController.value),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BOTTOM BAR
  // ─────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 2.h),
      decoration: BoxDecoration(
        color: _R.cardBg,
        border: Border(top: BorderSide(color: _R.divider)),
        boxShadow: [
          BoxShadow(
            color: _R.shadow.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _canSubmit ? 1 : 0.6,
          child: CommonButton(
            text: _canSubmit ? 'Submit Feedback' : 'Select a Rating',
            onPressed: () {
              if (!_canSubmit) {
                HapticFeedback.lightImpact();
                Get.snackbar(
                  'Rating required',
                  'Please select a star rating before submitting.',
                  snackPosition: SnackPosition.BOTTOM,
                  margin: EdgeInsets.all(4.w),
                  borderRadius: 12,
                  backgroundColor: _R.ink,
                  colorText: Colors.white,
                );
                return;
              }
              _submitFeedback(
                trekId: booking?.trek?.id ?? 0,
                customerId: booking?.customerId ?? 0,
                bookingId: booking?.id ?? 0,
                batchId: booking?.batch?.id ?? 0,
                safetySecurity: selectedCategories.contains(
                  'Safety & Security',
                ),
                organizerManner: selectedCategories.contains(
                  'Organizer Manner',
                ),
                trekPlanning: selectedCategories.contains('Trek Planning'),
                womenSafety: selectedCategories.contains('Women Safety'),
              );
            },
            gradient: _R.ctaGradient,
            textColor: CommonColors.whiteColor,
            fontSize: 14.0.sp,
            fontWeight: FontWeight.w600,
            borderRadius: 14,
            height: 6.h,
            isFullWidth: true,
          ),
        ),
      ),
    );
  }

  void _submitFeedback({
    required int trekId,
    required int customerId,
    required int bookingId,
    required int batchId,
    required bool safetySecurity,
    required bool organizerManner,
    required bool trekPlanning,
    required bool womenSafety,
  }) {
    _trekC.createReview(
      trekId: trekId,
      customerId: customerId,
      batchId: batchId,
      bookingId: bookingId,
      safetySecurity: safetySecurity,
      organizerManner: organizerManner,
      trekPlanning: trekPlanning,
      womenSafety: womenSafety,
    );
  }
}

// ─────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────
class _CategoryItem {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final Color accent;

  const _CategoryItem({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.accent,
  });
}

// ─────────────────────────────────────────────
//  CATEGORY TILE
// ─────────────────────────────────────────────
class _CategoryTile extends StatelessWidget {
  final _CategoryItem item;
  final bool selected;

  const _CategoryTile({required this.item, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: selected ? item.tint : _R.bg,
        borderRadius: BorderRadius.circular(3.5.w),
        border: Border.all(
          color: selected ? item.accent.withValues(alpha: 0.5) : _R.divider,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: item.accent.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: selected ? item.accent : Colors.white,
              borderRadius: BorderRadius.circular(2.5.w),
              border: Border.all(
                color: selected
                    ? item.accent
                    : item.accent.withValues(alpha: 0.25),
                width: selected ? 0 : 1.2,
              ),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutBack,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: selected
                    ? Icon(
                        Icons.check_rounded,
                        key: const ValueKey('check'),
                        color: Colors.white,
                        size: 5.w,
                      )
                    : Icon(
                        item.icon,
                        key: const ValueKey('icon'),
                        size: 5.w,
                        color: item.accent,
                      ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  textScaler: const TextScaler.linear(1.0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppType.style(
                    11.0.sp,
                    w: FontWeight.w700,
                    color: _R.ink,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  item.subtitle,
                  textScaler: const TextScaler.linear(1.0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppType.style(
                    9.0.sp,
                    w: FontWeight.w400,
                    color: _R.inkMid,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: 5.5.w,
            height: 5.5.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? item.accent : Colors.transparent,
              border: Border.all(
                color: selected
                    ? item.accent
                    : _R.inkLight.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: selected
                ? Icon(Icons.done_rounded, color: Colors.white, size: 3.5.w)
                : null,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  RATING RING
// ─────────────────────────────────────────────
class _RatingRing extends StatelessWidget {
  final double rating;
  final Color color;
  final double size;

  const _RatingRing({
    required this.rating,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = rating / 5.0;
    final intRating = rating.round();

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: fraction),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (_, value, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 4,
                  backgroundColor: _R.divider,
                  valueColor: AlwaysStoppedAnimation(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: intRating > 0
                    ? Icon(
                        _R.ratingIcon[intRating] ?? Icons.star_rounded,
                        key: ValueKey(intRating),
                        size: size * 0.45,
                        color: color,
                      )
                    : Icon(
                        Icons.star_border_rounded,
                        key: const ValueKey(0),
                        size: size * 0.45,
                        color: _R.inkLight,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STAR ROW
// ─────────────────────────────────────────────
class _StarRow extends StatefulWidget {
  final double rating;
  final ValueChanged<double> onChanged;
  final Color activeColor;

  const _StarRow({
    required this.rating,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  State<_StarRow> createState() => _StarRowState();
}

class _StarRowState extends State<_StarRow> {
  static const int _count = 5;
  int _hoverIndex = 0;
  final GlobalKey _rowKey = GlobalKey();

  int _posToIndex(Offset globalPos) {
    final box = _rowKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || box.size.width <= 0) return 0;
    final local = box.globalToLocal(globalPos);
    final slot = box.size.width / _count;
    return ((local.dx / slot).floor() + 1).clamp(1, _count);
  }

  @override
  Widget build(BuildContext context) {
    final display = _hoverIndex > 0 ? _hoverIndex : widget.rating.round();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) {
        final idx = _posToIndex(d.globalPosition);
        if (idx <= 0) return;
        setState(() => _hoverIndex = idx);
        widget.onChanged(idx.toDouble());
      },
      onTapUp: (_) => setState(() => _hoverIndex = 0),
      onTapCancel: () => setState(() => _hoverIndex = 0),
      onPanStart: (d) {
        final idx = _posToIndex(d.globalPosition);
        if (idx <= 0) return;
        setState(() => _hoverIndex = idx);
        widget.onChanged(idx.toDouble());
      },
      onPanUpdate: (d) {
        final idx = _posToIndex(d.globalPosition);
        if (idx > 0 && idx != _hoverIndex) {
          setState(() => _hoverIndex = idx);
          widget.onChanged(idx.toDouble());
        }
      },
      onPanEnd: (_) => setState(() => _hoverIndex = 0),
      onPanCancel: () => setState(() => _hoverIndex = 0),
      child: SizedBox(
        key: _rowKey,
        height: 11.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_count, (i) {
            final starNum = i + 1;
            final isActive = starNum <= display;
            final isCurrent = starNum == display;

            return Expanded(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: isActive ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  builder: (_, t, __) {
                    final scale = 1.0 + (t * 0.22);
                    return Transform.scale(
                      scale: scale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 8.5.w,
                            color: _R.divider,
                          ),
                          ClipRect(
                            clipper: _StarFillClipper(t),
                            child: Icon(
                              Icons.star_rounded,
                              size: 8.5.w,
                              color: widget.activeColor,
                            ),
                          ),
                          if (isCurrent && widget.rating > 0)
                            _PulseRing(color: widget.activeColor),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _StarFillClipper extends CustomClipper<Rect> {
  final double fraction;
  const _StarFillClipper(this.fraction);
  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);
  @override
  bool shouldReclip(_StarFillClipper old) => old.fraction != fraction;
}

class _PulseRing extends StatefulWidget {
  final Color color;
  const _PulseRing({required this.color});
  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _scale = Tween<double>(
      begin: 0.8,
      end: 1.8,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween<double>(
      begin: 0.45,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Container(
          width: 8.5.w,
          height: 8.5.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withValues(alpha: _opacity.value),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _SentimentPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _SentimentPill({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 4.w, color: color),
          SizedBox(width: 1.5.w),
          Text(
            label,
            textScaler: const TextScaler.linear(1.0),
            style: AppType.style(10.0.sp, w: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _SelectionCounter extends StatelessWidget {
  final int selected;
  final int total;
  const _SelectionCounter({required this.selected, required this.total});

  @override
  Widget build(BuildContext context) {
    final active = selected > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: active ? _R.tealSoft : _R.bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: active ? _R.teal.withValues(alpha: 0.25) : _R.divider,
        ),
      ),
      child: Text(
        '$selected/$total',
        textScaler: const TextScaler.linear(1.0),
        style: AppType.style(
          9.0.sp,
          w: FontWeight.w700,
          color: active ? _R.teal : _R.inkLight,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  REVIEW TEXT FIELD
// ─────────────────────────────────────────────
class _ReviewTextField extends StatefulWidget {
  final TextEditingController controller;
  const _ReviewTextField({required this.controller});
  @override
  State<_ReviewTextField> createState() => _ReviewTextFieldState();
}

class _ReviewTextFieldState extends State<_ReviewTextField>
    with SingleTickerProviderStateMixin {
  late final FocusNode _focus;
  late final AnimationController _borderCtrl;
  late final Animation<Color?> _borderColor;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _borderCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _borderColor = ColorTween(
      begin: _R.divider,
      end: _R.brand,
    ).animate(_borderCtrl);
    _focus.addListener(() {
      if (!mounted) return;
      _focus.hasFocus ? _borderCtrl.forward() : _borderCtrl.reverse();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _borderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _borderCtrl,
      builder: (_, child) {
        return Container(
          height: 15.h,
          decoration: BoxDecoration(
            color: _R.bg,
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(
              color: _borderColor.value ?? _R.divider,
              width: _focus.hasFocus ? 1.8 : 1.2,
            ),
            boxShadow: _focus.hasFocus
                ? [
                    BoxShadow(
                      color: _R.brand.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: child,
        );
      },
      child: TextFormField(
        focusNode: _focus,
        controller: widget.controller,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: AppType.style(11.0.sp, color: _R.ink, height: 1.4),
        decoration: InputDecoration(
          hintText: 'Describe what made this trek memorable...',
          hintStyle: AppType.style(10.0.sp, color: _R.inkLight, height: 1.4),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(4.w),
        ),
      ),
    );
  }
}
