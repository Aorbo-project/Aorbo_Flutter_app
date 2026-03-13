  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:sizer/sizer.dart';
  import 'screen_constants.dart';

  class CommonSafetyCard extends StatelessWidget {
    final String title;
    final String subtitle;
    final String backgroundImage;
    final String? logoPath;
    final String? footerText;
    final List<Color> gradientColors;
    final double? height;
    final double? width;
    final VoidCallback? onTap;
    final EdgeInsetsGeometry? margin;
    final BorderRadius? borderRadius;

    const CommonSafetyCard({
      Key? key,
      required this.title,
      required this.subtitle,
      required this.backgroundImage,
      this.logoPath,
      this.footerText,
      this.gradientColors = const [
        Color(0xFF6A1B9A),
        Color(0xFF8E24AA),
      ],
      this.height,
      this.width,
      this.onTap,
      this.margin,
      this.borderRadius,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: height ?? 35.h, // 35% of screen height
          width: width ?? 100.w, // 100% of screen width
          margin: margin ?? EdgeInsets.all(2.w), // 2% of screen width
          child: ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.circular(2.w),
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(child: _buildBackgroundImage()),

                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),

                // Foreground 2x2 Grid Content
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 10.w,
                      right: 6.w,
                      top: 8.w,
                      // bottom: 2.w,
                    ), // 3% of screen width
                    child: Column(
                      children: [
                        _buildTextContent(),
                        // Top Right (empty)
                        SizedBox(width: 30.w),
                        _buildLogoFooter(),
                        // Bottom Right (empty)
                        SizedBox(width: 35.w),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildBackgroundImage() {
      return Image.asset(
        backgroundImage,
        fit: BoxFit.cover,

        gaplessPlayback: true, // Keeps old image while new one loads
        errorBuilder: (_, __, ___) => Container(color: Colors.grey),
      );
    }

    Widget _buildTextContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: FontSize.s12, // Responsive font size
              fontWeight: FontWeight.w800,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 1,
                  color: Colors.pink,
                ),
              ],
              color: Colors.white,
              height: 1.2,
            ),
          ),
          SizedBox(height: 0.6.h),
          Text(
            subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: FontSize.s10, // Responsive font size
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      );
    }

    Widget _buildLogoFooter() {
      return Align(
        alignment: Alignment.bottomRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (logoPath != null)
              Image.asset(
                logoPath!,
                height: 9.h, // 4% of screen height
                width: 9.h, // Keep aspect ratio square
              ),
            // if (footerText != null) ...[
            //   // SizedBox(height: 1.5.h), // 1.5% of screen height
            //   Text(
            //     footerText!,
            //     style: GoogleFonts.poppins(
            //       fontSize: FontSize.s10, // Responsive font size
            //       fontWeight: FontWeight.w600,
            //       color: Colors.white,
            //     ),
            //   ),
            // ],
          ],
        ),
      );
    }
  }
