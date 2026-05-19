import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../freezed_models/booking/booking_history_model.dart';
import 'common_colors.dart';
import 'common_images.dart';
import 'screen_constants.dart';
import 'package:arobo_app/repository/repository.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS — mirrors CommonTrekCard _TkC
// ─────────────────────────────────────────────
class _BC {
  static const bg          = CommonColors.whiteColor;
  static const ink         = CommonColors.cFF111827;
  static const inkMid      = CommonColors.cFF6B7280;
  static const inkLight    = CommonColors.grey_AEAEAE;
  static const iconBadge   = CommonColors.cFF111827;   // dark black vendor badge
  static const brand       = CommonColors.lightBlueColor3;
  static const tealSoft    = CommonColors.cFFE6F5F3;
  static const divider     = CommonColors.trekroutecolorlight;
  static const shadow      = CommonColors.c0A000000;

  // Status colors — same as original _getStatusColor logic
  static const upcoming    = CommonColors.upcomingColor;
  static const completed   = CommonColors.completedColor2;
  static const ongoing     = CommonColors.blueColor_367FEE;
  static const cancelled   = CommonColors.cancelledColor;
}

class CommonBookedCard extends StatelessWidget {
  final BookingHistoryData booking;
  final VoidCallback? onViewDetailsTap;

  const CommonBookedCard({
    super.key,
    required this.booking,
    this.onViewDetailsTap,
  });

  // ── ALL ORIGINAL LOGIC UNTOUCHED ────────────

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':   return _BC.upcoming.withValues(alpha: 0.8);
      case 'completed':  return _BC.completed.withValues(alpha: 0.8);
      case 'ongoing':    return _BC.ongoing;
      case 'cancelled':  return _BC.cancelled;
      default:           return Colors.grey;
    }
  }

  // ── Helpers ─────────────────────────────────

  /// Vendor initials from business name
  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  /// Labeled info column — mirrors _buildInfoItem in CommonTrekCard
  Widget _infoItem(String label, String value) {
    if (value.isEmpty || value == '-') return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
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
              color: _BC.inkMid,
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
              color: _BC.ink,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);

    print("image ${booking.trek?.vendor?.businessLogo ?? ''}");

    final vendorName   = booking.trek?.vendor?.businessName ?? '-';
    final trekTitle    = booking.trek?.title ?? '-';
    final tbrId        = booking.batch?.tbrId ?? '-';
    final startDate    = booking.batch?.startDate ?? '-';
    final duration     = booking.trek?.duration ?? '-';
    final bookedSlots  = booking.batch?.bookedSlots ?? 0;
    final statusRaw    = booking.trekStatus ?? '';
    final statusLabel  = statusRaw.isNotEmpty
        ? statusRaw[0].toUpperCase() + statusRaw.substring(1)
        : '-';

    return GestureDetector(
      onTap: onViewDetailsTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.6.h),
        decoration: BoxDecoration(
          color: _BC.bg,
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(color: _BC.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: CommonColors.blackColor.withOpacity(0.07),
              offset: const Offset(0, 3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(4.w, 2.8.h, 4.w, 1.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              // ═══ TOP: Trek title + Status pill ═══
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      trekTitle,
                      textScaler: const TextScaler.linear(1.0),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s13,
                        fontWeight: FontWeight.w600,
                        color: _BC.ink,
                        height: 1.3,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  // Status pill — top right (mirrors policy chip position)
                  if (statusRaw.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.5.w, vertical: 0.35.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(statusRaw).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(1.5.w),
                        border: Border.all(
                          color: _getStatusColor(statusRaw).withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        statusLabel,
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s8,
                          fontWeight: FontWeight.w700,
                          color: _getStatusColor(statusRaw),
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 0.3.h),

              // ═══ VENDOR ROW — mirrors CommonTrekCard vendor row ═══
              Row(
                children: [
                  // Vendor logo badge
              CustomNetworkImage(
                accessToken: Repository.token,
              imageUrl: booking.trek?.vendor?.businessLogo ?? '',
                width: 10.w,
                height: 10.w,
                fit: BoxFit.contain,
                color: Colors.white,
              ),
                  SizedBox(width: 3.w),

                  // Vendor name + TBR ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendorName,
                          textScaler: const TextScaler.linear(1.0),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s12,
                            fontWeight: FontWeight.w600,
                            color: _BC.ink,
                          ),
                        ),
                        SizedBox(height: 0.1.h),
                        // TBR ID — subtle label below vendor name
                        Text(
                          'TBR ID: $tbrId',
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s8,
                            color: _BC.inkLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 0.3.h),

              // ═══ INFO ROW: left labels + right slots ═══
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Left — departure date + duration
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoItem('Departure Date', startDate),
                        _infoItem('Duration', duration),
                      ],
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // Right — booked slots count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$bookedSlots',
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s16,
                          fontWeight: FontWeight.w700,
                          color: _BC.ink,
                        ),
                      ),
                      Text(
                        'slots booked',
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s8,
                          color: _BC.inkMid,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 0.3.h),

              // Divider
              Container(height: 0.5, color: _BC.divider),

              SizedBox(height: 0.3.h),

              // ═══ Bottom row: View details CTA ═══
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View details',
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s11,
                          fontWeight: FontWeight.w600,
                          color: _BC.brand,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Icon(Icons.arrow_forward_rounded,
                          size: 4.w, color: _BC.brand),
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