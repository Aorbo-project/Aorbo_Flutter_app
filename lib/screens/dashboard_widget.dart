import 'dart:developer';
import 'dart:math' as math;

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/widgets/dissolve_to_dashboard.dart' show whenDashboardVisible;
import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/common_btn.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/dashboard_header_theme.dart';
import 'package:arobo_app/utils/header_scene.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/know_more_card.dart';
import 'package:arobo_app/utils/sponsored_video_card.dart';
import 'package:arobo_app/models/sponsored_slot_data.dart';
import 'package:arobo_app/utils/seasonal_forecast_mock_data.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:flutter_touch_ripple/flutter_touch_ripple.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import 'package:sizer/sizer.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:ntp/ntp.dart';
import 'package:table_calendar/table_calendar.dart';

import '../freezed_models/treks/treks_model_data.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';

/// Neutral palette for the body/calendar. The HEADER no longer reads from
/// this — it is fully driven by DashboardHeaderTheme.
class _C {
  static const bg = AppColors.bgCool;
  static const cardBg = AppColors.surface;
  static const ink = AppColors.ink;
  static const inkMid = AppColors.inkMid;
  static const inkLight = AppColors.inkLight;
  static const teal = AppColors.teal;
  static const tealLight = AppColors.tealLight;
  static const tealSoft = AppColors.tealSoft;
  static const fieldBg = AppColors.elevated;
  static const fieldBorder = AppColors.border;
  static const shadow = Color(0x0D000000);
  static const iconBadgeBg = AppColors.ink;
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
    return 'https://api.aorbotreks.co.in$path';
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
      _dashboardC.fetchWhatsNew();
      _dashboardC.fetchTopTreks();
      _dashboardC.fetchSeasonalPicks();
      _dashboardC.fetchSponsoredSlots();
    });
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
    final bool? completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SourceLocationScreen()),
    );

    // If the user successfully completed the route selection, check
    // availability immediately (no debounce) and only open the calendar
    // if there's actually something to show — otherwise the dashboard's
    // own "no treks on this route" card takes over, no empty popup.
    if (completed == true && mounted) {
      await _dashboardC.fetchCalendarDatesNow();
      if (!mounted) return;
      if (_dashboardC.availableDates.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _selectDate(context);
        });
      }
    }
  }

  Future<void> _selectDestinationTrek() async {
    final bool? completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SourceLocationScreen()),
    );

    if (completed == true && mounted) {
      await _dashboardC.fetchCalendarDatesNow();
      if (!mounted) return;
      if (_dashboardC.availableDates.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _selectDate(context);
        });
      }
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

  /// Open a sponsored ad's click-through URL in the external browser.
  Future<void> _openSponsoredUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // A dead ad URL must never surface an error to the user.
    }
  }

  void _handleSearchPress() async {
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Select Departure Date',
                                        style: AppType.style(
                                          15.5,
                                          w: FontWeight.w700,
                                          color: _C.ink,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Tap an available date to continue',
                                        style: AppType.style(
                                          10.5,
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
                                      Text(
                                        'Loading available dates…',
                                        style: AppType.style(
                                          11.5,
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
                                  titleTextStyle: AppType.style(
                                    14.5,
                                    w: FontWeight.w700,
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
                                  weekdayStyle: AppType.style(
                                    10.5,
                                    w: FontWeight.w700,
                                    color: _C.inkMid,
                                    letterSpacing: 0.4,
                                  ),
                                  weekendStyle: AppType.style(
                                    10.5,
                                    w: FontWeight.w700,
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
  // Calendar cell helpers
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
                    style: AppType.style(9, w: FontWeight.w800, color: color),
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
          style: AppType.style(9.5, w: FontWeight.w500, color: _C.inkMid),
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
              style: AppType.style(
                12.5,
                w: isSelected || isAvailable
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
                style: AppType.style(
                  9,
                  w: FontWeight.w800,
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
        color: ht.gradientColors.first,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: Duration(
                  milliseconds: _themeC.hasResolvedRemote.value ? 600 : 0,
                ),
                child: HeaderSceneBackground(
                  key: ValueKey('scene_${ht.id}'),
                  scene: ht.scene.layers.isEmpty
                      ? DashboardHeaderTheme.classic.scene
                      : ht.scene,
                ),
              ),
            ),
            if (HeaderThemeController.debugThemeSwitcherEnabled)
              SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6, right: 6),
                    child: _DebugSeasonSwitcher(
                      current: ht,
                      controller: _themeC,
                    ),
                  ),
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

                    _FadeSlideIn(
                      delayMs: 150,
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              ht.tagline,
                              textAlign: TextAlign.center,
                              style: AppType.style(
                                FontSize.s14,
                                w: FontWeight.w600,
                                color: ht.ink,
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
                                      style: AppType.style(
                                        9.5,
                                        w: FontWeight.w600,
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

                    _FadeSlideIn(delayMs: 290, child: _buildSearchCard(ht)),
                    SizedBox(height: ScreenConstant.size20),

                    _FadeSlideIn(
                      delayMs: 440,
                      // The "no treks on this route" inline card already has
                      // its own Change Route / Notify Me buttons — showing
                      // this main CTA too would just duplicate them.
                      child: Obx(() {
                        if (_computeNoTreksOnRoute()) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            Center(
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
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.75,
                                      height: ScreenConstant.size44,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          30,
                                        ),
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
                            SizedBox(height: ScreenConstant.size30),
                          ],
                        );
                      }),
                    ),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    final hasValue = value.text.isNotEmpty;
                    return Text(
                      hasValue ? value.text : hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textScaler: const TextScaler.linear(1.0),
                      style: hasValue
                          ? AppType.style(
                              FontSize.s14,
                              w: FontWeight.w600,
                              color: ht.ink,
                            )
                          : AppType.style(
                              FontSize.s14,
                              w: FontWeight.w500,
                              color: ht.inkLight,
                            ),
                    );
                  },
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

  /// Single source of truth for "does the selected route currently have
  /// zero bookable dates". Read reactively — call only from inside an
  /// Obx (or another reactive builder) so Rx dependencies are tracked.
  /// Shared by the date section's empty state and the Search button, so
  /// the two can never drift out of sync with each other.
  bool _computeNoTreksOnRoute() {
    final cityId = _dashboardC.selectedCityId.value;
    final trekId = _dashboardC.selectedTrekId.value;
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

    final bool hasNoValidDates =
        upcomingDates.isEmpty ||
        upcomingDates.every((d) {
          final dt = DateTime.tryParse(d.date ?? '');
          return dt == null || !_dashboardC.isDateAvailable(dt);
        });

    return isCityTrekSelected && !datesLoading && hasNoValidDates;
  }

  /// Departure-date section. If the selected route has NO bookable dates,
  /// the whole section (calendar icon + label + chips) is replaced by a
  /// compact animated empty state.
  Widget _buildDateSection(DashboardHeaderTheme ht) {
    return Obx(() {
      final selectedDateValue = _dashboardC.selectedDate.value;
      final dateText = _dashboardC.dateController.value.text;
      final observerState = _dashboardC.calenderTrekDatesObserver.value;

      final bool isCityTrekSelected =
          _dashboardC.selectedCityId.value != 0 &&
          _dashboardC.selectedTrekId.value != 0;
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

      final bool noTreksOnRoute = _computeNoTreksOnRoute();

      if (noTreksOnRoute) {
        if (dateText.isNotEmpty || selectedDateValue != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _dashboardC.selectedDate.value = null;
              _dashboardC.dateController.value.clear();
            }
          });
        }

        final String routeKey =
            '${_dashboardC.selectedCityId.value}_${_dashboardC.selectedTrekId.value}';
        final bool isInitiallyNotified =
            _dashboardC.notifiedRoutes[routeKey] ?? false;

        return _NoTreksOnRouteSection(
          accent: ht.accent,
          accentSoft: ht.accentSoft,
          ink: ht.ink,
          inkMid: ht.inkMid,
          inkLight: ht.inkLight,
          fieldBg: _C.fieldBg,
          fieldBorder: _C.fieldBorder,
          isInitiallyNotified: isInitiallyNotified,
          onNotifyMe: () => _showNotifyMeBottomSheet(
            ht,
            _dashboardC.fromController.value.text,
            _dashboardC.toController.value.text,
            routeKey: routeKey,
          ),
          onChangeRoute: _handleChangeRoute,
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
                      style: AppType.style(
                        FontSize.s10,
                        w: FontWeight.w500,
                        color: ht.inkLight,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    if (!isCityTrekSelected)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Select source & destination first',
                          style: AppType.style(
                            FontSize.s10,
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
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 4,
                          itemBuilder: (_, i) => Container(
                            width: 17.w,
                            margin: EdgeInsets.only(right: 2.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ).withShimmerAi(loading: true),
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

  /// Scrolls the dashboard to the top so the user can see and edit both
  /// the "From" and "To" fields, then opens the source-location picker.
  void _handleChangeRoute() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _selectSourceLocation();
    });
  }

  /// Shows a themed bottom sheet that simulates the notify-me subscription
  /// flow: loading → success → auto-close. The `onSuccess` callback is
  /// invoked only after the "API call" completes, so the caller can update
  /// its inline state accurately.
  Future<void> _showNotifyMeBottomSheet(
    DashboardHeaderTheme ht,
    String from,
    String to, {
    required String routeKey,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => _NotifyMeSheet(
        ht: ht,
        from: from,
        to: to,
        onSuccess: () async {
          // Don't wrap in if(!success) throw Exception('Failed to subscribe') —
          // that masks the real server message. Let the controller throw with
          // the actual message; _NotifyMeSheetState._extractServerMessage
          // will surface it in the sheet UI.
          await _dashboardC.subscribeToRouteNotification(
            _dashboardC.selectedCityId.value,
            _dashboardC.selectedTrekId.value,
          );
        },
      ),
    );
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
              style: AppType.style(
                FontSize.s12,
                w: FontWeight.w600,
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
              style: AppType.style(
                FontSize.s8,
                w: FontWeight.w500,
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
          style: AppType.style(FontSize.s10, color: ht.inkLight),
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
                    style: AppType.style(
                      FontSize.s10,
                      w: isSelected ? FontWeight.w700 : FontWeight.w500,
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
                        style: AppType.style(
                          FontSize.s8,
                          w: FontWeight.w700,
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
      backgroundColor: _C.bg,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        controller: _scrollController,
        child: Column(
          children: [
            // Dynamic themed header. Only the background scene + gradient
            // cross-fade when the theme changes — the foreground content
            // (logo / tagline / search / CTA) stays mounted, so its staggered
            // entrance runs exactly once and doesn't blink when the theme
            // resolves from default → cache → remote a beat after open.
            Obx(() {
              final ht = _themeC.theme.value;
              return _buildHeader(ht);
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

                    // One in-feed sponsored video card (server-chosen this
                    // session), dropped at its configured position — never
                    // first or last, and only when there are enough real
                    // cards for it not to dominate the row.
                    final List<Object> whatsNewFeed =
                        List<Object>.from(whatsNewCardsData);
                    final SponsoredSlot? adSlot =
                        _dashboardC.whatsNewSlot.value;
                    if (adSlot != null &&
                        (adSlot.videoUrl ?? '').isNotEmpty &&
                        whatsNewCardsData.length >= 2) {
                      final insertAt = adSlot.position
                          .clamp(1, whatsNewCardsData.length);
                      whatsNewFeed.insert(insertAt, adSlot);
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
                                    style: AppType.style(
                                      FontSize.s13,
                                      w: FontWeight.w700,
                                      color: _C.ink,
                                      letterSpacing: -0.2,
                                    ),
                                  ).withShimmerAi(loading: whatsNewLoading),
                                  SizedBox(height: 0.3.h),
                                  Text(
                                    'Adventure simplified combo delivers!',
                                    textScaler: const TextScaler.linear(1.0),
                                    style: AppType.style(
                                      FontSize.s10,
                                      color: _C.inkMid,
                                    ),
                                  ).withShimmerAi(loading: whatsNewLoading),
                                ],
                              ),
                              InkWell(
                                onTap: () => Get.toNamed('/know-more-screen'),
                                child: Text(
                                  'View more',
                                  style: AppType.style(
                                    FontSize.s11,
                                    w: FontWeight.w600,
                                    color: _C.teal,
                                    letterSpacing: 0.4,
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
                                    _currentPage = page % whatsNewFeed.length;
                                  },
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final item =
                                        whatsNewFeed[index % whatsNewFeed.length];

                                    if (item is SponsoredSlot) {
                                      return SponsoredVideoCard(
                                        videoUrl: item.videoUrl ?? '',
                                        advertiser: item.advertiser,
                                        headline: item.headline ?? '',
                                        onImpression: () => _dashboardC
                                            .logSponsoredImpression(item.id),
                                        onCtaTap: () {
                                          _dashboardC
                                              .logSponsoredClick(item.id);
                                          _openSponsoredUrl(item.ctaUrl);
                                        },
                                      );
                                    }

                                    final cardData = item as KnowMoreData;
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
                                    style: AppType.style(
                                      FontSize.s13,
                                      w: FontWeight.w700,
                                      color: _C.ink,
                                      letterSpacing: -0.2,
                                    ),
                                  ).withShimmerAi(loading: topTreksLoading),
                                  SizedBox(height: 0.3.h),
                                  Text(
                                    "Season's Best Treks, Ready for you!",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: AppType.style(
                                      FontSize.s10,
                                      color: _C.inkMid,
                                    ),
                                  ).withShimmerAi(loading: topTreksLoading),
                                ],
                              ),
                              InkWell(
                                onTap: () => Get.toNamed('/popular-treks'),
                                child: Text(
                                  'View more',
                                  style: AppType.style(
                                    FontSize.s11,
                                    w: FontWeight.w600,
                                    color: _C.teal,
                                    letterSpacing: 0.4,
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
                                    // +1 for one server-chosen vendor-promoted
                                    // ("Sponsored") trek at its configured
                                    // position — never first or last.
                                    itemCount: (_dashboardC.topTreksSlot.value !=
                                                null &&
                                            topTreksResponse.length >= 2)
                                        ? topTreksResponse.length + 1
                                        : topTreksResponse.length,
                                    itemBuilder: (context, index) {
                                      final SponsoredSlot? trekSlot =
                                          _dashboardC.topTreksSlot.value;
                                      final hasSponsored = trekSlot != null &&
                                          topTreksResponse.length >= 2;
                                      final sponsoredAt = hasSponsored
                                          ? trekSlot.position
                                              .clamp(1, topTreksResponse.length)
                                          : -1;

                                      if (hasSponsored &&
                                          index == sponsoredAt) {
                                        _dashboardC.logSponsoredImpression(
                                          trekSlot.id,
                                        );
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            left: ScreenConstant.size12,
                                            right: ScreenConstant.size6,
                                          ),
                                          child: TopTreksCard(
                                            isSponsored: true,
                                            onTap: () {
                                              _dashboardC.logSponsoredClick(
                                                trekSlot.id,
                                              );
                                              Get.toNamed('/popular-treks');
                                            },
                                            imagePath: getFullImageUrl(
                                              trekSlot.imagePath,
                                            ),
                                            title: trekSlot.title ??
                                                trekSlot.advertiser,
                                            description:
                                                'By ${trekSlot.advertiser}',
                                            kicker: trekSlot.kicker,
                                            meta: trekSlot.meta,
                                            width: topTreksCardWidth,
                                            height: topTreksCardHeight,
                                          ),
                                        );
                                      }

                                      final dataIndex =
                                          hasSponsored && index > sponsoredAt
                                          ? index - 1
                                          : index;
                                      final trekData =
                                          topTreksResponse[dataIndex];
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
                                          onTap: () =>
                                              Get.toNamed('/popular-treks'),
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
                                      style: AppType.style(
                                        FontSize.s13,
                                        w: FontWeight.w700,
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
                                      style: AppType.style(
                                        FontSize.s10,
                                        w: FontWeight.w400,
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
                                  style: AppType.style(
                                    FontSize.s11,
                                    w: FontWeight.w600,
                                    color: _C.teal,
                                    letterSpacing: 0.4,
                                  ),
                                ).withShimmerAi(loading: seasonalLoading),
                              ),
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
                                : Builder(
                                    builder: (context) {
                                      final List<Widget> seasonalCards =
                                          previewPicks.map<Widget>((pick) {
                                        final pickImageType =
                                            parseSeasonalPickImageType(
                                          pick.imageType,
                                        );
                                        final resolvedImagePath =
                                            getFullImageUrl(pick.imagePath);
                                        final displayImagePath = pickImageType ==
                                                SeasonalPickImageType
                                                    .illustration
                                            ? resolvedImagePath
                                            : (resolvedImagePath.isEmpty
                                                ? CommonImages.himalayas
                                                : resolvedImagePath);
                                        return Padding(
                                          padding:
                                              EdgeInsets.only(right: 3.w),
                                          child: SeasonalGradientCard(
                                            onTap: () => Get.toNamed(
                                                '/seasonal-forecast'),
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
                                      }).toList();

                                      // One in-feed sponsored video card
                                      // (server-chosen this session), dropped
                                      // at its configured position — never
                                      // first or last, and only with enough
                                      // real cards around it.
                                      final SponsoredSlot? seasonalAd =
                                          _dashboardC
                                              .seasonalForecastSlot.value;
                                      if (seasonalAd != null &&
                                          (seasonalAd.videoUrl ?? '')
                                              .isNotEmpty &&
                                          seasonalCards.length >= 2) {
                                        final insertAt = seasonalAd.position
                                            .clamp(1, seasonalCards.length);
                                        seasonalCards.insert(
                                          insertAt,
                                          Padding(
                                            padding:
                                                EdgeInsets.only(right: 3.w),
                                            child: SizedBox(
                                              width: 70.w,
                                              height: 24.h,
                                              child: SponsoredVideoCard(
                                                videoUrl:
                                                    seasonalAd.videoUrl ?? '',
                                                advertiser:
                                                    seasonalAd.advertiser,
                                                headline:
                                                    seasonalAd.headline ?? '',
                                                widthFraction: 70,
                                                trailingMargin: 0,
                                                onImpression: () => _dashboardC
                                                    .logSponsoredImpression(
                                                        seasonalAd.id),
                                                onCtaTap: () {
                                                  _dashboardC
                                                      .logSponsoredClick(
                                                          seasonalAd.id);
                                                  _openSponsoredUrl(
                                                      seasonalAd.ctaUrl);
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      return Row(children: seasonalCards);
                                    },
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
                            fontSize: AppType.clampFontSize(FontSize.s28),
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
                              fontSize: AppType.clampFontSize(FontSize.s14),
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

  // Single card only — shimmer_ai gives every .withShimmerAi() instance its
  // own independently-timed AnimationController (confirmed via package
  // source), so two adjacent shimmering cards never stay in phase and their
  // brightness bands visibly misalign right at the seam between them. A
  // second "peek" card wasn't worth that broken-looking artifact, and real
  // data mostly renders a single card here anyway (see the `length <= 1`
  // branch above).
  Widget _buildShimmerPagePlaceholder() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.82,
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

  // Single card only — same shimmer_ai desync issue as
  // _buildShimmerPagePlaceholder above: 3 adjacent independently-timed
  // shimmer sweeps would look even more visibly broken than 2 did.
  Widget _buildSeasonalPicksShimmerPlaceholder(double width, double height) {
    return Padding(
      padding: EdgeInsets.only(left: ScreenConstant.size12),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ).withShimmerAi(loading: true),
    );
  }
}

// ---------------------------------------------------------------------------
// Header animation helpers
// ---------------------------------------------------------------------------

class _DebugSeasonSwitcher extends StatelessWidget {
  final DashboardHeaderTheme current;
  final HeaderThemeController controller;
  const _DebugSeasonSwitcher({required this.current, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themes = DashboardHeaderTheme.allSeasonal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: themes.map((t) {
          final isActive = t.id == current.id;
          return GestureDetector(
            onTap: () => controller.debugSetTheme(t),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.accent,
                border: Border.all(
                  color: isActive ? Colors.white : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Text(
                t.id[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

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
    duration: const Duration(milliseconds: 560),
  );
  late final Animation<double> _a = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    // Don't start while a splash→dashboard dissolve cover is still up — the
    // stagger would finish hidden and the reveal would show content caught
    // mid-motion. Runs immediately on any normal (non-dissolve) arrival.
    whenDashboardVisible(() {
      if (!mounted) return;
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) _c.forward();
      });
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

// ---------------------------------------------------------------------------
// No Treks / Notify Me Widgets
// ---------------------------------------------------------------------------

/// Themed empty-state that replaces the Departure Date row when no treks
/// are available on the selected route. Mirrors the visual rhythm of the
/// "From"/"To" fields: themed accent icon, AppType typography, TouchRipple
/// feedback, and proper async state management for the notify-me flow.
class _NoTreksOnRouteSection extends StatefulWidget {
  final Color accent;
  final Color accentSoft;
  final Color ink;
  final Color inkMid;
  final Color inkLight;
  final Color fieldBg;
  final Color fieldBorder;
  final bool isInitiallyNotified;

  /// Called when the user taps "Notify Me". Must complete without throwing
  /// for the UI to switch to the "Confirmed" state.
  final Future<void> Function() onNotifyMe;

  /// Called when the user taps "Change Route".
  final VoidCallback onChangeRoute;

  const _NoTreksOnRouteSection({
    required this.accent,
    required this.accentSoft,
    required this.ink,
    required this.inkMid,
    required this.inkLight,
    required this.fieldBg,
    required this.fieldBorder,
    required this.isInitiallyNotified,
    required this.onNotifyMe,
    required this.onChangeRoute,
  });

  @override
  State<_NoTreksOnRouteSection> createState() => _NoTreksOnRouteSectionState();
}

class _NoTreksOnRouteSectionState extends State<_NoTreksOnRouteSection> {
  bool _isSaving = false;

  // Derives confirmed state directly from the parent's prop.
  // No local state drift is possible.
  bool get _isConfirmed => widget.isInitiallyNotified;

  Future<void> _handleNotifyMe() async {
    setState(() => _isSaving = true);
    try {
      await widget.onNotifyMe();
      // The parent's reactive state will update isInitiallyNotified,
      // which will cause _isConfirmed to become true automatically.
    } catch (_) {
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = _isSaving;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Message ──
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.accent.withValues(alpha: 0.08),
                  ),
                  child: ClipOval(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Lottie.asset(
                        'assets/animations/hiking_animation.json',
                        repeat: true,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'No treks available on this route yet.',
                    textScaler: const TextScaler.linear(1.0),
                    style: AppType.style(
                      FontSize.s10,
                      w: FontWeight.w500,
                      color: widget.inkMid,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Action area ──
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: _isConfirmed
                  ? _buildConfirmedChip()
                  : _buildActionButtons(isSaving),
            ),
          ],
        ),
      ),
    );
  }

  // ── Confirmed inline chip ──────────────────────────────────────────
  Widget _buildConfirmedChip() {
    return Container(
      key: const ValueKey('confirmed'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: widget.accentSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: widget.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 15,
            color: widget.accent,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'We\'ll notify you when treks open up!',
              overflow: TextOverflow.ellipsis,
              style: AppType.style(
                FontSize.s10,
                w: FontWeight.w600,
                color: widget.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ─────────────────────────────────────────────────
  Widget _buildActionButtons(bool isSaving) {
    return Wrap(
      key: const ValueKey('actions'),
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Change Route — solid accent button with TouchRipple
        _ThemedChip(
          label: 'Change Route',
          icon: Icons.swap_horiz_rounded,
          iconSize: 14,
          fontSize: FontSize.s10,
          isSolid: true,
          accent: widget.accent,
          accentSoft: widget.accentSoft,
          onTap: widget.onChangeRoute,
        ),

        // Notify Me — outlined button with loading spinner
        _ThemedChip(
          label: 'Notify Me',
          icon: isSaving ? null : Icons.notifications_active_outlined,
          iconSize: 14,
          fontSize: FontSize.s10,
          isSolid: false,
          accent: widget.accent,
          accentSoft: widget.accentSoft,
          isLoading: isSaving,
          onTap: isSaving ? null : _handleNotifyMe,
        ),
      ],
    );
  }
}

/// Small reusable chip button that matches the search-card theme.
class _ThemedChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final double iconSize;
  final double fontSize;
  final bool isSolid;
  final Color accent;
  final Color accentSoft;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ThemedChip({
    required this.label,
    required this.icon,
    required this.iconSize,
    required this.fontSize,
    required this.isSolid,
    required this.accent,
    required this.accentSoft,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return TouchRipple(
      rippleColor: accent.withValues(alpha: 0.08),
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: disabled ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSolid ? accent : accentSoft,
            borderRadius: BorderRadius.circular(10),
            border: isSolid
                ? null
                : Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                )
              else if (icon != null)
                Icon(
                  icon,
                  size: iconSize,
                  color: isSolid ? Colors.white : accent,
                ),
              if (icon != null || isLoading) const SizedBox(width: 6),
              Text(
                label,
                style: AppType.style(
                  fontSize,
                  w: FontWeight.w600,
                  color: isSolid ? Colors.white : accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Self-contained notify-me bottom-sheet content. The auto-close timer
/// lives in [initState] so it fires exactly once, not on every rebuild.
class _NotifyMeSheet extends StatefulWidget {
  final DashboardHeaderTheme ht;
  final String from;
  final String to;
  final Future<void> Function() onSuccess;

  const _NotifyMeSheet({
    required this.ht,
    required this.from,
    required this.to,
    required this.onSuccess,
  });

  @override
  State<_NotifyMeSheet> createState() => _NotifyMeSheetState();
}

class _NotifyMeSheetState extends State<_NotifyMeSheet>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  // The controller carefully re-throws the real server/network message (see
  // subscribeToRouteNotification's doc comment) — this used to be discarded
  // entirely in favor of a hardcoded "check your connection" string, which
  // was actively misleading for non-network failures (e.g. a real 500 or
  // validation error shown to a user on full wifi).
  String? _errorMessage;
  Timer? _autoCloseTimer;
  late final AnimationController _slideController;
  late final Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _slideAnim = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );
    _slideController.forward();

    _performAction();
  }

  Future<void> _performAction() async {
    try {
      await widget.onSuccess();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = false;
      });

      // Start the auto-close countdown only after success is shown.
      _autoCloseTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });

      // Close sheet after a short delay on error
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ht = widget.ht;

    return AnimatedBuilder(
      animation: _slideAnim,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, (1 - _slideAnim.value) * 40),
        child: Opacity(opacity: _slideAnim.value, child: child),
      ),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: _C.inkLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ht.accentSoft,
                shape: BoxShape.circle,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(ht.accent),
                      ),
                    )
                  : Icon(
                      _hasError
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_rounded,
                      size: 48,
                      color: _hasError ? _C.danger : ht.accent,
                    ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              _isLoading
                  ? 'Subscribing…'
                  : _hasError
                  ? 'Something went wrong'
                  : 'You\'re on the list!',
              style: AppType.style(
                FontSize.s16,
                w: FontWeight.w700,
                color: _C.ink,
              ),
            ),
            const SizedBox(height: 8),

            // Body
            Text(
              _isLoading
                  ? 'Setting up notifications for ${widget.from} → ${widget.to}…'
                  : _hasError
                  ? (_errorMessage?.isNotEmpty == true
                        ? _errorMessage!
                        : 'Please check your connection and try again.')
                  : 'We\'ll send you a push notification as soon as treks '
                        'become available from ${widget.from} to ${widget.to}.',
              textAlign: TextAlign.center,
              style: AppType.style(FontSize.s11, color: _C.inkMid, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Close button
            SizedBox(
              width: double.infinity,
              child: TouchRipple(
                rippleColor: ht.accent.withValues(alpha: 0.08),
                onTap: () {
                  _autoCloseTimer?.cancel();
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: _C.fieldBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Close',
                      style: AppType.style(
                        FontSize.s12,
                        w: FontWeight.w600,
                        color: _C.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!_isLoading && !_hasError) ...[
              const SizedBox(height: 12),
              Text(
                'Auto-closing in a few seconds…',
                style: AppType.style(FontSize.s9, color: _C.inkLight),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
