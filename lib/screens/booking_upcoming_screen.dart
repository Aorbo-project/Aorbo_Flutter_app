import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import 'package:dotted_line/dotted_line.dart';
import '../freezed_models/booking/booking_history_model.dart';
import '../models/dispute/dispute_detail_modal.dart';
import '../controller/dashboard_controller.dart';
import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';
import '../utils/custom_snackbar.dart';
import 'invoice_example_screen.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _TC {
  static const bg         = Color(0xFFF4F7FF);
  static const cardBg     = Color(0xFFFFFFFF);
  static const ink        = Color(0xFF0F172A);
  static const inkMid     = Color(0xFF64748B);
  static const inkLight   = Color(0xFF94A3B8);
  static const accent     = Color(0xFF111827);
  static const brand      = Color(0xFF4271FF);
  static const brandLight = Color(0xFFEEF2FF);
  static const teal       = Color(0xFF0F7B6C);
  static const tealLight  = Color(0xFFE6F5F3);
  static const divider    = Color(0xFFE2E8F0);
  static const shadow     = Color(0x0A000000);
}

// ─────────────────────────────────────────────
//  TICKET CLIPPER
// ─────────────────────────────────────────────
class TicketClipper extends CustomClipper<Path> {
  final double cutoutOffset;
  TicketClipper(this.cutoutOffset);

