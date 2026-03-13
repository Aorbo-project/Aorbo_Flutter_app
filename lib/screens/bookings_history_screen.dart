import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';
import '../utils/common_booked_card.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final ScrollController _scrollController = ScrollController();

  // String _selectedFilter = 'All Bookings';
  bool _isLoadingMore = false;

  // Static status values for filtering
  List<String> get _statusFilters {
    return ['All Bookings', 'upcoming', 'completed', 'ongoing', 'cancelled'];
  }

  // Filter bookings based on selected status

  // List<BookingHistoryData> getUpcomingBookings(
  //     List<BookingHistoryData> allBookings) {
  //   return allBookings
  //       .where((b) => b.status?.toLowerCase() == "Upcoming")
  //       .toList();
  // }

  @override
  void initState() {
    super.initState();
    // Reset filter to default when screen is initialized
    _dashboardC.selectedFilter.value = 'All Bookings';
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    // Clear the list to ensure shimmer shows on initial load
    _dashboardC.bookingList.clear();
    _dashboardC.getBookingHistory(isRefresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _dashboardC.hasMoreBookings.value) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _dashboardC.getBookingHistory();

    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.whiteColor,
      appBar: AppBar(
        backgroundColor: CommonColors.whiteColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: false,
        title: Text(
          'My Bookings',
          style: GoogleFonts.roboto(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w500,
            color: CommonColors.blackColor,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _showFilterBottomSheet(context);
            },
            child: Container(
              margin: EdgeInsets.only(right: 4.w),
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
              decoration: BoxDecoration(
                border: Border.all(color: CommonColors.greyColor),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _dashboardC.selectedFilter.value,
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s10,
                      fontWeight: FontWeight.w400,
                      color: CommonColors.blackColor,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 5.w,
                    color: CommonColors.blackColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        // Show shimmer loading only for initial load or filter change
        // (when booking list is empty and we're loading)
        if (_dashboardC.isLoadingBookingHistory.value && _dashboardC.bookingList.isEmpty) {
          return _buildShimmerLoading();
        }

        // Show empty state when no bookings and not loading
        if (_dashboardC.bookingList.isEmpty && !_dashboardC.isLoadingBookingHistory.value) {
          return Center(
            child: Text(
              'No bookings found',
              style: GoogleFonts.poppins(
                fontSize: FontSize.s9,
                color: CommonColors.blackColor.withValues(alpha: 0.6),
              ),
            ),
          );
        }

        // Show booking list with pagination loader
        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.only(top: 2.h),
          itemCount: _dashboardC.bookingList.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _dashboardC.bookingList.length) {
              return _buildLoadingIndicator();
            }

            final booking = _dashboardC.bookingList[index];
            return Container(
              margin: EdgeInsets.symmetric(vertical: 2.w),
              child: CommonBookedCard(
                booking: booking,
                onViewDetailsTap: () {
                  final status = booking.status?.toLowerCase().trim();

                  Get.toNamed(
                    '/bookingsupcoming',
                    arguments: {'booking': booking, 'status': status},
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Center(
        child: CircularProgressIndicator(color: CommonColors.blueColor),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 2.h),
      itemCount: 5, // Show 5 shimmer cards
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
          child: _buildShimmerBookingCard(),
        );
      },
    );
  }

  Widget _buildShimmerBookingCard() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.1),
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with trek name and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 2.h,
                  decoration: BoxDecoration(
                    color: CommonColors.greyColorEBEBEB,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).withShimmerAi(loading: true),
              ),
              SizedBox(width: 3.w),
              Container(
                width: 20.w,
                height: 3.h,
                decoration: BoxDecoration(
                  color: CommonColors.greyColorEBEBEB,
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ).withShimmerAi(loading: true),
            ],
          ),
          SizedBox(height: 2.h),

          // Dates row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 15.w,
                      height: 1.5.h,
                      decoration: BoxDecoration(
                        color: CommonColors.greyColorEBEBEB,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).withShimmerAi(loading: true),
                    SizedBox(height: 0.5.h),
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
              ),
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: CommonColors.greyColorEBEBEB,
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ).withShimmerAi(loading: true),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 15.w,
                      height: 1.5.h,
                      decoration: BoxDecoration(
                        color: CommonColors.greyColorEBEBEB,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).withShimmerAi(loading: true),
                    SizedBox(height: 0.5.h),
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
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Bottom section with price and button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20.w,
                    height: 1.5.h,
                    decoration: BoxDecoration(
                      color: CommonColors.greyColorEBEBEB,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).withShimmerAi(loading: true),
                  SizedBox(height: 0.5.h),
                  Container(
                    width: 15.w,
                    height: 2.h,
                    decoration: BoxDecoration(
                      color: CommonColors.greyColorEBEBEB,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).withShimmerAi(loading: true),
                ],
              ),
              Container(
                width: 25.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: CommonColors.greyColorEBEBEB,
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ).withShimmerAi(loading: true),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: CommonColors.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 3.5.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CommonColors.greyColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  'Filter Bookings',
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s11,
                    fontWeight: FontWeight.w600,
                    color: CommonColors.blackColor,
                  ),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _statusFilters.length,
              itemBuilder: (context, index) {
                final filter = _statusFilters[index];
                final isSelected = _dashboardC.selectedFilter.value == filter;
                return InkWell(
                  onTap: () async {
                    setState(() {
                      _dashboardC.selectedFilter.value = filter;
                      // Clear the booking list immediately to show shimmer
                      _dashboardC.bookingList.clear();
                    });
                    // Close the modal immediately after selection
                    Navigator.pop(context);
                    // Then load the data in background
                    _dashboardC.getBookingHistory(isRefresh: true);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? CommonColors.lightBlueColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: CommonColors.greyColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          filter,
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s9,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? CommonColors.blueColor
                                : CommonColors.blackColor,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check,
                            color: CommonColors.blueColor,
                            size: 5.w,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
