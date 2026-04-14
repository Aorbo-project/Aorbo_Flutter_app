import 'dart:developer';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/models/user_profile/user_profile_modal.dart';
import 'package:arobo_app/models/user_profile/state_list_model.dart';
import 'package:arobo_app/utils/common_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_colors.dart';
import '../utils/common_images.dart';
import '../utils/screen_constants.dart';

class _C {
  static const bg = Color(0xFFF5F8FF);
  static const cardBg = Color(0xFFFFFFFF);
  static const ink = Color(0xFF111827);
  static const inkMid = Color(0xFF6B7280);
  static const inkLight = Color(0xFF9CA3AF);
  static const teal = Color(0xFF0F7B6C);
  static const tealLight = Color(0xFF1AA090);
  static const tealSoft = Color(0xFFE6F5F3);
  static const fieldBg = Color(0xFFF9FAFB);
  static const fieldBorder = Color(0xFFE5E7EB);
  static const shadow = Color(0x0D000000);
  static const iconBadgeBg = Color(0xFF111827);
}

class TravellerInfoScreen extends StatefulWidget {
  const TravellerInfoScreen({super.key});

  @override
  State<TravellerInfoScreen> createState() => _TravellerInfoScreenState();
}

class _NC {
  static const ink = Color(0xFF0F172A);
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
  bool isShowContactUpdate = false;

  int? _expandedTravellerIndex;
  bool _isAddTravellerExpanded = false;

  final UserController _userC = Get.find<UserController>();
  final DashboardController _dashboardC = Get.find<DashboardController>();

