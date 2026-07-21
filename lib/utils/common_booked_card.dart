import 'dart:math' as math;
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../freezed_models/booking/booking_history_model.dart';
import 'common_colors.dart';
import 'ist_date_utils.dart';
import 'screen_constants.dart';
import 'package:arobo_app/repository/repository.dart';

// ─────────────────────────────────────────────
// DESIGN TOKENS — refined for white scaffold
// ─────────────────────────────────────────────
class _BC {
  // Pure white card + visible border/shadow so it pops on a white scaffold
  static const bg = Colors.white;
  static const cardBorder = Color(0xFFDDE3EC);
  static const ink = Color(0xFF0F172A);
  static const inkMid = Color(0xFF64748B);
  static const inkLight = Color(0xFF94A3B8);
  static const iconBadge = Color(0xFF1E293B);
  // Brand accents
  static const brand = Color(0xFF3B82F6);
  static const brandSoft = Color(0xFFDBEAFE);
  static const divider = Color(0xFFE2E8F0);
  // Status palette — more saturated for contrast on white
  static const upcoming = Color(0xFF2563EB);
  static const completed = Color(0xFF059669);
  static const ongoing = Color(0xFF0891B2);
  static const cancelled = Color(0xFFDC2626);
  static const warning = Color(0xFFF59E0B);
  // Rating
  static const ratingBg = Color(0xFFFFFBEB);
  static const ratingBorder = Color(0xFFFDE68A);
}

