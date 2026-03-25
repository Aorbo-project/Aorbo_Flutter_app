import 'package:arobo_app/utils/app_logger.dart';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_touch_ripple/flutter_touch_ripple.dart';

enum LocationType { city, trek }

class Location {
  final String name;
  Location({required this.name});
}

class SourceLocationScreen extends StatefulWidget {
  final String hintText;
  final String title;
  final LocationType locationType;

  const SourceLocationScreen({
    super.key,
    required this.hintText,
    required this.title,
    this.locationType = LocationType.city,
  });

  @override
  State<SourceLocationScreen> createState() => _SourceLocationScreenState();
}

class _SourceLocationScreenState extends State<SourceLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late List<String> filteredLocations;
  bool _isSearchFocused = false;
  final DashboardController _dashboardC = Get.find<DashboardController>();

  @override
  void initState() {
    super.initState();
    filteredLocations = _getLocations();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  List<String> _getLocations() {
    if (widget.locationType == LocationType.city) {
      return _dashboardC.citiesData.value.data
              ?.map((city) => city.cityName ?? '')
              .toList() ??
          [];
    } else {
      return _dashboardC.trekData.value.data
              ?.map((trek) => trek.name ?? '')
              .toList() ??
          [];
    }
  }

  List<String> get _popularLocations {
    if (widget.locationType == LocationType.city) {
      return _dashboardC.citiesData.value.data
              ?.where((city) => city.isPopular ?? false)
              .map((city) => city.cityName ?? '')
              .toList() ??
          [];
    } else {
      return _dashboardC.trekData.value.data
              ?.where((trek) => trek.isPopular ?? false)
              .map((trek) => trek.name ?? '')
              .toList() ??
          [];
    }
  }

  void _filterLocations(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredLocations = _getLocations();
      } else {
        filteredLocations = _getLocations()
            .where((location) =>
                location.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  bool get _shouldShowTitle {
    if (_searchController.text.isEmpty) return true;
    return false;
  }

  bool get _isLoading {
    return widget.locationType == LocationType.city
        ? _dashboardC.isLoadingCities.value
        : _dashboardC.isLoadingTreks.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.whiteColor,
      appBar: AppBar(
        backgroundColor: CommonColors.whiteColor,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Stack(
          children: [
            Container(
              height: 5.5.h,
              width: 70.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.h),
                border: Border.all(color: CommonColors.grey500!, width: 0.1.h),
                gradient: LinearGradient(
                  colors: [CommonColors.whiteColor, CommonColors.grey500],
                ),
              ),
              alignment: Alignment.center,
              child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(1.0)),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _filterLocations,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s11,
                    color: CommonColors.blackColor,
                    letterSpacing: 0.5.w,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: _isSearchFocused ? '' : widget.hintText,
                    hintStyle: GoogleFonts.poppins(
                      color: CommonColors.blackColor,
                      fontSize: FontSize.s10,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5.w,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 1.2.h,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.h),
                child: TouchRipple(
                  rippleColor: CommonColors.blackColor.withValues(alpha: 0.1),
                  onTap: () {
                    FocusScope.of(context).requestFocus(_searchFocusNode);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: CommonColors.transparent,
                      borderRadius: BorderRadius.circular(3.h),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_shouldShowTitle)
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Text(
                    widget.title,
                    textScaler: const TextScaler.linear(1.0),
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s12,
                      fontWeight: FontWeight.w500,
                      color: CommonColors.blackColor,
                    ),
                  ),
                ],
              ),
            ),
          // Locations List
          Expanded(
            child: Obx(() {
              if (_isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final locations = _searchController.text.isEmpty
                  ? _popularLocations
                  : filteredLocations;

              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: locations.length,
                separatorBuilder: (context, index) => Divider(
                  height: 0.1.h,
                  color: CommonColors.grey500,
                ),
                itemBuilder: (context, index) {
                  final locationName = locations[index];
                  final location = widget.locationType == LocationType.city
                      ? _dashboardC.citiesData.value.data?.firstWhere(
                          (city) => city.cityName == locationName,
                          orElse: () =>
                              _dashboardC.citiesData.value.data!.first)
                      : null;

                  final trek = widget.locationType == LocationType.trek
                      ? _dashboardC.trekData.value.data?.firstWhere(
                          (trek) => trek.name == locationName,
                          orElse: () => _dashboardC.trekData.value.data!.first)
                      : null;

                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0.5.h,
                      horizontal: 3.w,
                    ),
                    title: Text(
                      locationName,
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s10,
                        color: CommonColors.textColor2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      if (widget.locationType == LocationType.city &&
                          location != null) {
                        _dashboardC.selectedCityId.value = location.id ?? 0;
                        appLog("message: ${location.id}");
                        appLog("message: ${location.cityName}");
                        appLog("message: ${index}");
                        _dashboardC.fromController.value.text =
                            location.cityName ?? '';
                      } else if (widget.locationType == LocationType.trek &&
                          trek != null) {
                        _dashboardC.selectedTrekId.value = trek.id ?? 0;
                        _dashboardC.toController.value.text = trek.name ?? '';
                      }
                      Navigator.pop(context);
                    },
                    splashColor: CommonColors.blackColor.withValues(alpha: 0.1),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
