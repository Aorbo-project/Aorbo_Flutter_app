import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:sizer/sizer.dart';
import 'common_colors.dart';
import 'screen_constants.dart';
import '../models/coupon_code/coupon_code_model.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _CC {
  static const bg         = CommonColors.whiteColor;
  static const ink        = CommonColors.cFF111827;
  static const inkMid     = CommonColors.cFF6B7280;
  static const inkLight   = CommonColors.grey_AEAEAE;
  static const brand      = CommonColors.lightBlueColor3;   // #4271FF
  static const brandSoft  = Color(0xFFEEF2FF);
  static const teal       = CommonColors.cFF0F7B6C;
  static const tealSoft   = CommonColors.cFFE6F5F3;
  static const amber      = Color(0xFFEF9F27);
  static const amberSoft  = Color(0xFFFAEEDA);
  static const amberText  = Color(0xFF854F0B);
  static const red        = CommonColors.cFFDC2626;
  static const redSoft    = CommonColors.cFFFFE4E4;
  static const divider    = CommonColors.trekroutecolorlight;

  // Strip color per discount type
  static const stripPct   = CommonColors.cFFE6F5F3;   // teal-tint  — percentage
  static const stripFlat  = Color(0xFFEEF2FF);         // blue-tint  — fixed
  static const stripOther = Color(0xFFFAEEDA);         // amber-tint — other
}

// ─────────────────────────────────────────────
//  COUPON CARD
//  Design: Option 2
//  - Narrow left strip with rotated vertical text
//  - Blue code pill + title block
//  - Dashed center divider (custom painter)
//  - Description + T&C inline
//  - Apply / Applied / Disabled button
//  - Expired tag shown when coupon is inactive
//
//  ALL ORIGINAL LOGIC UNTOUCHED
// ─────────────────────────────────────────────
class CouponCard extends StatelessWidget {
  final CouponCardData? coupon;
  final VoidCallback    onApply;
  final bool            isApplied;

  const CouponCard({
    Key? key,
    required this.coupon,
    required this.onApply,
    this.isApplied = false,
  }) : super(key: key);

  // ── Same discount text logic as original ────
  String _sideText() {
    final raw  = coupon?.discountValue ?? '0';
    final val  = double.tryParse(raw)?.toInt() ?? 0;
    final type = coupon?.discountType?.toLowerCase() ?? '';
    if (type == 'percentage') return 'upto $val% off';
    if (type == 'fixed')       return 'flat ₹$val off';
    return '$val off';
  }

  // Strip background by discount type
  Color get _stripColor {
    final type = coupon?.discountType?.toLowerCase() ?? '';
    if (type == 'percentage') return _CC.stripPct;
    if (type == 'fixed')      return _CC.stripFlat;
    return _CC.stripOther;
  }

  Color get _stripTextColor {
    final type = coupon?.discountType?.toLowerCase() ?? '';
    if (type == 'percentage') return _CC.teal;
    if (type == 'fixed')      return _CC.brand;
    return _CC.amberText;
  }

  Color get _pillBg {
    final type = coupon?.discountType?.toLowerCase() ?? '';
    if (type == 'percentage') return _CC.tealSoft;
    if (type == 'fixed')      return _CC.brandSoft;
    return _CC.amberSoft;
  }

  Color get _pillText {
    final type = coupon?.discountType?.toLowerCase() ?? '';
    if (type == 'percentage') return _CC.teal;
    if (type == 'fixed')      return _CC.brand;
    return _CC.amberText;
  }

