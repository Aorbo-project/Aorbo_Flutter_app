import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'common_colors.dart';
import 'common_images.dart';
import 'screen_constants.dart';

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    final snackBarHeight = 5.h;

    // Remove any existing SnackBars
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        duration: duration,
        content: _AnimatedSnackBarContent(
          message: message,
          height: snackBarHeight,
        ),
      ),
    );
  }
}

class _AnimatedSnackBarContent extends StatefulWidget {
  final String message;
  final double height;

  const _AnimatedSnackBarContent({
    required this.message,
    required this.height,
  });

  @override
  State<_AnimatedSnackBarContent> createState() =>
      _AnimatedSnackBarContentState();
}

class _AnimatedSnackBarContentState extends State<_AnimatedSnackBarContent>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from bottom
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the constraints for the message
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: widget.message,
        style: GoogleFonts.poppins(
          fontSize: FontSize.s10,
          fontWeight: FontWeight.w500,
        ),
      ),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 80.w);

    // Calculate container width based on text width plus padding and icon
    final double containerWidth = textPainter.width + widget.height + 8.w;
    final double finalWidth = containerWidth.clamp(40.w, 92.w);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Container(
            width: finalWidth,
            height: widget.height,
            decoration: BoxDecoration(
              color: Color(0xFF61D5C7),
              borderRadius: BorderRadius.circular(widget.height / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: widget.height,
                  width: widget.height,
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFEB3B),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    CommonImages.logo3,
                    fit: BoxFit.contain,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s10,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
