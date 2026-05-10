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
    _dashboardC = Get.put(DashboardController());
    Get.put(TrekController());
    Get.put(CouponController());
    Get.put(UserController());
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
