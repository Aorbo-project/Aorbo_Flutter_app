import 'dart:developer';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/models/user_profile/state_list_model.dart';
import 'package:arobo_app/utils/common_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../freezed_models/profile/user_profile_model.dart';
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
  static const danger = Color(0xFFEF4444);
}

class _NC {
  static const ink = Color(0xFF0F172A);
}

const _kAnimDuration = Duration(milliseconds: 280);
const _kAnimCurve = Curves.easeOutCubic;

class TravellerInfoScreen extends StatefulWidget {
  const TravellerInfoScreen({super.key});

  @override
  State<TravellerInfoScreen> createState() => _TravellerInfoScreenState();
}

class _TravellerInfoScreenState extends State<TravellerInfoScreen>
    with TickerProviderStateMixin {
  final FocusNode nameNode = FocusNode();

  String _selectedState = '';
  List<StateListData> filteredStates = [];
  bool isShowContactUpdate = false;

  int? _expandedTravellerIndex;
  bool _isAddTravellerExpanded = false;

  bool _isSavingContact = false;
  bool _isSavingTraveller = false;
  bool _isAddingTraveller = false;
  int? _deletingIndex;

  late final UserController _userC;
  late final DashboardController _dashboardC;
  Worker? _profileWorker;

  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();

    _userC = Get.find<UserController>();
    _dashboardC = Get.find<DashboardController>();

    filteredStates = List.from(_dashboardC.stateList);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _profileWorker = ever(_userC.userProfileData, (userData) {
      if (!mounted) return;
      if (userData.customer != null) _initializeStateData();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeStateData();
    });
  }

  void _initializeStateData() {
    final customer = _userC.userProfileData.value.customer;
    final stateId = customer?.state?.id;
    final stateName = customer?.state?.name;

    if (stateId != null) {
      if (_userC.stateUpdateId.value != stateId ||
          _selectedState != (stateName ?? '')) {
        _userC.stateUpdateId.value = stateId;
        if (mounted) {
          setState(() => _selectedState = stateName ?? '');
        } else {
          _selectedState = stateName ?? '';
        }
      }
    } else if (filteredStates.isNotEmpty && _selectedState.isEmpty) {
      _userC.stateUpdateId.value = filteredStates.first.id ?? 0;
      if (mounted) {
        setState(() => _selectedState = filteredStates.first.name ?? '');
      } else {
        _selectedState = filteredStates.first.name ?? '';
      }
    }
  }

  void _resetTravellerForm() {
    _userC.travellerId.value = 0;
    _userC.nameControllerTraveller.value.clear();
    _userC.ageControllerTraveller.value.clear();
    _userC.selectedGender.value = '';
    if (mounted) FocusScope.of(context).unfocus();
  }

  void _openTravellerEditor(Traveler traveler, int index) {
    _userC.travellerId.value = traveler.id ?? 0;
    _userC.nameControllerTraveller.value.text = traveler.name ?? '';
    _userC.ageControllerTraveller.value.text = traveler.age?.toString() ?? '';
    _userC.selectedGender.value = (traveler.gender ?? '').toLowerCase();

    setState(() {
      _expandedTravellerIndex = index;
      _isAddTravellerExpanded = false;
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) FocusScope.of(context).requestFocus(nameNode);
    });
  }

  void _closeTravellerEditor() {
    _resetTravellerForm();
    setState(() => _expandedTravellerIndex = null);
  }

  void _openAddTravellerForm() {
    _resetTravellerForm();
    setState(() {
      _expandedTravellerIndex = null;
      _isAddTravellerExpanded = true;
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) FocusScope.of(context).requestFocus(nameNode);
    });
  }

  void _closeAddTravellerForm() {
    _resetTravellerForm();
    setState(() => _isAddTravellerExpanded = false);
  }

  bool _validateTravellerForm() {
    final name = _userC.nameControllerTraveller.value.text.trim();
    final ageText = _userC.ageControllerTraveller.value.text.trim();
    final gender = _userC.selectedGender.value.trim();

    if (name.isEmpty) {
      _showSnack('Please enter the traveller\'s name.');
      return false;
    }
    if (gender.isEmpty) {
      _showSnack('Please select a gender.');
      return false;
    }
    final age = int.tryParse(ageText);
    if (age == null || age <= 0 || age > 120) {
      _showSnack('Please enter a valid age (1–120).');
      return false;
    }
    return true;
  }

  bool _validateContactForm() {
    final email = _userC.emailController.value.text.trim();
    final phone = _userC.phoneNumberController.value.text.trim();

    if (phone.isEmpty || phone.length != 10) {
      _showSnack('Phone number must be 10 digits.');
      return false;
    }
    final emailRegex = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      _showSnack('Please enter a valid email address.');
      return false;
    }
    if (_userC.stateUpdateId.value == 0) {
      _showSnack('Please select your state of residence.');
      return false;
    }
    return true;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(4.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
        ),
      );
  }

  Future<void> _submitTravellerUpdate() async {
    if (_isSavingTraveller) return;
    if (!_validateTravellerForm()) return;

    setState(() => _isSavingTraveller = true);
    try {
      await _userC.updateTraveler();
      if (!mounted) return;
      _resetTravellerForm();
      setState(() => _expandedTravellerIndex = null);
    } catch (e) {
      log('updateTraveler failed: $e');
      _showSnack('Could not update traveller. Please try again.');
    } finally {
      if (mounted) setState(() => _isSavingTraveller = false);
    }
  }

  Future<void> _submitNewTraveller() async {
    if (_isAddingTraveller) return;
    if (!_validateTravellerForm()) return;

    setState(() => _isAddingTraveller = true);
    try {
      await _userC.addTraveler();
      if (!mounted) return;
      log(
        'added traveller: ${_userC.nameControllerTraveller.value.text}, '
        '${_userC.ageControllerTraveller.value.text}',
      );
      _resetTravellerForm();
      setState(() => _isAddTravellerExpanded = false);
    } catch (e) {
      log('addTraveler failed: $e');
      _showSnack('Could not add traveller. Please try again.');
    } finally {
      if (mounted) setState(() => _isAddingTraveller = false);
    }
  }

