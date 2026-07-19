import 'package:arobo_app/utils/common_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

import '../widgets/custom_network_image.dart';

/// Photo-first "Top Treks" card: full-bleed image, bottom gradient scrim,
/// a floating "Top Pick" badge, a heart-save action, and title/description
/// overlaid on the scrim. Designed to sit inside a peeking horizontal
/// PageView carousel or a 2-up grid.
class TopTreksCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final String badgeText;
  final IconData badgeIcon;
  final String? kicker;
  final String? meta;
  final IconData metaIcon;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;
  final bool isFavorite;
  final double width;
  final double height;

  const TopTreksCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    this.badgeText = 'Top Pick',
    this.badgeIcon = Icons.star_rounded,
    this.kicker,
    this.meta,
    this.metaIcon = Icons.hiking_rounded,
    this.onFavoriteTap,
    this.onTap,
    this.isFavorite = false,
    required this.width,
    required this.height,
  });

  @override
  State<TopTreksCard> createState() => _TopTreksCardState();
}

class _TopTreksCardState extends State<TopTreksCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  OverlayEntry? _overlayEntry;
  final GlobalKey _heartIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
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
  }

  void _showHeartBurst(BuildContext context) {
    _removeOverlay();

    final RenderBox? heartIcon =
        _heartIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (heartIcon == null) return;

    final position = heartIcon.localToGlobal(Offset.zero);
    final size = heartIcon.size;
    final centerX = position.dx + (size.width / 2);
    final centerY = position.dy + (size.height / 2);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: List.generate(6, (index) {
          return Positioned(
            left: centerX - 15,
            top: centerY - 15,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 600 + (index * 100)),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                final angle = (index * (360 / 6)) * (pi / 180);
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
  }

  void _handleFavoriteTap() {
    if (widget.onFavoriteTap != null) {
      widget.onFavoriteTap!();
      _animationController.forward();
      if (!widget.isFavorite) _showHeartBurst(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: CommonColors.grey200,
            border: Border.all(
              color: CommonColors.whiteColor.withValues(alpha: 0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: CommonColors.blackColor.withValues(alpha: 0.16),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full-bleed photo (local asset for design-review dummy
              // data, network for live backend-driven data)
              widget.imagePath.startsWith('http')
                  ? CustomNetworkImage(
                      imageUrl: widget.imagePath,
                      width: widget.width,
                      height: widget.height,
                      fit: BoxFit.cover,
                      borderRadius: 22,
                    )
                  : Image.asset(
                      widget.imagePath,
                      width: widget.width,
                      height: widget.height,
                      fit: BoxFit.cover,
                    ),

              // Bottom scrim for text legibility — deepens with a hint of
              // brand teal so it reads as designed, not just "darkened".
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.22, 0.6, 1.0],
                    colors: [
                      Colors.transparent,
                      CommonColors.blackColor.withValues(alpha: 0.38),
                      Color.lerp(
                        CommonColors.blackColor,
                        CommonColors.darkCyan,
                        0.28,
                      )!.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),

              // "Top Pick" badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CommonColors.whiteColor.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: CommonColors.blackColor.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.badgeIcon,
                        size: 13,
                        color: CommonColors.appRedColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.badgeText,
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: CommonColors.blackColor,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Heart save
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: CommonColors.blackColor.withValues(alpha: 0.28),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _handleFavoriteTap,
                    child: SizedBox(
                      width: 34,
                      height: 34,
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
                              size: 18,
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

              // Kicker + title + meta + description
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.kicker != null && widget.kicker!.isNotEmpty) ...[
                      Text(
                        widget.kicker!.toUpperCase(),
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: CommonColors.secondaryColor,
                          letterSpacing: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                    ],
                    Text(
                      widget.title,
                      textScaler: const TextScaler.linear(1.0),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: CommonColors.whiteColor,
                        letterSpacing: -0.2,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.meta != null && widget.meta!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.metaIcon,
                            size: 12,
                            color: CommonColors.whiteColor.withValues(
                              alpha: 0.85,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.meta!,
                            textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.whiteColor.withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      textScaler: const TextScaler.linear(1.0),
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                        color: CommonColors.whiteColor.withValues(alpha: 0.78),
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
