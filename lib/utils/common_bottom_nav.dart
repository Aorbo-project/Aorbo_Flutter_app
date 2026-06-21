import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class CommonBottomNav extends StatefulWidget {
  final int selectedIndex;
  final Function(int)? onIndexChanged;
  final Color? selectedIconColor;
  final Color? unselectedIconColor;

  const CommonBottomNav({
    super.key,
    required this.selectedIndex,
    this.onIndexChanged,
    this.selectedIconColor,
    this.unselectedIconColor,
  });

  @override
  State<CommonBottomNav> createState() => _CommonBottomNavState();
}

class _CommonBottomNavState extends State<CommonBottomNav> {
  final DashboardController _dashboardC = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 4.w,
        right: 4.w,
        bottom: 2.h,
      ),
      padding: EdgeInsets.symmetric(vertical: 1.2.h),
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Obx(() {
        int currentIndex = _dashboardC.selectedScreen.value;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildItem(Icons.home_rounded, "Home", 0, currentIndex),
            _buildItem(Icons.event_available_rounded, "Bookings", 1, currentIndex),
            _buildItem(Icons.person_rounded, "Account", 2, currentIndex),
          ],
        );
      }),
    );
  }

  Widget _buildItem(
    IconData icon,
    String label,
    int index,
    int currentIndex,
  ) {
    bool isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () {
        if (widget.onIndexChanged != null) {
          widget.onIndexChanged!(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 4.w : 2.w,
          vertical: 1.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? CommonColors.blackColor.withValues(alpha: 1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isSelected
                  ? (widget.selectedIconColor ?? CommonColors.primaryColor)
                  : (widget.unselectedIconColor ?? Colors.grey),
            ),
            if (isSelected) ...[
              SizedBox(width: 2.w),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: widget.selectedIconColor ?? CommonColors.primaryColor,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}