import 'package:arobo_app/controller/coupon_controller.dart';
import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/screens/bookings_history_screen.dart';
import 'package:arobo_app/screens/dashboard_widget.dart';
import 'package:arobo_app/screens/my_account_screen.dart';
import 'package:arobo_app/utils/common_bottom_nav.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardMain extends StatefulWidget {
  const DashboardMain({super.key});

  @override
  State<DashboardMain> createState() => _DashboardMainState();
}

class _DashboardMainState extends State<DashboardMain> {
  late final DashboardController _dashboardC;

  @override
  void initState() {
    super.initState();
    // permanent: true — these are app-session-wide singletons referenced via
    // Get.find() from dozens of screens (traveller info, payment, account,
    // booking flow). Without this, GetX's smart management can dispose them
    // (and, on UserController/TrekController, the TextEditingControllers and
    // in-flight order/payment state they hold) whenever it decides nothing
    // currently on-screen depends on them — a screen still holding a cached
    // reference then hits "used after being disposed" on next interaction.
    _dashboardC = Get.put(DashboardController(), permanent: true);
    final trekC = Get.put(TrekController(), permanent: true);
    Get.put(CouponController(), permanent: true);
    Get.put(UserController(), permanent: true);

    // Every path into the dashboard (fresh OTP login or a relaunch that
    // restores an existing session) passes through here — the one place
    // that's guaranteed to run before the user could possibly reopen Razorpay
    // checkout again. Fire-and-forget: see checkPendingOrderOnResume's own
    // doc comment for why this must not block startup.
    trekC.checkPendingOrderOnResume();
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
    return Scaffold(
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
    );
  }
}
