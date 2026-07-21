import 'dart:math' as math;
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/utils/auth_utils.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../freezed_models/treks/treks_model_data.dart';
import '../widgets/custom_network_image.dart';

// ─────────────────────────────────────────────
// DESIGN TOKENS — alpine / trail theme
// ─────────────────────────────────────────────
class _TC {
  static const bg = Colors.white;
  static const bgTint = Color(0xFFF6FAF7);
  static const cardBorder = Color(0xFFD8E2DA);
  static const ink = Color(0xFF16281E);
  static const inkMid = Color(0xFF5B6E60);
  static const inkLight = Color(0xFF8FA396);
  static const forest = Color(0xFF2D6A4F);
  static const forestDeep = Color(0xFF1B4332);
  static const forestSoft = Color(0xFFE8F3ED);
  static const trailAmber = Color(0xFFD97706);
  static const amberBg = Color(0xFFFFF8EB);
  static const amberBorder = Color(0xFFF5DFAE);
  static const divider = Color(0xFFE2EAE4);
  static const success = Color(0xFF059669);
  static const danger = Color(0xFFDC2626);
}

class CommonTrekCard extends StatefulWidget {
  final TrekData? trek;
  final VoidCallback? onTap;
  final bool showShare;
  final VoidCallback? onShareTap;
  final VoidCallback? onViewItineraryTap;

  /// Kept for API compatibility — route is now shown once on the
  /// search summary screen, so the card no longer renders it.
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;
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
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  // ── RESPONSIVE HELPERS ───────────────────────
  double _rw(double pct, double max) => math.min(pct.w, max);
  double _rh(double pct, double max) => math.min(pct.h, max);
  // ── DATA HELPERS ─────────────────────────────
  String _formatPriceSpaced(String raw) =>
      AuthUtils.formatPrice(raw).replaceAll(',', ' ');
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

