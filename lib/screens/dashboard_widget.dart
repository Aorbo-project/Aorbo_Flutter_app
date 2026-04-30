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

    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
                minHeight: 400,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select Departure Date',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '📅 Green dates have available treks',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    flex: 1,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Obx(() {
                          final isLoading = _dashboardC.calenderTrekDatesObserver.value.maybeWhen(
                            loading: (data) => true,
                            orElse: () => false,
                          );

                          if (isLoading) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Loading available dates...'),
                                ],
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: TableCalendar(
                                firstDay: firstDate,
                                lastDay: lastDate,
                                focusedDay: tempFocusedDay,
                                calendarFormat: tempCalendarFormat,
                                availableCalendarFormats: const {
                                  CalendarFormat.month: 'Month',
                                },
                                onFormatChanged: (format) {
                                  setState(() {
                                    tempCalendarFormat = format;
                                  });
                                },
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    tempSelectedDate = selectedDay;
                                    tempFocusedDay = focusedDay;
                                  });
                                },
                                onPageChanged: (focusedDay) {
                                  tempFocusedDay = focusedDay;
                                },
                                calendarStyle: CalendarStyle(
                                  markersAlignment: Alignment.bottomCenter,
                                  markerSize: 20,
                                  defaultDecoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent,
                                  ),
                                  selectedTextStyle: TextStyle(
                                    color: CommonColors.blackColor,
                                    fontWeight: FontWeight.w700
                                  ),
                                  selectedDecoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: CommonColors.searchbtn,
                                  ),
                                  todayDecoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue.shade100,
                                  ),
                                  weekendTextStyle: TextStyle(
                                    color: Colors.red.shade400,
                                  ),
                                  defaultTextStyle: TextStyle(
                                    color: Colors.black87,
                                  ),
                                  cellPadding: EdgeInsets.zero,
                                  cellMargin: EdgeInsets.all(
                                    MediaQuery.of(context).size.width * 0.01,
                                  ),
                                ),
                                calendarBuilders: CalendarBuilders(
                                  defaultBuilder: (context, day, focusedDay) {
                                    final dateStr = DateFormat('yyyy-MM-dd').format(day);
                                    final trekCount = _dashboardC.availableDates[dateStr];
                                    final isAvailable = trekCount != null && trekCount > 0;

                                    if (day == tempSelectedDate) {
                                      return Container(
                                        margin: EdgeInsets.all(
                                          MediaQuery.of(context).size.width * 0.01,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: CommonColors.searchbtn,
                                          border: Border.all(width: 1,color: Colors.black)
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${day.day}',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context).size.width * 0.035,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    return Container(
                                      margin: EdgeInsets.all(
                                        MediaQuery.of(context).size.width * 0.01,
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isAvailable
                                            ? Colors.green.shade100
                                            : Colors.transparent,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            color: isAvailable
                                                ? Colors.green.shade900
                                                : Colors.black87,
                                            fontWeight: isAvailable
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: MediaQuery.of(context).size.width * 0.035,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  markerBuilder: (context, day, events) {
                                    final dateStr = DateFormat('yyyy-MM-dd').format(day);
                                    final trekCount = _dashboardC.availableDates[dateStr];

                                    if (trekCount != null && trekCount > 0 && day != tempSelectedDate) {
                                      return Positioned(
                                        bottom: 2,
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.045,
                                          height: MediaQuery.of(context).size.width * 0.036,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$trekCount',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context).size.width * 0.028,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return null;
                                  },
                                ),
                                headerStyle: HeaderStyle(
                                  formatButtonVisible: true,
                                  titleCentered: true,
                                  formatButtonShowsNext: false,
                                  titleTextStyle: GoogleFonts.poppins(
                                    fontSize: MediaQuery.of(context).size.width * 0.04,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  formatButtonTextStyle: GoogleFonts.poppins(
                                    fontSize: MediaQuery.of(context).size.width * 0.032,
                                    color: CommonColors.searchbtn,
                                  ),
                                  leftChevronIcon: Icon(
                                    Icons.chevron_left,
                                    color: CommonColors.blackColor,
                                    size: MediaQuery.of(context).size.width * 0.06,
                                  ),
                                  rightChevronIcon: Icon(
                                    Icons.chevron_right,
                                    color: CommonColors.blackColor,
                                    size: MediaQuery.of(context).size.width * 0.06,
                                  ),
                                  headerPadding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                daysOfWeekStyle: DaysOfWeekStyle(
                                  weekdayStyle: GoogleFonts.poppins(
                                    fontSize: MediaQuery.of(context).size.width * 0.032,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                  weekendStyle: GoogleFonts.poppins(
                                    fontSize: MediaQuery.of(context).size.width * 0.032,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade400,
                                  ),
                                  dowTextFormatter: (date, locale) {
                                    return DateFormat.E(locale).format(date).substring(0, 2);
                                  },
                                ),
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (_dashboardC.isDateAvailable(tempSelectedDate)) {
                      int trekCount = _dashboardC.getTrekCountForDate(tempSelectedDate);
                      return Container(
                        padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.03,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${DateFormat('EEEE, MMM d, yyyy').format(tempSelectedDate)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: MediaQuery.of(context).size.width * 0.035,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '$trekCount trek${trekCount > 1 ? 's' : ''} available',
                                    style: GoogleFonts.poppins(
                                      fontSize: MediaQuery.of(context).size.width * 0.03,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (tempSelectedDate != _dashboardC.selectedDate.value) {
                      return Container(
                        padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.03,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No treks available on this date. Please select another date.',
                                style: GoogleFonts.poppins(
                                  fontSize: MediaQuery.of(context).size.width * 0.03,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox();
                  }),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.height * 0.012,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontSize: MediaQuery.of(context).size.width * 0.035,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _dashboardC.selectedDate.value = tempSelectedDate;
                              _dashboardC.dateController.value.text = DateFormat('dd/MM/yyyy').format(tempSelectedDate);
                              _selectedDay = tempSelectedDate;
                              _focusedDay = tempFocusedDay;
                              _calendarFormat = tempCalendarFormat;
                              _updateNearestWeekendDates();
                            });
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CommonColors.searchbtn,
                            padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.height * 0.012,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Select',
                            style: GoogleFonts.poppins(
                              fontSize: MediaQuery.of(context).size.width * 0.035,
                              color: CommonColors.searchbtntext,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        );
      },
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
    _trekShortsTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
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
                    // List<KnowMoreData>? knowMoreCardsData = [
                    //   KnowMoreData(title:"Variety of Treks",subtitle: "From Serene trails to thrilling climbs, find treksthat match your vibes !",hasKnowMore: false,imagePath: "https://firebasestorage.googleapis.com/v0/b/sastastay-1d420.firebasestorage.app/o/knowmore1.png?alt=media&token=32b0be2e-958e-4fd5-8e89-72293ed38cfa",textColor: "#000000",customGradient: ["#F7EB68","#FFEF3E","#FFEF3E"]),
                    //   KnowMoreData(title:"Countless Organizers",subtitle: "Choose from an extensive  network of trusted trek  organizers, All in one place !",hasKnowMore: false,imagePath: "https://firebasestorage.googleapis.com/v0/b/sastastay-1d420.firebasestorage.app/o/knowmore1.png?alt=media&token=32b0be2e-958e-4fd5-8e89-72293ed38cfa",textColor: "#FFFFFF",customGradient: ["#FFFFFF","#B40000","#B40000"])
                    // ];
                    List<KnowMoreData>? knowMoreCardsData = _dashboardC
                        .whatsNewObserver.value
                        .maybeWhen(
                      success: (whatsNewResponse) =>
                      (whatsNewResponse as WhatsNewDataResponseModel)
                          .data,
                      error: (sc) => [],
                      orElse: () => [
                        KnowMoreData(),
                        KnowMoreData(),
                        KnowMoreData(),
                        KnowMoreData()
                      ],
                    );
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
                                        cardData?.customGradient ?? []),
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
                                        cardData?.textColor),
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
                    List<TopTreksData>? topTreksCardsData = _dashboardC
                        .topTreksObserver.value
                        .maybeWhen(
                      success: (topTreksResponse) =>
                      (topTreksResponse as TopTreksDataResponseModel)
                          .data,
                      error: (sc) => [],
                      orElse: () => [
                        TopTreksData(),
                        TopTreksData(),
                        TopTreksData(),
                        TopTreksData()
                      ],
                    );
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
                                        textColor: CommonColors.blackColor,
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
                    List<ShortsTreksData>? shortsTreksCardsData = _dashboardC
                        .shortsTreksObserver.value
                        .maybeWhen(
                      success: (shortsTreksResponse) =>
                      (shortsTreksResponse as ShortsTreksDataResponseModel)
                          .data,
                      error: (sc) => [],
                      orElse: () => [
                        ShortsTreksData(),
                        ShortsTreksData(),
                        ShortsTreksData(),
                        ShortsTreksData()
                      ],
                    );
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
                              padEnds: false,
                              pageSnapping: true,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final cardData = shortsTreksCardsData?[
                                index % shortsTreksCardsData.length];
                                return Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 1.w),
                                    child: TrekShorts(
                                      imagePath: cardData?.imagePath ?? "",
                                      title: cardData?.description ?? "",
                                      description: cardData?.title ?? "",
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
                    List<SeasonalForecastData>? seasonalForecastData = _dashboardC
                        .seasonalForcastObserver.value
                        .maybeWhen(
                      success: (seasonalForcastResponse) =>
                      (seasonalForcastResponse
                      as SeasonalForecastDataResponseModel)
                          .data,
                      error: (sc) => [],
                      orElse: () => [
                        SeasonalForecastData(),
                        SeasonalForecastData(),
                        SeasonalForecastData(),
                        SeasonalForecastData()
                      ],
                    );
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
                                    gradientColors: AppTheme.hexToColor(
                                        cardData.color),
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