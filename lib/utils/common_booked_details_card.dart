import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../freezed_models/booking/booking_history_model.dart';
import 'common_colors.dart';
import 'screen_constants.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS — mirrors CommonBookedCard
// ─────────────────────────────────────────────
class _UpC {
  static const bg        = CommonColors.whiteColor;
  static const ink       = CommonColors.cFF111827;
  static const inkMid    = CommonColors.cFF6B7280;
  static const inkLight  = CommonColors.grey_AEAEAE;
  static const brand     = CommonColors.lightBlueColor3;
  static const tealSoft  = CommonColors.cFFE6F5F3;
  static const divider   = CommonColors.trekroutecolorlight;

  static const upcoming  = CommonColors.upcomingColor;
  static const completed = CommonColors.completedColor2;
  static const ongoing   = CommonColors.blueColor_367FEE;
  static const cancelled = CommonColors.cancelledColor;
}

class UpcomingBookingCard extends StatelessWidget {
  final BookingHistoryData? booking;
  final VoidCallback? onViewMoreTap;

  const UpcomingBookingCard({
    super.key,
    required this.booking,
    this.onViewMoreTap,
  });

  // ── Status Color Logic ──────────────────────

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':   return _UpC.upcoming.withValues(alpha: 0.8);
      case 'completed':  return _UpC.completed.withValues(alpha: 0.8);
      case 'ongoing':    return _UpC.ongoing;
      case 'cancelled':  return _UpC.cancelled;
      default:           return Colors.grey;
    }
  }

  // ── Helpers ─────────────────────────────────

    String _getOriginCity() {
    if (booking?.cityId != null) {
      // cityId is available but city name mapping requires separate lookup
      // Using a safe fallback since model doesn't expose city object
      return 'Origin City';
    }
    return 'Origin City';
  }

  String _getDestinationCity() {
    if (booking?.trek?.title != null) {
      return booking?.trek?.destination?.name ?? booking?.trek?.title ?? '';
    }
    return 'Destination';
  }

  String _getDurationText() {
    if (booking?.trek?.durationDays != null &&
        booking?.trek?.durationNights != null) {
      return '${booking?.trek!.durationDays}D | ${booking?.trek!.durationNights}N';
    }
    return booking?.trek?.duration ?? 'N/A';
  }

  /// Labeled info column — mirrors _buildInfoItem in CommonBookedCard
  Widget _infoItem(String label, String value) {
    if (value.isEmpty || value == '-' || value == 'N/A') {
      return const SizedBox.shrink();
    }
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
              color: _UpC.inkMid,
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
              color: _UpC.ink,
            ),
          ),
        ],
      ),
    );
  }

  /// Route connector — dotted line with duration pill
  Widget _routeConnector() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _UpC.divider,
                        _UpC.divider.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  color: _UpC.ink,
                  borderRadius: BorderRadius.circular(2.h),
                ),
                child: Text(
                  _getDurationText(),
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s8,
                    color: CommonColors.whiteColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _UpC.divider.withValues(alpha: 0.3),
                        _UpC.divider,
                      ],
                    ),
                  ),
                ),
              ),
            ],
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

    final vendorName  = booking?.trek?.vendor?.businessName ?? '-';
    final trekTitle   = booking?.trek?.title ?? 'Unknown Trek';
    final tbrId       = booking?.batch?.tbrId ?? '-';
    final startDate   = booking?.batch?.startDate ?? '-';
    final statusRaw   = booking?.trekStatus ?? booking?.status ?? '';
    final statusLabel = statusRaw.isNotEmpty
        ? statusRaw[0].toUpperCase() + statusRaw.substring(1)
        : '-';
    final bookedSlots = booking?.totalTravelers ?? booking?.batch?.bookedSlots ?? 0;

    return GestureDetector(
      onTap: onViewMoreTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.6.h),
        decoration: BoxDecoration(
          color: _UpC.bg,
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(color: _UpC.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: CommonColors.blackColor.withValues(alpha: 0.07),
              offset: const Offset(0, 3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(4.w, 0.8.h, 4.w, 0.8.h),
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
                        color: _UpC.ink,
                        height: 1.3,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  if (statusRaw.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.5.w, vertical: 0.35.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(statusRaw).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(1.5.w),
                        border: Border.all(
                          color: _getStatusColor(statusRaw).withValues(alpha: 0.4),
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

              // ═══ VENDOR ROW — mirrors CommonBookedCard ═══
              Row(
                children: [
                  CustomNetworkImage(
                    imageUrl: booking?.trek?.vendor?.businessLogo ?? '',
                    width: 10.w,
                    height: 10.w,
                    fit: BoxFit.contain,
                    color: Colors.white,
                  ),
                  SizedBox(width: 3.w),
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
                            color: _UpC.ink,
                          ),
                        ),
                        SizedBox(height: 0.1.h),
                        Text(
                          'TBR ID: $tbrId',
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s8,
                            color: _UpC.inkLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 0.3.h),

              // ═══ ROUTE ROW: Origin — Duration — Destination ═══
              Container(
                padding: EdgeInsets.symmetric(vertical: 0.5.h),
                child: Row(
                  children: [
                    // Origin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From',
                            textScaler: const TextScaler.linear(1.0),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s7,
                              fontWeight: FontWeight.w500,
                              color: _UpC.inkMid,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 0.1.h),
                          Text(
                            _getOriginCity(),
                            textScaler: const TextScaler.linear(1.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s11,
                              fontWeight: FontWeight.w600,
                              color: _UpC.ink,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Connector with duration
                    _routeConnector(),

                    // Destination
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'To',
                            textScaler: const TextScaler.linear(1.0),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s7,
                              fontWeight: FontWeight.w500,
                              color: _UpC.inkMid,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 0.1.h),
                          Text(
                            _getDestinationCity(),
                            textScaler: const TextScaler.linear(1.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s11,
                              fontWeight: FontWeight.w600,
                              color: _UpC.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 0.3.h),

              // ═══ INFO ROW: left labels + right slots ═══
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left — departure date
                  Expanded(
                    child: _infoItem('Departure Date', startDate),
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
                          color: _UpC.ink,
                        ),
                      ),
                      Text(
                        'travellers',
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s8,
                          color: _UpC.inkMid,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 0.3.h),

              // Divider
              Container(height: 0.5, color: _UpC.divider),

              SizedBox(height: 0.3.h),

              // ═══ Bottom row: View details CTA ═══
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View more',
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s11,
                          fontWeight: FontWeight.w600,
                          color: _UpC.brand,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Icon(Icons.arrow_forward_rounded,
                          size: 4.w, color: _UpC.brand),
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