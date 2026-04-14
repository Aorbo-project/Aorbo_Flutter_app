import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../utils/common_colors.dart';
import '../utils/common_images.dart';
import '../utils/screen_constants.dart';
import '../utils/common_btn.dart';
import '../models/emergency_contact_model.dart';
import '../repository/repository.dart';
import '../repository/network_url.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF4F7FF);
  static const cardBg = Color(0xFFFFFFFF);
  static const accent = Color(0xFF3B5BDB);
  static const accentLight = Color(0xFFEEF2FF);
  static const danger = Color(0xFFE03131);
  static const dangerLight = Color(0xFFFFF5F5);
  static const textPrimary = Color(0xFF1A1D2E);
  static const textSecond = Color(0xFF6C7293);
  static const textMuted = Color(0xFFADB5BD);
  static const border = Color(0xFFE9ECEF);
  static const iconBadge = Color(0xFF111827);
}

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
  final Repository _repository = Repository();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
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

  // ── ALL ORIGINAL LOGIC ──────────────────────
  Future<void> _loadEmergencyContacts() async {
    try {
      setState(() => isLoading = true);
      final response = await _repository.getApiCall(
        url: NetworkUrl.emergencyContacts,
      );
      if (response != null) {
        final r = EmergencyContactResponse.fromJson(response);
        if (r.success == true) {
          setState(() => apiEmergencyContacts = r.data ?? []);
        }
      }
    } catch (e) {
      // Silently fail
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _saveEmergencyContacts() async {
    if (selectedContacts.isEmpty) {
      Get.back();
      return;
    }
    try {
      setState(() => isLoading = true);
      int successCount = 0;
      String? errorMessage;
      for (final contact in selectedContacts) {
        final phone = contact.phones.isNotEmpty
            ? contact.phones.first.number
            : '';
        final body = {
          'name': contact.displayName,
          'phone': phone,
          'relationship': contact.displayName,
        };
        try {
          final response = await _repository.postApiCall(
            url: NetworkUrl.emergencyContacts,
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
      if (errorMessage != null) {
        _showSnack(errorMessage, isError: true);
      } else {
        _showSnack('$successCount contact(s) saved successfully');
      }
      await _loadEmergencyContacts();
      setState(() => selectedContacts.clear());

      // FIX: after saving, pop all the way back to Safety.
      // The back-stack is: Safety → Picker → SelectedEmergencyContacts
      // Get.until pops screens until it reaches the Safety route,
      // so the user never sees the picker screen on the way back.
      Get.until((route) => route.settings.name == '/safety');
    } catch (e) {
      _showSnack('Failed to save contacts: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteEmergencyContact(int id) async {
    try {
      final response = await _repository.deleteApiCall(
        url: NetworkUrl.deleteEmergencyContact(id),
      );
      if (response != null) {
        final r = EmergencyContactDeleteResponse.fromJson(response);
        _showSnack(
          r.message ?? 'Contact deleted successfully',
          isError: r.success != true,
        );
        if (r.success == true) await _loadEmergencyContacts();
      }
    } catch (e) {
      _showSnack('Failed to delete: ${e.toString()}', isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? _C.danger : _C.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      ),
    );
  }

  void _showDeleteConfirmation(int id, String contactName) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _C.dangerLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: _C.danger,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete Contact',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s14,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to remove $contactName from your emergency contacts?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s10,
                  color: _C.textSecond,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: _C.border, width: 1.5),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: _C.textSecond,
                          fontSize: FontSize.s10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _deleteEmergencyContact(id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.danger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: FontSize.s10,
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

  // FIX: _addMoreContacts uses Get.toNamed (not Get.offNamed)
  // so the back-stack stays intact:
  //   Safety → (Manage) SelectedEmergencyContacts
  //                       → (Add more) EmergencyContacts picker
  //                                     ← back returns here
  // Previously Get.offNamed popped this screen first, so returning
  // from the picker sent the user all the way back to Safety.
  Future<void> _addMoreContacts() async {
    final total = apiEmergencyContacts.length + selectedContacts.length;
    if (total >= 3) {
      _showSnack('Maximum 3 emergency contacts allowed', isError: true);
      return;
    }
    final result = await Get.toNamed(
      '/emergency-contacts',
      arguments: selectedContacts,
    );
    if (result != null && result is List<Contact>) {
      setState(() {
        final existingIds = selectedContacts.map((e) => e.id).toSet();
        for (final contact in result) {
          final totalAfterAdd =
              apiEmergencyContacts.length + selectedContacts.length;
          if (!existingIds.contains(contact.id) && totalAfterAdd < 3) {
            selectedContacts.add(contact);
          }
        }
      });
    }
  }

  // ── UI helpers ──────────────────────────────
  Widget _buildAvatar(String name, {Color? bgColor, Color? textColor}) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 11.w,
      height: 11.w,
      decoration: BoxDecoration(
        color: bgColor ?? _C.accentLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w700,
            color: textColor ?? _C.accent,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteBtn(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _C.dangerLight,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close_rounded, color: _C.danger, size: 18),
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
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: _C.accent.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
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
                        color: _C.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contact.phone ?? 'No number',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s9,
                        color: _C.textSecond,
                      ),
                    ),
                    if (contact.relationship != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _C.accentLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          contact.relationship!,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s7,
                            fontWeight: FontWeight.w600,
                            color: _C.accent,
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
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _C.accent.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _C.accent.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
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
                              color: _C.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
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
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s9,
                        color: _C.textSecond,
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
                color: _C.accentLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 9.w,
                color: _C.accent,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'No contacts yet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s13,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              'Add up to 3 trusted contacts who\nwill be notified in an emergency.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                color: _C.textSecond,
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
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _C.accent.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _C.accent.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: _C.iconBadge,
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
                      color: _C.textPrimary,
                    ),
                  ),
                  Text(
                    '${3 - (apiEmergencyContacts.length + selectedContacts.length)} slot(s) remaining',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s8,
                      color: _C.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: _C.accent, size: 4.w),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalContacts = apiEmergencyContacts.length + selectedContacts.length;

    return WillPopScope(
      onWillPop: () async {
        Get.back(result: selectedContacts);
        return true;
      },
      child: Scaffold(
        backgroundColor: _C.bg,
        appBar: AppBar(
          backgroundColor: _C.bg,
          scrolledUnderElevation: 0,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: _C.textPrimary),
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
              color: _C.textPrimary,
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 4.w),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: _C.iconBadge,
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
            child: Container(
              height: 1,
              color: _C.textPrimary.withValues(alpha: 0.06),
            ),
          ),
        ),
        body: Column(
          children: [
            // Counter header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
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
                            color: _C.textPrimary,
                          ),
                        ),
                        SizedBox(height: 0.3.h),
                        Text(
                          'They will be notified in case of emergency',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s9,
                            color: _C.textSecond,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: totalContacts >= 3
                          ? const Color(0xFFFFF3BF)
                          : _C.accentLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          totalContacts >= 3
                              ? Icons.lock_outline_rounded
                              : Icons.person_outline_rounded,
                          size: 14,
                          color: totalContacts >= 3
                              ? const Color(0xFFE67700)
                              : _C.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$totalContacts / 3',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s10,
                            fontWeight: FontWeight.w700,
                            color: totalContacts >= 3
                                ? const Color(0xFFE67700)
                                : _C.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: totalContacts / 3,
                  minHeight: 6,
                  backgroundColor: _C.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    totalContacts >= 3 ? const Color(0xFFFAB005) : _C.accent,
                  ),
                ),
              ),
            ),

            SizedBox(height: 1.5.h),

            // Contact list
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: _C.accent,
                        strokeWidth: 2.5,
                      ),
                    )
                  : (apiEmergencyContacts.isEmpty && selectedContacts.isEmpty)
                  ? _buildEmptyState()
                  : ListView(
                      padding: EdgeInsets.only(
                        left: 5.w,
                        right: 5.w,
                        top: 1.h,
                        bottom: selectedContacts.isNotEmpty ? 14.h : 3.h,
                      ),
                      children: [
                        // Saved contacts
                        if (apiEmergencyContacts.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'SAVED CONTACTS',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s8,
                                fontWeight: FontWeight.w700,
                                color: _C.textMuted,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          ...apiEmergencyContacts.asMap().entries.map(
                            (e) => _buildApiContactCard(e.value, e.key),
                          ),
                        ],

                        // Pending contacts
                        if (selectedContacts.isNotEmpty) ...[
                          if (apiEmergencyContacts.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: _C.border,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'TO BE SAVED',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: FontSize.s8,
                                        fontWeight: FontWeight.w700,
                                        color: _C.textMuted,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: _C.border,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                'NEW CONTACTS',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: FontSize.s8,
                                  fontWeight: FontWeight.w700,
                                  color: _C.textMuted,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ...selectedContacts.asMap().entries.map(
                            (e) => _buildPendingContactCard(e.value, e.key),
                          ),
                        ],

                        // Add more button
                        if (totalContacts < 3) _buildAddMoreButton(),
                      ],
                    ),
            ),
          ],
        ),

        // Floating save button
        bottomNavigationBar: selectedContacts.isNotEmpty
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _C.cardBg,
                  boxShadow: [
                    BoxShadow(
                      color: CommonColors.blackColor.withValues(alpha: 0.08),
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
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: _C.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Text(
                        '${selectedContacts.length} contact(s) ready to save',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s9,
                          color: _C.textSecond,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      CommonButton(
                        text: 'Save Emergency Contacts',
                        onPressed: () {
                          if (!isLoading) _saveEmergencyContacts();
                        },
                        gradient: CommonColors.btnGradient,
                        textColor: CommonColors.whiteColor,
                        fontWeight: FontWeight.w700,
                        fontSize: FontSize.s12,
                        height: 6.h,
                        isDisabled: isLoading,
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
