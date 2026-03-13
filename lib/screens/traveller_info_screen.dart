import 'dart:developer';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/models/user_profile/user_profile_modal.dart';
import 'package:arobo_app/models/user_profile/state_list_model.dart';
import 'package:arobo_app/utils/common_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_colors.dart';
import '../utils/common_images.dart';
import '../utils/screen_constants.dart';

class TravellerInfoScreen extends StatefulWidget {
  const TravellerInfoScreen({super.key});

  @override
  State<TravellerInfoScreen> createState() => _TravellerInfoScreenState();
}

class _TravellerInfoScreenState extends State<TravellerInfoScreen> {
  final nameNode = FocusNode();

  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _stateController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedState = '';
  List<StateListData> filteredStates = [];
  bool isTravellerUpdate = false;
  bool isShowTravellerForm = false;
  bool isShowContactUpdate = false;

  @override
  void initState() {
    super.initState();
    // Initialize filtered states with the state list from controller
    filteredStates = List.from(_dashboardC.stateList);

    _nameController.addListener(_onFieldChanged);
    _dateController.addListener(_onFieldChanged);
    _stateController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);

    // Initialize state when user profile is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStateData();
    });
  }

  void _initializeStateData() {
    if (_userC.userProfileData.value.customer?.state?.id != null) {
      // User has existing state data
      _userC.stateUpdateId.value =
          _userC.userProfileData.value.customer!.state?.id ?? 0;
      _selectedState = _userC.userProfileData.value.customer?.state?.name ?? '';
    } else if (filteredStates.isNotEmpty) {
      // New user - set default state
      _userC.stateUpdateId.value = filteredStates.first.id ?? 0;
      _selectedState = filteredStates.first.name ?? '';
    }
  }

  void _onFieldChanged() {
    setState(() {
      // This will trigger a rebuild to update the button state
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _stateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  final UserController _userC = Get.find<UserController>();
  final DashboardController _dashboardC = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    // Listen to user profile data changes and initialize state
    _userC.userProfileData.listen((userData) {
      if (userData.customer != null) {
        _initializeStateData();
      }
    });

    return Scaffold(
      backgroundColor: CommonColors.offWhiteColor3,
      appBar: AppBar(
        backgroundColor: CommonColors.lightBlueColor3.withValues(alpha: 0.2),
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: false,
        title: Text(
          'Traveller Information',
          style: GoogleFonts.roboto(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w500,
            color: CommonColors.blackColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 5.h,
            color: CommonColors.lightBlueColor3.withValues(alpha: 0.2),
          ),
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  if (_userC.userProfileData.value.customer?.email != null &&
                      _userC.userProfileData.value.customer?.phone != null)
                    SizedBox(
                      width: 100.w,
                      child: Container(
                        // elevation: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.w),
                          boxShadow: [
                            BoxShadow(
                              color: CommonColors.blackColor
                                  .withValues(alpha: 0.2),
                              offset: Offset(2, 2),
                              blurRadius: 6,
                              spreadRadius: 2,
                            )
                          ],
                          color: CommonColors.whiteColor,
                        ),
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.circular(5.w),
                        // ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                        setState(() {
                                          isShowContactUpdate =
                                              !isShowContactUpdate;
                                          _userC.phoneNumberController.value
                                              .text = (_userC.userProfileData
                                                      .value.customer?.phone ??
                                                  '-')
                                              .replaceFirst('+91', '');
                                          _userC.emailController.value.text =
                                              _userC.userProfileData.value
                                                      .customer?.email ??
                                                  '-';
                                          _userC.stateUpdateId.value = _userC
                                              .userProfileData
                                              .value
                                              .customer!
                                              .state!
                                              .id!;
                                          _selectedState = _userC
                                                  .userProfileData
                                                  .value
                                                  .customer
                                                  ?.state
                                                  ?.name ??
                                              '-';
                                        });
                                      },
                                      child: Text(
                                        'Edit',
                                        textScaler:
                                            const TextScaler.linear(1.0),
                                        style: GoogleFonts.alexandria(
                                          fontSize: FontSize.s10,
                                          fontWeight: FontWeight.w500,
                                          color: CommonColors.blueColor,
                                        ),
                                      ),
                                    ),
                                  ]),

                              SizedBox(height: 0.3.h),
                              Text(
                                'Trip ticket details will be provided to',
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s8,
                                  color: CommonColors.blackColor
                                      .withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),

                              SizedBox(height: 2.h),
                              // Phone Row for the existing user data
                              Container(
                                color: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.w, vertical: 1.h),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child:
                                          SvgPicture.asset(CommonImages.phone),
                                    ),
                                    SizedBox(width: 3.w),
                                    // Phone Number and Label
                                    Expanded(
                                      child: Text(
                                        _userC.userProfileData.value.customer
                                                ?.phone ??
                                            '-',
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
                              // Email Row for the existing user data
                              Container(
                                color: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.w, vertical: 1.h),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child:
                                          SvgPicture.asset(CommonImages.email),
                                    ),
                                    SizedBox(width: 3.w),
                                    // Phone Number and Label
                                    Expanded(
                                      child: Text(
                                        _userC.userProfileData.value.customer
                                                ?.email ??
                                            '-',
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
                              //
                              // State of Residence for user data
                              Container(
                                color: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.w, vertical: 1.h),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: SvgPicture.asset(
                                          CommonImages.location4),
                                    ),
                                    SizedBox(width: 3.w),
                                    // Phone Number and Label
                                    Expanded(
                                      child: Text(
                                        _dashboardC
                                                .stateList[_dashboardC.stateList
                                                    .indexWhere(
                                              (element) =>
                                                  element.id ==
                                                  _userC.userProfileData.value
                                                      .customer!.state?.id,
                                            )]
                                                .name ??
                                            '-',
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
                              // WhatsApp row for the existing user data
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (_userC.userProfileData.value.customer?.email != null &&
                      _userC.userProfileData.value.customer?.phone != null)
                    SizedBox(height: 2.h),

                  if (isShowContactUpdate ||
                      _userC.userProfileData.value.customer?.email == null ||
                      _userC.userProfileData.value.customer?.phone == null ||
                      _userC.userProfileData.value.customer?.state?.id == null)
                    SizedBox(
                      width: 100.w,
                      child: Container(
                        // elevation: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.w),
                          boxShadow: [
                            BoxShadow(
                              color: CommonColors.blackColor
                                  .withValues(alpha: 0.2),
                              offset: Offset(2, 2),
                              blurRadius: 6,
                              spreadRadius: 2,
                            )
                          ],
                          color: CommonColors.whiteColor,
                        ),
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.circular(5.w),
                        // ),
                        child: Container(
                          width: 100.w,
                          margin: EdgeInsets.only(
                            left: 6.w,
                            right: 6.w,
                            top: 1.5.h,
                            bottom: 1.5.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Contact Details',
                                      textScaler: const TextScaler.linear(1.0),
                                      style: GoogleFonts.alexandria(
                                        fontSize: FontSize.s14,
                                        fontWeight: FontWeight.w500,
                                        color: CommonColors.blackColor,
                                      ),
                                    ),
                                  ),
                                  if (isShowContactUpdate)
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isShowContactUpdate =
                                                !isShowContactUpdate;
                                          });
                                        },
                                        icon: Icon(Icons.cancel_outlined))
                                ],
                              ),
                              SizedBox(height: 0.3.h),
                              Text(
                                'Trip ticket details will be provided to',
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s8,
                                  color: CommonColors.blackColor
                                      .withValues(alpha: 0.6),
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
                                    // Country code
                                    Container(
                                      width: 27.w,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 1.2.h),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: Color(0xFF878787),
                                            width: 0.25.w,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Country Code',
                                            textScaler:
                                                const TextScaler.linear(1.0),
                                            style: GoogleFonts.poppins(
                                              fontSize: FontSize.s7,
                                              color: CommonColors.blackColor,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          SizedBox(height: 0.4.h),
                                          Text(
                                            '+91(IND)',
                                            textScaler:
                                                const TextScaler.linear(1.0),
                                            style: GoogleFonts.poppins(
                                              fontSize: FontSize.s10,
                                              fontWeight: FontWeight.w400,
                                              color: CommonColors.blackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Phone number
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 3.w,
                                            right: 3.w,
                                            top: 0.8.h,
                                            bottom: 0.8.h),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Phone Number',
                                              textScaler:
                                                  const TextScaler.linear(1.0),
                                              style: GoogleFonts.poppins(
                                                fontSize: FontSize.s7,
                                                color: CommonColors.blackColor,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                            MediaQuery(
                                              data: MediaQuery.of(context)
                                                  .copyWith(
                                                      textScaler:
                                                          TextScaler.linear(
                                                              1.0)),
                                              child: TextField(
                                                enabled: false,
                                                controller: _userC
                                                    .phoneNumberController
                                                    .value,
                                                keyboardType:
                                                    TextInputType.phone,
                                                maxLength: 10,
                                                style: GoogleFonts.poppins(
                                                  fontSize: FontSize.s10,
                                                  color:
                                                      CommonColors.blackColor,
                                                ),
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  counterText: '',
                                                  isDense: true,
                                                ),
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
                                    left: 4.w, top: 0.8.h, bottom: 0.8.h),
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
                                          textScaler: TextScaler.linear(1.0)),
                                      child: TextField(
                                        controller:
                                            _userC.emailController.value,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: GoogleFonts.poppins(
                                          fontSize: FontSize.s10,
                                          fontWeight: FontWeight.w400,
                                          color: CommonColors.blackColor,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
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
                                    onTap: _showStateSelectionBottomSheet,
                                    borderRadius: BorderRadius.circular(2.w),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4.w, vertical: 1.h),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'State of Residence',
                                                textScaler:
                                                    const TextScaler.linear(
                                                        1.0),
                                                style: GoogleFonts.poppins(
                                                  fontSize: FontSize.s7,
                                                  color:
                                                      CommonColors.blackColor,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                              SizedBox(height: 0.25.h),
                                              Text(
                                                _selectedState,
                                                textScaler:
                                                    const TextScaler.linear(
                                                        1.0),
                                                style: GoogleFonts.poppins(
                                                  fontSize: FontSize.s10,
                                                  fontWeight: FontWeight.w400,
                                                  color:
                                                      CommonColors.blackColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Icon(Icons.keyboard_arrow_down,
                                              color: Colors.black, size: 6.w),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              // WhatsApp row
                              // Row(
                              //   crossAxisAlignment: CrossAxisAlignment.center,
                              //   children: [
                              //     SvgPicture.asset(
                              //       CommonImages.whatsappIcon,
                              //       width: 9.w,
                              //       height: 9.w,
                              //     ),
                              //     SizedBox(width: 2.5.w),
                              //     Expanded(
                              //       child: Text(
                              //         'Share booking details and trek updates via WhatsApp',
                              //         textScaler: const TextScaler.linear(1.0),
                              //         style: GoogleFonts.poppins(
                              //           fontSize: FontSize.s8,
                              //           fontWeight: FontWeight.w300,
                              //           color: CommonColors.blackColor
                              //               .withValues(alpha: 0.7),
                              //         ),
                              //       ),
                              //     ),
                              //     Transform.scale(
                              //       scale: 0.8,
                              //       child: Switch.adaptive(
                              //         activeColor: CommonColors.whiteColor,
                              //         activeTrackColor: CommonColors
                              //             .completedColor
                              //             .withValues(alpha: 0.8),
                              //         inactiveTrackColor:
                              //             CommonColors.shimmerBaseColor,
                              //         inactiveThumbColor: CommonColors.blackColor,
                              //         value: _whatsappUpdates,
                              //         onChanged: (value) {
                              //           setState(() {
                              //             _whatsappUpdates = value;
                              //           });
                              //         },
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              CommonButton(
                                height: 48,
                                gradient: CommonColors.filterGradient,
                                text: 'Save',
                                textColor: CommonColors.whiteColor,
                                onPressed: () async {
                                  await _userC.updateUserProfile();
                                  setState(() {
                                    isShowContactUpdate = false;
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (isShowContactUpdate ||
                      _userC.userProfileData.value.customer?.email == null ||
                      _userC.userProfileData.value.customer?.phone == null ||
                      _userC.userProfileData.value.customer?.state?.id == null)
                    SizedBox(height: 2.h),
                  if (_userC.userProfileData.value.customer?.travelers
                          ?.isNotEmpty ??
                      false)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: CommonColors.whiteColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                CommonColors.blackColor.withValues(alpha: 0.2),
                            offset: Offset(2, 2),
                            blurRadius: 6,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Traveller Details',
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s14,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.blackColor,
                              ),
                            ),

                            SizedBox(height: 2.h),
                            // Static traveller list
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _userC.userProfileData.value.customer
                                      ?.travelers?.length ??
                                  0,
                              itemBuilder: (context, index) {
                                final traveler = _userC.userProfileData.value
                                    .customer?.travelers?[index];
                                return Column(
                                  children: [
                                    _buildExistingTravellerItem(
                                      travelData: traveler!,
                                    ),
                                    if (index !=
                                        (_userC.userProfileData.value.customer
                                                    ?.travelers?.length ??
                                                0) -
                                            1)
                                      SizedBox(height: 1.h),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (isShowTravellerForm ||
                      (_userC.userProfileData.value.customer?.travelers
                              ?.isEmpty ??
                          true))
                    SizedBox(height: 2.h),
                  if (isShowTravellerForm ||
                      (_userC.userProfileData.value.customer?.travelers
                              ?.isEmpty ??
                          true))
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: CommonColors.whiteColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                CommonColors.blackColor.withValues(alpha: 0.2),
                            offset: Offset(2, 2),
                            blurRadius: 6,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(
                          left: 33,
                          right: 33,
                          top: 23,
                          bottom: 23,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Traveller Details',
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.alexandria(
                                      fontSize: FontSize.s14,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.blackColor,
                                    ),
                                  ),
                                ),
                                if (isTravellerUpdate || isShowTravellerForm)
                                  IconButton(
                                      onPressed: () {
                                        isTravellerUpdate = false;
                                        isShowTravellerForm = false;
                                        FocusScope.of(context).unfocus();
                                        _userC.nameControllerTraveller.value
                                            .clear();
                                        _userC.ageControllerTraveller.value
                                            .clear();
                                        _userC.selectedGender.value = '';
                                        setState(() {});
                                      },
                                      icon: Icon(Icons.cancel_outlined))
                              ],
                            ),
                            SizedBox(height: 2.h),
                            _buildTextField(
                                controller:
                                    _userC.nameControllerTraveller.value,
                                hint: 'Name',
                                focusNode: nameNode),
                            SizedBox(height: 2.h),
                            _buildTextField(
                                controller: _userC.ageControllerTraveller.value,
                                hint: 'Age',
                                keyboardType: TextInputType.number),
                            SizedBox(height: 1.7.h),
                            Text(
                              'Gender',
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s11,
                                fontWeight: FontWeight.w300,
                                color: CommonColors.blackColor
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Row(
                              children: [
                                _buildGenderButton('Male'),
                                SizedBox(width: 2.w),
                                _buildGenderButton('Female'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: 2.h),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.w),
                    width: 100.w,
                    decoration: BoxDecoration(
                      color: CommonColors.whiteColor,
                      borderRadius: BorderRadius.circular(6.w),
                      boxShadow: [
                        BoxShadow(
                          color: CommonColors.blackColor.withValues(alpha: 0.2),
                          offset: Offset(2, 2),
                          blurRadius: 6,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          // If form is not visible and we have existing travellers, show the form
                          if (!isShowTravellerForm &&
                              (_userC.userProfileData.value.customer?.travelers
                                      ?.isNotEmpty ??
                                  false)) {
                            setState(() {
                              isShowTravellerForm = true;
                            });
                            return;
                          }

                          // If form is visible or no existing travellers, proceed with add/update
                          if (isTravellerUpdate) {
                            await _userC.updateTraveler();
                            setState(() {
                              isTravellerUpdate = false;
                              isShowTravellerForm = false;
                            });
                          } else {
                            await _userC.addTraveler();
                            log('message : ${_userC.nameControllerTraveller.value.text},${_userC.ageControllerTraveller.value} ');
                            setState(() {
                              isShowTravellerForm = false;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(6.w),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 1.2.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                CommonImages.adduser,
                                width: 7.5.w,
                                height: 7.5.w,
                              ),
                              SizedBox(width: 2.5.w),
                              Text(
                                isTravellerUpdate
                                    ? 'Update Traveller'
                                    : isShowTravellerForm
                                        ? 'Add Traveller'
                                        : 'Add New Traveller',
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s14,
                                  fontWeight: FontWeight.w600,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // SizedBox(height: 2.h),
                  // // Traveller Information Card
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 1.w),
                  //   child: Container(
                  //     width: double.infinity,
                  //     height: 35.h,
                  //     padding: EdgeInsets.all(5.w),
                  //     decoration: BoxDecoration(
                  //       color: CommonColors.whiteColor,
                  //       borderRadius: BorderRadius.circular(5.w),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color:
                  //               CommonColors.blackColor.withValues(alpha: 0.2),
                  //           offset: Offset(2, 2),
                  //           blurRadius: 6,
                  //           spreadRadius: 2,
                  //         )
                  //       ],
                  //     ),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           'Traveller Information',
                  //           // textScaler: const TextScaler.linear(1.0),
                  //           style: GoogleFonts.roboto(
                  //             fontSize: FontSize.s12,
                  //             fontWeight: FontWeight.w500,
                  //             letterSpacing: 0.5,
                  //             color: CommonColors.blackColor
                  //                 .withValues(alpha: 0.8),
                  //           ),
                  //         ),
                  //         SizedBox(height: 2.h),
                  //         _buildTextField(
                  //           controller: _nameController,
                  //           hint: 'Name',
                  //         ),
                  //         SizedBox(height: 2.h),
                  //         GestureDetector(
                  //           onTap: _selectDate,
                  //           child: _buildTextField(
                  //             controller: _dateController,
                  //             hint: 'Date of Birth',
                  //             suffixIcon: Padding(
                  //               padding: EdgeInsets.all(3.w),
                  //               child: SvgPicture.asset(
                  //                 CommonImages.calendar,
                  //                 width: 5.w,
                  //                 height: 5.w,
                  //                 // fit: BoxFit.contain,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //         SizedBox(height: 2.h),
                  //         Text(
                  //           'Gender',
                  //           textScaler: const TextScaler.linear(1.0),
                  //           style: GoogleFonts.roboto(
                  //             fontSize: FontSize.s12,
                  //             fontWeight: FontWeight.w400,
                  //             color: CommonColors.blackColor
                  //                 .withValues(alpha: 0.5),
                  //           ),
                  //         ),
                  //         SizedBox(height: 1.h),
                  //         Row(
                  //           children: [
                  //             _buildGenderButton('Male'),
                  //             SizedBox(width: 2.w),
                  //             _buildGenderButton('Female'),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 3.h),
                  // // Contact Details Section with inner and outer shadow effect
                  // Container(
                  //   height: 35.h,
                  //   // margin: EdgeInsets.only(
                  //   //     top: 4), // slight margin to show inner shadow
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(5.w),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: CommonColors.blackColor.withValues(alpha: 0.2),
                  //         offset: Offset(2, 2),
                  //         blurRadius: 6,
                  //         spreadRadius: 2,
                  //       )
                  //     ],
                  //   ),
                  //   padding: EdgeInsets.all(5.w),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       // Your existing content here (Contact Details title, fields, etc.)
                  //       Text(
                  //         'Contact Details',
                  //         style: GoogleFonts.roboto(
                  //           fontSize: FontSize.s12,
                  //           fontWeight: FontWeight.w500,
                  //           letterSpacing: 0.5,
                  //           color:
                  //               CommonColors.blackColor.withValues(alpha: 0.8),
                  //         ),
                  //       ),
                  //       SizedBox(height: 1.5.h),
                  //       // Updated State of Residence UI
                  //       Container(
                  //         // Wrapped in Container
                  //         width: double.infinity, // Added width
                  //         decoration: BoxDecoration(
                  //           // Added decoration
                  //           border: Border.all(
                  //               color: Color(0xFF878787)), // Added border
                  //           borderRadius:
                  //               BorderRadius.circular(8), // Added border radius
                  //           color: Colors.white, // Added background color
                  //         ),
                  //         child: Material(
                  //           // Added Material for InkWell effect
                  //           color: Colors.transparent,
                  //           child: InkWell(
                  //             // Added InkWell for tap detection
                  //             onTap: _showStateSelectionBottomSheet,
                  //             // Call the new method
                  //             borderRadius: BorderRadius.circular(2.w),
                  //             // Match container border radius
                  //             child: Container(
                  //               // Added inner container for padding
                  //               padding: EdgeInsets.symmetric(
                  //                 horizontal: 4.w,
                  //                 vertical: 1.5.h, // Adjusted vertical padding
                  //               ),
                  //               child: Row(
                  //                 mainAxisAlignment:
                  //                     MainAxisAlignment.spaceBetween,
                  //                 children: [
                  //                   Column(
                  //                     crossAxisAlignment:
                  //                         CrossAxisAlignment.start,
                  //                     children: [
                  //                       Text(
                  //                         _selectedState.isEmpty
                  //                             ? 'State of Residence'
                  //                             : _selectedState,
                  //                         textScaler:
                  //                             const TextScaler.linear(1.0),
                  //                         style: GoogleFonts.poppins(
                  //                           fontSize: FontSize.s10,
                  //                           color: CommonColors.blackColor
                  //                               .withValues(alpha: 0.5),
                  //                           fontWeight: FontWeight.w400,
                  //                         ),
                  //                       ),
                  //                     ],
                  //                   ),
                  //                   Icon(Icons.keyboard_arrow_down,
                  //                       // Dropdown icon
                  //                       color: Colors.black,
                  //                       size: 6.w), // Adjusted size
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(height: 0.5.h),
                  //       // Adjusted spacing
                  //       Padding(
                  //         padding: EdgeInsets.only(left: 2.w),
                  //         child: Text(
                  //           'Required for GST Tax Invoicing',
                  //           style: GoogleFonts.roboto(
                  //             fontSize: FontSize.s9,
                  //             color: CommonColors.blackColor
                  //                 .withValues(alpha: 0.5),
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(height: 2.h),
                  //       Container(
                  //         decoration: BoxDecoration(
                  //           border: Border.all(color: Color(0xFF878787)),
                  //           borderRadius: BorderRadius.circular(8),
                  //           color: Colors.white,
                  //         ),
                  //         child: Row(
                  //           children: [
                  //             Container(
                  //               width: 25.w,
                  //               padding: EdgeInsets.symmetric(vertical: 1.2.h),
                  //               decoration: BoxDecoration(
                  //                 border: Border(
                  //                   right: BorderSide(
                  //                     color: Color(0xFF878787),
                  //                     width: 0.25.w,
                  //                   ),
                  //                 ),
                  //               ),
                  //               child: Column(
                  //                 crossAxisAlignment: CrossAxisAlignment.center,
                  //                 children: [
                  //                   Text(
                  //                     'Country Code',
                  //                     textScaler: const TextScaler.linear(1.0),
                  //                     style: GoogleFonts.poppins(
                  //                       fontSize: FontSize.s8,
                  //                       color: CommonColors.blackColor
                  //                           .withValues(alpha: 0.5),
                  //                       fontWeight: FontWeight.w300,
                  //                     ),
                  //                   ),
                  //                   SizedBox(height: 0.4.h),
                  //                   Text(
                  //                     '+91(IND)',
                  //                     textScaler: const TextScaler.linear(1.0),
                  //                     style: GoogleFonts.poppins(
                  //                       fontSize: FontSize.s11,
                  //                       fontWeight: FontWeight.w400,
                  //                       color: CommonColors.blackColor,
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //             Expanded(
                  //               child: Padding(
                  //                 padding: EdgeInsets.only(
                  //                   left: 3.w,
                  //                   right: 3.w,
                  //                   top: 1.2.h,
                  //                   bottom: 0.8.h,
                  //                 ),
                  //                 child: Column(
                  //                   crossAxisAlignment:
                  //                       CrossAxisAlignment.start,
                  //                   children: [
                  //                     Text(
                  //                       'Phone Number',
                  //                       textScaler:
                  //                           const TextScaler.linear(1.0),
                  //                       style: GoogleFonts.poppins(
                  //                         fontSize: FontSize.s8,
                  //                         color: CommonColors.blackColor
                  //                             .withValues(alpha: 0.5),
                  //                         fontWeight: FontWeight.w300,
                  //                       ),
                  //                     ),
                  //                     MediaQuery(
                  //                       data: MediaQuery.of(context).copyWith(
                  //                           textScaler: TextScaler.linear(1.0)),
                  //                       child: TextField(
                  //                         controller: _phoneController,
                  //                         keyboardType: TextInputType.phone,
                  //                         maxLength: 10,
                  //                         style: GoogleFonts.poppins(
                  //                           fontSize: FontSize.s10,
                  //                           color: CommonColors.blackColor,
                  //                         ),
                  //                         decoration: InputDecoration(
                  //                           border: InputBorder.none,
                  //                           counterText: '',
                  //                           isDense: true,
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       SizedBox(height: 2.h),
                  //       _buildTextField(
                  //         controller: _emailController,
                  //         hint: 'Email',
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(height: 4.h),
                  // // Save Button
                  // Container(
                  //   width: double.infinity,
                  //   height: 6.5.h,
                  //   margin: EdgeInsets.symmetric(horizontal: 2.w),
                  //   decoration: BoxDecoration(
                  //     gradient: _isFormValid
                  //         ? CommonColors.btnGradient
                  //         : CommonColors.disableBtnGradient,
                  //     borderRadius: BorderRadius.circular(8.w),
                  //   ),
                  //   child: TextButton(
                  //     onPressed: _isFormValid
                  //         ? () {
                  //             // Save changes
                  //             Navigator.pop(context);
                  //           }
                  //         : null,
                  //     style: TextButton.styleFrom(
                  //       foregroundColor: Colors.transparent,
                  //       disabledForegroundColor: Colors.transparent,
                  //     ),
                  //     child: Text(
                  //       'Save Changes',
                  //       style: GoogleFonts.poppins(
                  //         fontSize: FontSize.s11,
                  //         fontWeight: FontWeight.w600,
                  //         color: CommonColors.whiteColor,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showStateSelectionBottomSheet() async {
    TextEditingController searchController = TextEditingController();

    setState(() {
      filteredStates = List.from(_dashboardC.stateList);
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
          builder: (context, setModalState) {
            return SizedBox(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        IconButton(
                          icon: SvgPicture.asset(
                            CommonImages.close,
                            width: 5.w,
                            height: 5.w,
                            fit: BoxFit.contain,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      height: 6.h,
                      padding: EdgeInsets.symmetric(horizontal: 2.5.w),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              CommonColors.whiteColor,
                              Color(0xFFF8FBFF),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(3.75.w),
                          border: Border.all(
                            color: Color(0xffd5d5d5),
                            width: 0.8,
                          )),
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
                                  color: CommonColors.blackColor
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s10,
                                color: CommonColors.blackColor,
                              ),
                              onChanged: (value) {
                                setModalState(() {
                                  filteredStates = _dashboardC.stateList
                                      .where((state) =>
                                          state.name
                                              ?.toLowerCase()
                                              .contains(value.toLowerCase()) ??
                                          false)
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
                              filteredStates[index].name ?? '',
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s10,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.blackColor,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedState =
                                    filteredStates[index].name ?? '';
                                _userC.stateUpdateId.value =
                                    filteredStates[index].id ?? 0;
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
        filteredStates = List.from(_dashboardC.stateList);
      });
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    FocusNode? focusNode,
    bool enabled = true,
    Widget? suffixIcon,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      child: TextField(
        controller: controller,
        enabled: enabled,
        focusNode: focusNode,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: GoogleFonts.roboto(
          fontSize: FontSize.s11,
          color: CommonColors.blackColor,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.roboto(
            fontSize: FontSize.s11,
            fontWeight: FontWeight.w400,
            color: CommonColors.blackColor.withValues(alpha: 0.5),
          ),
          counterText: '',
          contentPadding: EdgeInsets.only(left: 21, top: 13, bottom: 13),
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
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildGenderButton(String gender) {
    final bool isSelected =
        _userC.selectedGender.value.toLowerCase() == gender.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
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
                left: 4.5.w, right: 2.5.w, top: 1.h, bottom: 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  gender,
                  textScaler: const TextScaler.linear(1.0),
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s11,
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

  Widget _buildExistingTravellerItem({
    required Travelers travelData,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    travelData.name ?? '-',
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w500,
                      color: CommonColors.blackColor,
                    ),
                  ),
                  Text(
                    '${travelData.gender}, ${travelData.age}',
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s9,
                      fontWeight: FontWeight.w400,
                      color: CommonColors.blackColor,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                isTravellerUpdate = true;
                isShowTravellerForm = true;
                _userC.travellerId.value = travelData.id ?? 0;
                _userC.nameControllerTraveller.value.text =
                    travelData.name ?? '-';
                _userC.ageControllerTraveller.value.text =
                    travelData.age.toString();
                _userC.selectedGender.value =
                    travelData.gender?.toLowerCase() ?? '-';
                setState(() {});
                FocusScope.of(context).requestFocus(nameNode);
              },
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
  }
}
