import 'dart:developer';
import 'dart:math' as math;

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/common_btn.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/dashboard_header_theme.dart';
import 'package:arobo_app/utils/header_scene.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/know_more_card.dart';
import 'package:arobo_app/utils/seasonal_forecast_mock_data.dart';
import 'package:arobo_app/utils/seasonal_gradient_card.dart';
import 'package:arobo_app/utils/top_treks_card.dart';
import 'package:arobo_app/models/know_more_data.dart';
import 'package:arobo_app/models/seasonal_picks_data.dart';
import 'package:arobo_app/models/city_model.dart';
import 'package:arobo_app/screens/source_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter_touch_ripple/flutter_touch_ripple.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import 'package:sizer/sizer.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:ntp/ntp.dart';
import 'package:table_calendar/table_calendar.dart';

import '../freezed_models/treks/treks_model_data.dart';

/// Neutral palette for the body/calendar. The HEADER no longer reads from
/// this — it is fully driven by DashboardHeaderTheme.
class _C {
  static const bg = Color(0xFFF5F8FF);
  static const cardBg = Color(0xFFFFFFFF);
  static const ink = Color(0xFF111827);
  static const inkMid = Color(0xFF6B7280);
  static const inkLight = Color(0xFF9CA3AF);
  static const teal = Color(0xFF0F7B6C);
  static const tealLight = Color(0xFF1AA090);
  static const tealSoft = Color(0xFFE6F5F3);
  static const fieldBg = Color(0xFFF9FAFB);
  static const fieldBorder = Color(0xFFE5E7EB);
  static const shadow = Color(0x0D000000);
  static const iconBadgeBg = Color(0xFF111827);
  static const danger = Color(0xFFEF4444);
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  int selectedIndex = 0;
  DateTime? _ntpTime;

  final ScrollController _scrollController = ScrollController();
  final ScrollController _knowMoreController = ScrollController();
  final PageController _topTreksPageController = PageController(
    viewportFraction: 0.74,
  );
  final ScrollController _seasonalForecastController = ScrollController();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _glowController; // pulsing glow on Search button
  bool _isPressed = false;

  final PageController _pageController = PageController(
    viewportFraction: 0.85,
    initialPage: 500,
  );

  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;
  int _currentPage = 0;

