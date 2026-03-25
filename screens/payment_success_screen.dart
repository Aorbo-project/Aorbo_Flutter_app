import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/app_dimensions.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:sizer/sizer.dart';

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

class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({super.key});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with TickerProviderStateMixin {
  final TrekController _trekControllerC = Get.find<TrekController>();
  final DashboardController _dashboardC = Get.find<DashboardController>();

  double? screenHeight;
  double greenHeight = 0;
  bool showSecondTick = false;
  bool showCard = false;
  bool showFirstAnimation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        screenHeight = MediaQuery.of(context).size.height;
        setState(() => greenHeight = screenHeight!);
        Future.delayed(const Duration(milliseconds: 4000), () {
          if (mounted) {
            setState(() {
              greenHeight = 20.h;
              showFirstAnimation = false;
              showSecondTick = true;
              showCard = true;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // Clear all booking data after the widget tree unlocks
    // Using post-frame callback to avoid "setState() called during dispose" error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trekControllerC.clearBookingData();
      _dashboardC.clearSearchAndBookingData();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(child: Container(color:   CommonColors.cFFFFFDF9)),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            top: 0,
            left: 0,
            right: 0,
            height: greenHeight > 0 ? greenHeight : 100.h,
            child: Container(
              color: CommonColors.materialGreen,
              child: showFirstAnimation
                  ? Center(
                      child: Lottie.asset(
                        'assets/animations/tick_animation.json',
                        width: 50.w,
                        height: 30.h,
                        repeat: false,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          if (showSecondTick)
            Positioned(
              top: 5.h,
              child: Lottie.asset(
                'assets/animations/bus_animation.json',
                width: 40.w,
                height: 15.h,
                repeat: true,
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            top: showCard ? 18.h : 100.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
              child: Container(
                color: CommonColors.offWhiteColor,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 3.h),
                      _TicketCardSection(),
                      SizedBox(height: 2.h),
                      const _BottomInfoSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCardSection extends StatefulWidget {
  const _TicketCardSection({super.key});

  @override
  State<_TicketCardSection> createState() => _TicketCardSectionState();
}

class _TicketCardSectionState extends State<_TicketCardSection> {
  Set<int> openSections = {}; // now all sections are collapsed initially
  final TrekController _trekControllerC = Get.find<TrekController>();

  final GlobalKey _dottedKey = GlobalKey();
  final GlobalKey _cardKey = GlobalKey();
  double cutoutOffset = 0;

  //
  // final List<Map<String, String>> travellers = [
  //   {"name": "Praveen M", "gender": "M", "age": "21"},
  //   {"name": "Sneha R", "gender": "F", "age": "23"},
  //   {"name": "Praveen M", "gender": "M", "age": "21"},
  //   {"name": "Sneha R", "gender": "F", "age": "23"},
  // ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateCutoutOffset());
  }

  void _updateCutoutOffset() {
    final RenderBox? box =
        _dottedKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? cardBox =
        _cardKey.currentContext?.findRenderObject() as RenderBox?;

    if (box != null && cardBox != null) {
      final position = box.localToGlobal(Offset.zero);
      final cardTop = cardBox.localToGlobal(Offset.zero).dy;
      final localOffset = position.dy - cardTop;

      setState(() {
        cutoutOffset = localOffset + box.size.height / 2;
      });
    }
  }

  Widget sectionHeader(String title, int index) {
    bool isOpen = openSections.contains(index);
    return InkWell(
      onTap: () {
        setState(() {
          if (isOpen) {
            openSections.remove(index);
          } else {
            openSections.add(index);
          }
        });
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _updateCutoutOffset(),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                  color: CommonColors.blackColor,
                  letterSpacing: 16 * 0.05,
                ),
              ),
            ),
            Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget sectionDivider() => Divider(thickness: 0.5, height: 0);

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      key: _cardKey,
      padding: EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 3.h),
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(6.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "A round-trip trek covering ",
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              letterSpacing: 14 * 0.2,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            _trekControllerC.verifyOrderModal.value.data?.trek?.title ?? '-',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              fontFamily: "Roboto",
              color: CommonColors.lightBlueColor2,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Column: Departure
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('E, dd MMM').format(
                        DateTime.parse(
                          _trekControllerC
                                  .verifyOrderModal
                                  .value
                                  .data!
                                  .batch
                                  ?.startDate ??
                              '',
                        ),
                      ),
                      style: TextStyle(
                        fontSize: FontSize.s9,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                        color: CommonColors.blackColor,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _trekControllerC
                              .verifyOrderModal
                              .value
                              .data!
                              .city
                              ?.cityName ??
                          '-',
                      style: TextStyle(
                        fontSize: FontSize.s8,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                        color: CommonColors.blackColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),

              // Center: Duration Tag
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 1.h,
                      horizontal: 2.w,
                    ),
                    decoration: BoxDecoration(
                      color:   CommonColors.cFFF6F6F6,
                      borderRadius: BorderRadius.circular(2.5.w),
                      boxShadow: [
                        BoxShadow(
                          color: CommonColors.blackColor.withValues(alpha: 0.05),
                          blurRadius: 1.w,
                          offset: Offset(0, 0.5.h),
                        ),
                      ],
                    ),
                    child: Text(
                      (_trekControllerC
                                  .verifyOrderModal
                                  .value
                                  .data
                                  ?.trek
                                  ?.duration ??
                              '-')
                          .replaceAll('Days', 'D')
                          .replaceAll('Nights', 'N')
                          .replaceAll(',', ' |'),
                      style: TextStyle(
                        fontSize: FontSize.s7,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                        color: CommonColors.blackColor,
                      ),
                    ),
                  ),
                ),
              ),

              // Right Column: Return
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('E, dd MMM').format(
                        DateTime.parse(
                          _trekControllerC
                                  .verifyOrderModal
                                  .value
                                  .data!
                                  .batch
                                  ?.endDate ??
                              '',
                        ),
                      ),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: FontSize.s9,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                        color: CommonColors.blackColor,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _trekControllerC
                              .verifyOrderModal
                              .value
                              .data!
                              .trek
                              ?.destinationData
                              ?.name ??
                          '-',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: FontSize.s8,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                        color: CommonColors.blackColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 5.h),
          sectionHeader("Booking Details", 0),
          Visibility(
            visible: openSections.contains(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ticketRow(
                  "Ticket No",
                  _trekControllerC.orderData.value.receipt ?? '-',
                ),
                _ticketRow(
                  "Order ID",
                  _trekControllerC.verifyOrderModal.value.payment?.orderId ??
                      '-',
                ),
                _ticketRow(
                  "Date of Booking",
                  DateFormat('E, d MMM hh:mm a').format(
                    DateTime.parse(
                      _trekControllerC
                              .verifyOrderModal
                              .value
                              .data
                              ?.bookingDate ??
                          '-',
                    ).toLocal(),
                  ),
                ),

                SizedBox(height: 1.h),

                // Sub-header for Traveller Details
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Text(
                    "Traveller Details",
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      fontWeight: FontWeight.w500,
                      color: CommonColors.blackColor,
                    ),
                  ),
                ),

                // List of travellers
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row for Traveller Info
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.8.h,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              "Traveller Name",
                              style: TextStyle(
                                fontSize: FontSize.s11,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Poppins",
                                color: CommonColors.blackColor,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Age",
                              style: TextStyle(
                                fontSize: FontSize.s11,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Poppins",
                                color: CommonColors.blackColor,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              "Gender",
                              style: TextStyle(
                                fontSize: FontSize.s11,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Poppins",
                                color: CommonColors.blackColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 0.5.h),

                    // Traveller rows
                    ...?_trekControllerC.verifyOrderModal.value.data?.travelers!
                        .map((t) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    t.traveler?.name ?? '-',
                                    style: TextStyle(
                                      fontSize: FontSize.s10,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Poppins",
                                      color: CommonColors.blackColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    t.traveler?.age.toString() ?? '-',
                                    style: TextStyle(
                                      fontSize: FontSize.s10,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Poppins",
                                      color: CommonColors.cFF555555,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    t.traveler?.gender ?? '-',
                                    style: TextStyle(
                                      fontSize: FontSize.s10,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Poppins",
                                      color: CommonColors.cFF555555,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                        .toList(),
                  ],
                ),

                SizedBox(height: 2.h),
              ],
            ),
          ),
          sectionDivider(),

          SizedBox(height: 0.8.h),
          sectionHeader("Trek Details", 1),
          Visibility(
            visible: openSections.contains(1),
            child: Column(
              children: [
                _ticketRow(
                  "Trek Operator",
                  _trekControllerC
                          .verifyOrderModal
                          .value
                          .data!
                          .vendor
                          ?.companyInfo
                          ?.companyName ??
                      '-',
                ),
                _ticketRow(
                  "Boarding",
                  _trekControllerC
                          .verifyOrderModal
                          .value
                          .data
                          ?.city
                          ?.cityName ??
                      '-',
                ),
                _ticketRow(
                  "Trek Captain",
                  _trekControllerC
                          .verifyOrderModal
                          .value
                          .data!
                          .vendor
                          ?.companyInfo
                          ?.contactPerson ??
                      '-',
                ),
                _ticketRow(
                  "Captain Contact",
                  _trekControllerC
                          .verifyOrderModal
                          .value
                          .data!
                          .vendor
                          ?.companyInfo
                          ?.phone ??
                      '-',
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
          sectionDivider(),

          SizedBox(height: 0.8.h),
          sectionHeader("Payment Details", 2),
          Visibility(
            visible: openSections.contains(2),
            child: Column(
              children: [
                _ticketRow(
                  "Base Fare",
                  _trekControllerC.verifyOrderModal.value.data?.trek?.basePrice
                          .toString() ??
                      '0.00',
                ),
                if (_trekControllerC
                    .verifyOrderModal
                    .value
                    .paymentDetails!
                    .isPartialPayment!)
                  _ticketRow(
                    "Remaining Amount",
                    _trekControllerC
                            .verifyOrderModal
                            .value
                            .paymentDetails
                            ?.remainingAmount
                            .toString() ??
                        '0.00',
                  ),
                // _ticketRow("Tax + Fee", "₹385"),
                _ticketRow(
                  "Total Paid",
                  _trekControllerC.verifyOrderModal.value.payment?.amount
                          .toString() ??
                      '0.00',
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),

          SizedBox(height: 5.h),
          DottedLine(
            key: _dottedKey,
            dashColor: CommonColors.black54,
            dashLength: 3.5.w,
            dashGapLength: 4.w,
            lineThickness: 0.2.h,
          ),

          SizedBox(height: 3.h),
          // Row of 3 dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.6.w),
                child: Container(
                  width: 2.w,
                  height: 2.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CommonColors.cFFA5A5A5,
                  ),
                ),
              );
            }),
          ),

          SizedBox(height: 2.5.h),

          // Text: Aligned Left with padding
          Padding(
            padding: EdgeInsets.only(left: 0.5.w),
            child: Text(
              "Not Insta-perfect.\nBut soul-perfect...!!",
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600,
                color:   CommonColors.cFF868686,
                letterSpacing: 16 * 0.2,
              ),
              textAlign: TextAlign.left,
            ),
          ),

          SizedBox(height: 2.h),

          // Image: Aligned Right
          Padding(
            padding: EdgeInsets.only(right: 0.w),
            child: Align(
              alignment: Alignment.centerRight,
              child: Image.asset(CommonImages.logo1, width: 30.w, height: 5.h),
            ),
          ),

          SizedBox(height: 0.5.h),
        ],
      ),
    );

    return PhysicalShape(
      clipper: TicketClipper(cutoutOffset),
      elevation: 10,
      color: CommonColors.transparent,
      shadowColor: CommonColors.blackColor.withValues(alpha: 0.75),
      child: ClipPath(clipper: TicketClipper(cutoutOffset), child: cardContent),
    );
  }

  Widget _ticketRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11.sp,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w400,
                color:   CommonColors.cFF555555,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 9.5.sp,
                fontFamily: "Poppins",
                fontWeight: value.contains("₹")
                    ? FontWeight.w500
                    : FontWeight.w400,
                color: CommonColors.blackColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomInfoSection extends StatelessWidget {
  const _BottomInfoSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trek info text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text(
              "Trek details will be provided on the day of the journey via the following number.",
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
                color:   CommonColors.cFF5B5B5B,
              ),
            ),
          ),

          SizedBox(height: 1.5.h),

          // Mobile number
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text(
              "+91 9182736579",
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
                color: CommonColors.blackColor,
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Icons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _actionButton(Icons.confirmation_num_outlined, "Ticket"),
              SizedBox(width: 18.w),
              _actionButton(Icons.cancel_outlined, "Cancel"),
              SizedBox(width: 18.w),
              _actionButton(Icons.share_outlined, "Share"),
            ],
          ),

          SizedBox(height: 4.h),

          // FAQ Container
          Container(
            height: 8.h,
            margin: EdgeInsets.symmetric(horizontal: 3.5.w),
            padding: EdgeInsets.symmetric(horizontal: 3.5.w),
            decoration: BoxDecoration(
              color: CommonColors.whiteColor,
              borderRadius: BorderRadius.circular(4.w),
              border: Border.all(color:   CommonColors.cFFE7E7E7),
              boxShadow: [
                BoxShadow(
                  color:   CommonColors.grey100.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: CommonColors.black26),
                  ),
                  child: Icon(
                    Icons.help_outline,
                    size: 20.sp,
                    color: CommonColors.blackColor,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    "Frequently Asked Questions",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                      color: CommonColors.blackColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: CommonColors.black45,
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Go Beyond Text
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              bottom: 30.0,
              left: 0,
              right: 30.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Go Beyond,\nExplore More!',
                  textAlign: TextAlign.start,
                  // textScaler: const TextScaler.linear(1.0),
                  style: GoogleFonts.sourceSerif4(
                    fontSize: FontSize.s28,
                    fontWeight: FontWeight.bold,
                    color: CommonColors.greyColorf7f7f7.withValues(alpha: 0.5),
                    height: 1.3,
                    letterSpacing: 1.8,
                  ),
                ),
                SizedBox(height: AppDimensions.dh(20)),
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: FontSize.s14,
                      color: CommonColors.greyColorf7f7f7,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(text: 'Crafted with passion '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.bottom,
                        child: Icon(
                          Icons.favorite,
                          color: CommonColors.red_B52424,
                          size: FontSize.s12,
                        ),
                      ),
                      TextSpan(text: '\nrooted in Hyderabad.'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 24.sp, color:   CommonColors.lightBlueColor2),
        SizedBox(height: 0.8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            fontFamily: "Roboto",
            color:   CommonColors.lightBlueColor2,
          ),
        ),
      ],
    );
  }
}
