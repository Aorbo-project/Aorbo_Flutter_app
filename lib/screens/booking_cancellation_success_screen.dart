import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import '../controller/dashboard_controller.dart';
import '../controller/trek_controller.dart';
import '../freezed_models/booking/booking_history_model.dart';
import '../models/refund/refund_status_model.dart';
import '../models/treaks/booking_cancelled_modal.dart';
import '../utils/common_colors.dart';
import '../utils/common_booked_details_card.dart';
import '../utils/screen_constants.dart';

class BookingCancellationSuccessScreen extends StatefulWidget {
  final BookingHistoryData? booking;
  final String refund;
  final BookingCancelledData? cancelledData;
  const BookingCancellationSuccessScreen({
    super.key,
    required this.booking,
    required this.refund,
    this.cancelledData,
  });

  @override
  State<BookingCancellationSuccessScreen> createState() =>
      _BookingCancellationSuccessScreenState();
}

class _BookingCancellationSuccessScreenState extends State<BookingCancellationSuccessScreen> {
  final DashboardController dashboardC = Get.find<DashboardController>();
  final TrekController _trekC = Get.find<TrekController>();
  bool _isLoading = true;

  bool get _hasRefund => (widget.cancelledData?.totalRefundableAmount ?? 0) > 0;
  bool get _isAdvanceOnly => widget.cancelledData?.isAdvanceOnly == true;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
    // Start polling if a cash refund was issued
    if (_hasRefund && widget.cancelledData?.bookingId != null) {
      _trekC.startRefundPolling(widget.cancelledData!.bookingId!.toString());
    }
  }

  void _simulateLoading() {
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _trekC.stopRefundPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (booking == null) {
    //   return Scaffold(
    //     appBar: AppBar(title: Text('Error')),
    //     body: Center(child: Text('No booking data found')),
    //   );
    // }

    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: CommonColors.lightBlueColor3.withValues(alpha: 0.2),
            scrolledUnderElevation: 0,
            elevation: 0,
            automaticallyImplyLeading: true,
            centerTitle: false,
            leading: BackButton(
              onPressed: () {
                Get.offAllNamed('/dashboard');
                dashboardC.selectedScreen.value = 1;
                setState(() {});
              },
            ),
            title: Text(
              'Your ticket details',
              style: GoogleFonts.poppins(
                fontSize: FontSize.s13,
                fontWeight: FontWeight.w500,
                color: CommonColors.blackColor,
              ),
            ),
          ),
          body: Stack(
            children: [
              // Light blue background extension
              Container(
                height: 8.h,
                color: CommonColors.lightBlueColor3.withValues(alpha: 0.2),
              ),
              // White container with content
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6.w),
                    topRight: Radius.circular(6.w),
                  ),
                ),
                child: _isLoading
                    ? _buildShimmerLoading()
                    : SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Trek Details Card
                              UpcomingBookingCard(booking: widget.booking!),
                              SizedBox(height: 2.h),

                              // Traveler Details Table
                              _buildTravelerDetailsTable(widget.booking!),
                              SizedBox(height: 2.h),

                              // Cancellation Status Card
                              _buildCancellationStatusCard(widget.booking!, dashboardC),
                              SizedBox(height: 2.h),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTravelerDetailsTable(BookingHistoryData booking) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.1),
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableRow(
            '${booking.travelers?.length ?? 0} Slots',
            booking.travelers
                    ?.map((t) => t.traveler?.name ?? 'Unknown')
                    .join(', ') ??
                'Unknown',
            isHeader: false,
          ),
          Divider(height: 2.h),
          _buildTableRow(
            'Ticket No',
            booking.travelers
                    ?.map((t) => booking.batch?.tbrId ?? 'N/A')
                    .join(', ') ??
                'N/A',
            isHeader: false,
          ),
          Divider(height: 2.h),
          _buildTableRow(
            'Fare',
            '₹ ${booking.finalAmount ?? booking.totalAmount ?? '0'}',
            isHeader: false,
            valueColor: CommonColors.blackColor,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    String label,
    String value, {
    bool isHeader = false,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: FontSize.s10,
              fontWeight: isHeader ? FontWeight.w600 : FontWeight.w400,
              color: CommonColors.greyTextColor,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: FontSize.s10,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: valueColor ?? CommonColors.blackColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancellationStatusCard(
    BookingHistoryData booking,
    DashboardController dashboardC,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.1),
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4F8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.w),
                topRight: Radius.circular(4.w),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ticket Cancelled',
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s14,
                          fontWeight: FontWeight.w600,
                          color: CommonColors.blackColor,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'on ${_formatDate(DateTime.now())}',
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s10,
                          color: CommonColors.greyTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Center(
                    child: Icon(Icons.cancel_outlined,
                        color: Colors.orange.shade700, size: 6.w),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: CommonColors.whiteColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(4.w),
                bottomRight: Radius.circular(4.w),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Context-aware message
                Text(
                  _isAdvanceOnly
                      ? 'Your advance amount is non-refundable. A credit note will be issued for GST reversal.'
                      : _hasRefund
                          ? 'Your refund will be processed to your original payment method.'
                          : 'No refund is applicable for this cancellation.',
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s10,
                    color: CommonColors.blackColor,
                  ),
                ),
                SizedBox(height: 2.h),

                // Refund amount row — only when a cash refund exists
                if (_hasRefund) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Total refund ',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s10,
                              color: CommonColors.greyTextColor,
                            ),
                          ),
                          Text(
                            '₹ ${widget.refund}',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _showRefundStatusSheet(context),
                        child: Text(
                          'Track Refund →',
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s10,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Credit note notice for FLEX-01
                if (_isAdvanceOnly) ...[
                  SizedBox(height: 1.5.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(2.w),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 4.w, color: Colors.amber.shade800),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'A credit note for GST reversal will be shared to your registered email.',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s9,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom sheet showing live refund status — updates via socket or polling.
  void _showRefundStatusSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      builder: (_) => Obx(() {
        final result = _trekC.refundStatusObserver.value;
        RefundStatusData? statusData;
        result.maybeWhen(success: (m) => statusData = m?.data, orElse: () {});
        final isPolling = result.maybeWhen(loading: (_) => true, orElse: () => false);

        return Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Refund Status',
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              if (isPolling || statusData == null)
                const Center(child: CircularProgressIndicator())
              else ...[
                _buildStatusStep('Cancellation Confirmed', true, Icons.check_circle),
                _buildStatusStep(
                  'Refund Initiated',
                  statusData?.refundStatus != null,
                  Icons.currency_rupee,
                ),
                _buildStatusStep(
                  'Being Processed by Bank',
                  statusData?.refundStatus == 'processing' ||
                      statusData?.refundStatus == 'processed',
                  Icons.account_balance,
                ),
                _buildStatusStep(
                  (statusData?.isProcessed ?? false)
                      ? 'Credited — ${_formatSettledAt(statusData?.refundProcessedAt)}'
                      : (statusData?.isFailed ?? false)
                          ? 'Failed — Contact Support'
                          : 'Awaiting Credit',
                  statusData?.isProcessed ?? false,
                  (statusData?.isFailed ?? false) ? Icons.error_outline : Icons.done_all,
                  isFailed: statusData?.isFailed ?? false,
                ),
                SizedBox(height: 2.h),
                Text(
                  statusData?.statusMessage ?? 'Checking refund status...',
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s10,
                    color: CommonColors.greyTextColor,
                  ),
                ),
                if (statusData?.refundSpeed != null) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    'Speed: ${statusData?.refundSpeed == 'instant' ? 'Instant (within minutes)' : 'Normal (3–5 business days)'}',
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s9,
                      color: CommonColors.greyTextColor,
                    ),
                  ),
                ],
              ],
              SizedBox(height: 3.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusStep(String label, bool done, IconData icon, {bool isFailed = false}) {
    final color = isFailed
        ? Colors.red
        : done
            ? Colors.green
            : CommonColors.greyTextColor;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        children: [
          Icon(icon, size: 5.w, color: color),
          SizedBox(width: 3.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: FontSize.s11,
              color: color,
              fontWeight: done ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSettledAt(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main booking card shimmer
          Container(
            width: double.infinity,
            height: 25.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(3.w),
            ),
          ).withShimmerAi(loading: true),
          SizedBox(height: 2.h),

          // Traveler details table shimmer
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: CommonColors.whiteColor,
              borderRadius: BorderRadius.circular(4.w),
              boxShadow: [
                BoxShadow(
                  color: CommonColors.blackColor.withValues(alpha: 0.1),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                // Slots row shimmer
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).withShimmerAi(loading: true),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).withShimmerAi(loading: true),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                // Ticket No row shimmer
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).withShimmerAi(loading: true),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).withShimmerAi(loading: true),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                // Fare row shimmer
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).withShimmerAi(loading: true),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).withShimmerAi(loading: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),

          // Cancellation status card shimmer
          Container(
            decoration: BoxDecoration(
              color: CommonColors.whiteColor,
              borderRadius: BorderRadius.circular(4.w),
              boxShadow: [
                BoxShadow(
                  color: CommonColors.blackColor.withValues(alpha: 0.1),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                // Top section shimmer (light blue background)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F4F8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.w),
                      topRight: Radius.circular(4.w),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 30.w,
                              height: 2.h,
                              decoration: BoxDecoration(
                                color: CommonColors.greyColorEBEBEB,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ).withShimmerAi(loading: true),
                            SizedBox(height: 0.5.h),
                            Container(
                              width: 20.w,
                              height: 1.5.h,
                              decoration: BoxDecoration(
                                color: CommonColors.greyColorEBEBEB,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ).withShimmerAi(loading: true),
                          ],
                        ),
                      ),
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                      ).withShimmerAi(loading: true),
                    ],
                  ),
                ),

                // Bottom section shimmer (white background)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: CommonColors.whiteColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(4.w),
                      bottomRight: Radius.circular(4.w),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Refund message shimmer
                      Container(
                        width: double.infinity,
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).withShimmerAi(loading: true),
                      SizedBox(height: 2.h),

                      // Refund amount and status row shimmer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 35.w,
                            height: 1.5.h,
                            decoration: BoxDecoration(
                              color: CommonColors.greyColorEBEBEB,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ).withShimmerAi(loading: true),
                          Container(
                            width: 25.w,
                            height: 1.5.h,
                            decoration: BoxDecoration(
                              color: CommonColors.greyColorEBEBEB,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ).withShimmerAi(loading: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
