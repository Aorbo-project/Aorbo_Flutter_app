import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_images.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _L {
  static const bg        = CommonColors.whiteColor;
  static const ink       = CommonColors.cFF111827;
  static const inkMid    = CommonColors.cFF6B7280;
  static const inkLight  = CommonColors.grey_AEAEAE;
  static const iconBadge = CommonColors.cFF111827;
  static const teal      = CommonColors.cFF0F7B6C;
  static const tealSoft  = CommonColors.cFFE6F5F3;
  static const brand     = CommonColors.lightBlueColor3;
  static const brandSoft = Color(0xFFEEF2FF);
  static const divider   = CommonColors.trekroutecolorlight;
  static const inputBg   = Color(0xFFF9FAFB);
  static const focusBg   = Color(0xFFF3F4F6);
}

class SourceLocationScreen extends StatefulWidget {
  const SourceLocationScreen({super.key});

  @override
  State<SourceLocationScreen> createState() => _SourceLocationScreenState();
}

class _SourceLocationScreenState extends State<SourceLocationScreen>
    with TickerProviderStateMixin {
  // ── Controllers ────────────────────────────
  final DashboardController _dashboardC = Get.find<DashboardController>();

  final TextEditingController _fromCtrl = TextEditingController();
  final TextEditingController _toCtrl   = TextEditingController();
  final FocusNode _fromFocus = FocusNode();
  final FocusNode _toFocus   = FocusNode();

  List<String> _filteredList = [];
  bool _isFromFocused = true;
  bool _isFetchingCalendar = false;

  // Animations
  late final AnimationController _listFadeCtrl;
  late final Animation<double> _listFade;

  late final AnimationController _tabCtrl; // 0 = cities, 1 = treks

  @override
  void initState() {
    super.initState();

    _listFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..value = 1.0;
    _listFade = CurvedAnimation(parent: _listFadeCtrl, curve: Curves.easeOut);

    _tabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 0,
    );

    _filteredList = _getCities();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusScope.of(context).requestFocus(_fromFocus);
    });

    _fromFocus.addListener(_onFromFocusChange);
    _toFocus.addListener(_onToFocusChange);
  }

  void _onFromFocusChange() {
    if (!mounted) return;
    if (_fromFocus.hasFocus) _switchTab(fromFocused: true);
  }

  void _onToFocusChange() {
    if (!mounted) return;
    if (_toFocus.hasFocus) _switchTab(fromFocused: false);
  }

  Future<void> _switchTab({required bool fromFocused}) async {
    if (_isFromFocused == fromFocused) return;
    await _listFadeCtrl.reverse();
    if (!mounted) return;
    setState(() {
      _isFromFocused = fromFocused;
      _filteredList  = fromFocused ? _getCities() : _getTreks();
    });
    fromFocused ? _tabCtrl.reverse() : _tabCtrl.forward();
    _listFadeCtrl.forward();
  }

  @override
  void dispose() {
    _fromFocus.removeListener(_onFromFocusChange);
    _toFocus.removeListener(_onToFocusChange);
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _fromFocus.dispose();
    _toFocus.dispose();
    _listFadeCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── Data helpers ───────────────────────────
  List<String> _getCities() =>
      _dashboardC.citiesData.value.data
          ?.map((e) => e.cityName ?? '')
          .where((s) => s.isNotEmpty)
          .toList() ??
      [];

  List<String> _getTreks() =>
      _dashboardC.trekData.value.data
          ?.map((e) => e.name ?? '')
          .where((s) => s.isNotEmpty)
          .toList() ??
      [];

  void _filter(String query) {
    if (!mounted) return;
    final source = _isFromFocused ? _getCities() : _getTreks();
    setState(() {
      _filteredList = query.isEmpty
          ? source
          : source
              .where((item) =>
                  item.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  Future<void> _fetchCalendarDates() async {
    if (_dashboardC.selectedCityId.value == 0 ||
        _dashboardC.selectedTrekId.value == 0) {
      return;
    }
    final now   = DateTime.now();
    final later = now.add(const Duration(days: 90));
    await _dashboardC.fetchCalenderTrekDates(
      cityId:   _dashboardC.selectedCityId.value,
      trekId:   _dashboardC.selectedTrekId.value,
      statDate: DateFormat('yyyy-MM-dd').format(now),
      endDate:  DateFormat('yyyy-MM-dd').format(later),
    );
  }

  Future<void> _onItemTap(String value) async {
    if (_isFetchingCalendar) return;

    if (_isFromFocused) {
      final city = _dashboardC.citiesData.value.data
          ?.firstWhereOrNull((c) => c.cityName == value);
      _dashboardC.selectedCityId.value = city?.id ?? 0;
      _dashboardC.fromController.value.text = value;
      _fromCtrl.text = value;

      _toCtrl.clear();
      _dashboardC.toController.value.text = '';
      _dashboardC.selectedTrekId.value = 0;

      FocusScope.of(context).requestFocus(_toFocus);
    } else {
      final trek = _dashboardC.trekData.value.data
          ?.firstWhereOrNull((t) => t.name == value);
      _dashboardC.selectedTrekId.value = trek?.id ?? 0;
      _dashboardC.toController.value.text = value;
      _toCtrl.text = value;
      _toFocus.unfocus();

      if (_fromCtrl.text.isNotEmpty && _toCtrl.text.isNotEmpty) {
        setState(() => _isFetchingCalendar = true);
        await _fetchCalendarDates();
        if (mounted) setState(() => _isFetchingCalendar = false);
        Get.back();
      }
    }
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);

    return Scaffold(
      backgroundColor: _L.bg,
      appBar: _buildAppBar(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 0),
              child: _buildInputCard(),
            ),
            SizedBox(height: 2.2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: _buildSegmentedTabs(),
            ),
            SizedBox(height: 1.6.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: _buildHeaderRow(),
            ),
            SizedBox(height: 1.h),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _L.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: _L.ink),
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _L.divider),
      ),
      title: Text(
        'Select Locations',
        textScaler: const TextScaler.linear(1.0),
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s14,
          fontWeight: FontWeight.w700,
          color: _L.ink,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  INPUT CARD
  // ─────────────────────────────────────────────
  Widget _buildInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: _L.bg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _L.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildField(
            controller: _fromCtrl,
            focusNode:  _fromFocus,
            hint:       'From City',
            svgPath:    CommonImages.location3,
            isFocused:  _isFromFocused,
            isTop:      true,
          ),
          Container(height: 1, color: _L.divider),
          _buildField(
            controller: _toCtrl,
            focusNode:  _toFocus,
            hint:       'Select Trek',
            svgPath:    CommonImages.location2,
            isFocused:  !_isFromFocused,
            isTop:      false,
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required String svgPath,
    required bool isFocused,
    required bool isTop,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isFocused ? _L.focusBg : _L.bg,
        borderRadius: BorderRadius.only(
          topLeft:     isTop ? Radius.circular(4.w) : Radius.zero,
          topRight:    isTop ? Radius.circular(4.w) : Radius.zero,
          bottomLeft:  !isTop ? Radius.circular(4.w) : Radius.zero,
          bottomRight: !isTop ? Radius.circular(4.w) : Radius.zero,
        ),
      ),
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1.0)),
        child: TextField(
          controller: controller,
          focusNode:  focusNode,
          onChanged:  _filter,
          textAlignVertical: TextAlignVertical.center,
          cursorColor: _L.teal,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize:   FontSize.s11,
            color:      _L.ink,
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.all(14),
              child: SvgPicture.asset(
                svgPath,
                height: ScreenConstant.size20,
                width:  ScreenConstant.size20,
                colorFilter: ColorFilter.mode(
                  isFocused ? _L.ink : _L.inkLight,
                  BlendMode.srcIn,
                ),
              ),
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    splashRadius: 20,
                    icon: Icon(Icons.close_rounded,
                        size: 4.w, color: _L.inkMid),
                    onPressed: () {
                      controller.clear();
                      _filter('');
                    },
                  )
                : null,
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize:   FontSize.s11,
              color:      _L.inkLight,
            ),
            border:        InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            isCollapsed:   true,
            contentPadding:
                EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 0),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SEGMENTED TABS — animated sliding indicator
  // ─────────────────────────────────────────────
  Widget _buildSegmentedTabs() {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        return Container(
          height: 5.h,
          decoration: BoxDecoration(
            color: _L.inputBg,
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(color: _L.divider, width: 1),
          ),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _tabCtrl,
                builder: (_, __) {
                  return Positioned(
                    left: 4 + (w / 2 - 4) * _tabCtrl.value,
                    top: 4,
                    bottom: 4,
                    width: w / 2 - 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2.5.w),
                        boxShadow: [
                          BoxShadow(
                            color:
                                CommonColors.blackColor.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: _tabButton(
                      label: 'Cities',
                      active: _isFromFocused,
                      onTap: () =>
                          FocusScope.of(context).requestFocus(_fromFocus),
                    ),
                  ),
                  Expanded(
                    child: _tabButton(
                      label: 'Treks',
                      active: !_isFromFocused,
                      onTap: () =>
                          FocusScope.of(context).requestFocus(_toFocus),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(2.5.w),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize:   FontSize.s11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color:      active ? _L.ink : _L.inkMid,
            ),
            child: Text(label,
                textScaler: const TextScaler.linear(1.0)),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HEADER ROW (title + count)
  // ─────────────────────────────────────────────
  Widget _buildHeaderRow() {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: Text(
            _isFromFocused ? 'Popular Cities' : 'Popular Treks',
            key: ValueKey(_isFromFocused),
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize:   FontSize.s12,
              fontWeight: FontWeight.w700,
              color:      _L.ink,
            ),
          ),
        ),
        const Spacer(),
        if (_filteredList.isNotEmpty)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Container(
              key: ValueKey('${_isFromFocused}_${_filteredList.length}'),
              padding: EdgeInsets.symmetric(
                  horizontal: 2.5.w, vertical: 0.4.h),
              decoration: BoxDecoration(
                color: _L.tealSoft,
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Text(
                '${_filteredList.length} found',
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize:   FontSize.s8,
                  fontWeight: FontWeight.w600,
                  color:      _L.teal,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  SUGGESTION LIST
  // ─────────────────────────────────────────────
  Widget _buildList() {
    return Obx(() {
      final loading = _isFromFocused
          ? _dashboardC.isLoadingCities.value
          : _dashboardC.isLoadingTreks.value;

      if (loading) return _buildShimmerList();
      if (_filteredList.isEmpty) return _buildEmptyState();

      return FadeTransition(
        opacity: _listFade,
        child: ListView.separated(
          physics:
              const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.h),
          itemCount: _filteredList.length,
          separatorBuilder: (_, __) =>
              Container(height: 0.5, color: _L.divider),
          itemBuilder: (_, i) {
            final item = _filteredList[i];
            // Staggered entrance
            return TweenAnimationBuilder<double>(
              key: ValueKey('${_isFromFocused}_$i'),
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 260 + (i * 22).clamp(0, 240)),
              curve: Curves.easeOutCubic,
              builder: (_, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, (1 - t) * 8),
                  child: child,
                ),
              ),
              child: _ListItem(
                label: item,
                disabled: _isFetchingCalendar,
                onTap: () => _onItemTap(item),
              ),
            );
          },
        ),
      );
    });
  }

  // ─────────────────────────────────────────────
  //  SHIMMER
  // ─────────────────────────────────────────────
  Widget _buildShimmerList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.h),
      itemCount: 8,
      separatorBuilder: (_, __) =>
          Container(height: 0.5, color: _L.divider),
      itemBuilder: (_, i) => Padding(
        padding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 1.w),
        child: Row(
          children: [
            Container(
              width: 1.w,
              height: 2.2.h,
              decoration: BoxDecoration(
                color: _L.divider,
                borderRadius: BorderRadius.circular(1.w),
              ),
            ),
            SizedBox(width: 3.w),
            Container(
              width:  40.w + (i * 3.0).clamp(0.0, 20.0),
              height: 1.5.h,
              decoration: BoxDecoration(
                color: _L.divider,
                borderRadius: BorderRadius.circular(1.w),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  EMPTY STATE
  // ─────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:  16.w,
              height: 16.w,
              decoration: BoxDecoration(
                color: _L.tealSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded,
                  size: 8.w, color: _L.teal),
            ),
            SizedBox(height: 2.h),
            Text(
              'No results found',
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize:   FontSize.s13,
                fontWeight: FontWeight.w700,
                color:      _L.ink,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              'Try a different search term',
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize:   FontSize.s10,
                color:      _L.inkMid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  LIST ITEM — accent bar + scale-on-press
// ─────────────────────────────────────────────
class _ListItem extends StatefulWidget {
  final String label;
  final bool disabled;
  final VoidCallback onTap;
  const _ListItem({
    required this.label,
    required this.disabled,
    required this.onTap,
  });

  @override
  State<_ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<_ListItem> {
  bool _pressed = false;

  void _set(bool v) {
    if (widget.disabled) return;
    if (mounted) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown:   (_) => _set(true),
      onTapCancel: ()  => _set(false),
      onTapUp:     (_) => _set(false),
      onTap: widget.disabled ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
              vertical: 1.6.h, horizontal: 2.5.w),
          decoration: BoxDecoration(
            color: _pressed ? _L.inputBg : Colors.transparent,
            borderRadius: BorderRadius.circular(2.5.w),
          ),
          child: Row(
            children: [
              // Accent bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _pressed ? 1.2.w : 0.8.w,
                height: 2.4.h,
                decoration: BoxDecoration(
                  color: _pressed ? _L.teal : _L.divider,
                  borderRadius: BorderRadius.circular(1.w),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  widget.label,
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize:   FontSize.s11,
                    color:      _L.ink,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
