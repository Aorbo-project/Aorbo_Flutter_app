import 'dart:math';

import 'package:arobo_app/freezed_models/booking/booking_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/models/treaks/treak_detail_modal.dart';
import 'package:arobo_app/utils/booking_constants.dart';
import 'package:arobo_app/utils/common_btn.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/total_fare_modal.dart';

import '../freezed_models/profile/user_profile_model.dart';

/// Screen for collecting traveller information and managing booking details
/// Handles user contact details, traveller selection, and payment options
class TravellerInformationScreen extends StatefulWidget {
  const TravellerInformationScreen({Key? key}) : super(key: key);

  @override
  State<TravellerInformationScreen> createState() =>
      _TravellerInformationScreenState();
}

class _TravellerInformationScreenState extends State<TravellerInformationScreen> with SingleTickerProviderStateMixin {

  final TrekController _trekControllerC = Get.find<TrekController>();
  final DashboardController _dashboardC = Get.find<DashboardController>();
  final UserController _userC = Get.find<UserController>();
  late TrekDetailData travelData;
  final nameNode = FocusNode();

  String _selectedState = BookingConstants.defaultState;
  List<String> filteredStates = [];

  bool _whatsappUpdates = false;
  String _selectedPaymentOption = "standard";

  final GlobalKey _checkboxKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  // List to store selected traveller data
  List<Traveler> selectedTravellers = [];

  @override
  void initState() {
    super.initState();
    filteredStates = _dashboardC.stateList
        .map((element) => element.name!)
        .toList();

    travelData = _trekControllerC.trekDetailData.value;

    _trekControllerC.calculateFareRequestModel.value = _trekControllerC.calculateFareRequestModel.value.copyWith(batchId: travelData.batchInfo?.id ?? 1, travelerCount: 1,addInsurance: false,addFreeCancellationProtection: false,couponCode: "",cancellationPolicyType: "standard");
    _trekControllerC.calculateFare();


    debounce(
      _trekControllerC.calculateFareRequestModel,
          (value) {
        // This will be called after 500ms of no changes
        print('Searching for: $value');
        _trekControllerC.calculateFare();
      },
      time: Duration(milliseconds: 500),
    );

  }

  @override
  void dispose() {
    _removeOverlay();
    nameNode.dispose();
    _userC.nameControllerTraveller.value.clear();
    _userC.ageControllerTraveller.value.clear();
    _userC.selectedGender.value = '';
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Method to format date from "2025-09-05" to "05-09-2025"
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '-';
    }

