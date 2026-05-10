import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../widgets/loading_animation_modal.dart';
import 'package:flutter_touch_ripple/flutter_touch_ripple.dart';
import '../controller/dashboard_controller.dart';
import '../models/user_profile/state_list_model.dart';

class PersonalizedTreksScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const PersonalizedTreksScreen({
    super.key,
    required this.arguments,
  });

  @override
  State<PersonalizedTreksScreen> createState() =>
      _PersonalizedTreksScreenState();
}

class _PersonalizedTreksScreenState extends State<PersonalizedTreksScreen> {
  final DashboardController _dashboardController =
      Get.find<DashboardController>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _ageFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  String _selectedGender = '';
  String _selectedState = '';
  List<StateListData> filteredStates = [];
  bool _whatsappUpdates = true;

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty &&
      _ageController.text.trim().isNotEmpty &&
      int.tryParse(_ageController.text.trim()) != null &&
      int.parse(_ageController.text.trim()) > 0 &&
      _phoneController.text.trim().length == 10 &&
      RegExp(r'^[0-9]{10}$').hasMatch(_phoneController.text.trim()) &&
      _emailController.text.trim().isNotEmpty &&
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
          .hasMatch(_emailController.text.trim()) &&
      _selectedState.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Initialize filtered states with the state list from controller
    filteredStates = List.from(_dashboardController.stateList);

    // Add focus listeners
    _nameFocusNode.addListener(() {
      setState(() {});
    });
    _ageFocusNode.addListener(() {
      setState(() {});
    });
    _phoneFocusNode.addListener(() {
      setState(() {});
    });
    _emailFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();

    // Remove focus listeners before disposing
    _nameFocusNode.removeListener(() {
      setState(() {});
    });
    _ageFocusNode.removeListener(() {
      setState(() {});
    });
    _phoneFocusNode.removeListener(() {
      setState(() {});
    });
    _emailFocusNode.removeListener(() {
      setState(() {});
    });

