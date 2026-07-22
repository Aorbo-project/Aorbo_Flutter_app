import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';
import '../utils/common_btn.dart';
import '../models/emergency_contact_model.dart';
import '../repository/repository.dart';
import '../repository/network_url.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS — aligned with TravellerInfoScreen
// ─────────────────────────────────────────────
class _C {
  static const bg          = Color(0xFFF5F8FF);
  static const cardBg      = Color(0xFFFFFFFF);
  static const ink         = Color(0xFF111827);
  static const inkMid      = Color(0xFF6B7280);
  static const inkLight    = Color(0xFF9CA3AF);
  static const teal        = Color(0xFF0F7B6C);
  static const tealSoft    = Color(0xFFE6F5F3);
  static const fieldBg     = Color(0xFFF9FAFB);
  static const fieldBorder = Color(0xFFE5E7EB);
  static const iconBadgeBg = Color(0xFF111827);
  static const danger      = Color(0xFFEF4444);
  static const dangerLight = Color(0xFFFEF2F2);
  static const divider     = Color(0xFFE5E7EB);
  static const ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
  );
}

class _NInk {
  static const ink = Color(0xFF0F172A);
}

const _kAnimDur   = Duration(milliseconds: 280);
const _kAnimCurve = Curves.easeOutCubic;

class SelectedEmergencyContactsScreen extends StatefulWidget {
  const SelectedEmergencyContactsScreen({super.key});

  @override
  State<SelectedEmergencyContactsScreen> createState() =>
      _SelectedEmergencyContactsScreenState();
}

