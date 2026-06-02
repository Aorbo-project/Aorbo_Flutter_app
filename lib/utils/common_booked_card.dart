import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../freezed_models/booking/booking_history_model.dart';
import 'common_colors.dart';
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
}

class CommonBookedCard extends StatelessWidget {
  final BookingHistoryData booking;

  final VoidCallback? onViewDetailsTap;

  const CommonBookedCard({
    super.key,
    required this.booking,
    this.onViewDetailsTap,
  });

  // ─────────────────────────────────────────────
  // STATUS COLOR
  // ─────────────────────────────────────────────

  Color _getStatusColor(String status) {
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

  // ─────────────────────────────────────────────
  // INITIALS
  // ─────────────────────────────────────────────

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return '?';
    }

    final parts = name.trim().split(' ');

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  // ─────────────────────────────────────────────
  // INFO ITEM
  // ─────────────────────────────────────────────

  Widget _infoItem(String label, String value) {
    if (value.isEmpty || value == '-') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 0.6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s7,
              fontWeight: FontWeight.w500,
              color: _BC.inkMid,
            ),
          ),

          SizedBox(height: 0.15.h),

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
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);

    final vendorName =
    booking.trek?.vendor?.businessName ??
    'Unknown Vendor';

    final vendorLogo =
        booking.trek?.vendor?.businessLogo ?? '';

    final trekTitle =
        booking.trek?.title ?? '-';

    final tbrId =
        booking.batch?.tbrId ?? '-';

    final startDate =
        booking.batch?.startDate ?? '-';

    final duration =
        booking.trek?.duration ?? '-';

    final bookedSlots =
        booking.batch?.bookedSlots ?? 0;

    final availableSlots =
        booking.batch?.availableSlots ?? 0;

    final statusRaw =
        booking.trekStatus ?? '';

    final statusLabel =
        statusRaw.isNotEmpty
            ? statusRaw[0].toUpperCase() +
                statusRaw.substring(1)
            : '-';

    return GestureDetector(
      onTap: onViewDetailsTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 1.w,
          vertical: 0.7.h,
        ),
        decoration: BoxDecoration(
          color: _BC.bg,
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(
            color: _BC.divider,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            4.w,
            2.h,
            4.w,
            1.2.h,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // ─────────────────────────
              // TOP ROW
              // ─────────────────────────

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Expanded(
                    child: Text(
                      trekTitle,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      textScaler:
                          const TextScaler.linear(1),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s13,
                        fontWeight:
                            FontWeight.w700,
                        color: _BC.ink,
                        height: 1.3,
                      ),
                    ),
                  ),

                  SizedBox(width: 2.w),

                  if (statusRaw.isNotEmpty)
                    Container(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 2.5.w,
                        vertical: 0.4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          statusRaw,
                        ).withOpacity(0.12),
                        borderRadius:
                            BorderRadius.circular(
                          1.5.w,
                        ),
                        border: Border.all(
                          color:
                              _getStatusColor(
                            statusRaw,
                          ).withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        statusLabel,
                        textScaler:
                            const TextScaler.linear(
                          1,
                        ),
                        style: TextStyle(
                          fontFamily:
                              'Poppins',
                          fontSize:
                              FontSize.s8,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              _getStatusColor(
                            statusRaw,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 1.2.h),

              // ─────────────────────────
              // VENDOR ROW
              // ─────────────────────────

              Row(
                children: [

                  Container(
                    width: 11.w,
                    height: 11.w,
                    decoration: BoxDecoration(
                      color: _BC.iconBadge,
                      borderRadius:
                          BorderRadius.circular(
                        2.5.w,
                      ),
                    ),
                    clipBehavior:
                        Clip.antiAlias,
                    child:
                        vendorLogo.isNotEmpty
                            ? CustomNetworkImage(
                                accessToken:
                                    Repository
                                        .token,
                                imageUrl:
                                    vendorLogo,
                                width: 11.w,
                                height: 11.w,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Text(
                                  _initials(
                                    vendorName,
                                  ),
                                  textScaler:
                                      const TextScaler.linear(
                                    1,
                                  ),
                                  style: TextStyle(
                                    fontFamily:
                                        'Poppins',
                                    fontSize:
                                        FontSize
                                            .s10,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                    color: Colors
                                        .white,
                                  ),
                                ),
                              ),
                  ),

                  SizedBox(width: 3.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [

                        Text(
                          vendorName,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          textScaler:
                              const TextScaler.linear(
                            1,
                          ),
                          style: TextStyle(
                            fontFamily:
                                'Poppins',
                            fontSize:
                                FontSize.s12,
                            fontWeight:
                                FontWeight.w600,
                            color: _BC.ink,
                          ),
                        ),

                        SizedBox(height: 0.2.h),

                        Text(
                          'TBR ID: $tbrId',
                          textScaler:
                              const TextScaler.linear(
                            1,
                          ),
                          style: TextStyle(
                            fontFamily:
                                'Poppins',
                            fontSize:
                                FontSize.s8,
                            color:
                                _BC.inkLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 1.4.h),

              // ─────────────────────────
              // INFO ROW
              // ─────────────────────────

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [

                        _infoItem(
                          'Departure Date',
                          startDate,
                        ),

                        _infoItem(
                          'Duration',
                          duration,
                        ),

                        _infoItem(
                          'Available Slots',
                          '$availableSlots seats',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 3.w),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [

                      Text(
                        '$bookedSlots',
                        textScaler:
                            const TextScaler.linear(
                          1,
                        ),
                        style: TextStyle(
                          fontFamily:
                              'Poppins',
                          fontSize:
                              FontSize.s16,
                          fontWeight:
                              FontWeight.w700,
                          color: _BC.ink,
                        ),
                      ),

                      Text(
                        'slots booked',
                        textScaler:
                            const TextScaler.linear(
                          1,
                        ),
                        style: TextStyle(
                          fontFamily:
                              'Poppins',
                          fontSize:
                              FontSize.s8,
                          color:
                              _BC.inkMid,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 1.h),

              Container(
                height: 0.5,
                color: _BC.divider,
              ),

              SizedBox(height: 1.h),

              // ─────────────────────────
              // CTA
              // ─────────────────────────

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [

                  Row(
                    children: [

                      Text(
                        'View details',
                        textScaler:
                            const TextScaler.linear(
                          1,
                        ),
                        style: TextStyle(
                          fontFamily:
                              'Poppins',
                          fontSize:
                              FontSize.s11,
                          fontWeight:
                              FontWeight.w600,
                          color: _BC.brand,
                        ),
                      ),

                      SizedBox(width: 1.w),

                      Icon(
                        Icons
                            .arrow_forward_rounded,
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