import 'dart:developer';
import 'package:arobo_app/app_update/app_update_banner.dart';
import 'package:arobo_app/controller/coupon_controller.dart';
import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/freezed_models/booking/booking_history_model.dart';
import 'package:arobo_app/giveaway/giveaway_config.dart';
import 'package:arobo_app/giveaway/referral_links.dart';
import 'package:arobo_app/legal/legal_update_sheet.dart';
import 'package:arobo_app/screens/bookings_history_screen.dart';
import 'package:arobo_app/screens/dashboard_widget.dart';
import 'package:arobo_app/screens/my_account_screen.dart';
import 'package:arobo_app/screens/traveller_information_screen.dart';
import 'package:arobo_app/services/booking_draft_service.dart';
import 'package:arobo_app/services/push_router.dart';
import 'package:arobo_app/share/trek_link.dart';
import 'package:arobo_app/share/trek_share.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/utils/common_bottom_nav.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:arobo_app/widgets/rate_trek_popup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class DashboardMain extends StatefulWidget {
  const DashboardMain({super.key});
  @override
  State<DashboardMain> createState() => _DashboardMainState();
}

class _DashboardMainState extends State<DashboardMain> {
  late final DashboardController _dashboardC;
  DateTime? _lastBackPressTime;

  // ── Tab content transition ────────────────────────────────────────────
  // Direction of the last tab change (+1 → moving right through the tabs,
  // -1 → moving left). The body's incoming screen slides in from that
  // side, matching the pill's travel direction; back-press therefore
  // slides content home the way it came.
  int _lastTab = 0;
  int _tabDirection = 1;
  Worker? _tabWorker;
  Worker? _giveawayLinkWorker;
  Worker? _trekLinkWorker;
  Worker? _pushTapWorker;
  Future<void>? _legalPrompt;

  // Out faster than in — the stagger that makes a crossfade read as
  // "buttery" instead of "blurry".
  static const Duration _kTabIn = Duration(milliseconds: 240);
  static const Duration _kTabOut = Duration(milliseconds: 150);

