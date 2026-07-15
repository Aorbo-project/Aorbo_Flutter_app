import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../freezed_models/booking/booking_history_model.dart';
import 'common_colors.dart';
import 'ist_date_utils.dart';
import 'screen_constants.dart';
import 'package:arobo_app/repository/repository.dart';

// ─────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────
class _BC {
  static const bg = CommonColors.whiteColor;
  static const ink = CommonColors.cFF111827;
  static const inkMid = CommonColors.cFF6B7280;
  static const inkLight = CommonColors.grey_AEAEAE;
  static const iconBadge = CommonColors.cFF111827;
  static const brand = CommonColors.lightBlueColor3;
  static const divider = CommonColors.trekroutecolorlight;
  static const upcoming = Color(0xFF2563EB);
  static const completed = CommonColors.completedColor2;
  static const ongoing = CommonColors.blueColor_367FEE;
  static const cancelled = CommonColors.cancelledColor;

  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const ratingBg = Color(0xFFFFF7ED);
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

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  Color _getTrekStatusColor(String status) {
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
        return Colors.grey;
    }
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
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

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(1.5.w),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        textScaler: const TextScaler.linear(1),
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s8,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // INFO ITEM WITH ICON
  // ─────────────────────────────────────────────
  Widget _infoItem(IconData icon, String label, String value) {
    // Hide if value is empty
    if (value.isEmpty ||
        value == '-' ||
        value == '0 People' ||
        value == '0D / 0N') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 1.2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label & Icon Row
          Row(
            children: [
              Icon(icon, size: 3.5.w, color: _BC.inkMid),
              SizedBox(width: 1.5.w),
              Text(
                label,
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s8,
                  fontWeight: FontWeight.w500,
                  color: _BC.inkMid,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.3.h),
          // Value aligned under text
          Padding(
            padding: EdgeInsets.only(left: 5.w),
            child: Text(
              value,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s11,
                fontWeight: FontWeight.w600,
                color: _BC.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);

    // Extracting fields
    final String bookingId = booking.bookingNumber ?? '#${booking.id ?? '-'}';
    final String totalTravelers = '${booking.totalTravelers ?? 0} People';
    final String trekStatusRaw = booking.trekStatus ?? '';
    final String paymentStatusRaw = booking.paymentStatus ?? '';
    final String bookingDate = _formatDate(booking.bookingDate);
    final String cancellationPolicy =
        booking.cancellationPolicyType?.toString() ?? '-';

    final bool isCompleted = trekStatusRaw.toLowerCase() == 'completed';
    final bool ratingGiven = booking.ratingGiven ?? false;
    final bool showRateHint = isCompleted && !ratingGiven;

    final String title = booking.trek?.title ?? '-';

    // Duration Logic (Days/Nights or fallback to string)
    final String? durationDays = booking.trek?.durationDays?.toString();
    final String? durationNights = booking.trek?.durationNights?.toString();
    String durationStr = '-';
    if (durationDays != null || durationNights != null) {
      durationStr = '${durationDays ?? '0'}D / ${durationNights ?? '0'}N';
    } else if (booking.trek?.duration != null &&
        booking.trek!.duration!.isNotEmpty) {
      durationStr = booking.trek!.duration!; // Fallback
    }

    final String difficulty = booking.trek?.difficulty ?? '-';

    final String tbrId = booking.batch?.tbrId ?? '-';
    final String startDateStr = _formatDate(booking.batch?.startDate);
    final String startTimeStr = booking.batch?.startTime ?? '';

    final String startDateTime = startTimeStr.isNotEmpty
        ? '$startDateStr, $startTimeStr'
        : startDateStr;

    final String vendorName =
        booking.trek?.vendor?.businessName ?? 'Unknown Vendor';
    final String vendorLogo = booking.trek?.vendor?.businessLogo ?? '';
    final String destinationName = booking.trek?.destination?.name ?? '';

    // Format Status Labels
    String statusLabel = trekStatusRaw.isNotEmpty
        ? trekStatusRaw[0].toUpperCase() + trekStatusRaw.substring(1)
        : '';

    // Payment Badge Logic: Only show if Partial
    String paymentBadgeText = '';
    if (paymentStatusRaw.toLowerCase().contains('partial') ||
        paymentStatusRaw.toLowerCase().contains('advance')) {
      paymentBadgeText = 'Partial';
    }

    return GestureDetector(
      onTap: onViewDetailsTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.7.h),
        decoration: BoxDecoration(
          color: _BC.bg,
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(color: _BC.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─────────────────────────
              // COMPACT HEADER
              // ─────────────────────────
              Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: _BC.iconBadge,
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: vendorLogo.isNotEmpty
                        ? CustomNetworkImage(
                            accessToken: Repository.token,
                            imageUrl: vendorLogo,
                            width: 8.w,
                            height: 8.w,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Text(
                              _initials(vendorName),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      vendorName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s10,
                        fontWeight: FontWeight.w600,
                        color: _BC.inkMid,
                      ),
                    ),
                  ),
                  if (paymentBadgeText.isNotEmpty) ...[
                    _buildBadge(paymentBadgeText, _BC.warning),
                    SizedBox(width: 1.5.w),
                  ],
                  if (statusLabel.isNotEmpty)
                    _buildBadge(
                      statusLabel,
                      _getTrekStatusColor(trekStatusRaw),
                    ),
                ],
              ),

              SizedBox(height: 1.5.h),

              // ─────────────────────────
              // TITLE & DESTINATION
              // ─────────────────────────
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textScaler: const TextScaler.linear(1),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s14,
                  fontWeight: FontWeight.w700,
                  color: _BC.ink,
                  height: 1.3,
                ),
              ),
              if (destinationName.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 0.5.h),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, size: 3.5.w, color: _BC.brand),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          destinationName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s9,
                            color: _BC.inkMid,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 1.5.h),
              Container(height: 0.5, color: _BC.divider),
              SizedBox(height: 1.5.h),

              // ─────────────────────────
              // INFO GRID WITH ICONS
              // ─────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoItem(
                          Icons.receipt_long_outlined,
                          'Booking ID',
                          bookingId,
                        ),
                        _infoItem(Icons.tag_outlined, 'TBR ID', tbrId),
                        _infoItem(
                          Icons.calendar_today_outlined,
                          'Booking Date',
                          bookingDate,
                        ),
                        _infoItem(
                          Icons.event_available_outlined,
                          'Start Date',
                          startDateTime,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  // Right Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoItem(
                          Icons.people_alt_outlined,
                          'Travelers',
                          totalTravelers,
                        ),
                        _infoItem(
                          Icons.hourglass_bottom_outlined,
                          'Duration',
                          durationStr,
                        ),
                        _infoItem(
                          Icons.terrain_outlined,
                          'Difficulty',
                          difficulty,
                        ),
                        _infoItem(
                          Icons.shield_outlined,
                          'Cancellation',
                          cancellationPolicy,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ─────────────────────────
              // RATE TREK HINT
              // ─────────────────────────
              if (showRateHint) ...[
                SizedBox(height: 0.5.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 1.2.h,
                  ),
                  decoration: BoxDecoration(
                    color: _BC.ratingBg,
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(
                      color: _BC.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, color: _BC.warning, size: 5.w),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'You haven\'t rated this trek yet!',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s9,
                            fontWeight: FontWeight.w600,
                            color: _BC.ink,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onRateTrekTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 0.6.h,
                          ),
                          decoration: BoxDecoration(
                            color: _BC.warning,
                            borderRadius: BorderRadius.circular(1.5.w),
                          ),
                          child: Text(
                            'Rate Now',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s8,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 1.h),
              Container(height: 0.5, color: _BC.divider),
              SizedBox(height: 1.h),

              // ─────────────────────────
              // CTA
              // ─────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        'View details',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s11,
                          fontWeight: FontWeight.w600,
                          color: _BC.brand,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 4.w,
                        color: _BC.brand,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
