import 'package:arobo_app/controller/coupon_controller.dart';
import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/freezed_models/booking/booking_history_model.dart';
import 'package:arobo_app/screens/bookings_history_screen.dart';
import 'package:arobo_app/screens/dashboard_widget.dart';
import 'package:arobo_app/screens/my_account_screen.dart';
import 'package:arobo_app/utils/common_bottom_nav.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:arobo_app/widgets/rate_trek_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DashboardMain extends StatefulWidget {
  const DashboardMain({super.key});
  @override
  State<DashboardMain> createState() => _DashboardMainState();
}

class _DashboardMainState extends State<DashboardMain> {
  late final DashboardController _dashboardC;
  DateTime? _lastBackPressTime;
  @override
  void initState() {
    super.initState();
    _dashboardC = Get.put(DashboardController(), permanent: true);
    final trekC = Get.put(TrekController(), permanent: true);
    Get.put(CouponController(), permanent: true);
    Get.put(UserController(), permanent: true);
    trekC.checkPendingOrderOnResume();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowRateTrekPopup();
    });
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
    if (!mounted) return;

    try {
      // Fetch specifically 'completed' treks so we don't miss unrated ones
      // that might be pushed to page 2+ of the 'All Bookings' list.
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        body: Obx(() => _buildScreen(_dashboardC.selectedScreen.value)),
        bottomNavigationBar: Obx(
          () => CommonBottomNav(
            selectedIndex: _dashboardC.selectedScreen.value,
            selectedIconColor: CommonColors.appYellowColor,
            unselectedIconColor: Colors.black,
            onIndexChanged: (index) {
              _dashboardC.selectedScreen.value = index;
            },
          ),
        ),
      ),
    );
  }
}