Future<void> _confirmDeleteTraveller(int index, Traveler traveller) async {
  if (_deletingIndex != null) return;

  final bool? confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: _C.cardBg,
            borderRadius: BorderRadius.circular(5.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon badge + title row
              Row(
                children: [
                  Container(
                    width: 11.w,
                    height: 11.w,
                    decoration: BoxDecoration(
                      color: _C.danger.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: _C.danger,
                        size: 5.5.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Delete Traveller',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.w700,
                      color: _C.ink,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Traveller info chip
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.4.h,
                ),
                decoration: BoxDecoration(
                  color: _C.fieldBg,
                  borderRadius: BorderRadius.circular(2.5.w),
                  border: Border.all(color: _C.fieldBorder),
                ),
                child: Row(
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
                          (traveller.name?.isNotEmpty == true
                                  ? traveller.name!
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          traveller.name ?? 'Unknown',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s10,
                            fontWeight: FontWeight.w600,
                            color: _C.ink,
                          ),
                        ),
                        Text(
                          '${traveller.gender ?? '-'}, Age ${traveller.age ?? '-'}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s9,
                            color: _C.inkMid,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 1.5.h),

              // Body message
              Text(
                'This traveller will be permanently removed from your profile and cannot be recovered.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s9,
                  color: _C.inkMid,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 2.5.h),

              // Action buttons
              Row(
                children: [
                  // Cancel
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 5.5.h,
                        decoration: BoxDecoration(
                          color: _C.fieldBg,
                          borderRadius: BorderRadius.circular(2.w),
                          border: Border.all(color: _C.fieldBorder),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s10,
                              fontWeight: FontWeight.w600,
                              color: _C.inkMid,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // Delete
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 5.5.h,
                        decoration: BoxDecoration(
                          color: _C.danger,
                          borderRadius: BorderRadius.circular(2.w),
                          boxShadow: [
                            BoxShadow(
                              color: _C.danger.withOpacity(0.30),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                                size: 4.5.w,
                              ),
                              SizedBox(width: 1.5.w),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: FontSize.s10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  if (confirmed == true && mounted) {
    await _deleteTravellerAtIndex(index, traveller);
  }
}


  Future<void> _deleteTravellerAtIndex(int index, Traveler traveller) async {
    setState(() => _deletingIndex = index);

    try {
      final dynamic uc = _userC;
      try {
        await uc.deleteTraveler(traveller.id);
      } on NoSuchMethodError {
        _removeTravellerLocally(index);
      }

      if (!mounted) return;

      if (_expandedTravellerIndex == index) {
        _expandedTravellerIndex = null;
        _resetTravellerForm();
      } else if (_expandedTravellerIndex != null &&
          _expandedTravellerIndex! > index) {
        _expandedTravellerIndex = _expandedTravellerIndex! - 1;
      }
      setState(() {});
    } catch (e) {
      log('deleteTraveler failed: $e');
      _showSnack('Could not delete traveller. Please try again.');
    } finally {
      if (mounted) setState(() => _deletingIndex = null);
    }
  }

  void _removeTravellerLocally(int index) {
    final customer = _userC.userProfileData.value.customer;
    if (customer == null) return;

    final updatedTravelers = List<Traveler>.from(customer.travelers ?? []);
    if (index < 0 || index >= updatedTravelers.length) return;
    updatedTravelers.removeAt(index);

    try {
      final updatedCustomer = (customer as dynamic).copyWith(
        travelers: updatedTravelers,
      );
      _userC.userProfileData.value = (_userC.userProfileData.value as dynamic)
          .copyWith(customer: updatedCustomer);
    } catch (e) {
      log('Local traveller removal could not use copyWith: $e');
    }
  }

  List<Widget> _buildTravellerFormFields() {
    return [
      _buildFieldLabel('Full Name'),
      SizedBox(height: 0.6.h),
      _buildTextField(
        controller: _userC.nameControllerTraveller.value,
        hint: 'Name',
        focusNode: nameNode,
        textCapitalization: TextCapitalization.words,
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
                Obx(() {
                  final selected = _userC.selectedGender.value.toLowerCase();
                  return Row(
                    children: [
                      _buildGenderButton('Male', selected == 'male'),
                      SizedBox(width: 2.w),
                      _buildGenderButton('Female', selected == 'female'),
                    ],
                  );
                }),
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
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
    _profileWorker?.dispose();
    _entranceController.dispose();
    nameNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Obx(() {
        final travelers =
            _userC.userProfileData.value.customer?.travelers ?? const [];

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),

              _animatedSlideIn(
                index: 0,
                child: _buildContactCard(),
              ),

              AnimatedSize(
                duration: _kAnimDuration,
                curve: _kAnimCurve,
                child: AnimatedSwitcher(
                  duration: _kAnimDuration,
                  switchInCurve: _kAnimCurve,
                  switchOutCurve: _kAnimCurve,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SizeTransition(
                      sizeFactor: anim,
                      axisAlignment: -1,
                      child: child,
                    ),
                  ),
                  child: isShowContactUpdate
                      ? Padding(
                          key: const ValueKey('contact-save'),
                          padding: EdgeInsets.only(top: 2.h),
                          child: CommonButton(
                            height: 48,
                            gradient: CommonColors.filterGradient,
                            text: _isSavingContact ? 'Saving...' : 'Save',
                            textColor: CommonColors.whiteColor,
                            onPressed: _isSavingContact
                                ? () {}
                                : () async {
                                    if (!_validateContactForm()) return;
                                    setState(() => _isSavingContact = true);
                                    try {
                                      await _userC.updateUserProfile();
                                      if (!mounted) return;
                                      setState(
                                          () => isShowContactUpdate = false);
                                    } catch (e) {
                                      log('updateUserProfile failed: $e');
                                      _showSnack(
                                          'Could not save changes. Please try again.');
                                    } finally {
                                      if (mounted) {
                                        setState(
                                            () => _isSavingContact = false);
                                      }
                                    }
                                  },
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('contact-empty')),
                ),
              ),

              SizedBox(height: 2.h),

              _animatedSlideIn(
                index: 1,
                child: _buildCard(
                  icon: CommonImages.account,
                  title: 'Traveller Details',
                  children: [
                    AnimatedSize(
                      duration: _kAnimDuration,
                      curve: _kAnimCurve,
                      child: travelers.isEmpty
                          ? _buildEmptyTravellerState()
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: travelers.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 1.h),
                              itemBuilder: (context, index) {
                                return _buildExistingTravellerItem(
                                  travelData: travelers[index],
                                  index: index,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 1.8.h),

              _animatedSlideIn(
                index: 2,
                child: _buildAddTravellerContainer(),
              ),

              SizedBox(height: 4.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _animatedSlideIn({required int index, required Widget child}) {
    final start = (index * 0.12).clamp(0.0, 1.0);
    final end = (start + 0.6).clamp(0.0, 1.0);
    final anim = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) {
        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(0, (1 - anim.value) * 18),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildContactCard() {
    return _buildCard(
      icon: CommonImages.phone,
      title: 'Contact Information',
      trailing: AnimatedSwitcher(
        duration: _kAnimDuration,
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: !isShowContactUpdate
            ? TextButton(
                key: const ValueKey('edit-btn'),
                onPressed: _enterContactEditMode,
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
                key: const ValueKey('close-btn'),
                onPressed: () =>
                    setState(() => isShowContactUpdate = false),
                icon: Icon(
                  Icons.close_rounded,
                  size: 5.w,
                  color: _C.inkMid,
                ),
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
          value: _userC.userProfileData.value.customer?.phone ?? '-',
        ),
        SizedBox(height: 0.8.h),
        _buildReadRow(
          icon: CommonImages.email,
          value: _userC.userProfileData.value.customer?.email ?? '-',
        ),
        SizedBox(height: 0.8.h),
        _buildReadRow(
          icon: CommonImages.location4,
          value: () {
            final idx = _dashboardC.stateList.indexWhere(
              (e) =>
                  e.id == _userC.userProfileData.value.customer?.state?.id,
            );
            return idx >= 0
                ? _dashboardC.stateList[idx].name ?? '-'
                : '-';
          }(),
        ),
        AnimatedSize(
          duration: _kAnimDuration,
          curve: _kAnimCurve,
          child: AnimatedSwitcher(
            duration: _kAnimDuration,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SizeTransition(
                sizeFactor: anim,
                axisAlignment: -1,
                child: child,
              ),
            ),
            child: isShowContactUpdate
                ? Column(
                    key: const ValueKey('contact-edit'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      const Divider(
                          color: _C.fieldBorder, thickness: 1, height: 1),
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
                  )
                : const SizedBox.shrink(key: ValueKey('contact-readonly')),
          ),
        ),
      ],
    );
  }

  void _enterContactEditMode() {
    final customer = _userC.userProfileData.value.customer;
    _userC.phoneNumberController.value.text =
        (customer?.phone ?? '').replaceFirst('+91', '');
    _userC.emailController.value.text = customer?.email ?? '';

    if (customer?.state?.id != null) {
      _userC.stateUpdateId.value = customer!.state!.id!;
      _selectedState = customer.state?.name ?? '';
    }
    setState(() => isShowContactUpdate = true);
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
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: TextField(
        controller: controller,
        enabled: enabled,
        focusNode: focusNode,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
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
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: const TextScaler.linear(1.0)),
                    child: TextField(
                      controller: _userC.phoneNumberController.value,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
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
                Expanded(
                  child: Column(
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
                      AnimatedSwitcher(
                        duration: _kAnimDuration,
                        child: Text(
                          _selectedState.isEmpty
                              ? 'Select state'
                              : _selectedState,
                          key: ValueKey(_selectedState),
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s10,
                            fontWeight: FontWeight.w400,
                            color: _selectedState.isEmpty
                                ? _C.inkLight
                                : _C.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.keyboard_arrow_down,
                    color: _C.inkMid, size: 6.w),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton(String gender, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _userC.selectedGender.value = gender.toLowerCase(),
        child: AnimatedContainer(
          duration: _kAnimDuration,
          curve: _kAnimCurve,
          height: 5.5.h,
          decoration: BoxDecoration(
            color: isSelected ? _C.teal : _C.fieldBg,
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(
              color: isSelected ? _C.teal : _C.fieldBorder,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _C.teal.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: _kAnimDuration,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : _C.inkMid,
              ),
              child: Text(
                gender,
                textScaler: const TextScaler.linear(1.0),
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
    required Traveler travelData,
    required int index,
  }) {
    final isExpanded = _expandedTravellerIndex == index;
    final isDeleting = _deletingIndex == index;

    return AnimatedContainer(
      duration: _kAnimDuration,
      curve: _kAnimCurve,
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: _C.fieldBg,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: isExpanded ? _C.teal.withOpacity(0.25) : _C.fieldBorder,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: _C.teal.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : const [],
      ),
      child: AnimatedOpacity(
        duration: _kAnimDuration,
        opacity: isDeleting ? 0.5 : 1,
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: isDeleting
                          ? null
                          : () {
                              if (isExpanded) {
                                _closeTravellerEditor();
                              } else {
                                _openTravellerEditor(travelData, index);
                              }
                            },
                      child: AnimatedSwitcher(
                        duration: _kAnimDuration,
                        child: Text(
                          isExpanded ? 'Cancel' : 'Edit',
                          key: ValueKey(isExpanded),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s9,
                            fontWeight: FontWeight.w600,
                            color: isExpanded ? _C.inkMid : _C.teal,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 1.w),
                    GestureDetector(
                      onTap: isDeleting
                          ? null
                          : () => _confirmDeleteTraveller(index, travelData),
                      child: Container(
                        padding: EdgeInsets.all(1.8.w),
                        decoration: BoxDecoration(
                          color: _C.danger.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: isDeleting
                            ? SizedBox(
                                width: 4.8.w,
                                height: 4.8.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _C.danger,
                                ),
                              )
                            : Icon(
                                Icons.delete_outline_rounded,
                                size: 4.8.w,
                                color: _C.danger,
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            AnimatedSize(
              duration: _kAnimDuration,
              curve: _kAnimCurve,
              child: AnimatedSwitcher(
                duration: _kAnimDuration,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SizeTransition(
                    sizeFactor: anim,
                    axisAlignment: -1,
                    child: child,
                  ),
                ),
                child: isExpanded
                    ? Column(
                        key: const ValueKey('traveller-edit'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 1.5.h),
                          const Divider(
                              color: _C.fieldBorder, thickness: 1, height: 1),
                          SizedBox(height: 1.8.h),
                          ..._buildTravellerFormFields(),
                          SizedBox(height: 2.h),
                          CommonButton(
                            height: 48,
                            gradient: CommonColors.filterGradient,
                            text: _isSavingTraveller
                                ? 'Updating...'
                                : 'Update Traveller',
                            textColor: CommonColors.whiteColor,
                            onPressed: _isSavingTraveller
                                ? () {}
                                : _submitTravellerUpdate,
                          ),
                        ],
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('traveller-collapsed')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTravellerContainer() {
    return AnimatedContainer(
      duration: _kAnimDuration,
      curve: _kAnimCurve,
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
                AnimatedSwitcher(
                  duration: _kAnimDuration,
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: Tween<double>(begin: 0.75, end: 1).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: _isAddTravellerExpanded
                      ? IconButton(
                          key: const ValueKey('add-close'),
                          onPressed: _closeAddTravellerForm,
                          icon: Icon(
                            Icons.close_rounded,
                            size: 5.w,
                            color: _C.inkMid,
                          ),
                        )
                      : Icon(
                          Icons.add_rounded,
                          key: const ValueKey('add-plus'),
                          size: 5.w,
                          color: _C.teal,
                        ),
                ),
              ],
            ),
            AnimatedSize(
              duration: _kAnimDuration,
              curve: _kAnimCurve,
              child: AnimatedSwitcher(
                duration: _kAnimDuration,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SizeTransition(
                    sizeFactor: anim,
                    axisAlignment: -1,
                    child: child,
                  ),
                ),
                child: _isAddTravellerExpanded
                    ? Column(
                        key: const ValueKey('add-expanded'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          const Divider(
                              color: _C.fieldBorder, thickness: 1, height: 1),
                          SizedBox(height: 2.h),
                          ..._buildTravellerFormFields(),
                          SizedBox(height: 2.h),
                          CommonButton(
                            height: 48,
                            gradient: CommonColors.filterGradient,
                            text: _isAddingTraveller
                                ? 'Adding...'
                                : 'Add Traveller',
                            textColor: CommonColors.whiteColor,
                            onPressed: _isAddingTraveller
                                ? () {}
                                : _submitNewTraveller,
                          ),
                        ],
                      )
                    : Padding(
                        key: const ValueKey('add-collapsed'),
                        padding: EdgeInsets.only(left: 12.w, top: 0.8.h),
                        child: Text(
                          'Tap to add a new traveller profile.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s9,
                            color: _C.inkMid,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStateSelectionBottomSheet() async {
    final searchController = TextEditingController();
    filteredStates = List.from(_dashboardC.stateList);

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
                          Icon(Icons.search,
                              color: _C.inkLight, size: 5.5.w),
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
                                            s.name
                                                ?.toLowerCase()
                                                .contains(
                                                    value.toLowerCase()) ??
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
                      child: filteredStates.isEmpty
                          ? Center(
                              child: Text(
                                'No states match your search.',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: FontSize.s10,
                                  color: _C.inkMid,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredStates.length,
                              itemBuilder: (context, index) {
                                final state = filteredStates[index];
                                final isSelected =
                                    state.id == _userC.stateUpdateId.value;
                                return AnimatedContainer(
                                  duration: _kAnimDuration,
                                  margin:
                                      EdgeInsets.symmetric(vertical: 0.3.h),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _C.tealSoft
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(2.w),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(2.w),
                                      ),
                                      title: Text(
                                        state.name ?? '',
                                        textScaler:
                                            const TextScaler.linear(1.0),
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
                                          _selectedState = state.name ?? '';
                                          _userC.stateUpdateId.value =
                                              state.id ?? 0;
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
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
    );

    searchController.dispose();
    if (mounted) {
      setState(() => filteredStates = List.from(_dashboardC.stateList));
    }
  }
}
