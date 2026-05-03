import 'package:animated_rating_stars/animated_rating_stars.dart';
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

class TicketClipper extends CustomClipper<Path> {
  final double cutoutOffset;

  TicketClipper(this.cutoutOffset);

  @override
  Path getClip(Size size) {
    double radius = 2.w;
    double circleRadius = 5.w;
    double verticalPosition = cutoutOffset;

    Path basePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    Path cutouts = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(0, verticalPosition),
          radius: circleRadius,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width, verticalPosition),
          radius: circleRadius,
        ),
      );

    return Path.combine(PathOperation.difference, basePath, cutouts);
  }

  @override
  bool shouldReclip(TicketClipper oldClipper) =>
      oldClipper.cutoutOffset != cutoutOffset;
}

class BookingsUpcomingScreen extends StatefulWidget {
  final dynamic bookingId;
  const BookingsUpcomingScreen({super.key, required this.bookingId});

  @override
  State<BookingsUpcomingScreen> createState() => _BookingsUpcomingScreenState();
}

class _BookingsUpcomingScreenState extends State<BookingsUpcomingScreen>
    with SingleTickerProviderStateMixin {
  final DashboardController _dashboardC = Get.find<DashboardController>();
  late AnimationController _animationController;
  Set<int> openSections = {};
  final GlobalKey _dottedKey = GlobalKey();
  final GlobalKey _cardKey = GlobalKey();
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
  }

  @override
  void dispose() {
    _animationController.dispose();
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

        setState(() {
          cutoutOffset = localOffset + box.size.height / 2;
        });
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
    Future.delayed(const Duration(milliseconds: 100), () {
      _updateCutoutOffset();
    });
  }

  Widget _sectionHeader(String title, int index) {
    bool isOpen = openSections.contains(index);
    return InkWell(
      onTap: () => _toggleSection(index),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: CommonColors.blackColor,
                ),
              ),
            ),
            Icon(
              isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 5.w,
              color: CommonColors.greyTextColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _ticketRow(String title, String value, {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w400,
                color: CommonColors.greyTextColor,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 9.5.sp,
                fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w400,
                color: isHighlight ? CommonColors.blueColor_367FEE : CommonColors.blackColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(BookingHistoryData? booking) {
    if (booking == null) return const SizedBox.shrink();

    final trek = booking.trek;
    final batch = booking.batch;
    final startDate =  DateTime.tryParse(batch?.startDate ?? "");
    final endDate = DateTime.tryParse(batch?.endDate ?? "");
    final bookingDate = booking.bookingDate != null ? DateTime.parse(booking.bookingDate!) : null;

    final cardContent = Container(
      key: _cardKey,
      padding: EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 3.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getStatusGradient(booking.status),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Text(
              _getStatusText(booking.status).toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 8.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Trek Title
          Text(
            trek?.title ?? 'Trek Details',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: CommonColors.blueColor_367FEE,
            ),
          ),
          SizedBox(height: 1.h),

          // Booking Number
          Text(
            'Booking #${booking.bookingNumber ?? 'N/A'}',
            style: GoogleFonts.poppins(
              fontSize: 8.sp,
              fontWeight: FontWeight.w400,
              color: CommonColors.greyTextColor,
            ),
          ),
          SizedBox(height: 2.h),

          // Date Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      startDate != null
                          ? DateFormat('E, dd MMM').format(startDate)
                          : 'Start Date',
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: CommonColors.blackColor,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      trek?.destination?.name ?? 'Starting Point',
                      style: GoogleFonts.poppins(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w400,
                        color: CommonColors.greyTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 0.8.h, horizontal: 1.5.w),
                    decoration: BoxDecoration(
                      color: CommonColors.greyColorEBEBEB,
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Text(
                      trek?.duration?.replaceAll('Days', 'D').replaceAll('Nights', 'N') ?? '2D | 1N',
                      style: GoogleFonts.poppins(
                        fontSize: 7.sp,
                        fontWeight: FontWeight.w500,
                        color: CommonColors.blackColor,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      endDate != null
                          ? DateFormat('E, dd MMM').format(endDate)
                          : 'End Date',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: CommonColors.blackColor,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Destination',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w400,
                        color: CommonColors.greyTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Booking Details Section
          _sectionHeader("Booking Details", 0),
          if (openSections.contains(0)) ...[
            _ticketRow("TBR ID", batch?.tbrId ?? 'N/A'),
            _ticketRow("Booking ID", booking.bookingNumber ?? 'N/A'),
            _ticketRow("Booking Date", bookingDate != null
                ? DateFormat('E, d MMM yyyy').format(bookingDate)
                : 'N/A'),
            SizedBox(height: 1.h),

            // Traveller Details Header
            Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Text(
                "Traveller Details",
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: CommonColors.blackColor,
                ),
              ),
            ),

            // Travellers List Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      "Traveller Name",
                      style: GoogleFonts.poppins(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w500,
                        color: CommonColors.greyTextColor,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Age",
                      style: GoogleFonts.poppins(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w500,
                        color: CommonColors.greyTextColor,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Gender",
                      style: GoogleFonts.poppins(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w500,
                        color: CommonColors.greyTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Travellers List
            ...?booking.travelers?.map((t) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      t.traveler?.name ?? 'N/A',
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w400,
                        color: CommonColors.blackColor,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      t.traveler?.age?.toString() ?? '-',
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w400,
                        color: CommonColors.greyTextColor,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      t.traveler?.gender ?? '-',
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w400,
                        color: CommonColors.greyTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
            SizedBox(height: 2.h),
          ],

          Divider(thickness: 0.5, height: 1),

          // Trek Details Section
          _sectionHeader("Trek Details", 1),
          if (openSections.contains(1)) ...[
            _ticketRow("Trek Operator", trek?.vendor?.businessName ?? 'N/A'),
            _ticketRow("Boarding Point", booking.cityId?.toString() ?? 'To be announced'),
            _ticketRow("Trek Captain", trek?.captainName ?? 'To be announced'),
            _ticketRow("Captain Contact", trek?.captainPhone ?? 'Not available'),
            _ticketRow("Difficulty Level", trek?.difficulty ?? 'Moderate'),
            SizedBox(height: 2.h),
          ],

          Divider(thickness: 0.5, height: 1),

          // Payment Details Section
          _sectionHeader("Payment Details", 2),
          if (openSections.contains(2)) ...[
            _ticketRow("Total Amount", "₹${booking.totalAmount ?? '0'}", isHighlight: true),
            _ticketRow("Discount", "-₹${booking.discountAmount ?? '0'}"),
            _ticketRow("Platform Fees", "₹${booking.platformFees ?? '0'}"),
            _ticketRow("GST", "₹${booking.gstAmount ?? '0'}"),
            _ticketRow("Final Amount", "₹${booking.finalAmount ?? '0'}", isHighlight: true),
            _ticketRow("Payment Status", _getPaymentStatusText(booking.paymentStatus) ?? 'N/A'),
            SizedBox(height: 2.h),
          ],

          SizedBox(height: 3.h),

          // Dotted Line
          DottedLine(
            key: _dottedKey,
            dashColor: CommonColors.greyTextColor.withOpacity(0.5),
            dashLength: 3.5.w,
            dashGapLength: 4.w,
            lineThickness: 0.2.h,
          ),

          SizedBox(height: 2.h),

          // Decorative Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.5.w),
                child: Container(
                  width: 1.5.w,
                  height: 1.5.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CommonColors.greyTextColor.withOpacity(0.5),
                  ),
                ),
              );
            }),
          ),

          SizedBox(height: 2.h),

          // Quote Text
          Padding(
            padding: EdgeInsets.only(left: 1.w),
            child: Text(
              "Not Insta-perfect.\nBut soul-perfect...!!",
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: CommonColors.greyTextColor.withOpacity(0.7),
              ),
            ),
          ),

          SizedBox(height: 1.5.h),

          // Logo
          Align(
            alignment: Alignment.centerRight,
            child: Image.asset(
              'assets/images/img/logo.png',
              width: 25.w,
              height: 4.h,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
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
        );
      },
    );
  }

  List<Color> _getStatusGradient(String? status) {
    switch (status) {
      case 'confirmed':
        return [CommonColors.greyColor_494949, Colors.green.shade700];
      case 'completed':
        return [CommonColors.blueColor_367FEE, Colors.blue.shade700];
      case 'cancelled':
        return [CommonColors.appRedColor, Colors.red.shade700];
      default:
        return [Colors.orange, Colors.orange.shade700];
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

  String? _getPaymentStatusText(String? status) {
    switch (status) {
      case 'full_paid':
        return 'Full Paid';
      case 'partial_paid':
        return 'Partial Paid';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: const Color(0xffF8F9FA),
          appBar: AppBar(
            backgroundColor: CommonColors.lightBlueColor3.withOpacity(0.2),
            scrolledUnderElevation: 0,
            elevation: 0,
            automaticallyImplyLeading: true,
            centerTitle: false,
            title: Text(
              'Booking Details',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: CommonColors.blackColor,
              ),
            ),
          ),
          body: Obx(() {
            final isLoading = _dashboardC.bookingDetailsObserver.value.maybeWhen(
              loading: (ecd) => true,
              orElse: () => false,
            );
            final booking = _dashboardC.bookingDetailsObserver.value.maybeWhen(
              success: (response) => (response as BookingDetailsResponseModel).data,
              orElse: () => null,
            );
            final status = booking?.status;

            if (isLoading) {
              return _buildShimmerLoading();
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  // Ticket Card
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: _buildTicketCard(booking),
                  ),
                  SizedBox(height: 2.h),

                  // Contact Info
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Trek details will be provided on the day of the journey\nvia the following number.",
                          style: GoogleFonts.poppins(
                            fontSize: 8.5.sp,
                            color: CommonColors.greyTextColor,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 0.8.h),
                        if (booking?.trek?.captainName != null)
                          Text(
                            booking?.trek?.captainName ?? "",
                            style: GoogleFonts.poppins(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: CommonColors.blackColor,
                            ),
                          ),
                        SizedBox(height: 0.5.h),
                        if (booking?.trek?.captainPhone != null)
                          Text(
                            booking?.trek?.captainPhone ?? "",
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: CommonColors.blueColor_367FEE,
                            ),
                          )
                        else
                          Text(
                            "Contact number not available",
                            style: GoogleFonts.poppins(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.greyTextColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        Icons.confirmation_num_outlined,
                        "Ticket",
                        onTap: () {
                          Get.to(() => const InvoiceExampleScreen());
                        },
                      ),
                      if (status == 'upcoming' || status == 'confirmed' || status == 'booked')
                        _buildActionButton(
                          Icons.cancel_outlined,
                          "Cancel",
                          onTap: () async {
                            String? bookingId = booking?.id?.toString();
                            if (bookingId != null) {
                              await _dashboardC.getRefundDetail(bookingId);
                              if (_dashboardC.refundDetailData.value.canCancel == false) {
                                final message = _dashboardC.refundDetailData.value.cancellationMessage ??
                                    'Cancellation is not allowed for this booking';
                                SchedulerBinding.instance.addPostFrameCallback((_) {
                                  CustomSnackBar.show(context, message: message);
                                });
                                return;
                              }
                            }
                            Get.toNamed('/bookingscancel', arguments: booking);
                          },
                        ),
                      _buildActionButton(
                        Icons.share_outlined,
                        "Share",
                        onTap: () {
                          CustomSnackBar.show(context, message: 'Share feature coming soon');
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),

                  // FAQ Card
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.w),
                      border: Border.all(color: CommonColors.greyC4C4C4.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: CommonColors.greyC4C4C4),
                        ),
                        child: Icon(
                          Icons.help_outline,
                          size: 6.w,
                          color: CommonColors.blackColor,
                        ),
                      ),
                      title: Text(
                        "Frequently Asked Questions",
                        style: GoogleFonts.poppins(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 4.5.w, color: CommonColors.greyTextColor),
                      onTap: () {
                        CustomSnackBar.show(context, message: 'FAQ coming soon');
                      },
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // Rating Card (for completed status)
                  if (status == 'completed' && booking != null)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: _buildRatingCard(bookingData: booking),
                    ),

                  // Dispute Card
                  if (_dashboardC.disputeDetailDataList.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Obx(() => _buildDisputeCard(
                        disputeData: _dashboardC.disputeDetailDataList,
                      )),
                    ),

                  SizedBox(height: 4.h),

                  // Footer Text
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Go Beyond,\nExplore More!',
                          style: GoogleFonts.sourceSerif4(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: CommonColors.greyColorf7f7f7,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: CommonColors.greyTextColor,
                              fontWeight: FontWeight.w400,
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
                              const TextSpan(text: '\nrooted in Hyderabad.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              color: CommonColors.blueColor_367FEE.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 6.w, color: CommonColors.blueColor_367FEE),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              color: CommonColors.blueColor_367FEE,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisputeCard({required List<Disputes> disputeData}) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: CommonColors.appRedColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: CommonColors.appRedColor,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Dispute Details',
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: CommonColors.blackColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...disputeData.map((dispute) => Column(
            children: [
              _buildDisputeInfoRow('Status', dispute.status ?? 'N/A'),
              SizedBox(height: 1.h),
              _buildDisputeInfoRow('Disputed Amount', '₹${dispute.disputedAmount ?? 0}'),
              SizedBox(height: 1.h),
              _buildDisputeInfoRow('Issue Type', dispute.issueType ?? 'N/A'),
              SizedBox(height: 1.h),
              _buildDisputeInfoRow('Priority', dispute.priority ?? 'N/A'),
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
                decoration: BoxDecoration(
                  color: CommonColors.appRedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Text(
                  'Your dispute is being reviewed by our support team. We will update you soon.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 8.sp,
                    color: CommonColors.appRedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildDisputeInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9.sp,
            color: CommonColors.greyTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 9.sp,
            color: CommonColors.blackColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingCard({required BookingHistoryData bookingData}) {
    return Container(
      padding: EdgeInsets.fromLTRB(6.w, 3.h, 4.w, 3.h),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookingData.ratingGiven == true
                      ? 'Thank you for rating!'
                      : 'Share your trek experience with us!',
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                    color: CommonColors.blackColor,
                  ),
                ),
                SizedBox(height: 1.5.h),
                AnimatedRatingStars(
                  initialRating: bookingData.ratingValue ?? 0.0,
                  readOnly: bookingData.ratingGiven == true,
                  onChanged: (rating) {
                    if (bookingData.ratingGiven != true) {
                      Get.toNamed(
                        '/rate-review',
                        arguments: bookingData,
                      );
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
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 70.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(6.w),
            ),
          ).withShimmerAi(loading: true),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            height: 25.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(4.w),
            ),
          ).withShimmerAi(loading: true),
        ],
      ),
    );
  }
}