  @override
  void initState() {
    super.initState();
    _dashboardC = Get.put(DashboardController(), permanent: true);
    final trekC = Get.put(TrekController(), permanent: true);
    Get.put(CouponController(), permanent: true);
    final userC = Get.put(UserController(), permanent: true);

    _lastTab = _dashboardC.selectedScreen.value.clamp(0, 2);

    // Fires synchronously on every selectedScreen write, BEFORE the Obx
    // rebuilds — so the transition direction is always correct, including
    // back-press and any programmatic navigation.
    _tabWorker = ever<int>(_dashboardC.selectedScreen, (i) {
      if (i != _lastTab) {
        _tabDirection = i > _lastTab ? 1 : -1;
        _lastTab = i;
      }
    });

    // Everything network-bound is deferred to after the first frame so the
    // splash→dashboard reveal isn't competing with these calls.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      trekC.checkPendingOrderOnResume();
      // "We've updated our terms" — once per app run, silent on failure.
      // The rate popup waits for it so the two never stack.
      _legalPrompt = maybeShowLegalUpdatePrompt();
      _maybeShowRateTrekPopup();
      final resumed = await BookingDraftService.checkAndResume(trekC, userC);
      if (resumed && mounted) {
        Get.to(() => const TravellerInformationScreen());
        return;
      }
      _openGiveawayIfLinked();
      _openTrekIfLinked();
      _openPushIfTapped();
    });

    // A referral link tapped while signed in, with the app already open.
    _giveawayLinkWorker = ever<bool>(
      ReferralLinkCapture.instance.openGiveawayRequested,
      (requested) {
        if (requested) _openGiveawayIfLinked();
      },
    );

    // A trek link tapped while signed in, with the app already open.
    _trekLinkWorker = ever<TrekLink?>(
      ReferralLinkCapture.instance.openTrekRequested,
      (link) {
        if (link != null) _openTrekIfLinked();
      },
    );

    // A notification tapped with the app already open / in the background.
    _pushTapWorker = ever<Map<String, dynamic>?>(
      PendingPush.instance.tapped,
      (data) {
        if (data != null) _openPushIfTapped();
      },
    );
  }

  /// A notification tapped (app closed, in the background, or open): open
  /// the screen it is about, once (scan E1).
  void _openPushIfTapped() {
    if (!mounted || PendingPush.instance.tapped.value == null) return;
    final data = PendingPush.instance.take();
    if (data == null) return;
    final target = routeForPush(data, giveawayEnabled: GiveawayConfig.enabled);
    if (target == null || Get.currentRoute == target.route) return;
    Get.toNamed(target.route, arguments: target.arguments);
  }

  /// A shared trek link — tapped while signed in, or saved before sign-in
  /// (tapped link or Play install referrer): open that trek once.
  Future<void> _openTrekIfLinked() async {
    final requested = ReferralLinkCapture.instance.openTrekRequested;
    final link = requested.value ?? await PendingTrekLink.read();
    if (link == null || !mounted) return;
    requested.value = null;
    await PendingTrekLink.clear();
    await TrekLinkOpener.open(link);
  }

  /// A referral link opened the app while signed in: show the giveaway (the
  /// "invite friends" view for an existing user) once, then forget it.
  void _openGiveawayIfLinked() {
    final requested = ReferralLinkCapture.instance.openGiveawayRequested;
    if (!requested.value || !mounted) return;
    requested.value = false;
    if (GiveawayConfig.enabled && Get.currentRoute != '/giveaway') {
      Get.toNamed('/giveaway');
    }
  }

  @override
  void dispose() {
    _tabWorker?.dispose();
    _giveawayLinkWorker?.dispose();
    _trekLinkWorker?.dispose();
    _pushTapWorker?.dispose();
    RateTrekPopup.dismiss(); // clean up overlay on dispose
    super.dispose();
  }

  /// Unwraps the booking history from:
  /// Rx<PaginationModel<Rx<ApiResult<BookingHistoryModel>>>>
  /// down to a clean List<BookingHistoryData>.
  List<BookingHistoryData> _extractBookings() {
    final pagination = _dashboardC.bookingHistoryObserver.value;
    final rxApiResult = pagination.data;
    final apiResult = rxApiResult.value;
    return apiResult.maybeWhen(
      success: (m) => m?.data ?? <BookingHistoryData>[],
      orElse: () => <BookingHistoryData>[],
    );
  }

  /// On app open: if a recently completed trek is still unrated, show the
  /// animated rate popup (RateTrekPopup self-guards eligibility + repeat).
  Future<void> _maybeShowRateTrekPopup() async {
    // Let the dashboard paint and settle first — no jank on cold start.
    await Future.delayed(const Duration(milliseconds: 1200));
    // Never over the legal update sheet — wait until it's closed.
    await _legalPrompt;
    if (!mounted) return;

    try {
      final List<BookingHistoryData> bookings = await _dashboardC
          .fetchCompletedBookingsForPopup();

      if (bookings.isEmpty) return;
      // Only interrupt on the home tab.
      if (_dashboardC.selectedScreen.value != 0) return;
      if (!mounted) return;

      await RateTrekPopup.maybeShow(context, bookings);
    } catch (_) {
      // A rating nudge must never block or crash app start.
    }
  }

  void _handleBackPress() {
    if (_dashboardC.selectedScreen.value != 0) {
      _dashboardC.selectedScreen.value = 0;
      return;
    }
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      CustomSnackBar.show(context, message: 'Press back again to exit');
    } else {
      SystemNavigator.pop();
    }
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const Dashboard();
      case 1:
        return const BookingsScreen();
      case 2:
        return const MyAccountScreen();
      default:
        return const Dashboard();
    }
  }

  /// Directional fade+slide for the tab content. Incoming screen slides
  /// in from the pill's travel direction and fades up; outgoing fades out
  /// quickly with no slide (pure fade exits read cleaner than two things
  /// moving at once). Both are render-object-cheap transforms — no
  /// repaint of the screens' own content.
  Widget _tabTransition(Widget child, Animation<double> animation) {
    final isCurrent =
        child.key == ValueKey<int>(_dashboardC.selectedScreen.value);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    if (isCurrent) {
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0.055 * _tabDirection, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    }

    return FadeTransition(
      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(curved),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: AppColors.bgCool,
        extendBody: true,
        body: Obx(() {
          final idx = _dashboardC.selectedScreen.value;
          return Stack(
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: _kTabIn,
                  reverseDuration: _kTabOut,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOut,
                  transitionBuilder: _tabTransition,
                  child: KeyedSubtree(
                    key: ValueKey<int>(idx),
                    child: _buildScreen(idx),
                  ),
                ),
              ),
              // "A new version is available" / "Please update by …" — a
              // small closable card floating just above the bottom nav, on
              // the home tab only. Renders nothing when there's no news.
              // The Builder reads the body's MediaQuery, where (extendBody)
              // padding.bottom is the nav's full footprint.
              if (idx == 0)
                Positioned(
                  left: 4.w,
                  right: 4.w,
                  bottom: 0,
                  child: Builder(
                    builder: (bodyContext) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(bodyContext).padding.bottom + 1.h,
                      ),
                      child: const AppUpdateBanner(),
                    ),
                  ),
                ),
            ],
          );
        }),
        // The nav needs no Obx: CommonBottomNav subscribes to
        // selectedScreen itself (its worker drives the pill flight).
        bottomNavigationBar: CommonBottomNav(
          selectedIconColor: CommonColors.appYellowColor,
          unselectedIconColor: Colors.black,
          onIndexChanged: (index) {
            _dashboardC.selectedScreen.value = index;
          },
        ),
      ),
    );
  }
}