    _nameFocusNode.dispose();
    _ageFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);
    return Scaffold(
      backgroundColor: CommonColors.whiteColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: CommonColors.whiteColor,
            elevation: 0,
            pinned: true,
            automaticallyImplyLeading: true,
            // expandedHeight: 0,
            // collapsedHeight: kToolbarHeight,
            centerTitle: false,
            title: Text(
              'Personalized Treks',
              // textScaler: const TextScaler.linear(1.0),
              style: GoogleFonts.poppins(
                color: CommonColors.blackColor,
                fontSize: FontSize.s12,
                fontWeight: FontWeight.w400,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                    color: CommonColors.whiteColor,
                    border: Border.all(
                        color:
                            CommonColors.grey_767676.withValues(alpha: 0.5))),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20, left: 14),
                    child: Text(
                      'Please Provide the following details to help us\ncraft your ideal trek experience',
                      // textScaler: const TextScaler.linear(1.0),
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s9,
                        color: CommonColors.blackColor.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.2.h),
                  // Traveller Details Card
                  SizedBox(
                    width: 100.w,
                    child: Container(
                      // elevation: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.w),
                        boxShadow: [
                          BoxShadow(
                            color:
                                CommonColors.blackColor.withValues(alpha: 0.2),
                            offset: Offset(2, 2),
                            blurRadius: 6,
                            spreadRadius: 2,
                          )
                        ],
                        color: CommonColors.offWhiteColor2,
                      ),
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(5.w),
                      // ),
                      child: Container(
                        width: 100.w,
                        margin: EdgeInsets.only(
                          left: 8.w,
                          right: 8.w,
                          top: 2.8.h,
                          bottom: 2.8.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Traveller Details',
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.alexandria(
                                fontSize: FontSize.s14,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.blackColor,
                              ),
                            ),
                            SizedBox(height: 2.5.h),
                            _buildTextField(
                                _nameController, 'Name', _nameFocusNode),
                            SizedBox(height: 2.5.h),
                            _buildTextField(
                                _ageController, 'Age', _ageFocusNode,
                                keyboardType: TextInputType.number),
                            SizedBox(height: 2.h),
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
                            SizedBox(height: 0.8.h),
                            Row(
                              children: [
                                _buildGenderButton('Male'),
                                SizedBox(width: 5.w),
                                _buildGenderButton('Female'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.2.h),
                  // Contact Details Card
                  SizedBox(
                    width: 100.w,
                    child: Container(
                      // elevation: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.w),
                        boxShadow: [
                          BoxShadow(
                            color:
                                CommonColors.blackColor.withValues(alpha: 0.2),
                            offset: Offset(2, 2),
                            blurRadius: 6,
                            spreadRadius: 2,
                          )
                        ],
                        color: CommonColors.offWhiteColor2,
                      ),
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(5.w),
                      // ),
                      child: Container(
                        width: 100.w,
                        margin: EdgeInsets.only(
                          left: 8.w,
                          right: 8.w,
                          top: 2.8.h,
                          bottom: 2.8.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color:
                                            _phoneController.text.isNotEmpty ||
                                                    _phoneFocusNode.hasFocus
                                                ? Color(0xFF90CAF9)
                                                : Color(0xFF878787)),
                                    borderRadius: BorderRadius.circular(2.w),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      // Country code
                                      Container(
                                        width: 27.w,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 1.2.h),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            right: BorderSide(
                                              color: _phoneController
                                                          .text.isNotEmpty ||
                                                      _phoneFocusNode.hasFocus
                                                  ? Color(0xFF90CAF9)
                                                  : Color(0xFF878787),
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
                                                    const TextScaler.linear(
                                                        1.0),
                                                style: GoogleFonts.poppins(
                                                  fontSize: FontSize.s7,
                                                  color:
                                                      CommonColors.blackColor,
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
                                                  controller: _phoneController,
                                                  focusNode: _phoneFocusNode,
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
                                                  onChanged: (value) {
                                                    setState(() {});
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
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2.w),
                                    child: TouchRipple(
                                      rippleColor: CommonColors.blackColor
                                          .withValues(alpha: 0.1),
                                      onTap: () {
                                        FocusScope.of(context)
                                            .requestFocus(_phoneFocusNode);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(2.w),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.8.h),
                            // Email
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color:
                                            _emailController.text.isNotEmpty ||
                                                    _emailFocusNode.hasFocus
                                                ? Color(0xFF90CAF9)
                                                : Color(0xFF878787)),
                                    borderRadius: BorderRadius.circular(2.w),
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.only(
                                      left: 4.w, top: 0.8.h, bottom: 0.8.h),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Email ID',
                                        textScaler:
                                            const TextScaler.linear(1.0),
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
                                          controller: _emailController,
                                          focusNode: _emailFocusNode,
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
                                          onChanged: (value) {
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2.w),
                                    child: TouchRipple(
                                      rippleColor: CommonColors.blackColor
                                          .withValues(alpha: 0.1),
                                      onTap: () {
                                        FocusScope.of(context)
                                            .requestFocus(_emailFocusNode);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(2.w),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.8.h),
                            // State
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: _selectedState.isNotEmpty
                                        ? Color(0xFF90CAF9)
                                        : Color(0xFF878787)),
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
                                                  const TextScaler.linear(1.0),
                                              style: GoogleFonts.poppins(
                                                fontSize: FontSize.s7,
                                                color: CommonColors.blackColor,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                            SizedBox(height: 0.25.h),
                                            Text(
                                              _selectedState,
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
                                        Icon(Icons.keyboard_arrow_down,
                                            color: Colors.black, size: 6.w),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 3.h),
                            // WhatsApp row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  CommonImages.whatsappIcon,
                                  width: 9.w,
                                  height: 9.w,
                                ),
                                SizedBox(width: 2.5.w),
                                Expanded(
                                  child: Text(
                                    'Share booking details and trek updates via WhatsApp',
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s8,
                                      fontWeight: FontWeight.w300,
                                      color: CommonColors.blackColor
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                                Transform.scale(
                                  scale: 0.8,
                                  child: Switch.adaptive(
                                    activeColor: CommonColors.whiteColor,
                                    activeTrackColor: CommonColors
                                        .completedColor
                                        .withValues(alpha: 0.8),
                                    inactiveTrackColor:
                                        CommonColors.shimmerBaseColor,
                                    inactiveThumbColor: CommonColors.blackColor,
                                    value: _whatsappUpdates,
                                    onChanged: (value) {
                                      setState(() {
                                        _whatsappUpdates = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Submit Button
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 6.75.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7.5.w),
                        gradient: _isFormValid
                            ? CommonColors.radioBtnGradient
                            : CommonColors.disableBtnGradient,
                      ),
                      child: TextButton(
                        onPressed: _isFormValid
                            ? () async {
                                try {
                                  // Show loading animation
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return PopScope(
                                        canPop: false,
                                        child: const LoadingAnimationModal(),
                                      );
                                    },
                                  );

                                  // Simulate API call delay
                                  await Future.delayed(
                                      const Duration(seconds: 2));

                                  // The LoadingAnimationModal will automatically show success
                                  // and navigate after its internal animation completes
                                  await Future.delayed(
                                      const Duration(seconds: 1));

                                  // Close loading modal and navigate
                                  if (context.mounted) {
                                    Get.toNamed('/thank-you');

                                    // Redirect to dashboard after 10 seconds
                                    Future.delayed(const Duration(seconds: 5),
                                        () {
                                      if (context.mounted) {
                                        Get.offAllNamed(
                                            '/dashboard'); // Redirect to dashboard
                                      }
                                    });
                                  }
                                } catch (e) {
                                  // Close loading modal if open
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }

                                  // Show error dialog
                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            'Error',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          content: Text(
                                            'Something went wrong. Please try again.',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text(
                                                'OK',
                                                style: GoogleFonts.poppins(
                                                  color: CommonColors
                                                      .trek_route_color,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                }
                              }
                            : null,
                        child: Text(
                          'Submit',
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    FocusNode focusNode, {
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            maxLength: maxLength,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: FontSize.s11,
                fontWeight: FontWeight.w300,
                color: CommonColors.blackColor.withValues(alpha: 0.6),
              ),
              counterText: '',
              contentPadding:
                  EdgeInsets.only(left: 5.25.w, top: 1.6.h, bottom: 1.6.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.w),
                borderSide: BorderSide(
                  color: controller.text.isNotEmpty || focusNode.hasFocus
                      ? Color(0xFF90CAF9)
                      : Color(0xFF878787),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.w),
                borderSide: BorderSide(
                  color: controller.text.isNotEmpty || focusNode.hasFocus
                      ? Color(0xFF90CAF9)
                      : Color(0xFF878787),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.w),
                borderSide: BorderSide(color: Color(0xFF90CAF9)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: GoogleFonts.poppins(
              fontSize: FontSize.s11,
              color: CommonColors.blackColor,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2.w),
              child: TouchRipple(
                rippleColor: CommonColors.blackColor.withValues(alpha: 0.1),
                onTap: () {
                  FocusScope.of(context).requestFocus(focusNode);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String gender) {
    final bool isSelected = _selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
        },
        child: Container(
          height: 5.6.h,
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedGender == gender
                  ? CommonColors.blueColor
                  : Color(0xFF878787),
            ),
            borderRadius: BorderRadius.circular(2.w),
            color: Colors.white,
          ),
          child: Container(
            margin: EdgeInsets.only(
                left: 5.w, right: 6.25.w, top: 1.5.h, bottom: 1.5.h),
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
                  width: 4.5.w,
                  height: 4.5.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected ? CommonColors.radioBtnGradient : null,
                    border: isSelected
                        ? null
                        : Border.all(
                            color: CommonColors.greyColor585858,
                            width: 0.5.w,
                          ),
                    color: Colors.white,
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 1.5.w,
                            height: 1.5.w,
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

  Future<void> _showStateSelectionBottomSheet() async {
    TextEditingController searchController = TextEditingController();

    setState(() {
      filteredStates = List.from(_dashboardController.stateList);
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
                                  filteredStates = _dashboardController
                                      .stateList
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
        filteredStates = List.from(_dashboardController.stateList);
      });
    });
  }
}
