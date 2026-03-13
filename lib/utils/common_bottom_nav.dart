import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/screens/bookings_history_screen.dart';
import 'package:arobo_app/screens/dashboard_widget.dart';
import 'package:arobo_app/screens/my_account_screen.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

// Static Bottom Navigation Widget for quick use

// Original customizable widget (keeping the existing implementation)
class CommonBottomNav extends StatefulWidget {
  final int selectedIndex;
  final Function(int)? onIndexChanged; // Optional callback for index changes
  final Color? selectedIconColor;
  final Color? unselectedIconColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final Color? backgroundColor;
  final double? iconSize;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const CommonBottomNav({
    Key? key,
    required this.selectedIndex,
    this.onIndexChanged,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.backgroundColor,
    this.iconSize,
    this.fontSize,
    this.padding,
  }) : super(key: key);

  @override
  State<CommonBottomNav> createState() => _CommonBottomNavState();
}

class _CommonBottomNavState extends State<CommonBottomNav> {
  final DashboardController _dashboardC = Get.find<DashboardController>();

  // Get current index based on route
  @override
  Widget build(BuildContext context) {
    // return Container(
    //   decoration: BoxDecoration(
    //     color: backgroundColor ?? CommonColors.whiteColor,
    //     boxShadow: [
    //       BoxShadow(
    //         color: CommonColors.greyColor.withValues(alpha: 0.2),
    //         blurRadius: 2.w,
    //         offset: Offset(0, -0.5.h),
    //       ),
    //     ],
    //   ),
    //   child: Padding(
    //     padding: padding ??
    //         EdgeInsets.symmetric(
    //           horizontal: 4.w,
    //           vertical: 1.5.h,
    //         ),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceAround,
    //       children: items.asMap().entries.map((entry) {
    //         final index = entry.key;
    //         final item = entry.value;
    //         return _buildNavItem(
    //           label: item.label,
    //           index: index,
    //           currentIndex: currentIndex,
    //           filledIcon: item.filledIcon,
    //           outlinedIcon: item.outlinedIcon,
    //         );
    //       }).toList(),
    //     ),
    //   ),
    // );
    return BottomNavigationBar(
      backgroundColor: CommonColors.whiteColor,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.event_available_outlined), label: 'My Bookings'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'My Account'),
      ],
      currentIndex: _dashboardC.selectedScreen.value,
      selectedItemColor: widget.selectedIconColor,
      onTap: widget.onIndexChanged,
    );
  }
}
