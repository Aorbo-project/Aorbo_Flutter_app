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

// ─────────────────────────────────────────────
//  DESIGN TOKENS — matches TrekDetailsScreen _C
// ─────────────────────────────────────────────
class _TI {
  static const bg        = CommonColors.offWhiteColor;
  static const cardBg    = CommonColors.whiteColor;
  static const ink       = CommonColors.blackColor;
  static const inkMid    = CommonColors.cFF6B7280;
  static const inkLight  = CommonColors.grey_AEAEAE;
  static const brand     = CommonColors.trek_route_color;
  static const teal      = CommonColors.cFF0F7B6C;
  static const tealSoft  = CommonColors.cFFE6F5F3;
  static const iconBadge = CommonColors.cFF111827;
  static const divider   = CommonColors.trekroutecolorlight;
  static const shadow    = CommonColors.c0A000000;
}

class TravellerInformationScreen extends StatefulWidget {
  const TravellerInformationScreen({Key? key}) : super(key: key);

  @override
  State<TravellerInformationScreen> createState() =>
      _TravellerInformationScreenState();
}

class _TravellerInformationScreenState
    extends State<TravellerInformationScreen>
    with SingleTickerProviderStateMixin {

  // ── ALL ORIGINAL CONTROLLERS & STATE UNTOUCHED ───────────────────────────
  final TrekController      _trekC = Get.find<TrekController>();
  final DashboardController _dashboardC      = Get.find<DashboardController>();
  final UserController      _userC           = Get.find<UserController>();
  late TrekDetailData travelData;
  final nameNode = FocusNode();

  String _selectedState = BookingConstants.defaultState;
  List<String> filteredStates = [];

  bool _whatsappUpdates = false;
  String _selectedPaymentOption = 'standard';

  final GlobalKey _checkboxKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  List<Traveler> selectedTravellers = [];

  @override
  void initState() {
    super.initState();
    filteredStates = _dashboardC.stateList
        .map((element) => element.name!)
        .toList();

    travelData = _trekC.trekDetailData.value;

    _trekC.calculateFareRequestModel.value =
        _trekC.calculateFareRequestModel.value.copyWith(
      batchId: travelData.batchInfo?.id ?? 1,
      travelerCount: 1,
      addInsurance: false,
      addFreeCancellationProtection: false,
      couponCode: '',
      cancellationPolicyType: 'standard',
    );
    _trekC.calculateFare();

    debounce(
      _trekC.calculateFareRequestModel,
      (value) {
        _trekC.calculateFare();
      },
      time: const Duration(milliseconds: 500),
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

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
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

  String _calculateEndDate(String? startDate, int? durationDays) {
    if (startDate == null || startDate.isEmpty || durationDays == null) return '-';
    try {
      DateTime start = DateTime.parse(startDate);
      DateTime end = start.add(Duration(days: durationDays));
      return '${end.day.toString().padLeft(2, '0')}-${end.month.toString().padLeft(2, '0')}-${end.year}';
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
    final cx = position.dx + (size.width / 2);
    final cy = position.dy + (size.height / 2);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          ...List.generate(12, (index) {
            final angle = (index * (360 / 12)) * (pi / 180);
            return Positioned(
              left: cx - 2,
              top: cy - 2,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (context, value, child) => Transform.translate(
                  offset: Offset(cos(angle) * (40 * value), sin(angle) * (40 * value)),
                  child: Opacity(opacity: 1 - value,
                    child: Container(width: 4, height: 4,
                      decoration: BoxDecoration(color: CommonColors.lightBlueColor, shape: BoxShape.circle)),
                  ),
                ),
              ),
            );
          }),
          ...List.generate(6, (index) {
            final angle = (index * (360 / 6)) * (pi / 180);
            final delay = (index * 100);
            return Positioned(
              left: cx - 15,
              top: cy - 15,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  final delayedValue = value == 0 ? 0.0
                      : ((value * 1000 - delay) / (800 - delay)).clamp(0.0, 1.0);
                  final yOffset = sin(value * pi * 2) * 20;
                  final distance = 60 * delayedValue;
                  return Transform.translate(
                    offset: Offset(cos(angle) * distance, (sin(angle) * distance) + yOffset),
                    child: Transform.scale(
                      scale: delayedValue * (1 - delayedValue * 0.5),
                      child: Opacity(
                        opacity: 1 - delayedValue,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: CommonColors.lightBlueColor, blurRadius: 4, spreadRadius: 1)]),
                          child: Icon(Icons.check, color: CommonColors.lightBlueColor, size: 16),
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

  // ── SHARED UI HELPERS — matching TrekDetailsScreen ───────────────────────

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _TI.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: child,
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 9.w,
          height: 9.w,
          decoration: BoxDecoration(
            color: _TI.iconBadge,
            borderRadius: BorderRadius.circular(2.5.w),
          ),
          child: Center(child: Icon(icon, color: Colors.white, size: 4.5.w)),
        ),
        SizedBox(width: 3.w),
        Text(
          title,
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w700,
            color: _TI.ink,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String svgAsset, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.2.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: SvgPicture.asset(svgAsset, width: 4.w, height: 4.w),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              value,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s11,
                fontWeight: FontWeight.w500,
                color: _TI.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CONTACT BOTTOM SHEET — original logic ────────────────────────────────
  void _showContactDetailsBottomSheet({bool isEdit = false}) {
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
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: CommonColors.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(left: 6.w, right: 6.w, top: 2.h, bottom: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 10.w, height: 0.5.h,
                    margin: EdgeInsets.only(bottom: 1.5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
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
                SizedBox(height: 0.5.h),
                Text(
                  'Trip ticket details will be provided to',
                  textScaler: const TextScaler.linear(1.0),
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s8,
                    color: CommonColors.blackColor.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: 2.h),
                // Phone
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF878787)),
                    borderRadius: BorderRadius.circular(2.w),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 27.w,
                        padding: EdgeInsets.symmetric(vertical: 1.2.h),
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: const Color(0xFF878787), width: 0.25.w)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Country Code', textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(fontSize: FontSize.s7, color: CommonColors.blackColor, fontWeight: FontWeight.w300)),
                            SizedBox(height: 0.4.h),
                            Text('+91(IND)', textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(fontSize: FontSize.s10, fontWeight: FontWeight.w400, color: CommonColors.blackColor)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 3.w, right: 3.w, top: 0.8.h, bottom: 0.8.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Phone Number', textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.poppins(fontSize: FontSize.s7, color: CommonColors.blackColor, fontWeight: FontWeight.w300)),
                              MediaQuery(
                                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
                                child: TextField(
                                  controller: _userC.phoneNumberController.value,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  style: GoogleFonts.poppins(fontSize: FontSize.s10, color: CommonColors.blackColor),
                                  decoration: const InputDecoration(border: InputBorder.none, counterText: '', isDense: true),
                                  onChanged: (value) => setModalState(() {}),
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
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFF878787)), borderRadius: BorderRadius.circular(2.w), color: Colors.white),
                  padding: EdgeInsets.only(left: 4.w, top: 0.8.h, bottom: 0.8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email ID', textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(fontSize: FontSize.s7, color: CommonColors.blackColor, fontWeight: FontWeight.w300)),
                      MediaQuery(
                        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
                        child: TextField(
                          controller: _userC.emailController.value,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.poppins(fontSize: FontSize.s10, fontWeight: FontWeight.w400, color: CommonColors.blackColor),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                          onChanged: (value) => setModalState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.8.h),
                // State
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFF878787)), borderRadius: BorderRadius.circular(2.w), color: Colors.white),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showStateSelectionBottomSheet(setModalState),
                      borderRadius: BorderRadius.circular(2.w),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('State of Residence', textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(fontSize: FontSize.s7, color: CommonColors.blackColor, fontWeight: FontWeight.w300)),
                                SizedBox(height: 0.25.h),
                                Text(_selectedState, textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(fontSize: FontSize.s10, fontWeight: FontWeight.w400, color: CommonColors.blackColor)),
                              ],
                            ),
                            Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 6.w),
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
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(isEdit ? 'Contact details updated successfully' : 'Contact details saved successfully',
                          textScaler: const TextScaler.linear(1.0)),
                        backgroundColor: CommonColors.completedColor,
                        duration: const Duration(seconds: 2),
                      ));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── TRAVELLER BOTTOM SHEET — original logic ──────────────────────────────
  void _showTravellerBottomSheet({Traveler? traveller, bool isEdit = false}) {
    if (isEdit && traveller != null) {
      _userC.travellerId.value = traveller.id ?? 0;
      _userC.nameControllerTraveller.value.text = traveller.name ?? '';
      _userC.ageControllerTraveller.value.text = traveller.age.toString();
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
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: CommonColors.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(left: 6.w, right: 6.w, top: 2.h, bottom: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 10.w, height: 0.5.h,
                    margin: EdgeInsets.only(bottom: 1.5.h),
                    decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEdit ? 'Edit Traveller' : 'Add New Traveller',
                      textScaler: const TextScaler.linear(1.0),
                      style: GoogleFonts.alexandria(fontSize: FontSize.s16, fontWeight: FontWeight.w600, color: CommonColors.blackColor)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, size: 6.w)),
                  ],
                ),
                SizedBox(height: 2.h),
                _buildTextFieldInSheet(_userC.nameControllerTraveller.value, 'Name', focusNode: nameNode, onChanged: () => setModalState(() {})),
                SizedBox(height: 2.h),
                _buildTextFieldInSheet(_userC.ageControllerTraveller.value, 'Age', keyboardType: TextInputType.number, onChanged: () => setModalState(() {})),
                SizedBox(height: 1.7.h),
                Text('Gender', textScaler: const TextScaler.linear(1.0),
                  style: GoogleFonts.poppins(fontSize: FontSize.s11, fontWeight: FontWeight.w300, color: CommonColors.blackColor.withValues(alpha: 0.6))),
                SizedBox(height: 1.h),
                Row(children: [
                  _buildGenderButtonInSheet('Male', setModalState),
                  SizedBox(width: 2.w),
                  _buildGenderButtonInSheet('Female', setModalState),
                ]),
                SizedBox(height: 3.h),
                CommonButton(
                  height: 48,
                  gradient: CommonColors.filterGradient,
                  text: isEdit ? 'Update Traveller' : 'Add Traveller',
                  textColor: CommonColors.whiteColor,
                  onPressed: () async {
                    if (_validateTravellerDetails()) {
                      if (isEdit) { await _userC.updateTraveler(); } else { await _userC.addTraveler(); }
                      setState(() {});
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(isEdit ? 'Traveller updated successfully' : 'Traveller added successfully', textScaler: const TextScaler.linear(1.0)),
                        backgroundColor: CommonColors.completedColor,
                        duration: const Duration(seconds: 2),
                      ));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldInSheet(TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text, int? maxLength, FocusNode? focusNode, VoidCallback? onChanged}) {
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
          hintStyle: GoogleFonts.poppins(fontSize: FontSize.s11, fontWeight: FontWeight.w300, color: CommonColors.blackColor.withAlpha(153)),
          counterText: '',
          contentPadding: const EdgeInsets.only(left: 21, top: 13, bottom: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF878787))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF878787))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF90CAF9))),
          filled: true,
          fillColor: Colors.white,
        ),
        style: GoogleFonts.poppins(fontSize: FontSize.s10, color: CommonColors.blackColor),
      ),
    );
  }

  Widget _buildGenderButtonInSheet(String gender, StateSetter setModalState) {
    final bool isSelected = _userC.selectedGender.value.toLowerCase() == gender.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () => setModalState(() => _userC.selectedGender.value = gender),
        child: Container(
          height: 5.5.h,
          decoration: BoxDecoration(
            border: Border.all(color: _userC.selectedGender.value == gender ? CommonColors.blueColor : const Color(0xFF878787)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Container(
            margin: EdgeInsets.only(left: 4.5.w, right: 2.5.w, top: 1.h, bottom: 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(gender, textScaler: const TextScaler.linear(1.0),
                  style: GoogleFonts.poppins(fontSize: FontSize.s10, fontWeight: FontWeight.w500, color: CommonColors.blackColor.withValues(alpha: 0.6))),
                Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected ? CommonColors.radioBtnGradient : null,
                    border: isSelected ? null : Border.all(color: CommonColors.greyColor585858, width: 2),
                    color: Colors.white,
                  ),
                  child: isSelected ? Center(child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))) : null,
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid 10-digit phone number'), backgroundColor: CommonColors.appRedColor));
      return false;
    }
    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid email address'), backgroundColor: CommonColors.appRedColor));
      return false;
    }
    if (_userC.stateUpdateId.value == 0 || _selectedState.isEmpty || _selectedState == '-') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select your state of residence'), backgroundColor: CommonColors.appRedColor));
      return false;
    }
    return true;
  }

  bool _validateTravellerDetails() {
    String name   = _userC.nameControllerTraveller.value.text.trim();
    String age    = _userC.ageControllerTraveller.value.text.trim();
    String gender = _userC.selectedGender.value;
    if (name.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter traveller name'), backgroundColor: CommonColors.appRedColor)); return false; }
    if (age.isEmpty)  { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter traveller age'), backgroundColor: CommonColors.appRedColor)); return false; }
    int? ageValue = int.tryParse(age);
    if (ageValue == null || ageValue <= 0) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid age'), backgroundColor: CommonColors.appRedColor)); return false; }
    if (gender.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select gender'), backgroundColor: CommonColors.appRedColor)); return false; }
    return true;
  }

  Future<void> _showStateSelectionBottomSheet(StateSetter setModalState) async {
    TextEditingController searchController = TextEditingController();
    setState(() { filteredStates = _dashboardC.stateList.map((e) => e.name!).toList(); });
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CommonColors.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(5.w))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 2.5.h, left: 5.w, right: 5.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Select state of residence', textScaler: const TextScaler.linear(1.0),
                  style: GoogleFonts.poppins(fontSize: FontSize.s14, fontWeight: FontWeight.w600, color: CommonColors.blackColor)),
                SizedBox(height: 2.h),
                Container(
                  height: 6.h,
                  padding: EdgeInsets.symmetric(horizontal: 2.5.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [CommonColors.whiteColor, Color(0xFFF8FBFF)]),
                    borderRadius: BorderRadius.circular(3.75.w),
                    border: Border.all(color: const Color(0xffd5d5d5), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey, size: 6.w),
                      SizedBox(width: 2.5.w),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search State',
                            border: InputBorder.none,
                            hintStyle: GoogleFonts.poppins(fontSize: FontSize.s10, color: CommonColors.blackColor.withValues(alpha: 0.6)),
                          ),
                          style: GoogleFonts.poppins(fontSize: FontSize.s10, color: CommonColors.blackColor),
                          onChanged: (value) {
                            setSheetState(() {
                              filteredStates = _dashboardC.stateList.map((e) => e.name!).toList()
                                  .where((state) => state.toLowerCase().contains(value.toLowerCase())).toList();
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
                    itemBuilder: (context, index) => ListTile(
                      title: Text(filteredStates[index], textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(fontSize: FontSize.s10, fontWeight: FontWeight.w500, color: CommonColors.blackColor)),
                      onTap: () {
                        setModalState(() {
                          _userC.stateUpdateId.value = _dashboardC.stateList[_dashboardC.stateList.indexWhere((e) => e.name == filteredStates[index])].id!;
                          _selectedState = filteredStates[index];
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => setState(() { filteredStates = _dashboardC.stateList.map((e) => e.name!).toList(); }));
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _TI.bg,
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Trip Summary card ─────────────────────────────────
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader('Trip Summary', Icons.route_rounded),
                        SizedBox(height: 2.h),

                        // Route row
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: _TI.brand.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(3.w),
                            border: Border.all(color: _TI.brand.withOpacity(0.15)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('FROM', textScaler: const TextScaler.linear(1.0),
                                      style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s7, fontWeight: FontWeight.w600, color: _TI.inkLight, letterSpacing: 0.8)),
                                    SizedBox(height: 0.3.h),
                                    Text(_formatDate(travelData.batchInfo?.startDate), textScaler: const TextScaler.linear(1.0),
                                      style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s11, fontWeight: FontWeight.w700, color: _TI.ink)),
                                    Text(_dashboardC.fromController.value.text, textScaler: const TextScaler.linear(1.0),
                                      style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s9, color: _TI.inkMid)),
                                  ],
                                ),
                              ),
                              // Duration pill
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                                decoration: BoxDecoration(
                                  color: _TI.brand,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 4.w),
                                    SizedBox(height: 0.2.h),
                                    Text('${travelData.durationDays}D|${travelData.durationNights}N',
                                      textScaler: const TextScaler.linear(1.0),
                                      style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s8, fontWeight: FontWeight.w700, color: Colors.white)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('TO', textScaler: const TextScaler.linear(1.0),
                                      style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s7, fontWeight: FontWeight.w600, color: _TI.inkLight, letterSpacing: 0.8)),
                                    SizedBox(height: 0.3.h),
                                    Text(_calculateEndDate(travelData.batchInfo?.startDate, travelData.durationDays),
                                      textScaler: const TextScaler.linear(1.0),
                                      style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s11, fontWeight: FontWeight.w700, color: _TI.ink)),
                                    Text(_dashboardC.toController.value.text, textScaler: const TextScaler.linear(1.0),
                                      style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s9, color: _TI.inkMid)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 1.5.h),
                        Text(
                          'A round-trip trek covering ${travelData.title ?? '-'}',
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s9, color: _TI.inkMid, height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // ── Travellers card ───────────────────────────────────
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader('Travellers', Icons.people_outline_rounded),
                        SizedBox(height: 2.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FF),
                            borderRadius: BorderRadius.circular(3.w),
                            border: Border.all(color: _TI.brand.withOpacity(0.12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Adults', textScaler: const TextScaler.linear(1.0),
                                    style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s12, fontWeight: FontWeight.w600, color: _TI.ink)),
                                  Text('18+ years', textScaler: const TextScaler.linear(1.0),
                                    style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s9, color: _TI.inkMid)),
                                ],
                              ),
                              Obx(() {
                                final adultCount = _trekC.calculateFareRequestModel.value.travelerCount;
                                return Row(
                                  children: [
                                    _counterBtn(Icons.remove, () {
                                      setState(() {
                                        if (adultCount > 1) {
                                          _trekC.calculateFareRequestModel.value =
                                              _trekC.calculateFareRequestModel.value.copyWith(travelerCount: adultCount - 1);
                                          if (selectedTravellers.length > adultCount) {
                                            selectedTravellers = selectedTravellers.take(adultCount).toList();
                                          }
                                        }
                                      });
                                      _trekC.trekPersonCount.value = adultCount;
                                      _trekC.travellerDetailList.value = selectedTravellers;
                                    }, active: adultCount > 1),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                                      child: Text('$adultCount', textScaler: const TextScaler.linear(1.0),
                                        style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s16, fontWeight: FontWeight.w700, color: _TI.ink)),
                                    ),
                                    _counterBtn(Icons.add, () {
                                      if (adultCount < (travelData.batchInfo?.availableSlots ?? 0)) {
                                        _trekC.calculateFareRequestModel.value =
                                            _trekC.calculateFareRequestModel.value.copyWith(travelerCount: adultCount + 1);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text('Maximum available slots reached (${travelData.batchInfo?.availableSlots ?? 0})', textScaler: const TextScaler.linear(1.0)),
                                          backgroundColor: CommonColors.appRedColor,
                                          duration: const Duration(seconds: 2),
                                        ));
                                      }
                                      _trekC.trekPersonCount.value = adultCount;
                                    }, active: adultCount < (travelData.batchInfo?.availableSlots ?? 0)),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // ── Contact Details card ──────────────────────────────
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: _sectionHeader('Contact Details', Icons.contact_phone_outlined)),
                            GestureDetector(
                              onTap: () => _showContactDetailsBottomSheet(
                                isEdit: _userC.userProfileData.value.customer?.email != null &&
                                    _userC.userProfileData.value.customer?.phone != null,
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: _TI.brand.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _TI.brand.withOpacity(0.25)),
                                ),
                                child: Text(
                                  (_userC.userProfileData.value.customer?.email != null &&
                                      _userC.userProfileData.value.customer?.phone != null) ? 'Edit' : 'Add',
                                  textScaler: const TextScaler.linear(1.0),
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s9, fontWeight: FontWeight.w600, color: _TI.brand),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Text('Trip ticket details will be provided to', textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s8, color: _TI.inkMid)),
                        SizedBox(height: 2.h),
                        _infoRow(CommonImages.phone, _userC.userProfileData.value.customer?.phone ?? '-'),
                        _infoRow(CommonImages.email, _userC.userProfileData.value.customer?.email ?? '-'),
                        _infoRow(CommonImages.location4,
                          _userC.userProfileData.value.customer?.state?.id != null
                              ? _dashboardC.stateList[_dashboardC.stateList.indexWhere(
                                  (e) => e.id == _userC.userProfileData.value.customer?.state?.id)].name ?? '-'
                              : '-',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // ── Traveller Details card ────────────────────────────
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: _sectionHeader('Traveller Details', Icons.badge_outlined)),
                            GestureDetector(
                              onTap: () => _showTravellerBottomSheet(isEdit: false),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: _TI.iconBadge,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_rounded, color: Colors.white, size: 3.5.w),
                                    SizedBox(width: 1.w),
                                    Text('Add New', textScaler: const TextScaler.linear(1.0),
                                      style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s9, fontWeight: FontWeight.w600, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Obx(() {
                          final adultCount = _trekC.calculateFareRequestModel.value.travelerCount;
                          return Text(
                            'Select up to $adultCount traveller${adultCount > 1 ? 's' : ''} (${selectedTravellers.length}/$adultCount selected)',
                            textScaler: const TextScaler.linear(1.0),
                            style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s9, color: _TI.inkMid),
                          );
                        }),
                        SizedBox(height: 1.5.h),

                        if (_userC.userProfileData.value.customer?.travelers?.isEmpty ?? true)
                          GestureDetector(
                            onTap: () => _showTravellerBottomSheet(isEdit: false),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 2.5.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FF),
                                borderRadius: BorderRadius.circular(3.w),
                                border: Border.all(color: _TI.brand.withOpacity(0.2), width: 1.5),
                              ),
                              child: Column(
                                children: [
                                  SvgPicture.asset(CommonImages.adduser, width: 10.w, height: 10.w),
                                  SizedBox(height: 1.h),
                                  Text('Tap to add traveller details', textScaler: const TextScaler.linear(1.0),
                                    style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s11, fontWeight: FontWeight.w500, color: _TI.brand)),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _userC.userProfileData.value.customer?.travelers?.length ?? 0,
                            separatorBuilder: (_, __) => SizedBox(height: 1.h),
                            itemBuilder: (context, index) {
                              final traveler = _userC.userProfileData.value.customer?.travelers?[index];
                              return _buildExistingTravellerItem(
                                travelData: traveler!,
                                isSelected: selectedTravellers.any((t) => t.id == traveler.id),
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // ── Free Cancellation card ────────────────────────────
                  Obx(() {
                    CalculateFareResponseModel? fareResp = _trekC.calculateFareResponseModel.value.maybeWhen(
                      success: (r) => r, orElse: () => null);
                    return Visibility(
                      visible: fareResp?.allowCancellation ?? true,
                      child: _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader('Free Cancellation', Icons.shield_outlined),
                            SizedBox(height: 1.5.h),
                            RichText(
                              textScaler: const TextScaler.linear(1.0),
                              text: TextSpan(children: [
                                TextSpan(text: 'A fee of ₹90 per person will be charged for a full refund on cancellations made ',
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s9, fontWeight: FontWeight.w300, color: _TI.ink)),
                                TextSpan(text: 'T&C',
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s9, fontWeight: FontWeight.w600, color: CommonColors.blueColor)),
                                TextSpan(text: ' at least 24 hours prior to departure.',
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s9, fontWeight: FontWeight.w300, color: _TI.ink)),
                              ]),
                            ),
                            SizedBox(height: 2.h),
                            Obx(() {
                              final freeCancellation = _trekC.calculateFareRequestModel.value.addFreeCancellationProtection;
                              return GestureDetector(
                                onTap: () {
                                  _trekC.calculateFareRequestModel.value =
                                      _trekC.calculateFareRequestModel.value.copyWith(addFreeCancellationProtection: !freeCancellation);
                                  if (_trekC.calculateFareRequestModel.value.addFreeCancellationProtection) {
                                    _showTickOverlay(context);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                                  decoration: BoxDecoration(
                                    color: freeCancellation ? _TI.brand.withOpacity(0.06) : const Color(0xFFF8F9FF),
                                    borderRadius: BorderRadius.circular(3.w),
                                    border: Border.all(color: freeCancellation ? _TI.brand.withOpacity(0.3) : _TI.divider),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        key: _checkboxKey,
                                        width: 6.25.w,
                                        height: 6.25.w,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: CommonColors.lightBlueColor.withValues(alpha: 0.7), width: 0.5.w),
                                          borderRadius: BorderRadius.circular(5),
                                          color: freeCancellation ? CommonColors.blueColor : Colors.white,
                                        ),
                                        child: freeCancellation ? Icon(Icons.check, size: 5.w, color: Colors.white) : null,
                                      ),
                                      SizedBox(width: 3.w),
                                      Expanded(
                                        child: Text('I would like to choose the free cancellation option',
                                          textScaler: const TextScaler.linear(1.0),
                                          style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s10, fontWeight: FontWeight.w500, color: _TI.ink)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  }),

                  SizedBox(height: 2.h),

                  // ── Travel Insurance card ─────────────────────────────
                  Obx(() {
                    final selectedInsuranceOption = _trekC.calculateFareRequestModel.value.addInsurance;
                    return _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 9.w, height: 9.w,
                                decoration: BoxDecoration(color: _TI.iconBadge, borderRadius: BorderRadius.circular(2.5.w)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2.5.w),
                                  child: Image.asset(CommonImages.logo, fit: BoxFit.contain),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Travel Insurance', textScaler: const TextScaler.linear(1.0),
                                      style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s14, fontWeight: FontWeight.w700, color: _TI.ink)),
                                    Text('Secure your trek, enjoy the adventure', textScaler: const TextScaler.linear(1.0),
                                      style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s8, color: _TI.inkMid)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text('View covers', textScaler: const TextScaler.linear(1.0),
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s9, fontWeight: FontWeight.w600, color: CommonColors.blueColor)),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          _insuranceOption(
                            title: 'Add Travel Insurance',
                            subtitle: '₹80 for 1 Traveller',
                            isSelected: selectedInsuranceOption == true,
                            onTap: () => _trekC.calculateFareRequestModel.value =
                                _trekC.calculateFareRequestModel.value.copyWith(addInsurance: true),
                          ),
                          SizedBox(height: 1.2.h),
                          _insuranceOption(
                            title: "Don't add Travel Insurance",
                            isSelected: selectedInsuranceOption == false,
                            onTap: () => _trekC.calculateFareRequestModel.value =
                                _trekC.calculateFareRequestModel.value.copyWith(addInsurance: false),
                          ),
                        ],
                      ),
                    );
                  }),

                  SizedBox(height: 2.h),

                  // ── Payment Options card ──────────────────────────────
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader('Payment Options', Icons.payment_outlined),
                        SizedBox(height: 0.5.h),
                        Text("Lock your spot. Adventure's calling!", textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s9, color: _TI.inkMid)),
                        SizedBox(height: 2.h),
                        if (travelData.cancellationPolicy?.id != 1) ...[
                          _paymentOption(
                            title: 'Pay ₹999',
                            subtitle: _getTotalFareSubtitleText(),
                            isSelected: _selectedPaymentOption == 'flexible',
                            onTap: () {
                              setState(() => _selectedPaymentOption = 'flexible');
                              _trekC.calculateFareRequestModel.value =
                                  _trekC.calculateFareRequestModel.value.copyWith(cancellationPolicyType: 'flexible');
                            },
                          ),
                          SizedBox(height: 1.2.h),
                        ],
                        _paymentOption(
                          title: 'Pay Full Payment',
                          subtitle: 'Secure your booking with full payment',
                          isSelected: _selectedPaymentOption == 'standard',
                          onTap: () {
                            setState(() => _selectedPaymentOption = 'standard');
                            _trekC.calculateFareRequestModel.value =
                                _trekC.calculateFareRequestModel.value.copyWith(cancellationPolicyType: 'standard');
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Loading overlay — original logic
          Obx(() => _trekC.calculateFareResponseModel.value.maybeWhen(
            loading: (_) => Container(
              color: CommonColors.grey400,
              child: Center(child: CircularProgressIndicator(color: CommonColors.blueColor)),
            ),
            orElse: () => const SizedBox(),
          )),
        ],
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _TI.cardBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: _TI.ink),
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _TI.divider),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Traveller Information', textScaler: const TextScaler.linear(1.0),
            style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s13, fontWeight: FontWeight.w700, color: _TI.ink)),
          Row(
            children: [
              if (_dashboardC.fromController.value.text.isNotEmpty)
                Flexible(child: Text(_dashboardC.fromController.value.text, textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s9, color: _TI.inkMid))),
              if (_dashboardC.fromController.value.text.isNotEmpty && _dashboardC.toController.value.text.isNotEmpty)
                Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.arrow_forward_rounded, color: _TI.inkLight, size: 12)),
              if (_dashboardC.toController.value.text.isNotEmpty)
                Flexible(child: Text(_dashboardC.toController.value.text, textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s9, color: _TI.inkMid))),
            ],
          ),
        ],
      ),
    );
  }

  // ── BOTTOM BAR — original logic ───────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: Obx(() {
        final fareReqModel = _trekC.calculateFareRequestModel.value;
        CalculateFareResponseModel? fareRespModel = _trekC.calculateFareResponseModel.value.maybeWhen(
          success: (r) => r, orElse: () => null);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (fareReqModel.travelerCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 27, right: 25, top: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => TotalFareModal(
                          breakDown: fareRespModel?.breakdown,
                          adultCount: fareReqModel.travelerCount,
                          onClose: () => Navigator.pop(context),
                        ),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Fare', textScaler: const TextScaler.linear(1.0),
                                style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s10, fontWeight: FontWeight.w600, color: _TI.ink)),
                              Text('Tax Included', textScaler: const TextScaler.linear(1.0),
                                style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s8, color: _TI.inkMid)),
                            ],
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: _TI.inkMid),
                        ],
                      ),
                    ),
                    RichText(
                      textScaler: const TextScaler.linear(1.0),
                      text: TextSpan(children: [
                        TextSpan(text: '₹ ', style: GoogleFonts.roboto(fontSize: FontSize.s15, fontWeight: FontWeight.w600, color: CommonColors.softGreen2)),
                        TextSpan(text: '${fareRespModel?.breakdown?.amountToPayNow ?? "--"}',
                          style: GoogleFonts.poppins(fontSize: FontSize.s16, fontWeight: FontWeight.w700, color: CommonColors.softGreen2)),
                      ]),
                    ),
                  ],
                ),
              ),
            if (fareReqModel.travelerCount > 0) SizedBox(height: 1.5.h),
            Padding(
              padding: const EdgeInsets.only(left: 41, right: 41, bottom: 20),
              child: Obx(() {
                final isFormValid = _trekC.calculateFareRequestModel.value.travelerCount > 0 &&
                    _userC.userProfileData.value.customer?.email != null &&
                    _userC.userProfileData.value.customer?.phone != null &&
                    _userC.userProfileData.value.customer?.state?.id != null &&
                    selectedTravellers.length >= _trekC.calculateFareRequestModel.value.travelerCount;
                return CommonButton(
                  text: 'Pay Now',
                  fontSize: FontSize.s14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  onPressed: () {
                    if (isFormValid) {
                      _trekC.createOrderRequestModel.value =
                          _trekC.createOrderRequestModel.value.copyWith(travelers: selectedTravellers.toList());
                      _handlePayment(fareRespModel?.breakdown);
                    }
                  },
                  gradient: isFormValid ? CommonColors.filterGradient : CommonColors.disableBtnGradient,
                  textColor: CommonColors.whiteColor,
                  height: 48,
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────
  Widget _counterBtn(IconData icon, VoidCallback onTap, {bool active = true}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 8.w, height: 8.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? _TI.iconBadge : const Color(0xFFF1F5F9),
        ),
        child: Icon(icon, size: 4.w, color: active ? Colors.white : _TI.inkLight),
      ),
    );
  }

  Widget _insuranceOption({required String title, String? subtitle, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected ? _TI.brand.withOpacity(0.05) : const Color(0xFFF8F9FF),
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(color: isSelected ? _TI.brand.withOpacity(0.4) : _TI.divider, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 6.w, height: 6.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected ? CommonColors.radioBtnGradient : null,
                border: isSelected ? null : Border.all(color: CommonColors.greyColor585858, width: 0.5.w),
                color: Colors.white,
              ),
              child: isSelected ? Center(child: Container(width: 2.w, height: 2.w, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))) : null,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s11, fontWeight: FontWeight.w500, color: _TI.ink)),
                  if (subtitle != null)
                    Text(subtitle, textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s8, color: _TI.inkMid)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentOption({required String title, required String subtitle, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        decoration: BoxDecoration(
          color: isSelected ? _TI.brand.withOpacity(0.05) : const Color(0xFFF8F9FF),
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(color: isSelected ? _TI.brand.withOpacity(0.4) : _TI.divider, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 6.w, height: 6.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected ? CommonColors.radioBtnGradient : null,
                border: isSelected ? null : Border.all(color: CommonColors.greyColor585858, width: 0.5.w),
                color: Colors.white,
              ),
              child: isSelected ? Center(child: Container(width: 2.w, height: 2.w, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))) : null,
            ),
            SizedBox(width: 3.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s11, fontWeight: FontWeight.w600, color: _TI.ink)),
                Text(subtitle, textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s8, color: _TI.inkMid)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingTravellerItem({required Traveler travelData, required bool isSelected}) {
    return Obx(() {
      final adultCount = _trekC.calculateFareRequestModel.value.travelerCount;
      if (selectedTravellers.length > adultCount) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() { selectedTravellers.clear(); _trekC.travellerDetailList.value = []; });
        });
        return const SizedBox.shrink();
      }
      final bool isTravellerSelected = selectedTravellers.any((t) => t.id == travelData.id);
      final bool canSelect = isTravellerSelected || selectedTravellers.length < adultCount;

      return Container(
        decoration: BoxDecoration(
          color: isTravellerSelected ? _TI.brand.withOpacity(0.04) : const Color(0xFFF8F9FF),
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(color: isTravellerSelected ? _TI.brand.withOpacity(0.3) : _TI.divider, width: isTravellerSelected ? 1.5 : 1),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          child: Row(
            children: [
              SizedBox(
                width: 24, height: 24,
                child: Checkbox(
                  value: isTravellerSelected,
                  onChanged: canSelect ? (bool? value) {
                    setState(() {
                      if (value ?? false) {
                        if (!selectedTravellers.any((t) => t.id == travelData.id)) selectedTravellers.add(travelData);
                      } else {
                        selectedTravellers.removeWhere((t) => t.id == travelData.id);
                      }
                      _trekC.travellerDetailList.value = List.from(selectedTravellers);
                    });
                  } : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  activeColor: _TI.brand,
                ),
              ),
              SizedBox(width: 3.w),
              // Avatar
              Container(
                width: 9.w, height: 9.w,
                decoration: BoxDecoration(
                  color: isTravellerSelected ? _TI.brand.withOpacity(0.12) : const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (travelData.name?.isNotEmpty == true) ? travelData.name![0].toUpperCase() : '?',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s12, fontWeight: FontWeight.w700,
                      color: isTravellerSelected ? _TI.brand : _TI.inkMid),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(travelData.name ?? '-', textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s11, fontWeight: FontWeight.w600,
                        color: canSelect ? _TI.ink : _TI.inkLight)),
                    Text('${travelData.gender ?? ''}, ${travelData.age ?? ''}', textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s9,
                        color: canSelect ? _TI.inkMid : _TI.inkLight)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showTravellerBottomSheet(traveller: travelData, isEdit: true),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
                  decoration: BoxDecoration(
                    color: _TI.brand.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _TI.brand.withOpacity(0.2)),
                  ),
                  child: Text('Edit', textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s9, fontWeight: FontWeight.w600, color: _TI.brand)),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _handlePayment(BreakDownDataModel? breakDown) {
    Get.toNamed(BookingRoutes.payment);
  }

  String _getTotalFareSubtitleText() {
    if (_selectedPaymentOption == BookingConstants.partialPayment) {
      return 'Advance Paid ₹999, pay remaining before trek start';
    }
    return 'Secure your booking with full payment';
  }
}
