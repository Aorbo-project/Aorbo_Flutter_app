import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/utils/auth_utils.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../freezed_models/treks/treks_model_data.dart';
import '../widgets/custom_network_image.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _TkC {
  static const bg          = CommonColors.whiteColor;
  static const ink         = CommonColors.cFF111827;
  static const inkMid      = CommonColors.cFF6B7280;
  static const inkLight    = CommonColors.grey_AEAEAE;
  static const iconBadge   = CommonColors.cFF111827;
  static const teal        = CommonColors.cFF0F7B6C;
  static const tealSoft    = CommonColors.cFFE6F5F3;
  static const brand       = CommonColors.lightBlueColor3;
  static const discBg      = CommonColors.cFFFFE4E4;
  static const discFg      = CommonColors.cFFDC2626;
  static const badgeBg     = Color(0xFFEAF3DE);
  static const badgeFg     = Color(0xFF3B6D11);
  static const slotsFg     = CommonColors.cFFDC2626;
  static const divider     = CommonColors.trekroutecolorlight;
  static const shadow      = CommonColors.c0A000000;
  static const policyStd   = Color(0xFFEEF2FF);
  static const policyFlex  = CommonColors.cFFE6F5F3;
  static const policyStdFg = CommonColors.lightBlueColor3;
  static const policyFlexFg= CommonColors.cFF0F7B6C;
  static const verifiedBg  = Color(0xFFEEF2FF);
  static const verifiedFg  = CommonColors.lightBlueColor3;
}

class CommonTrekCard extends StatelessWidget {
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

  // ── ALL ORIGINAL LOGIC UNTOUCHED ────────────

  LinearGradient getRatingColor(double rating) {
    if (rating >= 3.0 && rating <= 3.8) {
      return const LinearGradient(
          colors: [Color(0xFFFFD300), Color(0xFFFFD300)]);
    } else if (rating < 3.0) {
      return const LinearGradient(
          colors: [Color(0xFFFF6B3A), Color(0xFFFF6B3A)]);
    }
    return const LinearGradient(
        colors: [Color(0xFF19FA00), Color(0xFF4EE53D)]);
  }

