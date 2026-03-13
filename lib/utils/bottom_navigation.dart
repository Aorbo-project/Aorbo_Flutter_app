import 'package:flutter/material.dart';

class BottomNavigation{

  static Widget bottomNavigation=Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(label: 'Home', index: 0),
          _buildNavItem(label: 'My Bookings', index: 1),
          _buildNavItem(label: 'Help', index: 2),
        ],
      ),
    ),
  );
  static Widget _buildNavItem({required String label, required int index}) {
    // final isSelected = index == selectedIndex;

    return GestureDetector(
      // onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon(
          //   isSelected ? _getFilledIcon(index) : _getOutlinedIcon(index),
          //   color: isSelected ? const Color(0xFFFED811) : Colors.black,
          //   size: 24,
          // ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

}