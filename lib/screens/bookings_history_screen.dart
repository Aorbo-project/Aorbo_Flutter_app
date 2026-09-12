import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/screens/booking_upcoming_screen.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import 'package:sizer/sizer.dart';

import '../freezed_models/booking/booking_history_model.dart';
import '../utils/common_booked_card.dart';
import '../utils/common_colors.dart';
import '../utils/ist_date_utils.dart';
import '../utils/screen_constants.dart'; // FontSize

// ─────────────────────────────────────────────
//  DESIGN TOKENS — aligned with CommonBookedCard
// ─────────────────────────────────────────────
class _Bk {
  static const bg = Colors.white;
  static const ink = AppColors.inkStrong;
  static const inkMid = Color(0xFF64748B);
  static const inkFaint = Color(0xFF94A3B8);
  static const hairline = Color(0xFFDDE3EC);
  static const brand = Color(0xFF3B82F6);
  static const brandSoft = AppColors.infoSoft;
  static const divider = AppColors.divider;
  static const upcoming = AppColors.info;
  static const ongoing = Color(0xFF0891B2);
  static const completed = AppColors.success;
  static const cancelled = AppColors.danger;
  static const warning = AppColors.warning;
}

const List<String> _kMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _kMonthsFull = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _fmt(DateTime d) => '${d.day} ${_kMonths[d.month - 1]} ${d.year}';
String _fmtShort(DateTime d) => '${d.day} ${_kMonths[d.month - 1]}';

String _startDisplay(DateTime d) {
  final now = DateTime.now();
  return d.year == now.year ? _fmtShort(d) : '${_fmtShort(d)} ${d.year}';
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime? _tryParseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    return ISTDateUtils.toIST(raw);
  } catch (_) {
    return null;
  }
}

String _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  final dt = _tryParseDate(raw);
  return dt == null ? raw : _fmt(dt);
}

String _initials(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
}

// ─────────────────────────────────────────────
//  FILTERS — Status · Calendar range · Destination
// ─────────────────────────────────────────────
class _Filters {
  DateTimeRange? range;
  final Set<String> destinations = <String>{};
  final Set<String> statuses = <String>{};

  _Filters copy() {
    return _Filters()
      ..range = range
      ..destinations.addAll(destinations)
      ..statuses.addAll(statuses);
  }

  void reset() {
    range = null;
    destinations.clear();
    statuses.clear();
  }

  bool get hasAny =>
      range != null || destinations.isNotEmpty || statuses.isNotEmpty;

  int get activeCount {
    var n = 0;
    if (range != null) n++;
    if (destinations.isNotEmpty) n++;
    if (statuses.isNotEmpty) n++;
    return n;
  }
}

class _StatusOption {
  final String id;
  final String label;
  final Color color;
  const _StatusOption(this.id, this.label, this.color);
}

const List<_StatusOption> _kStatusOptions = [
  _StatusOption('upcoming', 'Upcoming', _Bk.upcoming),
  _StatusOption('ongoing', 'Ongoing', _Bk.ongoing),
  _StatusOption('completed', 'Completed', _Bk.completed),
  _StatusOption('cancelled', 'Cancelled', _Bk.cancelled),
];

class _MonthGroup {
  final String label;
  final List<BookingHistoryData> items = [];
  _MonthGroup(this.label);
}

