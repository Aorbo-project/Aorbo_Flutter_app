import 'dart:async';
import 'package:arobo_app/controller/coupon_controller.dart';
import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/models/city_model.dart';
import 'package:arobo_app/screens/source_location_screen.dart';
import 'package:arobo_app/screens/trek_details_screen.dart';
import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/arobo_theme.dart';
import 'package:arobo_app/utils/common_discount_card.dart';
import 'package:arobo_app/utils/common_filter_bar.dart';
import 'package:arobo_app/utils/common_trek_card.dart';
import 'package:arobo_app/utils/statefullwrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../freezed_models/treks/treks_model_data.dart';
import '../models/coupon_code/coupon_code_model.dart';

class SearchSummaryScreen extends StatefulWidget {
  const SearchSummaryScreen({super.key});

  @override
  State<SearchSummaryScreen> createState() => _SearchSummaryScreenState();
}

class _SearchSummaryScreenState extends State<SearchSummaryScreen>
    with TickerProviderStateMixin {
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
  late final AnimationController _headerSlideCtrl;
  late final Animation<Offset> _headerSlideAnim;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _ntpTime;

  @override
  void initState() {
    super.initState();
    _initializeNTPTime();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _headerSlideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _headerSlideAnim =
        Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _headerSlideCtrl, curve: Curves.easeOutCubic),
        );

    _fadeCtrl.forward();
    _headerSlideCtrl.forward();
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
    _headerSlideCtrl.dispose();
    super.dispose();
  }

  Future<void> _initializeNTPTime() async {
    try {
      final DateTime ntpTime = await NTP.now();
      if (!mounted) return;
      setState(() {
        _ntpTime = ntpTime;
        _focusedDay = ntpTime;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ntpTime = DateTime.now();
        _focusedDay = DateTime.now();
      });
    }
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

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await _couponC.fetchPlatformCoupons();
    await _trekC.searchTreks(
      cityId: _dashboardC.selectedCityId.value,
      trekId: _dashboardC.selectedTrekId.value,
      date: _dashboardC.dateController.value.text,
      refresh: true,
    );
  }

  Future<void> _openLocationSearch() async {
    await Navigator.push<City>(
      context,
      MaterialPageRoute(builder: (_) => const SourceLocationScreen()),
    );

    if (_dashboardC.fromController.value.text.isNotEmpty &&
        _dashboardC.toController.value.text.isNotEmpty &&
        _dashboardC.dateController.value.text.isNotEmpty) {
      _onRefresh();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final bool isCityTrekSelected =
        _dashboardC.selectedCityId.value != 0 &&
        _dashboardC.selectedTrekId.value != 0;

    if (!isCityTrekSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select source and destination first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_ntpTime == null) await _initializeNTPTime();
    if (!context.mounted) return;

    final DateTime currentTime = _ntpTime ?? DateTime.now();
    final DateTime normalizedCurrent = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
    );
    final DateTime threeMonthsLater = normalizedCurrent.add(
      const Duration(days: 90),
    );

    await _showCustomDatePicker(context, normalizedCurrent, threeMonthsLater);
  }

  Future<void> _showCustomDatePicker(
    BuildContext context,
    DateTime firstDate,
    DateTime lastDate,
  ) async {
    DateTime tempSelectedDate = _dashboardC.selectedDate.value ?? firstDate;
    DateTime tempFocusedDay = _focusedDay;
    CalendarFormat tempCalendarFormat = _calendarFormat;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            final screenHeight = MediaQuery.of(context).size.height;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Transform.translate(
                offset: Offset(0, (1 - value) * 40),
                child: Opacity(opacity: value, child: child),
              ),
              child: Container(
                constraints: BoxConstraints(maxHeight: screenHeight * 0.82),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 24,
                      spreadRadius: 2,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AroboTheme.elevated,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        border: const Border(
                          bottom: BorderSide(color: AroboTheme.border),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AroboTheme.inkLight.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                            child: Row(
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.85, end: 1.0),
                                  duration: const Duration(milliseconds: 380),
                                  curve: Curves.elasticOut,
                                  builder: (_, v, child) =>
                                      Transform.scale(scale: v, child: child),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AroboTheme.tealSoft,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AroboTheme.teal.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_month_rounded,
                                      color: AroboTheme.teal,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Select Departure Date',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w700,
                                          color: AroboTheme.ink,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Tap an available date to continue',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 10.5,
                                          color: AroboTheme.inkMid,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AroboTheme.border,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: AroboTheme.inkMid,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                            child: Row(
                              children: [
                                _legendItem(
                                  color: AroboTheme.teal,
                                  label: 'Available',
                                  hasCount: true,
                                ),
                                const SizedBox(width: 14),
                                _legendItem(
                                  color: AroboTheme.teal,
                                  label: 'Selected',
                                  solid: true,
                                ),
                                const SizedBox(width: 14),
                                _legendItem(
                                  color: AroboTheme.inkLight,
                                  label: 'Unavailable',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AroboTheme.border),
                          ),
                          padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
                          child: Obx(() {
                            final isLoading = _dashboardC
                                .calenderTrekDatesObserver
                                .value
                                .maybeWhen(
                                  loading: (_) => true,
                                  orElse: () => false,
                                );

                            if (isLoading) {
                              return SizedBox(
                                height: 280,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AroboTheme.teal,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Loading available dates…',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 11.5,
                                          color: AroboTheme.inkMid,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Theme(
                              data: Theme.of(context).copyWith(
                                cardColor: Colors.white,
                                scaffoldBackgroundColor: Colors.white,
                                colorScheme: ColorScheme.fromSeed(
                                  seedColor: AroboTheme.teal,
                                  brightness: Brightness.light,
                                  surface: Colors.white,
                                ),
                              ),
                              child: TableCalendar(
                                firstDay: firstDate,
                                lastDay: lastDate,
                                focusedDay: tempFocusedDay,
                                calendarFormat: tempCalendarFormat,
                                availableCalendarFormats: const {
                                  CalendarFormat.month: 'Month',
                                },
                                sixWeekMonthsEnforced: true,
                                rowHeight: 50,
                                daysOfWeekHeight: 28,
                                shouldFillViewport: false,
                                onFormatChanged: (f) =>
                                    setSheet(() => tempCalendarFormat = f),
                                onPageChanged: (foc) => tempFocusedDay = foc,
                                selectedDayPredicate: (d) =>
                                    isSameDay(d, tempSelectedDate),
                                onDaySelected: (sel, foc) {
                                  final bool isAvailable = _dashboardC
                                      .isDateAvailable(sel);

                                  if (!isAvailable) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No treks available on this date',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    _dashboardC.selectedDate.value = sel;
                                    _dashboardC.dateController.value.text =
                                        DateFormat('dd/MM/yyyy').format(sel);
                                    _selectedDay = sel;
                                    _focusedDay = foc;
                                    _calendarFormat = tempCalendarFormat;
                                  });

                                  Get.back();
                                  _onRefresh();
                                },
                                calendarStyle: const CalendarStyle(
                                  outsideDaysVisible: false,
                                  cellPadding: EdgeInsets.zero,
                                  cellMargin: EdgeInsets.all(2),
                                  tableBorder: TableBorder.symmetric(
                                    inside: BorderSide(
                                      color: Color(0xFFF3F4F6),
                                    ),
                                  ),
                                ),
                                calendarBuilders: CalendarBuilders(
                                  defaultBuilder: (ctx, day, _) =>
                                      _buildDayCell(
                                        day: day,
                                        isSelected: false,
                                        isToday: false,
                                      ),
                                  todayBuilder: (ctx, day, _) => _buildDayCell(
                                    day: day,
                                    isSelected: isSameDay(
                                      day,
                                      tempSelectedDate,
                                    ),
                                    isToday: true,
                                  ),
                                  selectedBuilder: (ctx, day, _) =>
                                      _buildDayCell(
                                        day: day,
                                        isSelected: true,
                                        isToday: isSameDay(
                                          day,
                                          _ntpTime ?? DateTime.now(),
                                        ),
                                      ),
                                  markerBuilder: (_, __, ___) => null,
                                ),
                                headerStyle: HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  titleTextStyle: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: AroboTheme.ink,
                                    letterSpacing: -0.2,
                                  ),
                                  leftChevronIcon: _chevron(
                                    Icons.chevron_left_rounded,
                                    AroboTheme.teal,
                                  ),
                                  rightChevronIcon: _chevron(
                                    Icons.chevron_right_rounded,
                                    AroboTheme.teal,
                                  ),
                                  headerPadding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                ),
                                daysOfWeekStyle: DaysOfWeekStyle(
                                  weekdayStyle: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AroboTheme.inkMid,
                                    letterSpacing: 0.4,
                                  ),
                                  weekendStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AroboTheme.danger.withValues(
                                      alpha: 0.7,
                                    ),
                                    letterSpacing: 0.4,
                                  ),
                                  dowTextFormatter: (date, locale) =>
                                      DateFormat.E(locale)
                                          .format(date)
                                          .substring(0, 1)
                                          .toUpperCase(),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _legendItem({
    required Color color,
    required String label,
    bool solid = false,
    bool hasCount = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        hasCount
            ? Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: AroboTheme.tealSoft,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              )
            : Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: solid ? color : Colors.transparent,
                  shape: BoxShape.circle,
                  border: solid ? null : Border.all(color: color, width: 1.5),
                ),
                child: solid
                    ? const Icon(
                        Icons.check_rounded,
                        size: 8,
                        color: Colors.white,
                      )
                    : null,
              ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
            color: AroboTheme.inkMid,
          ),
        ),
      ],
    );
  }

  Widget _chevron(IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: accent),
    );
  }

  Widget _buildDayCell({
    required DateTime day,
    required bool isSelected,
    required bool isToday,
  }) {
    final dateStr = DateFormat('yyyy-MM-dd').format(day);
    final trekCount = _dashboardC.availableDates[dateStr] ?? 0;
    final isAvailable = trekCount > 0;
    final isWeekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    const double cellSize = 42.0;
    const double radius = 11.0;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AroboTheme.teal, AroboTheme.tealLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : isAvailable
              ? AroboTheme.tealSoft
              : Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          border: isToday && !isSelected
              ? Border.all(color: AroboTheme.teal, width: 1.6)
              : isAvailable && !isSelected
              ? Border.all(
                  color: AroboTheme.teal.withValues(alpha: 0.35),
                  width: 1,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AroboTheme.teal.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                fontWeight: isSelected || isAvailable
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : isAvailable
                    ? AroboTheme.teal
                    : isWeekend
                    ? AroboTheme.danger.withValues(alpha: 0.7)
                    : AroboTheme.ink,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            if (isAvailable)
              Text(
                isSelected ? '✓' : '$trekCount',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.95)
                      : AroboTheme.teal,
                  height: 1.0,
                ),
              )
            else
              const SizedBox(height: 9),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _dashboardC.dateController.value.text;
    final fromText = _dashboardC.fromController.value.text;
    final toText = _dashboardC.toController.value.text;

    return StatefulWrapper(
      onInit: () async {
        await _couponC.fetchPlatformCoupons();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) _scrollController.jumpTo(0);
        });
      },
      child: Scaffold(
        backgroundColor: AroboTheme.bg,
        appBar: _buildAppBar(fromText, toText, dateText, context),
        // Using a Column to statically attach the filter bar directly below AppBar
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              CommonFilterBar(
                onFiltersChanged: (filters) {
                  _applyFilters(filters);
                },
                onGroupBookingChanged: (value) =>
                    setState(() => _isGroupBooking = value),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AroboTheme.primary,
                  backgroundColor: Colors.white,
                  onRefresh: _onRefresh,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n.metrics.pixels >=
                          n.metrics.maxScrollExtent - 300) {}
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
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        _buildTrekList(dateText),
                        const SliverToBoxAdapter(child: SizedBox(height: 40)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    String from,
    String to,
    String dateText,
    BuildContext context,
  ) {
    return AppBar(
      backgroundColor: AroboTheme.cardBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: AroboTheme.ink),
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AroboTheme.border),
      ),
      title: SlideTransition(
        position: _headerSlideAnim,
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
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
                              style: AroboTheme.label(
                                size: 14,
                                weight: FontWeight.w800,
                                color: AroboTheme.ink400,
                              ),
                            ),
                          ),
                        if (from.isNotEmpty && to.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: AroboTheme.primary,
                              size: 16,
                            ),
                          ),
                        if (to.isNotEmpty)
                          Flexible(
                            child: Text(
                              to,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textScaler: const TextScaler.linear(1.0),
                              style: AroboTheme.label(
                                size: 14,
                                weight: FontWeight.w800,
                                color: AroboTheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (dateText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: AroboTheme.ink400,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formattedDate(dateText),
                            textScaler: const TextScaler.linear(1.0),
                            style: AroboTheme.label(
                              size: 11,
                              weight: FontWeight.w600,
                              color: AroboTheme.ink400,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${_formattedWeekday(dateText)})',
                            textScaler: const TextScaler.linear(1.0),
                            style: AroboTheme.label(
                              size: 11,
                              color: AroboTheme.ink400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.search_rounded),
                    color: AroboTheme.primary,
                    onPressed: _openLocationSearch,
                    tooltip: 'Change Route',
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month_rounded),
                    color: AroboTheme.primary,
                    onPressed: () => _selectDate(context),
                    tooltip: 'Change Date',
                  ),
                ],
              ),
            ],
          ),
        ),
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
        height: 16.h,
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
                  textColour: coupon.textColour ?? '#0F7B6C',
                  code: coupon.code ?? '',
                  offerAmount: coupon.discountValue ?? '',
                  imagePath: coupon.imagePath ?? '',
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

  Widget _buildTrekList(String dateText) {
    return Obx(() {
      final isLoading = _trekC.treksResponseObserver.value.data.value.maybeWhen(
        loading: (_) => true,
        orElse: () => false,
      );

      final treks = _trekC.treksResponseObserver.value.data.value.maybeWhen(
        success: (data) {
          if (data is FetchTreksResponseModel) {
            List<TrekData> filteredTreks = List<TrekData>.from(data.data ?? []);

            if (activeFilters.contains('Flexible')) {
              filteredTreks = filteredTreks
                  .where(
                    (trek) =>
                        trek.cancellationPolicy?.title?.toLowerCase().contains(
                          'flexible',
                        ) ==
                        true,
                  )
                  .toList();
            }
            if (activeFilters.contains('Standard')) {
              filteredTreks = filteredTreks
                  .where(
                    (trek) =>
                        trek.cancellationPolicy?.title?.toLowerCase().contains(
                          'standard',
                        ) ==
                        true,
                  )
                  .toList();
            }
            if (activeFilters.contains('Strict')) {
              filteredTreks = filteredTreks
                  .where(
                    (trek) =>
                        trek.cancellationPolicy?.title?.toLowerCase().contains(
                          'strict',
                        ) ==
                        true,
                  )
                  .toList();
            }
            if (activeFilters.contains('4.5+ Stars')) {
              filteredTreks = filteredTreks
                  .where((t) => (t.rating ?? 0) >= 4.5)
                  .toList();
            }
            if (activeFilters.contains('4+ Stars')) {
              filteredTreks = filteredTreks
                  .where((t) => (t.rating ?? 0) >= 4)
                  .toList();
            }
            if (activeFilters.contains('3.5+ Stars')) {
              filteredTreks = filteredTreks
                  .where((t) => (t.rating ?? 0) >= 3.5)
                  .toList();
            }

            if (activeFilters.contains('Price: Low → High')) {
              filteredTreks.sort((a, b) {
                final aPrice = double.tryParse(a.price ?? '0') ?? 0;
                final bPrice = double.tryParse(b.price ?? '0') ?? 0;
                return aPrice.compareTo(bPrice);
              });
            }
            if (activeFilters.contains('Price: High → Low')) {
              filteredTreks.sort((a, b) {
                final aPrice = double.tryParse(a.price ?? '0') ?? 0;
                final bPrice = double.tryParse(b.price ?? '0') ?? 0;
                return bPrice.compareTo(aPrice);
              });
            }
            if (activeFilters.contains('Top Rated')) {
              filteredTreks.sort(
                (a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0),
              );
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
          hasScrollBody: false,
          child: _buildEmptyState(dateText),
        );
      }

      final hasExplicitSort = activeFilters.any(
        (f) => f.contains('Price') || f.contains('Top Rated'),
      );
      final ranked = hasExplicitSort ? treks : List<TrekData>.from(treks)
        ..sort(
          (a, b) => AroboPersonalization.instance
              .scoreFor(b.id, b.rating, b.price, b.hasDiscount)
              .compareTo(
                AroboPersonalization.instance.scoreFor(
                  a.id,
                  a.rating,
                  a.price,
                  a.hasDiscount,
                ),
              ),
        );

      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == ranked.length) return const SizedBox(height: 40);
          final trek = ranked[index];
          final animDelay = 300 + ((index.clamp(0, 5).toInt()) * 80);

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: animDelay),
            curve: Curves.easeOutCubic,
            builder: (ctx, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 24 * (1 - value)),
                child: child,
              ),
            ),
            child: Container(
              margin: EdgeInsets.only(top: 0.5.h, left: 0, right: 0),
              child: CommonTrekCard(
                trek: trek,
                fromLocation: _dashboardC.fromController.value.text,
                toLocation: _dashboardC.toController.value.text,
                onTap: () async {
                  AroboPersonalization.instance.pushRecent(trek.id?.toString());
                  _trekC.trekDetailId.value = trek.id ?? 0;
                  await _trekC.trekDetail(batchId: trek.batchInfo?.id ?? 0);
                  Get.to(() => TrekDetailsScreen(trek: trek));
                },
              ).withShimmerAi(loading: isLoading),
            ),
          );
        }, childCount: ranked.isEmpty ? 0 : ranked.length + 1),
      );
    });
  }

  Widget _buildEmptyState(String dateText) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: AroboTheme.elevated,
                  shape: BoxShape.circle,
                  border: Border.all(color: AroboTheme.border, width: 1.5),
                ),
                child: Icon(
                  Icons.hiking_rounded,
                  size: 11.w,
                  color: AroboTheme.primary,
                ),
              ),
              SizedBox(height: 2.5.h),
              Text(
                'No treks available',
                textScaler: const TextScaler.linear(1.0),
                style: AroboTheme.label(
                  size: 16,
                  weight: FontWeight.w800,
                  color: AroboTheme.ink,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 0.8.h),
              Text(
                dateText.isNotEmpty
                    ? 'for ${_formattedDate(dateText)}'
                    : 'for this route',
                textScaler: const TextScaler.linear(1.0),
                style: AroboTheme.label(
                  size: 12,
                  weight: FontWeight.w600,
                  color: AroboTheme.ink400,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Try selecting a different date or route',
                textScaler: const TextScaler.linear(1.0),
                style: AroboTheme.label(size: 10, color: AroboTheme.inkMid),
              ),
              SizedBox(height: 3.5.h),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 7.w,
                    vertical: 1.4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AroboTheme.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AroboTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    'Change search',
                    textScaler: const TextScaler.linear(1.0),
                    style: AroboTheme.label(
                      size: 12,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
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
