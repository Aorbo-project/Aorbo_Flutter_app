import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../utils/common_images.dart';

class SourceLocationScreen extends StatefulWidget {
  const SourceLocationScreen({super.key});

  @override
  State<SourceLocationScreen> createState() => _SourceLocationScreenState();
}

class _SourceLocationScreenState extends State<SourceLocationScreen> {
  final DashboardController _dashboardC = Get.find<DashboardController>();

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  final FocusNode _fromFocus = FocusNode();
  final FocusNode _toFocus = FocusNode();

  List<String> filteredList = [];
  bool _isFromFocused = true;

  @override
  void initState() {
    super.initState();

    filteredList = _getCities();

    /// ✅ Auto focus on FROM (cities) when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_fromFocus);
    });

    _fromFocus.addListener(() {
      if (_fromFocus.hasFocus) {
        setState(() {
          _isFromFocused = true;
          filteredList = _getCities();
        });
      }
    });

    _toFocus.addListener(() {
      if (_toFocus.hasFocus) {
        setState(() {
          _isFromFocused = false;
          filteredList = _getTreks();
        });
      }
    });
  }

  List<String> _getCities() {
    return _dashboardC.citiesData.value.data
        ?.map((e) => e.cityName ?? '')
        .toList() ??
        [];
  }

  List<String> _getTreks() {
    return _dashboardC.trekData.value.data
        ?.map((e) => e.name ?? '')
        .toList() ??
        [];
  }

  void _filter(String query) {
    final sourceList = _isFromFocused ? _getCities() : _getTreks();

    setState(() {
      filteredList = sourceList
          .where((item) =>
          item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _fetchCalendarDates() async {

    if(_dashboardC.selectedCityId.value == 0 || _dashboardC.selectedTrekId.value == 0) return;

    final DateTime currentDate = DateTime.now();
    final DateTime threeMonthsLater = currentDate.add(const Duration(days: 90));

    // Format dates for API
    final String startDateStr = DateFormat('yyyy-MM-dd').format(currentDate);
    final String endDateStr = DateFormat('yyyy-MM-dd').format(threeMonthsLater);

    // Fetch calendar dates
    await _dashboardC.fetchCalenderTrekDates(
      cityId:_dashboardC.selectedCityId.value,
      trekId: _dashboardC.selectedTrekId.value,
      statDate: startDateStr,
      endDate: endDateStr,
    );
  }


  void _onItemTap(String value) async {   // add 'async'
    // Update selection first (city or trek)
    if (_isFromFocused) {
      final city = _dashboardC.citiesData.value.data
          ?.firstWhere((c) => c.cityName == value);
      _dashboardC.selectedCityId.value = city?.id ?? 0;
      _dashboardC.fromController.value.text = value;
      _fromController.text = value;
      FocusScope.of(context).requestFocus(_toFocus);
    } else {
      final trek = _dashboardC.trekData.value.data
          ?.firstWhere((t) => t.name == value);
      _dashboardC.selectedTrekId.value = trek?.id ?? 0;
      _dashboardC.toController.value.text = value;
      _toController.text = value;
      _toFocus.unfocus();
    }

    // ✅ Wait for calendar API to finish
    await _fetchCalendarDates();

    // ✅ Then navigate back
    if (_fromController.text.isNotEmpty && _toController.text.isNotEmpty) {
      Get.back();
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.whiteColor,
      appBar: AppBar(
        backgroundColor: CommonColors.whiteColor,
        title: Text(
          "Select Locations",
          style: GoogleFonts.poppins(
            fontSize: FontSize.s12,
            color: CommonColors.blackColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            Container(
              height: 5.5.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.h),
                border: Border.all(color: Colors.grey[300]!, width: 0.1.h),
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey.shade100],
                ),
              ),
              alignment: Alignment.center,
              child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(1.0)),
                child: TextField(
                  controller: _fromController,
                  focusNode: _fromFocus,
                  onChanged: _filter,
                  textAlign: TextAlign.start, // ✅ important
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s11,
                    color: CommonColors.blackColor,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding:
                      EdgeInsets.all(10),
                      child: SvgPicture.asset(
                        CommonImages.location3,
                        height: ScreenConstant.size24,
                        width: ScreenConstant.size24,
                        colorFilter: ColorFilter.mode(
                            CommonColors.grey_AEAEAE,
                            BlendMode.srcIn),
                      ),
                    ),
                    hintText: "From City",
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 1.2.h,
                      horizontal: 2.w, // ✅ spacing after icon
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              height: 5.5.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.h),
                border: Border.all(color: Colors.grey[300]!, width: 0.1.h),
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey.shade100],
                ),
              ),
              alignment: Alignment.center,
              child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(1.0)),
                child: TextField(
                  controller: _toController,
                  focusNode: _toFocus,
                  onChanged: _filter,
                  textAlign: TextAlign.start, // ✅ important
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s11,
                    color: CommonColors.blackColor,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding:
                      EdgeInsets.all(10),
                      child: SvgPicture.asset(
                        CommonImages.location2,
                        height: ScreenConstant.size24,
                        width: ScreenConstant.size24,
                        colorFilter: ColorFilter.mode(
                            CommonColors.grey_AEAEAE,
                            BlendMode.srcIn),
                      ),
                    ),
                    hintText: "Select Trek",
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 1.2.h,
                      horizontal: 2.w,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(_isFromFocused ? "Popular Cities" : "Popular Treks",style: TextStyle(fontWeight: FontWeight.w600,color: CommonColors.blackColor,fontSize: 16.sp)),
            SizedBox(height: 1.h),
            /// SINGLE LIST
            Expanded(
              child: Obx(() {
                final isLoading = _isFromFocused
                    ? _dashboardC.isLoadingCities.value
                    : _dashboardC.isLoadingTreks.value;


                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.separated(
                  itemCount: filteredList.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 0.1.h,
                    color: Colors.grey[300],
                  ),
                  itemBuilder: (context, index) {
                    final item = filteredList[index];

                    return ListTile(
                      title: Text(
                        item,
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s10,
                          color: CommonColors.textColor2,
                        ),
                      ),
                      onTap: () => _onItemTap(item),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _fromFocus.dispose();
    _toFocus.dispose();
    super.dispose();
  }
}
