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
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF4F7FF);
  static const cardBg = Color(0xFFFFFFFF);
  static const accent = Color(0xFF3B5BDB);
  static const accentLight = Color(0xFFEEF2FF);
  static const textPrimary = Color(0xFF1A1D2E);
  static const textSecond = Color(0xFF6C7293);
  static const textMuted = Color(0xFFADB5BD);
  static const border = Color(0xFFE9ECEF);
}

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  _EmergencyContactsScreenState createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen>
    with SingleTickerProviderStateMixin {
  List<Contact> allContacts = [];
  List<Contact> filteredContacts = [];
  List<Contact> selectedContacts = [];
  List<EmergencyContact> apiEmergencyContacts = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  final Repository _repository = Repository();

  // ── ALL ORIGINAL LOGIC ──────────────────────
  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments;
    if (arguments != null && arguments is List<Contact>) {
      selectedContacts = List.from(arguments);
    }
    _loadApiEmergencyContacts();
    fetchContacts();
    searchController.addListener(filterContacts);
  }

  Future<void> _loadApiEmergencyContacts() async {
    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.emergencyContacts,
      );
      if (response != null) {
        final contactResponse = EmergencyContactResponse.fromJson(response);
        if (contactResponse.success == true) {
          setState(() {
            apiEmergencyContacts = contactResponse.data ?? [];
          });
        }
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> fetchContacts() async {
    final status = await Permission.contacts.status;
    if (!status.isGranted) {
      final result = await Permission.contacts.request();
      if (!result.isGranted) {
        setState(() => isLoading = false);
        _showSnack('Contact permission denied', isError: true);
        return;
      }
    }
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    setState(() {
      allContacts = contacts.where((c) => c.phones.isNotEmpty).toList();
      filteredContacts = allContacts;
      isLoading = false;
    });
  }

  void filterContacts() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredContacts = allContacts.where((contact) {
        final name = contact.displayName.toLowerCase();
        final phones = contact.phones.map((p) => p.number).join().toLowerCase();
        return name.contains(query) || phones.contains(query);
      }).toList();
    });
  }

  void toggleSelection(Contact contact) {
    setState(() {
      if (selectedContacts.contains(contact)) {
        selectedContacts.remove(contact);
      } else {
        final total = apiEmergencyContacts.length + selectedContacts.length;
        if (total < 3) {
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
        backgroundColor: isError ? const Color(0xFFE03131) : _C.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      ),
    );
  }

  // ── UI helpers ──────────────────────────────
  Widget _buildAvatar(String name, {bool isSelected = false}) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 11.w,
      height: 11.w,
      decoration: BoxDecoration(
        color: isSelected ? _C.accent : _C.accentLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : _C.accent,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? _C.accent : Colors.transparent,
        border: Border.all(
          color: isSelected ? _C.accent : _C.textMuted,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
          : null,
    );
  }

  Widget _buildContactTile(Contact contact, int index) {
    final phone = contact.phones.isNotEmpty
        ? contact.phones.first.number
        : 'No number';
    final isSelected = selectedContacts.contains(contact);

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
          color: isSelected ? _C.accentLight : _C.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _C.accent.withValues(alpha: 0.4) : _C.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _C.accent.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: InkWell(
          onTap: () => toggleSelection(contact),
          borderRadius: BorderRadius.circular(16),
          splashColor: _C.accent.withValues(alpha: 0.08),
          highlightColor: _C.accent.withValues(alpha: 0.04),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
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
                          color: isSelected ? _C.accent : _C.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 11,
                            color: isSelected
                                ? _C.accent.withValues(alpha: 0.7)
                                : _C.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s9,
                              color: isSelected
                                  ? _C.accent.withValues(alpha: 0.7)
                                  : _C.textSecond,
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
                color: _C.accentLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 9.w,
                color: _C.accent,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'No contacts found',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s13,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              'Try a different name or number',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                color: _C.textSecond,
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
              decoration: const BoxDecoration(
                color: Color(0xFFFFF5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.contacts_outlined,
                size: 9.w,
                color: const Color(0xFFE03131),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Contacts access needed',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s13,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              'Please allow access to your contacts to add emergency contacts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                color: _C.textSecond,
                height: 1.6,
              ),
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: fetchContacts,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Grant Permission',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: FontSize.s10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSelected = apiEmergencyContacts.length + selectedContacts.length;
    final slotsLeft = 3 - totalSelected;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.bg,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: _C.textPrimary),
        // FIX: back button returns selectedContacts to caller
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(result: selectedContacts),
        ),
        title: Text(
          'Select Contacts',
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
                backgroundColor: const Color(0xFF111827),
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
          // Search + info header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            color: _C.bg,
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: _C.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _C.border, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
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
                      color: _C.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by name or number…',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s10,
                        color: _C.textMuted,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: _C.textMuted,
                        size: 5.5.w,
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: _C.textMuted,
                                size: 4.5.w,
                              ),
                              onPressed: () {
                                searchController.clear();
                                filterContacts();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                  ),
                ),
                SizedBox(height: 1.5.h),

                // Slot info row
                Row(
                  children: [
                    Row(
                      children: List.generate(3, (i) {
                        final filled = i < totalSelected;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 6),
                          width: filled ? 20 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: filled ? _C.accent : _C.border,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 10),
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
                              : _C.textSecond,
                        ),
                      ),
                    ),
                    if (selectedContacts.isNotEmpty)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _C.accentLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${selectedContacts.length} selected',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s8,
                            fontWeight: FontWeight.w700,
                            color: _C.accent,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Contacts list
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: _C.accent,
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
                      bottom: selectedContacts.isNotEmpty ? 14.h : 3.h,
                    ),
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      return _buildContactTile(filteredContacts[index], index);
                    },
                  ),
          ),
        ],
      ),

      // Continue button
      // FIX: uses Get.toNamed (not offNamed) so pressing back from
      // SelectedEmergencyContactsScreen returns here correctly.
      bottomNavigationBar: selectedContacts.isNotEmpty
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
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
                        color: _C.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Stacked avatars
                        SizedBox(
                          width: selectedContacts.length > 1
                              ? (selectedContacts.length * 22.0).clamp(0, 66) +
                                    10
                              : 36,
                          height: 30,
                          child: Stack(
                            children: selectedContacts
                                .take(3)
                                .toList()
                                .asMap()
                                .entries
                                .map((e) {
                                  return Positioned(
                                    left: e.key * 18.0,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: _C.accent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _C.cardBg,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          e.value.displayName.isNotEmpty
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
                                  );
                                })
                                .toList(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${selectedContacts.length} contact${selectedContacts.length == 1 ? '' : 's'} selected',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s9,
                            color: _C.textSecond,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    // FIX: Get.toNamed instead of Get.offNamed
                    // so the back-stack is preserved and returning
                    // from SelectedEmergencyContactsScreen brings
                    // the user back here (or all the way to Safety).
                    CommonButton(
                      text: 'Continue  →',
                      onPressed: () async {
                        final result = await Get.toNamed(
                          '/selected-emergency-contacts',
                          arguments: selectedContacts,
                        );
                        if (result != null && result is List<Contact>) {
                          setState(() {
                            selectedContacts = List.from(result);
                          });
                        }
                      },
                      gradient: CommonColors.btnGradient,
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
