import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'dart:math';

class TopTreksCard extends StatefulWidget {
  final Color gradientEndColor;
  final String imagePath;
  final String title;
  final String description;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? imageWidth;
  final double? imageHeight;
  final EdgeInsetsGeometry? contentPadding;
  final LinearGradient? customGradient;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;

  const TopTreksCard({
    Key? key,
    required this.gradientEndColor,
    required this.imagePath,
    required this.title,
    required this.description,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.textColor,
    this.width,
    this.height,
    this.imageWidth,
    this.imageHeight,
    this.contentPadding,
    this.customGradient,
    this.titleStyle,
    this.descriptionStyle,
  }) : super(key: key);

  @override
  State<TopTreksCard> createState() => _TopTreksCardState();
}

class _TopTreksCardState extends State<TopTreksCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showOverlay = false;
  OverlayEntry? _overlayEntry;
  final GlobalKey _heartIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _showOverlay = false;
  }

  void _showHeartOverlay(BuildContext context) {
    _removeOverlay();

    // Get the position of the heart icon
    final RenderBox? heartIcon =
        _heartIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (heartIcon == null) return;

    final position = heartIcon.localToGlobal(Offset.zero);
    final size = heartIcon.size;

    // Calculate the center of the heart icon
    final heartCenterX = position.dx + (size.width / 2);
    final heartCenterY = position.dy + (size.height / 2);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: List.generate(6, (index) {
          return Positioned(
            left: heartCenterX - 15,
            top: heartCenterY - 15,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 600 + (index * 100)),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                final angle = (index * (360 / 6)) * (3.14159 / 180);
                final radius = 40 * value;
                final opacity = (1 - value);
                final scale = 1 - (value * 0.5);

                return Transform.translate(
                  offset: Offset(
                    cos(angle) * radius,
                    sin(angle) * radius - (30 * value),
                  ),
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: Icon(
                        Icons.favorite,
                        color: CommonColors.favColor,
                        size: 30,
                      ),
                    ),
                  ),
                );
              },
              onEnd: index == 0 ? _removeOverlay : null,
            ),
          );
        }),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _showOverlay = true;
  }

  void _handleFavoriteTap() {
    if (widget.onFavoriteTap != null) {
      widget.onFavoriteTap!();
      _animationController.forward();
      _showHeartOverlay(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);
    final cardWidth = widget.width ?? MediaQuery.of(context).size.width * 0.75;

    return SizedBox(
      width: 80.w,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScreenConstant.size20),
        ),
        child: Container(
          height: 25.h,
          padding: EdgeInsets.all(ScreenConstant.size5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenConstant.size15),
            gradient: widget.customGradient ??
                LinearGradient(
                  colors: [
                    CommonColors.whiteColor,
                    widget.gradientEndColor,
                  ],
                ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 35.w,
                height: 23.h,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(ScreenConstant.size18),
                      child: Image.asset(
                        widget.imagePath,
                        width: 34.w,
                        height: 23.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0.5.h,
                      right: 0.5.h,
                      child: SizedBox(
                        width: 4.5.h,
                        height: 4.5.h,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _handleFavoriteTap,
                            borderRadius: BorderRadius.circular(2.25.h),
                            child: AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Icon(
                                    widget.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    key: _heartIconKey,
                                    size: 2.5.h,
                                    color: widget.isFavorite
                                        ? CommonColors.favColor
                                        : CommonColors.whiteColor,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 2.5.h,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.title,
                          textAlign: TextAlign.end,
                          textScaler: const TextScaler.linear(1.0),
                          style: widget.titleStyle ??
                              GoogleFonts.poppins(
                                fontSize: FontSize.s17,
                                fontWeight: FontWeight.w500,
                                color:
                                    widget.textColor ?? CommonColors.blackColor,
                                height: 1.2,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          widget.description,
                          textAlign: TextAlign.end,
                          textScaler: const TextScaler.linear(1.0),
                          style: widget.descriptionStyle ??
                              TextStyle(
                                fontSize: FontSize.s7,
                                color:
                                    widget.textColor ?? CommonColors.blackColor,
                                height: 1.3,
                                letterSpacing: 0.2,
                              ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Example usage:
// TopTreksCard(
//   gradientEndColor: CommonColors.appYellowColor,
//   imagePath: 'assets/images/img6.png',
//   title: 'Coorg',
//   description: 'The SCOTLAND of India, offers misty hills, lush coffee plantations & serene waterfalls.',
//   onFavoriteTap: () {
//     // Handle favorite tap
//   },
// );

// For a custom styled card:
// TopTreksCard(
//   gradientEndColor: CommonColors.appPurpleColor,
//   imagePath: 'assets/images/custom_trek.png',
//   title: 'Custom Trek',
//   description: 'Custom description here',
//   width: 400,
//   height: 280,
//   imageWidth: 200,
//   imageHeight: 300,
//   isFavorite: true,
//   contentPadding: EdgeInsets.all(15),
//   customGradient: LinearGradient(
//     colors: [Colors.blue, Colors.purple],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   ),
//   titleStyle: TextStyle(fontSize: 21, color: Colors.white),
//   descriptionStyle: TextStyle(fontSize: 11, color: Colors.white70),
//   onFavoriteTap: () => print('Favorite tapped'),
// );