/// A human, state-aware message — used ONLY on the live band now.
class _TripTag {
  final String message;
  final IconData icon;
  final Color color;
  const _TripTag(this.message, this.icon, this.color);
}

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────
class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final ScrollController _scrollC = ScrollController();

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  /// 0 = Upcoming · 1 = Past · 2 = All
  int _segment = 0;
  bool _segmentTouched = false;

  final _Filters _filters = _Filters();
  bool _showBackToTop = false;

  /// Most recent booking paid within the last 2 days (banner + spotlight).
  BookingHistoryData? _recentBooking;
  final GlobalKey _spotlightKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _dashboardC.selectedFilter.value = 'All Bookings';
      _dashboardC.loadAllBookingHistory();
    });
  }

  @override
  void dispose() {
    _scrollC.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── ACTIONS ──────────────────────────────────────────────────────────────
  void _goBack() {
    final route = ModalRoute.of(context);
    if (route?.settings.name == '/my-bookings') {
      // Opened as a pushed route (Profile → My Bookings): just pop,
      // the Profile screen is still underneath.
      Get.back();
      return;
    }
    // Embedded inside the dashboard shell: switch to Home tab.
    _dashboardC.selectedScreen.value = 0;
  }

  void _enterFailedMode() {
    FirebaseCrashlytics.instance.log('Bookings: failed payments opened');
    _dashboardC.selectedFilter.value = 'Failed Payments';
    _dashboardC.getFailedBookingAttempts();
  }

  void _exitFailedMode() {
    _dashboardC.selectedFilter.value = 'All Bookings';
    _dashboardC.loadAllBookingHistory();
  }

  Future<void> _onRefresh() async {
    if (_dashboardC.selectedFilter.value == 'Failed Payments') {
      await _dashboardC.getFailedBookingAttempts(force: true);
    } else {
      await _dashboardC.loadAllBookingHistory(
        force: true,
        waitForCompletion: false,
      );
    }
  }

  void _onSegmentChanged(int i) {
    HapticFeedback.selectionClick();
    setState(() {
      _segment = i;
      _segmentTouched = true;
    });
  }

  void _resetFilters() {
    HapticFeedback.selectionClick();
    setState(() => _filters.reset());
  }

  // ── JUST BOOKED: banner → jump to the full card in Upcoming ─────────────
  void _jumpToBooking() {
    HapticFeedback.selectionClick();
    if (_recentBooking == null) return;
    setState(() {
      _filters.reset();
      _segment = 0; // Upcoming
      _segmentTouched = true;
    });
    _revealRecent(0);
  }

  /// The just-booked card may sit far below the viewport and not be built
  /// yet (slivers are lazy), so step down one screen at a time until the
  /// spotlight key exists, then glide to it.
  void _revealRecent(int attempt) {
    if (attempt > 15) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final BuildContext? ctx = _spotlightKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          alignment: 0.15,
        );
        return;
      }
      if (_scrollC.hasClients) {
        final pos = _scrollC.position;
        if (pos.pixels < pos.maxScrollExtent) {
          final double next = math.min(
            pos.pixels + pos.viewportDimension * 0.9,
            pos.maxScrollExtent,
          );
          _scrollC.jumpTo(next);
          _revealRecent(attempt + 1);
        }
      }
    });
  }

  // ── DATA HELPERS ─────────────────────────────────────────────────────────
  String _statusOf(BookingHistoryData b) =>
      (b.trekStatus ?? '').toLowerCase().trim();

  bool _isUpcoming(BookingHistoryData b) => _statusOf(b) == 'upcoming';
  bool _isOngoing(BookingHistoryData b) => _statusOf(b) == 'ongoing';

  DateTime? _startOf(BookingHistoryData b) => _tryParseDate(b.batch?.startDate);

  String _destinationOf(BookingHistoryData b) =>
      (b.trek?.destination?.name ?? '').trim();

  int? _durationDaysOf(BookingHistoryData b) {
    final dynamic d = b.trek?.durationDays;
    if (d is num) return d.round();
    return null;
  }

  String _durationLabel(BookingHistoryData b) {
    final dynamic days = b.trek?.durationDays;
    final dynamic nights = b.trek?.durationNights;
    final String? d = days?.toString();
    final String? n = nights?.toString();
    if (d != null || n != null) return '${d ?? '0'}D / ${n ?? '0'}N';
    final String? dur = b.trek?.duration;
    if (dur != null && dur.isNotEmpty) return dur;
    return '-';
  }

  String _bookingIdOf(BookingHistoryData b) =>
      b.bookingNumber ?? '#${b.id ?? '-'}';

  String _countdownShort(DateTime start) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = DateTime(
      start.year,
      start.month,
      start.day,
    ).difference(today).inDays;
    if (days <= 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days < 7) return 'In $days days';
    if (days < 30) return 'In ${(days / 7).ceil()} weeks';
    return 'In ${(days / 30).ceil()} months';
  }

  String _liveDayLabel(BookingHistoryData b) {
    final DateTime? s = _startOf(b);
    if (s == null) return 'Live now';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(s.year, s.month, s.day);
    final int day = today.difference(start).inDays + 1;
    final int? total = _durationDaysOf(b);
    if (total == null || total < 1 || day < 1) return 'Live now';
    return 'Day ${day > total ? total : day} of $total';
  }

  List<BookingHistoryData> _dedupe(List<BookingHistoryData> list) {
    final seen = <Object>{};
    final out = <BookingHistoryData>[];
    for (final b in list) {
      final key = b.id ?? b;
      if (seen.add(key)) out.add(b);
    }
    return out;
  }

  List<BookingHistoryData> _currentBookings() {
    final raw = _dashboardC.bookingHistoryObserver.value.data.value.maybeWhen(
      success: (resp) =>
          (resp as BookingHistoryModel).data ?? const <BookingHistoryData>[],
      orElse: () => const <BookingHistoryData>[],
    );
    return _dedupe(raw);
  }

  int _compareStartAsc(BookingHistoryData a, BookingHistoryData b) {
    final da = _startOf(a);
    final db = _startOf(b);
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  }

  int _compareTrekDateDesc(BookingHistoryData a, BookingHistoryData b) {
    final da = _startOf(a) ?? _tryParseDate(a.bookingDate);
    final db = _startOf(b) ?? _tryParseDate(b.bookingDate);
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return db.compareTo(da);
  }

  // ── SEGMENT + FILTER PIPELINE ────────────────────────────────────────────
  // Live treks live ONLY in the top section (hero / carousel) and inside
  // "All" — they never pollute the Upcoming tab. Filters and tabs never stack.
  List<BookingHistoryData> _scopedList(List<BookingHistoryData> all) {
    switch (_segment) {
      case 0:
        return all.where(_isUpcoming).toList()..sort(_compareStartAsc);
      case 1:
        return all.where((b) => !_isUpcoming(b) && !_isOngoing(b)).toList()
          ..sort(_compareTrekDateDesc);
      default:
        return all.toList()..sort(_compareTrekDateDesc);
    }
  }

  List<BookingHistoryData> _applyFiltersList(
    List<BookingHistoryData> list,
    _Filters f,
  ) {
    if (!f.hasAny) return list;
    return list.where((b) {
      if (f.statuses.isNotEmpty && !f.statuses.contains(_statusOf(b))) {
        return false;
      }
      if (f.range != null && !_rangeMatches(f.range!, _startOf(b))) {
        return false;
      }
      if (f.destinations.isNotEmpty &&
          !f.destinations.contains(_destinationOf(b))) {
        return false;
      }
      return true;
    }).toList();
  }

  bool _rangeMatches(DateTimeRange r, DateTime? start) {
    if (start == null) return false;
    final s = DateTime(start.year, start.month, start.day);
    final a = DateTime(r.start.year, r.start.month, r.start.day);
    final b = DateTime(r.end.year, r.end.month, r.end.day);
    return !s.isBefore(a) && !s.isAfter(b);
  }

  List<String> _destinationOptions(List<BookingHistoryData> list) {
    final set = <String>{};
    for (final b in list) {
      final d = b.trek?.destination?.name;
      if (d != null && d.trim().isNotEmpty) set.add(d.trim());
    }
    final options = set.toList()..sort();
    return options.length > 1 ? options : const <String>[];
  }

  List<_MonthGroup> _groupByMonth(List<BookingHistoryData> items) {
    final groups = <_MonthGroup>[];
    String? lastKey;
    for (final b in items) {
      final d = _startOf(b) ?? _tryParseDate(b.bookingDate);
      final key = d == null ? 'earlier' : '${d.year}-${d.month}';
      if (key != lastKey) {
        groups.add(
          _MonthGroup(
            d == null ? 'Earlier' : '${_kMonthsFull[d.month - 1]} ${d.year}',
          ),
        );
        lastKey = key;
      }
      groups.last.items.add(b);
    }
    return groups;
  }

  /// Live-trek band message ("Day 2 of 3 — hope you're loving the trail").
  /// Text banners exist ONLY for live treks until the next update.
  String _liveMessageFor(BookingHistoryData b) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final DateTime? start = _startOf(b);
    if (start != null) {
      final s = DateTime(start.year, start.month, start.day);
      final int? total = _durationDaysOf(b);
      final int day = today.difference(s).inDays + 1;
      if (day <= 1) return 'Your journey has begun — enjoy every step!';
      if (total != null && day >= total) return 'Final day — soak it all in!';
      if (total != null && total > 1) {
        return "Day ${day > total ? total : day} of $total — hope you're loving the trail";
      }
    }
    return 'Happening now — have an amazing trek!';
  }

  /// The freshest upcoming booking paid within the last 2 days, if any.
  BookingHistoryData? _justBookedBooking(List<BookingHistoryData> all) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    BookingHistoryData? best;
    DateTime? bestDate;
    for (final b in all) {
      if (_statusOf(b) != 'upcoming') continue;
      final DateTime? dt = _tryParseDate(b.bookingDate);
      if (dt == null) continue;
      final d = DateTime(dt.year, dt.month, dt.day);
      if (today.difference(d).inDays > 2) continue;
      if (bestDate == null || dt.isAfter(bestDate)) {
        best = b;
        bestDate = dt;
      }
    }
    return best;
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Bk.bg,
      appBar: _buildAppBar(context),
      floatingActionButton: _buildBackToTop(),
      body: FadeTransition(opacity: _fade, child: Obx(() => _buildBody())),
    );
  }

  Widget _buildBody() {
    if (_dashboardC.selectedFilter.value == 'Failed Payments') {
      return _failedView();
    }

    final data = _dashboardC.bookingHistoryObserver.value.data.value;
    final bool loading = data.maybeWhen(
      loading: (_) => true,
      orElse: () => false,
    );
    final bool settled = data.maybeWhen(
      success: (_) => true,
      error: (_) => true,
      orElse: () => false,
    );
    final bool hasError = data.maybeWhen(
      error: (_) => true,
      orElse: () => false,
    );

    if (loading || !settled) return _scrollBody(_shimmerSlivers());
    if (hasError) {
      return _scrollBody([
        SliverFillRemaining(hasScrollBody: false, child: _buildErrorState()),
      ]);
    }

    final all = _currentBookings();
    if (all.isEmpty) {
      return _scrollBody([
        SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState()),
      ]);
    }

    // Live treks are already the top section — default straight to Upcoming.
    final bool hasUpcoming = all.any(_isUpcoming);
    if (!_segmentTouched) {
      _segment = hasUpcoming ? 0 : 1;
    }

    final filtered = _filters.hasAny
        ? _applyFiltersList(all, _filters)
        : _scopedList(all);
    final bool syncing =
        !_dashboardC.bookingHistoryObserver.value.isPaginationCompleted;

    return _scrollBody(
      _contentSlivers(all: all, filtered: filtered, syncing: syncing),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _Bk.bg,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: Obx(() {
        final failed = _dashboardC.selectedFilter.value == 'Failed Payments';
        return IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: failed ? _exitFailedMode : _goBack,
        );
      }),
      centerTitle: false,
      iconTheme: const IconThemeData(color: _Bk.ink),
      title: Obx(() {
        final failed = _dashboardC.selectedFilter.value == 'Failed Payments';
        final model = _dashboardC.bookingHistoryObserver.value;
        final data = model.data.value;
        final list = failed ? const <BookingHistoryData>[] : _currentBookings();

        final String subtitle;
        if (failed) {
          subtitle = 'Payment attempts that need attention';
        } else {
          final bool pageLoading = data.maybeWhen(
            loading: (_) => true,
            orElse: () => false,
          );
          final bool error = data.maybeWhen(
            error: (_) => true,
            orElse: () => false,
          );
          if (pageLoading) {
            subtitle = 'Loading your bookings…';
          } else if (error) {
            subtitle = "Couldn't load bookings";
          } else if (_filters.hasAny) {
            subtitle =
                'Showing ${_applyFiltersList(list, _filters).length} of ${list.length} bookings';
          } else if (!model.isPaginationCompleted) {
            subtitle = 'Syncing your bookings…';
          } else if (list.isEmpty) {
            subtitle = 'All your treks in one place';
          } else {
            final int liveCount = list.where(_isOngoing).length;
            final int upcomingCount = list.where(_isUpcoming).length;
            if (liveCount > 0) {
              subtitle =
                  '$liveCount trek${liveCount == 1 ? '' : 's'} live · ${list.length} booking${list.length == 1 ? '' : 's'}';
            } else if (upcomingCount > 0) {
              subtitle =
                  '${list.length} booking${list.length == 1 ? '' : 's'} · $upcomingCount upcoming';
            } else {
              subtitle = '${list.length} booking${list.length == 1 ? '' : 's'}';
            }
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bookings',
              textScaler: const TextScaler.linear(1),
              style: AppType.style(
                FontSize.s18,
                w: FontWeight.w800,
                color: _Bk.ink,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 0.1.h),
            Text(
              subtitle,
              textScaler: const TextScaler.linear(1),
              style: AppType.style(FontSize.s9, color: _Bk.inkFaint),
            ),
          ],
        );
      }),
      actions: [
        Obx(() {
          final failed = _dashboardC.selectedFilter.value == 'Failed Payments';
          if (failed) {
            return IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: _exitFailedMode,
            );
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterButton(),
              // Explicitly styled so the menu never inherits a broken theme:
              // white surface, ink text, drops UNDER the icon.
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: _Bk.ink),
                color: Colors.white,
                elevation: 8,
                position: PopupMenuPosition.under,
                offset: const Offset(0, 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.w),
                  side: const BorderSide(color: _Bk.hairline),
                ),
                onSelected: (v) {
                  if (v == 'failed') _enterFailedMode();
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'failed',
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      children: [
                        Icon(
                          Icons.credit_card_off_rounded,
                          size: 4.4.w,
                          color: _Bk.warning,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          'Failed payments',
                          style: AppType.style(
                            FontSize.s11,
                            w: FontWeight.w600,
                            color: _Bk.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ],
      bottom: _SyncProgressBar(
        child: Obx(() {
          if (_dashboardC.selectedFilter.value == 'Failed Payments') {
            if (!_dashboardC.isLoadingFailedAttempts.value) {
              return const SizedBox.shrink();
            }
            return const LinearProgressIndicator(
              minHeight: 3,
              color: _Bk.ink,
              backgroundColor: _Bk.hairline,
            );
          }
          final model = _dashboardC.bookingHistoryObserver.value;
          final bool pageLoading = model.data.value.maybeWhen(
            loading: (_) => true,
            orElse: () => false,
          );
          final bool error = model.data.value.maybeWhen(
            error: (_) => true,
            orElse: () => false,
          );
          final bool syncing =
              !pageLoading && !error && !model.isPaginationCompleted;
          if (!syncing) return const SizedBox.shrink();
          return const LinearProgressIndicator(
            minHeight: 3,
            color: _Bk.ink,
            backgroundColor: _Bk.hairline,
          );
        }),
      ),
    );
  }

  Widget _buildFilterButton() {
    final int active = _filters.activeCount;
    return IconButton(
      onPressed: _showFilterSheet,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.tune_rounded, color: _Bk.ink),
          if (active > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(3),
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                decoration: const BoxDecoration(
                  color: _Bk.brand,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$active',
                    textScaler: const TextScaler.linear(1),
                    style: AppType.style(
                      FontSize.s8,
                      w: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── SCROLL BODY ──────────────────────────────────────────────────────────
  Widget _scrollBody(List<Widget> slivers) {
    return RefreshIndicator(
      color: _Bk.ink,
      strokeWidth: 2.2,
      onRefresh: _onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: CustomScrollView(
          controller: _scrollC,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ...slivers,
            SliverPadding(padding: EdgeInsets.only(bottom: 12.h)),
          ],
        ),
      ),
    );
  }

  bool _onScrollNotification(ScrollNotification n) {
    if (n is ScrollUpdateNotification || n is ScrollEndNotification) {
      final bool want = n.metrics.pixels > 1000;
      if (want != _showBackToTop) setState(() => _showBackToTop = want);
    }
    return false;
  }

  Widget _buildBackToTop() {
    return IgnorePointer(
      ignoring: !_showBackToTop,
      child: AnimatedScale(
        scale: _showBackToTop ? 1 : 0.6,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _showBackToTop ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: () => _scrollC.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
            ),
            child: Container(
              width: 11.w,
              height: 11.w,
              decoration: BoxDecoration(
                color: _Bk.ink,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _Bk.ink.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                size: 5.w,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── CONTENT ──────────────────────────────────────────────────────────────
  // Every trek is featured at most once: the just-booked trek is headlined
  // by the banner (which jumps to its full card), so the hero never repeats
  // it; live treks get the hero/carousel; everything else lives in the list.
  List<Widget> _contentSlivers({
    required List<BookingHistoryData> all,
    required List<BookingHistoryData> filtered,
    required bool syncing,
  }) {
    final slivers = <Widget>[];
    slivers.add(SliverToBoxAdapter(child: SizedBox(height: 1.2.h)));

    final ongoing = all.where(_isOngoing).toList()..sort(_compareStartAsc);
    final upcoming = all.where(_isUpcoming).toList()..sort(_compareStartAsc);

    _recentBooking = _justBookedBooking(all);

    // ── JUST BOOKED banner (≤ 2 days old, points into the Upcoming tab) ──
    if (_recentBooking != null) {
      slivers.add(
        SliverToBoxAdapter(child: _buildJustBookedBanner(_recentBooking!)),
      );
    }

    // ── LIVE: 1 trek → full-width hero · 2+ → horizontal carousel ──
    if (ongoing.length == 1) {
      slivers.add(
        SliverToBoxAdapter(child: _buildTicketHero(ongoing.first, live: true)),
      );
    } else if (ongoing.length > 1) {
      slivers.add(SliverToBoxAdapter(child: _buildLiveHeader(ongoing.length)));
      slivers.add(SliverToBoxAdapter(child: _buildLiveCarousel(ongoing)));
    } else if (upcoming.isNotEmpty) {
      // The just-booked trek is already headlined by the banner above and
      // lives as a full card in the Upcoming tab — never feature it twice.
      final bool heroIsRecent =
          _recentBooking != null &&
          upcoming.first.id != null &&
          upcoming.first.id == _recentBooking!.id;
      if (!heroIsRecent) {
        slivers.add(
          SliverToBoxAdapter(
            child: _buildTicketHero(upcoming.first, live: false),
          ),
        );
      }
    }

    if (_filters.hasAny) {
      // ══ RESULTS MODE: flat list, no tab division ══
      slivers.add(
        SliverToBoxAdapter(
          child: _buildResultsHeader(filtered.length, all.length),
        ),
      );
      slivers.add(SliverToBoxAdapter(child: _buildFilterPillsRow()));
      if (filtered.isEmpty) {
        slivers.add(
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildNoMatchState(),
          ),
        );
      } else {
        _addTimeline(slivers, filtered, syncing);
      }
    } else {
      // ══ BROWSE MODE: tabs + timeline ══
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 1.h),
            child: _SegmentedControl(
              labels: const ['Upcoming', 'Past', 'All'],
              index: _segment,
              onChanged: _onSegmentChanged,
            ),
          ),
        ),
      );

      if (ongoing.isEmpty && upcoming.isEmpty) {
        slivers.add(SliverToBoxAdapter(child: _buildNoActiveNotice()));
      }

      if (filtered.isEmpty) {
        slivers.add(
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildSegmentEmptyState(),
          ),
        );
      } else {
        _addTimeline(slivers, filtered, syncing);
      }
    }

    return slivers;
  }

  void _addTimeline(
    List<Widget> slivers,
    List<BookingHistoryData> items,
    bool syncing,
  ) {
    int i = 0;
    for (final group in _groupByMonth(items)) {
      slivers.add(
        SliverToBoxAdapter(
          child: _buildMonthLabel(group.label, group.items.length),
        ),
      );
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate((context, idx) {
            final b = group.items[idx];
            final n = i++;
            return KeyedSubtree(
              key: ValueKey('t-${b.id ?? 'i$n'}'),
              child: _buildBookingCard(b, n),
            );
          }, childCount: group.items.length),
        ),
      );
    }

    if (syncing) {
      slivers.add(SliverToBoxAdapter(child: _buildSyncRow()));
    } else if (items.length > 8) {
      slivers.add(SliverToBoxAdapter(child: _buildEndMarker()));
    }
  }

  // ── LIVE SECTION HEADER (when 2+ treks are happening) ───────────────────
  Widget _buildLiveHeader(int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.w, 1.6.h, 5.w, 1.h),
      child: Row(
        children: [
          const _LivePulse(color: _Bk.ongoing),
          SizedBox(width: 2.2.w),
          Text(
            'Live now',
            style: AppType.style(
              FontSize.s13,
              w: FontWeight.w800,
              color: _Bk.ink,
            ),
          ),
          SizedBox(width: 1.8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 1.8.w, vertical: 0.25.h),
            decoration: BoxDecoration(
              color: _Bk.ongoing.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '$count trek${count == 1 ? '' : 's'}',
              textScaler: const TextScaler.linear(1),
              style: AppType.style(
                FontSize.s8,
                w: FontWeight.w800,
                color: _Bk.ongoing,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Horizontal, swipeable row of FULL live tickets — every live trek on one
  /// screen row instead of stacking N tall cards vertically.
  Widget _buildLiveCarousel(List<BookingHistoryData> live) {
    // Clamped so the ticket's fixed-px parts (stub, logo, strip) always fit.
    final double cardH = math.max(240.0, math.min(34.h, 330.0));
    return SizedBox(
      height: cardH,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: live.length,
        separatorBuilder: (_, __) => SizedBox(width: 3.w),
        itemBuilder: (context, i) =>
            _buildTicketHero(live[i], live: true, height: cardH),
      ),
    );
  }

  // ── HERO TICKET (CommonBookedCard design language) ──────────────────────
  Widget _buildTicketHero(
    BookingHistoryData b, {
    required bool live,
    double? height,
  }) {
    final double cornerRadius = 4.5.w;
    // PhysicalShape's clip can silently fail to re-apply across rebuilds
    // (this screen rebuilds via Obx constantly), which left the gradient
    // band with square top corners. The inner ClipPath guarantees the
    // ticket silhouette is always clipped.
    final Widget ticket = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: b.id == null
          ? null
          : () => Get.to(() => BookingsUpcomingScreen(bookingId: b.id)),
      child: PhysicalShape(
        clipper: _TicketClipper(
          cornerRadius: cornerRadius,
          notchRadius: 9,
          notchFromBottom: 50,
        ),
        color: Colors.white,
        elevation: 5,
        shadowColor: AppColors.inkStrong.withValues(alpha: 0.22),
        child: ClipPath(
          clipper: _TicketClipper(
            cornerRadius: cornerRadius,
            notchRadius: 9,
            notchFromBottom: 50,
          ),
          child: CustomPaint(
            foregroundPainter: _TicketBorderPainter(
              cornerRadius: cornerRadius,
              notchRadius: 9,
              notchFromBottom: 50,
              color: _Bk.hairline,
            ),
            child: height == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _heroBand(b, live),
                      _heroContent(b, live: live),
                      _heroStub(b, live: live),
                    ],
                  )
                : SizedBox(
                    width: 84.w,
                    height: height,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _heroBand(b, live),
                        Expanded(child: _heroContent(b, live: live)),
                        _heroStub(b, live: live),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
    if (height != null) return ticket;
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0.2.h, 4.w, 0),
      child: ticket,
    );
  }

  Widget _heroBand(BookingHistoryData b, bool live) {
    if (live) {
      // The only text banner in the app: one line on the live band.
      final String message = _liveMessageFor(b);
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 4.2.w, vertical: 0.9.h),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF0891B2), Color(0xFF0E7490)],
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                const _LivePulse(color: Colors.white),
                SizedBox(width: 1.6.w),
                Text(
                  'LIVE',
                  textScaler: const TextScaler.linear(1),
                  style: AppType.style(
                    FontSize.s8,
                    w: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(width: 2.4.w),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaler: const TextScaler.linear(1),
                    style: AppType.style(
                      FontSize.s9,
                      w: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ],
            ),
            const Positioned.fill(child: _SheenSweep()),
          ],
        ),
      );
    }

    final DateTime? start = _startOf(b);
    String pill = 'COMING UP';
    if (start != null) {
      final c = _countdownShort(start).toUpperCase();
      pill = c == 'TODAY' ? 'STARTS TODAY' : c;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.2.w, vertical: 1.1.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_rounded,
            size: 4.w,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          SizedBox(width: 2.w),
          Text(
            'NEXT ADVENTURE',
            textScaler: const TextScaler.linear(1),
            style: AppType.style(
              FontSize.s8,
              w: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: 0.4.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              pill,
              textScaler: const TextScaler.linear(1),
              style: AppType.style(
                FontSize.s8,
                w: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroContent(BookingHistoryData b, {required bool live}) {
    final Color statusColor = live ? _Bk.ongoing : _Bk.upcoming;
    final String statusLabel = live ? 'Ongoing' : 'Upcoming';
    final String title = b.trek?.title ?? 'Trek booking';
    final String destination = _destinationOf(b);
    final String difficulty = b.trek?.difficulty ?? '';
    final String vendorName = b.trek?.vendor?.businessName ?? 'Unknown Vendor';
    final String vendorLogo = b.trek?.vendor?.businessLogo ?? '';
    final double logoSize = 9.5.w;

    final String startDateStr = _formatDate(b.batch?.startDate);
    final String startTimeStr = b.batch?.startTime ?? '';
    final String startDateTime = startTimeStr.isNotEmpty
        ? '$startDateStr · $startTimeStr'
        : startDateStr;
    final String durationStr = _durationLabel(b);

    return Padding(
      padding: EdgeInsets.fromLTRB(4.2.w, 1.2.h, 4.2.w, 0.8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(2.6.w),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: vendorLogo.isNotEmpty
                    ? CustomNetworkImage(
                        accessToken: Repository.token,
                        imageUrl: vendorLogo,
                        width: logoSize,
                        height: logoSize,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Text(
                          _initials(vendorName),
                          style: AppType.style(
                            FontSize.s10,
                            w: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              SizedBox(width: 2.8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORGANISED BY',
                      textScaler: const TextScaler.linear(1),
                      style: AppType.style(
                        FontSize.s7,
                        w: FontWeight.w600,
                        color: _Bk.inkFaint,
                        height: 1,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 0.25.h),
                    Text(
                      vendorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.style(
                        FontSize.s10,
                        w: FontWeight.w600,
                        color: _Bk.ink,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              _badge(statusLabel, statusColor, filled: true),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaler: const TextScaler.linear(1),
            style: AppType.style(
              FontSize.s13,
              w: FontWeight.w800,
              color: _Bk.ink,
              height: 1.15,
              letterSpacing: -0.2,
            ),
          ),
          if (destination.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 0.35.h),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 3.1.w,
                    color: _Bk.brand,
                  ),
                  SizedBox(width: 0.9.w),
                  Expanded(
                    child: Text(
                      destination,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.style(
                        FontSize.s9,
                        color: _Bk.inkMid,
                        height: 1.25,
                      ),
                    ),
                  ),
                  if (difficulty.isNotEmpty && difficulty != '-')
                    _badge(difficulty, _Bk.brand, small: true),
                ],
              ),
            ),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 0.85.h, horizontal: 2.4.w),
            decoration: BoxDecoration(
              color: _Bk.divider.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.7.w),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _endpoint('Starts', startDateTime, CrossAxisAlignment.start),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.5.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.terrain_rounded,
                          size: 4.4.w,
                          color: statusColor.withValues(alpha: 0.6),
                        ),
                        SizedBox(
                          height: 7,
                          child: CustomPaint(
                            size: const Size(double.infinity, 7),
                            painter: _DottedTrailPainter(
                              color: statusColor.withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _endpoint('Duration', durationStr, CrossAxisAlignment.end),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStub(BookingHistoryData b, {required bool live}) {
    final Color statusColor = live ? _Bk.ongoing : _Bk.upcoming;
    final String bookingId = _bookingIdOf(b);
    final String booked = _formatDate(b.bookingDate);
    return SizedBox(
      height: 50,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: CustomPaint(
              size: const Size(double.infinity, 1),
              painter: _DashedLinePainter(color: _Bk.divider),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.2.w),
              child: Row(
                children: [
                  _RouteFlowBadge(color: statusColor, size: const Size(56, 24)),
                  SizedBox(width: 2.2.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          bookingId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaler: const TextScaler.linear(1),
                          style: AppType.style(
                            FontSize.s10,
                            w: FontWeight.w700,
                            color: _Bk.ink,
                            height: 1.2,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          booked.isEmpty ? 'Booking' : 'Booked $booked',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaler: const TextScaler.linear(1),
                          style: AppType.style(
                            FontSize.s8,
                            color: _Bk.inkFaint,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View trip',
                        style: AppType.style(
                          FontSize.s9,
                          w: FontWeight.w600,
                          color: _Bk.brand,
                        ),
                      ),
                      SizedBox(width: 0.8.w),
                      Container(
                        padding: EdgeInsets.all(0.9.w),
                        decoration: const BoxDecoration(
                          color: _Bk.brandSoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 3.2.w,
                          color: _Bk.brand,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── JUST BOOKED BANNER ───────────────────────────────────────────────────
  Widget _buildJustBookedBanner(BookingHistoryData b) {
    final String title = b.trek?.title ?? 'Your new trek';
    final DateTime? start = _startOf(b);
    final String sub = start != null
        ? 'Starts ${_startDisplay(start)} · ${_countdownShort(start)}'
        : 'Get ready for your adventure';

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0.2.h, 4.w, 1.h),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _jumpToBooking,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
            ),
            borderRadius: BorderRadius.circular(3.6.w),
            boxShadow: [
              BoxShadow(
                color: _Bk.brand.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3.6.w),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    children: [
                      Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.celebration_rounded,
                          size: 5.w,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BOOKED JUST NOW',
                              textScaler: const TextScaler.linear(1),
                              style: AppType.style(
                                FontSize.s8,
                                w: FontWeight.w800,
                                color: Colors.white.withValues(alpha: 0.85),
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 0.3.h),
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textScaler: const TextScaler.linear(1),
                              style: AppType.style(
                                FontSize.s11,
                                w: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 0.3.h),
                            Text(
                              sub,
                              textScaler: const TextScaler.linear(1),
                              style: AppType.style(
                                FontSize.s8,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'View',
                          textScaler: const TextScaler.linear(1),
                          style: AppType.style(
                            FontSize.s9,
                            w: FontWeight.w800,
                            color: _Bk.brand,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned.fill(child: _SheenSweep()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── SHARED TICKET PRIMITIVES ─────────────────────────────────────────────
  Widget _badge(
    String text,
    Color color, {
    bool filled = false,
    bool small = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 1.8.w : 2.2.w,
        vertical: small ? 0.3.h : 0.4.h,
      ),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
        border: filled
            ? null
            : Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text.toUpperCase(),
        textScaler: const TextScaler.linear(1),
        style: AppType.style(
          FontSize.s8,
          w: FontWeight.w700,
          color: filled ? Colors.white : color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _endpoint(String label, String value, CrossAxisAlignment align) {
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          textScaler: const TextScaler.linear(1),
          style: AppType.style(
            FontSize.s7,
            w: FontWeight.w600,
            color: _Bk.inkFaint,
            height: 1,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 0.3.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textScaler: const TextScaler.linear(1),
          style: AppType.style(
            FontSize.s11,
            w: FontWeight.w700,
            color: _Bk.ink,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  // ── RESULTS MODE (filters active) ────────────────────────────────────────
  Widget _buildResultsHeader(int shown, int total) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.w, 1.4.h, 5.w, 0.8.h),
      child: Row(
        children: [
          Text(
            '$shown of $total bookings',
            style: AppType.style(
              FontSize.s11,
              w: FontWeight.w800,
              color: _Bk.ink,
            ),
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _resetFilters,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.6.h),
              child: Text(
                'Clear all',
                textScaler: const TextScaler.linear(1),
                style: AppType.style(
                  FontSize.s10,
                  w: FontWeight.w700,
                  color: _Bk.brand,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPillsRow() {
    final pills = <Widget>[];

    if (_filters.range != null) {
      pills.add(
        _filterPill(
          '${_fmt(_filters.range!.start)} – ${_fmt(_filters.range!.end)}',
          () => setState(() => _filters.range = null),
        ),
      );
    }
    for (final d in _filters.destinations.toList()) {
      pills.add(
        _filterPill(d, () => setState(() => _filters.destinations.remove(d))),
      );
    }
    for (final s in _kStatusOptions) {
      if (_filters.statuses.contains(s.id)) {
        pills.add(
          _filterPill(
            s.label,
            () => setState(() => _filters.statuses.remove(s.id)),
            color: s.color,
          ),
        );
      }
    }
    pills.add(_addFilterPill());

    return SizedBox(
      height: 5.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: pills.length,
        separatorBuilder: (_, __) => SizedBox(width: 1.8.w),
        itemBuilder: (context, i) => pills[i],
      ),
    );
  }

  Widget _filterPill(String label, VoidCallback onRemove, {Color? color}) {
    final Color accent = color ?? _Bk.brand;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _showFilterSheet, // tap the pill body → edit filters
      child: Container(
        padding: EdgeInsets.only(left: 3.2.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 1.8.w,
                height: 1.8.w,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 1.6.w),
            ],
            Flexible(
              child: Text(
                label,
                textScaler: const TextScaler.linear(1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.style(
                  FontSize.s9,
                  w: FontWeight.w700,
                  color: accent,
                ),
              ),
            ),
            SizedBox(width: 1.2.w),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                onRemove();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.6.w,
                  vertical: 1.35.h,
                ),
                child: Icon(Icons.close_rounded, size: 3.6.w, color: accent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addFilterPill() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _showFilterSheet,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.2.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _Bk.ink,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, size: 3.6.w, color: Colors.white),
            SizedBox(width: 1.4.w),
            Text(
              'Filters',
              textScaler: const TextScaler.linear(1),
              style: AppType.style(
                FontSize.s9,
                w: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TIMELINE ─────────────────────────────────────────────────────────────
  Widget _buildMonthLabel(String label, int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.w, 1.6.h, 5.w, 0.9.h),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            textScaler: const TextScaler.linear(1),
            style: AppType.style(
              FontSize.s9,
              w: FontWeight.w800,
              color: _Bk.inkMid,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(width: 1.6.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 1.7.w, vertical: 0.2.h),
            decoration: BoxDecoration(
              color: _Bk.divider.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '$count',
              textScaler: const TextScaler.linear(1),
              style: AppType.style(
                FontSize.s8,
                w: FontWeight.w700,
                color: _Bk.inkFaint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoActiveNotice() {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 1.2.h),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: _Bk.bg,
          borderRadius: BorderRadius.circular(3.6.w),
          border: Border.all(color: _Bk.hairline),
        ),
        child: Row(
          children: [
            Container(
              width: 9.w,
              height: 9.w,
              decoration: BoxDecoration(
                color: _Bk.warning.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 4.2.w,
                color: _Bk.warning,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No active treks right now',
                    style: AppType.style(
                      FontSize.s11,
                      w: FontWeight.w700,
                      color: _Bk.ink,
                    ),
                  ),
                  SizedBox(height: 0.2.h),
                  Text(
                    'Your past adventures are below — or plan a new one.',
                    style: AppType.style(
                      FontSize.s9,
                      color: _Bk.inkMid,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _goBack,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: _Bk.ink,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Book now',
                  textScaler: const TextScaler.linear(1),
                  style: AppType.style(
                    FontSize.s8,
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

  Widget _buildSyncRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(color: _Bk.ink, strokeWidth: 2),
          ),
          SizedBox(width: 2.5.w),
          Text(
            'Syncing the rest of your bookings…',
            style: AppType.style(FontSize.s9, color: _Bk.inkFaint),
          ),
        ],
      ),
    );
  }

  Widget _buildEndMarker() {
    return Padding(
      padding: EdgeInsets.only(top: 2.5.h, bottom: 1.h),
      child: Center(
        child: Text(
          "That's all your bookings",
          textAlign: TextAlign.center,
          style: AppType.style(FontSize.s9, color: _Bk.inkFaint),
        ),
      ),
    );
  }

  // ── BOOKING CARD (timeline — CommonBookedCard + spotlight on just-booked)
  Widget _commonCard(BookingHistoryData booking) {
    return CommonBookedCard(
      booking: booking,
      onViewDetailsTap: booking.id == null
          ? null
          : () => Get.to(() => BookingsUpcomingScreen(bookingId: booking.id)),
      onRateTrekTap: booking.id == null
          ? null
          : () => Get.to(
              () => BookingsUpcomingScreen(
                bookingId: booking.id,
                autoOpenRating: true,
              ),
            ),
    );
  }

  Widget _buildBookingCard(BookingHistoryData? booking, int index) {
    final bool spotlight =
        booking != null &&
        _recentBooking != null &&
        booking.id != null &&
        booking.id == _recentBooking!.id;

    final Widget body = Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: booking == null
          ? const SizedBox.shrink()
          : (spotlight
                ? KeyedSubtree(
                    key: _spotlightKey,
                    child: _Spotlight(
                      color: _Bk.brand,
                      child: _commonCard(booking),
                    ),
                  )
                : _commonCard(booking)),
    );

    if (index >= 6) return body;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + (index > 5 ? 5 : index) * 50),
      curve: Curves.easeOutCubic,
      builder: (ctx, value, ch) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: ch,
        ),
      ),
      child: body,
    );
  }

  // ── FAILED PAYMENTS ───────────────────────────────────────────────────────
  Widget _failedView() {
    if (_dashboardC.isLoadingFailedAttempts.value) {
      return _scrollBody([
        SliverToBoxAdapter(child: SizedBox(height: 1.4.h)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => _buildShimmerCard(),
            childCount: 4,
          ),
        ),
      ]);
    }

    final attempts = _dashboardC.failedBookingAttempts;
    if (attempts.isEmpty) {
      return _scrollBody([
        SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState()),
      ]);
    }

    return _scrollBody([
      SliverToBoxAdapter(child: SizedBox(height: 1.4.h)),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 1.2.h),
          child: Row(
            children: [
              Icon(
                Icons.credit_card_off_rounded,
                size: 4.2.w,
                color: _Bk.warning,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  "${attempts.length} payment${attempts.length == 1 ? '' : 's'} didn't go through",
                  style: AppType.style(
                    FontSize.s10,
                    w: FontWeight.w700,
                    color: _Bk.inkMid,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => _buildFailedCard(attempts[i], i),
          childCount: attempts.length,
        ),
      ),
    ]);
  }

  Widget _buildFailedCard(Map<String, dynamic> attempt, int index) {
    final trek = attempt['trek'] as Map<String, dynamic>?;
    final batch = attempt['batch'] as Map<String, dynamic>?;
    final trekTitle = trek?['title'] as String? ?? 'Trek booking';
    final amount = attempt['amount'];
    final createdAt = attempt['created_at'] as String?;
    final startDate = batch?['start_date'] as String?;
    final failureDescription =
        attempt['failure_description'] as String? ??
        'Payment did not go through';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index > 8 ? 8 : index) * 45),
      curve: Curves.easeOutCubic,
      builder: (ctx, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
        padding: EdgeInsets.all(4.5.w),
        decoration: BoxDecoration(
          color: _Bk.bg,
          borderRadius: BorderRadius.circular(3.8.w),
          border: Border.all(color: _Bk.hairline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 0.55.h),
                  child: Container(
                    width: 2.2.w,
                    height: 2.2.w,
                    decoration: BoxDecoration(
                      color: _Bk.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(width: 2.6.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trekTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppType.style(
                          FontSize.s13,
                          w: FontWeight.w700,
                          color: _Bk.ink,
                        ),
                      ),
                      if (startDate != null) ...[
                        SizedBox(height: 0.3.h),
                        Text(
                          'Departure · ${_formatDate(startDate)}',
                          style: AppType.style(FontSize.s9, color: _Bk.inkMid),
                        ),
                      ],
                    ],
                  ),
                ),
                if (createdAt != null)
                  Text(
                    _formatDate(createdAt),
                    style: AppType.style(FontSize.s8, color: _Bk.inkFaint),
                  ),
              ],
            ),
            SizedBox(height: 1.5.h),
            Container(height: 1, color: _Bk.hairline),
            SizedBox(height: 1.2.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    failureDescription,
                    style: AppType.style(
                      FontSize.s9,
                      color: _Bk.inkMid,
                      height: 1.45,
                    ),
                  ),
                ),
                if (amount != null) ...[
                  SizedBox(width: 2.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.2.w,
                      vertical: 0.4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _Bk.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Text(
                      '₹$amount',
                      textScaler: const TextScaler.linear(1),
                      style: AppType.style(
                        FontSize.s9,
                        w: FontWeight.w700,
                        color: _Bk.warning,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── STATES ────────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    final bool failed = _dashboardC.selectedFilter.value == 'Failed Payments';
    final IconData icon = failed
        ? Icons.credit_card_off_rounded
        : Icons.terrain_rounded;
    final Color tint = failed
        ? _Bk.warning.withValues(alpha: 0.12)
        : _Bk.completed.withValues(alpha: 0.12);
    final Color fg = failed ? _Bk.warning : _Bk.completed;
    final String title = failed ? 'No failed payments' : 'No treks booked yet';
    final String subtitle = failed
        ? 'All your payments have gone through smoothly.'
        : 'Your live treks, upcoming adventures and booking history will live here.';

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
              child: Icon(icon, size: 9.w, color: fg),
            ),
            SizedBox(height: 2.4.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppType.style(
                FontSize.s14,
                w: FontWeight.w700,
                color: _Bk.ink,
              ),
            ),
            SizedBox(height: 0.7.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppType.style(
                FontSize.s10,
                color: _Bk.inkMid,
                height: 1.5,
              ),
            ),
            SizedBox(height: 2.8.h),
            if (!failed) _buildPrimaryCta('Book a new trek', _goBack),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: _Bk.cancelled.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 8.5.w,
                color: _Bk.cancelled,
              ),
            ),
            SizedBox(height: 2.2.h),
            Text(
              "Couldn't load your bookings",
              textAlign: TextAlign.center,
              style: AppType.style(
                FontSize.s14,
                w: FontWeight.w700,
                color: _Bk.ink,
              ),
            ),
            SizedBox(height: 0.6.h),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: AppType.style(
                FontSize.s10,
                color: _Bk.inkMid,
                height: 1.5,
              ),
            ),
            SizedBox(height: 2.4.h),
            _buildPrimaryCta(
              'Try again',
              () => _dashboardC.loadAllBookingHistory(
                force: true,
                waitForCompletion: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMatchState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: _Bk.brandSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.tune_rounded, size: 8.5.w, color: _Bk.brand),
            ),
            SizedBox(height: 2.2.h),
            Text(
              'No bookings match your filters',
              textAlign: TextAlign.center,
              style: AppType.style(
                FontSize.s14,
                w: FontWeight.w700,
                color: _Bk.ink,
              ),
            ),
            SizedBox(height: 0.6.h),
            Text(
              'Try widening the date range or clearing a filter.',
              textAlign: TextAlign.center,
              style: AppType.style(
                FontSize.s10,
                color: _Bk.inkMid,
                height: 1.5,
              ),
            ),
            SizedBox(height: 2.4.h),
            _buildPrimaryCta('Clear filters', _resetFilters),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentEmptyState() {
    String title;
    String subtitle;
    bool showCta = false;
    switch (_segment) {
      case 0:
        title = 'No upcoming treks yet';
        subtitle = 'When you book your next trek it will appear here.';
        showCta = true;
        break;
      case 1:
        title = 'No past bookings yet';
        subtitle = 'Your completed and cancelled treks will appear here.';
        break;
      default:
        title = 'No bookings';
        subtitle = 'Your bookings will appear here.';
        break;
    }
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: _Bk.brandSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 8.5.w,
                color: _Bk.brand,
              ),
            ),
            SizedBox(height: 2.2.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppType.style(
                FontSize.s14,
                w: FontWeight.w700,
                color: _Bk.ink,
              ),
            ),
            SizedBox(height: 0.6.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppType.style(
                FontSize.s10,
                color: _Bk.inkMid,
                height: 1.5,
              ),
            ),
            if (showCta) ...[
              SizedBox(height: 2.4.h),
              _buildPrimaryCta('Book a new trek', _goBack),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryCta(String label, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: _Bk.ink,
          borderRadius: BorderRadius.circular(2.8.w),
          boxShadow: [
            BoxShadow(
              color: _Bk.ink.withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          textScaler: const TextScaler.linear(1),
          style: AppType.style(
            FontSize.s10,
            w: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── SHIMMER ───────────────────────────────────────────────────────────────
  List<Widget> _shimmerSlivers() {
    return [
      SliverToBoxAdapter(child: SizedBox(height: 1.2.h)),
      SliverToBoxAdapter(child: _buildShimmerHero()),
      SliverToBoxAdapter(child: _buildShimmerBar()),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => _buildShimmerCard(),
          childCount: 3,
        ),
      ),
    ];
  }

  Widget _buildShimmerHero() {
    Widget block(double? w, double h, [double r = 6]) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: CommonColors.greyColorEBEBEB,
        borderRadius: BorderRadius.circular(r),
      ),
    ).withShimmerAi(loading: true);

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0.2.h, 4.w, 0),
      child: Container(
        height: 26.h,
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: _Bk.bg,
          borderRadius: BorderRadius.circular(4.5.w),
          border: Border.all(color: _Bk.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                block(18.w, 2.h, 100),
                const Spacer(),
                block(12.w, 1.6.h, 100),
              ],
            ),
            SizedBox(height: 2.4.h),
            block(55.w, 2.4.h, 8),
            SizedBox(height: 1.h),
            block(38.w, 1.4.h),
            const Spacer(),
            block(60.w, 5.h, 10),
            const Spacer(),
            block(26.w, 3.2.h, 100),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 1.h),
      child: Container(
        height: 5.4.h,
        decoration: BoxDecoration(
          color: CommonColors.greyColorEBEBEB,
          borderRadius: BorderRadius.circular(3.w),
        ),
      ).withShimmerAi(loading: true),
    );
  }

  Widget _buildShimmerCard() {
    Widget block(double? w, double h, [double r = 6]) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: CommonColors.greyColorEBEBEB,
        borderRadius: BorderRadius.circular(r),
      ),
    ).withShimmerAi(loading: true);

    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.4.h),
      padding: EdgeInsets.all(4.5.w),
      decoration: BoxDecoration(
        color: _Bk.bg,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: _Bk.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              block(9.w, 9.w, 14),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    block(16.w, 1.2.h, 100),
                    SizedBox(height: 0.6.h),
                    block(30.w, 1.6.h),
                  ],
                ),
              ),
              block(15.w, 2.2.h, 100),
            ],
          ),
          SizedBox(height: 2.h),
          block(55.w, 2.h),
          SizedBox(height: 0.8.h),
          block(32.w, 1.3.h),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            height: 7.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(3.w),
            ),
          ).withShimmerAi(loading: true),
          SizedBox(height: 2.2.h),
          Row(
            children: [
              block(13.w, 2.4.h, 100),
              SizedBox(width: 3.w),
              block(28.w, 1.3.h),
              const Spacer(),
              block(8.w, 1.8.h, 100),
            ],
          ),
        ],
      ),
    );
  }

  // ── FILTER SHEET — Status → Search by calendar → Destination ────────────
  void _showFilterSheet() {
    FirebaseCrashlytics.instance.log('Bookings: filter sheet opened');

    final draft = _filters.copy();
    final now = DateTime.now();
    bool showCalendar = false;
    DateTime calMonth = DateTime(now.year, now.month, 1);
    DateTime? rangeStart = draft.range?.start;
    DateTime? rangeEnd = draft.range?.end;
    if (rangeStart != null) {
      calMonth = DateTime(rangeStart.year, rangeStart.month, 1);
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final all = _currentBookings();
          final destinations = _destinationOptions(all);
          final int resultCount = _applyFiltersList(all, draft).length;

          final bool footerOk = showCalendar
              ? rangeStart != null
              : resultCount > 0;
          final String footerLabel;
          if (showCalendar) {
            footerLabel = rangeStart != null
                ? 'Set ${_fmt(rangeStart!)} – ${_fmt(rangeEnd ?? rangeStart!)}'
                : 'Pick a start date';
          } else {
            footerLabel = resultCount > 0
                ? 'Show $resultCount booking${resultCount == 1 ? '' : 's'}'
                : 'No matching bookings';
          }

          return Container(
            constraints: BoxConstraints(maxHeight: 86.h),
            decoration: BoxDecoration(
              color: _Bk.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 10.w,
                      height: 0.5.h,
                      margin: EdgeInsets.only(top: 1.4.h, bottom: 1.2.h),
                      decoration: BoxDecoration(
                        color: _Bk.hairline,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 0.6.h),
                    child: Row(
                      children: [
                        if (showCalendar)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () =>
                                setSheetState(() => showCalendar = false),
                            child: Padding(
                              padding: EdgeInsets.only(right: 2.w),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                size: 5.4.w,
                                color: _Bk.ink,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            showCalendar ? 'Pick dates' : 'Filter bookings',
                            style: AppType.style(
                              FontSize.s14,
                              w: FontWeight.w800,
                              color: _Bk.ink,
                            ),
                          ),
                        ),
                        if (!showCalendar && draft.hasAny)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setSheetState(() => draft.reset()),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.8.h,
                              ),
                              child: Text(
                                'Reset',
                                textScaler: const TextScaler.linear(1),
                                style: AppType.style(
                                  FontSize.s10,
                                  w: FontWeight.w800,
                                  color: _Bk.brand,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 1.2.h),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: showCalendar
                            ? SizedBox(
                                key: const ValueKey('cal'),
                                width: double.infinity,
                                child: _RangeCalendar(
                                  initialMonth: calMonth,
                                  initialStart: rangeStart,
                                  initialEnd: rangeEnd,
                                  onChanged: (r) => setSheetState(() {
                                    rangeStart = r?.start;
                                    rangeEnd = r?.end;
                                    if (rangeStart != null) {
                                      calMonth = DateTime(
                                        rangeStart!.year,
                                        rangeStart!.month,
                                        1,
                                      );
                                    }
                                  }),
                                ),
                              )
                            : SizedBox(
                                key: const ValueKey('filters'),
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1 ── STATUS
                                    _sheetSection('Status', [
                                      for (final s in _kStatusOptions)
                                        _FilterChip(
                                          label: s.label,
                                          color: s.color,
                                          selected: draft.statuses.contains(
                                            s.id,
                                          ),
                                          onTap: () => setSheetState(() {
                                            if (!draft.statuses.remove(s.id)) {
                                              draft.statuses.add(s.id);
                                            }
                                          }),
                                        ),
                                    ]),
                                    // 2 ── SEARCH BY CALENDAR
                                    _sheetSection('Search by calendar', [
                                      _FilterChip(
                                        label: draft.range != null
                                            ? '${_fmt(draft.range!.start)} – ${_fmt(draft.range!.end)}'
                                            : 'Pick dates',
                                        selected: draft.range != null,
                                        onTap: () => setSheetState(() {
                                          showCalendar = true;
                                          if (rangeStart != null) {
                                            calMonth = DateTime(
                                              rangeStart!.year,
                                              rangeStart!.month,
                                              1,
                                            );
                                          }
                                        }),
                                      ),
                                      if (draft.range != null)
                                        _FilterChip(
                                          label: 'Clear dates',
                                          selected: false,
                                          onTap: () => setSheetState(() {
                                            draft.range = null;
                                            rangeStart = null;
                                            rangeEnd = null;
                                          }),
                                        ),
                                    ]),
                                    // 3 ── DESTINATION
                                    if (destinations.isNotEmpty)
                                      _sheetSection('Destination', [
                                        for (final d in destinations)
                                          _FilterChip(
                                            label: d,
                                            selected: draft.destinations
                                                .contains(d),
                                            onTap: () => setSheetState(() {
                                              if (!draft.destinations.remove(
                                                d,
                                              )) {
                                                draft.destinations.add(d);
                                              }
                                            }),
                                          ),
                                      ]),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.w, 0.6.h, 5.w, 1.4.h),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        if (showCalendar) {
                          if (rangeStart != null) {
                            setSheetState(() {
                              draft.range = DateTimeRange(
                                start: rangeStart!,
                                end: rangeEnd ?? rangeStart!,
                              );
                              showCalendar = false;
                            });
                          }
                          return;
                        }
                        Navigator.pop(sheetContext);
                        setState(() {
                          _filters.range = draft.range;
                          _filters.destinations
                            ..clear()
                            ..addAll(draft.destinations);
                          _filters.statuses
                            ..clear()
                            ..addAll(draft.statuses);
                        });
                        FirebaseCrashlytics.instance.log(
                          'Bookings: ${_filters.activeCount} filter(s) applied',
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 1.6.h),
                        decoration: BoxDecoration(
                          color: footerOk ? _Bk.ink : _Bk.inkFaint,
                          borderRadius: BorderRadius.circular(2.8.w),
                          boxShadow: [
                            BoxShadow(
                              color: _Bk.ink.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            footerLabel,
                            textScaler: const TextScaler.linear(1),
                            style: AppType.style(
                              FontSize.s11,
                              w: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

  Widget _sheetSection(String title, List<Widget> chips) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.w, 1.2.h, 5.w, 0.4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            textScaler: const TextScaler.linear(1),
            style: AppType.style(
              FontSize.s9,
              w: FontWeight.w800,
              color: _Bk.inkFaint,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(spacing: 2.w, runSpacing: 1.2.h, children: chips),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CUSTOM RANGE CALENDAR (in-sheet, no dialog routes)
// ─────────────────────────────────────────────
class _RangeCalendar extends StatefulWidget {
  final DateTime initialMonth;
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final ValueChanged<DateTimeRange?> onChanged;

  const _RangeCalendar({
    required this.initialMonth,
    this.initialStart,
    this.initialEnd,
    required this.onChanged,
  });

  @override
  State<_RangeCalendar> createState() => _RangeCalendarState();
}

class _RangeCalendarState extends State<_RangeCalendar> {
  late DateTime _month = widget.initialMonth;
  late DateTime? _start = widget.initialStart;
  late DateTime? _end = widget.initialEnd;

  void _notify() {
    widget.onChanged(
      _start == null
          ? null
          : DateTimeRange(start: _start!, end: _end ?? _start!),
    );
  }

  void _pick(DateTime day) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_start == null || (_start != null && _end != null)) {
        _start = day;
        _end = null;
      } else if (day.isBefore(_start!)) {
        _start = day;
      } else {
        _end = day;
      }
    });
    _notify();
  }

  void _setQuick(DateTime a, DateTime b) {
    HapticFeedback.selectionClick();
    setState(() {
      _start = a.isBefore(b) ? a : b;
      _end = a.isBefore(b) ? b : a;
      _month = DateTime(_start!.year, _start!.month, 1);
    });
    _notify();
  }

  void _shiftMonth(int delta) {
    final m = DateTime(_month.year, _month.month + delta, 1);
    final now = DateTime.now();
    final min = DateTime(now.year - 5, 1, 1);
    final max = DateTime(now.year + 5, 12, 1);
    if (!m.isBefore(min) && !m.isAfter(max)) {
      setState(() => _month = m);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final int daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final int firstWeekday = DateTime(_month.year, _month.month, 1).weekday;
    final int blanks = firstWeekday - 1;
    final int itemCount = blanks + daysInMonth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _shiftMonth(-1),
                child: Padding(
                  padding: EdgeInsets.all(1.4.w),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 5.6.w,
                    color: _Bk.ink,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${_kMonthsFull[_month.month - 1]} ${_month.year}',
                    textScaler: const TextScaler.linear(1),
                    style: AppType.style(
                      FontSize.s11,
                      w: FontWeight.w800,
                      color: _Bk.ink,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _shiftMonth(1),
                child: Padding(
                  padding: EdgeInsets.all(1.4.w),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 5.6.w,
                    color: _Bk.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 0.8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.4.w),
          child: Row(
            children: [
              for (final d in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                Expanded(
                  child: Center(
                    child: Text(
                      d,
                      textScaler: const TextScaler.linear(1),
                      style: AppType.style(
                        FontSize.s8,
                        w: FontWeight.w700,
                        color: _Bk.inkFaint,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 0.5.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.4.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.05,
              mainAxisSpacing: 2,
            ),
            itemCount: itemCount,
            itemBuilder: (context, i) {
              if (i < blanks) return const SizedBox.shrink();
              final DateTime day = DateTime(
                _month.year,
                _month.month,
                i - blanks + 1,
              );
              final bool isStart = _start != null && _sameDay(day, _start!);
              final bool isEnd = _end != null && _sameDay(day, _end!);
              final bool isSel = isStart || isEnd;
              final bool inRange =
                  _start != null &&
                  _end != null &&
                  !day.isBefore(
                    DateTime(_start!.year, _start!.month, _start!.day),
                  ) &&
                  !day.isAfter(DateTime(_end!.year, _end!.month, _end!.day));
              final bool isToday = _sameDay(day, today);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _pick(day),
                child: Container(
                  margin: EdgeInsets.all(0.5.w),
                  decoration: BoxDecoration(
                    color: isSel
                        ? _Bk.brand
                        : inRange
                        ? _Bk.brand.withValues(alpha: 0.10)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: (!isSel && isToday)
                        ? Border.all(color: _Bk.brand, width: 1.2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      textScaler: const TextScaler.linear(1),
                      style: AppType.style(
                        FontSize.s10,
                        w: isSel || isToday || inRange
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: isSel
                            ? Colors.white
                            : inRange || isToday
                            ? _Bk.brand
                            : _Bk.inkMid,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 1.2.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: [
              _FilterChip(
                label: 'This month',
                selected: false,
                onTap: () => _setQuick(
                  DateTime(now.year, now.month, 1),
                  DateTime(now.year, now.month + 1, 0),
                ),
              ),
              _FilterChip(
                label: 'Next 3 months',
                selected: false,
                onTap: () => _setQuick(
                  DateTime(now.year, now.month, now.day),
                  DateTime(
                    now.year,
                    now.month,
                    now.day,
                  ).add(const Duration(days: 89)),
                ),
              ),
              _FilterChip(
                label: 'This year',
                selected: false,
                onTap: () => _setQuick(
                  DateTime(now.year, 1, 1),
                  DateTime(now.year, 12, 31),
                ),
              ),
              _FilterChip(
                label: 'Clear',
                selected: false,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _start = null;
                    _end = null;
                  });
                  _notify();
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  SEGMENTED CONTROL
// ─────────────────────────────────────────────
class _SegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  const _SegmentedControl({
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5.4.h,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _Bk.bg,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: _Bk.hairline),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double thumbW = (constraints.maxWidth - 6) / labels.length;
          final double x = labels.length <= 1
              ? 0.0
              : -1.0 + (2.0 * index / (labels.length - 1));
          return Stack(
            children: [
              AnimatedAlign(
                alignment: Alignment(x, 0),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                child: Container(
                  width: thumbW,
                  height: constraints.maxHeight,
                  decoration: BoxDecoration(
                    color: _Bk.ink,
                    borderRadius: BorderRadius.circular(2.4.w),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(i),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: AppType.style(
                              FontSize.s10,
                              w: i == index ? FontWeight.w800 : FontWeight.w600,
                              color: i == index ? Colors.white : _Bk.inkMid,
                            ),
                            child: Text(
                              labels[i],
                              textScaler: const TextScaler.linear(1),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FILTER CHIP
// ─────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = color ?? _Bk.brand;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 3.6.w, vertical: 1.05.h),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.1) : _Bk.bg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? accent.withValues(alpha: 0.45) : _Bk.hairline,
            width: selected ? 1.3 : 1,
          ),
        ),
        child: Text(
          label,
          textScaler: const TextScaler.linear(1),
          style: AppType.style(
            FontSize.s10,
            w: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? accent : _Bk.inkMid,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ANIMATIONS
// ─────────────────────────────────────────────

/// Pulsing dot for the LIVE badge.
class _LivePulse extends StatefulWidget {
  final Color color;
  const _LivePulse({required this.color});

  @override
  State<_LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<_LivePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final v = _c.value;
        return Transform.scale(
          scale: 0.75 + 0.35 * v,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.45 * (1 - v)),
                  blurRadius: 6 + 6 * v,
                  spreadRadius: 1 + 3 * v,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Subtle light sweep across the live hero band.
class _SheenSweep extends StatefulWidget {
  const _SheenSweep();

  @override
  State<_SheenSweep> createState() => _SheenSweepState();
}

class _SheenSweepState extends State<_SheenSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) =>
            CustomPaint(painter: _SheenPainter(_c.value), size: Size.infinite),
      ),
    );
  }
}

class _SheenPainter extends CustomPainter {
  final double t;
  _SheenPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    if (w <= 0 || size.height <= 0) return;
    final band = w * 0.22;
    final x = -band + (w + band * 2) * t;
    final rect = Rect.fromLTWH(x, 0, band, size.height);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0x00FFFFFF), Color(0x30FFFFFF), Color(0x00FFFFFF)],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_SheenPainter old) => old.t != t;
}

// ─────────────────────────────────────────────
//  TICKET PRIMITIVES (same geometry as CommonBookedCard)
// ─────────────────────────────────────────────
Path _buildTicketPath(
  Size size, {
  required double cornerRadius,
  required double notchRadius,
  required double notchFromBottom,
}) {
  final double notchY = size.height - notchFromBottom;
  final ticket = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(cornerRadius),
      ),
    );
  final notches = Path()
    ..addOval(Rect.fromCircle(center: Offset(0, notchY), radius: notchRadius))
    ..addOval(
      Rect.fromCircle(center: Offset(size.width, notchY), radius: notchRadius),
    );
  return Path.combine(PathOperation.difference, ticket, notches);
}

class _TicketClipper extends CustomClipper<Path> {
  final double cornerRadius;
  final double notchRadius;
  final double notchFromBottom;
  const _TicketClipper({
    required this.cornerRadius,
    required this.notchRadius,
    required this.notchFromBottom,
  });
  @override
  Path getClip(Size size) => _buildTicketPath(
    size,
    cornerRadius: cornerRadius,
    notchRadius: notchRadius,
    notchFromBottom: notchFromBottom,
  );
  @override
  bool shouldReclip(_TicketClipper old) =>
      old.cornerRadius != cornerRadius ||
      old.notchRadius != notchRadius ||
      old.notchFromBottom != notchFromBottom;
}

class _TicketBorderPainter extends CustomPainter {
  final double cornerRadius;
  final double notchRadius;
  final double notchFromBottom;
  final Color color;
  const _TicketBorderPainter({
    required this.cornerRadius,
    required this.notchRadius,
    required this.notchFromBottom,
    required this.color,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(
      _buildTicketPath(
        size,
        cornerRadius: cornerRadius,
        notchRadius: notchRadius,
        notchFromBottom: notchFromBottom,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_TicketBorderPainter old) =>
      old.cornerRadius != cornerRadius ||
      old.notchRadius != notchRadius ||
      old.notchFromBottom != notchFromBottom ||
      old.color != color;
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;
    const dash = 5.0, gap = 3.5;
    double x = 14;
    while (x < size.width - 14) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(math.min(x + dash, size.width - 14), 0),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

class _DottedTrailPainter extends CustomPainter {
  final Color color;
  const _DottedTrailPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const double r = 1.2, gap = 6;
    final double y = size.height / 2;
    for (double x = r; x <= size.width - r; x += gap) {
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_DottedTrailPainter old) => old.color != color;
}

/// Animated route-flow badge (same as the card's stub badge).
class _RouteFlowBadge extends StatefulWidget {
  final Color color;
  final Size size;
  const _RouteFlowBadge({required this.color, required this.size});

  @override
  State<_RouteFlowBadge> createState() => _RouteFlowBadgeState();
}

class _RouteFlowBadgeState extends State<_RouteFlowBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
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
      builder: (_, __) => CustomPaint(
        size: widget.size,
        painter: _RouteFlowPainter(t: _ctrl.value, color: widget.color),
      ),
    );
  }
}

class _RouteFlowPainter extends CustomPainter {
  final double t;
  final Color color;
  const _RouteFlowPainter({required this.t, required this.color});

  Path _buildRoute(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(3, h - 5)
      ..cubicTo(w * 0.28, h - 2, w * 0.18, h * 0.15, w * 0.48, h * 0.5)
      ..cubicTo(w * 0.72, h * 0.78, w * 0.78, 3, w - 7, 6);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final route = _buildRoute(size);
    final metrics = route.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final ui.PathMetric metric = metrics.first;
    final double length = metric.length;

    canvas.drawPath(
      route,
      Paint()
        ..color = color.withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    const double dash = 5.0;
    const double gap = 5.0;
    const double cycle = dash + gap;
    final double offset = t * cycle;
    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    for (double d = offset - cycle; d < length; d += cycle) {
      final double start = d.clamp(0.0, length);
      final double end = (d + dash).clamp(0.0, length);
      if (end <= start) continue;
      canvas.drawPath(metric.extractPath(start, end), dashPaint);
    }

    final Offset startPos = metric.getTangentForOffset(0)!.position;
    canvas.drawCircle(
      startPos,
      2.4,
      Paint()..color = color.withValues(alpha: 0.25),
    );
    canvas.drawCircle(startPos, 1.4, Paint()..color = color);

    final Offset endPos = metric.getTangentForOffset(length)!.position;
    final double pulse = 0.5 - 0.5 * math.cos(t * 2 * math.pi);
    canvas.drawCircle(
      endPos,
      3.0 + pulse * 3.0,
      Paint()
        ..color = color.withValues(alpha: 0.28 * (1 - pulse))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(endPos, 2.8, Paint()..color = color);
    canvas.drawCircle(endPos, 1.1, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_RouteFlowPainter old) => old.t != t || old.color != color;
}

// ─────────────────────────────────────────────
//  SPOTLIGHT — glowing ring on the just-booked card
// ─────────────────────────────────────────────
class _Spotlight extends StatefulWidget {
  final Widget child;
  final Color color;
  const _Spotlight({required this.child, required this.color});

  @override
  State<_Spotlight> createState() => _SpotlightState();
}

class _SpotlightState extends State<_Spotlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final double v = _c.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.w),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.7 * (1 - v)),
              width: 1.6,
            ),
            color: widget.color.withValues(alpha: 0.05 * (1 - v)),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────
//  SYNC PROGRESS BAR (app bar bottom)
// ─────────────────────────────────────────────
class _SyncProgressBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  const _SyncProgressBar({required this.child});

  @override
  Size get preferredSize => const Size.fromHeight(3);

  @override
  Widget build(BuildContext context) => SizedBox(height: 3, child: child);
}