    try {
      List<String> dateParts = dateString.split('-');
      if (dateParts.length == 3) {
        return '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  /// Calculates the end date based on start date and duration
  String _calculateEndDate(String? startDate, int? durationDays) {
    if (startDate == null || startDate.isEmpty || durationDays == null) {
      return '-';
    }

    try {
      DateTime start = DateTime.parse(startDate);
      DateTime end = start.add(Duration(days: durationDays));
      String day = end.day.toString().padLeft(2, '0');
      String month = end.month.toString().padLeft(2, '0');
      String year = end.year.toString();
      return '$day-$month-$year';
    } catch (e) {
      return '-';
    }
  }

  void _showTickOverlay(BuildContext context) {
    _removeOverlay();

    final RenderBox? checkbox =
    _checkboxKey.currentContext?.findRenderObject() as RenderBox?;
    if (checkbox == null) return;

    final position = checkbox.localToGlobal(Offset.zero);
    final size = checkbox.size;

    final checkboxCenterX = position.dx + (size.width / 2);
    final checkboxCenterY = position.dy + (size.height / 2);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          ...List.generate(12, (index) {
            final angle = (index * (360 / 12)) * (pi / 180);
            return Positioned(
              left: checkboxCenterX - 2,
              top: checkboxCenterY - 2,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(
                      cos(angle) * (40 * value),
                      sin(angle) * (40 * value),
                    ),
                    child: Opacity(
                      opacity: 1 - value,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: CommonColors.lightBlueColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          ...List.generate(6, (index) {
            final angle = (index * (360 / 6)) * (pi / 180);
            final delay = (index * 100);

            return Positioned(
              left: checkboxCenterX - 15,
              top: checkboxCenterY - 15,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  final delayedValue = value == 0
                      ? 0.0
                      : ((value * 1000 - delay) / (800 - delay)).clamp(
                    0.0,
                    1.0,
                  );

                  final yOffset = sin(value * pi * 2) * 20;
                  final distance = 60 * delayedValue;

                  return Transform.translate(
                    offset: Offset(
                      cos(angle) * distance,
                      (sin(angle) * distance) + yOffset,
                    ),
                    child: Transform.scale(
                      scale: delayedValue * (1 - delayedValue * 0.5),
                      child: Opacity(
                        opacity: 1 - delayedValue,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: CommonColors.lightBlueColor,
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check,
                            color: CommonColors.lightBlueColor,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                onEnd: index == 0 ? _removeOverlay : null,
              ),
            );
          }),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Shows bottom sheet for contact details (add/edit)
  void _showContactDetailsBottomSheet({bool isEdit = false}) {
    // Reset controllers with current values
    _userC.phoneNumberController.value.text =
    (isEdit && _userC.userProfileData.value.customer?.phone != null)
        ? _userC.userProfileData.value.customer!.phone!.replaceFirst('+91', '')
        : '';
    _userC.emailController.value.text =
    (isEdit && _userC.userProfileData.value.customer?.email != null)
        ? _userC.userProfileData.value.customer!.email!
        : '';

    if (isEdit && _userC.userProfileData.value.customer?.state != null) {
      _userC.stateUpdateId.value = _userC.userProfileData.value.customer!.state!.id!;
      _selectedState = _userC.userProfileData.value.customer!.state!.name ?? '-';
    } else {
      _userC.stateUpdateId.value = 0;
      _selectedState = BookingConstants.defaultState;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.50,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: CommonColors.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 6.w,
                right: 6.w,
                top: 2.h,
                bottom: 2.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Edit Contact Details' : 'Add Contact Details',
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.alexandria(
                          fontSize: FontSize.s16,
                          fontWeight: FontWeight.w600,
                          color: CommonColors.blackColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, size: 6.w),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Trip ticket details will be provided to',
                    textScaler: const TextScaler.linear(1.0),
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s8,
                      color: CommonColors.blackColor.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Phone Row
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF878787)),
                      borderRadius: BorderRadius.circular(2.w),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 27.w,
                          padding: EdgeInsets.symmetric(vertical: 1.2.h),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Color(0xFF878787),
                                width: 0.25.w,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Country Code',
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s7,
                                  color: CommonColors.blackColor,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              SizedBox(height: 0.4.h),
                              Text(
                                '+91(IND)',
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s10,
                                  fontWeight: FontWeight.w400,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 3.w,
                              right: 3.w,
                              top: 0.8.h,
                              bottom: 0.8.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Phone Number',
                                  textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s7,
                                    color: CommonColors.blackColor,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                    textScaler: TextScaler.linear(1.0),
                                  ),
                                  child: TextField(
                                    controller: _userC.phoneNumberController.value,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s10,
                                      color: CommonColors.blackColor,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      counterText: '',
                                      isDense: true,
                                    ),
                                    onChanged: (value) {
                                      setModalState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.8.h),
                  // Email
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF878787)),
                      borderRadius: BorderRadius.circular(2.w),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.only(
                      left: 4.w,
                      top: 0.8.h,
                      bottom: 0.8.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email ID',
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s7,
                            color: CommonColors.blackColor,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            textScaler: TextScaler.linear(1.0),
                          ),
                          child: TextField(
                            controller: _userC.emailController.value,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s10,
                              fontWeight: FontWeight.w400,
                              color: CommonColors.blackColor,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (value) {
                              setModalState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.8.h),
                  // State
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF878787)),
                      borderRadius: BorderRadius.circular(2.w),
                      color: Colors.white,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showStateSelectionBottomSheet(setModalState),
                        borderRadius: BorderRadius.circular(2.w),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'State of Residence',
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s7,
                                      color: CommonColors.blackColor,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(height: 0.25.h),
                                  Text(
                                    _selectedState,
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s10,
                                      fontWeight: FontWeight.w400,
                                      color: CommonColors.blackColor,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black,
                                size: 6.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  CommonButton(
                    height: 48,
                    gradient: CommonColors.filterGradient,
                    text: isEdit ? 'Update' : 'Save',
                    textColor: CommonColors.whiteColor,
                    onPressed: () async {
                      if (_validateContactDetails()) {
                        await _userC.updateUserProfile();
                        setState(() {});
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEdit ? 'Contact details updated successfully' : 'Contact details saved successfully',
                              textScaler: const TextScaler.linear(1.0),
                            ),
                            backgroundColor: CommonColors.completedColor,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Shows bottom sheet for traveller details (add/edit)
  void _showTravellerBottomSheet({Traveler? traveller, bool isEdit = false}) {
    // Reset or set controllers based on edit mode
    if (isEdit && traveller != null) {
      _userC.travellerId.value = traveller.id ?? 0;
      _userC.nameControllerTraveller.value.text = traveller.name ?? '';
      _userC.ageControllerTraveller.value.text = traveller.age.toString() ?? '';
      _userC.selectedGender.value = traveller.gender ?? '';
    } else {
      _userC.travellerId.value = 0;
      _userC.nameControllerTraveller.value.clear();
      _userC.ageControllerTraveller.value.clear();
      _userC.selectedGender.value = '';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: CommonColors.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 6.w,
                right: 6.w,
                top: 2.h,
                bottom: 2.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Edit Traveller' : 'Add New Traveller',
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.alexandria(
                          fontSize: FontSize.s16,
                          fontWeight: FontWeight.w600,
                          color: CommonColors.blackColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, size: 6.w),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  _buildTextFieldInSheet(
                    _userC.nameControllerTraveller.value,
                    'Name',
                    focusNode: nameNode,
                    onChanged: () => setModalState(() {}),
                  ),
                  SizedBox(height: 2.h),
                  _buildTextFieldInSheet(
                    _userC.ageControllerTraveller.value,
                    'Age',
                    keyboardType: TextInputType.number,
                    onChanged: () => setModalState(() {}),
                  ),
                  SizedBox(height: 1.7.h),
                  Text(
                    'Gender',
                    textScaler: const TextScaler.linear(1.0),
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w300,
                      color: CommonColors.blackColor.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      _buildGenderButtonInSheet('Male', setModalState),
                      SizedBox(width: 2.w),
                      _buildGenderButtonInSheet('Female', setModalState),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  CommonButton(
                    height: 48,
                    gradient: CommonColors.filterGradient,
                    text: isEdit ? 'Update Traveller' : 'Add Traveller',
                    textColor: CommonColors.whiteColor,
                    onPressed: () async {
                      if (_validateTravellerDetails()) {
                        if (isEdit) {
                          await _userC.updateTraveler();
                        } else {
                          await _userC.addTraveler();
                        }
                        setState(() {});
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEdit ? 'Traveller updated successfully' : 'Traveller added successfully',
                              textScaler: const TextScaler.linear(1.0),
                            ),
                            backgroundColor: CommonColors.completedColor,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextFieldInSheet(
      TextEditingController controller,
      String hint, {
        TextInputType keyboardType = TextInputType.text,
        int? maxLength,
        FocusNode? focusNode,
        VoidCallback? onChanged,
      }) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        focusNode: focusNode,
        maxLength: maxLength,
        onChanged: (_) => onChanged?.call(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: FontSize.s11,
            fontWeight: FontWeight.w300,
            color: CommonColors.blackColor.withAlpha(153),
          ),
          counterText: '',
          contentPadding: const EdgeInsets.only(left: 21, top: 13, bottom: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF878787)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF878787)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF90CAF9)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: GoogleFonts.poppins(
          fontSize: FontSize.s10,
          color: CommonColors.blackColor,
        ),
      ),
    );
  }

  Widget _buildGenderButtonInSheet(String gender, StateSetter setModalState) {
    final bool isSelected =
        _userC.selectedGender.value.toLowerCase() == gender.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setModalState(() {
            _userC.selectedGender.value = gender;
          });
        },
        child: Container(
          height: 5.5.h,
          decoration: BoxDecoration(
            border: Border.all(
              color: _userC.selectedGender.value == gender
                  ? CommonColors.blueColor
                  : Color(0xFF878787),
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Container(
            margin: EdgeInsets.only(
              left: 4.5.w,
              right: 2.5.w,
              top: 1.h,
              bottom: 1.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  gender,
                  textScaler: const TextScaler.linear(1.0),
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s10,
                    fontWeight: FontWeight.w500,
                    color: CommonColors.blackColor.withValues(alpha: 0.6),
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected ? CommonColors.radioBtnGradient : null,
                    border: isSelected
                        ? null
                        : Border.all(
                      color: CommonColors.greyColor585858,
                      width: 2,
                    ),
                    color: Colors.white,
                  ),
                  child: isSelected
                      ? Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _validateContactDetails() {
    String phone = _userC.phoneNumberController.value.text.trim();
    String email = _userC.emailController.value.text.trim();

    if (phone.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid 10-digit phone number'),
          backgroundColor: CommonColors.appRedColor,
        ),
      );
      return false;
    }

    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: CommonColors.appRedColor,
        ),
      );
      return false;
    }

    if (_userC.stateUpdateId.value == 0 || _selectedState.isEmpty || _selectedState == '-') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your state of residence'),
          backgroundColor: CommonColors.appRedColor,
        ),
      );
      return false;
    }

    return true;
  }

  bool _validateTravellerDetails() {
    String name = _userC.nameControllerTraveller.value.text.trim();
    String age = _userC.ageControllerTraveller.value.text.trim();
    String gender = _userC.selectedGender.value;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter traveller name'),
          backgroundColor: CommonColors.appRedColor,
        ),
      );
      return false;
    }

    if (age.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter traveller age'),
          backgroundColor: CommonColors.appRedColor,
        ),
      );
      return false;
    }

    int? ageValue = int.tryParse(age);
    if (ageValue == null || ageValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid age'),
          backgroundColor: CommonColors.appRedColor,
        ),
      );
      return false;
    }

    if (gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select gender'),
          backgroundColor: CommonColors.appRedColor,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _showStateSelectionBottomSheet(StateSetter setModalState) async {
    TextEditingController searchController = TextEditingController();

    setState(() {
      filteredStates = _dashboardC.stateList
          .map((element) => element.name!)
          .toList();
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CommonColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 2.5.h,
                  left: 5.w,
                  right: 5.w,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Select state of residence",
                      textScaler: const TextScaler.linear(1.0),
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s14,
                        fontWeight: FontWeight.w600,
                        color: CommonColors.blackColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      height: 6.h,
                      padding: EdgeInsets.symmetric(horizontal: 2.5.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [CommonColors.whiteColor, Color(0xFFF8FBFF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(3.75.w),
                        border: Border.all(
                          color: Color(0xffd5d5d5),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey, size: 6.w),
                          SizedBox(width: 2.5.w),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: "Search State",
                                border: InputBorder.none,
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: FontSize.s10,
                                  color: CommonColors.blackColor.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s10,
                                color: CommonColors.blackColor,
                              ),
                              onChanged: (value) {
                                setSheetState(() {
                                  filteredStates = _dashboardC.stateList
                                      .map((element) => element.name!)
                                      .toList()
                                      .where(
                                        (state) => state.toLowerCase().contains(
                                      value.toLowerCase(),
                                    ),
                                  )
                                      .toList();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.25.h),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredStates.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              filteredStates[index],
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s10,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.blackColor,
                              ),
                            ),
                            onTap: () {
                              setModalState(() {
                                _userC.stateUpdateId.value = _dashboardC
                                    .stateList[_dashboardC.stateList.indexWhere(
                                      (element) =>
                                  element.name == filteredStates[index],
                                )]
                                    .id!;
                                _selectedState = filteredStates[index];
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        filteredStates = _dashboardC.stateList
            .map((element) => element.name!)
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CommonColors.whiteColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: CommonColors.blackColor),
        titleSpacing: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: CommonColors.greyColor, height: 1.5),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              textScaler: const TextScaler.linear(1.0),
              'Traveller Information',
              style: GoogleFonts.poppins(
                fontSize: FontSize.s11,
                fontWeight: FontWeight.w600,
                color: CommonColors.blackColor,
              ),
            ),
            Row(
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_dashboardC.fromController.value.text.isNotEmpty)
                        Flexible(
                          child: Text(
                            _dashboardC.fromController.value.text,
                            textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s9,
                              fontWeight: FontWeight.w400,
                              color: CommonColors.blackColor,
                            ),
                          ),
                        ),
                      if (_dashboardC.fromController.value.text.isNotEmpty &&
                          _dashboardC.toController.value.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.arrow_forward_outlined,
                            color: CommonColors.grey_AEAEAE,
                            size: 16,
                          ),
                        ),
                      if (_dashboardC.toController.value.text.isNotEmpty)
                        Flexible(
                          child: Text(
                            _dashboardC.toController.value.text,
                            textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s9,
                              fontWeight: FontWeight.w400,
                              color: CommonColors.blackColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              padding: const EdgeInsets.only(
                  left: 8, right: 8, top: 9, bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Slot Booking Details Section
                  Container(
                    width: 99.w,
                    decoration: BoxDecoration(
                      color: CommonColors.lightBlueColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 99.w,
                          margin: const EdgeInsets.only(top: 14),
                          child: Column(
                            children: [
                              Text(
                                'A round-trip trek covering',
                                textScaler: const TextScaler.linear(1.0),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s9,
                                  fontWeight: FontWeight.w400,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                              Text(
                                travelData.title ?? '-',
                                textScaler: const TextScaler.linear(1.0),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s9,
                                  fontWeight: FontWeight.w700,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          width: 99.w,
                          height: 5.8.h,
                          margin: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            bottom: 14,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,
                                  children: [
                                    MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                        textScaler: const TextScaler.linear(
                                            1.0),
                                      ),
                                      child: Text(
                                        _formatDate(
                                            travelData.batchInfo?.startDate),
                                        style: GoogleFonts.poppins(
                                          fontSize: FontSize.s9,
                                          fontWeight: FontWeight.w500,
                                          color: CommonColors.blackColor,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _dashboardC.fromController.value.text,
                                      textScaler: const TextScaler.linear(
                                          1.0),
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s8,
                                        fontWeight: FontWeight.w400,
                                        color: CommonColors.blackColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 14, right: 14),
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  top: 4,
                                  bottom: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${travelData.durationDays}D|${travelData
                                      .durationNights}N',
                                  textAlign: TextAlign.center,
                                  textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s9,
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.blackColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                        textScaler: const TextScaler.linear(
                                            1.0),
                                      ),
                                      child: Text(
                                        _calculateEndDate(
                                          travelData.batchInfo?.startDate,
                                          travelData.durationDays,
                                        ),
                                        textScaler: const TextScaler.linear(
                                            1.0),
                                        style: GoogleFonts.poppins(
                                          fontSize: FontSize.s9,
                                          fontWeight: FontWeight.w500,
                                          color: CommonColors.blackColor,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _dashboardC.toController.value.text,
                                      textScaler: const TextScaler.linear(
                                          1.0),
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s8,
                                        fontWeight: FontWeight.w400,
                                        color: CommonColors.blackColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                    child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      decoration: BoxDecoration(
                        color: CommonColors.whiteColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: CommonColors.blackColor.withValues(
                                alpha: 0.2),
                            offset: Offset(2, 2),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0),
                            child: Center(
                              child: Text(
                                'Travellers',
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s14,
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                            ),
                          ),
                          Container(
                              height: 1.5, color: CommonColors.greyColor),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 46.0,
                              right: 28.0,
                              top: 15.0,
                              bottom: 13.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      'Adults',
                                      textScaler: const TextScaler.linear(
                                          1.0),
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s11,
                                        fontWeight: FontWeight.w600,
                                        color: CommonColors.blackColor,
                                      ),
                                    ),
                                    Text(
                                      '18+ years',
                                      textScaler: const TextScaler.linear(
                                          1.0),
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s9,
                                        fontWeight: FontWeight.w400,
                                        color: CommonColors.blackColor
                                            .withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Obx(() {
                                  final adultCount = _trekControllerC
                                      .calculateFareRequestModel.value
                                      .travelerCount;
                                  return Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (adultCount > 1) {
                                              _trekControllerC
                                                  .calculateFareRequestModel
                                                  .value = _trekControllerC
                                                  .calculateFareRequestModel
                                                  .value.copyWith(
                                                  travelerCount: _trekControllerC
                                                      .calculateFareRequestModel
                                                      .value.travelerCount -
                                                      1);
                                              if (selectedTravellers.length >
                                                  adultCount) {
                                                selectedTravellers =
                                                    selectedTravellers
                                                        .take(adultCount)
                                                        .toList();
                                              }
                                            }
                                          });
                                          _trekControllerC.trekPersonCount
                                              .value = adultCount;
                                          _trekControllerC.travellerDetailList
                                              .value =
                                              selectedTravellers;
                                        },
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: CommonColors
                                                  .blueColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.remove,
                                              size: 20,
                                              color: CommonColors
                                                  .blueColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                        ),
                                        child: Text(
                                          '$adultCount',
                                          textScaler: const TextScaler.linear(
                                              1.0),
                                          style: GoogleFonts.poppins(
                                            fontSize: FontSize.s14,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.blackColor,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (adultCount <
                                              (travelData.batchInfo
                                                  ?.availableSlots ?? 0)) {
                                            _trekControllerC
                                                .calculateFareRequestModel
                                                .value = _trekControllerC
                                                .calculateFareRequestModel
                                                .value.copyWith(
                                                travelerCount: _trekControllerC
                                                    .calculateFareRequestModel
                                                    .value.travelerCount + 1);
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Maximum available slots reached (${(travelData
                                                      .batchInfo
                                                      ?.availableSlots ??
                                                      0)})',
                                                  textScaler: const TextScaler
                                                      .linear(
                                                    1.0,
                                                  ),
                                                ),
                                                backgroundColor:
                                                CommonColors.appRedColor,
                                                duration: Duration(
                                                    seconds: 2),
                                              ),
                                            );
                                          }
                                          _trekControllerC.trekPersonCount
                                              .value =
                                              adultCount;
                                        },
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                              adultCount <
                                                  (travelData
                                                      .batchInfo
                                                      ?.availableSlots ??
                                                      0)
                                                  ? CommonColors.blueColor
                                                  : CommonColors.grey_AEAEAE,
                                              width: 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.add,
                                              size: 20,
                                              color:
                                              adultCount <
                                                  (travelData
                                                      .batchInfo
                                                      ?.availableSlots ??
                                                      0)
                                                  ? CommonColors.blueColor
                                                  : CommonColors.grey_AEAEAE,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Contact Details Section
                  SizedBox(
                    width: 100.w,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.w),
                          boxShadow: [
                            BoxShadow(
                              color: CommonColors.blackColor.withValues(
                                  alpha: 0.2),
                              offset: Offset(2, 2),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                          color: CommonColors.whiteColor,
                        ),
                        child: Container(
                          width: 100.w,
                          margin: EdgeInsets.only(
                            left: 6.w,
                            right: 6.w,
                            top: 1.5.h,
                            bottom: 1.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Text(
                                    'Contact Details',
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.alexandria(
                                      fontSize: FontSize.s14,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.blackColor,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _showContactDetailsBottomSheet(
                                        isEdit: _userC.userProfileData.value
                                            .customer?.email != null &&
                                            _userC.userProfileData.value
                                                .customer?.phone != null,
                                      );
                                    },
                                    child: Text(
                                      (_userC.userProfileData.value.customer
                                          ?.email != null &&
                                          _userC.userProfileData.value
                                              .customer?.phone != null)
                                          ? 'Edit'
                                          : 'Add',
                                      textScaler: const TextScaler.linear(
                                          1.0),
                                      style: GoogleFonts.alexandria(
                                        fontSize: FontSize.s10,
                                        fontWeight: FontWeight.w500,
                                        color: CommonColors.blueColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.3.h),
                              Text(
                                'Trip ticket details will be provided to',
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s8,
                                  color: CommonColors.blackColor.withValues(
                                      alpha: 0.6),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              // Phone Row
                              Container(
                                color: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 1.w,
                                  vertical: 1.h,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: SvgPicture.asset(
                                          CommonImages.phone),
                                    ),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: Text(
                                        _userC.userProfileData.value.customer
                                            ?.phone ?? '-',
                                        style: GoogleFonts.poppins(
                                          fontSize: FontSize.s11,
                                          color: CommonColors.blackColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Email Row
                              Container(
                                color: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 1.w,
                                  vertical: 1.h,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: SvgPicture.asset(
                                          CommonImages.email),
                                    ),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: Text(
                                        _userC.userProfileData.value.customer
                                            ?.email ?? '-',
                                        style: GoogleFonts.poppins(
                                          fontSize: FontSize.s11,
                                          color: CommonColors.blackColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // State of Residence
                              Container(
                                color: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 1.w,
                                  vertical: 1.h,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: SvgPicture.asset(
                                          CommonImages.location4),
                                    ),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: Text(
                                        _userC.userProfileData.value.customer
                                            ?.state?.id != null
                                            ? _dashboardC
                                            .stateList[_dashboardC.stateList
                                            .indexWhere(
                                              (element) =>
                                          element.id ==
                                              _userC.userProfileData.value
                                                  .customer?.state?.id,
                                        )].name ?? '-'
                                            : '-',
                                        style: GoogleFonts.poppins(
                                          fontSize: FontSize.s11,
                                          color: CommonColors.blackColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Travellers Section
                  if ((_userC.userProfileData.value.customer?.travelers
                      ?.isNotEmpty ?? false))
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                      child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        decoration: BoxDecoration(
                          color: CommonColors.whiteColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: CommonColors.blackColor.withValues(
                                  alpha: 0.2),
                              offset: Offset(2, 2),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Text(
                                    'Traveller Details',
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s14,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.blackColor,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _showTravellerBottomSheet(isEdit: false),
                                    child: Text(
                                      'Add New',
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s10,
                                        fontWeight: FontWeight.w500,
                                        color: CommonColors.blueColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Obx(() {
                                final adultCount = _trekControllerC.calculateFareRequestModel.value.travelerCount;
                                return Visibility(
                                  visible: (adultCount > 0),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 1.h),
                                      Text(
                                        'Select up to $adultCount traveller${adultCount >
                                            1 ? 's' : ''} (${selectedTravellers
                                            .length}/$adultCount selected)',
                                        style: GoogleFonts.poppins(
                                          fontSize: FontSize.s9,
                                          fontWeight: FontWeight.w400,
                                          color: CommonColors.blackColor
                                              .withOpacity(0.6),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }),
                              SizedBox(height: 2.h),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _userC.userProfileData.value
                                    .customer?.travelers?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final traveler = _userC.userProfileData
                                      .value.customer?.travelers?[index];
                                  return Column(
                                    children: [
                                      _buildExistingTravellerItem(
                                        travelData: traveler!,
                                        isSelected: selectedTravellers.any(
                                              (traveller) =>
                                          traveller.id == traveler.id,
                                        ),
                                      ),
                                      if (index != (_userC.userProfileData.value.customer?.travelers?.length ?? 0) - 1) SizedBox(height: 1.h),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if ((_userC.userProfileData.value.customer?.travelers
                      ?.isEmpty ?? true))
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                      child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        decoration: BoxDecoration(
                          color: CommonColors.whiteColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: CommonColors.blackColor.withValues(
                                  alpha: 0.2),
                              offset: Offset(2, 2),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showTravellerBottomSheet(isEdit: false),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 3.h),
                              child: Center(
                                child: Column(
                                  children: [
                                    SvgPicture.asset(
                                      CommonImages.adduser,
                                      width: 10.w,
                                      height: 10.w,
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      'Add Traveller Details',
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s12,
                                        fontWeight: FontWeight.w500,
                                        color: CommonColors.blueColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 2.5.h),

                  // Free Cancellation
                  Obx(() {
                    CalculateFareResponseModel? calculateFareResponse = _trekControllerC.calculateFareResponseModel.value.maybeWhen(
                        success: (response) => response,
                        orElse: () => null
                    );
                    return Visibility(
                      visible: calculateFareResponse?.allowCancellation ?? true,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: CommonColors.filterGradient2,
                            boxShadow: [
                              BoxShadow(
                                color: CommonColors.blackColor.withValues(
                                    alpha: 0.2),
                                offset: Offset(2, 2),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(5.w),
                          ),
                          child: Container(
                            margin: EdgeInsets.only(
                              left: 6.w,
                              right: 3.w,
                              top: 2.h,
                              bottom: 2.5.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Free Cancellation',
                                  textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s15,
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.blackColor,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                RichText(
                                  textScaler: const TextScaler.linear(1.0),
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                        'A fee of ₹90 per person will be charged for a full refund on ticket cancellations made ',
                                        style: GoogleFonts.poppins(
                                          fontSize: FontSize.s8,
                                          fontWeight: FontWeight.w300,
                                          color: CommonColors.blackColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'T&C',
                                        style: GoogleFonts.roboto(
                                          fontSize: FontSize.s8,
                                          fontWeight: FontWeight.w500,
                                          color: CommonColors.blueColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' at least 24 hours prior to departure',
                                        style: GoogleFonts.poppins(
                                          fontSize: FontSize.s8,
                                          fontWeight: FontWeight.w300,
                                          color: CommonColors.blackColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Obx(() {
                                  final freeCancellation = _trekControllerC.calculateFareRequestModel.value.addFreeCancellationProtection;
                                  return GestureDetector(
                                    onTap: () {
                                      _trekControllerC.calculateFareRequestModel.value = _trekControllerC.calculateFareRequestModel.value.copyWith(addFreeCancellationProtection: !freeCancellation);
                                      if (_trekControllerC.calculateFareRequestModel.value.addFreeCancellationProtection) {
                                        _showTickOverlay(context);
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          key: _checkboxKey,
                                          width: 6.25.w,
                                          height: 6.25.w,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: CommonColors.lightBlueColor
                                                  .withValues(alpha: 0.7),
                                              width: 0.5.w,
                                            ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                            color: freeCancellation
                                                ? CommonColors.blueColor
                                                : Colors.white,
                                          ),
                                          child: freeCancellation
                                              ? Icon(
                                            Icons.check,
                                            size: 5.w,
                                            color: Colors.white,
                                          )
                                              : null,
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          'I would like to choose the free\ncancellation option',
                                          style: GoogleFonts.roboto(
                                            fontSize: FontSize.s7,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.blackColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 2.5.h),

                  // Travel Insurance Container
                  Obx(() {
                    final selectedInsuranceOption = _trekControllerC.calculateFareRequestModel.value.addInsurance;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                      child: Container(
                        width: 100.w,
                        decoration: BoxDecoration(
                          color: CommonColors.whiteColor,
                          borderRadius: BorderRadius.circular(5.w),
                          boxShadow: [
                            BoxShadow(
                              color: CommonColors.blackColor.withValues(
                                  alpha: 0.2),
                              offset: Offset(2, 2),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Container(
                          width: 100.w,
                          margin: EdgeInsets.only(
                            left: 6.w,
                            right: 6.w,
                            top: 2.2.h,
                            bottom: 2.8.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Center(
                                    child: Image.asset(
                                      CommonImages.logo,
                                      width: 12.5.w,
                                      height: 12.5.w,
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          'Travel Insurance',
                                          textScaler: const TextScaler.linear(
                                              1.0),
                                          style: GoogleFonts.poppins(
                                            fontSize: FontSize.s14,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.blackColor,
                                          ),
                                        ),
                                        Text(
                                          'Secure your trek, enjoy the adventure',
                                          textScaler: const TextScaler.linear(
                                              1.0),
                                          style: GoogleFonts.poppins(
                                            fontSize: FontSize.s7,
                                            fontWeight: FontWeight.w400,
                                            color: CommonColors.blackColor
                                                .withValues(
                                              alpha: 0.6,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 0.5.h),
                                        GestureDetector(
                                          onTap: () {},
                                          child: Row(
                                            children: [
                                              Text(
                                                'View covers',
                                                textScaler: const TextScaler
                                                    .linear(
                                                  1.0,
                                                ),
                                                style: GoogleFonts.poppins(
                                                  fontSize: FontSize.s7,
                                                  fontWeight: FontWeight.w500,
                                                  color: CommonColors
                                                      .blueColor,
                                                ),
                                              ),
                                              SizedBox(width: 1.w),
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 3.5.w,
                                                color: CommonColors
                                                    .blueColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.5.h),
                              // Insurance Options
                              Container(
                                width: 100.w,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedInsuranceOption == true
                                        ? CommonColors.blueColor
                                        : Color(0xFF878787),
                                  ),
                                  borderRadius: BorderRadius.circular(2.w),
                                  color: Colors.white,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      _trekControllerC.calculateFareRequestModel.value = _trekControllerC.calculateFareRequestModel.value.copyWith(addInsurance: true);
                                    },
                                    borderRadius: BorderRadius.circular(2.w),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        left: 6.25.w,
                                        right: 5.w,
                                        top: 1.25.h,
                                        bottom: 1.5.h,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Add Travel Insurance',
                                                textScaler: const TextScaler
                                                    .linear(
                                                  1.0,
                                                ),
                                                style: GoogleFonts.roboto(
                                                  fontSize: FontSize.s11,
                                                  fontWeight: FontWeight.w400,
                                                  color: CommonColors
                                                      .blackColor,
                                                ),
                                              ),
                                              Text(
                                                '₹80 for 1 Traveller',
                                                textScaler: const TextScaler
                                                    .linear(
                                                  1.0,
                                                ),
                                                style: GoogleFonts.roboto(
                                                  fontSize: FontSize.s7,
                                                  fontWeight: FontWeight.w400,
                                                  color: CommonColors.blackColor
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: 6.w,
                                            height: 6.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient:
                                              selectedInsuranceOption == true
                                                  ? CommonColors
                                                  .radioBtnGradient
                                                  : null,
                                              border:
                                              selectedInsuranceOption == true
                                                  ? null
                                                  : Border.all(
                                                color: CommonColors
                                                    .greyColor585858,
                                                width: 0.5.w,
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: selectedInsuranceOption ==
                                                true
                                                ? Center(
                                              child: Container(
                                                width: 2.w,
                                                height: 2.w,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                                : const SizedBox.shrink(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.875.h),
                              Container(
                                width: 100.w,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedInsuranceOption ==
                                        false
                                        ? CommonColors.blueColor
                                        : Color(0xFF878787),
                                  ),
                                  borderRadius: BorderRadius.circular(2.w),
                                  color: Colors.white,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      _trekControllerC.calculateFareRequestModel.value = _trekControllerC.calculateFareRequestModel.value.copyWith(addInsurance: false);
                                    },
                                    borderRadius: BorderRadius.circular(2.w),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        left: 6.25.w,
                                        right: 5.w,
                                        top: 1.25.h,
                                        bottom: 1.5.h,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Don't add Travel Insurance",
                                            textScaler: const TextScaler.linear(
                                                1.0),
                                            style: GoogleFonts.roboto(
                                              fontSize: FontSize.s11,
                                              fontWeight: FontWeight.w400,
                                              color: CommonColors.blackColor,
                                            ),
                                          ),
                                          Container(
                                            width: 6.w,
                                            height: 6.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient:
                                              selectedInsuranceOption ==
                                                  false
                                                  ? CommonColors
                                                  .radioBtnGradient
                                                  : null,
                                              border:
                                              selectedInsuranceOption ==
                                                  false
                                                  ? null
                                                  : Border.all(
                                                color: CommonColors
                                                    .greyColor585858,
                                                width: 0.5.w,
                                              ),
                                              color: Colors.white,
                                            ),
                                            child:
                                            selectedInsuranceOption ==
                                                false
                                                ? Center(
                                              child: Container(
                                                width: 2.w,
                                                height: 2.w,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                                : const SizedBox.shrink(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 3.75.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.w),
                        boxShadow: [
                          BoxShadow(
                            color: CommonColors.blackColor.withValues(
                                alpha: 0.2),
                            offset: Offset(2, 2),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 5.w, vertical: 3.h),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      'Lock your spot. Pay now.',
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s9,
                                        fontWeight: FontWeight.w400,
                                        color: CommonColors.blackColor,
                                      ),
                                    ),
                                    Text(
                                      'Adventure\'s calling!',
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s14,
                                        fontWeight: FontWeight.w600,
                                        color: CommonColors.blackColor,
                                      ),
                                    ),
                                    SizedBox(height: 0.5.h),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.5.h),
                          // Pay ₹999 Section - Only show for Flexible cancellation policy (ID = 1)
                          if (travelData.cancellationPolicy?.id == 1) ...[
                            Container(
                              width: 100.w,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedPaymentOption == 'flexible'
                                      ? CommonColors.blueColor
                                      : Color(0xFF878787),
                                ),
                                borderRadius: BorderRadius.circular(2.w),
                                color: Colors.white,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedPaymentOption = 'flexible';
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      left: 7.5.w,
                                      right: 6.25.w,
                                      top: 2.1.h,
                                      bottom: 1.5.h,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            MediaQuery(
                                              data: MediaQuery.of(context)
                                                  .copyWith(
                                                textScaler: const TextScaler
                                                    .linear(
                                                  1.0,
                                                ),
                                              ),
                                              child: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'Pay ₹',
                                                      style: GoogleFonts
                                                          .roboto(
                                                        fontSize: FontSize
                                                            .s11,
                                                        fontWeight: FontWeight
                                                            .w400,
                                                        color:
                                                        CommonColors
                                                            .blackColor,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: '999',
                                                      style: GoogleFonts
                                                          .roboto(
                                                        fontSize: FontSize
                                                            .s11,
                                                        fontWeight: FontWeight
                                                            .w600,
                                                        color:
                                                        CommonColors
                                                            .blackColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _getTotalFareSubtitleText(),
                                              textScaler: const TextScaler
                                                  .linear(
                                                1.0,
                                              ),
                                              style: GoogleFonts.roboto(
                                                fontSize: FontSize.s7,
                                                fontWeight: FontWeight.w400,
                                                color: CommonColors.blackColor
                                                    .withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 6.w,
                                          height: 6.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient:
                                            _selectedPaymentOption ==
                                                'flexible'
                                                ? CommonColors
                                                .radioBtnGradient
                                                : null,
                                            border:
                                            _selectedPaymentOption ==
                                                'flexible'
                                                ? null
                                                : Border.all(
                                              color:
                                              CommonColors.greyColor585858,
                                              width: 0.5.w,
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: _selectedPaymentOption ==
                                              'partial'
                                              ? Center(
                                            child: Container(
                                              width: 2.w,
                                              height: 2.w,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          )
                                              : const SizedBox.shrink(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 2.5.h),
                          ],
                          Container(
                            width: 100.w,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedPaymentOption == 'standard'
                                    ? CommonColors.blueColor
                                    : Color(0xFF878787),
                              ),
                              borderRadius: BorderRadius.circular(2.w),
                              color: Colors.white,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedPaymentOption = 'standard';
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                    left: 7.5.w,
                                    right: 6.25.w,
                                    top: 2.1.h,
                                    bottom: 1.5.h,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          MediaQuery(
                                            data: MediaQuery.of(context)
                                                .copyWith(
                                              textScaler: const TextScaler
                                                  .linear(
                                                1.0,
                                              ),
                                            ),
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Pay Full ',
                                                    style: GoogleFonts.roboto(
                                                      fontSize: FontSize.s11,
                                                      fontWeight: FontWeight
                                                          .w400,
                                                      color:
                                                      CommonColors.blackColor,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: 'Payment',
                                                    style: GoogleFonts.roboto(
                                                      fontSize: FontSize.s11,
                                                      fontWeight: FontWeight
                                                          .w600,
                                                      color:
                                                      CommonColors.blackColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'Secure your booking with full payment',
                                            textScaler: const TextScaler
                                                .linear(
                                              1.0,
                                            ),
                                            style: GoogleFonts.roboto(
                                              fontSize: FontSize.s7,
                                              fontWeight: FontWeight.w400,
                                              color: CommonColors.blackColor
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 6.w,
                                        height: 6.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: _selectedPaymentOption ==
                                              'standard'
                                              ? CommonColors.radioBtnGradient
                                              : null,
                                          border: _selectedPaymentOption ==
                                              'standard'
                                              ? null
                                              : Border.all(
                                            color:
                                            CommonColors.greyColor585858,
                                            width: 0.5.w,
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: _selectedPaymentOption ==
                                            'standard'
                                            ? Center(
                                          child: Container(
                                            width: 2.w,
                                            height: 2.w,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.5.h),
                ],
              ),
            ),
          ),
          Obx(() => _trekControllerC.calculateFareResponseModel.value.maybeWhen(
            loading: (loadingData) => Container(
              color: CommonColors.grey400,
              child: Center(
                child: CircularProgressIndicator(
                  color: CommonColors.blueColor,
                ),
              ),
            ),
            orElse: () => const SizedBox(),
          )),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Obx(() {
          final calculateFareRequestModel = _trekControllerC.calculateFareRequestModel.value;
          CalculateFareResponseModel? calculateFareResponseModel = _trekControllerC.calculateFareResponseModel.value.maybeWhen(
              success: (response) => response,
              orElse: () => null
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 27, right: 25, top: 10),
                child: calculateFareRequestModel.travelerCount > 0
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => TotalFareModal(
                            breakDown:calculateFareResponseModel?.breakdown,
                            adultCount: calculateFareRequestModel.travelerCount,
                            onClose: () => Navigator.pop(context)
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Total Fare',
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s9,
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 24,
                                color: CommonColors.blackColor,
                              ),
                            ],
                          ),
                          Text(
                            'Tax Included',
                            textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s8,
                              fontWeight: FontWeight.w300,
                              color: CommonColors.blackColor.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      textScaler: const TextScaler.linear(1.0),
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '₹ ',
                            style: GoogleFonts.roboto(
                              fontSize: FontSize.s15,
                              fontWeight: FontWeight.w600,
                              color: CommonColors.softGreen2,
                            ),
                          ),
                          TextSpan(
                            text: "${calculateFareResponseModel?.breakdown?.amountToPayNow ?? "--"}",
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s15,
                              fontWeight: FontWeight.w600,
                              color: CommonColors.softGreen2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                    : const SizedBox.shrink(),
              ),
              if (_trekControllerC.calculateFareRequestModel.value.travelerCount > 0) SizedBox(height: 2.h),
              Padding(
                padding: const EdgeInsets.only(left: 41, right: 41, bottom: 20),
                child: Obx(() {
                  final isFormValid = _trekControllerC.calculateFareRequestModel.value.travelerCount > 0 &&
                      _userC.userProfileData.value.customer?.email != null &&
                      _userC.userProfileData.value.customer?.phone != null &&
                      _userC.userProfileData.value.customer?.state?.id != null &&
                      selectedTravellers.length >= _trekControllerC.calculateFareRequestModel.value.travelerCount;

                  return CommonButton(
                    text: 'Pay Now',
                    fontSize: FontSize.s14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    onPressed: () {
                      if (isFormValid) {
                        _trekControllerC.createOrderRequestModel.value = _trekControllerC.createOrderRequestModel.value.copyWith(travelers: selectedTravellers.toList());
                        _handlePayment(calculateFareResponseModel?.breakdown);
                      }
                    },
                    gradient: isFormValid
                        ? CommonColors.filterGradient
                        : CommonColors.disableBtnGradient,
                    textColor: CommonColors.whiteColor,
                    height: 48,
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildExistingTravellerItem({
    required Traveler travelData,
    required bool isSelected,
  }) {
    return Obx(() {
      final adultCount = _trekControllerC.calculateFareRequestModel.value.travelerCount;

      // Check if selected travellers exceed adult count
      if (selectedTravellers.length > adultCount) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              selectedTravellers.clear();
              _trekControllerC.travellerDetailList.value = [];
            });
          }
        });
        return const SizedBox.shrink();
      }

      final bool isTravellerSelected = selectedTravellers.any(
            (traveller) => traveller.id == travelData.id,
      );

      final bool canSelect = isTravellerSelected || selectedTravellers.length < adultCount;

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isTravellerSelected,
                  onChanged: canSelect
                      ? (bool? value) {
                    setState(() {
                      if (value ?? false) {
                        if (!selectedTravellers.any(
                              (traveller) => traveller.id == travelData.id,
                        )) {
                          selectedTravellers.add(travelData);
                        }
                      } else {
                        selectedTravellers.removeWhere(
                              (traveller) => traveller.id == travelData.id,
                        );
                      }
                      _trekControllerC.travellerDetailList.value = List.from(selectedTravellers);
                    });
                  }
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  activeColor: CommonColors.blueColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      travelData.name ?? '-',
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s11,
                        fontWeight: FontWeight.w500,
                        color: canSelect
                            ? CommonColors.blackColor
                            : CommonColors.blackColor.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      '${travelData.gender ?? ''}, ${travelData.age ?? ''}',
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s9,
                        fontWeight: FontWeight.w400,
                        color: canSelect
                            ? CommonColors.blackColor.withOpacity(0.6)
                            : CommonColors.blackColor.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _showTravellerBottomSheet(
                  traveller: travelData,
                  isEdit: true,
                ),
                child: Text(
                  'Edit',
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s9,
                    fontWeight: FontWeight.w500,
                    color: CommonColors.blueColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Handles the payment flow
  void _handlePayment(BreakDownDataModel? breakDown) {
    Get.toNamed(BookingRoutes.payment);
  }

  String _getTotalFareSubtitleText() {
    if (_selectedPaymentOption == BookingConstants.partialPayment) {
      double remaining = 5;
      return 'Advance Paid ₹999, Pay ₹${remaining.toStringAsFixed(0)} before trek start';
    } else {
      return 'Secure your booking with full payment';
    }
  }

}