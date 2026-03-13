import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final double? borderRadius;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final bool isFullWidth;
  final bool isDisabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final LinearGradient? gradient;
  final FontWeight? fontWeight;
  final String? fontFamily;

  const CommonButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.fontSize,
    this.fontFamily,
    this.borderRadius,
    this.elevation,
    this.padding,
    this.isFullWidth = true,
    this.isDisabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.gradient,
    this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : (width ?? 40.w),
      height: height ?? 6.h,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          elevation: elevation ?? 3,
          shadowColor: CommonColors.blackColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4.h),
          ),
          disabledBackgroundColor: backgroundColor?.withValues(alpha: 0.6) ??
              CommonColors.searchbtn.withValues(alpha: 0.6),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null
                ? (backgroundColor ??
                    CommonColors.searchbtn.withValues(alpha: 0.9))
                : null,
            borderRadius: BorderRadius.circular(borderRadius ?? 4.h),
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (prefixIcon != null) ...[
                  prefixIcon!,
                  SizedBox(width: 1.w),
                ],
                Text(
                  text,
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontSize: fontSize ?? FontSize.s14,
                    fontWeight: fontWeight ?? FontWeight.w800,
                    color: textColor ?? CommonColors.searchbtntext,
                    fontFamily: fontFamily,
                  ),
                ),
                if (suffixIcon != null) ...[
                  SizedBox(width: 1.w),
                  suffixIcon!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Example usage:
// CommonButton(
//   text: 'Continue',
//   onPressed: () {
//     // Your action here
//   },
//   backgroundColor: CommonColors.appYellowColor,
//   textColor: CommonColors.blackColor,
//   isFullWidth: true,
// );

// For a custom styled button:
// CommonButton(
//   text: 'Custom Button',
//   onPressed: () {},
//   backgroundColor: Colors.blue,
//   textColor: Colors.white,
//   borderRadius: 10,
//   elevation: 4,
//   padding: EdgeInsets.symmetric(vertical: 12),
//   isFullWidth: false,
//   width: 200,
//   prefixIcon: Icon(Icons.add),
// );