  bool get _isActive =>
      (coupon?.isActive ?? false) && !(coupon?.isExpired ?? true);

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isActive || isApplied ? 1.0 : 0.65,
      child: Padding(
        padding: EdgeInsets.only(bottom: 2.h, left: 4.w, right: 4.w),
        child: Container(
          decoration: BoxDecoration(
            color: _CC.bg,
            borderRadius: BorderRadius.circular(4.w),
            border: Border.all(
              color: isApplied
                  ? _CC.teal.withOpacity(0.35)
                  : _CC.divider,
              width: isApplied ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: CommonColors.blackColor.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ── LEFT ACCENT STRIP ──────────
                _buildStrip(),

                // ── DASHED NOTCH DIVIDER ───────
                _buildNotchDivider(),

                // ── MAIN BODY ─────────────────
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        3.w, 1.8.h, 3.w, 1.8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // Code pill + Apply button
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // Coupon code pill
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.5.w,
                                        vertical: 0.4.h),
                                    decoration: BoxDecoration(
                                      color: _pillBg,
                                      borderRadius:
                                          BorderRadius.circular(
                                              1.5.w),
                                      border: Border.all(
                                        color: _pillText
                                            .withOpacity(0.25),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      coupon?.code ?? '',
                                      textScaler:
                                          const TextScaler.linear(
                                              1.0),
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: FontSize.s11,
                                        fontWeight: FontWeight.w800,
                                        color: _pillText,
                                        letterSpacing: 3,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 0.6.h),
                                  // Title
                                  Text(
                                    coupon?.title ?? '',
                                    textScaler:
                                        const TextScaler.linear(
                                            1.0),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: FontSize.s10,
                                      fontWeight: FontWeight.w500,
                                      color: _CC.ink,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 2.w),
                            // Apply / Applied / Disabled
                            _buildApplyButton(),
                          ],
                        ),

                        SizedBox(height: 1.2.h),

                        // Dashed horizontal rule
                        CustomPaint(
                          painter: DottedLinePainter(),
                          size: Size(double.infinity, 1),
                        ),

                        SizedBox(height: 1.h),

                        // Description + T&C
                        RichText(
                          textScaler:
                              const TextScaler.linear(1.0),
                          text: TextSpan(
                            text:
                                '${coupon?.description ?? ''} ',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s9,
                              color: _CC.inkMid,
                              height: 1.5,
                            ),
                            children: [
                              if (coupon?.termsAndConditions
                                      ?.isNotEmpty ==
                                  true)
                                TextSpan(
                                  text: 'T&C',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: FontSize.s9,
                                    fontWeight: FontWeight.w600,
                                    color: _CC.brand,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () =>
                                            _showTermsSheet(
                                                context),
                                ),
                            ],
                          ),
                        ),

                        // Expired tag
                        if (!_isActive && !isApplied) ...[
                          SizedBox(height: 0.8.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.25.h),
                            decoration: BoxDecoration(
                              color: _CC.redSoft,
                              borderRadius:
                                  BorderRadius.circular(1.w),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timer_off_outlined,
                                    size: 3.w,
                                    color: _CC.red),
                                SizedBox(width: 1.w),
                                Text(
                                  coupon?.isExpired == true
                                      ? 'Coupon expired'
                                      : 'Coupon inactive',
                                  textScaler:
                                      const TextScaler.linear(
                                          1.0),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: FontSize.s8,
                                    fontWeight: FontWeight.w600,
                                    color: _CC.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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

  // ─────────────────────────────────────────────
  //  LEFT STRIP — rotated discount text
  // ─────────────────────────────────────────────
  Widget _buildStrip() {
    final parts = _sideText().split(' ');

    return Container(
      width: 13.w,
      decoration: BoxDecoration(
        color: _stripColor,
        borderRadius: BorderRadius.only(
          topLeft:    Radius.circular(4.w),
          bottomLeft: Radius.circular(4.w),
        ),
      ),
      child: Center(
        child: RotatedBox(
          quarterTurns: 3,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildStripText(parts),
          ),
        ),
      ),
    );
  }

  // ── Same split-text logic as original ───────
  List<Widget> _buildStripText(List<String> parts) {
    final smStyle = TextStyle(
      fontFamily: 'Poppins',
      fontSize: FontSize.s9,
      fontWeight: FontWeight.w500,
      color: _stripTextColor,
    );
    final lgStyle = TextStyle(
      fontFamily: 'Poppins',
      fontSize: FontSize.s13,
      fontWeight: FontWeight.w800,
      color: _stripTextColor,
    );

    if (parts.length >= 3 &&
        (parts[0].toLowerCase() == 'flat' ||
            parts[0].toLowerCase() == 'upto')) {
      return [
        Text(parts[0], style: smStyle),
        SizedBox(width: 1.w),
        Text(parts[1], style: lgStyle),
        SizedBox(width: 0.5.w),
        Text(parts[2], style: smStyle),
      ];
    }
    return [Text(parts.join(' '), style: smStyle)];
  }

  // ─────────────────────────────────────────────
  //  NOTCH DIVIDER — dashed vertical line with
  //  two half-circles cut out top and bottom
  // ─────────────────────────────────────────────
  Widget _buildNotchDivider() {
    return SizedBox(
      width: 3.w,
      child: CustomPaint(
        painter: _NotchDividerPainter(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  APPLY BUTTON
  // ─────────────────────────────────────────────
  Widget _buildApplyButton() {
    final Color bg;
    final Color fg;
    final String label;

    if (isApplied) {
      bg    = _CC.tealSoft;
      fg    = _CC.teal;
      label = 'Applied ✓';
    } else if (_isActive) {
      bg    = _CC.brand;
      fg    = Colors.white;
      label = 'Apply';
    } else {
      bg    = const Color(0xFFF3F4F6);
      fg    = _CC.inkLight;
      label = 'Apply';
    }

    return GestureDetector(
      onTap: _isActive && !isApplied ? onApply : null,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 3.w, vertical: 0.7.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: Text(
          label,
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s9,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  TERMS BOTTOM SHEET — same as original
  // ─────────────────────────────────────────────
  void _showTermsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: _CC.bg,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(5.w)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 10.w,
                height: 4,
                decoration: BoxDecoration(
                  color: _CC.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              coupon?.code ?? '',
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s16,
                fontWeight: FontWeight.w800,
                color: _pillText,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Terms & Conditions',
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s13,
                fontWeight: FontWeight.w700,
                color: _CC.ink,
              ),
            ),
            SizedBox(height: 1.5.h),
            ...coupon?.termsAndConditions?.map(
                  (term) => Padding(
                    padding: EdgeInsets.only(bottom: 1.2.h),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: _pillText,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            term,
                            textScaler:
                                const TextScaler.linear(1.0),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s10,
                              color: _CC.inkMid,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).toList() ??
                [],
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  NOTCH DIVIDER PAINTER
//  Dashed vertical line + semi-circle cutouts
//  at top and bottom
// ─────────────────────────────────────────────
class _NotchDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const r = 6.0; // notch radius
    final paint = Paint()
      ..color = const Color(0xFFD9D9D9)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;

    // Dashed vertical line between the two notches
    double y = r;
    const dash = 4.0, gap = 3.0;
    while (y < size.height - r) {
      canvas.drawLine(
        Offset(cx, y),
        Offset(cx, (y + dash).clamp(0.0, size.height - r)),
        paint,
      );
      y += dash + gap;
    }

    // Top notch — bottom half-circle (notch points into card)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, 0), radius: r),
      0,
      3.14159,
      false,
      paint,
    );

    // Bottom notch — top half-circle
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, size.height), radius: r),
      3.14159,
      3.14159,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_NotchDividerPainter _) => false;
}

// ─────────────────────────────────────────────
//  DOTTED LINE PAINTER — horizontal rule
//  Same as original, kept for compatibility
// ─────────────────────────────────────────────
class DottedLinePainter extends CustomPainter {
  final bool isHorizontal;

  const DottedLinePainter({this.isHorizontal = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD9D9D9)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    if (isHorizontal) {
      double x = 0;
      const dash = 5.0, gap = 4.0;
      while (x < size.width) {
        canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
        x += dash + gap;
      }
    } else {
      double y = 0;
      const dash = 5.0, gap = 4.0;
      while (y < size.height) {
        canvas.drawLine(Offset(0, y), Offset(0, y + dash), paint);
        y += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter _) => false;
}