  @override
  void initState() {
    super.initState();
    filteredStates = List.from(_dashboardC.stateList);

    _nameController.addListener(_onFieldChanged);
    _dateController.addListener(_onFieldChanged);
    _stateController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStateData();
    });
  }

  void _initializeStateData() {
    if (_userC.userProfileData.value.customer?.state?.id != null) {
      _userC.stateUpdateId.value =
          _userC.userProfileData.value.customer!.state?.id ?? 0;
      _selectedState = _userC.userProfileData.value.customer?.state?.name ?? '';
    } else if (filteredStates.isNotEmpty) {
      _userC.stateUpdateId.value = filteredStates.first.id ?? 0;
      _selectedState = filteredStates.first.name ?? '';
    }
  }

  void _onFieldChanged() => setState(() {});

  void _resetTravellerForm() {
    _userC.travellerId.value = 0;
    _userC.nameControllerTraveller.value.clear();
    _userC.ageControllerTraveller.value.clear();
    _userC.selectedGender.value = '';
    FocusScope.of(context).unfocus();
  }

  void _openTravellerEditor(Travelers traveler, int index) {
    _userC.travellerId.value = traveler.id ?? 0;
    _userC.nameControllerTraveller.value.text = traveler.name ?? '';
    _userC.ageControllerTraveller.value.text = traveler.age?.toString() ?? '';
    _userC.selectedGender.value = (traveler.gender ?? '').toLowerCase();

    setState(() {
      _expandedTravellerIndex = index;
      _isAddTravellerExpanded = false;
    });

    FocusScope.of(context).requestFocus(nameNode);
  }

  void _closeTravellerEditor() {
    _resetTravellerForm();
    setState(() {
      _expandedTravellerIndex = null;
    });
  }

  void _openAddTravellerForm() {
    _resetTravellerForm();
    setState(() {
      _expandedTravellerIndex = null;
      _isAddTravellerExpanded = true;
    });
    FocusScope.of(context).requestFocus(nameNode);
  }

  void _closeAddTravellerForm() {
    _resetTravellerForm();
    setState(() {
      _isAddTravellerExpanded = false;
    });
  }

  Future<void> _submitTravellerUpdate() async {
    await _userC.updateTraveler();
    if (!mounted) return;
    _resetTravellerForm();
    setState(() {
      _expandedTravellerIndex = null;
    });
  }

  Future<void> _submitNewTraveller() async {
    await _userC.addTraveler();
    if (!mounted) return;
    log(
      'message : ${_userC.nameControllerTraveller.value.text},'
      '${_userC.ageControllerTraveller.value.text}',
    );
    _resetTravellerForm();
    setState(() {
      _isAddTravellerExpanded = false;
    });
  }

  List<Widget> _buildTravellerFormFields() {
    return [
      _buildFieldLabel('Full Name'),
      SizedBox(height: 0.6.h),
      _buildTextField(
        controller: _userC.nameControllerTraveller.value,
        hint: 'Name',
        focusNode: nameNode,
      ),
      SizedBox(height: 1.7.h),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Gender'),
                SizedBox(height: 0.6.h),
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
          SizedBox(width: 3.w),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Age'),
                SizedBox(height: 0.6.h),
                _buildTextField(
                  controller: _userC.ageControllerTraveller.value,
                  hint: 'Age',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    nameNode.dispose();
    _nameController.dispose();
    _dateController.dispose();
    _stateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userC.userProfileData.listen((userData) {
      if (userData.customer != null) _initializeStateData();
    });

    final travelers = _userC.userProfileData.value.customer?.travelers ?? [];

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.bg,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: _C.ink),
        title: Text(
          'Traveller Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s15,
            fontWeight: FontWeight.w700,
            color: _NC.ink,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 5.h,
            //color: CommonColors.lightBlueColor3.withOpacity(0.2),
          ),
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),

                  _buildCard(
                    icon: CommonImages.phone,
                    title: 'Contact Information',
                    trailing: !isShowContactUpdate
                        ? TextButton(
                            onPressed: () {
                              setState(() {
                                isShowContactUpdate = true;
                                _userC.phoneNumberController.value.text =
                                    (_userC
                                                .userProfileData
                                                .value
                                                .customer
                                                ?.phone ??
                                            '-')
                                        .replaceFirst('+91', '');
                                _userC.emailController.value.text =
                                    _userC
                                        .userProfileData
                                        .value
                                        .customer
                                        ?.email ??
                                    '-';
                                if (_userC
                                        .userProfileData
                                        .value
                                        .customer
                                        ?.state
                                        ?.id !=
                                    null) {
                                  _userC.stateUpdateId.value = _userC
                                      .userProfileData
                                      .value
                                      .customer!
                                      .state!
                                      .id!;
                                  _selectedState =
                                      _userC
                                          .userProfileData
                                          .value
                                          .customer
                                          ?.state
                                          ?.name ??
                                      '-';
                                }
                              });
                            },
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s10,
                                fontWeight: FontWeight.w600,
                                color: _C.teal,
                              ),
                            ),
                          )
                        : IconButton(
                            onPressed: () =>
                                setState(() => isShowContactUpdate = false),
                            icon: Icon(
                              Icons.close_rounded,
                              size: 5.w,
                              color: _C.inkMid,
                            ),
                          ),
                    children: [
                      Text(
                        'Trip ticket details will be provided to',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s9,
                          color: _C.inkLight,
                        ),
                      ),
                      SizedBox(height: 1.5.h),
                      _buildReadRow(
                        icon: CommonImages.phone,
                        value:
                            _userC.userProfileData.value.customer?.phone ?? '-',
                      ),
                      SizedBox(height: 0.8.h),
                      _buildReadRow(
                        icon: CommonImages.email,
                        value:
                            _userC.userProfileData.value.customer?.email ?? '-',
                      ),
                      SizedBox(height: 0.8.h),
                      _buildReadRow(
                        icon: CommonImages.location4,
                        value: () {
                          final idx = _dashboardC.stateList.indexWhere(
                            (e) =>
                                e.id ==
                                _userC
                                    .userProfileData
                                    .value
                                    .customer
                                    ?.state
                                    ?.id,
                          );
                          return idx >= 0
                              ? _dashboardC.stateList[idx].name ?? '-'
                              : '-';
                        }(),
                      ),
                      if (isShowContactUpdate) ...[
                        SizedBox(height: 2.h),
                        Divider(color: _C.fieldBorder, thickness: 1, height: 1),
                        SizedBox(height: 2.h),
                        _buildFieldLabel('Phone Number'),
                        SizedBox(height: 0.6.h),
                        _buildPhoneField(),
                        SizedBox(height: 1.8.h),
                        _buildFieldLabel('Email ID'),
                        SizedBox(height: 0.6.h),
                        _buildTextField(
                          controller: _userC.emailController.value,
                          hint: 'e.g. john@example.com',
                          keyboardType: TextInputType.emailAddress,
                          suffixIcon: Icon(
                            Icons.email_outlined,
                            size: 4.5.w,
                            color: _C.inkLight,
                          ),
                        ),
                        SizedBox(height: 1.8.h),
                        _buildFieldLabel('State of Residence'),
                        SizedBox(height: 0.6.h),
                        _buildStateSelector(),
                      ],
                    ],
                  ),

                  if (isShowContactUpdate) ...[
                    SizedBox(height: 2.h),
                    CommonButton(
                      height: 48,
                      gradient: CommonColors.filterGradient,
                      text: 'Save',
                      textColor: CommonColors.whiteColor,
                      onPressed: () async {
                        await _userC.updateUserProfile();
                        setState(() => isShowContactUpdate = false);
                      },
                    ),
                  ],

                  SizedBox(height: 2.h),

                  _buildCard(
                    icon: CommonImages.account,
                    title: 'Traveller Details',
                    children: [
                      if (travelers.isEmpty)
                        _buildEmptyTravellerState()
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: travelers.length,
                          separatorBuilder: (_, __) => SizedBox(height: 1.h),
                          itemBuilder: (context, index) {
                            return _buildExistingTravellerItem(
                              travelData: travelers[index],
                              index: index,
                            );
                          },
                        ),
                    ],
                  ),

                  SizedBox(height: 1.8.h),

                  _buildAddTravellerContainer(),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String icon,
    required String title,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9.w,
                height: 9.w,
                decoration: BoxDecoration(
                  color: _C.iconBadgeBg,
                  borderRadius: BorderRadius.circular(2.5.w),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    icon,
                    width: 4.5.w,
                    height: 4.5.w,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  title,
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s10,
                    fontWeight: FontWeight.w600,
                    color: _C.ink,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: 2.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReadRow({required String icon, required String value}) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 5.w,
          height: 5.w,
          colorFilter: const ColorFilter.mode(_C.inkMid, BlendMode.srcIn),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            value,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s10,
              fontWeight: FontWeight.w500,
              color: _C.ink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      textScaler: const TextScaler.linear(1.0),
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: FontSize.s9,
        fontWeight: FontWeight.w500,
        color: _C.inkMid,
      ),
    );
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
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s10,
          color: _C.ink,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s10,
            color: _C.inkLight,
          ),
          counterText: '',
          isDense: true,
          filled: true,
          fillColor: _C.fieldBg,
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.4.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.w),
            borderSide: const BorderSide(color: _C.fieldBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.w),
            borderSide: const BorderSide(color: _C.fieldBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.w),
            borderSide: const BorderSide(color: _C.teal, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.w),
            borderSide: const BorderSide(color: _C.fieldBorder),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: _C.fieldBg,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: _C.fieldBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 27.w,
            padding: EdgeInsets.symmetric(vertical: 1.2.h),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: _C.fieldBorder)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Country Code',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s7,
                    color: _C.inkLight,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  '+91(IND)',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s10,
                    fontWeight: FontWeight.w500,
                    color: _C.ink,
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
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s7,
                      color: _C.inkLight,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(1.0)),
                    child: TextField(
                      enabled: false,
                      controller: _userC.phoneNumberController.value,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s10,
                        color: _C.ink,
                      ),
                      decoration: const InputDecoration(
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
    );
  }

  Widget _buildStateSelector() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _C.fieldBg,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: _C.fieldBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showStateSelectionBottomSheet,
          borderRadius: BorderRadius.circular(2.w),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'State of Residence',
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s7,
                        color: _C.inkLight,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 0.25.h),
                    Text(
                      _selectedState,
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s10,
                        fontWeight: FontWeight.w400,
                        color: _C.ink,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.keyboard_arrow_down, color: _C.inkMid, size: 6.w),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton(String gender) {
    final bool isSelected =
        _userC.selectedGender.value.toLowerCase() == gender.toLowerCase();

    return Expanded(
      child: GestureDetector(
        onTap: () =>
            setState(() => _userC.selectedGender.value = gender.toLowerCase()),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 5.5.h,
          decoration: BoxDecoration(
            color: isSelected ? _C.teal : _C.fieldBg,
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(
              color: isSelected ? _C.teal : _C.fieldBorder,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              gender,
              textScaler: const TextScaler.linear(1.0),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : _C.inkMid,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTravellerState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _C.fieldBg,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: _C.fieldBorder),
      ),
      child: Text(
        'No travellers added yet. Use the add traveller section below.',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s10,
          color: _C.inkMid,
        ),
      ),
    );
  }

  Widget _buildExistingTravellerItem({
    required Travelers travelData,
    required int index,
  }) {
    final isExpanded = _expandedTravellerIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: _C.fieldBg,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: isExpanded ? _C.teal.withOpacity(0.25) : _C.fieldBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 9.w,
                height: 9.w,
                decoration: const BoxDecoration(
                  color: _C.tealSoft,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (travelData.name?.isNotEmpty == true
                            ? travelData.name!
                            : '?')[0]
                        .toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s12,
                      fontWeight: FontWeight.w700,
                      color: _C.teal,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      travelData.name ?? '-',
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s10,
                        fontWeight: FontWeight.w600,
                        color: _C.ink,
                      ),
                    ),
                    Text(
                      '${travelData.gender ?? '-'}, Age ${travelData.age ?? '-'}',
                      textScaler: const TextScaler.linear(1.0),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s9,
                        color: _C.inkMid,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  if (isExpanded) {
                    _closeTravellerEditor();
                  } else {
                    _openTravellerEditor(travelData, index);
                  }
                },
                child: Text(
                  isExpanded ? 'Cancel' : 'Edit',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s9,
                    fontWeight: FontWeight.w600,
                    color: isExpanded ? _C.inkMid : _C.teal,
                  ),
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            SizedBox(height: 1.5.h),
            Divider(color: _C.fieldBorder, thickness: 1, height: 1),
            SizedBox(height: 1.8.h),
            ..._buildTravellerFormFields(),
            SizedBox(height: 2.h),
            CommonButton(
              height: 48,
              gradient: CommonColors.filterGradient,
              text: 'Update Traveller',
              textColor: CommonColors.whiteColor,
              onPressed: _submitTravellerUpdate,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddTravellerContainer() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: const [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
        border: _isAddTravellerExpanded
            ? Border.all(color: _C.teal.withOpacity(0.2))
            : null,
      ),
      child: InkWell(
        onTap: _isAddTravellerExpanded ? null : _openAddTravellerForm,
        borderRadius: BorderRadius.circular(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 9.w,
                  height: 9.w,
                  decoration: BoxDecoration(
                    color: _C.iconBadgeBg,
                    borderRadius: BorderRadius.circular(2.5.w),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      CommonImages.adduser,
                      width: 4.5.w,
                      height: 4.5.w,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Add Traveller',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.w600,
                      color: _C.ink,
                    ),
                  ),
                ),
                if (_isAddTravellerExpanded)
                  IconButton(
                    onPressed: _closeAddTravellerForm,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 5.w,
                      color: _C.inkMid,
                    ),
                  )
                else
                  Icon(Icons.add_rounded, size: 5.w, color: _C.teal),
              ],
            ),
            if (!_isAddTravellerExpanded) ...[
              SizedBox(height: 0.8.h),
              Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: Text(
                  'Tap to add a new traveller profile.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s9,
                    color: _C.inkMid,
                  ),
                ),
              ),
            ],
            if (_isAddTravellerExpanded) ...[
              SizedBox(height: 2.h),
              Divider(color: _C.fieldBorder, thickness: 1, height: 1),
              SizedBox(height: 2.h),
              ..._buildTravellerFormFields(),
              SizedBox(height: 2.h),
              CommonButton(
                height: 48,
                gradient: CommonColors.filterGradient,
                text: 'Add Traveller',
                textColor: CommonColors.whiteColor,
                onPressed: _submitNewTraveller,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showStateSelectionBottomSheet() async {
    final searchController = TextEditingController();
    setState(() => filteredStates = List.from(_dashboardC.stateList));

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
                    Container(
                      width: 10.w,
                      height: 0.5.h,
                      margin: EdgeInsets.only(bottom: 1.5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(1.w),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select state of residence',
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s14,
                            fontWeight: FontWeight.w600,
                            color: _C.ink,
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
                        color: _C.fieldBg,
                        borderRadius: BorderRadius.circular(3.w),
                        border: Border.all(color: _C.fieldBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: _C.inkLight, size: 5.5.w),
                          SizedBox(width: 2.5.w),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Search State',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: FontSize.s10,
                                  color: _C.inkLight,
                                ),
                              ),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s10,
                                color: _C.ink,
                              ),
                              onChanged: (value) {
                                setModalState(() {
                                  filteredStates = _dashboardC.stateList
                                      .where(
                                        (s) =>
                                            s.name?.toLowerCase().contains(
                                              value.toLowerCase(),
                                            ) ??
                                            false,
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
                          final isSelected =
                              filteredStates[index].id ==
                              _userC.stateUpdateId.value;
                          return ListTile(
                            title: Text(
                              filteredStates[index].name ?? '',
                              textScaler: const TextScaler.linear(1.0),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s10,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected ? _C.teal : _C.ink,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_rounded,
                                    color: _C.teal,
                                    size: 5.w,
                                  )
                                : null,
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
      setState(() => filteredStates = List.from(_dashboardC.stateList));
    });
  }
}