class CommonBookedCard extends StatelessWidget {
  final BookingHistoryData booking;
  final VoidCallback? onViewDetailsTap;
  final VoidCallback? onRateTrekTap;
  const CommonBookedCard({
    super.key,
    required this.booking,
    this.onViewDetailsTap,
    this.onRateTrekTap,
  });
  static const double _stubHeight = 50;
  double _rw(double pct, double max) => math.min(pct.w, max);
  double _rh(double pct, double max) => math.min(pct.h, max);
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return _BC.upcoming;
      case 'completed':
        return _BC.completed;
      case 'ongoing':
        return _BC.ongoing;
      case 'cancelled':
        return _BC.cancelled;
      default:
        return _BC.inkLight;
    }
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    final dt = ISTDateUtils.toIST(rawDate);
    if (dt == null) return rawDate;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Widget _badge(
    String text,
    Color color, {
    bool filled = false,
    bool small = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? _rw(1.5, 8) : _rw(2, 11),
        vertical: small ? _rh(0.25, 3) : _rh(0.35, 4.5),
      ),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
        border: filled
            ? null
            : Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text.toUpperCase(),
        textScaler: const TextScaler.linear(1),
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s8,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: filled ? Colors.white : color,
        ),
      ),
    );
  }

  Widget _endpoint(String label, String value, CrossAxisAlignment align) {
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          textScaler: const TextScaler.linear(1),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s7,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: _BC.inkLight,
            height: 1,
          ),
        ),
        SizedBox(height: _rh(0.3, 3.5)),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textScaler: const TextScaler.linear(1),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s11,
            fontWeight: FontWeight.w700,
            color: _BC.ink,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);
    final String bookingId = booking.bookingNumber ?? '#${booking.id ?? '-'}';
    final String trekStatusRaw = booking.trekStatus ?? '';
    final String paymentStatusRaw = booking.paymentStatus ?? '';
    final String bookingDate = _formatDate(booking.bookingDate);
    final bool isCompleted = trekStatusRaw.toLowerCase() == 'completed';
    final bool ratingGiven = booking.ratingGiven ?? false;
    final bool showRateHint = isCompleted && !ratingGiven;
    final String title = booking.trek?.title ?? '-';
    final String? durationDays = booking.trek?.durationDays?.toString();
    final String? durationNights = booking.trek?.durationNights?.toString();
    String durationStr = '-';
    if (durationDays != null || durationNights != null) {
      durationStr = '${durationDays ?? '0'}D / ${durationNights ?? '0'}N';
    } else if (booking.trek?.duration != null &&
        booking.trek!.duration!.isNotEmpty) {
      durationStr = booking.trek!.duration!;
    }
    final String difficulty = booking.trek?.difficulty ?? '';
    final String startDateStr = _formatDate(booking.batch?.startDate);
    final String startTimeStr = booking.batch?.startTime ?? '';
    final String startDateTime = startTimeStr.isNotEmpty
        ? '$startDateStr · $startTimeStr'
        : startDateStr;
    final String vendorName =
        booking.trek?.vendor?.businessName ?? 'Unknown Vendor';
    final String vendorLogo = booking.trek?.vendor?.businessLogo ?? '';
    final String destinationName = booking.trek?.destination?.name ?? '';
    final Color statusColor = _statusColor(trekStatusRaw);
    final String statusLabel = trekStatusRaw.isNotEmpty
        ? trekStatusRaw[0].toUpperCase() + trekStatusRaw.substring(1)
        : '';
    final bool isPartial =
        paymentStatusRaw.toLowerCase().contains('partial') ||
        paymentStatusRaw.toLowerCase().contains('advance');
    final double logoSize = _rw(9.5, 42);
    final double cornerRadius = _rw(4.5, 20);
    return GestureDetector(
      onTap: onViewDetailsTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _rw(1, 16),
          vertical: _rh(0.7, 8),
        ),
        child: PhysicalShape(
          clipper: _TicketClipper(
            cornerRadius: cornerRadius,
            notchRadius: 9,
            notchFromBottom: _stubHeight,
          ),
          color: _BC.bg,
          elevation: 5,
          shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.22),
          child: CustomPaint(
            // Strokes a 1px border along the exact ticket outline
            // (including the side notches) so the shape reads on white.
            foregroundPainter: _TicketBorderPainter(
              cornerRadius: cornerRadius,
              notchRadius: 9,
              notchFromBottom: _stubHeight,
              color: _BC.cardBorder,
            ),
            child: Stack(
              children: [
                // ── watermark ──
                Positioned(
                  top: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(cornerRadius),
                    ),
                    child: Transform.rotate(
                      angle: -0.12,
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.terrain_rounded,
                        size: 110,
                        color: statusColor.withValues(alpha: 0.035),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        _rw(4.2, 20),
                        _rh(1.5, 16),
                        _rw(4.2, 20),
                        _rh(1, 11),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── header ──
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: logoSize,
                                height: logoSize,
                                decoration: BoxDecoration(
                                  color: _BC.iconBadge,
                                  borderRadius: BorderRadius.circular(
                                    _rw(2.6, 12),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _BC.iconBadge.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
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
                                          _initials(vendorName),
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: FontSize.s10,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                              ),
                              SizedBox(width: _rw(2.8, 13)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ORGANISED BY',
                                      textScaler: const TextScaler.linear(1),
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: FontSize.s7,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                        color: _BC.inkLight,
                                        height: 1,
                                      ),
                                    ),
                                    SizedBox(height: _rh(0.25, 3)),
                                    Text(
                                      vendorName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: FontSize.s10,
                                        fontWeight: FontWeight.w600,
                                        color: _BC.ink,
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isPartial) ...[
                                    _badge('Partial', _BC.warning),
                                    SizedBox(height: _rh(0.35, 4)),
                                  ],
                                  if (statusLabel.isNotEmpty)
                                    _badge(
                                      statusLabel,
                                      statusColor,
                                      filled: true,
                                    ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: _rh(1.1, 12)),
                          // ── title + destination ──
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textScaler: const TextScaler.linear(1),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s13,
                              fontWeight: FontWeight.w800,
                              color: _BC.ink,
                              height: 1.15,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (destinationName.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: _rh(0.35, 4.5)),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: _rw(3.1, 14),
                                    color: _BC.brand,
                                  ),
                                  SizedBox(width: _rw(0.9, 4.5)),
                                  Expanded(
                                    child: Text(
                                      destinationName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: FontSize.s9,
                                        color: _BC.inkMid,
                                        height: 1.25,
                                      ),
                                    ),
                                  ),
                                  if (difficulty.isNotEmpty &&
                                      difficulty != '-')
                                    _badge(difficulty, _BC.brand, small: true),
                                ],
                              ),
                            ),
                          SizedBox(height: _rh(1.2, 13)),
                          // ── journey row ──
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: _rh(0.85, 9),
                              horizontal: _rw(2.4, 12),
                            ),
                            decoration: BoxDecoration(
                              color: _BC.divider.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(_rw(2.7, 12)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _endpoint(
                                  'Starts',
                                  startDateTime,
                                  CrossAxisAlignment.start,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: _rw(2.5, 12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.terrain_rounded,
                                          size: _rw(4.4, 19),
                                          color: statusColor.withValues(
                                            alpha: 0.6,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 7,
                                          child: CustomPaint(
                                            size: const Size(
                                              double.infinity,
                                              7,
                                            ),
                                            painter: _DottedTrailPainter(
                                              color: statusColor.withValues(
                                                alpha: 0.35,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                _endpoint(
                                  'Duration',
                                  durationStr,
                                  CrossAxisAlignment.end,
                                ),
                              ],
                            ),
                          ),
                          // ── rate hint ──
                          if (showRateHint) ...[
                            SizedBox(height: _rh(1, 10)),
                            GestureDetector(
                              onTap: onRateTrekTap,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: _rw(3.2, 15),
                                  vertical: _rh(0.75, 8),
                                ),
                                decoration: BoxDecoration(
                                  color: _BC.ratingBg,
                                  borderRadius: BorderRadius.circular(
                                    _rw(2.4, 11),
                                  ),
                                  border: Border.all(color: _BC.ratingBorder),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: _BC.warning,
                                      size: _rw(4.4, 20),
                                    ),
                                    SizedBox(width: _rw(2.2, 10)),
                                    Expanded(
                                      child: Text(
                                        'How was your trek? Tap to rate',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: FontSize.s9,
                                          fontWeight: FontWeight.w600,
                                          color: _BC.ink,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: _rw(2.8, 13),
                                        vertical: _rh(0.45, 5.5),
                                      ),
                                      decoration: BoxDecoration(
                                        color: _BC.warning,
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      child: Text(
                                        'Rate',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: FontSize.s8,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // ── tear-off stub ──
                    SizedBox(
                      height: _stubHeight,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: _rw(4, 20),
                            ),
                            child: CustomPaint(
                              size: const Size(double.infinity, 1),
                              painter: _DashedLinePainter(color: _BC.divider),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: _rw(4.2, 20),
                              ),
                              child: Row(
                                children: [
                                  CustomPaint(
                                    size: const Size(54, 22),
                                    painter: _BarcodePainter(
                                      seed: bookingId.hashCode,
                                      color: _BC.ink.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  SizedBox(width: _rw(2.2, 11)),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          bookingId,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textScaler: const TextScaler.linear(
                                            1,
                                          ),
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: FontSize.s10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.6,
                                            color: _BC.ink,
                                            height: 1.2,
                                          ),
                                        ),
                                        Text(
                                          'Booked $bookingDate',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textScaler: const TextScaler.linear(
                                            1,
                                          ),
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: FontSize.s8,
                                            color: _BC.inkLight,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Details',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: FontSize.s9,
                                          fontWeight: FontWeight.w600,
                                          color: _BC.brand,
                                        ),
                                      ),
                                      SizedBox(width: _rw(0.8, 4)),
                                      Container(
                                        padding: EdgeInsets.all(_rw(0.8, 4)),
                                        decoration: const BoxDecoration(
                                          color: _BC.brandSoft,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_rounded,
                                          size: _rw(3.2, 14),
                                          color: _BC.brand,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED TICKET PATH — used by clipper + border
// ─────────────────────────────────────────────
Path _buildTicketPath(
  Size size, {
  required double cornerRadius,
  required double notchRadius,
  required double notchFromBottom,
}) {
  final double notchY = size.height - notchFromBottom;
  final ticket = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(cornerRadius),
      ),
    );
  final notches = Path()
    ..addOval(Rect.fromCircle(center: Offset(0, notchY), radius: notchRadius))
    ..addOval(
      Rect.fromCircle(center: Offset(size.width, notchY), radius: notchRadius),
    );
  return Path.combine(PathOperation.difference, ticket, notches);
}

// ─────────────────────────────────────────────
// TICKET CLIPPER
// ─────────────────────────────────────────────
class _TicketClipper extends CustomClipper<Path> {
  final double cornerRadius;
  final double notchRadius;
  final double notchFromBottom;
  const _TicketClipper({
    required this.cornerRadius,
    required this.notchRadius,
    required this.notchFromBottom,
  });
  @override
  Path getClip(Size size) => _buildTicketPath(
    size,
    cornerRadius: cornerRadius,
    notchRadius: notchRadius,
    notchFromBottom: notchFromBottom,
  );
  @override
  bool shouldReclip(_TicketClipper old) =>
      old.cornerRadius != cornerRadius ||
      old.notchRadius != notchRadius ||
      old.notchFromBottom != notchFromBottom;
}

// ─────────────────────────────────────────────
// TICKET BORDER — outlines the shape on white
// ─────────────────────────────────────────────
class _TicketBorderPainter extends CustomPainter {
  final double cornerRadius;
  final double notchRadius;
  final double notchFromBottom;
  final Color color;
  const _TicketBorderPainter({
    required this.cornerRadius,
    required this.notchRadius,
    required this.notchFromBottom,
    required this.color,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(
      _buildTicketPath(
        size,
        cornerRadius: cornerRadius,
        notchRadius: notchRadius,
        notchFromBottom: notchFromBottom,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_TicketBorderPainter old) =>
      old.cornerRadius != cornerRadius ||
      old.notchRadius != notchRadius ||
      old.notchFromBottom != notchFromBottom ||
      old.color != color;
}

// ─────────────────────────────────────────────
// DASHED PERFORATION
// ─────────────────────────────────────────────
class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;
    const dash = 5.0, gap = 3.5;
    double x = 14;
    while (x < size.width - 14) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(math.min(x + dash, size.width - 14), 0),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

// ─────────────────────────────────────────────
// DOTTED TRAIL
// ─────────────────────────────────────────────
class _DottedTrailPainter extends CustomPainter {
  final Color color;
  const _DottedTrailPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const double r = 1.2, gap = 6;
    final double y = size.height / 2;
    for (double x = r; x <= size.width - r; x += gap) {
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_DottedTrailPainter old) => old.color != color;
}

// ─────────────────────────────────────────────
// BARCODE
// ─────────────────────────────────────────────
class _BarcodePainter extends CustomPainter {
  final int seed;
  final Color color;
  const _BarcodePainter({required this.seed, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    final paint = Paint()..color = color;
    double x = 0;
    while (x < size.width) {
      final double w = 0.8 + rnd.nextDouble() * 2.2;
      final double h = rnd.nextBool()
          ? size.height
          : size.height * (0.6 + rnd.nextDouble() * 0.4);
      canvas.drawRect(Rect.fromLTWH(x, size.height - h, w, h), paint);
      x += w + 0.8 + rnd.nextDouble() * 1.8;
    }
  }

  @override
  bool shouldRepaint(_BarcodePainter old) =>
      old.seed != seed || old.color != color;
}
