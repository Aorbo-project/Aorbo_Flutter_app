import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../models/emergency_contact_model.dart';
import '../repository/network_url.dart';
import '../repository/repository.dart';
import '../utils/common_btn.dart';
import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';

String _normalizePhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
}

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF5F8FF);
  static const cardBg = Colors.white;
  static const ink = Color(0xFF111827);
  static const inkMid = Color(0xFF6B7280);
  static const inkLight = Color(0xFF9CA3AF);
  static const teal = Color(0xFF0F7B6C);
  static const tealSoft = Color(0xFFE6F5F3);
  static const fieldBorder = Color(0xFFE5E7EB);
  static const iconBadgeBg = Color(0xFF111827);
  static const danger = Color(0xFFEF4444);
  static const divider = Color(0xFFE5E7EB);
  static const warn = Color(0xFFE67700);
  static const ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
  );
}

/// Explicit permission state — no more guessing from an empty list (FIX).
enum _PermState { checking, granted, denied, permanentlyDenied }

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen>
    with WidgetsBindingObserver {
  final Repository _repository = Repository();
  final TextEditingController _searchController = TextEditingController();

  List<Contact> _allContacts = [];
  List<Contact> _filtered = [];
  final List<Contact> _selected = [];
  final Set<String> _selectedIds = {};

  int _maxSelectable = 3;
  Set<String> _existingPhones = {};

  _PermState _permState = _PermState.checking;
  bool _isLoading = true;
  bool _wentToSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_filterContacts);
    _parseArguments();
    _fetchContacts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.removeListener(_filterContacts);
    _searchController.dispose();
    super.dispose();
  }

  /// Re-check permission when returning from app settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _wentToSettings) {
      _wentToSettings = false;
      _fetchContacts();
    }
  }

  // ── Arguments ─────────────────────────────────────────────────────────

  void _parseArguments() {
    final args = Get.arguments;
    if (args is Map) {
      _maxSelectable = (args['maxSelectable'] as int?) ?? 3;
      _existingPhones = Set<String>.from(
        args['existingPhones'] as List? ?? const [],
      );
    } else {
      // Legacy fallback: opened without arguments — derive limits from API.
      _loadLimitsFromApi();
    }
  }

  Future<void> _loadLimitsFromApi() async {
    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.emergencyContacts,
      );
      if (response != null && mounted) {
        final r = EmergencyContactResponse.fromJson(response);
        if (r.success == true) {
          final saved = r.data ?? [];
          setState(() {
            _maxSelectable = (3 - saved.length).clamp(0, 3);
            _existingPhones = saved
                .map((c) => _normalizePhone(c.phone ?? ''))
                .where((p) => p.isNotEmpty)
                .toSet();
            // If loading finished first, prune selections that are now invalid.
            _selected.removeWhere(
              (c) => _existingPhones.contains(
                _normalizePhone(
                  c.phones.isNotEmpty ? c.phones.first.number : '',
                ),
              ),
            );
            while (_selected.length > _maxSelectable) {
              final removed = _selected.removeLast();
              _selectedIds.remove(removed.id);
            }
          });
        }
      }
    } catch (e) {
      log('_loadLimitsFromApi failed: $e');
    }
  }

  // ── Contacts + permission ─────────────────────────────────────────────

  Future<void> _fetchContacts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _permState = _PermState.checking;
    });

    final status = await Permission.contacts.request();

    if (!mounted) return;
    if (status.isPermanentlyDenied) {
      setState(() {
        _permState = _PermState.permanentlyDenied;
        _isLoading = false;
      });
      return;
    }
    if (!status.isGranted) {
      setState(() {
        _permState = _PermState.denied;
        _isLoading = false;
      });
      return;
    }

    try {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      if (!mounted) return;
      setState(() {
        _permState = _PermState.granted;
        _allContacts = contacts.where((c) => c.phones.isNotEmpty).toList()
          ..sort(
            (a, b) => a.displayName.toLowerCase().compareTo(
              b.displayName.toLowerCase(),
            ),
          );
        _isLoading = false;
      });
      _filterContacts();
    } catch (e) {
      log('_fetchContacts failed: $e');
      if (mounted) {
        setState(() {
          _permState = _PermState.granted;
          _isLoading = false;
        });
      }
    }
  }

  void _openSettings() {
    _wentToSettings = true;
    openAppSettings();
  }

  // ── Search ────────────────────────────────────────────────────────────

  void _filterContacts() {
    if (!mounted) return;
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? List.from(_allContacts)
          : _allContacts.where((contact) {
              final name = contact.displayName.toLowerCase();
              final phones = contact.phones
                  .map((p) => _normalizePhone(p.number))
                  .join(' ');
              return name.contains(query) ||
                  phones.contains(query.replaceAll(RegExp(r'\D'), ''));
            }).toList();
    });
  }

  // ── Selection ─────────────────────────────────────────────────────────

  bool _isAlreadySaved(Contact contact) {
    final phone = contact.phones.isNotEmpty
        ? _normalizePhone(contact.phones.first.number)
        : '';
    return phone.isNotEmpty && _existingPhones.contains(phone);
  }

  void _toggleSelection(Contact contact) {
    if (_isAlreadySaved(contact)) {
      _showSnack('This number is already an emergency contact.', isError: true);
      return;
    }
    setState(() {
      if (_selectedIds.contains(contact.id)) {
        _selectedIds.remove(contact.id);
        _selected.removeWhere((c) => c.id == contact.id);
        return;
      }
      if (_selected.length >= _maxSelectable) {
        _showSnack(
          'You can add $_maxSelectable more contact${_maxSelectable == 1 ? '' : 's'} only.',
          isError: true,
        );
        return;
      }
      // Also block duplicate numbers within the current selection.
      final phone = _normalizePhone(contact.phones.first.number);
      final alreadyPicked = _selected.any(
        (c) =>
            _normalizePhone(c.phones.isNotEmpty ? c.phones.first.number : '') ==
            phone,
      );
      if (alreadyPicked) {
        _showSnack(
          'A contact with this number is already selected.',
          isError: true,
        );
        return;
      }
      _selectedIds.add(contact.id);
      _selected.add(contact);
    });
  }

  void _confirmSelection() {
    Get.back(result: List<Contact>.from(_selected));
  }

  // ── Snack ─────────────────────────────────────────────────────────────

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
                    color: Colors.white,
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

  // ── UI helpers ────────────────────────────────────────────────────────

  Widget _avatar(String name, {required bool isSelected}) {
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
          name.isNotEmpty ? name[0].toUpperCase() : '?',
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

  Widget _selectionIndicator(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 6.w,
      height: 6.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? _C.teal : Colors.transparent,
        border: Border.all(color: isSelected ? _C.teal : _C.inkLight, width: 2),
      ),
      child: isSelected
          ? Icon(Icons.check_rounded, color: Colors.white, size: 3.5.w)
          : null,
    );
  }

  Widget _contactTile(Contact contact) {
    final phone = contact.phones.first.number;
    final isSelected = _selectedIds.contains(contact.id);
    final alreadySaved = _isAlreadySaved(contact);

    return AnimatedContainer(
      key: ValueKey(contact.id),
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: alreadySaved
            ? _C.cardBg.withValues(alpha: 0.6)
            : isSelected
            ? _C.tealSoft
            : _C.cardBg,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: isSelected ? _C.teal.withValues(alpha: 0.4) : _C.fieldBorder,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: alreadySaved ? null : () => _toggleSelection(contact),
        borderRadius: BorderRadius.circular(3.w),
        splashColor: _C.teal.withValues(alpha: 0.08),
        child: Opacity(
          opacity: alreadySaved ? 0.55 : 1,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
            child: Row(
              children: [
                _avatar(contact.displayName, isSelected: isSelected),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                                ? _C.teal.withValues(alpha: 0.7)
                                : _C.inkLight,
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              phone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s9,
                                color: isSelected
                                    ? _C.teal.withValues(alpha: 0.7)
                                    : _C.inkMid,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (alreadySaved)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _C.tealSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Added',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s8,
                        fontWeight: FontWeight.w700,
                        color: _C.teal,
                      ),
                    ),
                  )
                else
                  _selectionIndicator(isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
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
            child: Icon(Icons.search_off_rounded, size: 9.w, color: _C.teal),
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
            _allContacts.isEmpty
                ? 'No contacts with phone numbers on this device'
                : 'Try a different name or number',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s9,
              color: _C.inkMid,
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionState() {
    final isPermanent = _permState == _PermState.permanentlyDenied;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: _C.danger.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.contacts_outlined, size: 9.w, color: _C.danger),
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
              isPermanent
                  ? 'Permission was denied permanently.\nEnable Contacts access in app settings.'
                  : 'Please allow access to your contacts\nto add emergency contacts.',
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
              onTap: isPermanent ? _openSettings : _fetchContacts,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.4.h),
                decoration: BoxDecoration(
                  color: _C.teal,
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Text(
                  isPermanent ? 'Open Settings' : 'Grant Permission',
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

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final slotsLeft = _maxSelectable - _selected.length;

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
          onPressed: Get.back, // back = cancel; Done returns the selection
        ),
        title: Text(
          'Select Contacts',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w700,
            color: _C.ink,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.divider),
        ),
      ),
      body: Column(
        children: [
          // ── Search + slot info ─────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _C.cardBg,
                    borderRadius: BorderRadius.circular(3.w),
                    border: Border.all(color: _C.fieldBorder),
                  ),
                  child: TextField(
                    controller: _searchController,
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
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: _C.inkLight,
                                size: 4.5.w,
                              ),
                              onPressed: _searchController.clear,
                            )
                          : null,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                  ),
                ),
                SizedBox(height: 1.5.h),
                Row(
                  children: [
                    ...List.generate(_maxSelectable.clamp(0, 3), (i) {
                      final filled = i < _selected.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        width: filled ? 20 : 10,
                        height: 8,
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
                          color: slotsLeft == 0 ? _C.warn : _C.inkMid,
                        ),
                      ),
                    ),
                    if (_selected.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _C.tealSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_selected.length} selected',
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

          // ── List / states ──────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: _C.teal,
                      strokeWidth: 2.5,
                    ),
                  )
                : _permState != _PermState.granted
                ? _permissionState()
                : _filtered.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: EdgeInsets.only(
                      left: 4.w,
                      right: 4.w,
                      top: 1.h,
                      bottom: _selected.isNotEmpty ? 16.h : 3.h,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) =>
                        _contactTile(_filtered[index]),
                  ),
          ),
        ],
      ),

      // ── Done button — returns the selection, never navigates forward ──
      bottomNavigationBar: _selected.isNotEmpty
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: (_selected.length * 18.0) + 14,
                          height: 30,
                          child: Stack(
                            children: _selected
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
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '${_selected.length} contact${_selected.length == 1 ? '' : 's'} selected',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s9,
                            color: _C.inkMid,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    CommonButton(
                      text: 'Done',
                      onPressed: _confirmSelection,
                      gradient: _C.ctaGradient,
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