  String _vendorName() =>
      (widget.trek?.companyName ??
              widget.trek?.businessName ??
              widget.trek?.vendor ??
              '')
          .trim();
  String _vendorInitials() {
    final name = _vendorName();
    if (name.isEmpty) return '?';
    final parts = name
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  bool _isNewVendor() {
    final ratingValue = double.tryParse('${widget.trek?.rating ?? 0}') ?? 0.0;
    return ratingValue <= 0.0;
  }

  // ── BUILD ────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);
    final trek = widget.trek;
    final String badgeText = trek?.badge?.name ?? 'Best Seller';
    final String policyText =
        trek?.cancellationPolicy?.title ?? 'Standard Cancellation Policy';
    final bool isFlexible = policyText.toLowerCase().contains('flexible');
    final String departure =
        "${trek?.batchInfo?.startDate ?? ''} ${trek?.batchInfo?.startTime ?? ''}"
            .trim();
    final String duration = (trek?.duration ?? '').trim();
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
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _rw(1, 16),
                vertical: _rh(0.6, 7),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_TC.bg, _TC.bgTint],
                  ),
                  borderRadius: BorderRadius.circular(_rw(4, 18)),
                  border: Border.all(color: _TC.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: _TC.forestDeep.withValues(alpha: 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: _TC.forest.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // topo rings, top-right corner
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(painter: _ContourPainter()),
                      ),
                    ),
                    // faint mountain watermark along the bottom edge
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 54,
                      child: const IgnorePointer(
                        child: CustomPaint(
                          painter: _RidgeWatermarkPainter(),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // "trail marker" accent strip
                        Container(
                          height: 3,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _TC.forestDeep,
                                _TC.forest,
                                _TC.trailAmber,
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            _rw(3.6, 16),
                            _rh(1.1, 12),
                            _rw(3.6, 16),
                            _rh(1.2, 14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHeader(trek, isFlexible),
                              SizedBox(height: _rh(0.8, 9)),
                              Text(
                                trek?.name ?? '-',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textScaler: const TextScaler.linear(1),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: FontSize.s13,
                                  fontWeight: FontWeight.w800,
                                  color: _TC.ink,
                                  height: 1.2,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(height: _rh(0.6, 7)),
                              Wrap(
                                spacing: _rw(1.4, 7),
                                runSpacing: _rh(0.4, 5),
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (badgeText.isNotEmpty)
                                    _chip(
                                      badgeText.toUpperCase(),
                                      color: _TC.trailAmber,
                                      filled: true,
                                    ),
                                  if (duration.isNotEmpty)
                                    _chip(
                                      duration.toUpperCase(),
                                      color: _TC.forestDeep,
                                      icon: Icons.timelapse_rounded,
                                    ),
                                  if (!_isNewVendor()) _ratingPill(trek),
                                ],
                              ),
                              SizedBox(height: _rh(0.9, 10)),
                              Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _TC.divider.withValues(alpha: 0),
                                      _TC.divider,
                                      _TC.divider.withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: _rh(0.9, 10)),
                              // departure/slots · price · action — one row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: _buildDepartureSlots(
                                      trek,
                                      departure,
                                    ),
                                  ),
                                  SizedBox(width: _rw(2.5, 12)),
                                  _buildPriceBlock(trek),
                                  SizedBox(width: _rw(2.5, 12)),
                                  _ctaButton(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── HEADER: logo · name + NEW · policy top-right ──
  Widget _buildHeader(TrekData? trek, bool isFlexible) {
    final vendorName = _vendorName().isEmpty ? '-' : _vendorName();
    final vendorLogo = trek?.vendorLogo ?? '';
    final logoSize = _rw(7.6, 34);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: _TC.forestDeep,
            borderRadius: BorderRadius.circular(_rw(2.2, 10)),
          ),
          clipBehavior: Clip.antiAlias,
          child: vendorLogo.isNotEmpty
              ? CustomNetworkImage(
                  accessToken: Repository.token,
                  imageUrl: vendorLogo,
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.cover,
                )
              : Center(
                  child: Text(
                    _vendorInitials(),
                    textScaler: const TextScaler.linear(1),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
        SizedBox(width: _rw(2.2, 11)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ORGANISED BY',
                textScaler: const TextScaler.linear(1),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s7,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: _TC.inkLight,
                  height: 1,
                ),
              ),
              SizedBox(height: _rh(0.2, 2.5)),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      vendorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textScaler: const TextScaler.linear(1),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s10,
                        fontWeight: FontWeight.w600,
                        color: _TC.ink,
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (_isNewVendor()) ...[
                    SizedBox(width: _rw(1.2, 6)),
                    _newOrganiserChip(),
                  ],
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: _rw(2, 10)),
        _chip(
          isFlexible ? 'FLEXIBLE' : 'STANDARD',
          color: isFlexible ? _TC.success : _TC.inkMid,
          icon: isFlexible
              ? Icons.swap_horiz_rounded
              : Icons.verified_user_outlined,
        ),
      ],
    );
  }

  Widget _newOrganiserChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _rw(1.4, 7), vertical: 2),
      decoration: BoxDecoration(
        color: _TC.forestSoft,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _TC.forest.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco_rounded, size: _rw(2.4, 10), color: _TC.forest),
          SizedBox(width: _rw(0.6, 3)),
          Text(
            'NEW',
            textScaler: const TextScaler.linear(1),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s7,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: _TC.forest,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingPill(TrekData? trek) {
    final ratingValue = double.tryParse('${trek?.rating ?? 0}') ?? 0.0;
    if (ratingValue <= 0.0) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _rw(1.8, 9), vertical: 3),
      decoration: BoxDecoration(
        color: _TC.amberBg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _TC.amberBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: _rw(3, 13), color: _TC.trailAmber),
          SizedBox(width: _rw(0.7, 3.5)),
          Text(
            '$ratingValue',
            textScaler: const TextScaler.linear(1),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s8,
              fontWeight: FontWeight.w700,
              color: _TC.ink,
            ),
          ),
        ],
      ),
    );
  }

  // ── CHIP ─────────────────────────────────────
  Widget _chip(
    String text, {
    required Color color,
    IconData? icon,
    bool filled = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _rw(1.8, 9),
        vertical: _rh(0.28, 3.5),
      ),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
        border: filled
            ? null
            : Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: _rw(2.7, 12),
              color: filled ? Colors.white : color,
            ),
            SizedBox(width: _rw(0.8, 4)),
          ],
          Text(
            text,
            textScaler: const TextScaler.linear(1),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s7,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: filled ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }

  // ── DEPARTURE + SLOTS (left column) ──────────
  Widget _buildDepartureSlots(TrekData? trek, String departure) {
    final available = trek?.batchInfo?.availableSlots ?? 0;
    final total = trek?.batchInfo?.capacity ?? 0;
    final hasSlots = available > 0 || total > 0;
    final hasTotal = total > 0;
    final booked = hasTotal ? (total - available).clamp(0, total) : 0;
    final bookedPct = hasTotal ? booked / total : 0.0;
    final isLow = hasTotal ? (available / total) <= 0.3 : available <= 5;
    final accent = isLow ? _TC.danger : _TC.success;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.event_rounded, size: _rw(3.2, 14), color: _TC.forest),
            SizedBox(width: _rw(1.2, 6)),
            Expanded(
              child: Text(
                departure.isEmpty ? '-' : departure,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: const TextScaler.linear(1),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s9,
                  fontWeight: FontWeight.w700,
                  color: _TC.ink,
                ),
              ),
            ),
          ],
        ),
        if (hasSlots) ...[
          SizedBox(height: _rh(0.4, 5)),
          Row(
            children: [
              if (isLow) ...[
                Icon(
                  Icons.local_fire_department_rounded,
                  size: _rw(3, 13),
                  color: _TC.danger,
                ),
                SizedBox(width: _rw(0.7, 3.5)),
              ],
              Text(
                hasTotal ? '$available/$total slots left' : '$available slots',
                textScaler: const TextScaler.linear(1),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s8,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ],
          ),
          if (hasTotal) ...[
            SizedBox(height: _rh(0.4, 5)),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: bookedPct),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 4,
                    backgroundColor: _TC.divider.withValues(alpha: 0.6),
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  );
                },
              ),
            ),
          ],
        ],
      ],
    );
  }

  // ── PRICE BLOCK ──────────────────────────────
  Widget _buildPriceBlock(TrekData? trek) {
    final hasDiscount = trek?.hasDiscount == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasDiscount)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getOriginalPrice(),
                textScaler: const TextScaler.linear(1),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s8,
                  color: _TC.inkLight,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: _TC.inkLight,
                ),
              ),
              SizedBox(width: _rw(1, 5)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _rw(1.3, 6),
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: _TC.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trek?.discountText ?? '',
                  textScaler: const TextScaler.linear(1),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s8,
                    fontWeight: FontWeight.w700,
                    color: _TC.danger,
                  ),
                ),
              ),
            ],
          ),
        if (hasDiscount) SizedBox(height: _rh(0.2, 2.5)),
        Text(
          hasDiscount
              ? _calculateDiscountedPrice()
              : _formatPriceSpaced(trek?.price ?? '0.00'),
          textScaler: const TextScaler.linear(1),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w800,
            color: _TC.forestDeep,
            letterSpacing: -0.2,
            height: 1.15,
          ),
        ),
        Text(
          '/ person',
          textScaler: const TextScaler.linear(1),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s8,
            fontWeight: FontWeight.w500,
            color: _TC.inkMid,
          ),
        ),
      ],
    );
  }

  // ── COMPACT ACTION (replaces the old footer) ──
  Widget _ctaButton() {
    final isShare = widget.showShare;
    return GestureDetector(
      onTap: isShare ? widget.onShareTap : widget.onViewItineraryTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _rw(8.6, 38),
            height: _rw(8.6, 38),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_TC.forestDeep, _TC.forest],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _TC.forestDeep.withValues(alpha: 0.30),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              isShare ? Icons.share_outlined : Icons.arrow_forward_rounded,
              size: _rw(3.8, 17),
              color: Colors.white,
            ),
          ),
          SizedBox(height: _rh(0.3, 3.5)),
          Text(
            isShare ? 'Share' : 'Itinerary',
            textScaler: const TextScaler.linear(1),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s7,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: _TC.forestDeep,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TOPOGRAPHIC CONTOUR RINGS (card corner)
// ─────────────────────────────────────────────
class _ContourPainter extends CustomPainter {
  const _ContourPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _TC.forest.withValues(alpha: 0.06);
    final center = Offset(size.width + 8, -8);
    for (double r = 26; r <= 150; r += 24) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(_ContourPainter old) => false;
}

// ─────────────────────────────────────────────
// FAINT MOUNTAIN WATERMARK — bottom of card
// (light-on-white, replaces the dark footer)
// ─────────────────────────────────────────────
class _RidgeWatermarkPainter extends CustomPainter {
  const _RidgeWatermarkPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // soft "sun" glow, lower-left
    canvas.drawCircle(
      Offset(w * 0.12, h * 0.55),
      h * 0.5,
      Paint()..color = _TC.trailAmber.withValues(alpha: 0.05),
    );
    final back = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.66)
      ..lineTo(w * 0.14, h * 0.34)
      ..lineTo(w * 0.30, h * 0.70)
      ..lineTo(w * 0.46, h * 0.22)
      ..lineTo(w * 0.62, h * 0.64)
      ..lineTo(w * 0.78, h * 0.32)
      ..lineTo(w * 0.92, h * 0.68)
      ..lineTo(w, h * 0.48)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(back, Paint()..color = _TC.forest.withValues(alpha: 0.045));
    final front = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.84)
      ..lineTo(w * 0.20, h * 0.52)
      ..lineTo(w * 0.38, h * 0.86)
      ..lineTo(w * 0.56, h * 0.46)
      ..lineTo(w * 0.72, h * 0.82)
      ..lineTo(w * 0.88, h * 0.56)
      ..lineTo(w, h * 0.80)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(front, Paint()..color = _TC.forest.withValues(alpha: 0.07));
  }

  @override
  bool shouldRepaint(_RidgeWatermarkPainter old) => false;
}
