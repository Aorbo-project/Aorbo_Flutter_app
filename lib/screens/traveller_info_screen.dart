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
import '../utils/state_selection_bottom_sheet.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';

class _C {
  static const bg = AppColors.bgCool;
  static const cardBg = AppColors.surface;
  static const ink = AppColors.ink;
  static const inkMid = AppColors.inkMid;
  static const inkLight = AppColors.inkLight;
  static const teal = AppColors.teal;
  static const tealLight = AppColors.tealLight;
  static const tealSoft = AppColors.tealSoft;
  static const fieldBg = AppColors.elevated;
  static const fieldBorder = AppColors.border;
  static const shadow = Color(0x0D000000);
  static const iconBadgeBg = AppColors.ink;
  static const danger = Color(0xFFEF4444);
  static const ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.forestDeep, AppColors.forest],
  );
}

class _NC {
  static const ink = AppColors.inkStrong;
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
    _userC.selectedGender.value = traveler.gender ?? '';

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

  void _addMyselfAsTraveler(String name) {
    _resetTravellerForm();
    _userC.nameControllerTraveller.value.text = name;
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
    final name = _userC.nameController.value.text.trim();
    final email = _userC.emailController.value.text.trim();
    final phone = _userC.phoneNumberController.value.text.trim();

    if (name.isEmpty) {
      _showSnack('Please enter your name.');
      return false;
    }
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

  /// Forest-green themed snackbar with an icon badge and dismiss affordance.
  /// Uses [AppGradients.cta] (forest deep → forest) for the surface and the
  /// brand's standard radius / shadow tokens so it matches the rest of the UI.
  void _showSnack(String message, {bool isError = true}) {
    if (!mounted) return;

    final IconData icon = isError
        ? Icons.error_outline_rounded
        : Icons.check_circle_outline_rounded;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          // Wrapper lets us paint a gradient on the SnackBar surface
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
            decoration: BoxDecoration(
              gradient: AppGradients.cta, // forest deep → forest
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.forestDeep.withValues(alpha: 0.30),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon badge (frosted circle on top of the gradient)
                Container(
                  width: 9.w,
                  height: 9.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 4.8.w),
                ),
                SizedBox(width: 3.w),
                // Message
                Expanded(
                  child: Text(
                    message,
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: AppType.clampFontSize(10.sp),
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.35,
                    ),
                  ),
                ),
                // Dismiss affordance
                GestureDetector(
                  onTap: () =>
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.only(left: 2.w),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 5.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent, // let the gradient show
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          padding: EdgeInsets.zero, // gradient handles its own padding
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          duration: const Duration(seconds: 3),
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
      barrierColor: Colors.black.withValues(alpha: 0.4),
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
                  color: Colors.black.withValues(alpha: 0.08),
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
                Row(
                  children: [
                    Container(
                      width: 11.w,
                      height: 11.w,
                      decoration: BoxDecoration(
                        color: _C.danger.withValues(alpha: 0.10),
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
                      style: AppType.style(
                        FontSize.s13,
                        w: FontWeight.w700,
                        color: _C.ink,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
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
                            style: AppType.style(
                              FontSize.s12,
                              w: FontWeight.w700,
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
                            style: AppType.style(
                              FontSize.s10,
                              w: FontWeight.w600,
                              color: _C.ink,
                            ),
                          ),
                          Text(
                            '${traveller.gender ?? '-'}, Age ${traveller.age ?? '-'}',
                            style: AppType.style(FontSize.s9, color: _C.inkMid),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.5.h),
                Text(
                  'This traveller will be permanently removed from your profile and cannot be recovered.',
                  style: AppType.style(
                    FontSize.s9,
                    color: _C.inkMid,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 2.5.h),
                Row(
                  children: [
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
                              style: AppType.style(
                                FontSize.s10,
                                w: FontWeight.w600,
                                color: _C.inkMid,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
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
                                color: _C.danger.withValues(alpha: 0.30),
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
                                  style: AppType.style(
                                    FontSize.s10,
                                    w: FontWeight.w600,
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
      if (traveller.id == null) {
        _showSnack('Could not delete traveller. Please try again.');
        return;
      }

      // null = success, non-null string = error message
      final deleted = await _userC.deleteTraveler(traveller.id!);
      if (!mounted) return;

      if (deleted != null && deleted.isNotEmpty) {
        // ❌ Failure — show the server's message
        _showSnack(deleted);
        return;
      }

      // ✅ Success — refresh UI
      if (_expandedTravellerIndex == index) {
        _expandedTravellerIndex = null;
        _resetTravellerForm();
      } else if (_expandedTravellerIndex != null &&
          _expandedTravellerIndex! > index) {
        _expandedTravellerIndex = _expandedTravellerIndex! - 1;
      }
      setState(() {});
    } catch (e) {
      // Safety net — controller shouldn't normally throw, but just in case
      String errorMsg = 'Could not delete traveller.';
      try {
        final dynamic responseData = (e as dynamic).response?.data;
        if (responseData is Map && responseData['message'] != null) {
          errorMsg = responseData['message'].toString();
        }
      } catch (_) {}
      log('deleteTraveler failed: $e');
      if (mounted) _showSnack(errorMsg);
    } finally {
      if (mounted) setState(() => _deletingIndex = null);
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
          style: AppType.style(
            FontSize.s15,
            w: FontWeight.w700,
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
              _animatedSlideIn(index: 0, child: _buildContactCard()),
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
                            gradient: _C.ctaGradient,
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
                                        () => isShowContactUpdate = false,
                                      );
                                    } catch (e) {
                                      log('updateUserProfile failed: $e');
                                      _showSnack(
                                        'Could not save changes. Please try again.',
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(
                                          () => _isSavingContact = false,
                                        );
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
              _animatedSlideIn(index: 2, child: _buildAddTravellerContainer()),
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
    final customer = _userC.userProfileData.value.customer;
    final rawName = customer?.name?.trim() ?? '';
    final displayName = rawName.isNotEmpty ? rawName : 'Primary User';

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
                  style: AppType.style(
                    FontSize.s10,
                    w: FontWeight.w600,
                    color: _C.teal,
                  ),
                ),
              )
            : IconButton(
                key: const ValueKey('close-btn'),
                onPressed: () => setState(() => isShowContactUpdate = false),
                icon: Icon(Icons.close_rounded, size: 5.w, color: _C.inkMid),
              ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: _C.tealSoft,
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(color: _C.teal.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Text(
                  '👤 Primary',
                  style: AppType.style(
                    FontSize.s8,
                    w: FontWeight.w700,
                    color: _C.teal,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'You are the main account holder. Tickets & updates will be sent to $displayName.',
                  style: AppType.style(
                    FontSize.s9,
                    color: _C.teal,
                    w: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.5.h),
        _buildReadRow(icon: CommonImages.account, value: displayName),
        SizedBox(height: 0.8.h),
        _buildReadRow(icon: CommonImages.phone, value: customer?.phone ?? '-'),
        SizedBox(height: 0.8.h),
        _buildReadRow(icon: CommonImages.email, value: customer?.email ?? '-'),
        SizedBox(height: 0.8.h),
        _buildReadRow(
          icon: CommonImages.location4,
          value: () {
            final idx = _dashboardC.stateList.indexWhere(
              (e) => e.id == customer?.state?.id,
            );
            return idx >= 0 ? _dashboardC.stateList[idx].name ?? '-' : '-';
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
                        color: _C.fieldBorder,
                        thickness: 1,
                        height: 1,
                      ),
                      SizedBox(height: 2.h),
                      _buildFieldLabel('Full Name'),
                      SizedBox(height: 0.6.h),
                      _buildTextField(
                        controller: _userC.nameController.value,
                        hint: 'Your Name',
                        textCapitalization: TextCapitalization.words,
                      ),
                      SizedBox(height: 1.8.h),
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
    _userC.nameController.value.text = customer?.name ?? '';
    _userC.phoneNumberController.value.text = (customer?.phone ?? '')
        .replaceFirst('+91', '');
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
            color: CommonColors.blackColor.withValues(alpha: 0.08),
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
                  style: AppType.style(
                    FontSize.s10,
                    w: FontWeight.w600,
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
            style: AppType.style(
              FontSize.s10,
              w: FontWeight.w500,
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
      style: AppType.style(FontSize.s9, w: FontWeight.w500, color: _C.inkMid),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    FocusNode? focusNode,
    bool enabled = true,
    bool readOnly = false,
    Widget? suffixIcon,
    Widget? prefix,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.0)),
      child: TextField(
        controller: controller,
        enabled: enabled,
        readOnly: readOnly,
        focusNode: focusNode,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        style: AppType.style(
          FontSize.s10,
          color: readOnly ? _C.inkMid : _C.ink,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppType.style(FontSize.s10, color: _C.inkLight),
          counterText: '',
          isDense: true,
          filled: true,
          fillColor: _C.fieldBg,
          suffixIcon: suffixIcon,
          prefix: prefix,
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
    return _buildTextField(
      controller: _userC.phoneNumberController.value,
      hint: 'Phone Number',
      readOnly: true, // Blocked for editing
      prefix: Padding(
        padding: EdgeInsets.only(right: 3.w),
        child: Text(
          '+91',
          style: AppType.style(FontSize.s10, w: FontWeight.w700, color: _C.ink),
        ),
      ),
      suffixIcon: Icon(
        Icons.lock_outline_rounded,
        size: 4.w,
        color: _C.inkLight,
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
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
                        style: AppType.style(
                          FontSize.s7,
                          w: FontWeight.w300,
                          color: _C.inkLight,
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
                          style: AppType.style(
                            FontSize.s10,
                            w: FontWeight.w400,
                            color: _selectedState.isEmpty
                                ? _C.inkLight
                                : _C.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: _C.inkMid, size: 6.w),
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
        onTap: () => _userC.selectedGender.value = gender,
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
                      color: _C.teal.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: _kAnimDuration,
              style: AppType.style(
                FontSize.s10,
                w: FontWeight.w600,
                color: isSelected ? Colors.white : _C.inkMid,
              ),
              child: Text(gender, textScaler: const TextScaler.linear(1.0)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTravellerState() {
    final customer = _userC.userProfileData.value.customer;
    final rawName = customer?.name?.trim() ?? '';
    final hasName = rawName.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: _C.fieldBg,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: _C.fieldBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.group_add_rounded, size: 10.w, color: _C.teal),
          SizedBox(height: 1.h),
          Text(
            'Who is traveling?',
            style: AppType.style(
              FontSize.s12,
              w: FontWeight.w700,
              color: _C.ink,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Add yourself or your group members to your profile so you can quickly select them during checkout.',
            textAlign: TextAlign.center,
            style: AppType.style(FontSize.s9, color: _C.inkMid, height: 1.4),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              if (hasName)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _addMyselfAsTraveler(rawName),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.2.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2.w),
                        border: Border.all(color: _C.teal),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline, size: 4.w, color: _C.teal),
                          SizedBox(width: 2.w),
                          Text(
                            'Add Myself',
                            style: AppType.style(
                              FontSize.s10,
                              w: FontWeight.w600,
                              color: _C.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (hasName) SizedBox(width: 3.w),
              Expanded(
                child: GestureDetector(
                  onTap: _openAddTravellerForm,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1.2.h),
                    decoration: BoxDecoration(
                      gradient: _C.ctaGradient,
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 4.w,
                          color: Colors.white,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Add New',
                          style: AppType.style(
                            FontSize.s10,
                            w: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
          color: isExpanded ? _C.teal.withValues(alpha: 0.25) : _C.fieldBorder,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: _C.teal.withValues(alpha: 0.08),
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
                      style: AppType.style(
                        FontSize.s12,
                        w: FontWeight.w700,
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
                        style: AppType.style(
                          FontSize.s10,
                          w: FontWeight.w600,
                          color: _C.ink,
                        ),
                      ),
                      Text(
                        '${travelData.gender ?? '-'}, Age ${travelData.age ?? '-'}',
                        textScaler: const TextScaler.linear(1.0),
                        style: AppType.style(FontSize.s9, color: _C.inkMid),
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
                          style: AppType.style(
                            FontSize.s9,
                            w: FontWeight.w600,
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
                          color: _C.danger.withValues(alpha: 0.08),
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
                            color: _C.fieldBorder,
                            thickness: 1,
                            height: 1,
                          ),
                          SizedBox(height: 1.8.h),
                          ..._buildTravellerFormFields(),
                          SizedBox(height: 2.h),
                          CommonButton(
                            height: 48,
                            gradient: _C.ctaGradient,
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
                        key: ValueKey('traveller-collapsed'),
                      ),
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
            ? Border.all(color: _C.teal.withValues(alpha: 0.2))
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
                    style: AppType.style(
                      FontSize.s13,
                      w: FontWeight.w600,
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
                            color: _C.fieldBorder,
                            thickness: 1,
                            height: 1,
                          ),
                          SizedBox(height: 2.h),
                          ..._buildTravellerFormFields(),
                          SizedBox(height: 2.h),
                          CommonButton(
                            height: 48,
                            gradient: _C.ctaGradient,
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
                          style: AppType.style(FontSize.s9, color: _C.inkMid),
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
    await showStateSelectionBottomSheet(
      context: context,
      stateList: _dashboardC.stateList,
      selectedStateId: _userC.stateUpdateId.value,
      onStateSelected: (state) {
        setState(() {
          _selectedState = state.name ?? '';
          _userC.stateUpdateId.value = state.id ?? 0;
        });
      },
    );

    if (mounted) {
      setState(() => filteredStates = List.from(_dashboardC.stateList));
    }
  }
}
