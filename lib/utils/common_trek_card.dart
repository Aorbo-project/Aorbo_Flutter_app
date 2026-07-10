import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/auth_utils.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../freezed_models/treks/treks_model_data.dart';
import '../widgets/custom_network_image.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _TkC {
  static const bg = Colors.white;
  static const ink = Color(0xFF111827);
  static const inkMid = Color(0xFF6B7280);
  static const inkLight = Color(0xFF9CA3AF);
  static const teal = Color(0xFF0F7B6C);
  static const tealLight = Color(0xFF1AA090);
  static const tealSoft = Color(0xFFE6F5F3);
  static const fieldBg = Color(0xFFF9FAFB);
  static const fieldBorder = Color(0xFFE5E7EB);
  static const divider = Color(0xFFE5E7EB);
  static const danger = Color(0xFFDC2626);
  static const starColor = Color(0xFFEF9F27);
  static const priceColor = Color(0xFF0F7B6C);
  static const cardBorder = Color(0xFFE9ECEF);
}

class CommonTrekCard extends StatefulWidget {
  final TrekData? trek;
  final VoidCallback? onTap;
  final bool showShare;
  final VoidCallback? onShareTap;
  final VoidCallback? onViewItineraryTap;
  final String? fromLocation;
  final String? toLocation;

  const CommonTrekCard({
    super.key,
    required this.trek,
    this.onTap,
    this.showShare = false,
    this.onShareTap,
    this.onViewItineraryTap,
    this.fromLocation,
    this.toLocation,
  });

  @override
  State<CommonTrekCard> createState() => _CommonTrekCardState();
}

