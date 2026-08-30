import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:arobo_app/theme/app_typography.dart';

/// Same public API as before. Fixes:
///  • Disabled state is now visually distinct even with a gradient
///    (previously Ink painted the gradient regardless of isDisabled).
///  • Tap is genuinely blocked when isDisabled — no more `() {}` hacks.
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
    super.key,
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
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius ?? 4.h);
    final solid =
        backgroundColor ?? CommonColors.searchbtn.withValues(alpha: 0.9);

    return SizedBox(
      width: isFullWidth ? double.infinity : (width ?? 40.w),
      height: height ?? 6.h,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isDisabled ? 0.55 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: (gradient?.colors.first ?? solid).withValues(
                        alpha: 0.30,
                      ),
                      blurRadius: (elevation ?? 3) * 3,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                gradient: gradient,
                color: gradient == null ? solid : null,
                borderRadius: radius,
              ),
              child: InkWell(
                onTap: isDisabled ? null : onPressed,
                borderRadius: radius,
                splashColor: Colors.white.withValues(alpha: 0.15),
                highlightColor: Colors.transparent,
                child: Center(
                  child: Padding(
                    // Keep the label off the pill's rounded edges even when
                    // it's long enough to need truncating.
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (prefixIcon != null) ...[
                          prefixIcon!,
                          SizedBox(width: 1.w),
                        ],
                        // Flexible + ellipsis: a long label (or a huge
                        // sizer-scaled font on a tablet) now truncates
                        // inside the button instead of overflowing off its
                        // right edge.
                        Flexible(
                          child: Text(
                            text,
                            textScaler: const TextScaler.linear(1.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppType.style(
                              fontSize ?? FontSize.s14,
                              w: fontWeight ?? FontWeight.w800,
                              color: textColor ?? CommonColors.searchbtntext,
                            ),
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
            ),
          ),
        ),
      ),
    );
  }
}
