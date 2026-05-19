import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';
import '../utils/common_btn.dart';
import 'package:get/get.dart';
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
  static const divider     = Color(0xFFE5E7EB);
}

class _NInk {
  static const ink = Color(0xFF0F172A);
}

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen>
    with SingleTickerProviderStateMixin {
  List<Contact> allContacts      = [];
  List<Contact> filteredContacts = [];
  // Use a Set keyed on contact.id for O(1) lookup and to avoid
  // reference-equality issues when contacts come from arguments.
  final Set<String> _selectedIds = {};
  List<Contact> selectedContacts = [];

  List<EmergencyContact> apiEmergencyContacts = [];
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  final Repository _repository = Repository();

  @override
  void initState() {
    super.initState();

    // Restore previously selected contacts passed from caller
    final arguments = Get.arguments;
    if (arguments != null && arguments is List<Contact>) {
      selectedContacts = List.from(arguments);
      _selectedIds.addAll(selectedContacts.map((c) => c.id));
    }

    _loadApiEmergencyContacts();
    _fetchContacts();
    // Store the listener so we can remove it in dispose
    searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterContacts); // FIX: remove listener
    searchController.dispose();
    super.dispose();
  }

  // ── Data ────────────────────────────────────────────────────────────────────

  Future<void> _loadApiEmergencyContacts() async {
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
      log('_loadApiEmergencyContacts failed: $e');
    }
  }

  Future<void> _fetchContacts() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final status = await Permission.contacts.status;
    if (!status.isGranted) {
      final result = await Permission.contacts.request();
      if (!result.isGranted) {
        if (mounted) {
          setState(() => isLoading = false);
          _showSnack('Contact permission denied.', isError: true);
        }
        return;
      }
    }

    try {
      final contacts =
          await FlutterContacts.getContacts(withProperties: true);
      if (!mounted) return;
      setState(() {
        allContacts = contacts
            .where((c) => c.phones.isNotEmpty)
            .toList()
          ..sort((a, b) =>
              a.displayName.compareTo(b.displayName));
        filteredContacts = List.from(allContacts);
        isLoading = false;
      });
    } catch (e) {
      log('_fetchContacts failed: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _filterContacts() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredContacts = allContacts.where((contact) {
        final name   = contact.displayName.toLowerCase();
        final phones = contact.phones.map((p) => p.number).join().toLowerCase();
        return name.contains(query) || phones.contains(query);
      }).toList();
    });
  }

  /// Toggle using id-based set to avoid reference-equality issues.
  void _toggleSelection(Contact contact) {
    setState(() {
      if (_selectedIds.contains(contact.id)) {
        _selectedIds.remove(contact.id);
        selectedContacts.removeWhere((c) => c.id == contact.id);
      } else {
        final total =
            apiEmergencyContacts.length + selectedContacts.length;
        if (total < 3) {
          _selectedIds.add(contact.id);
          selectedContacts.add(contact);
        } else {
          _showSnack(
            'You can only have up to 3 emergency contacts total.',
            isError: true,
          );
        }
      }
    });
  }

  bool _isSelected(Contact contact) => _selectedIds.contains(contact.id);

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

  // ── UI helpers ──────────────────────────────────────────────────────────────

  Widget _buildAvatar(String name, {bool isSelected = false}) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 11.w,
      height: 11.w,
      decoration: BoxDecoration(
        color: isSelected ? _C.teal : _C.tealSoft,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : _C.teal,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 6.w,
      height: 6.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? _C.teal : Colors.transparent,
        border: Border.all(
          color: isSelected ? _C.teal : _C.inkLight,
          width: 2,
        ),
      ),
      child: isSelected
          ? Icon(Icons.check_rounded, color: Colors.white, size: 3.5.w)
          : null,
    );
  }

  Widget _buildContactTile(Contact contact, int index) {
    final phone = contact.phones.isNotEmpty
        ? contact.phones.first.number
        : 'No number';
    final isSelected = _isSelected(contact);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 200 + (index % 15) * 30),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: child,
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected ? _C.tealSoft : _C.cardBg,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color: isSelected
                ? _C.teal.withOpacity(0.4)
                : _C.fieldBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _C.teal.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: InkWell(
          onTap: () => _toggleSelection(contact),
          borderRadius: BorderRadius.circular(3.w),
          splashColor: _C.teal.withOpacity(0.08),
          highlightColor: _C.teal.withOpacity(0.04),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 1.4.h,
            ),
            child: Row(
              children: [
                _buildAvatar(contact.displayName, isSelected: isSelected),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.displayName,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? _C.teal : _C.ink,
                        ),
                      ),
                      SizedBox(height: 0.3.h),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: FontSize.s9,
                            color: isSelected
                                ? _C.teal.withOpacity(0.7)
                                : _C.inkLight,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            phone,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s9,
                              color: isSelected
                                  ? _C.teal.withOpacity(0.7)
                                  : _C.inkMid,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildSelectionIndicator(isSelected),
              ],
            ),
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
                color: _C.tealSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 9.w,
                color: _C.teal,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'No contacts found',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s13,
                fontWeight: FontWeight.w600,
                color: _C.ink,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              'Try a different name or number',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                color: _C.inkMid,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: _C.danger.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.contacts_outlined,
                size: 9.w,
                color: _C.danger,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Contacts access needed',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s13,
                fontWeight: FontWeight.w600,
                color: _C.ink,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              'Please allow access to your contacts\nto add emergency contacts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                color: _C.inkMid,
                height: 1.6,
              ),
            ),
            SizedBox(height: 2.h),
            GestureDetector(
              onTap: _fetchContacts,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                  vertical: 1.4.h,
                ),
                decoration: BoxDecoration(
                  color: _C.teal,
                  borderRadius: BorderRadius.circular(2.w),
                  boxShadow: [
                    BoxShadow(
                      color: _C.teal.withOpacity(0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Grant Permission',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: FontSize.s10,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final totalSelected =
        apiEmergencyContacts.length + selectedContacts.length;
    final slotsLeft = 3 - totalSelected;

    return Scaffold(
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
          // FIX: always return selectedContacts to caller
          onPressed: () => Get.back(result: selectedContacts),
        ),
        title: Text(
          'Select Contacts',
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
          // ── Search + slot info ─────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 2.h,
            ),
            color: _C.bg,
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: _C.cardBg,
                    borderRadius: BorderRadius.circular(3.w),
                    border: Border.all(color: _C.fieldBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s11,
                      color: _C.ink,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by name or number…',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s10,
                        color: _C.inkLight,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: _C.inkLight,
                        size: 5.5.w,
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: _C.inkLight,
                                size: 4.5.w,
                              ),
                              onPressed: () {
                                searchController.clear();
                                _filterContacts();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 1.5.h),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 1.5.h),

                // Slot info row
                Row(
                  children: [
                    ...List.generate(3, (i) {
                      final filled = i < totalSelected;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        width: filled ? 20 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: filled ? _C.teal : _C.fieldBorder,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        slotsLeft > 0
                            ? '$slotsLeft slot${slotsLeft == 1 ? '' : 's'} remaining'
                            : 'All slots filled',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s9,
                          fontWeight: FontWeight.w500,
                          color: slotsLeft == 0
                              ? const Color(0xFFE67700)
                              : _C.inkMid,
                        ),
                      ),
                    ),
                    if (selectedContacts.isNotEmpty)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _C.tealSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${selectedContacts.length} selected',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s8,
                            fontWeight: FontWeight.w700,
                            color: _C.teal,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ── Contacts list ──────────────────────────────────────────
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: _C.teal,
                      strokeWidth: 2.5,
                    ),
                  )
                : allContacts.isEmpty
                    ? _buildPermissionState()
                    : filteredContacts.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.only(
                              left: 4.w,
                              right: 4.w,
                              top: 1.h,
                              bottom: selectedContacts.isNotEmpty
                                  ? 14.h
                                  : 3.h,
                            ),
                            itemCount: filteredContacts.length,
                            itemBuilder: (context, index) =>
                                _buildContactTile(
                              filteredContacts[index],
                              index,
                            ),
                          ),
          ),
        ],
      ),

      // ── Continue button ────────────────────────────────────────────
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
                    color: Colors.black.withOpacity(0.08),
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
                    // Stacked avatars + count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: selectedContacts.length > 1
                              ? (selectedContacts.length * 22.0)
                                      .clamp(0, 66) +
                                  10
                              : 36,
                          height: 30,
                          child: Stack(
                            children: selectedContacts
                                .take(3)
                                .toList()
                                .asMap()
                                .entries
                                .map(
                                  (e) => Positioned(
                                    left: e.key * 18.0,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: _C.teal,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _C.cardBg,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          e.value.displayName
                                                  .isNotEmpty
                                              ? e.value.displayName[0]
                                                  .toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '${selectedContacts.length} contact${selectedContacts.length == 1 ? '' : 's'} selected',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s9,
                            color: _C.inkMid,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    // FIX: Get.toNamed (not offNamed) — preserves back-stack.
                    // Result flows back here so selectedContacts stays in sync.
                    CommonButton(
                      text: 'Continue  →',
                      onPressed: () async {
                        final result = await Get.toNamed(
                          '/selected-emergency-contacts',
                          arguments: selectedContacts,
                        );
                        if (result != null &&
                            result is List<Contact> &&
                            mounted) {
                          setState(() {
                            selectedContacts = List.from(result);
                            _selectedIds
                              ..clear()
                              ..addAll(
                                selectedContacts.map((c) => c.id),
                              );
                          });
                        }
                      },
                      gradient: CommonColors.filterGradient,
                      textColor: CommonColors.whiteColor,
                      fontWeight: FontWeight.w700,
                      fontSize: FontSize.s12,
                      height: 6.h,
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