  Color _parseBadgeColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Colors.transparent;
    if (colorHex.startsWith('#')) {
      try {
        String hex = colorHex.substring(1);
        if (hex.length == 6) hex = 'FF$hex';
        return Color(int.parse(hex, radix: 16));
      } catch (_) {
        return Colors.transparent;
      }
    }
    return Colors.transparent;
  }

  String _calculateDiscountedPrice() =>
      AuthUtils.formatPrice(
          trek?.price?.replaceAll(',', '') ?? '0.00');

  String _getOriginalPrice() {
    if (trek?.hasDiscount != true || trek?.discountText == null) {
      return AuthUtils.formatPrice(
          trek?.price?.replaceAll(',', '') ?? '0.00');
    }
    double discounted =
        double.tryParse(trek?.price?.replaceAll(',', '') ?? '0.00') ??
            0.00;
    String discountText = trek?.discountText ?? '';
    if (discountText.contains('%')) {
      double pct =
          double.tryParse(discountText.replaceAll(RegExp(r'[^\d.]'), '')) ??
              0.0;
      return AuthUtils.formatPrice(
          (discounted / (1 - (pct / 100))).toStringAsFixed(0));
    } else {
      double amt =
          double.tryParse(discountText.replaceAll(RegExp(r'[^\d.]'), '')) ??
              0.0;
      return AuthUtils.formatPrice((discounted + amt).toStringAsFixed(0));
    }
  }

  String _buildRoute() {
    final from = fromLocation ?? '';
    final to   = toLocation ?? '';
    if (from.isEmpty && to.isEmpty) return '';
    if (from.isEmpty) return to;
    if (to.isEmpty)   return from;
    return '$from → $to';
  }

  String _vendorInitials() {
    final name = (trek?.companyName ?? trek?.vendorName ?? trek?.businessName ?? trek?.vendor ?? '').trim();

    if (name.isEmpty) {
      return '?';
    }

    final parts = name
        .split(' ')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return (
      parts[0][0] + parts[1][0]
    ).toUpperCase();
  }
  // ── Helper for labeled info items ──────────
  Widget _buildInfoItem(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 0.3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s7,
              fontWeight: FontWeight.w500,
              color: _TkC.inkMid,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 0.1.h),
          Text(
            value,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s11,
              fontWeight: FontWeight.w600,
              color: _TkC.ink,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BUILD  (vendor directly below trek name)
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);

    print("policy $trek?.cancellationPolicy?.type");
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 92.w,
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        decoration: BoxDecoration(
          color: _TkC.bg,
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(color: _TkC.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: CommonColors.blackColor.withValues(alpha: 0.07),
              offset: const Offset(0, 3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ═══ TOP: Trek name + policy chip ═══
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
                        fontSize: FontSize.s13,
                        fontWeight: FontWeight.w600,
                        color: _TkC.ink,
                        height: 1.3,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                 _buildPolicyChip(
  trek?.cancellationPolicy?.title ?? "Standard Cancellation Policy",
),  // policy next to trek name
                ],
              ),

              SizedBox(height: 0.8.h),

              // ═══ VENDOR ROW (directly below trek name) ═══
              Row(
                children: [
                  // Vendor logo
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: _TkC.iconBadge,
                      borderRadius: BorderRadius.circular(2.5.w),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: trek?.vendorLogo?.isNotEmpty == true
                        ? CustomNetworkImage(
                            accessToken: Repository.token,
                            imageUrl: trek?.vendorLogo ?? "",
                            fit: BoxFit.cover,
                            width: 10.w,
                            height: 10.w,
                          )
                        : Center(
                            child: Text(
                              _vendorInitials(),
                              textScaler: const TextScaler.linear(1.0),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(width: 3.w),
                  // Vendor name + verified + rating
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vendor name & verified chip
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                trek?.companyName ?? trek?.vendorName ?? trek?.businessName ?? trek?.vendor ?? '-',
                                textScaler: const TextScaler.linear(1.0),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: FontSize.s12,
                                  fontWeight: FontWeight.w600,
                                  color: _TkC.ink,
                                ),
                              ),
                            ),
                            SizedBox(width: 1.5.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.5.w, vertical: 0.2.h),
                              decoration: BoxDecoration(
                                color: _TkC.verifiedBg,
                                borderRadius: BorderRadius.circular(1.5.w),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded,
                                      size: 3.w,
                                      color: _TkC.verifiedFg),
                                  SizedBox(width: 0.8.w),
                                  Text(
                                    'Verified',
                                    textScaler: const TextScaler.linear(1.0),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: FontSize.s7,
                                      fontWeight: FontWeight.w600,
                                      color: _TkC.verifiedFg,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.3.h),
                        // Rating
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 13, color: Color(0xFFEF9F27)),
                            SizedBox(width: 1.w),
                            Text(
                              '${trek?.rating ?? 0}',
                              textScaler: const TextScaler.linear(1.0),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s10,
                                fontWeight: FontWeight.w500,
                                color: _TkC.inkMid,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // ═══ CTA BADGE — color-only, no icon (icons dropped platform-wide
                  // for consistency; the color set in admin's Badge Master is the
                  // single source of truth, rendered identically here and on vendor) ═══
                  if (trek?.badge != null)
                    _buildPill(
                      text: trek!.badge!.name ?? '',
                      bg: _parseBadgeColor(trek?.badge?.color),
                      fg: CommonColors.blackColor,
                    )
                  else
                    _buildPill(
                      text: 'Best seller',
                      bg: _TkC.badgeBg,
                      fg: _TkC.badgeFg,
                    ),
                ],
              ),

              SizedBox(height: 0.8.h),

              // ═══ Row: Destination / Departure / Duration + Price ═══
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side – headings and values
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Destination
                        _buildInfoItem(
                          'Destination',
                          toLocation ?? fromLocation ?? '',
                        ),
                        // Departure date
                        _buildInfoItem(
                          'Departure Date',
                          "${trek?.batchInfo?.startDate} ${trek?.batchInfo?.startTime}",
                        ),
                        // Duration (Days/Nights)
                        _buildInfoItem(
                          'Duration', trek?.duration ?? '',   // e.g. "2D/1N"
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // Right side: price information + slots below
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Original price + discount pill
                      if (trek?.hasDiscount == true)
                        Row(
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
                            SizedBox(width: 1.5.w),
                            _buildPill(
                              text: trek?.discountText ?? '',
                              bg: _TkC.discBg,
                              fg: _TkC.discFg,
                            ),
                          ],
                        ),
                      if (trek?.hasDiscount == true)
                        SizedBox(height: 0.3.h),
                      // Discounted / actual price
                      Text(
                        trek?.hasDiscount == true
                            ? _calculateDiscountedPrice()
                            : AuthUtils.formatPrice(
                                trek?.price ?? '0.00'),
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s16,
                          fontWeight: FontWeight.w700,
                          color: _TkC.ink,
                        ),
                      ),
                      Text(
                        'per person',
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s8,
                          color: _TkC.inkMid,
                        ),
                      ),

                      // Slots below per person
                      if ((trek?.batchInfo?.availableSlots ?? 0) > 0)
                        Padding(
                          padding: EdgeInsets.only(top: 0.4.h),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 2.w,
                                height: 2.w,
                                decoration: BoxDecoration(
                                  color: _TkC.slotsFg,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                '${trek?.batchInfo?.availableSlots} slots left',
                                textScaler: const TextScaler.linear(1.0),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: FontSize.s9,
                                  fontWeight: FontWeight.w600,
                                  color: _TkC.slotsFg,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 0.8.h),

              // Divider
              Container(height: 0.5, color: _TkC.divider),

              SizedBox(height: 0.5.h),

              // ═══ Bottom row – View itinerary / Share ═══
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: showShare ? onShareTap : onViewItineraryTap,
                    child: showShare
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.share_outlined,
                                  size: 4.w, color: _TkC.brand),
                              SizedBox(width: 1.w),
                              Text(
                                'Share',
                                textScaler:
                                    const TextScaler.linear(1.0),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: FontSize.s11,
                                  fontWeight: FontWeight.w600,
                                  color: _TkC.brand,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View itinerary',
                                textScaler:
                                    const TextScaler.linear(1.0),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: FontSize.s11,
                                  fontWeight: FontWeight.w600,
                                  color: _TkC.brand,
                                ),
                              ),
                              SizedBox(width: 1.w),
                              Icon(Icons.arrow_forward_rounded,
                                  size: 4.w, color: _TkC.brand),
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
  }

  // ─────────────────────────────────────────────
  //  POLICY CHIP (unchanged)
  // ─────────────────────────────────────────────
  Widget _buildPolicyChip(String policy) {
   final isFlexible =
    policy.toLowerCase().contains('flexible');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.35.h),
      decoration: BoxDecoration(
        color: isFlexible ? _TkC.policyFlex : _TkC.policyStd,
        borderRadius: BorderRadius.circular(1.5.w),
        border: Border.all(
          color: (isFlexible ? _TkC.policyFlexFg : _TkC.policyStdFg)
              .withValues(alpha: 0.3),
          width: 1,
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
            color: isFlexible ? _TkC.policyFlexFg : _TkC.policyStdFg,
          ),
          SizedBox(width: 1.w),
          Text(
            policy,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s8,
              fontWeight: FontWeight.w600,
              color: isFlexible ? _TkC.policyFlexFg : _TkC.policyStdFg,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  PILL BADGE (unchanged)
  // ─────────────────────────────────────────────
  Widget _buildPill({
    required String text,
    required Color bg,
    required Color fg,
  }) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(1.5.w),
      ),
      child: Text(
        text,
        textScaler: const TextScaler.linear(1.0),
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s8,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}