class _SelectedEmergencyContactsScreenState
    extends State<SelectedEmergencyContactsScreen>
    with SingleTickerProviderStateMixin {
  List<Contact> selectedContacts = [];
  List<EmergencyContact> apiEmergencyContacts = [];
  bool isLoading = true;
  bool _isSaving = false;

  final Repository _repository = Repository();
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    final arguments = Get.arguments;
    if (arguments != null && arguments is List<Contact>) {
      selectedContacts = List.from(arguments);
    }
    _loadEmergencyContacts();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Data ────────────────────────────────────────────────────────────────────

  Future<void> _loadEmergencyContacts() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.emergencyContacts,
      );
      if (response != null && mounted) {
        final r = EmergencyContactResponse.fromJson(response);
        if (r.success == true) {
          setState(() => apiEmergencyContacts = r.data ?? []);
        }
      }
    } catch (e) {
      log('_loadEmergencyContacts failed: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _saveEmergencyContacts() async {
    if (_isSaving || selectedContacts.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      int successCount = 0;
      String? errorMessage;

      for (final contact in selectedContacts) {
        final phone = contact.phones.isNotEmpty
            ? contact.phones.first.number
            : '';
        final body = {
          'name':         contact.displayName,
          'phone':        phone,
          'relationship': contact.displayName,
        };
        try {
          final response = await _repository.postApiCall(
            url:  NetworkUrl.emergencyContacts,
            body: body,
          );
          if (response != null) {
            final r = EmergencyContactCreateResponse.fromJson(response);
            if (r.success == true) {
              successCount++;
            } else {
              errorMessage = r.message ?? 'Failed to save contact';
              break;
            }
          }
        } catch (e) {
          errorMessage = e.toString();
          break;
        }
      }

      if (!mounted) return;

      if (errorMessage != null) {
        _showSnack(errorMessage, isError: true);
      } else {
        _showSnack('$successCount contact(s) saved successfully');
      }

      await _loadEmergencyContacts();
      if (!mounted) return;
      setState(() => selectedContacts.clear());

      // Pop back to Safety screen. If the named route isn't found,
      // fall back to a single Get.back() so we never get stuck.
      final didPop = Get.currentRoute != '/safety';
      if (didPop) {
        Get.until((route) {
          return route.settings.name == '/safety' ||
              route.isFirst;
        });
      } else {
        Get.back();
      }
    } catch (e) {
      log('_saveEmergencyContacts failed: $e');
      if (mounted) _showSnack('Failed to save contacts. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteEmergencyContact(int id) async {
    try {
      final response = await _repository.deleteApiCall(
        url: NetworkUrl.deleteEmergencyContact(id),
      );
      if (response != null && mounted) {
        final r = EmergencyContactDeleteResponse.fromJson(response);
        _showSnack(
          r.message ?? 'Contact deleted successfully',
          isError: r.success != true,
        );
        if (r.success == true) await _loadEmergencyContacts();
      }
    } catch (e) {
      log('_deleteEmergencyContact failed: $e');
      if (mounted) _showSnack('Failed to delete. Please try again.', isError: true);
    }
  }

  /// Navigate to picker, preserving back-stack.
  /// Uses Get.toNamed so returning from picker comes back here.
  Future<void> _addMoreContacts() async {
    final total = apiEmergencyContacts.length + selectedContacts.length;
    if (total >= 3) {
      _showSnack('Maximum 3 emergency contacts allowed.', isError: true);
      return;
    }
    final result = await Get.toNamed(
      '/emergency-contacts',
      arguments: selectedContacts,
    );
    if (result != null && result is List<Contact> && mounted) {
      setState(() {
        final existingIds = selectedContacts.map((e) => e.id).toSet();
        for (final contact in result) {
          final totalNow =
              apiEmergencyContacts.length + selectedContacts.length;
          if (!existingIds.contains(contact.id) && totalNow < 3) {
            selectedContacts.add(contact);
          }
        }
      });
    }
  }

  // ── Snack ───────────────────────────────────────────────────────────────────

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: FontSize.s14,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s10,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isError ? _C.danger : _C.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
          margin: EdgeInsets.all(4.w),
        ),
      );
  }

  // ── Delete dialog (themed to match TravellerInfoScreen) ────────────────────

  void _showDeleteConfirmation(int id, String contactName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => Dialog(
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
              // Title row
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
                        size: FontSize.s14,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Delete Contact',
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

              // Contact chip
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
                          contactName.isNotEmpty
                              ? contactName[0].toUpperCase()
                              : '?',
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
                      child: Text(
                        contactName,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s10,
                          fontWeight: FontWeight.w600,
                          color: _C.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 1.5.h),

              Text(
                'This contact will be permanently removed from your emergency contacts and cannot be recovered.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s9,
                  color: _C.inkMid,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 2.5.h),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
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
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _deleteEmergencyContact(id);
                      },
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
                                size: FontSize.s12,
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
      ),
    );
  }

  void _removeContact(Contact contact) =>
      setState(() => selectedContacts.remove(contact));

  // ── UI helpers ──────────────────────────────────────────────────────────────

  Widget _buildAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 11.w,
      height: 11.w,
      decoration: const BoxDecoration(
        color: _C.tealSoft,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w700,
            color: _C.teal,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteBtn(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 9.w,
        height: 9.w,
        decoration: BoxDecoration(
          color: _C.danger.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          color: _C.danger,
          size: FontSize.s12,
        ),
      ),
    );
  }

  Widget _buildApiContactCard(EmergencyContact contact, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(color: _C.fieldBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAvatar(contact.name ?? '?'),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name ?? 'Unknown',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w600,
                      color: _C.ink,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    contact.phone ?? 'No number',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s9,
                      color: _C.inkMid,
                    ),
                  ),
                  if (contact.relationship != null &&
                      contact.relationship!.isNotEmpty) ...[
                    SizedBox(height: 0.5.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.3.h,
                      ),
                      decoration: BoxDecoration(
                        color: _C.tealSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        contact.relationship!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s7,
                          fontWeight: FontWeight.w600,
                          color: _C.teal,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _buildDeleteBtn(() {
              if (contact.id != null) {
                _showDeleteConfirmation(
                  contact.id!,
                  contact.name ?? 'this contact',
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingContactCard(Contact contact, int index) {
    final phone = contact.phones.isNotEmpty
        ? contact.phones.first.number
        : 'No number';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(
        milliseconds: 300 + (apiEmergencyContacts.length + index) * 80,
      ),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color: _C.teal.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _C.teal.withValues(alpha: 0.06),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAvatar(contact.displayName),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.displayName,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s11,
                            fontWeight: FontWeight.w600,
                            color: _C.ink,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.3.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3BF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Pending',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s7,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE67700),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    phone,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s9,
                      color: _C.inkMid,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            _buildDeleteBtn(() => _removeContact(contact)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18.w,
              height: 18.w,
              decoration: const BoxDecoration(
                color: _C.tealSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 9.w,
                color: _C.teal,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'No contacts yet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s13,
                fontWeight: FontWeight.w600,
                color: _C.ink,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              'Add up to 3 trusted contacts who\nwill be notified in an emergency.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                color: _C.inkMid,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return GestureDetector(
      onTap: _addMoreContacts,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color: _C.teal.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _C.teal.withValues(alpha: 0.06),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: const BoxDecoration(
                color: _C.iconBadgeBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add emergency contact',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w600,
                      color: _C.ink,
                    ),
                  ),
                  Text(
                    '${3 - (apiEmergencyContacts.length + selectedContacts.length)} slot(s) remaining',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s8,
                      color: _C.inkLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: _C.teal,
              size: 4.w,
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final totalContacts =
        apiEmergencyContacts.length + selectedContacts.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Get.back(result: selectedContacts);
      },
      child: Scaffold(
        backgroundColor: _C.bg,
        appBar: AppBar(
          backgroundColor: _C.bg,
          scrolledUnderElevation: 0,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          iconTheme: const IconThemeData(color: _C.ink),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Get.back(result: selectedContacts),
          ),
          title: Text(
            'Emergency Contacts',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s14,
              fontWeight: FontWeight.w700,
              color: _NInk.ink,
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 4.w),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: _C.iconBadgeBg,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => Get.toNamed('/help'),
                child: Text(
                  'FAQ',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _C.divider),
          ),
        ),
        body: Column(
          children: [
            // ── Counter header ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 5.w,
                vertical: 2.h,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trusted contacts',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s13,
                            fontWeight: FontWeight.w700,
                            color: _C.ink,
                          ),
                        ),
                        SizedBox(height: 0.3.h),
                        Text(
                          'They will be notified in case of emergency',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s9,
                            color: _C.inkMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 0.6.h,
                    ),
                    decoration: BoxDecoration(
                      color: totalContacts >= 3
                          ? const Color(0xFFFFF3BF)
                          : _C.tealSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          totalContacts >= 3
                              ? Icons.lock_outline_rounded
                              : Icons.person_outline_rounded,
                          size: FontSize.s10,
                          color: totalContacts >= 3
                              ? const Color(0xFFE67700)
                              : _C.teal,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '$totalContacts / 3',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s10,
                            fontWeight: FontWeight.w700,
                            color: totalContacts >= 3
                                ? const Color(0xFFE67700)
                                : _C.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress bar ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: totalContacts / 3,
                  minHeight: 6,
                  backgroundColor: _C.fieldBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    totalContacts >= 3
                        ? const Color(0xFFFAB005)
                        : _C.teal,
                  ),
                ),
              ),
            ),

            SizedBox(height: 1.5.h),

            // ── Contact list ───────────────────────────────────────────
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: _C.teal,
                        strokeWidth: 2,
                      ),
                    )
                  : (apiEmergencyContacts.isEmpty &&
                          selectedContacts.isEmpty)
                      ? _buildEmptyState()
                      : ListView(
                          padding: EdgeInsets.only(
                            left: 5.w,
                            right: 5.w,
                            top: 1.h,
                            bottom:
                                selectedContacts.isNotEmpty ? 14.h : 3.h,
                          ),
                          children: [
                            // Saved contacts
                            if (apiEmergencyContacts.isNotEmpty) ...[
                              Padding(
                                padding:
                                    EdgeInsets.only(bottom: 1.h),
                                child: Text(
                                  'SAVED CONTACTS',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: FontSize.s8,
                                    fontWeight: FontWeight.w700,
                                    color: _C.inkLight,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              ...apiEmergencyContacts
                                  .asMap()
                                  .entries
                                  .map((e) => _buildApiContactCard(
                                        e.value,
                                        e.key,
                                      )),
                            ],

                            // Pending contacts
                            if (selectedContacts.isNotEmpty) ...[
                              if (apiEmergencyContacts.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 1.h,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: _C.fieldBorder,
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 3.w,
                                        ),
                                        child: Text(
                                          'TO BE SAVED',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: FontSize.s8,
                                            fontWeight: FontWeight.w700,
                                            color: _C.inkLight,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: _C.fieldBorder,
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Padding(
                                  padding:
                                      EdgeInsets.only(bottom: 1.h),
                                  child: Text(
                                    'NEW CONTACTS',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: FontSize.s8,
                                      fontWeight: FontWeight.w700,
                                      color: _C.inkLight,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ...selectedContacts
                                  .asMap()
                                  .entries
                                  .map((e) => _buildPendingContactCard(
                                        e.value,
                                        e.key,
                                      )),
                            ],

                            // Add more
                            if (totalContacts < 3)
                              _buildAddMoreButton(),
                          ],
                        ),
            ),
          ],
        ),

        // ── Floating save button ───────────────────────────────────────
        bottomNavigationBar: selectedContacts.isNotEmpty
            ? Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: _C.cardBg,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10.w,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: _C.fieldBorder,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Text(
                        '${selectedContacts.length} contact(s) ready to save',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s9,
                          color: _C.inkMid,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      CommonButton(
                        text: _isSaving
                            ? 'Saving...'
                            : 'Save Emergency Contacts',
                        onPressed:
                            _isSaving ? () {} : _saveEmergencyContacts,
                        gradient: _C.ctaGradient,
                        textColor: CommonColors.whiteColor,
                        fontWeight: FontWeight.w700,
                        fontSize: FontSize.s12,
                        height: 6.h,
                        isDisabled: _isSaving,
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
