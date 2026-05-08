import 'dart:developer';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/models/seasonal_forecast_data.dart';
import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/common_btn.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/know_more_card.dart';
import 'package:arobo_app/utils/seasonal_forecast.dart';
import 'package:arobo_app/utils/top_treks_card.dart';
import 'package:arobo_app/models/know_more_data.dart';
import 'package:arobo_app/models/top_treks_data.dart';
import 'package:arobo_app/models/shorts_treks_data.dart';
import 'package:arobo_app/utils/trek_shorts.dart';
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

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  DateTime? _ntpTime;

  final ScrollController _scrollController = ScrollController();
  final ScrollController _knowMoreController = ScrollController();
  final ScrollController _topTreksController = ScrollController();
  final ScrollController _trekShortsController = ScrollController();
  final ScrollController _seasonalForecastController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  final PageController _pageController = PageController(
    viewportFraction: 0.85,
    initialPage: knowMoreCardsData.length * 100,
  );
  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;
  int _currentPage = 0;
  bool _isTrekShortsUserInteracting = false;
  Timer? _trekShortsTimer;
  final PageController _trekShortsPageController = PageController(
    viewportFraction: 0.38,
  );
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final TrekController _trekC = Get.find<TrekController>();

  // Calendar variables
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Add new variables for weekend treks
  List<DateTime> _nearestWeekendDates = [];

  // Add a map to track favorite state
  Map<String, bool> _favoriteTreks = {};

  @override
  void initState() {
    super.initState();
    _initializeNTPTime();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Add listener to refresh UI when calendar dates change
    ever(_dashboardC.calenderTrekDatesObserver, (value) {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild of the UI
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
      if (_knowMoreController.hasClients) _knowMoreController.jumpTo(0);
      if (_topTreksController.hasClients) _topTreksController.jumpTo(0);
      if (_trekShortsController.hasClients) _trekShortsController.jumpTo(0);
      if (_seasonalForecastController.hasClients)
        _seasonalForecastController.jumpTo(0);
    });

    // Initialize favorite state from topTreksCardsData
    for (var trek in topTreksCardsData) {
      _favoriteTreks[trek['title']] = trek['isFavorite'] ?? false;
    }

    _dashboardC.fetchWhatsNew();
    _dashboardC.fetchTopTreks();
    _dashboardC.fetchShortsTreks();
    _dashboardC.fetchSeasonalForeCasts();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only start auto-scroll if we're on the dashboard screen
    if (ModalRoute.of(context)?.settings.name == '/dashboard') {
      _startAutoScroll();
      _startTrekShortsAutoScroll();
    }
  }

  @override
  void deactivate() {
    _stopAutoScroll();
    _trekShortsTimer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _trekShortsTimer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    _knowMoreController.dispose();
    _topTreksController.dispose();
    _trekShortsController.dispose();
    _seasonalForecastController.dispose();
    _trekShortsPageController.dispose();
    super.dispose();
  }

  void _resetAllScrolls() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    if (_knowMoreController.hasClients) _knowMoreController.jumpTo(0);
    if (_topTreksController.hasClients) _topTreksController.jumpTo(0);
    if (_trekShortsController.hasClients) _trekShortsController.jumpTo(0);
    if (_seasonalForecastController.hasClients)
      _seasonalForecastController.jumpTo(0);
  }

  Future<void> _initializeNTPTime() async {
    try {
      DateTime ntpTime = await NTP.now();
      setState(() {
        _ntpTime = ntpTime;
        _focusedDay = ntpTime;
      });
    } catch (e) {
      // Fallback to device time if NTP fails
      setState(() {
        _ntpTime = DateTime.now();
        _focusedDay = DateTime.now();
      });
    }
  }


  // Helper method to find first available date
  DateTime? _getFirstAvailableDate(DateTime startDate, DateTime endDate) {
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      DateTime checkDate = startDate.add(Duration(days: i));
      if (_dashboardC.isDateAvailable(checkDate)) {
        return checkDate;
      }
    }
    return null;
  }

  void _updateSelectedDateToFirstAvailable() {
    if (_ntpTime == null) return;

    final DateTime currentDate = _ntpTime!;
    final DateTime threeMonthsLater = currentDate.add(const Duration(days: 90));

    // Check if current date has treks
    if (!_dashboardC.isDateAvailable(currentDate)) {
      // Find first available date
      DateTime? firstAvailableDate = _getFirstAvailableDate(currentDate, threeMonthsLater);

      if (firstAvailableDate != null) {
        setState(() {
          _dashboardC.selectedDate.value = firstAvailableDate;
          _dashboardC.dateController.value.text =
              DateFormat('dd/MM/yyyy').format(firstAvailableDate);
          _selectedDay = firstAvailableDate;
          _focusedDay = firstAvailableDate;
          _updateNearestWeekendDates();
        });
      }
    } else {
      setState(() {
        _selectedDay = currentDate;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // Ensure we have NTP time
    if (_ntpTime == null) {
      await _initializeNTPTime();
    }

    // Get current NTP time and normalize it to start of day
    final DateTime currentTime = _ntpTime ?? DateTime.now();
    final DateTime normalizedCurrentTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
    );

    final DateTime threeMonthsLater = normalizedCurrentTime.add(const Duration(days: 90));

    // Show custom date picker dialog
    await _showCustomDatePicker(
      context,
      normalizedCurrentTime,
      threeMonthsLater,
    );
  }

Future<void> _showCustomDatePicker(
  BuildContext context,
  DateTime firstDate,
  DateTime lastDate,
) async {
  DateTime tempSelectedDate = _dashboardC.selectedDate.value ?? firstDate;
  DateTime tempFocusedDay = _focusedDay;
  CalendarFormat tempCalendarFormat = _calendarFormat;

  const Color _bg = Color(0xFFFFFFFF);
  const Color _surface = Color(0xFFFFFFFF);
  const Color _topBar = Color(0xFF111111);
  const Color _topBar2 = Color(0xFF0A0A0A);
  const Color _accent = Color(0xFFFFD600);
  const Color _accentDark = Color(0xFFF5C000);
  const Color _accentLight = Color(0xFFFFF8DC);
  const Color _green = Color(0xFF16A34A);
  const Color _greenLight = Color(0xFFDCFCE7);
  const Color _ink = Color(0xFF0F0F0F);
  const Color _inkMid = Color(0xFF6B7280);
  const Color _inkLight = Color(0xFF9CA3AF);
  const Color _border = Color(0xFFE5E7EB);

  await showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheet) {
          final screenHeight = MediaQuery.of(context).size.height;

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Transform.translate(
              offset: Offset(0, (1 - value) * 48),
              child: Opacity(opacity: value, child: child),
            ),
            child: Container(
              height: screenHeight * 0.9,
              decoration: const BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 32,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_topBar, _topBar2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _accent.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _accent.withOpacity(0.25),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.calendar_month_rounded,
                                  color: _accent,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Select Departure Date',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Dates showing trek count are available',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.75),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.14),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                          child: Row(
                            children: [
                              _legendItem(
                                color: _green,
                                label: 'Treks available',
                                hasCount: true,
                              ),
                              const SizedBox(width: 18),
                              _legendItem(
                                color: _accent,
                                label: 'Selected',
                                solid: true,
                              ),
                              const SizedBox(width: 18),
                              _legendItem(
                                color: Colors.white.withOpacity(0.5),
                                label: 'Unavailable',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _border),
                          boxShadow: [
                            BoxShadow(
                              color: _accent.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(6, 8, 6, 14),
                        child: Obx(() {
                          final isLoading =
                              _dashboardC.calenderTrekDatesObserver.value.maybeWhen(
                            loading: (_) => true,
                            orElse: () => false,
                          );

                          if (isLoading) {
                            return SizedBox(
                              height: 300,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: _green,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Loading available dates…',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: _inkMid,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Theme(
                            data: Theme.of(context).copyWith(
                              cardColor: _surface,
                              scaffoldBackgroundColor: _surface,
                              colorScheme: ColorScheme.fromSeed(
                                seedColor: _accent,
                                brightness: Brightness.light,
                                surface: _surface,
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
                              rowHeight: 54,
                              daysOfWeekHeight: 30,
                              onFormatChanged: (f) =>
                                  setSheet(() => tempCalendarFormat = f),
                              onDaySelected: (sel, foc) => setSheet(() {
                                tempSelectedDate = sel;
                                tempFocusedDay = foc;
                              }),
                              onPageChanged: (foc) => tempFocusedDay = foc,
                              selectedDayPredicate: (d) =>
                                  isSameDay(d, tempSelectedDate),
                              calendarStyle: const CalendarStyle(
                                outsideDaysVisible: false,
                                cellPadding: EdgeInsets.zero,
                                cellMargin: EdgeInsets.all(2),
                                tableBorder: TableBorder.symmetric(
                                  inside: BorderSide(color: Color(0xFFF3F4F6)),
                                ),
                              ),
                              calendarBuilders: CalendarBuilders(
                                defaultBuilder: (ctx, day, _) => _buildDayCell(
                                  day: day,
                                  isSelected: false,
                                  isToday: false,
                                  accent: _accent,
                                  green: _green,
                                  greenLight: _greenLight,
                                ),
                                todayBuilder: (ctx, day, _) => _buildDayCell(
                                  day: day,
                                  isSelected: isSameDay(day, tempSelectedDate),
                                  isToday: true,
                                  accent: _accent,
                                  green: _green,
                                  greenLight: _greenLight,
                                ),
                                selectedBuilder: (ctx, day, _) => _buildDayCell(
                                  day: day,
                                  isSelected: true,
                                  isToday: isSameDay(day, _ntpTime ?? DateTime.now()),
                                  accent: _accent,
                                  green: _green,
                                  greenLight: _greenLight,
                                ),
                                markerBuilder: (_, __, ___) => null,
                              ),
                              headerStyle: HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                titleTextStyle: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _ink,
                                  letterSpacing: -0.2,
                                ),
                                leftChevronIcon: _chevron(Icons.chevron_left_rounded),
                                rightChevronIcon: _chevron(Icons.chevron_right_rounded),
                                headerPadding:
                                    const EdgeInsets.symmetric(vertical: 10),
                              ),
                              daysOfWeekStyle: DaysOfWeekStyle(
                                weekdayStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _inkMid,
                                  letterSpacing: 0.4,
                                ),
                                weekendStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFEF4444).withOpacity(0.65),
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
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Obx(() {
                      final isAvailable =
                          _dashboardC.isDateAvailable(tempSelectedDate);
                      final trekCount =
                          _dashboardC.getTrekCountForDate(tempSelectedDate);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isAvailable
                                ? [
                                    const Color(0xFFF0FDF4),
                                    const Color(0xFFDCFCE7),
                                  ]
                                : [
                                    const Color(0xFFFFFBEB),
                                    const Color(0xFFFEF3C7),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isAvailable
                                ? _green.withOpacity(0.25)
                                : _accent.withOpacity(0.22),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isAvailable ? _green : _accent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isAvailable
                                    ? Icons.check_rounded
                                    : Icons.info_outline_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('EEEE, MMM d, yyyy')
                                        .format(tempSelectedDate),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: _ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isAvailable
                                        ? '$trekCount trek${trekCount > 1 ? 's' : ''} available on this date'
                                        : 'No treks available — try another date',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isAvailable ? _green : _accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isAvailable)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _green,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$trekCount',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      14,
                      12,
                      14,
                      14 + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              side: const BorderSide(color: _border, width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              backgroundColor: _surface,
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: _inkMid,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: Obx(() {
                              final isAvailable =
                                  _dashboardC.isDateAvailable(tempSelectedDate);
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  gradient: isAvailable
                                      ? const LinearGradient(
                                          colors: [_accent, _accentDark],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isAvailable ? null : _border,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: isAvailable
                                      ? [
                                          BoxShadow(
                                            color: _accent.withOpacity(0.32),
                                            blurRadius: 14,
                                            offset: const Offset(0, 5),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: ElevatedButton(
                                  onPressed: isAvailable
                                      ? () {
                                          setState(() {
                                            _dashboardC.selectedDate.value =
                                                tempSelectedDate;
                                            _dashboardC.dateController.value.text =
                                                DateFormat('dd/MM/yyyy')
                                                    .format(tempSelectedDate);
                                            _selectedDay = tempSelectedDate;
                                            _focusedDay = tempFocusedDay;
                                            _calendarFormat =
                                                tempCalendarFormat;
                                            _updateNearestWeekendDates();
                                          });
                                          Get.back();
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    disabledBackgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Confirm Date',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isAvailable
                                              ? Colors.white
                                              : _inkLight,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 17,
                                        color: isAvailable
                                            ? Colors.white
                                            : _inkLight,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
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
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
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
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: solid ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: solid ? null : Border.all(color: color, width: 1.5),
              ),
              child: solid
                  ? const Icon(Icons.check_rounded,
                      size: 9, color: Colors.white)
                  : null,
            ),
      const SizedBox(width: 5),
      Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white.withOpacity(0.85),
        ),
      ),
    ],
  );
}

Widget _chevron(IconData icon) {
  return Container(
    padding: const EdgeInsets.all(6),
    decoration: const BoxDecoration(
      color: Color(0xFF2A2A2A),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, size: 20, color: const Color(0xFFFFD600)),
  );
}

Widget _buildDayCell({
  required DateTime day,
  required bool isSelected,
  required bool isToday,
  required Color accent,
  required Color green,
  required Color greenLight,
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
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFFFFD600), Color(0xFFF5C000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected
            ? null
            : isAvailable
                ? const Color(0xFFF0FDF4)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        border: isToday && !isSelected
            ? Border.all(color: const Color(0xFFFFD600), width: 1.8)
            : isAvailable && !isSelected
                ? Border.all(color: green.withOpacity(0.35), width: 1)
                : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD600).withOpacity(0.42),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight:
                  isSelected || isAvailable ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF0F0F0F)
                  : isAvailable
                      ? green
                      : isWeekend
                          ? const Color(0xFFEF4444).withOpacity(0.7)
                          : const Color(0xFF555555),
              height: 1.1,
            ),
          ),
          if (isAvailable) ...[
            const SizedBox(height: 1),
            Text(
              isSelected ? '✓' : '$trekCount',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white.withOpacity(0.85) : green,
                height: 1.0,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
  Future<void> _selectSourceLocation() async {
    final City? selectedCity = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SourceLocationScreen(),
      ),
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
      MaterialPageRoute(
        builder: (context) => SourceLocationScreen(),
      ),
    );

    if (selectedTrek != null) {
      setState(() {
        _dashboardC.toController.value.text = selectedTrek.name;
      });
    }
  }

  Future<void> _handleSearch() async {
    if (!_isFormValid) {
      CustomSnackBar.show(
        context,
        message: 'Please provide valid inputs',
      );
      return;
    }
    _resetAllScrolls();
    await _trekC.searchTreks(
      cityId: _dashboardC.selectedCityId.value,
      trekId: _dashboardC.selectedTrekId.value,
      date: _dashboardC.dateController.value.text,
      refresh: true
    );
    Get.toNamed('/search');
  }

  void _handleSearchPress() async {
    setState(() => _isPressed = true);
    _animationController.forward();

    await Future.delayed(const Duration(milliseconds: 150));
    log('date: ${_dashboardC.dateController.value.text}');

    if (!mounted) return;
    _animationController.reverse();
    setState(() => _isPressed = false);

    _handleSearch();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();

    if (mounted && knowMoreCardsData.length > 1) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
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
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _startTrekShortsAutoScroll() {
    _trekShortsTimer?.cancel();
    _trekShortsTimer = Timer.periodic(const Duration(seconds: 12), (timer) {
      final route = ModalRoute.of(context);
      if (!_isTrekShortsUserInteracting &&
          mounted &&
          shortsTreksCardsData.length > 1 &&
          (route != null && route.isCurrent)) {
        _trekShortsPageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _toggleFavorite(String trekTitle) {
    setState(() {
      _favoriteTreks[trekTitle] = !(_favoriteTreks[trekTitle] ?? false);
      final trekIndex =
      topTreksCardsData.indexWhere((trek) => trek['title'] == trekTitle);
      if (trekIndex != -1) {
        topTreksCardsData[trekIndex]['isFavorite'] = _favoriteTreks[trekTitle];
      }
    });
  }

  void _updateNearestWeekendDates() {
    if (_dashboardC.selectedDate.value == null) return;

    _nearestWeekendDates.clear();
    DateTime currentDate = _dashboardC.selectedDate.value!;

    if (_ntpTime != null) {
      final DateTime normalizedNTPTime = DateTime(
        _ntpTime!.year,
        _ntpTime!.month,
        _ntpTime!.day,
      );
      final DateTime normalizedCurrentDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );

      if (normalizedCurrentDate.isBefore(normalizedNTPTime)) {
        currentDate = _ntpTime!;
      }
    }

    // Find the next available Thursday, Friday, and Saturday
    for (int i = 0; i < 14; i++) {
      DateTime checkDate = currentDate.add(Duration(days: i));
      if ([4, 5, 6].contains(checkDate.weekday)) {
        if (_dashboardC.isDateAvailable(checkDate)) {
          _nearestWeekendDates.add(checkDate);
        }
      }
      if (_nearestWeekendDates.length >= 3) break;
    }
  }

  bool get _isFormValid =>
      _dashboardC.fromController.value.text.isNotEmpty &&
          _dashboardC.toController.value.text.isNotEmpty &&
          _dashboardC.dateController.value.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);

    return Scaffold(
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        controller: _scrollController,
        child: Column(
          children: [
            // Gradient Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              margin: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
              child: Container(
                decoration: BoxDecoration(
                  gradient: CommonColors.homeScreenBgGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: ScreenConstant.size16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: ScreenConstant.size20),
                        // Location and Profile Row
                        Container(
                          margin: EdgeInsets.only(left: 18, right: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    CommonImages.logo1,
                                    height: 7.h,
                                    width: 30.w,
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed('/help');
                                },
                                child: SvgPicture.asset(
                                  CommonImages.help,
                                  colorFilter: ColorFilter.mode(
                                      CommonColors.blackColor, BlendMode.srcIn),
                                  height: 2.8.h,
                                  width: 3.w,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        // Title Text
                        Center(
                          child: Text(
                            'Hike Beyond Limits with',
                            style: TextStyle(
                              fontSize: FontSize.s14,
                              color: CommonColors.blackColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: ScreenConstant.size27),
                        // Search Card
                        Container(
                          margin: EdgeInsets.only(left: 30, right: 30),
                          child: Card(
                            color: CommonColors.whiteColor,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(ScreenConstant.size20),
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
                                  // From Field
                                  Stack(
                                    children: [
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: _selectSourceLocation,
                                            child: Padding(
                                              padding:
                                              EdgeInsets.only(right: 8),
                                              child: SvgPicture.asset(
                                                CommonImages.location3,
                                                height: ScreenConstant.size24,
                                                width: ScreenConstant.size24,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              width: ScreenConstant.size12),
                                          Expanded(
                                            child: Stack(
                                              alignment: Alignment.centerRight,
                                              children: [
                                                MediaQuery(
                                                  data: MediaQuery.of(context)
                                                      .copyWith(
                                                    textScaler:
                                                    const TextScaler.linear(
                                                        1.0),
                                                  ),
                                                  child: TextFormField(
                                                    controller: _dashboardC
                                                        .fromController.value,
                                                    readOnly: true,
                                                    onTap:
                                                    _selectSourceLocation,
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: 'From',
                                                      hintStyle:
                                                      GoogleFonts.poppins(
                                                        fontSize: FontSize.s14,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color: CommonColors
                                                            .blackColor
                                                            .withOpacity(0.5),
                                                      ),
                                                      contentPadding:
                                                      EdgeInsets.only(
                                                          right: 36),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Positioned.fill(
                                        child: TouchRipple(
                                          rippleColor: CommonColors.blackColor
                                              .withOpacity(0.1),
                                          onTap: _selectSourceLocation,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  // To Field
                                  Stack(
                                    children: [
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: _selectDestinationTrek,
                                            child: Padding(
                                              padding:
                                              EdgeInsets.only(right: 8),
                                              child: SvgPicture.asset(
                                                CommonImages.location2,
                                                height: ScreenConstant.size24,
                                                width: ScreenConstant.size24,
                                                colorFilter: ColorFilter.mode(
                                                    CommonColors.grey_AEAEAE,
                                                    BlendMode.srcIn),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              width: ScreenConstant.size12),
                                          Expanded(
                                            child: Stack(
                                              alignment: Alignment.centerRight,
                                              children: [
                                                MediaQuery(
                                                  data: MediaQuery.of(context)
                                                      .copyWith(
                                                    textScaler:
                                                    const TextScaler.linear(
                                                        1.0),
                                                  ),
                                                  child: TextFormField(
                                                    controller: _dashboardC
                                                        .toController.value,
                                                    readOnly: true,
                                                    onTap:
                                                    _selectDestinationTrek,
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: 'To',
                                                      hintStyle:
                                                      GoogleFonts.poppins(
                                                        fontSize: FontSize.s14,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color: CommonColors
                                                            .blackColor
                                                            .withOpacity(0.5),
                                                      ),
                                                      contentPadding:
                                                      EdgeInsets.only(
                                                          right: 36),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Positioned.fill(
                                        child: TouchRipple(
                                          rippleColor: CommonColors.blackColor
                                              .withOpacity(0.1),
                                          onTap: _selectDestinationTrek,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  // Date Field
                                  Stack(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () => _selectDate(context),
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  top: 18, right: 8),
                                              child: SvgPicture.asset(
                                                CommonImages.calendar,
                                                height: ScreenConstant.size24,
                                                width: ScreenConstant.size24,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              width: ScreenConstant.size12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 1.h),
                                                Text(
                                                  'Departure Date',
                                                  textScaler: const TextScaler.linear(1.0),
                                                  style: GoogleFonts.poppins(
                                                    color: CommonColors.grey_AEAEAE,
                                                    fontSize: FontSize.s10,
                                                  ),
                                                ),
                                                SizedBox(height: 0.2.h),

                                                Obx(() {
                                                  // Force rebuild when these values change
                                                  final cityId = _dashboardC.selectedCityId.value;
                                                  final trekId = _dashboardC.selectedTrekId.value;
                                                  final selectedDateValue = _dashboardC.selectedDate.value;
                                                  final dateText = _dashboardC.dateController.value.text;
                                                  final observerState = _dashboardC.calenderTrekDatesObserver.value;

                                                  // Check if city and trek are selected
                                                  final bool isCityTrekSelected = cityId != 0 && trekId != 0;

                                                  // If city/trek not selected, show placeholder
                                                  if (!isCityTrekSelected) {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(top: 4.0),
                                                      child: Text(
                                                        'Select source & destination first',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: FontSize.s10,
                                                          color: CommonColors.grey_AEAEAE,
                                                          fontStyle: FontStyle.italic,
                                                        ),
                                                      ),
                                                    );
                                                  }

                                                  // If date is selected, show the selected date
                                                  if (dateText.isNotEmpty) {
                                                    bool isAvailable = selectedDateValue != null &&
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
                                                                fontSize: FontSize.s10,
                                                                color: CommonColors.blackColor,
                                                              ),
                                                            ),
                                                            if (selectedDateValue != null)
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 8.0),
                                                                child: Icon(
                                                                  isAvailable ? Icons.check_circle : Icons.warning,
                                                                  size: 14,
                                                                  color: isAvailable ? Colors.green : Colors.orange,
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                        // Show trek count if available
                                                        if (selectedDateValue != null && _dashboardC.isDateAvailable(selectedDateValue))
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 4.0),
                                                            child: Text(
                                                              '${_dashboardC.getTrekCountForDate(selectedDateValue)} trek${_dashboardC.getTrekCountForDate(selectedDateValue) > 1 ? 's' : ''} available',
                                                              style: GoogleFonts.poppins(
                                                                fontSize: FontSize.s8,
                                                                color: Colors.green,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    );
                                                  }

                                                  // If no date selected, show available dates list
                                                  final datesLoading = observerState.maybeWhen(
                                                      loading: (data) => true,
                                                      orElse: () => false
                                                  );

                                                  List<TrekDatesModel>? calenderTrekDates = observerState.maybeWhen(
                                                    success: (calenderResponse) => (calenderResponse as CalenderDatesResponseModel).data?.dates,
                                                    error: (sc) => [],
                                                    orElse: () => [],
                                                  );

                                                  // Filter dates to only show today and future dates
                                                  final DateTime now = _ntpTime ?? DateTime.now();
                                                  final today = DateTime(now.year, now.month, now.day);

                                                  List<TrekDatesModel> futureDates = (calenderTrekDates ?? []).where((dateData) {
                                                    if (dateData.date == null) return false;
                                                    DateTime date = DateTime.tryParse(dateData.date!) ?? DateTime.now();
                                                    return date.isAfter(today.subtract(const Duration(days: 1)));
                                                  }).toList();

                                                  // Take first 10 dates
                                                  List<TrekDatesModel> first10Dates = futureDates.take(10).toList();

                                                  if (first10Dates.isEmpty) {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(top: 8.0),
                                                      child: Text(
                                                        'No available dates found',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: FontSize.s10,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    );
                                                  }

                                                  return Column(
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only(top: 1.h),
                                                        height: 6.h,
                                                        child: ListView.builder(
                                                          key: ValueKey('date_list_${observerState.hashCode}_${first10Dates.length}'),
                                                          scrollDirection: Axis.horizontal,
                                                          physics: const BouncingScrollPhysics(),
                                                          itemCount: first10Dates.length,
                                                          itemBuilder: (context, index) {
                                                            final cardData = first10Dates[index];
                                                            if (cardData == null) return const SizedBox();

                                                            DateTime date = DateTime.tryParse(cardData.date ?? "") ?? DateTime.now();
                                                            String formattedDate = DateFormat('d MMM').format(date);
                                                            bool isSelected = _dashboardC.selectedDate.value == date;
                                                            bool isDateAvailable = _dashboardC.isDateAvailable(date);
                                                            int trekCount = _dashboardC.getTrekCountForDate(date);

                                                            return GestureDetector(
                                                              onTap: () {
                                                                if (isDateAvailable) {
                                                                  // Select the date
                                                                  _dashboardC.selectedDate.value = date;
                                                                  _dashboardC.dateController.value.text =
                                                                      DateFormat('dd/MM/yyyy').format(date);
                                                                  _selectedDay = date;
                                                                  _focusedDay = date;
                                                                  _updateNearestWeekendDates();

                                                                  // Force UI update
                                                                  setState(() {});

                                                                  // Optional: Show success message
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
                                                                  right: index == first10Dates.length - 1 ? 0 : ScreenConstant.size6,
                                                                ),
                                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                                decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                    color: isSelected
                                                                        ? CommonColors.blueColor
                                                                        : (isDateAvailable ? Colors.green.shade300 : Colors.grey.shade300),
                                                                    width: isSelected ? 1.5 : 0.5,
                                                                  ),
                                                                  borderRadius: BorderRadius.circular(12),
                                                                  color: isSelected
                                                                      ? CommonColors.blueColor.withOpacity(0.1)
                                                                      : (isDateAvailable ? Colors.green.withOpacity(0.05) : Colors.transparent),
                                                                ),
                                                                child: Column(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Text(
                                                                      formattedDate,
                                                                      style: GoogleFonts.poppins(
                                                                        fontSize: FontSize.s10,
                                                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                                                        color: isSelected
                                                                            ? CommonColors.blueColor
                                                                            : (isDateAvailable ? Colors.green : CommonColors.blackColor),
                                                                      ),
                                                                    ),
                                                                    if (isDateAvailable && trekCount > 0)
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(top: 2.0),
                                                                        child: Text(
                                                                          '$trekCount',
                                                                          style: GoogleFonts.poppins(
                                                                            fontSize: FontSize.s8,
                                                                            color: Colors.green,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ).withShimmerAi(loading: datesLoading),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: ScreenConstant.size20),
                        // Trek Types Card
                        Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
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
                                            message:
                                            'Please provide valid inputs',
                                          );
                                          return;
                                        }
                                        if (_nearestWeekendDates.isEmpty) {
                                          _updateNearestWeekendDates();
                                        }
                                        await _trekC.fetchWeekendTreks(
                                          cityId: _dashboardC
                                              .fromController.value.text,
                                          trekId: _dashboardC
                                              .toController.value.text,
                                          date: _dashboardC.dateController.value.text,
                                          refresh: true,
                                        );
                                        Get.toNamed(
                                          '/weekend-treks',
                                          arguments: {
                                            'city': _dashboardC
                                                .fromController.value.text,
                                            'trek': _dashboardC
                                                .toController.value.text,
                                            'date': _dashboardC.dateController.value.text,
                                            'weekendDates':
                                            _nearestWeekendDates,
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
                                              fontSize: FontSize.s10,
                                              fontWeight: FontWeight.w400,
                                              color: _isFormValid
                                                  ? CommonColors.blackColor
                                                  : CommonColors.greyColor2,
                                            ),
                                          ),
                                          SizedBox(
                                              height: ScreenConstant.size4),
                                          SvgPicture.asset(
                                            CommonImages.weekend,
                                            height: ScreenConstant.size25,
                                            width: ScreenConstant.size25,
                                            colorFilter: ColorFilter.mode(
                                              _isFormValid
                                                  ? CommonColors.blackColor
                                                  : CommonColors.greyColor2,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          if (_isFormValid &&
                                              _nearestWeekendDates.isNotEmpty)
                                            Padding(
                                              padding: EdgeInsets.only(top: 4),
                                              child: Text(
                                                'Next: ${DateFormat('EEE, MMM d').format(_nearestWeekendDates.first)}',
                                                textScaler:
                                                const TextScaler.linear(
                                                    1.0),
                                                style: TextStyle(
                                                  fontSize: FontSize.s8,
                                                  color:
                                                  CommonColors.blackColor,
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
                                    color: CommonColors.grey_AEAEAE,
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        if (!_isFormValid) {
                                          CustomSnackBar.show(
                                            context,
                                            message:
                                            'Please provide valid inputs',
                                          );
                                          return;
                                        }
                                        Get.toNamed(
                                          '/personalized-treks',
                                          arguments: {
                                            'city': _dashboardC
                                                .fromController.value.text,
                                            'trek': _dashboardC
                                                .toController.value.text,
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
                                              fontSize: FontSize.s10,
                                              fontWeight: FontWeight.w400,
                                              color: _isFormValid
                                                  ? CommonColors.blackColor
                                                  : CommonColors.greyColor2,
                                            ),
                                          ),
                                          SizedBox(
                                              height: ScreenConstant.size4),
                                          SvgPicture.asset(
                                            CommonImages.weekend2,
                                            height: ScreenConstant.size25,
                                            width: ScreenConstant.size25,
                                            colorFilter: ColorFilter.mode(
                                              _isFormValid
                                                  ? CommonColors.blackColor
                                                  : CommonColors.greyColor2,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          if (_isFormValid &&
                                              _nearestWeekendDates.isNotEmpty)
                                            Padding(
                                              padding: EdgeInsets.only(top: 4),
                                              child: Text(
                                                'Unique Trekking Routes',
                                                textScaler:
                                                const TextScaler.linear(
                                                    1.0),
                                                style: TextStyle(
                                                  fontSize: FontSize.s8,
                                                  color:
                                                  CommonColors.blackColor,
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
                        // Search Button
                        Center(
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) => Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.75,
                                height: ScreenConstant.size44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _isPressed
                                          ? Colors.transparent
                                          : CommonColors.searchbtn
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CommonButton(
                                  textColor: CommonColors.searchbtntext,
                                  text: 'Search',
                                  onPressed: _handleSearchPress,
                                  backgroundColor: CommonColors.searchbtn,
                                  fontSize: FontSize.s15,
                                  fontWeight: FontWeight.w600,
                                  isFullWidth: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: ScreenConstant.size30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // White Background Section
            Container(
              color: CommonColors.offWhiteColor2,
              child: Column(
                spacing: MediaQuery.of(context).size.height / 50,
                children: [
                  Obx(() {
                    final knowMoreLoading = _dashboardC.whatsNewObserver.value
                        .maybeWhen(loading: (data) => true, orElse: () => false);
                    List<KnowMoreData>? knowMoreCardsData = [
                      KnowMoreData(title:"Variety of Treks",subtitle: "From Serene trails to thrilling climbs, find treksthat match your vibes !",hasKnowMore: false,imagePath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/knowmore1.png?alt=media&token=367dcaa7-f0f6-4bb3-9d73-a67489aa77a8",textColour: "#000000",gradient: ["#F7EB68","#FFEF3E","#FFEF3E"]),
                      KnowMoreData(title:"Countless Organizers",subtitle: "Choose from an extensive  network of trusted trek  organizers, All in one place !",hasKnowMore: false,imagePath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/knowmore1.png?alt=media&token=367dcaa7-f0f6-4bb3-9d73-a67489aa77a8",textColour: "#FFFFFF",gradient: ["#FFFFFF","#B40000","#B40000"])
                    ];
                    // List<KnowMoreData>? knowMoreCardsData = _dashboardC
                    //     .whatsNewObserver.value
                    //     .maybeWhen(
                    //   success: (whatsNewResponse) =>
                    //   (whatsNewResponse as WhatsNewDataResponseModel)
                    //       .data,
                    //   error: (sc) => [],
                    //   orElse: () => [
                    //     KnowMoreData(),
                    //     KnowMoreData(),
                    //     KnowMoreData(),
                    //     KnowMoreData()
                    //   ],
                    // );
                    if (knowMoreCardsData?.isEmpty == true) return SizedBox();
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: ScreenConstant.size17,
                              right: ScreenConstant.size17,
                              top: ScreenConstant.size10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "What's New",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ).withShimmerAi(loading: knowMoreLoading),
                                  Text(
                                    'Adventure simplified combo delivers !',
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s10,
                                      color: Colors.grey,
                                    ),
                                  ).withShimmerAi(loading: knowMoreLoading),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  Get.toNamed('/know-more-screen');
                                },
                                child: Text(
                                  'View more',
                                  style: TextStyle(
                                    decorationColor: CommonColors.blueColor,
                                    color: CommonColors.blueColor,
                                    fontSize: FontSize.s11,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ).withShimmerAi(loading: knowMoreLoading),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 1.h),
                          height: 22.h,
                          child: Listener(
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
                              itemCount: null,
                              onPageChanged: (int page) {
                                _currentPage =
                                    page % (knowMoreCardsData?.length ?? 0);
                              },
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final cardData = knowMoreCardsData?[
                                index % (knowMoreCardsData.length ?? 0)];
                                return Container(
                                  margin: EdgeInsets.only(
                                    left: ScreenConstant.size0,
                                    right: ScreenConstant.size6,
                                  ),
                                  child: KnowMoreCard(
                                    customGradient: AppTheme.customGradient(
                                        cardData?.gradient ?? []),
                                    imagePath: cardData?.imagePath ?? "",
                                    title: cardData?.title ?? "",
                                    subtitle: cardData?.subtitle ?? "",
                                    onKnowMoreTap:
                                    cardData?.hasKnowMore == false
                                        ? null
                                        : () {
                                      Get.toNamed(
                                        '/know-more-details',
                                        arguments: {
                                          'knowMoreData': cardData,
                                        },
                                      );
                                    },
                                    textColor: AppTheme.hexToColor(
                                        cardData?.textColour),
                                  ).withShimmerAi(loading: knowMoreLoading),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  Obx(() {
                    final topTreksLoading = _dashboardC.topTreksObserver.value
                        .maybeWhen(loading: (data) => true, orElse: () => false);

                    List<TopTreksData>? topTreksCardsData  = [
                      TopTreksData(title:"Coorg",description: "From Serene trails to thrilling climbs, find treksthat match your vibes !",imagePath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/coorg%204.png?alt=media&token=354d476c-d3e5-4b9f-a06e-6b787227a608", textColour: "#35323b",gradient: ["#F7EB68","#FFEF3E","#FFEF3E"]),
                      TopTreksData(title:"Munnar",description: "From Serene trails to thrilling climbs, find treksthat match your vibes !",imagePath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/coorg%204.png?alt=media&token=354d476c-d3e5-4b9f-a06e-6b787227a608",textColour: "#ffffff",gradient: ["#ffffff","#9e87e1","#7a56e1"]),
                    ];

                    // List<TopTreksData>? topTreksCardsData = _dashboardC
                    //     .topTreksObserver.value
                    //     .maybeWhen(
                    //   success: (topTreksResponse) =>
                    //   (topTreksResponse as TopTreksDataResponseModel)
                    //       .data,
                    //   error: (sc) => [],
                    //   orElse: () => [
                    //     TopTreksData(),
                    //     TopTreksData(),
                    //     TopTreksData(),
                    //     TopTreksData()
                    //   ],
                    // );
                    if (topTreksCardsData?.isEmpty == true) return SizedBox();
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: ScreenConstant.size17,
                              right: ScreenConstant.size17,
                              top: ScreenConstant.size10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Top Treks",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ).withShimmerAi(loading: topTreksLoading),
                                  Text(
                                    "Season's Best Treks, Ready for you !",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s10,
                                      color: Colors.grey,
                                    ),
                                  ).withShimmerAi(loading: topTreksLoading),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  Get.toNamed('/popular-treks');
                                },
                                child: Text(
                                  'View more',
                                  style: GoogleFonts.poppins(
                                    decorationColor: CommonColors.blueColor,
                                    color: CommonColors.blueColor,
                                    fontSize: FontSize.s11,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ).withShimmerAi(loading: topTreksLoading),
                              ),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _topTreksController,
                          child: Container(
                            margin: EdgeInsets.only(
                              left: ScreenConstant.size10,
                              top: 1.h,
                            ),
                            child: Row(
                              children: [
                                ...(topTreksCardsData ?? []).map((trekData) =>
                                    Container(
                                      margin: EdgeInsets.only(
                                        right: ScreenConstant.size15,
                                      ),
                                      child: TopTreksCard(
                                        gradientEndColor: Colors.transparent,
                                        imagePath: trekData.imagePath ?? "",
                                        title: trekData.title ?? "",
                                        description:
                                        trekData.description ?? "",
                                        customGradient: AppTheme.customGradient(
                                            trekData.gradient),
                                        textColor: AppTheme.hexToColor(trekData.textColour),
                                        isFavorite: trekData.isFavorite ?? false,
                                        onFavoriteTap: () => _toggleFavorite(
                                            trekData.title ?? ""),
                                      ),
                                    ).withShimmerAi(loading: topTreksLoading))
                                    .toList(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  Obx(() {
                    final shortsLoading = _dashboardC.shortsTreksObserver.value
                        .maybeWhen(loading: (data) => true, orElse: () => false);
                    List<ShortsTreksData>? shortsTreksCardsData = [
                      ShortsTreksData(title: "cvubvghf  gjvhbun",description: "4M",textColour: "#ffffff",imagePath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/image%20(9).png?alt=media&token=a173b677-2c64-47b9-b610-6f8bad60650f",videoPath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/WhatsApp%20Video%202026-04-30%20at%209.47.14%20PM.mp4?alt=media&token=d6f20c28-3369-415b-8859-5a02dad8113a",shortVideoPath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/WhatsApp%20Video%202026-04-30%20at%209.46.02%20PM.mp4?alt=media&token=356e3d97-dfc9-4360-8a98-118a0b60a5c3"),
                      ShortsTreksData(title: "hgvjhbkjnllbhjg h",description: "5M",textColour: "#35323b",imagePath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/image%20(9).png?alt=media&token=a173b677-2c64-47b9-b610-6f8bad60650f",videoPath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/WhatsApp%20Video%202026-04-30%20at%209.47.14%20PM.mp4?alt=media&token=d6f20c28-3369-415b-8859-5a02dad8113a",shortVideoPath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/WhatsApp%20Video%202026-04-30%20at%209.46.02%20PM.mp4?alt=media&token=356e3d97-dfc9-4360-8a98-118a0b60a5c3"),
                    ];

                    // List<ShortsTreksData>? shortsTreksCardsData = _dashboardC
                    //     .shortsTreksObserver.value
                    //     .maybeWhen(
                    //   success: (shortsTreksResponse) =>
                    //   (shortsTreksResponse as ShortsTreksDataResponseModel)
                    //       .data,
                    //   error: (sc) => [],
                    //   orElse: () => [
                    //     ShortsTreksData(),
                    //     ShortsTreksData(),
                    //     ShortsTreksData(),
                    //     ShortsTreksData()
                    //   ],
                    // );

                    if (shortsTreksCardsData?.isEmpty == true) return SizedBox();
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
                                    "Trek Shorts",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ).withShimmerAi(loading: shortsLoading),
                                  Text(
                                    "Watch the Action Unfold!",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s10,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey,
                                    ),
                                  ).withShimmerAi(loading: shortsLoading),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  Get.toNamed('/trek-shorts');
                                },
                                child: Text(
                                  'View more',
                                  style: GoogleFonts.poppins(
                                    decorationColor: CommonColors.blueColor,
                                    color: CommonColors.blueColor,
                                    fontSize: FontSize.s11,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ).withShimmerAi(loading: shortsLoading),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 1.5.h,
                            top: 1.h,
                          ),
                          height: 23.h,
                          child: Listener(
                            onPointerDown: (_) {
                              _isTrekShortsUserInteracting = true;
                              _trekShortsTimer?.cancel();
                            },
                            onPointerUp: (_) {
                              _isTrekShortsUserInteracting = false;
                              _startTrekShortsAutoScroll();
                            },
                            onPointerCancel: (_) {
                              _isTrekShortsUserInteracting = false;
                              _startTrekShortsAutoScroll();
                            },
                            child: PageView.builder(
                              controller: _trekShortsPageController,
                              itemCount: null,
                              pageSnapping: true,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final cardData = shortsTreksCardsData?[
                                index % shortsTreksCardsData.length];
                                return Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 1.w),
                                    child: TrekShorts(shortsData: cardData
                                    ).withShimmerAi(loading: shortsLoading),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  Obx(() {
                    final seasonalForcastLoading = _dashboardC
                        .seasonalForcastObserver.value
                        .maybeWhen(loading: (data) => true, orElse: () => false);

                    List<SeasonalForecastData>? seasonalForecastData = [
                    SeasonalForecastData(title:"Puri SUMMER",description: "From Serene trails to thrilling climbs, find treksthat match your vibes !",imagePath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/man%20in%20front%20of%20the%20house%20in%20winter%20forest%20(1).png?alt=media&token=f889af68-4355-4dae-9289-138db1dfb67b", textColour: "#35323b",gradient: ["#F7EB68","#FFEF3E","#FFEF3E"],styling: StylingModel(title: TitleStylingModel(icon:"https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/Winter.png?alt=media&token=e0098e5c-ba45-4af2-8a54-f1eb8d41874f" ,textColour: "#ffffff",gradient: ["#9f88e0","#9e87e1","#7a56e1"]))),
                    SeasonalForecastData(title:"Munnar",description: "From Serene trails to thrilling climbs, find treksthat match your vibes !",imagePath: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/man%20in%20front%20of%20the%20house%20in%20winter%20forest%20(1).png?alt=media&token=f889af68-4355-4dae-9289-138db1dfb67b",textColour: "#000000",gradient: ["#9f88e0","#9e87e1","#7a56e1"],styling: StylingModel(title: TitleStylingModel(icon: "https://firebasestorage.googleapis.com/v0/b/ram-raheem-solutions.firebasestorage.app/o/Winter.png?alt=media&token=e0098e5c-ba45-4af2-8a54-f1eb8d41874f", textColour: "#35323b",gradient: ["#F7EB68","#FFEF3E","#FFEF3E"]))),
                    ];

                    // List<SeasonalForecastData>? seasonalForecastData = _dashboardC
                    //     .seasonalForcastObserver.value
                    //     .maybeWhen(
                    //   success: (seasonalForcastResponse) =>
                    //   (seasonalForcastResponse
                    //   as SeasonalForecastDataResponseModel)
                    //       .data,
                    //   error: (sc) => [],
                    //   orElse: () => [
                    //     SeasonalForecastData(),
                    //     SeasonalForecastData(),
                    //     SeasonalForecastData(),
                    //     SeasonalForecastData()
                    //   ],
                    // );

                    if (seasonalForecastData?.isEmpty == true) return SizedBox();
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Seasonal Forecast",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ).withShimmerAi(
                                      loading: seasonalForcastLoading),
                                  Text(
                                    "Weather Alerts for Safer Treks!",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s10,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey,
                                    ),
                                  ).withShimmerAi(
                                      loading: seasonalForcastLoading),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  Get.toNamed('/seasonal-forecast');
                                },
                                child: Text(
                                  'View more',
                                  style: TextStyle(
                                    letterSpacing: 2,
                                    decorationColor: CommonColors.blueColor,
                                    color: CommonColors.blueColor,
                                    fontSize: FontSize.s11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ).withShimmerAi(loading: seasonalForcastLoading),
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
                              top: 1.h,
                              bottom: ScreenConstant.size15,
                            ),
                            child: Row(
                              children: [
                                ...(seasonalForecastData ?? [])
                                    .map((cardData) => Padding(
                                  padding: EdgeInsets.only(right: 2.h),
                                  child: SeasonalForecast(
                                    title: cardData.title ?? "",
                                    description:
                                    cardData.description ?? "",
                                    imagePath: cardData.imagePath ?? "",
                                    gradient: AppTheme.customGradient(cardData.gradient),
                                    textColour: AppTheme.hexToColor(cardData.textColour),
                                    titleStylingModel: cardData.styling?.title,
                                  ).withShimmerAi(
                                      loading: seasonalForcastLoading),
                                ))
                                    .toList(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: ScreenConstant.size20),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, bottom: 30.0, left: 0, right: 80.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Go Beyond,\nExplore More!',
                          textAlign: TextAlign.start,
                          style: GoogleFonts.sourceSerif4(
                            fontSize: FontSize.s28,
                            fontWeight: FontWeight.bold,
                            color: CommonColors.greyColorf7f7f7
                                .withOpacity(0.5),
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
                              TextSpan(
                                text: 'Crafted with passion ',
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.bottom,
                                child: Icon(Icons.favorite,
                                    color: CommonColors.red_B52424,
                                    size: FontSize.s12),
                              ),
                              TextSpan(
                                text: '\nrooted in Hyderabad.',
                              ),
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
}