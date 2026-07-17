import 'dart:convert';
import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import 'package:dotted_line/dotted_line.dart';

import '../freezed_models/booking/booking_history_model.dart';
import '../models/dispute/dispute_detail_modal.dart';
import '../models/refund/refund_status_model.dart';
import '../controller/dashboard_controller.dart';
import '../utils/common_colors.dart';
import '../utils/custom_snackbar.dart';
import '../services/invoice_pdf_service.dart';
import '../utils/ist_date_utils.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _TC {
  static const bg = Color(0xFFF4F7FF);
  static const cardBg = Color(0xFFFFFFFF);
  static const ink = Color(0xFF0F172A);
  static const inkMid = Color(0xFF64748B);
  static const inkLight = Color(0xFF94A3B8);
  static const accent = Color(0xFF111827);
  static const brand = Color(0xFF4271FF);
  static const brandLight = Color(0xFFEEF2FF);
  static const teal = Color(0xFF0F7B6C);
  static const tealLight = Color(0xFFE6F5F3);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x0A000000);
  static const gold = Color(0xFFFFB800);
  static const goldDark = Color(0xFFE89B00);

  static const red = Color(0xFFDC2626);
  static const redLight = Color(0xFFFFE4E4);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3C7);
}

// ─────────────────────────────────────────────
//  TICKET CLIPPER
// ─────────────────────────────────────────────
class TicketClipper extends CustomClipper<Path> {
  final double cutoutOffset;
  TicketClipper(this.cutoutOffset);

  @override
  Path getClip(Size size) {
    double radius = 2.w;
    double circleRadius = 5.w;
    double vertPos = cutoutOffset;

    Path base = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    Path cutouts = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(0, vertPos), radius: circleRadius),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width, vertPos),
          radius: circleRadius,
        ),
      );

    return Path.combine(PathOperation.difference, base, cutouts);
  }

  @override
  bool shouldReclip(TicketClipper old) => old.cutoutOffset != cutoutOffset;
}

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────
class BookingsUpcomingScreen extends StatefulWidget {
  final dynamic bookingId;
  const BookingsUpcomingScreen({super.key, required this.bookingId});

  @override
  State<BookingsUpcomingScreen> createState() => _BookingsUpcomingScreenState();
}

