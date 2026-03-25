import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import '../controller/user_controller.dart';
import '../controller/trek_controller.dart';
import '../models/treaks/booking_history_modal.dart';
import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';
import '../utils/common_btn.dart';

class IssueReportScreen extends StatefulWidget {
  const IssueReportScreen({super.key});

  @override
  State<IssueReportScreen> createState() => _IssueReportScreenState();
}

class _IssueReportScreenState extends State<IssueReportScreen> {
  final UserController _userC = Get.find<UserController>();
  final TrekController _trekC = Get.find<TrekController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController otherCategoryController = TextEditingController();
  final TextEditingController otherIssueTypeController =
      TextEditingController();

  String? selectedIssueType;
  String? selectedIssueCategory;

  // Get booking ID from arguments if passed, or use a default/current booking
  int? bookingId;

  final List<String> issueTypes = [
    'accommodation_issue',
    'trek_services_issue',
    'transportation_issue',
    'other',
  ];

  final List<String> issueCategories = [
    'drunken_driving',
    'rash_unsafe_driving',
    'sexual_harassment',
    'verbal_abuse_assault',
    'others',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _getBookingId();
  }

  void _getBookingId() {
    final arguments = Get.arguments;

    if (arguments != null) {
      // Check if it's a BookingHistoryData object passed directly
      if (arguments is BookingHistoryData) {
        // Get booking ID from first traveler
        if (arguments.travelers?.isNotEmpty == true) {
          bookingId = arguments.travelers!.first.bookingId;
        }
      }
      // Check if it's a Map with booking data
      else if (arguments is Map<String, dynamic>) {
        // Direct booking ID
        if (arguments['bookingId'] != null) {
          bookingId = arguments['bookingId'] as int?;
        }
        // Booking data object
        else if (arguments['booking'] != null) {
          final booking = arguments['booking'];
          if (booking is BookingHistoryData) {
            if (booking.travelers?.isNotEmpty == true) {
              bookingId = booking.travelers!.first.bookingId;
            }
          }
        }
      }
    }

  }

  void _loadUserProfile() async {
    await _userC.getUserProfile();
    _populateUserData();
  }

  void _populateUserData() {
    final customer = _userC.userProfileData.value.customer;
    if (customer != null) {
      setState(() {
        nameController.text = customer.name ?? '';
        emailController.text = customer.email ?? '';
        phoneController.text = customer.phone?.replaceFirst('+91', '') ?? '';
      });
    }
  }

