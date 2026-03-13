import 'dart:developer';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/models/seasonal_forecast_data.dart';
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
import 'package:sizer/sizer.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:ntp/ntp.dart';

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
    viewportFraction: 0.38, // Balanced for better card visibility
  );
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final TrekController _trekC = Get.find<TrekController>();

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
      });
    } catch (e) {
      // Fallback to device time if NTP fails
      setState(() {
        _ntpTime = DateTime.now();
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

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dashboardC.selectedDate.value ?? normalizedCurrentTime,
      firstDate: normalizedCurrentTime,
      lastDate: normalizedCurrentTime.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: CommonColors.appBgColor,
              onPrimary: CommonColors.whiteColor,
              onSurface: CommonColors.blackColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dashboardC.selectedDate.value) {
      // Normalize picked date to start of day for comparison
      final DateTime normalizedPicked = DateTime(
        picked.year,
        picked.month,
        picked.day,
      );

      // Compare normalized dates
      if (normalizedPicked.isBefore(normalizedCurrentTime)) {
        CustomSnackBar.show(
          context,
          message: 'Please select today or a future date',
        );
        return;
      }

      setState(() {
        _dashboardC.selectedDate.value = picked;
        _dashboardC.dateController.value.text =
            DateFormat('dd/MM/yyyy').format(picked);
        _updateNearestWeekendDates();
      });
    }
  }

  // void _clearFromField() {
  //   setState(() {
  //     _fromController.clear();
  //   });
  // }

  // void _clearToField() {
  //   setState(() {
  //     _toController.clear();
  //   });
  // }

  Future<void> _selectSourceLocation() async {
    final City? selectedCity = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SourceLocationScreen(
          hintText: "Search Source Location",
          title: "Popular Cities",
          locationType: LocationType.city,
          // popularCities: popularCities,
          // allCities: allCities,
        ),
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
        builder: (context) => SourceLocationScreen(
          hintText: "Search Destination Location",
          title: "Popular Treks",
          locationType: LocationType.trek,
          // popularCities: popularTreks.map((t) => City(name: t.name)).toList(),
          // allCities: allTreks.map((t) => City(name: t.name)).toList(),
        ),
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
    await _trekC.searchTrek(
      cityId: _dashboardC.selectedCityId.value,
      trekId: _dashboardC.selectedTrekId.value,
      date: _dashboardC.dateController.value.text,
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

        // Check if the current context is valid and the widget is still visible
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

  // Add method to toggle favorite state
  void _toggleFavorite(String trekTitle) {
    setState(() {
      _favoriteTreks[trekTitle] = !(_favoriteTreks[trekTitle] ?? false);

      // Update the topTreksCardsData list
      final trekIndex =
          topTreksCardsData.indexWhere((trek) => trek['title'] == trekTitle);
      if (trekIndex != -1) {
        topTreksCardsData[trekIndex]['isFavorite'] = _favoriteTreks[trekTitle];
      }
    });
  }

  // Function to get nearest weekend dates
  void _updateNearestWeekendDates() {
    if (_dashboardC.selectedDate.value == null) return;

    _nearestWeekendDates.clear();
    DateTime currentDate = _dashboardC.selectedDate.value!;

    // Ensure we're not looking at dates before NTP time
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

    // Find the next Thursday, Friday, and Saturday
    for (int i = 0; i < 7; i++) {
      DateTime checkDate = currentDate.add(Duration(days: i));
      // Thursday = 4, Friday = 5, Saturday = 6
      if ([4, 5, 6].contains(checkDate.weekday)) {
        _nearestWeekendDates.add(checkDate);
      }
    }
  }

  bool get _isFormValid =>
      _dashboardC.fromController.value.text.isNotEmpty &&
      _dashboardC.toController.value.text.isNotEmpty &&
      _dashboardC.dateController.value.text.isNotEmpty;

  LinearGradient _getGradientByName(String name) {
    switch (name) {
      case 'gradientYellow':
        return CommonColors.gradientYellow;
      case 'gradientDarkRed':
        return CommonColors.gradientDarkRed;
      case 'gradientTeal':
        return CommonColors.gradientTeal;
      case 'gradientOrange':
        return CommonColors.gradientOrange;
      case 'gradientBlue':
        return CommonColors.gradientBlue;
      case 'gradientGreen':
        return CommonColors.gradientGreen;
      default:
        return CommonColors.gradientYellow;
    }
  }

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
                    bottomRight: Radius.circular(18)),
              ),
              margin: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
              child: Container(
                decoration: BoxDecoration(
                  gradient: CommonColors.homeScreenBgGradient,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18)),
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
                          // color: Colors.red,
                          margin: EdgeInsets.only(left: 18, right: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    CommonImages.logo2,
                                    height: 7.h,
                                    width: 30.w,
                                  ),
                                  // SvgPicture.asset(
                                  //   CommonImages.logo2,
                                  //   // colorFilter: ColorFilter.mode(
                                  //   //     CommonColors.blackColor,
                                  //   //     BlendMode.srcIn),
                                  //   height: ScreenConstant.size21,
                                  //   width: ScreenConstant.size21,
                                  // ),
                                  // SizedBox(width: ScreenConstant.size8),
                                  // Text(
                                  //   'Hyderabad',
                                  //   textScaler: const TextScaler.linear(1.0),
                                  //   style: TextStyle(
                                  //     color: CommonColors.whiteColor,
                                  //     fontSize: FontSize.s14,
                                  //     fontWeight: FontWeight.w500,
                                  //   ),
                                  // ),
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
                            // textScaler: const TextScaler.linear(1.0),
                            style: TextStyle(
                              fontSize: FontSize.s14,
                              color: CommonColors.whiteColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: ScreenConstant.size27),
                        // Search Card
                        Container(
                          // height: 24.h,
                          // color: Colors.red,
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
                                  bottom: ScreenConstant.size16),
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
                                                            .withValues(
                                                          alpha: 0.5,
                                                        ),
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
                                              .withValues(alpha: 0.1),
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
                                                            .withValues(
                                                          alpha: 0.5,
                                                        ),
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
                                              .withValues(alpha: 0.1),
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
                                            child: GestureDetector(
                                              onTap: () => _selectDate(context),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 1.h),
                                                  Text(
                                                    'Departure Date',
                                                    textScaler:
                                                        const TextScaler.linear(
                                                            1.0),
                                                    style: GoogleFonts.poppins(
                                                      color: CommonColors
                                                          .grey_AEAEAE,
                                                      fontSize: FontSize.s10,
                                                    ),
                                                  ),
                                                  SizedBox(height: 0.2.h),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Obx(() => Text(
                                                        _dashboardC
                                                                .dateController
                                                                .value
                                                                .text
                                                                .isNotEmpty
                                                            ? _dashboardC
                                                                .dateController
                                                                .value
                                                                .text
                                                            : 'xx/xx/xxxx',
                                                        textScaler:
                                                            const TextScaler
                                                                .linear(1.0),
                                                        style: TextStyle(
                                                          fontSize:
                                                              FontSize.s10,
                                                          color: CommonColors
                                                              .blackColor,
                                                        ),
                                                      )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Positioned.fill(
                                        child: TouchRipple(
                                          rippleColor: CommonColors.blackColor
                                              .withValues(alpha: 0.1),
                                          onTap: () => _selectDate(context),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                          ),
                                        ),
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
                                        await _trekC.searchTrek(
                                          cityId:
                                              _dashboardC.selectedCityId.value,
                                          trekId:
                                              _dashboardC.selectedTrekId.value,
                                          date: _dashboardC
                                              .dateController.value.text,
                                        );
                                        Get.toNamed(
                                          '/weekend-treks',
                                          arguments: {
                                            'city': _dashboardC
                                                .fromController.value.text,
                                            'trek': _dashboardC
                                                .toController.value.text,
                                            'date': _dashboardC
                                                .dateController.value.text,
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
                                              .withValues(alpha: 0.3),
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
                  Container(),
                  // What's New Section
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
                            ),
                            Text(
                              'Adventure simplified combo delivers !',
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s10,
                                color: Colors.grey,
                              ),
                            ),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Know More Cards
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
                          _currentPage = page % knowMoreCardsData.length;
                        },
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final cardData = knowMoreCardsData[
                              index % knowMoreCardsData.length];
                          return Container(
                            margin: EdgeInsets.only(
                              left: ScreenConstant.size0,
                              right: ScreenConstant.size6,
                            ),
                            child: KnowMoreCard(
                              customGradient: cardData['customGradient'],
                              imagePath: cardData['imagePath'],
                              title: cardData['title'],
                              subtitle: cardData['subtitle'],
                              onKnowMoreTap: cardData['hasKnowMore'] == false
                                  ? null
                                  : () {
                                      Get.toNamed(
                                        '/know-more-details',
                                        arguments: {
                                          'knowMoreData': KnowMoreData(
                                            title: cardData['title'],
                                            subtitle: cardData['subtitle'],
                                            imagePath: cardData['imagePath'],
                                            customGradient:
                                                cardData['customGradient'],
                                            textColor: cardData['textColor'],
                                            detailedTitle:
                                                cardData['detailedTitle'],
                                            detailedDescription:
                                                cardData['detailedDescription'],
                                            bulletPoints:
                                                cardData['bulletPoints'],
                                            callToAction:
                                                cardData['callToAction'],
                                          ),
                                        },
                                      );
                                    },
                              // width: MediaQuery.of(context).size.width * 0.8,
                              // height: MediaQuery.of(context).size.height * 0.20,
                              textColor: cardData['textColor'],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Top Treks Section
                  // Container(),
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
                            ),
                            Text(
                              "Season's Best Treks, Ready for you !",
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Get.toNamed('/popular-treks');
                          },
                          child: Text(
                            'View more',
                            // textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              // decoration: TextDecoration.underline,
                              decorationColor: CommonColors.blueColor,
                              color: CommonColors.blueColor,
                              fontSize: FontSize.s11,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Top Treks Cards
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
                          // SizedBox(width: ScreenConstant.size16),
                          ...topTreksCardsData
                              .map((trekData) => Container(
                                    margin: EdgeInsets.only(
                                      right: ScreenConstant.size15,
                                    ),
                                    child: TopTreksCard(
                                      gradientEndColor: Colors.transparent,
                                      imagePath: trekData['imagePath'],
                                      title: trekData['title'],
                                      description: trekData['description'],
                                      customGradient: _getGradientByName(
                                          trekData['gradient']),
                                      textColor: trekData['textColor'],
                                      isFavorite:
                                          _favoriteTreks[trekData['title']] ??
                                              false,
                                      onFavoriteTap: () =>
                                          _toggleFavorite(trekData['title']),
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                  ),

                  // Container(),
                  Padding(
                    padding: EdgeInsets.only(
                      left: ScreenConstant.size17,
                      right: ScreenConstant.size17,
                      top: ScreenConstant.size10,
                      // bottom: ScreenConstant.size10
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
                            ),
                            Text(
                              "Watch the Action Unfold!",
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s10,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Get.toNamed('/trek-shorts');
                          },
                          child: Text(
                            'View more',
                            // textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              // decoration: TextDecoration.underline,
                              decorationColor: CommonColors.blueColor,
                              color: CommonColors.blueColor,
                              fontSize: FontSize.s11,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Trek Shorts Cards with PageView
                  Container(
                    margin: EdgeInsets.only(
                      left: 1.5.h,
                      top: 1.h,
                    ),
                    height: 23.h, // Match the height of TrekShorts widget
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
                        // Infinite scrolling
                        padEnds: false,
                        pageSnapping: true,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final cardData = shortsTreksCardsData[
                              index % shortsTreksCardsData.length];
                          return Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 1.w),
                              child: TrekShorts(
                                imagePath: cardData['imagePath'],
                                title: cardData['title'],
                                description: cardData['description'],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Container(),
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
                            ),
                            Text(
                              "Weather Alerts for Safer Treks!",
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s10,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Get.toNamed('/seasonal-forecast');
                          },
                          child: Text(
                            'View more',
                            // textScaler: const TextScaler.linear(1.0),
                            style: TextStyle(
                              // decoration: TextDecoration.underline,
                              letterSpacing: 2,
                              decorationColor: CommonColors.blueColor,
                              color: CommonColors.blueColor,
                              fontSize: FontSize.s11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
                          ...seasonalForecastData
                              .map((cardData) => Padding(
                                    padding: EdgeInsets.only(right: 2.h),
                                    child: SeasonalForecast(
                                      title: cardData['title'],
                                      description: cardData['description'],
                                      imagePath: cardData['imagePath'],
                                      gradientColors: cardData['color'],
                                      // onViewMore: () {
                                      //   // Handle view more tap
                                      // },
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: ScreenConstant.size20),

                  // ➕ Added this new section right below Seasonal Forecast
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
                          // textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.sourceSerif4(
                            fontSize: FontSize.s28,
                            fontWeight: FontWeight.bold,
                            color: CommonColors.greyColorf7f7f7
                                .withValues(alpha: 0.5),
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