class _BookingsUpcomingScreenState extends State<BookingsUpcomingScreen>
    with TickerProviderStateMixin {
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final TrekController _trekC = Get.find<TrekController>();
  late AnimationController _animationController;

  late AnimationController _ratingPanelController;
  late Animation<double> _ratingPanelAnim;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  late AnimationController _shimmerController;
  late AnimationController _borderRotationController;

  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  bool _ratingPanelVisible = false;
  final bool _ratingDismissed = false;
  bool _isFabPressed = false;

  Set<int> openSections = {0};

  final GlobalKey _dottedKey = GlobalKey();
  final GlobalKey _cardKey = GlobalKey();
  double cutoutOffset = 0;

  bool _refundPollingStarted = false;
  Worker? _bookingDetailWorker;

  Future<void> _handleTicketDownload(BookingHistoryData? booking) async {
    if (booking == null) {
      CustomSnackBar.show(context, message: 'Booking details not available');
      return;
    }

    final policyType = booking.cancellationPolicyType?.toString();

    Get.dialog(
      Center(
        child: Container(
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _TC.brand),
              SizedBox(height: 2.h),
              Text(
                'Generating ticket...',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.sp,
                  color: _TC.ink,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      await InvoicePdfService.previewInvoice(
        booking: booking,
        policyType: policyType,
      );
      if (Get.isDialogOpen ?? false) Get.back();
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: 'Failed to generate ticket. Please try again.',
      );
    }
  }

  Future<void> _handleShare(BookingHistoryData? booking) async {
    if (booking == null) {
      CustomSnackBar.show(context, message: 'Booking details not available');
      return;
    }

    final trek = booking.trek;
    final batch = booking.batch;
    final startDate = ISTDateUtils.toIST(batch?.startDate);
    final endDate = ISTDateUtils.toIST(batch?.endDate);

    // Using source_city_name from backend
    // sourceCityName is null only for bookings made before boarding-city
    // selection was recorded (see Booking.city_id) — falling back to the
    // vendor's registered city here previously showed a specific but
    // essentially random city as if it were fact. Showing it as genuinely
    // unrecorded is honest; a confident wrong answer is worse than "unknown"
    // for a trip-critical detail like this.
    final String sourceCity = booking.sourceCityName ?? 'Not available';
    final String destinationName =
        trek?.destinationName ?? trek?.title ?? 'N/A';

    final StringBuffer sb = StringBuffer();
    sb.writeln('🏔️  ${trek?.title ?? 'Trek Booking'}');
    sb.writeln('━━━━━━━━━━━━━━━━━━━');
    sb.writeln('Booking ID       : ${booking.bookingNumber ?? 'N/A'}');
    sb.writeln('TBR ID           : ${batch?.tbrId ?? 'N/A'}');
    if (startDate != null) {
      sb.writeln(
        'Departure        : ${DateFormat('E, dd MMM yyyy').format(startDate)}',
      );
      sb.writeln('Departure City   : $sourceCity');
    }
    if (endDate != null) {
      sb.writeln(
        'Arrival          : ${DateFormat('E, dd MMM yyyy').format(endDate)}',
      );
      sb.writeln('Arrival City     : $sourceCity');
    }
    sb.writeln('Duration         : ${trek?.duration ?? '-'}');
    sb.writeln('Travellers       : ${booking.totalTravelers ?? 1}');
    sb.writeln('Operator         : ${trek?.vendor?.businessName ?? 'N/A'}');
    sb.writeln('Source City      : $sourceCity');
    sb.writeln(
      'Boarding Point   : ${trek?.boardingPoint ?? 'To be announced'}',
    );
    if (trek?.boardingTime != null) {
      sb.writeln('Boarding Time    : ${trek!.boardingTime}');
    }
    sb.writeln('Destination      : $destinationName');
    sb.writeln('━━━━━━━━━━━━━━━━━━━');
    sb.writeln('Booking confirmed with Aorbo! 🎉');
    sb.writeln('Download the app to explore more treks.');

    try {
      await Share.share(
        sb.toString(),
        subject: 'My Trek Booking — ${trek?.title ?? ''}',
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: 'Unable to share at the moment. Please try again.',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _dashboardC.getBookingDetail(bookingId: widget.bookingId ?? '0');

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();

    _ratingPanelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _ratingPanelAnim = CurvedAnimation(
      parent: _ratingPanelController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _borderRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.35, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _bookingDetailWorker = ever(_dashboardC.bookingDetailsObserver, (result) {
      result.maybeWhen(
        success: (r) {
          final booking = (r as BookingDetailsResponseModel).data;
          if (booking?.status == 'cancelled' &&
              booking?.id != null &&
              !_refundPollingStarted) {
            _refundPollingStarted = true;
            _trekC.startRefundPolling(booking!.id!.toString());
          }
        },
        orElse: () {},
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCutoutOffset();
    });
  }

  @override
  void dispose() {
    _trekC.stopRefundPolling();
    _bookingDetailWorker?.dispose();

    _animationController.dispose();
    _ratingPanelController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _borderRotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _updateCutoutOffset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? box =
          _dottedKey.currentContext?.findRenderObject() as RenderBox?;
      final RenderBox? cardBox =
          _cardKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && cardBox != null && mounted) {
        final position = box.localToGlobal(Offset.zero);
        final cardTop = cardBox.localToGlobal(Offset.zero).dy;
        final localOffset = position.dy - cardTop;
        setState(() => cutoutOffset = localOffset + box.size.height / 2);
      }
    });
  }

  void _toggleSection(int index) {
    setState(() {
      if (openSections.contains(index)) {
        openSections.remove(index);
      } else {
        openSections.add(index);
      }
    });
    Future.delayed(
      const Duration(milliseconds: 100),
      () => _updateCutoutOffset(),
    );
  }

  void _showRatingPanel() {
    setState(() => _ratingPanelVisible = true);
    _ratingPanelController.forward();
  }

  void _hideRatingPanel() {
    _ratingPanelController.reverse().then((_) {
      if (mounted) setState(() => _ratingPanelVisible = false);
    });
  }

  List<Color> _getStatusGradient(String? status) {
    switch (status) {
      case 'confirmed':
        return [const Color(0xFF0F7B6C), const Color(0xFF0D9488)];
      case 'completed':
        return [const Color(0xFF4271FF), const Color(0xFF6366F1)];
      case 'cancelled':
        return [const Color(0xFFDC2626), const Color(0xFFEF4444)];
      default:
        return [const Color(0xFFEA580C), const Color(0xFFF97316)];
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status?.toUpperCase() ?? 'PENDING';
    }
  }

  String _getPaymentStatusText(String? status) {
    switch (status) {
      case 'full_paid':
        return 'Fully Paid';
      case 'partial':
        return 'Partially Paid';
      case 'pending':
        return 'Pending';
      default:
        return status ?? 'N/A';
    }
  }

  Widget _sectionHeader(String title, int index) {
    final bool isOpen = openSections.contains(index);
    return InkWell(
      onTap: () => _toggleSection(index),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.6.h),
        child: Row(
          children: [
            Container(
              width: 7.w,
              height: 7.w,
              decoration: BoxDecoration(
                color: _TC.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _sectionIcon(index),
                color: Colors.white,
                size: 3.8.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: _TC.ink,
                ),
              ),
            ),
            AnimatedRotation(
              turns: isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                width: 7.w,
                height: 7.w,
                decoration: BoxDecoration(
                  color: isOpen ? _TC.accent : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 4.5.w,
                  color: isOpen ? Colors.white : _TC.inkMid,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _sectionIcon(int index) {
    switch (index) {
      case 0:
        return Icons.confirmation_number_outlined;
      case 1:
        return Icons.terrain_rounded;
      case 2:
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _ticketRow(String title, String value, {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.9.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9.sp,
                color: _TC.inkMid,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9.sp,
                fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
                color: isHighlight ? _TC.brand : _TC.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _parseFinanceSnapshot(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  String _fmtCurrency(dynamic value) {
    if (value == null) return '₹0';
    if (value is num) {
      final hasDecimal = value != value.roundToDouble();
      return '₹${hasDecimal ? value.toStringAsFixed(2) : value.toInt().toString()}';
    }
    return '₹$value';
  }

  String _capitalize(String? value) {
    if (value == null || value.isEmpty) return 'N/A';
    return value[0].toUpperCase() + value.substring(1);
  }

  Widget _financeGroupHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 1.2.h, bottom: 0.3.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: _TC.accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 8.sp,
            fontWeight: FontWeight.w700,
            color: _TC.accent,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(BookingHistoryData? booking) {
    if (booking == null) return const SizedBox.shrink();

    final trek = booking.trek;
    final batch = booking.batch;
    final startDate = ISTDateUtils.toIST(batch?.startDate);
    final endDate = ISTDateUtils.toIST(batch?.endDate);
    final bookingDate = ISTDateUtils.toIST(booking.bookingDate);

    // Extracting names from the new API response
    // sourceCityName is null only for bookings made before boarding-city
    // selection was recorded (see Booking.city_id) — falling back to the
    // vendor's registered city here previously showed a specific but
    // essentially random city as if it were fact. Showing it as genuinely
    // unrecorded is honest; a confident wrong answer is worse than "unknown"
    // for a trip-critical detail like this.
    final String sourceCity = booking.sourceCityName ?? 'Not available';
    final String destinationName =
        trek?.destinationName ?? trek?.title ?? 'N/A';

    final cardContent = Container(
      key: _cardKey,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 2.5.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getStatusGradient(booking.status),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    trek?.title ?? 'Trek Details',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 1.5.w),
                      Text(
                        _getStatusText(booking.status).toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // DATE ROW
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DEPARTURE',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w600,
                          color: _TC.inkLight,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        startDate != null
                            ? DateFormat('E, dd MMM').format(startDate)
                            : '-',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: _TC.ink,
                        ),
                      ),
                      SizedBox(height: 0.2.h),
                      Text(
                        sourceCity,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8.sp,
                          color: _TC.inkMid,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Icon(Icons.hiking_rounded, size: 5.w, color: _TC.ink),
                      SizedBox(height: 0.5.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          trek?.duration
                                  ?.replaceAll('Days', 'D')
                                  .replaceAll('Nights', 'N') ??
                              '-',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                            color: _TC.inkMid,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'ARRIVAL',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w600,
                          color: _TC.inkLight,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        endDate != null
                            ? DateFormat('E, dd MMM').format(endDate)
                            : '-',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: _TC.ink,
                        ),
                      ),
                      SizedBox(height: 0.2.h),
                      Text(
                        sourceCity,
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8.sp,
                          color: _TC.inkMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: DottedLine(
              key: _dottedKey,
              dashColor: _TC.divider,
              dashLength: 3.5.w,
              dashGapLength: 4.w,
              lineThickness: 1.5,
            ),
          ),

          SizedBox(height: 2.h),

          // SECTIONS
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              children: [
                // Booking Details
                _sectionHeader('Booking Details', 0),
                if (openSections.contains(0)) ...[
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _ticketRow(
                          'TBR ID',
                          batch?.tbrId ?? 'N/A',
                          isHighlight: true,
                        ),
                        _dividerLine(),
                        _ticketRow(
                          'Booking ID',
                          booking.bookingNumber ?? 'N/A',
                        ),
                        _dividerLine(),
                        _ticketRow(
                          'Booking Date',
                          bookingDate != null
                              ? DateFormat('E, d MMM yyyy').format(bookingDate)
                              : 'N/A',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  if (booking.travelers?.isNotEmpty == true) ...[
                    Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 4.w,
                            color: _TC.inkMid,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Traveller Details',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: _TC.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _TC.divider),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: _TC.accent.withValues(alpha: 0.04),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    'Name',
                                    style: _tableHeaderStyle(),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Age',
                                    style: _tableHeaderStyle(),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Gender',
                                    style: _tableHeaderStyle(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...?booking.travelers?.asMap().entries.map((e) {
                            final t = e.value;
                            final isLast =
                                e.key == (booking.travelers!.length - 1);
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                border: isLast
                                    ? null
                                    : const Border(
                                        bottom: BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      t.traveler?.name ?? '-',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w600,
                                        color: _TC.ink,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      t.traveler?.age?.toString() ?? '-',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 9.sp,
                                        color: _TC.inkMid,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      t.traveler?.gender ?? '-',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 9.sp,
                                        color: _TC.inkMid,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                  ],
                ],

                Container(height: 1, color: _TC.divider),

                // Trek Details
                _sectionHeader('Trek Details', 1),
                if (openSections.contains(1)) ...[
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _ticketRow(
                          'Trek Operator',
                          trek?.vendor?.businessName ?? 'N/A',
                        ),
                        _dividerLine(),
                        _ticketRow('Source City', sourceCity),
                        _dividerLine(),
                        _ticketRow(
                          'Boarding Point',
                          trek?.boardingPoint ?? 'To be announced',
                        ),
                        _dividerLine(),
                        _ticketRow(
                          'Boarding Time',
                          trek?.boardingTime ?? 'N/A',
                        ),
                        _dividerLine(),
                        _ticketRow('Destination', destinationName),
                        _dividerLine(),
                        _ticketRow(
                          'Trek Captain',
                          trek?.captainName ?? 'To be announced',
                        ),
                        _dividerLine(),
                        _ticketRow(
                          'Captain Contact',
                          trek?.captainPhone ?? 'Not available',
                        ),
                        _dividerLine(),
                        _ticketRow(
                          'Difficulty',
                          trek?.difficulty ?? 'Moderate',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                ],

                Container(height: 1, color: _TC.divider),

                // Payment Details
                _sectionHeader('Payment Details', 2),
                if (openSections.contains(2)) ...[
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Builder(
                      builder: (context) {
                        final snap = _parseFinanceSnapshot(
                          booking.financeSnapshot,
                        );

                        final travelerCount =
                            snap?['traveler_count'] ??
                            booking.totalTravelers ??
                            1;
                        final origBaseFare =
                            snap?['original_base_fare'] ??
                            booking.totalBasicCost ??
                            '0';
                        final farePerPerson =
                            snap?['original_base_fare_per_person'];
                        final vendorDiscount =
                            snap?['vendor_discount'] ??
                            booking.vendorDiscount ??
                            '0';
                        final couponId = snap?['coupon_id'];
                        final couponDiscount =
                            snap?['coupon_discount'] ??
                            booking.couponDiscount ??
                            '0';
                        final finalBaseFare = snap?['final_base_fare'];
                        final gst5 =
                            snap?['gst_5_percent'] ?? booking.gstAmount ?? '0';
                        final platformFee =
                            snap?['platform_fee'] ??
                            booking.platformFees ??
                            '0';
                        final insuranceFee =
                            snap?['insurance_fee'] ??
                            booking.insuranceAmount ??
                            '0';
                        final cancelProtectFee =
                            snap?['cancellation_protection_fee'] ??
                            booking.freeCancellationAmount ??
                            '0';
                        final finalAmount =
                            snap?['final_amount'] ?? booking.finalAmount ?? '0';
                        final cancelPolicy =
                            snap?['cancellation_policy_type'] ??
                            booking.cancellationPolicyType ??
                            'standard';
                        final advanceAmt =
                            snap?['advance_amount'] ??
                            booking.advanceAmount ??
                            '0';
                        final remainingAmt =
                            snap?['remaining_amount'] ??
                            booking.remainingAmount ??
                            '0';
                        final amountPaidNow = snap?['amount_paid_now'];
                        final paymentMethod =
                            snap?['payment_method'] ??
                            booking.paymentMethod ??
                            'N/A';

                        final bool isFlexible =
                            cancelPolicy?.toString().toLowerCase() ==
                            'flexible';
                        final bool isFullPaid =
                            booking.paymentStatus == 'full_paid';
                        final bool showAdvanceAndRemaining =
                            !(isFlexible && isFullPaid) && !(!isFlexible);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _financeGroupHeader('Base Fare Calculation'),
                            _ticketRow('Traveler Count', '$travelerCount'),
                            _dividerLine(),
                            _ticketRow(
                              'Original Base Fare',
                              _fmtCurrency(origBaseFare),
                            ),
                            if (farePerPerson != null) ...[
                              _dividerLine(),
                              _ticketRow(
                                'Base Fare / Person',
                                _fmtCurrency(farePerPerson),
                              ),
                            ],
                            _dividerLine(),
                            _ticketRow(
                              'Vendor Discount',
                              '-${_fmtCurrency(vendorDiscount)}',
                            ),
                            if (couponId != null) ...[
                              _dividerLine(),
                              _ticketRow('Coupon ID', '$couponId'),
                            ],
                            if ((couponDiscount is num &&
                                    couponDiscount != 0) ||
                                (couponDiscount is String &&
                                    couponDiscount != '0')) ...[
                              _dividerLine(),
                              _ticketRow(
                                'Coupon Discount',
                                '-${_fmtCurrency(couponDiscount)}',
                              ),
                            ],
                            _dividerLine(),
                            _ticketRow(
                              'Final Base Fare',
                              _fmtCurrency(finalBaseFare),
                              isHighlight: true,
                            ),

                            _financeGroupHeader('Taxes & Fees'),
                            _ticketRow('GST (5%)', _fmtCurrency(gst5)),
                            _dividerLine(),
                            _ticketRow(
                              'Platform Fee',
                              _fmtCurrency(platformFee),
                            ),
                            if ((insuranceFee is num && insuranceFee != 0) ||
                                (insuranceFee is String &&
                                    insuranceFee != '0' &&
                                    insuranceFee != '0.00')) ...[
                              _dividerLine(),
                              _ticketRow(
                                'Insurance Fee',
                                _fmtCurrency(insuranceFee),
                              ),
                            ],
                            if ((cancelProtectFee is num &&
                                    cancelProtectFee != 0) ||
                                (cancelProtectFee is String &&
                                    cancelProtectFee != '0' &&
                                    cancelProtectFee != '0.00')) ...[
                              _dividerLine(),
                              _ticketRow(
                                'Cancellation Protection Fee',
                                _fmtCurrency(cancelProtectFee),
                              ),
                            ],

                            _financeGroupHeader('Payment Summary'),
                            _ticketRow(
                              'Final Amount',
                              _fmtCurrency(finalAmount),
                              isHighlight: true,
                            ),
                            _dividerLine(),
                            _ticketRow(
                              'Cancellation Policy',
                              _capitalize(cancelPolicy.toString()),
                            ),
                            if (showAdvanceAndRemaining) ...[
                              _dividerLine(),
                              _ticketRow(
                                'Advance Amount',
                                _fmtCurrency(advanceAmt),
                              ),
                              if (amountPaidNow != null) ...[
                                _dividerLine(),
                                _ticketRow(
                                  'Amount Paid Now',
                                  _fmtCurrency(amountPaidNow),
                                  isHighlight: true,
                                ),
                              ],
                              _dividerLine(),
                              _ticketRow(
                                'Remaining Amount',
                                _fmtCurrency(remainingAmt),
                                isHighlight: booking.paymentStatus == 'partial',
                              ),
                            ],
                            _dividerLine(),
                            _ticketRow(
                              'Payment Method',
                              _capitalize(paymentMethod),
                            ),
                            _dividerLine(),
                            _ticketRow(
                              'Payment Status',
                              _getPaymentStatusText(booking.paymentStatus),
                              isHighlight: true,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                ],
              ],
            ),
          ),

          SizedBox(height: 1.5.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: DottedLine(
              dashColor: _TC.divider,
              dashLength: 3.5.w,
              dashGapLength: 4.w,
              lineThickness: 1.5,
            ),
          ),

          SizedBox(height: 2.5.h),

          // FOOTER
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 3.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    '"Not Insta-perfect.\nBut soul-perfect...!!"',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: _TC.inkLight,
                      height: 1.5,
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/img/aorbologo.png',
                  width: 22.w,
                  height: 4.h,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => FadeTransition(
        opacity: _animationController,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOutCubic,
                ),
              ),
          child: PhysicalShape(
            clipper: TicketClipper(cutoutOffset),
            elevation: 15,
            color: Colors.transparent,
            shadowColor: Colors.black.withValues(alpha: 0.15),
            child: ClipPath(
              clipper: TicketClipper(cutoutOffset),
              child: cardContent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dividerLine() => Container(
    height: 1,
    margin: EdgeInsets.symmetric(vertical: 0.3.h),
    color: _TC.divider,
  );

  TextStyle _tableHeaderStyle() => TextStyle(
    fontFamily: 'Poppins',
    fontSize: 8.sp,
    fontWeight: FontWeight.w600,
    color: _TC.inkMid,
    letterSpacing: 0.4,
  );

  Widget _buildActionButton(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _TC.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: _TC.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 5.w, color: Colors.white),
            ),
            SizedBox(height: 0.8.h),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: _TC.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefundTrackerCard(BookingHistoryData booking) {
    return Obx(() {
      final result = _trekC.refundStatusObserver.value;
      RefundStatusData? statusData;
      result.maybeWhen(success: (m) => statusData = m?.data, orElse: () {});
      final isPolling = result.maybeWhen(
        loading: (_) => true,
        orElse: () => false,
      );

      final bool isProcessed = statusData?.isProcessed ?? false;
      final bool isFailed = statusData?.isFailed ?? false;

      String statusText;
      String statusSubText;
      Color statusColor;
      Color statusBg;
      IconData statusIcon;

      if (isFailed) {
        statusText = 'Refund Failed';
        statusSubText =
            statusData?.refundFailureReason ??
            'Please contact support for help.';
        statusColor = _TC.red;
        statusBg = _TC.redLight;
        statusIcon = Icons.error_outline_rounded;
      } else if (isProcessed) {
        statusText = 'Refund Credited';
        statusSubText =
            statusData?.statusMessage ??
            'Your refund has been credited to your account.';
        statusColor = _TC.teal;
        statusBg = _TC.tealLight;
        statusIcon = Icons.check_circle_rounded;
      } else if (statusData?.refundStatus == 'processing' ||
          statusData?.refundStatus == 'initiated') {
        statusText = 'Refund Processing';
        statusSubText =
            statusData?.statusMessage ?? 'Your bank is processing the refund.';
        statusColor = _TC.brand;
        statusBg = _TC.brandLight;
        statusIcon = Icons.sync_rounded;
      } else {
        statusText = isPolling ? 'Checking Refund Status...' : 'Refund Pending';
        statusSubText = 'We are checking your refund status.';
        statusColor = _TC.inkMid;
        statusBg = const Color(0xFFF1F5F9);
        statusIcon = Icons.hourglass_top_rounded;
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: _TC.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFailed
                ? _TC.red.withValues(alpha: 0.25)
                : isProcessed
                ? _TC.teal.withValues(alpha: 0.25)
                : _TC.divider,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 9.w,
                  height: 9.w,
                  decoration: BoxDecoration(
                    color: _TC.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                    size: 4.5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Refund Tracker',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: _TC.ink,
                    ),
                  ),
                ),
                if (isPolling && !isProcessed && !isFailed)
                  SizedBox(
                    width: 4.w,
                    height: 4.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _TC.brand,
                    ),
                  ),
                if (isProcessed)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.5.w,
                      vertical: 0.4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _TC.tealLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'COMPLETED',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 7.sp,
                        fontWeight: FontWeight.w800,
                        color: _TC.teal,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 5.w),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusText,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                        SizedBox(height: 0.3.h),
                        Text(
                          statusSubText,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 8.sp,
                            color: _TC.inkMid,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (statusData?.refundAmount != null) ...[
              SizedBox(height: 1.5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Refund Amount',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.sp,
                      color: _TC.inkMid,
                    ),
                  ),
                  Text(
                    '₹ ${statusData?.refundAmount?.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: _TC.ink,
                    ),
                  ),
                ],
              ),
            ],
            if (statusData?.refundSpeed != null &&
                !isProcessed &&
                !isFailed) ...[
              SizedBox(height: 1.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color:
                      (statusData?.refundSpeed == 'instant'
                              ? _TC.teal
                              : _TC.amber)
                          .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      statusData?.refundSpeed == 'instant'
                          ? Icons.bolt_rounded
                          : Icons.schedule_outlined,
                      size: 3.8.w,
                      color: statusData?.refundSpeed == 'instant'
                          ? _TC.teal
                          : _TC.amber,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        statusData?.refundSpeed == 'instant'
                            ? 'Instant refund — credited within minutes'
                            : 'Normal refund — 3 to 5 business days',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w500,
                          color: statusData?.refundSpeed == 'instant'
                              ? _TC.teal
                              : _TC.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isProcessed && statusData?.refundProcessedAt != null) ...[
              SizedBox(height: 1.2.h),
              Row(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 3.8.w,
                    color: _TC.teal,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Credited on ${_formatSettledAt(statusData?.refundProcessedAt)}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: _TC.teal,
                    ),
                  ),
                ],
              ),
            ],
            if (isFailed) ...[
              SizedBox(height: 1.2.h),
              GestureDetector(
                onTap: () {
                  CustomSnackBar.show(
                    context,
                    message: 'Please contact support for refund assistance.',
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: _TC.redLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _TC.red.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.support_agent_rounded,
                        size: 4.w,
                        color: _TC.red,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Contact Support',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: _TC.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 1.5.h),
            Container(height: 1, color: _TC.divider),
            SizedBox(height: 1.5.h),
            GestureDetector(
              onTap: () => _showRefundStatusSheet(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
                decoration: BoxDecoration(
                  color: _TC.brandLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.track_changes_rounded,
                      size: 4.w,
                      color: _TC.brand,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Track Refund',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: _TC.brand,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 4.w,
                      color: _TC.brand,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showRefundStatusSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: _TC.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
        ),
        padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 4.h),
        child: Obx(() {
          final result = _trekC.refundStatusObserver.value;
          RefundStatusData? statusData;
          result.maybeWhen(success: (m) => statusData = m?.data, orElse: () {});
          final isPolling = result.maybeWhen(
            loading: (_) => true,
            orElse: () => false,
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 10.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: _TC.inkLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Container(
                    width: 9.w,
                    height: 9.w,
                    decoration: BoxDecoration(
                      color: _TC.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                      size: 4.5.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Refund Status',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _TC.ink,
                    ),
                  ),
                  const Spacer(),
                  if (isPolling)
                    SizedBox(
                      width: 4.w,
                      height: 4.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _TC.brand,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 2.h),
              if (isPolling && statusData == null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: const Center(child: CircularProgressIndicator()),
                )
              else ...[
                _buildStatusStep(
                  'Cancellation Confirmed',
                  true,
                  Icons.check_circle_rounded,
                ),
                _buildStatusConnector(true),
                _buildStatusStep(
                  'Refund Initiated',
                  statusData?.refundStatus != null,
                  Icons.currency_rupee_rounded,
                ),
                _buildStatusConnector(statusData?.refundStatus != null),
                _buildStatusStep(
                  'Being Processed by Bank',
                  statusData?.refundStatus == 'processing' ||
                      statusData?.refundStatus == 'processed',
                  Icons.account_balance_rounded,
                ),
                _buildStatusConnector(
                  statusData?.refundStatus == 'processing' ||
                      statusData?.refundStatus == 'processed',
                ),
                _buildStatusStep(
                  (statusData?.isProcessed ?? false)
                      ? 'Credited — ${_formatSettledAt(statusData?.refundProcessedAt)}'
                      : (statusData?.isFailed ?? false)
                      ? 'Failed — Contact Support'
                      : 'Awaiting Credit',
                  statusData?.isProcessed ?? false,
                  (statusData?.isFailed ?? false)
                      ? Icons.error_outline_rounded
                      : Icons.done_all_rounded,
                  isFailed: statusData?.isFailed ?? false,
                ),
                SizedBox(height: 2.5.h),
                if (statusData?.statusMessage != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.2.h,
                    ),
                    decoration: BoxDecoration(
                      color: (statusData?.isFailed ?? false)
                          ? _TC.redLight
                          : (statusData?.isProcessed ?? false)
                          ? _TC.tealLight
                          : _TC.brandLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          (statusData?.isFailed ?? false)
                              ? Icons.info_outline_rounded
                              : (statusData?.isProcessed ?? false)
                              ? Icons.check_circle_outline_rounded
                              : Icons.info_outline_rounded,
                          size: 4.w,
                          color: (statusData?.isFailed ?? false)
                              ? _TC.red
                              : (statusData?.isProcessed ?? false)
                              ? _TC.teal
                              : _TC.brand,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            statusData?.statusMessage ??
                                'Checking refund status...',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9.sp,
                              color: (statusData?.isFailed ?? false)
                                  ? _TC.red
                                  : (statusData?.isProcessed ?? false)
                                  ? _TC.teal
                                  : _TC.inkMid,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (statusData?.refundSpeed != null) ...[
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(
                        statusData?.refundSpeed == 'instant'
                            ? Icons.bolt_rounded
                            : Icons.schedule_outlined,
                        size: 3.8.w,
                        color: statusData?.refundSpeed == 'instant'
                            ? _TC.teal
                            : _TC.amber,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Speed: ${statusData?.refundSpeed == 'instant' ? 'Instant (within minutes)' : 'Normal (3–5 business days)'}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9.sp,
                          color: _TC.inkMid,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  height: 5.h,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _TC.brand.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: _TC.brand,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatusStep(
    String label,
    bool done,
    IconData icon, {
    bool isFailed = false,
  }) {
    final color = isFailed
        ? _TC.red
        : done
        ? _TC.teal
        : _TC.inkLight;

    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: isFailed
                ? _TC.redLight
                : done
                ? _TC.tealLight
                : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 5.w, color: color),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.sp,
              color: isFailed
                  ? _TC.red
                  : done
                  ? _TC.ink
                  : _TC.inkLight,
              fontWeight: done ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusConnector(bool active) {
    return Padding(
      padding: EdgeInsets.only(left: 4.5.w),
      child: Container(
        width: 1,
        height: 2.5.h,
        color: active ? _TC.teal.withValues(alpha: 0.4) : _TC.divider,
      ),
    );
  }

  String _formatSettledAt(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final ist = ISTDateUtils.toIST(iso);
    if (ist == null) return '';
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
    return '${months[ist.month - 1]} ${ist.day}, ${ist.year}';
  }

  Widget _buildFloatingRatingButton({required BookingHistoryData bookingData}) {
    final bool isCancelled = bookingData.status == 'cancelled';
    final bool trekEnded =
        bookingData.batch?.endDate != null &&
        DateTime.now().isAfter(
          DateTime.tryParse(bookingData.batch!.endDate!) ?? DateTime.now(),
        );
    if (isCancelled || !trekEnded) return const SizedBox.shrink();

    final bool isReviewed = bookingData.ratingGiven == true;
    final double currentRating = (bookingData.ratingValue ?? 0.0).toDouble();

    final Color primary = isReviewed
        ? const Color(0xFF0F766E)
        : const Color(0xFF1E3A8A);

    final Widget panel = ClipRect(
      child: SizeTransition(
        sizeFactor: _ratingPanelAnim,
        axisAlignment: 1.0,
        child: FadeTransition(
          opacity: _ratingPanelAnim,
          child: Padding(
            padding: EdgeInsets.only(bottom: 1.2.h),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primary.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.10),
                    blurRadius: 26,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(4.5.w, 2.0.h, 4.5.w, 2.0.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 11.w,
                          height: 11.w,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            isReviewed
                                ? Icons.verified_rounded
                                : Icons.star_rounded,
                            color: primary,
                            size: 5.5.w,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isReviewed
                                    ? 'You rated this trek'
                                    : 'Rate your trek',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: _TC.ink,
                                ),
                              ),
                              SizedBox(height: 0.35.h),
                              Text(
                                isReviewed
                                    ? 'Tap to view your review'
                                    : 'Help other trekkers with your experience',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w500,
                                  color: _TC.inkMid,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _hideRatingPanel,
                          child: Container(
                            width: 8.5.w,
                            height: 8.5.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _TC.divider),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 4.4.w,
                              color: _TC.inkMid,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isReviewed
                                      ? 'Review saved'
                                      : 'Tap a star to rate',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: _TC.ink,
                                  ),
                                ),
                                SizedBox(height: 0.2.h),
                                Text(
                                  isReviewed
                                      ? '${currentRating.toStringAsFixed(1)} / 5.0'
                                      : 'Your feedback helps other trekkers',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 8.sp,
                                    color: _TC.inkMid,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedRatingStars(
                            initialRating: currentRating,
                            readOnly: isReviewed,
                            onChanged: (rating) {
                              if (!isReviewed) {
                                Get.toNamed(
                                  '/rate-review',
                                  arguments: {
                                    'booking': bookingData,
                                    'preSelectedRating': rating,
                                  },
                                );
                              }
                            },
                            filledColor: const Color(0xFFFFB800),
                            displayRatingValue: false,
                            interactiveTooltips: true,
                            customFilledIcon: Icons.star_rounded,
                            customHalfFilledIcon: Icons.star_half_rounded,
                            customEmptyIcon: Icons.star_border_rounded,
                            starSize: 7.5.w,
                            animationDuration: const Duration(
                              milliseconds: 450,
                            ),
                            animationCurve: Curves.easeOutBack,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final Widget button = GestureDetector(
      onTapDown: (_) => setState(() => _isFabPressed = true),
      onTapUp: (_) => setState(() => _isFabPressed = false),
      onTapCancel: () => setState(() => _isFabPressed = false),
      onTap: _ratingPanelVisible ? _hideRatingPanel : _showRatingPanel,
      child: AnimatedScale(
        scale: _isFabPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          height: 7.8.h,
          width: 88.w,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: isReviewed
                  ? const [Color(0xFFFFFFFF), Color(0xFFF0FDFA)]
                  : const [Color(0xFFFFFFFF), Color(0xFFF6F9FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isReviewed
                  ? const Color(0xFF14B8A6).withValues(alpha: 0.18)
                  : const Color(0xFF3B82F6).withValues(alpha: 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isReviewed
                    ? const Color(0xFF14B8A6).withValues(alpha: 0.10)
                    : const Color(0xFF3B82F6).withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 11.w,
                height: 11.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isReviewed
                        ? const [Color(0xFF0F766E), Color(0xFF14B8A6)]
                        : const [Color(0xFF0F172A), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    isReviewed ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.white,
                    size: 5.8.w,
                  ),
                ),
              ),
              SizedBox(width: 3.5.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isReviewed ? 'View Your Review' : 'Rate Your Trek',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: _TC.ink,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      isReviewed
                          ? 'Tap to open your feedback'
                          : 'Help other trekkers discover',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 7.sp,
                        fontWeight: FontWeight.w500,
                        color: _TC.inkMid,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                width: 8.5.w,
                height: 8.5.w,
                decoration: BoxDecoration(
                  color:
                      (isReviewed
                              ? const Color(0xFF14B8A6)
                              : const Color(0xFF3B82F6))
                          .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedRotation(
                  turns: _ratingPanelVisible ? 0.5 : 0,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: isReviewed
                        ? const Color(0xFF0F766E)
                        : const Color(0xFF1E3A8A),
                    size: 5.2.w,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [if (_ratingPanelVisible) panel, button],
    );
  }

  Widget _buildDisputeCard({required List<Disputes> disputeData}) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CommonColors.appRedColor.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: CommonColors.appRedColor.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9.w,
                height: 9.w,
                decoration: BoxDecoration(
                  color: CommonColors.appRedColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: CommonColors.appRedColor,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Dispute Details',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: _TC.ink,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...disputeData.map(
            (dispute) => Column(
              children: [
                _buildDisputeInfoRow('Status', dispute.status ?? 'N/A'),
                _dividerLine(),
                _buildDisputeInfoRow(
                  'Disputed Amount',
                  '₹${dispute.disputedAmount ?? 0}',
                ),
                _dividerLine(),
                _buildDisputeInfoRow('Issue Type', dispute.issueType ?? 'N/A'),
                _dividerLine(),
                _buildDisputeInfoRow('Priority', dispute.priority ?? 'N/A'),
                SizedBox(height: 1.5.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: CommonColors.appRedColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Your dispute is being reviewed by our support team. We will update you soon.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8.sp,
                      color: CommonColors.appRedColor,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisputeInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.7.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9.sp,
              color: _TC.inkMid,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: _TC.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 70.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(20),
            ),
          ).withShimmerAi(loading: true),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            height: 20.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(16),
            ),
          ).withShimmerAi(loading: true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: _TC.bg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            scrolledUnderElevation: 0,
            elevation: 0,
            automaticallyImplyLeading: true,
            iconTheme: const IconThemeData(color: _TC.ink),
            centerTitle: false,
            title: Text(
              'Booking Details',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: _TC.ink,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: _TC.divider),
            ),
          ),
          body: Obx(() {
            final isLoading = _dashboardC.bookingDetailsObserver.value
                .maybeWhen(loading: (_) => true, orElse: () => false);
            final booking = _dashboardC.bookingDetailsObserver.value.maybeWhen(
              success: (r) => (r as BookingDetailsResponseModel).data,
              orElse: () => null,
            );
            final status = booking?.status;

            if (isLoading) return _buildShimmerLoading();

            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom:
                        (status == 'confirmed' &&
                            booking != null &&
                            !_ratingDismissed)
                        ? 18.h
                        : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: _buildTicketCard(booking),
                      ),
                      if (status == 'cancelled' && booking != null) ...[
                        SizedBox(height: 2.5.h),
                        _buildRefundTrackerCard(booking),
                      ],
                      SizedBox(height: 2.5.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 10.w,
                                height: 10.w,
                                decoration: BoxDecoration(
                                  color: _TC.tealLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.phone_outlined,
                                  size: 5.w,
                                  color: _TC.teal,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Trek details via contact',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 8.sp,
                                        color: _TC.inkMid,
                                      ),
                                    ),
                                    SizedBox(height: 0.2.h),
                                    if (booking?.trek?.captainName != null)
                                      Text(
                                        booking?.trek?.captainName ?? '',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: _TC.ink,
                                        ),
                                      ),
                                    if (booking?.trek?.captainPhone != null)
                                      Text(
                                        booking?.trek?.captainPhone ?? '',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: _TC.brand,
                                        ),
                                      )
                                    else
                                      Text(
                                        'Contact number not available',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 9.sp,
                                          color: _TC.inkMid,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 2.5.h),
                      // Action buttons
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                Icons.confirmation_num_outlined,
                                'Ticket',
                                onTap: () => _handleTicketDownload(booking),
                              ),
                            ),
                            if (status == 'upcoming' ||
                                status == 'confirmed' ||
                                status == 'booked') ...[
                              SizedBox(width: 3.w),
                              Expanded(
                                child: _buildActionButton(
                                  Icons.cancel_outlined,
                                  'Cancel',
                                  onTap: () async {
                                    String? bookingId = booking?.id?.toString();
                                    if (bookingId != null) {
                                      final message = await _trekC
                                          .fetchCancellationDetails(bookingId);
                                      if (message != null) {
                                        SchedulerBinding.instance
                                            .addPostFrameCallback((_) {
                                              CustomSnackBar.show(
                                                context,
                                                message: message,
                                              );
                                            });
                                        return;
                                      }
                                    }
                                    Get.toNamed(
                                      '/bookingscancel',
                                      arguments: booking,
                                    );
                                  },
                                ),
                              ),
                            ],
                            SizedBox(width: 3.w),
                            Expanded(
                              child: _buildActionButton(
                                Icons.share_outlined,
                                'Share',
                                onTap: () => _handleShare(booking),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.5.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: GestureDetector(
                          onTap: () => CustomSnackBar.show(
                            context,
                            message: 'FAQ coming soon',
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.8.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _TC.divider),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 10.w,
                                  height: 10.w,
                                  decoration: BoxDecoration(
                                    color: _TC.brandLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.help_outline_rounded,
                                    size: 5.w,
                                    color: _TC.brand,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Text(
                                    'Frequently Asked Questions',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: _TC.ink,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 4.w,
                                  color: _TC.inkLight,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_dashboardC.disputeDetailDataList.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.fromLTRB(4.w, 2.5.h, 4.w, 0),
                          child: Obx(
                            () => _buildDisputeCard(
                              disputeData: _dashboardC.disputeDetailDataList,
                            ),
                          ),
                        ),
                      SizedBox(height: 2.h),
                      Padding(
                        padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 5.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Go Beyond,\nExplore More!',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE2E8F0),
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10.sp,
                                  color: _TC.inkLight,
                                ),
                                children: [
                                  const TextSpan(text: 'Crafted with passion '),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      Icons.favorite,
                                      color: CommonColors.red_B52424,
                                      size: 10.sp,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '\nrooted in Hyderabad.',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (status == 'confirmed' &&
                    booking != null &&
                    !_ratingDismissed)
                  Positioned(
                    left: 4.w,
                    right: 4.w,
                    bottom: 3.h,
                    child: _buildFloatingRatingButton(bookingData: booking),
                  ),
                Obx(
                  () => _trekC.cancellationDetailsResponseObserver.value
                      .maybeWhen(
                        loading: (_) => Container(
                          color: CommonColors.grey400,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: CommonColors.blueColor,
                            ),
                          ),
                        ),
                        orElse: () => const SizedBox(),
                      ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}