class _CommonTrekCardState extends State<CommonTrekCard>
    with TickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  late final AnimationController _favCtrl;
  late final Animation<double> _favScale;

  late final AnimationController _newTagCtrl;

  bool _isFav = false;

  String get _favoriteKey => "${widget.trek?.id}_${widget.trek?.batchInfo?.id}";

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));

    _favCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _favScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 1.0),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 1.0),
    ]).animate(CurvedAnimation(parent: _favCtrl, curve: Curves.easeInOut));

    _newTagCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _isFav = AroboPersonalization.instance.isFavorite(_favoriteKey);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _favCtrl.dispose();
    _newTagCtrl.dispose();
    super.dispose();
  }

  String _formatPriceSpaced(String raw) {
    return AuthUtils.formatPrice(raw).replaceAll(',', ' ');
  }

  String _calculateDiscountedPrice() =>
      _formatPriceSpaced(widget.trek?.price?.replaceAll(',', '') ?? '0.00');

  String _getOriginalPrice() {
    if (widget.trek?.hasDiscount != true || widget.trek?.discountText == null) {
      return _formatPriceSpaced(
        widget.trek?.price?.replaceAll(',', '') ?? '0.00',
      );
    }
    double discounted =
        double.tryParse(widget.trek?.price?.replaceAll(',', '') ?? '0.00') ??
        0.00;
    String discountText = widget.trek?.discountText ?? '';
    if (discountText.contains('%')) {
      double pct =
          double.tryParse(discountText.replaceAll(RegExp(r'[^\d.]'), '')) ??
          0.0;
      return _formatPriceSpaced(
        (discounted / (1 - (pct / 100))).toStringAsFixed(0),
      );
    } else {
      double amt =
          double.tryParse(discountText.replaceAll(RegExp(r'[^\d.]'), '')) ??
          0.0;
      return _formatPriceSpaced((discounted + amt).toStringAsFixed(0));
    }
  }

  String _vendorInitials() {
    final name =
        (widget.trek?.companyName ??
                widget.trek?.businessName ??
                widget.trek?.vendor ??
                '')
            .trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((e) => e.trim().isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  bool _isNew() {
    final ratingValue = double.tryParse('${widget.trek?.rating ?? 0}') ?? 0.0;
    return ratingValue <= 0.0;
  }

  void _toggleFavorite() {
    HapticFeedback.mediumImpact();
    final key = _favoriteKey;
    AroboPersonalization.instance.toggleFavorite(key);
    setState(() {
      _isFav = AroboPersonalization.instance.isFavorite(key);
    });
    if (_isFav) {
      _favCtrl.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trek = widget.trek;
    final badgeText = trek?.badge?.name ?? 'Best Seller';
    final policyText =
        trek?.cancellationPolicy?.title ?? "Standard Cancellation Policy";
    final isFlexible = policyText.toLowerCase().contains('flexible');
    final policyValue = isFlexible ? 'Flexible' : 'Standard';

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (context, _) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              width: 92.w,
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 1.2.h),
              decoration: BoxDecoration(
                color: _TkC.bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _TkC.cardBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    offset: const Offset(0, 4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header Row: Title + CTA Badge ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          trek?.name ?? '-',
                          textScaler: const TextScaler.linear(1.0),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s15,
                            fontWeight: FontWeight.w800,
                            color: _TkC.ink,
                            height: 1.3,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      _buildCtaChip(badgeText),
                    ],
                  ),
                  SizedBox(height: 0.8.h),

                  // ── Vendor Row: Logo + Name + NEW Tag + Rating ──
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: _TkC.tealSoft,
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: trek?.vendorLogo?.isNotEmpty == true
                            ? CustomNetworkImage(
                                accessToken: Repository.token,
                                imageUrl: trek?.vendorLogo ?? "",
                                fit: BoxFit.cover,
                                width: 8.w,
                                height: 8.w,
                              )
                            : Center(
                                child: Text(
                                  _vendorInitials(),
                                  textScaler: const TextScaler.linear(1.0),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w800,
                                    color: _TkC.teal,
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                trek?.companyName ??
                                    trek?.businessName ??
                                    trek?.vendor ??
                                    '-',
                                textScaler: const TextScaler.linear(1.0),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: FontSize.s11,
                                  fontWeight: FontWeight.w600,
                                  color: _TkC.inkMid,
                                ),
                              ),
                            ),
                            if (_isNew()) ...[
                              SizedBox(width: 1.5.w),
                              _buildNewTag(),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 2.w),
                      _buildRating(trek),
                    ],
                  ),
                  SizedBox(height: 1.2.h),

                  // ── Info & Price Split Row ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Side: Info Items (Duration now has full width)
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildInfoItem(
                              Icons.location_on_outlined,
                              'Destination',
                              widget.toLocation ?? widget.fromLocation ?? '-',
                            ),
                            SizedBox(height: 0.8.h),
                            _buildInfoItem(
                              Icons.event_rounded,
                              'Departure',
                              "${trek?.batchInfo?.startDate ?? ''} ${trek?.batchInfo?.startTime ?? ''}",
                            ),
                            SizedBox(height: 0.8.h),
                            _buildInfoItem(
                              Icons.timelapse_rounded,
                              'Duration',
                              trek?.duration ?? '-',
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 4.w),

                      // Right Side: Price Section
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (trek?.hasDiscount == true)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getOriginalPrice(),
                                    textScaler: const TextScaler.linear(1.0),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: FontSize.s9,
                                      color: _TkC.inkLight,
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: _TkC.inkLight,
                                    ),
                                  ),
                                  SizedBox(width: 1.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 1.5.w,
                                      vertical: 0.3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _TkC.danger.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      trek?.discountText ?? '',
                                      textScaler: const TextScaler.linear(1.0),
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: FontSize.s8,
                                        fontWeight: FontWeight.w800,
                                        color: _TkC.danger,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (trek?.hasDiscount == true)
                              SizedBox(height: 0.2.h),
                            Text(
                              trek?.hasDiscount == true
                                  ? _calculateDiscountedPrice()
                                  : _formatPriceSpaced(trek?.price ?? '0.00'),
                              textScaler: const TextScaler.linear(1.0),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s18,
                                fontWeight: FontWeight.w900,
                                color: _TkC.priceColor,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'per person',
                              textScaler: const TextScaler.linear(1.0),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s9,
                                color: _TkC.inkMid,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if ((trek?.batchInfo?.availableSlots ?? 0) > 0)
                              Padding(
                                padding: EdgeInsets.only(top: 0.4.h),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.local_fire_department_rounded,
                                      size: 2.8.w,
                                      color: _TkC.danger,
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      '${trek?.batchInfo?.availableSlots} slots left',
                                      textScaler: const TextScaler.linear(1.0),
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: FontSize.s9,
                                        fontWeight: FontWeight.w700,
                                        color: _TkC.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 1.2.h),

                  // ── Compact Footer: Policy + Actions ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildPolicyPill(policyValue, isFlexible),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFavoriteButton(),
                          SizedBox(width: 2.w),
                          GestureDetector(
                            onTap: widget.showShare
                                ? widget.onShareTap
                                : widget.onViewItineraryTap,
                            behavior: HitTestBehavior.opaque,
                            child: widget.showShare
                                ? _buildLinkAction(
                                    Icons.share_outlined,
                                    'Share',
                                  )
                                : _buildLinkAction(
                                    Icons.arrow_forward_rounded,
                                    'View itinerary',
                                    reversed: true,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Clean, icon-led info item without background containers
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 0.2.h),
          child: Icon(icon, size: 3.5.w, color: _TkC.teal),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s8,
                  fontWeight: FontWeight.w600,
                  color: _TkC.inkLight,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 0.1.h),
              Text(
                value,
                textScaler: const TextScaler.linear(1.0),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s11,
                  fontWeight: FontWeight.w700,
                  color: _TkC.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Compact Policy Pill for the footer
  Widget _buildPolicyPill(String policyValue, bool isFlexible) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: isFlexible ? _TkC.teal.withOpacity(0.1) : _TkC.fieldBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFlexible ? _TkC.teal.withOpacity(0.3) : _TkC.fieldBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFlexible
                ? Icons.swap_horiz_rounded
                : Icons.verified_user_outlined,
            size: 3.w,
            color: isFlexible ? _TkC.teal : _TkC.inkMid,
          ),
          SizedBox(width: 1.w),
          Text(
            '$policyValue Policy',
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s9,
              fontWeight: FontWeight.w700,
              color: isFlexible ? _TkC.teal : _TkC.inkMid,
            ),
          ),
        ],
      ),
    );
  }

  // Smaller Sleek circular Save button
  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: _toggleFavorite,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _favCtrl,
        builder: (_, child) {
          return Transform.scale(scale: _favScale.value, child: child);
        },
        child: Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: _isFav ? _TkC.teal.withOpacity(0.1) : _TkC.fieldBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: _isFav ? _TkC.teal.withOpacity(0.3) : _TkC.fieldBorder,
              width: 1.2,
            ),
          ),
          child: Icon(
            _isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            size: 4.w,
            color: _isFav ? _TkC.teal : _TkC.inkMid,
          ),
        ),
      ),
    );
  }

  // Tighter Text Link Action (No container)
  Widget _buildLinkAction(
    IconData icon,
    String label, {
    bool reversed = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 1.w,
        vertical: 0.5.h,
      ), // Reduced padding
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!reversed) ...[
            Icon(icon, size: 3.8.w, color: _TkC.teal),
            SizedBox(width: 1.w),
          ],
          Text(
            label,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s11,
              fontWeight: FontWeight.w800,
              color: _TkC.teal,
            ),
          ),
          if (reversed) ...[
            SizedBox(width: 1.w),
            Icon(icon, size: 3.8.w, color: _TkC.teal),
          ],
        ],
      ),
    );
  }

  Widget _buildRating(TrekData? trek) {
    final ratingValue = double.tryParse('${trek?.rating ?? 0}') ?? 0.0;
    if (ratingValue <= 0.0) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: _TkC.starColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _TkC.starColor.withOpacity(0.2), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: _TkC.starColor),
          SizedBox(width: 1.w),
          Text(
            '$ratingValue',
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s11,
              fontWeight: FontWeight.w800,
              color: _TkC.ink,
            ),
          ),
        ],
      ),
    );
  }

  // Top Right CTA Badge
  Widget _buildCtaChip(String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: _TkC.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _TkC.teal.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 2.8.w, color: _TkC.teal),
          SizedBox(width: 1.w),
          Text(
            text.toUpperCase(),
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s8,
              fontWeight: FontWeight.w800,
              color: _TkC.teal,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── "NEW" TAG — Vibrant Animated Text ──
  Widget _buildNewTag() {
    return AnimatedBuilder(
      animation: _newTagCtrl,
      builder: (_, __) {
        final color = Color.lerp(
          const Color(0xFFEF9F27),
          const Color(0xFFFF6B3A),
          _newTagCtrl.value,
        );
        return Container(
          margin: EdgeInsets.only(bottom: 0.2.h),
          child: Text(
            'NEW',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s9,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: color!.withOpacity(0.5),
                  blurRadius: 6 * _newTagCtrl.value,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