  @override
  Path getClip(Size size) {
    double radius       = 2.w;
    double circleRadius = 5.w;
    double vertPos      = cutoutOffset;

    Path base = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    Path cutouts = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, vertPos), radius: circleRadius))
      ..addOval(Rect.fromCircle(center: Offset(size.width, vertPos), radius: circleRadius));

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
    with SingleTickerProviderStateMixin {

  final DashboardController _dashboardC = Get.find<DashboardController>();
  final TrekController _trekC =  Get.find<TrekController>();
  late AnimationController _animationController;

  // FIX: Booking Details (index 0) starts open
  Set<int> openSections = {0};

  final GlobalKey _dottedKey = GlobalKey();
  final GlobalKey _cardKey   = GlobalKey();
  double cutoutOffset = 0;

  @override
  void initState() {
    super.initState();
    _dashboardC.getBookingDetail(bookingId: widget.bookingId ?? '0');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();

    // FIX: Recalculate cutout offset after first frame since section 0 starts open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCutoutOffset();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateCutoutOffset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? box     = _dottedKey.currentContext?.findRenderObject() as RenderBox?;
      final RenderBox? cardBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && cardBox != null && mounted) {
        final position   = box.localToGlobal(Offset.zero);
        final cardTop    = cardBox.localToGlobal(Offset.zero).dy;
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
    Future.delayed(const Duration(milliseconds: 100), _updateCutoutOffset);
  }

  List<Color> _getStatusGradient(String? status) {
    switch (status) {
      case 'confirmed': return [const Color(0xFF0F7B6C), const Color(0xFF0D9488)];
      case 'completed': return [const Color(0xFF4271FF), const Color(0xFF6366F1)];
      case 'cancelled': return [const Color(0xFFDC2626), const Color(0xFFEF4444)];
      default:          return [const Color(0xFFEA580C), const Color(0xFFF97316)];
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'confirmed': return 'Confirmed';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      default:          return status?.toUpperCase() ?? 'PENDING';
    }
  }

  String? _getPaymentStatusText(String? status) {
    switch (status) {
      case 'full_paid':    return 'Fully Paid';
      case 'partial_paid': return 'Partially Paid';
      case 'pending':      return 'Pending';
      default:             return status;
    }
  }

  // ── SECTION HEADER ────────────────────────────────────────────────────────
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
              width: 7.w, height: 7.w,
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
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w700,
                  color: _TC.ink,
                ),
              ),
            ),
            AnimatedRotation(
              turns: isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                width: 7.w, height: 7.w,
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
      case 0: return Icons.confirmation_number_outlined;
      case 1: return Icons.terrain_rounded;
      case 2: return Icons.account_balance_wallet_outlined;
      default: return Icons.info_outline;
    }
  }

  // ── TICKET ROW ────────────────────────────────────────────────────────────
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
                fontSize: FontSize.s9,
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
                fontSize: FontSize.s9,
                fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
                color: isHighlight ? _TC.brand : _TC.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TICKET CARD ───────────────────────────────────────────────────────────
  Widget _buildTicketCard(BookingHistoryData? booking) {
    if (booking == null) return const SizedBox.shrink();

    final trek        = booking.trek;
    final batch       = booking.batch;
    final startDate   = DateTime.tryParse(batch?.startDate ?? '');
    final endDate     = DateTime.tryParse(batch?.endDate ?? '');
    final bookingDate = booking.bookingDate != null
        ? DateTime.parse(booking.bookingDate!)
        : null;

    final cardContent = Container(
      key: _cardKey,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── HEADER: dark gradient band ───────────────────────────────
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FIX: Trek name on the left, status badge on the right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        trek?.title ?? 'Trek Details',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    // Status pill moved here (top right)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
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
                              fontSize: FontSize.s8,
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
              ],
            ),
          ),

          // ── DATE ROW ──────────────────────────────────────────────────
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
                          fontSize: FontSize.s7,
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
                          fontSize: FontSize.s13,
                          fontWeight: FontWeight.w700,
                          color: _TC.ink,
                        ),
                      ),
                      SizedBox(height: 0.2.h),
                      Text(
                        trek?.destination?.name ?? '-',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s8,
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
                      // FIX: Changed from flight icon to trek-related icon
                      Icon(Icons.hiking_rounded,
                          size: 5.w, color: _TC.ink),
                      SizedBox(height: 0.5.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.4.h),
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
                            fontSize: FontSize.s8,
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
                          fontSize: FontSize.s7,
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
                          fontSize: FontSize.s13,
                          fontWeight: FontWeight.w700,
                          color: _TC.ink,
                        ),
                      ),
                      SizedBox(height: 0.2.h),
                      Text(
                        'Destination',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s8,
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

          // ── DOTTED SEPARATOR with cutout notches ──────────────────────
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

          // ── EXPANDABLE SECTIONS ───────────────────────────────────────
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
                        _ticketRow('TBR ID', batch?.tbrId ?? 'N/A',
                            isHighlight: true),
                        _dividerLine(),
                        _ticketRow('Booking ID',
                            booking.bookingNumber ?? 'N/A'),
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

                  // Traveller Details
                  if (booking.travelers?.isNotEmpty == true) ...[
                    Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Row(
                        children: [
                          Icon(Icons.people_outline_rounded,
                              size: 4.w, color: _TC.inkMid),
                          SizedBox(width: 2.w),
                          Text(
                            'Traveller Details',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s10,
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
                          // Header row
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: _TC.accent.withOpacity(0.04),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text('Name',
                                      style: _tableHeaderStyle()),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('Age',
                                      style: _tableHeaderStyle()),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text('Gender',
                                      style: _tableHeaderStyle()),
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
                                  horizontal: 3.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                border: isLast
                                    ? null
                                    : const Border(
                                        bottom: BorderSide(
                                            color: Color(0xFFE2E8F0))),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      t.traveler?.name ?? '-',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: FontSize.s9,
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
                                        fontSize: FontSize.s9,
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
                                        fontSize: FontSize.s9,
                                        color: _TC.inkMid,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
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
                        _ticketRow('Trek Operator',
                            trek?.vendor?.businessName ?? 'N/A'),
                        _dividerLine(),
                        _ticketRow('Boarding Point',
                            booking.cityId?.toString() ??
                                'To be announced'),
                        _dividerLine(),
                        _ticketRow('Trek Captain',
                            trek?.captainName ?? 'To be announced'),
                        _dividerLine(),
                        _ticketRow('Captain Contact',
                            trek?.captainPhone ?? 'Not available'),
                        _dividerLine(),
                        _ticketRow(
                            'Difficulty', trek?.difficulty ?? 'Moderate'),
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
                    child: Column(
                      children: [
                        _ticketRow('Total Amount',
                            '₹${booking.totalAmount ?? '0'}'),
                        _dividerLine(),
                        _ticketRow(
                            'Discount', '-₹${booking.discountAmount ?? '0'}'),
                        _dividerLine(),
                        _ticketRow('Platform Fees',
                            '₹${booking.platformFees ?? '0'}'),
                        _dividerLine(),
                        _ticketRow('GST', '₹${booking.gstAmount ?? '0'}'),
                        _dividerLine(),
                        _ticketRow('Final Amount',
                            '₹${booking.finalAmount ?? '0'}',
                            isHighlight: true),
                        _dividerLine(),
                        _ticketRow(
                          'Payment Status',
                          _getPaymentStatusText(booking.paymentStatus) ??
                              'N/A',
                          isHighlight: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                ],
              ],
            ),
          ),

          SizedBox(height: 1.5.h),

          // ── TICKET TEAR DOTTED LINE ───────────────────────────────────
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

          // ── FOOTER ────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 3.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"Not Insta-perfect.\nBut soul-perfect...!!"',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s10,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: _TC.inkLight,
                          height: 1.5,
                        ),
                      ),
                    ],
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
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          )),
          child: PhysicalShape(
            clipper: TicketClipper(cutoutOffset),
            elevation: 15,
            color: Colors.transparent,
            shadowColor: Colors.black.withOpacity(0.15),
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
        fontSize: FontSize.s8,
        fontWeight: FontWeight.w600,
        color: _TC.inkMid,
        letterSpacing: 0.4,
      );

  // ── ACTION BUTTON ─────────────────────────────────────────────────────────
  Widget _buildActionButton(IconData icon, String label,
      {VoidCallback? onTap}) {
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w, height: 10.w,
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
                fontSize: FontSize.s9,
                fontWeight: FontWeight.w600,
                color: _TC.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── RATING CARD ───────────────────────────────────────────────────────────
  Widget _buildRatingCard({required BookingHistoryData bookingData}) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
                  decoration: BoxDecoration(
                    color: _TC.tealLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    bookingData.ratingGiven == true
                        ? '✓ Reviewed'
                        : '⭐ Rate your trek',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s8,
                      fontWeight: FontWeight.w700,
                      color: _TC.teal,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  bookingData.ratingGiven == true
                      ? 'Thank you for your feedback!'
                      : 'Share your experience with fellow trekkers',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s10,
                    fontWeight: FontWeight.w600,
                    color: _TC.ink,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 1.5.h),
                AnimatedRatingStars(
                  initialRating: bookingData.ratingValue ?? 0.0,
                  readOnly: bookingData.ratingGiven == true,
                  onChanged: (rating) {
                    if (bookingData.ratingGiven != true) {
                      Get.toNamed('/rate-review', arguments: bookingData);
                    }
                  },
                  filledColor: CommonColors.completedColor2,
                  displayRatingValue: false,
                  interactiveTooltips: true,
                  customFilledIcon: Icons.star_rounded,
                  customHalfFilledIcon: Icons.star_half_rounded,
                  customEmptyIcon: Icons.star_border_rounded,
                  starSize: 7.w,
                  animationDuration: const Duration(milliseconds: 500),
                  animationCurve: Curves.easeInOut,
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Image.asset(
            'assets/images/img/womanwithplaque.png',
            width: 18.w,
            height: 18.w,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ── DISPUTE CARD ──────────────────────────────────────────────────────────
  Widget _buildDisputeCard({required List<Disputes> disputeData}) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CommonColors.appRedColor.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: CommonColors.appRedColor.withOpacity(0.07),
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
                width: 9.w, height: 9.w,
                decoration: BoxDecoration(
                  color: CommonColors.appRedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.warning_amber_rounded,
                    color: CommonColors.appRedColor, size: 5.w),
              ),
              SizedBox(width: 3.w),
              Text(
                'Dispute Details',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s13,
                  fontWeight: FontWeight.w700,
                  color: _TC.ink,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...disputeData.map((dispute) => Column(
                children: [
                  _buildDisputeInfoRow('Status', dispute.status ?? 'N/A'),
                  _dividerLine(),
                  _buildDisputeInfoRow(
                      'Disputed Amount', '₹${dispute.disputedAmount ?? 0}'),
                  _dividerLine(),
                  _buildDisputeInfoRow(
                      'Issue Type', dispute.issueType ?? 'N/A'),
                  _dividerLine(),
                  _buildDisputeInfoRow('Priority', dispute.priority ?? 'N/A'),
                  SizedBox(height: 1.5.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: CommonColors.appRedColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Your dispute is being reviewed by our support team. We will update you soon.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s8,
                        color: CommonColors.appRedColor,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              )),
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
          Text(label,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s9,
                  color: _TC.inkMid)),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s9,
                  fontWeight: FontWeight.w600,
                  color: _TC.ink)),
        ],
      ),
    );
  }

  // ── SHIMMER ───────────────────────────────────────────────────────────────
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

  // ── BUILD ─────────────────────────────────────────────────────────────────
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
                fontSize: FontSize.s15,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),

                      // Ticket Card
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: _buildTicketCard(booking),
                      ),

                      SizedBox(height: 2.5.h),

                      // Contact info block
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 10.w, height: 10.w,
                                decoration: BoxDecoration(
                                  color: _TC.tealLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.phone_outlined,
                                    size: 5.w, color: _TC.teal),
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
                                        fontSize: FontSize.s8,
                                        color: _TC.inkMid,
                                      ),
                                    ),
                                    SizedBox(height: 0.2.h),
                                    if (booking?.trek?.captainName != null)
                                      Text(
                                        booking?.trek?.captainName ?? '',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: FontSize.s11,
                                          fontWeight: FontWeight.w600,
                                          color: _TC.ink,
                                        ),
                                      ),
                                    if (booking?.trek?.captainPhone != null)
                                      Text(
                                        booking?.trek?.captainPhone ?? '',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: FontSize.s12,
                                          fontWeight: FontWeight.w700,
                                          color: _TC.brand,
                                        ),
                                      )
                                    else
                                      Text(
                                        'Contact number not available',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: FontSize.s9,
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
                                onTap: () => Get.to(() => const InvoiceExampleScreen()),
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
                                      final message = await _trekC.fetchCancellationDetails(bookingId);
                                      if (message != null) {
                                        SchedulerBinding.instance.addPostFrameCallback((_) {
                                          CustomSnackBar.show(context, message: message);
                                        });
                                        return;
                                      }
                                    }
                                    Get.toNamed('/bookingscancel', arguments: booking);
                                  },
                                ),
                              ),
                            ],
                            SizedBox(width: 3.w),
                            Expanded(
                              child: _buildActionButton(
                                Icons.share_outlined,
                                'Share',
                                onTap: () => CustomSnackBar.show(context,
                                    message: 'Share feature coming soon'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 2.5.h),

                      // FAQ Card
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: GestureDetector(
                          onTap: () => CustomSnackBar.show(context,
                              message: 'FAQ coming soon'),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 1.8.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _TC.divider),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 10.w, height: 10.w,
                                  decoration: BoxDecoration(
                                    color: _TC.brandLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.help_outline_rounded,
                                      size: 5.w, color: _TC.brand),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Text(
                                    'Frequently Asked Questions',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: FontSize.s11,
                                      fontWeight: FontWeight.w600,
                                      color: _TC.ink,
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded,
                                    size: 4.w, color: _TC.inkLight),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 2.5.h),

                      // Rating Card
                      if (status == 'completed' && booking != null)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: _buildRatingCard(bookingData: booking),
                        ),

                      // Dispute Card
                      if (_dashboardC.disputeDetailDataList.isNotEmpty)
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 4.w),
                          child: Obx(() => _buildDisputeCard(
                                disputeData: _dashboardC.disputeDetailDataList,
                              )),
                        ),

                      SizedBox(height: 2.h),

                      // Footer
                      Padding(
                        padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 5.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Go Beyond,\nExplore More!',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: FontSize.s28,
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
                                  fontSize: FontSize.s10,
                                  color: _TC.inkLight,
                                ),
                                children: [
                                  const TextSpan(text: 'Crafted with passion '),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(Icons.favorite,
                                        color: CommonColors.red_B52424,
                                        size: FontSize.s10),
                                  ),
                                  const TextSpan(text: '\nrooted in Hyderabad.'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() => _trekC.cancellationDetailsResponseObserver.value.maybeWhen(
                  loading: (_) => Container(
                    color: CommonColors.grey400,
                    child: Center(child: CircularProgressIndicator(color: CommonColors.blueColor)),
                  ),
                  orElse: () => const SizedBox(),
                )),
              ],
            );
          }),
        );
      },
    );
  }
}