  // Get priority and SLA based on issue type
  Map<String, String> _getPriorityAndSLA(String issueType) {
    switch (issueType) {
      case 'accommodation_issue':
        return {'priority': 'low', 'sla': '168h'};
      case 'trek_services_issue':
        return {'priority': 'high', 'sla': '72h'};
      case 'transportation_issue':
        return {'priority': 'medium', 'sla': '96h'};
      case 'other':
      default:
        return {'priority': 'low', 'sla': '168h'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: Obx(
            () => Scaffold(
              backgroundColor: CommonColors.whiteColor,
              appBar: AppBar(
                backgroundColor: CommonColors.appBarBg,
                elevation: 0,
                scrolledUnderElevation: 0,
                automaticallyImplyLeading: true,
                centerTitle: false,
                title: Text(
                  'Dispute Report',
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s14,
                    fontWeight: FontWeight.w600,
                    color: CommonColors.blackColor,
                  ),
                ),
              ),
              body: _userC.isLoading.value
                  ? _buildShimmerLoader()
                  : _trekC.isLoading.value
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: CommonColors.lightBlueColor2,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Submitting your dispute...',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s11,
                              color: CommonColors.greyTextColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildReportCard(),
                          SizedBox(height: 3.h),
                          _buildFormFields(),
                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
              bottomNavigationBar: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: SafeArea(child: _buildSubmitButton()),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportCard() {
    return Container(
      padding: EdgeInsets.fromLTRB(6.w, 4.w, 6.w, 4.w),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.15),
            offset: Offset(2, 2),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Raise a Dispute for Your Trek Experience',
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w600,
                        color: CommonColors.blackColor,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Submit your concerns and disputes for proper resolution',
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s9,
                        color: CommonColors.greyTextColor2,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              Icon(
                Icons.report_problem_outlined,
                size: 12.w,
                color: CommonColors.appRedColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer for Report Card
          Container(
            width: double.infinity,
            height: 15.h,
            decoration: BoxDecoration(
              color: CommonColors.greyColorEBEBEB,
              borderRadius: BorderRadius.circular(3.w),
            ),
          ).withShimmerAi(loading: true),
          SizedBox(height: 3.h),

          // Shimmer for Form Fields
          _buildShimmerField('Name'),
          SizedBox(height: 2.h),
          _buildShimmerPhoneField(),
          SizedBox(height: 2.h),
          _buildShimmerField('Email'),
          SizedBox(height: 2.h),
          _buildShimmerField('Dispute Type'),
          SizedBox(height: 2.h),
          _buildShimmerField('Dispute Category'),
          SizedBox(height: 2.h),
          _buildShimmerDescriptionField(),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildShimmerField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20.w,
          height: 2.h,
          decoration: BoxDecoration(
            color: CommonColors.greyColorEBEBEB,
            borderRadius: BorderRadius.circular(4),
          ),
        ).withShimmerAi(loading: true),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          height: 6.h,
          decoration: BoxDecoration(
            color: CommonColors.greyColorEBEBEB,
            borderRadius: BorderRadius.circular(2.w),
          ),
        ).withShimmerAi(loading: true),
      ],
    );
  }

  Widget _buildShimmerPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 25.w,
          height: 2.h,
          decoration: BoxDecoration(
            color: CommonColors.greyColorEBEBEB,
            borderRadius: BorderRadius.circular(4),
          ),
        ).withShimmerAi(loading: true),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(color: CommonColors.greyDFDFDF, width: 1),
          ),
          child: Row(
            children: [
              // Country code shimmer
              Container(
                width: 27.w,
                padding: EdgeInsets.symmetric(vertical: 1.2.h),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: CommonColors.greyDFDFDF, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 18.w,
                      height: 1.5.h,
                      decoration: BoxDecoration(
                        color: CommonColors.greyColorEBEBEB,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).withShimmerAi(loading: true),
                    SizedBox(height: 0.4.h),
                    Container(
                      width: 15.w,
                      height: 1.8.h,
                      decoration: BoxDecoration(
                        color: CommonColors.greyColorEBEBEB,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).withShimmerAi(loading: true),
                  ],
                ),
              ),
              // Phone number shimmer
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 25.w,
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).withShimmerAi(loading: true),
                      SizedBox(height: 0.5.h),
                      Container(
                        width: double.infinity,
                        height: 2.h,
                        decoration: BoxDecoration(
                          color: CommonColors.greyColorEBEBEB,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).withShimmerAi(loading: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 45.w,
              height: 2.h,
              decoration: BoxDecoration(
                color: CommonColors.greyColorEBEBEB,
                borderRadius: BorderRadius.circular(4),
              ),
            ).withShimmerAi(loading: true),
            Spacer(),
            Container(
              width: 15.w,
              height: 1.5.h,
              decoration: BoxDecoration(
                color: CommonColors.greyColorEBEBEB,
                borderRadius: BorderRadius.circular(4),
              ),
            ).withShimmerAi(loading: true),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          height: 15.h,
          decoration: BoxDecoration(
            color: CommonColors.greyColorEBEBEB,
            borderRadius: BorderRadius.circular(2.w),
          ),
        ).withShimmerAi(loading: true),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField(
          label: 'Name',
          controller: nameController,
          hintText: 'Enter Name',
          isRequired: true,
          isEnabled:
              _userC.userProfileData.value.customer?.name == null ||
              _userC.userProfileData.value.customer?.name?.isEmpty == true,
        ),
        SizedBox(height: 2.h),
        _buildPhoneNumberField(),
        SizedBox(height: 2.h),
        _buildInputField(
          label: 'Email',
          controller: emailController,
          hintText: 'Enter Email',
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
          isEnabled:
              _userC.userProfileData.value.customer?.email == null ||
              _userC.userProfileData.value.customer?.email?.isEmpty == true,
        ),
        SizedBox(height: 2.h),
        _buildDropdownField(
          label: 'Dispute Type',
          value: selectedIssueType,
          items: issueTypes,
          onChanged: (value) {
            setState(() {
              selectedIssueType = value;
            });
          },
          isRequired: true,
        ),
        if (selectedIssueType == 'other') ...[
          SizedBox(height: 2.h),
          _buildInputField(
            label: 'Please specify other dispute type',
            controller: otherIssueTypeController,
            hintText: 'Enter specific dispute type details',
            isRequired: true,
          ),
        ],
        SizedBox(height: 2.h),
        _buildDropdownField(
          label: 'Dispute Category (optional)',
          value: selectedIssueCategory,
          items: issueCategories,
          onChanged: (value) {
            setState(() {
              selectedIssueCategory = value;
            });
          },
          isRequired: false,
        ),
        if (selectedIssueCategory == 'others') ...[
          SizedBox(height: 2.h),
          _buildInputField(
            label: 'Please specify other category',
            controller: otherCategoryController,
            hintText: 'Enter specific category details',
            isRequired: true,
          ),
        ],
        SizedBox(height: 2.h),
        _buildDescriptionField(),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool isRequired = false,
    TextInputType? keyboardType,
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: FontSize.s11,
            fontWeight: FontWeight.w500,
            color: CommonColors.blackColor,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: isEnabled
                ? CommonColors.whiteColor
                : CommonColors.greyColorEBEBEB,
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(color: CommonColors.greyDFDFDF, width: 1),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: isEnabled,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                fontSize: FontSize.s9,
                color: CommonColors.greyTextColor,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 3.w,
                vertical: 2.h,
              ),
            ),
            style: GoogleFonts.poppins(
              fontSize: FontSize.s10,
              color: isEnabled
                  ? CommonColors.blackColor
                  : CommonColors.greyTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    bool isPhoneAvailable =
        _userC.userProfileData.value.customer?.phone != null &&
        _userC.userProfileData.value.customer?.phone?.isNotEmpty == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: GoogleFonts.poppins(
            fontSize: FontSize.s11,
            fontWeight: FontWeight.w500,
            color: CommonColors.blackColor,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: isPhoneAvailable
                ? CommonColors.greyColorEBEBEB
                : CommonColors.whiteColor,
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(color: CommonColors.greyDFDFDF, width: 1),
          ),
          child: Row(
            children: [
              // Country code
              Container(
                width: 27.w,
                padding: EdgeInsets.symmetric(vertical: 1.2.h),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: CommonColors.greyDFDFDF, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Country Code',
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s7,
                        color: CommonColors.blackColor,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 0.4.h),
                    Text(
                      '+91(IND)',
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
                    bottom: 0.8.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone Number',
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s7,
                          color: CommonColors.blackColor,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      TextFormField(
                        enabled: !isPhoneAvailable,
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s10,
                          color: isPhoneAvailable
                              ? CommonColors.greyTextColor
                              : CommonColors.blackColor,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          isDense: true,
                          hintText: isPhoneAvailable
                              ? ''
                              : 'Enter Phone Number',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: FontSize.s9,
                            color: CommonColors.greyTextColor,
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
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: FontSize.s11,
            fontWeight: FontWeight.w500,
            color: CommonColors.blackColor,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: CommonColors.whiteColor,
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(color: CommonColors.greyDFDFDF, width: 1),
            boxShadow: [
              BoxShadow(
                color: CommonColors.blackColor.withValues(alpha: 0.05),
                offset: Offset(0, 1),
                blurRadius: 3,
                spreadRadius: 0,
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                'Select ${label.trim()}',
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s10,
                  color: CommonColors.greyTextColor,
                ),
              ),
              value: value,
              onChanged: onChanged,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 5.w,
                color: CommonColors.greyTextColor,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    child: Text(
                      _formatDropdownText(item),
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s10,
                        color: CommonColors.blackColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
              dropdownColor: CommonColors.whiteColor,
              borderRadius: BorderRadius.circular(2.w),
              elevation: 8,
              menuMaxHeight: 30.h,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDropdownText(String text) {
    return text
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '',
        )
        .join(' ');
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Description (optional, max 2000 chars)',
              style: GoogleFonts.poppins(
                fontSize: FontSize.s11,
                fontWeight: FontWeight.w500,
                color: CommonColors.blackColor,
              ),
            ),
            Spacer(),
            Text(
              '${descriptionController.text.length}/2000',
              style: GoogleFonts.poppins(
                fontSize: FontSize.s8,
                color: descriptionController.text.length > 2000
                    ? CommonColors.appRedColor
                    : CommonColors.greyTextColor2,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(2.w),
          height: 15.h,
          decoration: BoxDecoration(
            color: CommonColors.whiteColor,
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(
              color: descriptionController.text.length > 2000
                  ? CommonColors.appRedColor
                  : CommonColors.greyDFDFDF,
              width: 1,
            ),
          ),
          child: TextFormField(
            onChanged: (value) {
              setState(() {});
            },
            controller: descriptionController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: 'Describe your dispute in detail',
              hintStyle: GoogleFonts.poppins(
                fontSize: FontSize.s9,
                color: CommonColors.greyTextColor,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(2.w),
            ),
            style: GoogleFonts.poppins(
              fontSize: FontSize.s10,
              color: CommonColors.blackColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    bool isFormValid =
        nameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        selectedIssueType != null &&
        descriptionController.text.length <= 2000 &&
        (selectedIssueCategory != 'others' ||
            otherCategoryController.text.isNotEmpty) &&
        (selectedIssueType != 'other' ||
            otherIssueTypeController.text.isNotEmpty);

    return CommonButton(
      text: 'Submit Dispute',
      onPressed: () {
        if (isFormValid) {
          _submitReport();
        }
      },
      isDisabled: !isFormValid,
      gradient: isFormValid
          ? CommonColors.filterGradient
          : CommonColors.disableBtnGradient,
      textColor: CommonColors.whiteColor,
      fontSize: FontSize.s11,
      fontWeight: FontWeight.w600,
      borderRadius: 7.w,
      height: 6.h,
    );
  }

  void _submitReport() async {
    if (descriptionController.text.length > 2000) {
      Get.snackbar(
        'Error',
        'Description cannot exceed 2000 characters',
        backgroundColor: CommonColors.appRedColor,
        colorText: CommonColors.whiteColor,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (bookingId == null) {
      Get.snackbar(
        'Error',
        'Booking ID not found. Please try again.',
        backgroundColor: CommonColors.appRedColor,
        colorText: CommonColors.whiteColor,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Prepare phone number with +91 prefix if not already present
    String phoneNumber = phoneController.text;
    if (!phoneNumber.startsWith('+91')) {
      phoneNumber = '+91$phoneNumber';
    }

    // Determine issue type - use "other" text if "other" is selected
    String finalIssueType = selectedIssueType!;
    if (selectedIssueType == 'other' &&
        otherIssueTypeController.text.isNotEmpty) {
      finalIssueType = otherIssueTypeController.text;
    }

    // Determine issue category - use "others" text if "others" is selected
    String? finalIssueCategory = selectedIssueCategory;
    if (selectedIssueCategory == 'others' &&
        otherCategoryController.text.isNotEmpty) {
      finalIssueCategory = otherCategoryController.text;
    }

    // Get priority and SLA based on issue type
    final priorityAndSLA = _getPriorityAndSLA(selectedIssueType!);
    final priority = priorityAndSLA['priority']!;
    final sla = priorityAndSLA['sla']!;

    // Submit the issue report using TrekController
    final success = await _trekC.submitIssueReport(
      name: nameController.text,
      phoneNumber: phoneNumber,
      email: emailController.text,
      bookingId: bookingId!,
      issueType: finalIssueType,
      issueCategory: finalIssueCategory,
      description: descriptionController.text.isNotEmpty
          ? descriptionController.text
          : null,
      priority: priority,
      sla: sla,
    );

    if (success) {
      // Clear form after successful submission
      nameController.clear();
      phoneController.clear();
      emailController.clear();
      descriptionController.clear();
      otherCategoryController.clear();
      otherIssueTypeController.clear();
      setState(() {
        selectedIssueType = null;
        selectedIssueCategory = null;
      });

    }
    // Error handling is done in the TrekController
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    descriptionController.dispose();
    otherCategoryController.dispose();
    otherIssueTypeController.dispose();
    super.dispose();
  }
}