  final DashboardController _dashboardC = Get.find<DashboardController>();
  final TrekController _trekC = Get.find<TrekController>();
  late final HeaderThemeController _themeC;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<DateTime> _nearestWeekendDates = [];
  final Map<int, bool> _favoriteTreks = {};

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '[api.aorbotreks.co.in$path](https://api.aorbotreks.co.in$path)';
  }

  List<String> _safeGradient(List<dynamic>? gradient, List<String> fallback) {
    if (gradient == null || gradient.isEmpty) {
      return fallback;
    }
    return gradient.map((e) => e.toString()).toList();
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _themeC = Get.isRegistered<HeaderThemeController>()
        ? Get.find<HeaderThemeController>()
        : Get.put(HeaderThemeController());

    _initializeNTPTime();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    ever(_dashboardC.calenderTrekDatesObserver, (value) {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetAllScrolls();
    });

    _dashboardC.fetchWhatsNew();
    _dashboardC.fetchTopTreks();
    _dashboardC.fetchSeasonalPicks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.settings.name == '/dashboard') {
      _startAutoScroll();
    }
  }

  @override
  void deactivate() {
    _stopAutoScroll();
    super.deactivate();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    _animationController.dispose();
    _glowController.dispose();
    _scrollController.dispose();
    _knowMoreController.dispose();
    _topTreksPageController.dispose();
    _seasonalForecastController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _resetAllScrolls() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    if (_knowMoreController.hasClients) _knowMoreController.jumpTo(0);
    if (_topTreksPageController.hasClients) {
      _topTreksPageController.jumpToPage(0);
    }
    if (_seasonalForecastController.hasClients) {
      _seasonalForecastController.jumpTo(0);
    }
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

  DateTime? _getFirstAvailableDate(DateTime startDate, DateTime endDate) {
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      final DateTime check = startDate.add(Duration(days: i));
      if (_dashboardC.isDateAvailable(check)) return check;
    }
    return null;
  }

  void _updateSelectedDateToFirstAvailable() {
    if (_ntpTime == null) return;
    final DateTime currentDate = _ntpTime!;
    final DateTime threeMonthsLater = currentDate.add(const Duration(days: 90));

    if (!_dashboardC.isDateAvailable(currentDate)) {
      final DateTime? first = _getFirstAvailableDate(
        currentDate,
        threeMonthsLater,
      );
      if (first != null) {
        setState(() {
          _dashboardC.selectedDate.value = first;
          _dashboardC.dateController.value.text = DateFormat(
            'dd/MM/yyyy',
          ).format(first);
          _selectedDay = first;
          _focusedDay = first;
          _updateNearestWeekendDates();
        });
      }
    } else {
      setState(() => _selectedDay = currentDate);
    }
  }

  void _updateNearestWeekendDates() {
    if (_dashboardC.selectedDate.value == null) return;

    _nearestWeekendDates.clear();
    final DateTime selectedDate = _dashboardC.selectedDate.value!;

    DateTime currentDate = selectedDate;
    if (_ntpTime != null) {
      final DateTime normalizedNTP = DateTime(
        _ntpTime!.year,
        _ntpTime!.month,
        _ntpTime!.day,
      );
      final DateTime normalizedCurrent = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );
      if (normalizedCurrent.isBefore(normalizedNTP)) {
        currentDate = _ntpTime!;
      }
    }

    const weekendDays = [DateTime.thursday, DateTime.friday, DateTime.saturday];

    final bool isSelectedAWeekend = weekendDays.contains(selectedDate.weekday);
    if (!isSelectedAWeekend && _dashboardC.isDateAvailable(selectedDate)) {
      _nearestWeekendDates.add(selectedDate);
    }

    for (int i = 0; i < 14; i++) {
      final DateTime check = currentDate.add(Duration(days: i));
      if (weekendDays.contains(check.weekday)) {
        if (_dashboardC.isDateAvailable(check)) {
          _nearestWeekendDates.add(check);
        }
        if (check.weekday == DateTime.saturday) break;
      }
    }
  }

  bool get _isFormValid =>
      _dashboardC.fromController.value.text.isNotEmpty &&
      _dashboardC.toController.value.text.isNotEmpty &&
      _dashboardC.dateController.value.text.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Auto-scroll
  // ---------------------------------------------------------------------------

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (!mounted) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || _isUserInteracting) {
        timer.cancel();
        return;
      }
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        if (_pageController.hasClients) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  Future<void> _selectSourceLocation() async {
    final City? selectedCity = await Navigator.push<City>(
      context,
      MaterialPageRoute(builder: (_) => SourceLocationScreen()),
    );
    if (selectedCity != null) {
      setState(() {
        _dashboardC.fromController.value.text = selectedCity.name;
      });
    }
  }

  Future<void> _selectDestinationTrek() async {
    final dynamic selectedTrek = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SourceLocationScreen()),
    );
    if (selectedTrek != null) {
      setState(() {
        _dashboardC.toController.value.text = selectedTrek.name;
      });
    }
  }

  Future<void> _handleSearch() async {
    if (!_isFormValid) {
      CustomSnackBar.show(context, message: 'Please provide valid inputs');
      return;
    }
    if (_dashboardC.selectedDate.value != null &&
        !_dashboardC.isDateAvailable(_dashboardC.selectedDate.value!)) {
      CustomSnackBar.show(
        context,
        message:
            'Selected date has no available treks. Please pick another date.',
      );
      return;
    }
    _resetAllScrolls();
    await _trekC.searchTreks(
      cityId: _dashboardC.selectedCityId.value,
      trekId: _dashboardC.selectedTrekId.value,
      date: _dashboardC.dateController.value.text,
      refresh: true,
    );
    Get.toNamed('/search');
  }

  void _handleSearchPress() async {
    // _isPressed already drove the button's shadow styling but never actually
    // blocked re-entry — a fast double-tap could fire _handleSearch() (and
    // searchTreks(refresh: true)) twice before the first tap's 150ms
    // animation delay even finished, duplicating every search result card.
    if (_isPressed) return;
    setState(() => _isPressed = true);
    _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    log('date: ${_dashboardC.dateController.value.text}');
    if (!mounted) return;
    _animationController.reverse();
    setState(() => _isPressed = false);
    _handleSearch();
  }

  Future<void> _toggleFavorite(int id, bool currentlyFavorite) async {
    setState(() => _favoriteTreks[id] = !currentlyFavorite);
    final success = await _dashboardC.toggleTopTrekFavorite(
      id,
      currentlyFavorite,
    );
    if (!success && mounted) {
      setState(() => _favoriteTreks[id] = currentlyFavorite);
    }
  }

  // ---------------------------------------------------------------------------
  // Date picker
  // ---------------------------------------------------------------------------

  Future<void> _selectDate(BuildContext context) async {
    final bool isCityTrekSelected =
        _dashboardC.selectedCityId.value != 0 &&
        _dashboardC.selectedTrekId.value != 0;

    if (!isCityTrekSelected) {
      CustomSnackBar.show(
        context,
        message: 'Please select source and destination first',
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
                  color: _C.cardBg,
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
                    // Header
                    Container(
                      decoration: BoxDecoration(
                        color: _C.fieldBg,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        border: const Border(
                          bottom: BorderSide(color: _C.fieldBorder),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color: _C.inkLight.withValues(alpha: 0.4),
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
                                      color: _C.tealSoft,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _C.teal.withValues(alpha: 0.25),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_month_rounded,
                                      color: _C.teal,
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
                                          color: _C.ink,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Tap an available date to continue',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 10.5,
                                          color: _C.inkMid,
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
                                      color: _C.cardBg,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: _C.fieldBorder),
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: _C.inkMid,
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
                                  color: _C.teal,
                                  label: 'Available',
                                  hasCount: true,
                                ),
                                const SizedBox(width: 14),
                                _legendItem(
                                  color: _C.teal,
                                  label: 'Selected',
                                  solid: true,
                                ),
                                const SizedBox(width: 14),
                                _legendItem(
                                  color: _C.inkLight,
                                  label: 'Unavailable',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Calendar
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _C.cardBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _C.fieldBorder),
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
                                          color: _C.teal,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Loading available dates…',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 11.5,
                                          color: _C.inkMid,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Theme(
                              data: Theme.of(context).copyWith(
                                cardColor: _C.cardBg,
                                scaffoldBackgroundColor: _C.cardBg,
                                colorScheme: ColorScheme.fromSeed(
                                  seedColor: _C.teal,
                                  brightness: Brightness.light,
                                  surface: _C.cardBg,
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
                                    CustomSnackBar.show(
                                      context,
                                      message:
                                          'No treks available on this date',
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
                                    _updateNearestWeekendDates();
                                  });

                                  Get.back();
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
                                    color: _C.ink,
                                    letterSpacing: -0.2,
                                  ),
                                  leftChevronIcon: _chevron(
                                    Icons.chevron_left_rounded,
                                    _C.teal,
                                  ),
                                  rightChevronIcon: _chevron(
                                    Icons.chevron_right_rounded,
                                    _C.teal,
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
                                    color: _C.inkMid,
                                    letterSpacing: 0.4,
                                  ),
                                  weekendStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: _C.danger.withValues(alpha: 0.7),
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

  // ---------------------------------------------------------------------------
  // Calendar cell helpers (unchanged)
  // ---------------------------------------------------------------------------

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
                  color: _C.tealSoft,
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
            color: _C.inkMid,
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
                  colors: [_C.teal, _C.tealLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : isAvailable
              ? _C.tealSoft
              : Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          border: isToday && !isSelected
              ? Border.all(color: _C.teal, width: 1.6)
              : isAvailable && !isSelected
              ? Border.all(color: _C.teal.withValues(alpha: 0.35), width: 1)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _C.teal.withValues(alpha: 0.35),
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
                    ? _C.teal
                    : isWeekend
                    ? _C.danger.withValues(alpha: 0.7)
                    : _C.ink,
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
                      : _C.teal,
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

  // ---------------------------------------------------------------------------
  // DYNAMIC HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader(DashboardHeaderTheme ht) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      margin: const EdgeInsets.only(bottom: 5),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        // Fallback color only — the scene paints the animated sky.
        color: ht.gradientColors.first,
        child: Stack(
          children: [
            // Layered animated scene (sky, weather, mountains, fireworks…)
            Positioned.fill(
              child: HeaderSceneBackground(
                key: ValueKey(
                  'scene_${ht.id}',
                ), // clean restart on theme switch
                scene: ht.scene,
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenConstant.size16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: ScreenConstant.size20),

                    // Logo + Help (structure static; logo swappable for collabs)
                    _FadeSlideIn(
                      delayMs: 0,
                      child: Container(
                        margin: const EdgeInsets.only(left: 18, right: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ht.logoOverrideUrl != null
                                ? Image.network(
                                    ht.logoOverrideUrl!,
                                    height: 7.h,
                                    width: 30.w,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      CommonImages.logo1,
                                      height: 7.h,
                                      width: 30.w,
                                    ),
                                  )
                                : Image.asset(
                                    CommonImages.logo1,
                                    height: 7.h,
                                    width: 30.w,
                                  ),
                            GestureDetector(
                              onTap: () => Get.toNamed('/help'),
                              child: SvgPicture.asset(
                                CommonImages.help,
                                colorFilter: ColorFilter.mode(
                                  ht.ink,
                                  BlendMode.srcIn,
                                ),
                                height: 2.8.h,
                                width: 3.w,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Tagline + seasonal/festival badge
                    _FadeSlideIn(
                      delayMs: 120,
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              ht.tagline,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s14,
                                color: ht.ink,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (ht.badgeText != null)
                              Container(
                                margin: EdgeInsets.only(top: 0.8.h),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: ht.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: ht.accent.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      size: 12,
                                      color: ht.accent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      ht.badgeText!,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        color: ht.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenConstant.size27),

                    // Search card
                    _FadeSlideIn(delayMs: 220, child: _buildSearchCard(ht)),
                    SizedBox(height: ScreenConstant.size20),

                    /*
                    // ---- Trek Types Card (Weekend / Personalized) ----
                    // Temporarily disabled. Restore by uncommenting.
                    Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Card(
                        color: CommonColors.whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(ScreenConstant.size12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(ScreenConstant.size15),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    if (!_isFormValid) {
                                      CustomSnackBar.show(
                                        context,
                                        message: 'Please provide valid inputs',
                                      );
                                      return;
                                    }
                                    if (_nearestWeekendDates.isEmpty) {
                                      _updateNearestWeekendDates();
                                    }
                                    await _trekC.fetchWeekendTreks(
                                      cityId:
                                          _dashboardC.fromController.value.text,
                                      trekId:
                                          _dashboardC.toController.value.text,
                                      date:
                                          _dashboardC.dateController.value.text,
                                      refresh: true,
                                    );
                                    Get.toNamed(
                                      '/weekend-treks',
                                      arguments: {
                                        'city': _dashboardC
                                            .fromController.value.text,
                                        'trek':
                                            _dashboardC.toController.value.text,
                                        'date': _dashboardC
                                            .dateController.value.text,
                                        'weekendDates': _nearestWeekendDates,
                                      },
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        'Weekend Treks',
                                        textScaler:
                                            const TextScaler.linear(1.0),
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: FontSize.s10,
                                          fontWeight: FontWeight.w600,
                                          color: _isFormValid
                                              ? _C.ink
                                              : _C.inkLight,
                                        ),
                                      ),
                                      SizedBox(height: ScreenConstant.size4),
                                      SvgPicture.asset(
                                        CommonImages.weekend,
                                        height: ScreenConstant.size25,
                                        width: ScreenConstant.size25,
                                        colorFilter: ColorFilter.mode(
                                          _isFormValid ? _C.teal : _C.inkLight,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      if (_isFormValid &&
                                          _nearestWeekendDates.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            'Next: ${DateFormat('EEE, MMM d').format(_nearestWeekendDates.first)}',
                                            textScaler:
                                                const TextScaler.linear(1.0),
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: FontSize.s8,
                                              color: _C.inkMid,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: ScreenConstant.size50,
                                color: _C.fieldBorder,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    if (!_isFormValid) {
                                      CustomSnackBar.show(
                                        context,
                                        message: 'Please provide valid inputs',
                                      );
                                      return;
                                    }
                                    Get.toNamed(
                                      '/personalized-treks',
                                      arguments: {
                                        'city': _dashboardC
                                            .fromController.value.text,
                                        'trek':
                                            _dashboardC.toController.value.text,
                                        'date': _dashboardC
                                            .dateController.value.text,
                                      },
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        'Personalized Treks',
                                        textScaler:
                                            const TextScaler.linear(1.0),
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: FontSize.s10,
                                          fontWeight: FontWeight.w600,
                                          color: _isFormValid
                                              ? _C.ink
                                              : _C.inkLight,
                                        ),
                                      ),
                                      SizedBox(height: ScreenConstant.size4),
                                      SvgPicture.asset(
                                        CommonImages.weekend2,
                                        height: ScreenConstant.size25,
                                        width: ScreenConstant.size25,
                                        colorFilter: ColorFilter.mode(
                                          _isFormValid ? _C.teal : _C.inkLight,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      if (_isFormValid &&
                                          _nearestWeekendDates.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            'Unique Trekking Routes',
                                            textScaler:
                                                const TextScaler.linear(1.0),
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: FontSize.s8,
                                              color: _C.inkMid,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenConstant.size20),
                    */

                    // Search button — themed accent + breathing glow
                    _FadeSlideIn(
                      delayMs: 340,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _scaleAnimation,
                            _glowController,
                          ]),
                          builder: (context, child) {
                            final glowAlpha = _isPressed
                                ? 0.0
                                : 0.20 + 0.16 * _glowController.value;
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.75,
                                height: ScreenConstant.size44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ht.accent.withValues(
                                        alpha: glowAlpha,
                                      ),
                                      blurRadius:
                                          12 + 6 * _glowController.value,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: CommonButton(
                                  textColor: Colors.white,
                                  text: 'Search',
                                  onPressed: _handleSearchPress,
                                  backgroundColor: ht.accent,
                                  fontSize: FontSize.s15,
                                  fontWeight: FontWeight.w600,
                                  isFullWidth: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenConstant.size30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard(DashboardHeaderTheme ht) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30),
      child: Card(
        color: CommonColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScreenConstant.size20),
        ),
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.only(
            left: ScreenConstant.size25,
            right: ScreenConstant.size25,
            top: ScreenConstant.size20,
            bottom: ScreenConstant.size16,
          ),
          child: Column(
            children: [
              _buildLocationField(
                ht: ht,
                controller: _dashboardC.fromController.value,
                hint: 'From',
                iconAsset: CommonImages.location3,
                onTap: _selectSourceLocation,
              ),
              const Divider(color: _C.fieldBorder),
              _buildLocationField(
                ht: ht,
                controller: _dashboardC.toController.value,
                hint: 'To',
                iconAsset: CommonImages.location2,
                onTap: _selectDestinationTrek,
              ),
              const Divider(color: _C.fieldBorder),
              _buildDateSection(ht),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required DashboardHeaderTheme ht,
    required TextEditingController controller,
    required String hint,
    required String iconAsset,
    required VoidCallback onTap,
  }) {
    return Stack(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SvgPicture.asset(
                  iconAsset,
                  height: ScreenConstant.size24,
                  width: ScreenConstant.size24,
                  colorFilter: ColorFilter.mode(ht.accent, BlendMode.srcIn),
                ),
              ),
            ),
            SizedBox(width: ScreenConstant.size12),
            Expanded(
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: TextFormField(
                  controller: controller,
                  readOnly: true,
                  onTap: onTap,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s14,
                    fontWeight: FontWeight.w600,
                    color: ht.ink,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s14,
                      fontWeight: FontWeight.w500,
                      color: ht.inkLight,
                    ),
                    contentPadding: const EdgeInsets.only(right: 36),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned.fill(
          child: TouchRipple(
            rippleColor: ht.accent.withValues(alpha: 0.08),
            onTap: onTap,
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }

  /// Departure-date section. If the selected route has NO bookable dates,
  /// the whole section (calendar icon + label + chips) is replaced by a
  /// compact animated empty state.
  Widget _buildDateSection(DashboardHeaderTheme ht) {
    return Obx(() {
      final cityId = _dashboardC.selectedCityId.value;
      final trekId = _dashboardC.selectedTrekId.value;
      final selectedDateValue = _dashboardC.selectedDate.value;
      final dateText = _dashboardC.dateController.value.text;
      final observerState = _dashboardC.calenderTrekDatesObserver.value;

      final bool isCityTrekSelected = cityId != 0 && trekId != 0;
      final bool datesLoading = observerState.maybeWhen(
        loading: (_) => true,
        orElse: () => false,
      );

      final List<TrekDatesModel> calenderTrekDates = observerState.maybeWhen(
        success: (r) =>
            (r as CalenderDatesResponseModel).data?.dates ?? <TrekDatesModel>[],
        orElse: () => <TrekDatesModel>[],
      );

      final DateTime now = _ntpTime ?? DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final List<TrekDatesModel> upcomingDates = calenderTrekDates.where((d) {
        if (d.date == null) return false;
        final dt = DateTime.tryParse(d.date!);
        if (dt == null) return false;
        return dt.isAfter(today.subtract(const Duration(days: 1)));
      }).toList();

      // Route chosen, dates finished loading, nothing bookable →
      // full-section empty state instead of untappable chips.
      final bool noTreksOnRoute =
          isCityTrekSelected &&
          !datesLoading &&
          upcomingDates.isEmpty &&
          dateText.isEmpty;

      if (noTreksOnRoute) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: _NoTreksOnRoute(
            accent: ht.accent,
            accentSoft: ht.accentSoft,
            ink: ht.ink,
            inkMid: ht.inkMid,
          ),
        );
      }

      final first10Dates = upcomingDates.take(10).toList();

      return InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(8),
        splashColor: ht.accent.withValues(alpha: 0.08),
        highlightColor: ht.accent.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18, right: 8),
                child: SvgPicture.asset(
                  CommonImages.calendar,
                  height: ScreenConstant.size24,
                  width: ScreenConstant.size24,
                  colorFilter: ColorFilter.mode(ht.accent, BlendMode.srcIn),
                ),
              ),
              SizedBox(width: ScreenConstant.size12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 1.h),
                    Text(
                      'Departure Date',
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: ht.inkLight,
                        fontSize: FontSize.s10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    if (!isCityTrekSelected)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Select source & destination first',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s10,
                            color: ht.inkLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else if (dateText.isNotEmpty)
                      _buildSelectedDateDisplay(ht, dateText, selectedDateValue)
                    else if (datesLoading)
                      Container(
                        margin: EdgeInsets.only(top: 1.h),
                        height: 6.h,
                        child: Row(
                          children: List.generate(
                            4,
                            (i) => Container(
                              width: 17.w,
                              margin: EdgeInsets.only(right: 2.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ).withShimmerAi(loading: true),
                          ),
                        ),
                      )
                    else
                      _buildDateChips(ht, first10Dates),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSelectedDateDisplay(
    DashboardHeaderTheme ht,
    String dateText,
    DateTime? selectedDateValue,
  ) {
    final bool isAvailable =
        selectedDateValue != null &&
        _dashboardC.isDateAvailable(selectedDateValue);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              dateText,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s12,
                fontWeight: FontWeight.w600,
                color: ht.ink,
              ),
            ),
            if (selectedDateValue != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  isAvailable ? Icons.check_circle : Icons.warning,
                  size: 14,
                  color: isAvailable ? ht.accent : _C.danger,
                ),
              ),
          ],
        ),
        if (selectedDateValue != null && isAvailable)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '${_dashboardC.getTrekCountForDate(selectedDateValue)} trek${_dashboardC.getTrekCountForDate(selectedDateValue) > 1 ? 's' : ''} available',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s8,
                fontWeight: FontWeight.w500,
                color: ht.accent,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateChips(
    DashboardHeaderTheme ht,
    List<TrekDatesModel> first10Dates,
  ) {
    if (first10Dates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          'No available dates found',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s10,
            color: ht.inkLight,
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 1.h),
      height: 6.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: first10Dates.length,
        itemBuilder: (ctx, index) {
          final cardData = first10Dates[index];
          final DateTime? date = DateTime.tryParse(cardData.date ?? '');
          if (date == null) return const SizedBox();

          final String formattedDate = DateFormat('d MMM').format(date);
          final bool isSelected = isSameDay(
            _dashboardC.selectedDate.value,
            date,
          );
          final bool isDateAvailable = _dashboardC.isDateAvailable(date);
          final int trekCount = _dashboardC.getTrekCountForDate(date);

          return GestureDetector(
            onTap: () {
              if (isDateAvailable) {
                setState(() {
                  _dashboardC.selectedDate.value = date;
                  _dashboardC.dateController.value.text = DateFormat(
                    'dd/MM/yyyy',
                  ).format(date);
                  _selectedDay = date;
                  _focusedDay = date;
                  _updateNearestWeekendDates();
                });
                CustomSnackBar.show(
                  context,
                  message: 'Date selected: $formattedDate',
                );
              } else {
                CustomSnackBar.show(
                  context,
                  message: 'No treks available on this date',
                );
              }
            },
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : ScreenConstant.size6,
                right: index == first10Dates.length - 1
                    ? 0
                    : ScreenConstant.size6,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? ht.accent
                      : isDateAvailable
                      ? ht.accent.withValues(alpha: 0.35)
                      : _C.fieldBorder,
                  width: isSelected ? 1.5 : 0.8,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? ht.accentSoft
                    : isDateAvailable
                    ? ht.accentSoft.withValues(alpha: 0.4)
                    : _C.fieldBg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s10,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? ht.accent
                          : isDateAvailable
                          ? ht.accent
                          : ht.inkMid,
                    ),
                  ),
                  if (isDateAvailable && trekCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        '$trekCount',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s8,
                          fontWeight: FontWeight.w700,
                          color: ht.accent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);

    return Scaffold(
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        controller: _scrollController,
        child: Column(
          children: [
            // Dynamic themed header — cross-fades between themes
            Obx(() {
              final ht = _themeC.theme.value;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: KeyedSubtree(
                  key: ValueKey('header_${ht.id}'),
                  child: _buildHeader(ht),
                ),
              );
            }),

            // ----------------------------------------------------------------
            // Content sections — each Obx parses its own data reactively
            // ----------------------------------------------------------------
            Container(
              color: _C.bg,
              child: Column(
                spacing: MediaQuery.of(context).size.height / 50,
                children: [
                  // ── What's New ──
                  Obx(() {
                    final whatsNewLoading = _dashboardC.whatsNewObserver.value
                        .maybeWhen(loading: (_) => true, orElse: () => false);

                    final whatsNewResponse = _dashboardC.whatsNewObserver.value
                        .maybeWhen(
                          success: (data) => data.data ?? [],
                          orElse: () => [],
                        );

                    final List<KnowMoreData> whatsNewCardsData =
                        whatsNewResponse.map<KnowMoreData>((e) {
                          return KnowMoreData(
                            title: e.title ?? '',
                            subtitle: e.subtitle ?? '',
                            hasKnowMore: e.hasKnowMore ?? false,
                            imagePath: getFullImageUrl(e.imagePath),
                            textColour: e.textColour ?? '#FFFFFF',
                            gradient: _safeGradient(e.gradient, [
                              '#0F7B6C',
                              '#1AA090',
                            ]),
                            detailedTitle: e.detailedTitle,
                            detailedDescription: e.detailedDescription,
                            bulletPoints: e.bulletPoints,
                            callToAction: e.callToAction,
                          );
                        }).toList();

                    if (!whatsNewLoading && whatsNewCardsData.isEmpty) {
                      return const SizedBox();
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: ScreenConstant.size17,
                            right: ScreenConstant.size17,
                            top: ScreenConstant.size10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "What's New",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: FontSize.s13,
                                      fontWeight: FontWeight.w700,
                                      color: _C.ink,
                                      letterSpacing: -0.2,
                                    ),
                                  ).withShimmerAi(loading: whatsNewLoading),
                                  SizedBox(height: 0.3.h),
                                  Text(
                                    'Adventure simplified combo delivers!',
                                    textScaler: const TextScaler.linear(1.0),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: FontSize.s10,
                                      color: _C.inkMid,
                                    ),
                                  ).withShimmerAi(loading: whatsNewLoading),
                                ],
                              ),
                              InkWell(
                                onTap: () => Get.toNamed('/know-more-screen'),
                                child: Text(
                                  'View more',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: _C.teal,
                                    fontSize: FontSize.s11,
                                    letterSpacing: 0.4,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ).withShimmerAi(loading: whatsNewLoading),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 1.h),
                          height: 22.h,
                          child: Builder(
                            builder: (context) {
                              if (whatsNewLoading) {
                                return _buildShimmerPagePlaceholder();
                              }

                              // The infinite-loop PageView trick (index %
                              // length, repeated forever) only makes sense
                              // with 2+ distinct cards — with exactly one,
                              // it just shows the same card over and over,
                              // which reads as duplicate/broken content.
                              if (whatsNewCardsData.length <= 1) {
                                if (whatsNewCardsData.isEmpty) {
                                  return const SizedBox();
                                }
                                final cardData = whatsNewCardsData.first;
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: KnowMoreCard(
                                    widthFraction: 92,
                                    trailingMargin: 0,
                                    gradientColors: cardData.gradient ?? [],
                                    imagePath: cardData.imagePath ?? '',
                                    title: cardData.title ?? '',
                                    subtitle: cardData.subtitle ?? '',
                                    textColor: AppTheme.hexToColor(
                                      cardData.textColour,
                                    ),
                                    onKnowMoreTap: cardData.hasKnowMore == false
                                        ? null
                                        : () {
                                            Get.toNamed(
                                              '/know-more-details',
                                              arguments: {
                                                'knowMoreData': cardData,
                                              },
                                            );
                                          },
                                  ),
                                );
                              }

                              return Listener(
                                onPointerDown: (_) {
                                  _isUserInteracting = true;
                                  _stopAutoScroll();
                                },
                                onPointerUp: (_) {
                                  _isUserInteracting = false;
                                  _startAutoScroll();
                                },
                                onPointerCancel: (_) {
                                  _isUserInteracting = false;
                                  _startAutoScroll();
                                },
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: null, // infinite scroll
                                  onPageChanged: (page) {
                                    _currentPage =
                                        page % whatsNewCardsData.length;
                                  },
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final cardData =
                                        whatsNewCardsData[index %
                                            whatsNewCardsData.length];
                                    return KnowMoreCard(
                                      gradientColors: cardData.gradient ?? [],
                                      imagePath: cardData.imagePath ?? '',
                                      title: cardData.title ?? '',
                                      subtitle: cardData.subtitle ?? '',
                                      textColor: AppTheme.hexToColor(
                                        cardData.textColour,
                                      ),
                                      onKnowMoreTap:
                                          cardData.hasKnowMore == false
                                          ? null
                                          : () {
                                              Get.toNamed(
                                                '/know-more-details',
                                                arguments: {
                                                  'knowMoreData': cardData,
                                                },
                                              );
                                            },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }),

                  // ── Top Treks ──
                  Obx(() {
                    final topTreksLoading = _dashboardC.topTreksObserver.value
                        .maybeWhen(loading: (_) => true, orElse: () => false);

                    final topTreksResponse = _dashboardC.topTreksObserver.value
                        .maybeWhen(
                          success: (data) => data.data ?? [],
                          orElse: () => [],
                        );

                    if (!topTreksLoading && topTreksResponse.isEmpty) {
                      return const SizedBox();
                    }

                    // 4:5 portrait, matching the recommended upload spec
                    // (1080x1350 / min 720x900) and the grid card ratio on
                    // the "View more" screen — same ratio everywhere a
                    // Top Treks photo is displayed.
                    final topTreksCardWidth = 68.w;
                    final topTreksCardHeight = topTreksCardWidth * 1.25;

                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: ScreenConstant.size17,
                            right: ScreenConstant.size17,
                            top: ScreenConstant.size10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Top Treks',
                                    textScaler: const TextScaler.linear(1.0),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: FontSize.s13,
                                      fontWeight: FontWeight.w700,
                                      color: _C.ink,
                                      letterSpacing: -0.2,
                                    ),
                                  ).withShimmerAi(loading: topTreksLoading),
                                  SizedBox(height: 0.3.h),
                                  Text(
                                    "Season's Best Treks, Ready for you!",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: FontSize.s10,
                                      color: _C.inkMid,
                                    ),
                                  ).withShimmerAi(loading: topTreksLoading),
                                ],
                              ),
                              InkWell(
                                onTap: () => Get.toNamed('/popular-treks'),
                                child: Text(
                                  'View more',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: _C.teal,
                                    fontSize: FontSize.s11,
                                    letterSpacing: 0.4,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ).withShimmerAi(loading: topTreksLoading),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: topTreksCardHeight,
                          child: Padding(
                            padding: EdgeInsets.only(top: 1.h),
                            child: topTreksLoading
                                ? _buildTopTreksShimmerPlaceholder(
                                    topTreksCardWidth,
                                    topTreksCardHeight,
                                  )
                                : PageView.builder(
                                    controller: _topTreksPageController,
                                    padEnds: false,
                                    itemCount: topTreksResponse.length,
                                    itemBuilder: (context, index) {
                                      final trekData = topTreksResponse[index];
                                      final isTrending =
                                          trekData.badgeType == 'trending';
                                      final trekId = trekData.id;
                                      final isFavorite =
                                          _favoriteTreks[trekId] ??
                                          (trekData.isFavorite ?? false);
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          left: ScreenConstant.size12,
                                          right: ScreenConstant.size6,
                                        ),
                                        child: TopTreksCard(
                                          imagePath: getFullImageUrl(
                                            trekData.imagePath,
                                          ),
                                          title: trekData.title ?? '',
                                          description:
                                              trekData.description ?? '',
                                          kicker: trekData.kicker,
                                          meta: trekData.meta,
                                          badgeText: isTrending
                                              ? 'Trending'
                                              : 'Top Pick',
                                          badgeIcon: isTrending
                                              ? Icons
                                                    .local_fire_department_rounded
                                              : Icons.star_rounded,
                                          width: topTreksCardWidth,
                                          height: topTreksCardHeight,
                                          isFavorite: isFavorite,
                                          onFavoriteTap: trekId == null
                                              ? null
                                              : () => _toggleFavorite(
                                                  trekId,
                                                  isFavorite,
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    );
                  }),

                  // ── Seasonal Forecast (seasonal_forecast_picks backend) ──
                  Obx(() {
                    final seasonalLoading = _dashboardC
                        .seasonalPicksObserver
                        .value
                        .maybeWhen(loading: (_) => true, orElse: () => false);

                    final seasonalData = _dashboardC.seasonalPicksObserver.value
                        .maybeWhen(
                          success: (data) => data.data,
                          orElse: () => null,
                        );

                    // Explicit generic — see seasonal_forecast_screen.dart
                    // for why an inferred `[]` here has crashed in release
                    // builds as List<dynamic> instead of List<SeasonalPickItem>.
                    final topPicks =
                        seasonalData?.topPicks ?? <SeasonalPickItem>[];
                    final avoidPicks =
                        seasonalData?.avoidPicks ?? <SeasonalPickItem>[];

                    if (!seasonalLoading &&
                        topPicks.isEmpty &&
                        avoidPicks.isEmpty) {
                      return const SizedBox();
                    }

                    final season = TrekSeason.values.firstWhere(
                      (s) => s.name == seasonalData?.season,
                      orElse: () => TrekSeason.spring,
                    );
                    final label = seasonalData?.label ?? '';

                    // Preview: top picks + one avoid pick, so the home
                    // screen shows both sides, not just the "good news"
                    // half — capped so the row still fits comfortably.
                    final previewPicks = [
                      ...topPicks.take(4),
                      ...avoidPicks.take(1),
                    ];

                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: ScreenConstant.size16,
                            right: ScreenConstant.size16,
                            top: ScreenConstant.size10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Seasonal Forecast',
                                      textScaler: const TextScaler.linear(1.0),
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: FontSize.s13,
                                        fontWeight: FontWeight.w700,
                                        color: _C.ink,
                                        letterSpacing: -0.2,
                                      ),
                                    ).withShimmerAi(loading: seasonalLoading),
                                    SizedBox(height: 0.3.h),
                                    Text(
                                      "Best for $label — and what to skip",
                                      textScaler: const TextScaler.linear(1.0),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: FontSize.s10,
                                        fontWeight: FontWeight.w400,
                                        color: _C.inkMid,
                                      ),
                                    ).withShimmerAi(loading: seasonalLoading),
                                  ],
                                ),
                              ),
                              SizedBox(width: 2.w),
                              InkWell(
                                onTap: () => Get.toNamed('/seasonal-forecast'),
                                child: Text(
                                  'View more',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    letterSpacing: 0.4,
                                    color: _C.teal,
                                    fontSize: FontSize.s11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ).withShimmerAi(loading: seasonalLoading),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _seasonalForecastController,
                          child: Container(
                            margin: EdgeInsets.only(
                              left: ScreenConstant.size15,
                              top: 1.5.h,
                              bottom: ScreenConstant.size15,
                            ),
                            child: seasonalLoading
                                ? _buildSeasonalPicksShimmerPlaceholder(
                                    70.w,
                                    24.h,
                                  )
                                : Row(
                                    children: previewPicks.map((pick) {
                                      final pickImageType =
                                          parseSeasonalPickImageType(
                                            pick.imageType,
                                          );
                                      final resolvedImagePath = getFullImageUrl(
                                        pick.imagePath,
                                      );
                                      // Only "photo" mode falls back to
                                      // a stock photo when empty — an
                                      // empty illustration is a valid,
                                      // handled state inside the card
                                      // (gradient alone, no overlay).
                                      final displayImagePath =
                                          pickImageType ==
                                              SeasonalPickImageType.illustration
                                          ? resolvedImagePath
                                          : (resolvedImagePath.isEmpty
                                                ? CommonImages.himalayas
                                                : resolvedImagePath);
                                      return Padding(
                                        padding: EdgeInsets.only(right: 3.w),
                                        child: SeasonalGradientCard(
                                          trekName: pick.trekName ?? '',
                                          reason: pick.reason ?? '',
                                          imagePath: displayImagePath,
                                          imageType: pickImageType,
                                          isAvoid: pick.isAvoid ?? false,
                                          season: season,
                                          width: 70.w,
                                          height: 24.h,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                        ),
                      ],
                    );
                  }),

                  SizedBox(height: ScreenConstant.size20),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10.0,
                      bottom: 30.0,
                      right: 80.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Go Beyond,\nExplore More!',
                          textAlign: TextAlign.start,
                          style: GoogleFonts.sourceSerif4(
                            fontSize: FontSize.s28,
                            fontWeight: FontWeight.bold,
                            color: CommonColors.greyColorf7f7f7.withValues(
                              alpha: 0.5,
                            ),
                            height: 1.3,
                            letterSpacing: 1.8,
                          ),
                        ),
                        SizedBox(height: ScreenConstant.size20),
                        RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: FontSize.s14,
                              color: CommonColors.greyColorf7f7f7,
                              letterSpacing: 1.8,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: 'Crafted with passion '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.bottom,
                                child: Icon(
                                  Icons.favorite,
                                  color: CommonColors.red_B52424,
                                  size: FontSize.s12,
                                ),
                              ),
                              const TextSpan(text: '\nrooted in Hyderabad.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ScreenConstant.size20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shimmer placeholder helpers
  // ---------------------------------------------------------------------------

  Widget _buildShimmerPagePlaceholder() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 2,
      itemBuilder: (_, __) => Container(
        width: MediaQuery.of(context).size.width * 0.82,
        margin: EdgeInsets.only(right: ScreenConstant.size6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ).withShimmerAi(loading: true),
    );
  }

  Widget _buildTopTreksShimmerPlaceholder(double width, double height) {
    return Row(
      children: List.generate(
        1,
        (i) => Padding(
          padding: EdgeInsets.only(
            left: ScreenConstant.size12,
            right: ScreenConstant.size6,
          ),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
          ).withShimmerAi(loading: true),
        ),
      ),
    );
  }

  Widget _buildSeasonalPicksShimmerPlaceholder(double width, double height) {
    return Row(
      children: List.generate(
        3,
        (i) => Padding(
          padding: EdgeInsets.only(right: 3.w),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ).withShimmerAi(loading: true),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header animation helpers
// ---------------------------------------------------------------------------

/// Staggered fade + slide-up entrance for header sections.
class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const _FadeSlideIn({required this.child, this.delayMs = 0});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );
  late final Animation<double> _a = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, child) => Opacity(
        opacity: _a.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _a.value) * 18),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Compact animated empty state shown when the selected From→To route has
/// no bookable trek dates: a hiker gently pacing across a faded peak.
class _NoTreksOnRoute extends StatefulWidget {
  final Color accent;
  final Color accentSoft;
  final Color ink;
  final Color inkMid;

  const _NoTreksOnRoute({
    required this.accent,
    required this.accentSoft,
    required this.ink,
    required this.inkMid,
  });

  @override
  State<_NoTreksOnRoute> createState() => _NoTreksOnRouteState();
}

class _NoTreksOnRouteState extends State<_NoTreksOnRoute>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.scale(scale: 0.96 + 0.04 * v, child: child),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: widget.accentSoft.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: widget.accent.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 46,
              height: 40,
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, __) {
                  final t = _c.value;
                  return Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 4,
                        child: Icon(
                          Icons.terrain_rounded,
                          size: 34,
                          color: widget.accent.withValues(alpha: 0.3),
                        ),
                      ),
                      Positioned(
                        bottom: 8 + 4 * math.sin(t * math.pi),
                        left: 8 + 14 * t,
                        child: Icon(
                          Icons.hiking_rounded,
                          size: 19,
                          color: widget.accent,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No treks on this route yet',
                    textScaler: TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: widget.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Try a different source or destination',
                    textScaler: TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9.5,
                      color: widget.inkMid,
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
