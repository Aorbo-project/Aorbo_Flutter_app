import 'dart:async';
import 'package:arobo_app/controller/coupon_controller.dart';
import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/models/coupon_code/coupon_code_model.dart';
import 'package:arobo_app/models/discount_card_model.dart';
import 'package:arobo_app/screens/source_location_screen.dart';
import 'package:arobo_app/screens/trek_details_screen.dart';
import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/arobo_theme.dart';
import 'package:arobo_app/utils/coupon_display_helper.dart';
import 'package:arobo_app/utils/coupon_gradient_card.dart';
import 'package:arobo_app/utils/common_filter_bar.dart';
import 'package:arobo_app/utils/common_trek_card.dart';
import 'package:arobo_app/utils/sponsored_banner_card.dart';
import 'package:arobo_app/utils/native_feed_ad_card.dart';
import 'package:arobo_app/utils/statefullwrapper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../freezed_models/treks/treks_model_data.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';

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

  /// Count the autoplay timer was last armed for — the Obx rebuilds on
  /// every coupon-state change, and re-arming inside it used to restart the
  /// timer (resetting the 5s cadence) over and over.
  int _couponAutoplayCount = -1;

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

  /// The live bottom toast (one at a time; a newer one replaces the older).
  OverlayEntry? _toastEntry;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trekC.fetchSearchSponsored(
        destinationId: _dashboardC.selectedTrekId.value,
      );
    });
  }

  @override
  void deactivate() {
    _couponTimer?.cancel();
    _couponAutoplayCount = -1; // re-arm when the screen becomes active again
    super.deactivate();
  }

  @override
  void dispose() {
    _couponTimer?.cancel();
    _couponPageController.dispose();
    _scrollController.dispose();
    _fadeCtrl.dispose();
    _headerSlideCtrl.dispose();
    // Drop any live toast before the state goes away.
    final old = _toastEntry;
    _toastEntry = null;
    old?.remove();
    super.dispose();
  }

  // ── BOTTOM TOAST — every user-visible change announces itself, sliding
  //    up from the bottom, with its own visual identity.
  void _feedback(String message, {bool error = false}) {
    if (!mounted) return;
    // Replace any live toast.
    final old = _toastEntry;
    _toastEntry = null;
    old?.remove();

    final double bottom = MediaQuery.of(context).padding.bottom + 20;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: bottom,
        left: 16,
        right: 16,
        child: _AppToast(
          message: message,
          error: error,
          onDone: () {
            if (_toastEntry == entry) {
              _toastEntry = null;
              entry.remove();
            }
          },
        ),
      ),
    );
    _toastEntry = entry;
    Overlay.of(context).insert(entry);
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
    return DateFormat('EEE').format(d);
  }

  Future<void> _openExternal(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // A dead ad URL must never surface an error to the user.
    }
  }

  /// True when the search FAILED (network etc.) — must not be shown as
  /// "no treks available".
  bool _searchHasError() => _trekC.treksResponseObserver.value.data.value
      .maybeWhen(error: (_) => true, orElse: () => false);

  /// True only when a search COMPLETED with zero results.
  bool _searchIsEmpty() =>
      _trekC.treksResponseObserver.value.data.value.maybeWhen(
        success: (data) => data is FetchTreksResponseModel
            ? (data.data ?? const []).isEmpty
            : true,
        orElse: () => false, // loading / initial → placeholders, not empty
      );

  /// Server-side filtering/sorting — the whole result set is re-queried
  /// with the active filters, so it stays correct across pagination.
  Future<void> _runSearch() async {
    await _trekC.searchTreks(
      cityId: _dashboardC.selectedCityId.value,
      trekId: _dashboardC.selectedTrekId.value,
      date: _dashboardC.dateController.value.text,
      refresh: true,
      filterQuery: buildFilterQueryString(
        activeFilters,
        groupBooking: _isGroupBooking,
      ),
    );
    _trekC.fetchSearchSponsored(
      destinationId: _dashboardC.selectedTrekId.value,
      cityId: _dashboardC.selectedCityId.value,
      date: TrekController.convertDateYYYYMMDD(
        _dashboardC.dateController.value.text,
      ),
    );
    // Results land asynchronously — force a rebuild so every non-Obx
    // layout decision (nothing depends on it now, but cheap insurance).
    if (mounted) setState(() {});
  }

  Future<void> _applyFilters() async {
    HapticFeedback.selectionClick();
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    await _runSearch();
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await _couponC.fetchPlatformCoupons();
    await _runSearch();
  }

  Future<void> _openLocationSearch() async {
    final int oldCityId = _dashboardC.selectedCityId.value;
    final int oldTrekId = _dashboardC.selectedTrekId.value;
    final String oldFrom = _dashboardC.fromController.value.text;
    final String oldTo = _dashboardC.toController.value.text;

    final bool? completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SourceLocationScreen()),
    );
    if (!mounted || completed != true) return;

    // The route changed — availability for the NEW pair must be fetched
    // here (the dashboard's auto-fetch only runs when the route screen was
    // opened from the dashboard itself).
    await _dashboardC.fetchCalendarDatesNow();
    if (!mounted) return;
    setState(() {});

    final routeChanged =
        oldCityId != _dashboardC.selectedCityId.value ||
        oldTrekId != _dashboardC.selectedTrekId.value;

    if (routeChanged) {
      final from = _dashboardC.fromController.value.text.trim();
      final to = _dashboardC.toController.value.text.trim();
      final old = (oldFrom.isEmpty || oldTo.isEmpty)
          ? 'your previous route'
          : '$oldFrom → $oldTo';
      _feedback('Route updated: $old → $from → $to');
    }

    if (_dashboardC.availableDates.isEmpty) {
      _feedback('No departures on this route yet', error: true);
      await _runSearch();
      return;
    }

    if (_dashboardC.dateController.value.text.isEmpty) {
      await _selectDate(context);
      if (!mounted) return;
      if (_dashboardC.dateController.value.text.isEmpty) {
        await _runSearch();
      }
      return;
    }

    await _onRefresh();
  }

  // ── NOTIFY ME — subscribe to alerts for the current route ───────────────
  Future<void> _subscribeNotify() async {
    HapticFeedback.selectionClick();
    final int cityId = _dashboardC.selectedCityId.value;
    final int trekId = _dashboardC.selectedTrekId.value;
    if (cityId == 0 || trekId == 0) return;
    try {
      await _dashboardC.subscribeToRouteNotification(cityId, trekId);
      _feedback("We'll notify you when dates open on this route");
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      _feedback(
        msg.isEmpty ? 'Could not set up alerts — try again' : msg,
        error: true,
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final bool isCityTrekSelected =
        _dashboardC.selectedCityId.value != 0 &&
        _dashboardC.selectedTrekId.value != 0;

    if (!isCityTrekSelected) {
      _feedback('Pick a departure city and trek first', error: true);
      return;
    }

    if (_ntpTime == null) await _initializeNTPTime();
    if (!context.mounted) return;

    // Fresh availability for the CURRENT route — the observer may still
    // hold the previous route's dates. Fire-and-forget: the sheet renders
    // its own loading state from the observer while it lands.
    unawaited(_dashboardC.fetchCalendarDatesNow());

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
    // A persisted date that isn't available on the current route (or has
    // already passed) must not render as "Selected".
    if (tempSelectedDate.isBefore(firstDate) ||
        !_dashboardC.isDateAvailable(tempSelectedDate)) {
      tempSelectedDate = firstDate;
    }
    // Open on the month of the SELECTION — but table_calendar asserts
    // focusedDay >= firstDay, and the 1st of the CURRENT month is before
    // today, so clamp.
    DateTime tempFocusedDay = DateTime(
      tempSelectedDate.year,
      tempSelectedDate.month,
      1,
    );
    if (tempFocusedDay.isBefore(firstDate)) tempFocusedDay = firstDate;
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
                            padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
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
                                          color: AroboTheme.ink,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Obx(() {
                                        final count =
                                            _dashboardC.availableDates.length;
                                        return Text(
                                          count > 0
                                              ? '$count departures available in the next 3 months'
                                              : 'Tap an available date to continue',
                                          style: AppType.style(
                                            10.5,
                                            color: AroboTheme.inkMid,
                                          ),
                                        );
                                      }),
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
                          _buildQuickDateChips(
                            firstDate,
                            (d) => setSheet(() => tempSelectedDate = d),
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
                            final state =
                                _dashboardC.calenderTrekDatesObserver.value;
                            final bool isLoading = state.maybeWhen(
                              loading: (_) => true,
                              orElse: () => false,
                            );
                            final bool isError = state.maybeWhen(
                              error: (_) => true,
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
                                      Text(
                                        'Loading available dates…',
                                        style: AppType.style(
                                          11.5,
                                          color: AroboTheme.inkMid,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (isError) {
                              return SizedBox(
                                height: 280,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.cloud_off_rounded,
                                        size: 40,
                                        color: AroboTheme.inkLight,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Couldn't load departure dates",
                                        style: AppType.style(
                                          12,
                                          w: FontWeight.w700,
                                          color: AroboTheme.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Check your connection and try again',
                                        style: AppType.style(
                                          10.5,
                                          color: AroboTheme.inkMid,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      GestureDetector(
                                        onTap: () =>
                                            _dashboardC.fetchCalendarDatesNow(),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 22,
                                            vertical: 9,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AroboTheme.primary,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            'Retry',
                                            style: AppType.style(
                                              11,
                                              w: FontWeight.w700,
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
                                    _feedback(
                                      'No treks on '
                                      '${DateFormat('d MMM').format(sel)} — '
                                      'try a highlighted date',
                                      error: true,
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
                                  // Notify the app-bar date chip's Obx.
                                  _dashboardC.dateController.refresh();

                                  Get.back();
                                  _feedback(
                                    'Departure set to '
                                    '${DateFormat('EEE, d MMM').format(sel)}',
                                  );
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
                                  titleTextStyle: AppType.style(
                                    14.5,
                                    w: FontWeight.w700,
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
                                  weekdayStyle: AppType.style(
                                    10.5,
                                    w: FontWeight.w700,
                                    color: AroboTheme.inkMid,
                                    letterSpacing: 0.4,
                                  ),
                                  weekendStyle: AppType.style(
                                    10.5,
                                    w: FontWeight.w700,
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

  /// Quick date chips: Today / First available / Next weekend — all computed
  /// from real availability, so a chip never appears if it can't be picked.
  Widget _buildQuickDateChips(
    DateTime firstDate,
    ValueChanged<DateTime> onPick,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final avail =
        _dashboardC.availableDates.keys
            .map(DateTime.parse)
            .where((d) => !d.isBefore(today))
            .toList()
          ..sort();

    DateTime? firstAvail;
    DateTime? nextWeekend;
    for (final d in avail) {
      firstAvail ??= d;
      if (nextWeekend == null &&
          (d.weekday >= DateTime.thursday && d.weekday <= DateTime.saturday)) {
        nextWeekend = d;
      }
      if (firstAvail != null && nextWeekend != null) break;
    }

    final chips = <({String label, DateTime day})>[];
    if (_dashboardC.isDateAvailable(today)) {
      chips.add((label: 'Today', day: today));
    }
    if (firstAvail != null && !isSameDay(firstAvail, today)) {
      chips.add((
        label: 'First available · ${DateFormat('d MMM').format(firstAvail)}',
        day: firstAvail,
      ));
    }
    if (nextWeekend != null &&
        !chips.any((c) => isSameDay(c.day, nextWeekend))) {
      chips.add((
        label: 'Weekend · ${DateFormat('d MMM').format(nextWeekend)}',
        day: nextWeekend,
      ));
    }
    if (chips.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 34,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) => GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onPick(chips[i].day);
            _dashboardC.selectedDate.value = chips[i].day;
            _dashboardC.dateController.value.text = DateFormat(
              'dd/MM/yyyy',
            ).format(chips[i].day);
            // Notify the app-bar date chip's Obx.
            _dashboardC.dateController.refresh();
            Get.back();
            _feedback(
              'Departure set to '
              '${DateFormat('EEE, d MMM').format(chips[i].day)}',
            );
            _onRefresh();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AroboTheme.tealSoft,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AroboTheme.teal.withValues(alpha: 0.3)),
            ),
            child: Text(
              chips[i].label,
              style: AppType.style(
                9.5,
                w: FontWeight.w700,
                color: AroboTheme.primary,
              ),
            ),
          ),
        ),
      ),
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
          style: AppType.style(
            9.5,
            w: FontWeight.w500,
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
              style: AppType.style(
                12.5,
                w: isSelected || isAvailable
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
                style: AppType.style(
                  9,
                  w: FontWeight.w800,
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
    return StatefulWrapper(
      onInit: () async {
        await _couponC.fetchPlatformCoupons();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) _scrollController.jumpTo(0);
        });
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: _buildAppBar(),
        // FAB visibility is reactive: with zero results (or a failed
        // search) there is nothing to filter — hide it until results
        // return. Reads the search observer INSIDE the Obx so it flips
        // live when async results land (this was the stale-state bug).
        floatingActionButton: Obx(() {
          if (_searchIsEmpty() || _searchHasError()) {
            return const SizedBox.shrink();
          }
          return AroboFilterFab(
            activeFilters: activeFilters,
            groupBookingEnabled: _isGroupBooking,
            onResult: (result) {
              final before = activeFilters.length;
              setState(() {
                activeFilters = List.from(result.selectedTitles);
                _isGroupBooking = result.groupBookingEnabled;
              });
              if (activeFilters.isEmpty && !_isGroupBooking && before > 0) {
                _feedback('Filters cleared — showing all treks');
              } else if (activeFilters.length > before ||
                  result.groupBookingEnabled) {
                _feedback(
                  '${activeFilters.length} filter'
                  '${activeFilters.length == 1 ? '' : 's'} applied',
                );
              }
              _applyFilters();
            },
          );
        }),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: RefreshIndicator(
            color: AroboTheme.primary,
            backgroundColor: AppColors.surface,
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top section visibility is REACTIVE: with zero results
                // (or a failed search) the route strip, coupons and filter
                // pills all collapse — and come back the instant results
                // return. Computed inside the Obx watching the search
                // observer, so async result landings flip it immediately.
                SliverToBoxAdapter(
                  child: Obx(() {
                    if (_searchIsEmpty() || _searchHasError()) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRouteStrip(),
                        const SizedBox(height: 8),
                        _buildCouponCarousel(),
                        const SizedBox(height: 8),
                        _buildActiveFilterPills(),
                      ],
                    );
                  }),
                ),
                _buildTrekList(),
                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Available Treks',
              textScaler: const TextScaler.linear(1.0),
              style: AroboTheme.label(
                size: 15,
                weight: FontWeight.w800,
                color: AroboTheme.ink,
              ),
            ),
            const SizedBox(height: 2),
            // Live result count + filter context.
            Obx(() {
              final isLoading = _trekC.treksResponseObserver.value.data.value
                  .maybeWhen(loading: (_) => true, orElse: () => false);
              final count = _trekC.treksResponseObserver.value.data.value
                  .maybeWhen(
                    success: (data) => data is FetchTreksResponseModel
                        ? (data.data ?? const []).length
                        : 0,
                    orElse: () => 0,
                  );
              final filterLabel = activeFilters.isNotEmpty
                  ? ' · ${activeFilters.length} filter'
                        '${activeFilters.length == 1 ? '' : 's'}'
                  : '';
              final groupLabel = _isGroupBooking ? ' · group' : '';
              return Text(
                isLoading
                    ? 'Finding treks…'
                    : '$count trek${count == 1 ? '' : 's'}'
                          '$filterLabel$groupLabel',
                textScaler: const TextScaler.linear(1.0),
                style: AroboTheme.label(size: 10, color: AroboTheme.ink400),
              );
            }),
          ],
        ),
      ),
      // ── DATE LIVES HERE — one compact chip, always reachable ──
      actions: [
        Obx(() {
          final dateText = _dashboardC.dateController.value.text;
          final parsed = _parseDate(dateText);
          return GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AroboTheme.tealSoft,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: AroboTheme.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 14,
                    color: AroboTheme.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    parsed != null
                        ? DateFormat('d MMM').format(parsed)
                        : 'Date',
                    textScaler: const TextScaler.linear(1.0),
                    style: AroboTheme.label(
                      size: 11,
                      weight: FontWeight.w800,
                      color: AroboTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.expand_more_rounded,
                    size: 14,
                    color: AroboTheme.primary,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // ROUTE CARD — two full-width slots (From / To),
  // stacked so long city & trek names never truncate.
  // ─────────────────────────────────────────────
  Widget _buildRouteStrip() {
    final from = _dashboardC.fromController.value.text.trim();
    final to = _dashboardC.toController.value.text.trim();

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      decoration: BoxDecoration(
        color: AroboTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AroboTheme.border, width: 0.9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F1B4332),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x121B4332),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openLocationSearch,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              children: [
                // ── SLOT 1: Departure city — full-width row ──
                _routeRow(
                  icon: Icons.location_city_rounded,
                  value: from,
                  hint: 'Departure city',
                  valueColor: AroboTheme.ink,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(height: 1, color: AroboTheme.border),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.hiking_rounded,
                          size: 14,
                          color: AroboTheme.primary,
                        ),
                      ),
                      Expanded(
                        child: Divider(height: 1, color: AroboTheme.border),
                      ),
                    ],
                  ),
                ),
                // ── SLOT 2: Destination trek — full row + edit button ──
                Row(
                  children: [
                    Expanded(
                      child: _routeRow(
                        icon: Icons.location_on_rounded,
                        value: to,
                        hint: 'Destination trek',
                        valueColor: AroboTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AroboTheme.ink,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AroboTheme.ink.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A single full-width route slot — icon + generous text.
  Widget _routeRow({
    required IconData icon,
    required String value,
    required String hint,
    required Color valueColor,
  }) {
    final bool filled = value.isNotEmpty;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AroboTheme.elevated,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AroboTheme.border),
          ),
          child: Icon(
            icon,
            size: 16,
            color: filled ? AroboTheme.primary : AroboTheme.ink400,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            filled ? value : hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaler: const TextScaler.linear(1.0),
            style: AroboTheme.label(
              size: 13,
              weight: FontWeight.w800,
              color: filled ? valueColor : AroboTheme.ink400,
            ),
          ),
        ),
      ],
    );
  }

  // ── ACTIVE FILTER PILLS ──────────────────────────────────────────────────
  Widget _buildActiveFilterPills() {
    if (activeFilters.isEmpty && !_isGroupBooking) {
      return const SizedBox.shrink();
    }
    final pills = <Widget>[
      for (final f in activeFilters)
        _filterPill(f, () {
          HapticFeedback.selectionClick();
          setState(() => activeFilters.remove(f));
          _feedback('Filter removed: $f');
          _applyFilters();
        }),
      if (_isGroupBooking)
        _filterPill('Group booking', () {
          HapticFeedback.selectionClick();
          setState(() => _isGroupBooking = false);
          _feedback('Group booking turned off');
          _applyFilters();
        }, icon: Icons.groups_rounded),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
      child: SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: pills.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) => pills[i],
        ),
      ),
    );
  }

  Widget _filterPill(String label, VoidCallback onRemove, {IconData? icon}) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AroboTheme.tealSoft,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AroboTheme.teal.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: AroboTheme.primary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppType.style(
                9.5,
                w: FontWeight.w700,
                color: AroboTheme.primary,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(
              Icons.close_rounded,
              size: 13,
              color: AroboTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  // Fallback gradient per discount_type — only used when the admin hasn't
  // set a custom `styling.gradient` on the coupon.
  static const Map<String, List<String>> _fallbackGradients = {
    'fixed': ['#D97B4F', '#B24A25'],
    'seasonal': ['#0F7B6C', '#1AA090'],
    'percentage': ['#2F5D9E', '#3B7BC4'],
    'group': ['#6B4A9E', '#8B5FBF'],
    'early_bird': ['#B5652D', '#D98C4A'],
    'conditional': ['#B0405B', '#D46A82'],
  };

  List<String> _gradientFor(CouponCardData coupon) {
    if (coupon.gradient != null && coupon.gradient!.length >= 2) {
      return coupon.gradient!;
    }
    return _fallbackGradients[coupon.discountType] ??
        _fallbackGradients['percentage']!;
  }

  Widget _buildCouponCarousel() {
    return Obx(() {
      final coupons = _couponC.adminCouponsObserver.value.maybeWhen(
        success: (data) => data?.data ?? const <CouponCardData>[],
        orElse: () => const <CouponCardData>[],
      );

      if (coupons.isEmpty) return const SizedBox.shrink();

      // Arm autoplay only when the SET actually changed — not on every
      // unrelated Obx rebuild.
      if (coupons.length != _couponAutoplayCount) {
        _couponAutoplayCount = coupons.length;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _startCouponAutoScroll(coupons.length);
        });
      }

      return SizedBox(
        height: 20.h,
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
            itemCount: null,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final coupon = coupons[index % coupons.length];
              final colors = _gradientFor(coupon);
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                child: CouponGradientCard(
                  gradientColors: colors,
                  badgeLabel: CouponDisplayHelper.badgeLabel(coupon),
                  headline: CouponDisplayHelper.headline(coupon),
                  conditionText: CouponDisplayHelper.conditionText(coupon),
                  code: coupon.code ?? '',
                  onCopyCode: () {},
                  onTapTnC: () => _openCouponDetails(coupon, colors),
                  onTap: () => _openCouponDetails(coupon, colors),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  void _openCouponDetails(CouponCardData coupon, List<String> colors) {
    Get.toNamed(
      '/discount-details',
      arguments: {
        'discountCard': DiscountCardModel(
          title: coupon.title ?? '',
          subtitle: coupon.description ?? '',
          gradient: colors,
          textColour: coupon.textColour ?? '#FFFFFF',
          code: coupon.code ?? '',
          offerAmount: CouponDisplayHelper.headline(coupon),
          imagePath: coupon.imagePath ?? '',
          detailedDescription: coupon.detailedDescription ?? '',
          howToApply: coupon.howToApply ?? '',
          termsAndConditions: coupon.termsAndConditions ?? const [],
          validFrom: coupon.validFrom,
          validUntil: coupon.validUntil,
        ),
      },
      preventDuplicates: true,
    );
  }

  Widget _buildTrekList() {
    // Read fresh so the empty-state label never shows a stale date.
    final String dateText = _dashboardC.dateController.value.text;

    return Obx(() {
      final isLoading = _trekC.treksResponseObserver.value.data.value.maybeWhen(
        loading: (_) => true,
        orElse: () => false,
      );

      // A FAILED search must never read as "no treks available".
      final bool failed = _searchHasError();

      final List<TrekData> ranked = _trekC
          .treksResponseObserver
          .value
          .data
          .value
          .maybeWhen(
            success: (data) => data is FetchTreksResponseModel
                ? List<TrekData>.from(data.data ?? const [])
                : <TrekData>[],
            error: (_) => <TrekData>[],
            orElse: () => List.generate(4, (_) => const TrekData()),
          );

      if (!isLoading && failed) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildSearchError(),
        );
      }

      if (!isLoading && ranked.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(dateText),
        );
      }

      // ── Sponsored + featured listings (server-chosen per search) ────
      final listingSlot = _trekC.searchListingSlot.value;
      final bannerSlot = _trekC.searchBannerSlot.value;

      // Now that the sponsored trek must match the current route+date
      // (see fetchSearchSponsored), it can genuinely also appear in the
      // organic results — it's a real match, not a fixed ad. Don't show
      // it twice: tag the organic card instead of injecting a duplicate.
      final sponsoredTrekId = (listingSlot?.trekId ?? 0) > 0
          ? listingSlot!.trekId
          : null;
      final sponsoredIsOrganic =
          sponsoredTrekId != null && ranked.any((t) => t.id == sponsoredTrekId);

      final entries = <({String kind, TrekData? trek, int? slotId})>[];
      var featuredUsed = false;
      for (var i = 0; i < ranked.length; i++) {
        final t = ranked[i];
        final isSponsoredMatch = sponsoredIsOrganic && t.id == sponsoredTrekId;
        final showFeatured =
            !isSponsoredMatch && !featuredUsed && t.featured == true;
        if (showFeatured) featuredUsed = true;
        entries.add((
          kind: isSponsoredMatch
              ? 'sponsored'
              : (showFeatured ? 'featured' : 'trek'),
          trek: t,
          slotId: isSponsoredMatch ? listingSlot!.slotId : null,
        ));
        if (i == 0 &&
            !sponsoredIsOrganic &&
            listingSlot != null &&
            (listingSlot.trekId ?? 0) > 0) {
          entries.add((
            kind: 'sponsored',
            trek: TrekData.fromJson(listingSlot.trekJson),
            slotId: listingSlot.slotId,
          ));
        }
      }
      if (ranked.isNotEmpty && bannerSlot != null) {
        entries.add((kind: 'ad', trek: null, slotId: bannerSlot.id));
      } else if (ranked.length >= 2 && _dashboardC.admobFallbackEnabled.value) {
        entries.add((kind: 'admob', trek: null, slotId: null));
      }
      entries.add((kind: 'spacer', trek: null, slotId: null));

      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final entry = entries[index];

          if (entry.kind == 'spacer') return const SizedBox(height: 40);

          if (entry.kind == 'admob') {
            return Padding(
              padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.h),
              child: SizedBox(
                width: 92.w,
                height: 22.h,
                child: const NativeFeedAdCard(
                  widthFraction: 92,
                  trailingMargin: 0,
                ),
              ),
            );
          }

          if (entry.kind == 'ad') {
            final s = bannerSlot!;
            _dashboardC.logSponsoredImpression(s.id);
            return SponsoredBannerCard(
              advertiser: s.advertiser,
              headline: s.headline ?? '',
              onTap: () {
                _dashboardC.logSponsoredClick(s.id);
                _openExternal(s.ctaUrl);
              },
            );
          }

          final animDelay = 300 + ((index.clamp(0, 5).toInt()) * 80);

          final TrekData trek = entry.trek!;
          final String? tag = entry.kind == 'sponsored'
              ? 'sponsored'
              : (entry.kind == 'featured' ? 'featured' : null);
          if (entry.kind == 'sponsored' && entry.slotId != null) {
            _dashboardC.logSponsoredImpression(entry.slotId!);
          }

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
                listingTag: tag,
                fromLocation: _dashboardC.fromController.value.text,
                toLocation: _dashboardC.toController.value.text,
                onTap: () async {
                  if (entry.kind == 'sponsored' && entry.slotId != null) {
                    _dashboardC.logSponsoredClick(entry.slotId!);
                  }
                  AroboPersonalization.instance.pushRecent(trek.id?.toString());
                  _trekC.trekDetailId.value = trek.id ?? 0;
                  await _trekC.trekDetail(batchId: trek.batchInfo?.id ?? 0);
                  Get.to(() => TrekDetailsScreen(trek: trek));
                },
              ).withShimmerAi(loading: isLoading),
            ),
          );
        }, childCount: ranked.isEmpty ? 0 : entries.length),
      );
    });
  }

  /// Search-failure state — distinct from "no treks", with a retry.
  Widget _buildSearchError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AroboTheme.elevated,
                shape: BoxShape.circle,
                border: Border.all(color: AroboTheme.border, width: 1.5),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 9.w,
                color: AroboTheme.inkLight,
              ),
            ),
            SizedBox(height: 2.2.h),
            Text(
              "Couldn't load treks",
              textScaler: const TextScaler.linear(1.0),
              style: AroboTheme.label(
                size: 15,
                weight: FontWeight.w800,
                color: AroboTheme.ink,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Check your connection and try again',
              textScaler: const TextScaler.linear(1.0),
              style: AroboTheme.label(size: 10.5, color: AroboTheme.inkMid),
            ),
            SizedBox(height: 3.h),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _feedback('Retrying…');
                _onRefresh();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.4.h),
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
                  'Retry',
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
    );
  }

  /// The first available departure strictly AFTER the selected date — used
  /// by the empty state as a one-tap rescue.
  DateTime? _nextAvailableAfter(DateTime? selected) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dates =
        _dashboardC.availableDates.keys
            .map(DateTime.parse)
            .where((d) => !d.isBefore(today))
            .where((d) => selected == null || d.isAfter(selected))
            .toList()
          ..sort();
    return dates.isEmpty ? null : dates.first;
  }

  // ─────────────────────────────────────────────
  // EMPTY STATE — full screen (no coupons/route strip above), with
  // Notify Me, a next-departure rescue chip, and route/date actions.
  // The DATE chip in the app bar stays reachable in this state too.
  // ─────────────────────────────────────────────
  Widget _buildEmptyState(String dateText) {
    final bool filtersActive = activeFilters.isNotEmpty || _isGroupBooking;
    final String routeKey =
        '${_dashboardC.selectedCityId.value}_${_dashboardC.selectedTrekId.value}';
    final next = _nextAvailableAfter(_dashboardC.selectedDate.value);

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
                  filtersActive ? Icons.tune_rounded : Icons.hiking_rounded,
                  size: 11.w,
                  color: AroboTheme.primary,
                ),
              ),
              SizedBox(height: 2.5.h),
              Text(
                filtersActive
                    ? 'No treks match your filters'
                    : 'No treks available',
                textScaler: const TextScaler.linear(1.0),
                style: AroboTheme.label(
                  size: 16,
                  weight: FontWeight.w800,
                  color: AroboTheme.ink,
                ),
              ),
              SizedBox(height: 0.8.h),
              Text(
                filtersActive
                    ? 'Try removing a filter or changing the date'
                    : (dateText.isNotEmpty
                          ? 'for ${_formattedDate(dateText)} on this route'
                          : 'for this route yet'),
                textScaler: const TextScaler.linear(1.0),
                style: AroboTheme.label(
                  size: 12,
                  weight: FontWeight.w600,
                  color: AroboTheme.ink400,
                ),
              ),

              // ── FILTERS caused the empty result → clear them ──
              if (filtersActive) ...[
                SizedBox(height: 3.h),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      activeFilters.clear();
                      _isGroupBooking = false;
                    });
                    _feedback('Filters cleared — showing all treks');
                    _applyFilters();
                  },
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
                      'Clear filters',
                      textScaler: const TextScaler.linear(1.0),
                      style: AroboTheme.label(
                        size: 12,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // ── One-tap rescue: the next date that HAS departures ──
                if (next != null) ...[
                  SizedBox(height: 1.6.h),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _dashboardC.selectedDate.value = next;
                      _dashboardC.dateController.value.text = DateFormat(
                        'dd/MM/yyyy',
                      ).format(next);
                      _dashboardC.dateController.refresh();
                      setState(() {});
                      _feedback(
                        'Departure moved to '
                        '${DateFormat('EEE, d MMM').format(next)}',
                      );
                      _onRefresh();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 1.1.h,
                      ),
                      decoration: BoxDecoration(
                        color: AroboTheme.tealSoft,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: AroboTheme.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: AroboTheme.primary,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Next departure · '
                            '${DateFormat('EEE, d MMM').format(next)}',
                            textScaler: const TextScaler.linear(1.0),
                            style: AroboTheme.label(
                              size: 11,
                              weight: FontWeight.w700,
                              color: AroboTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // ── NOTIFY ME — alerts when dates open on this route ──
                SizedBox(height: 2.2.h),
                Obx(() {
                  final subscribed =
                      _dashboardC.notifiedRoutes[routeKey] ?? false;
                  return GestureDetector(
                    onTap: subscribed ? null : _subscribeNotify,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 1.4.h,
                      ),
                      decoration: BoxDecoration(
                        color: subscribed
                            ? AroboTheme.tealSoft
                            : AroboTheme.primary,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AroboTheme.primary.withValues(
                            alpha: subscribed ? 0.35 : 1,
                          ),
                        ),
                        boxShadow: subscribed
                            ? null
                            : [
                                BoxShadow(
                                  color: AroboTheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            subscribed
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_none_rounded,
                            size: 16,
                            color: subscribed
                                ? AroboTheme.primary
                                : Colors.white,
                          ),
                          SizedBox(width: 2.5.w),
                          Text(
                            subscribed
                                ? "You'll be notified"
                                : 'Notify me when dates open',
                            textScaler: const TextScaler.linear(1.0),
                            style: AroboTheme.label(
                              size: 12,
                              weight: FontWeight.w700,
                              color: subscribed
                                  ? AroboTheme.primary
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],

              // ── Change search → the route screen ──
              SizedBox(height: 1.6.h),
              GestureDetector(
                onTap: _openLocationSearch,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 7.w,
                    vertical: 1.4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AroboTheme.primary),
                  ),
                  child: Text(
                    'Change search',
                    textScaler: const TextScaler.linear(1.0),
                    style: AroboTheme.label(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AroboTheme.primary,
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

// ─────────────────────────────────────────────
//  BOTTOM TOAST — slides up from the bottom,
//  holds, fades out; removes itself.
// ─────────────────────────────────────────────
class _AppToast extends StatefulWidget {
  final String message;
  final bool error;
  final VoidCallback onDone;
  const _AppToast({
    required this.message,
    required this.error,
    required this.onDone,
  });

  @override
  State<_AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<_AppToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _slideIn;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.error ? 2900 : 2100),
    )..forward().whenComplete(widget.onDone);
    _slideIn = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.09, curve: Curves.easeOutCubic),
    );
    _fadeOut = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.88, 1.0, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.error ? AroboTheme.danger : AroboTheme.primary;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final double opacity = (_slideIn.value * (1 - _fadeOut.value)).clamp(
            0.0,
            1.0,
          );
          // Slide up from below on entry; sink slightly on exit.
          final double dy = (36 * (1 - _slideIn.value)) + (14 * _fadeOut.value);
          return Opacity(
            opacity: opacity,
            child: Transform.translate(offset: Offset(0, dy), child: child),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AroboTheme.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 26,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.error
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_rounded,
                    size: 16,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.style(
                      11,
                      w: FontWeight.w700,
                      color: AroboTheme.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
