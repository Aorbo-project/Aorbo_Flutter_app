import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../models/emergency_contact_model.dart';
import '../repository/network_url.dart';
import '../repository/repository.dart';
import '../utils/common_btn.dart';
import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';

// ─────────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────────
const int kMaxEmergencyContacts = 3;

const List<String> kRelationships = [
  'Family',
  'Parent',
  'Sibling',
  'Spouse',
  'Friend',
  'Colleague',
  'Other',
];

/// Normalizes a phone for duplicate comparison:
/// strips everything non-digit, keeps the last 10 digits.
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
  static const fieldBg = Color(0xFFF9FAFB);
  static const fieldBorder = Color(0xFFE5E7EB);
  static const iconBadgeBg = Color(0xFF111827);
  static const danger = Color(0xFFEF4444);
  static const divider = Color(0xFFE5E7EB);
  static const warnBg = Color(0xFFFFF3BF);
  static const warn = Color(0xFFE67700);
  static const ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
  );
}

class SelectedEmergencyContactsScreen extends StatefulWidget {
  const SelectedEmergencyContactsScreen({super.key});

  @override
  State<SelectedEmergencyContactsScreen> createState() =>
      _SelectedEmergencyContactsScreenState();
}

class _SelectedEmergencyContactsScreenState
    extends State<SelectedEmergencyContactsScreen> {
  final Repository _repository = Repository();

  List<EmergencyContact> _saved = [];
  final List<Contact> _pending = [];
  final Map<String, String> _relationships = {}; // contact.id → relationship

  bool _isLoading = true;
  bool _isSaving = false;
  bool _allowPop = false;

  int get _total => _saved.length + _pending.length;
  int get _slotsLeft => kMaxEmergencyContacts - _total;

  /// All phone numbers currently in use (saved + pending), normalized.
  Set<String> get _usedPhones {
    final set = <String>{
      ..._saved.map((c) => _normalizePhone(c.phone ?? '')),
      ..._pending.map(
        (c) =>
            _normalizePhone(c.phones.isNotEmpty ? c.phones.first.number : ''),
      ),
    };
    set.remove('');
    return set;
  }

  @override
  void initState() {
    super.initState();
    // Backward-compatible: accept a preselected list, dedupe safely.
    final args = Get.arguments;
    if (args is List<Contact>) {
      for (final c in args) {
        _tryAddPending(c);
      }
    }
    _loadSaved();
  }

  // ── Data ──────────────────────────────────────────────────────────────

  bool _tryAddPending(Contact c) {
    final phone = c.phones.isNotEmpty
        ? _normalizePhone(c.phones.first.number)
        : '';
    if (phone.isEmpty) return false; // no usable number
    if (_usedPhones.contains(phone)) return false; // duplicate
    if (_total >= kMaxEmergencyContacts) return false;
    _pending.add(c);
    _relationships.putIfAbsent(c.id, () => 'Family');
    return true;
  }

  Future<void> _loadSaved() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.emergencyContacts,
      );
      if (response != null && mounted) {
        final r = EmergencyContactResponse.fromJson(response);
        if (r.success == true) {
          _saved = r.data ?? [];
          // FIX (race + duplicates): once the server list arrives,
          // drop pending items whose number is already saved, and trim
          // any overflow beyond the 3-slot limit.
          final savedPhones = _saved
              .map((c) => _normalizePhone(c.phone ?? ''))
              .toSet();
          _pending.removeWhere(
            (c) => savedPhones.contains(
              _normalizePhone(c.phones.isNotEmpty ? c.phones.first.number : ''),
            ),
          );
          while (_total > kMaxEmergencyContacts && _pending.isNotEmpty) {
            _pending.removeLast();
          }
        }
      }
    } catch (e) {
      log('_loadSaved failed: $e');
      if (mounted) {
        _showSnack(
          'Could not load saved contacts. Pull down to retry.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Saves pending contacts one by one. Successfully saved contacts are
  /// removed from the pending list immediately, so a partial failure never
  /// desyncs UI and server (FIX for the break-and-clear-all bug).
  Future<void> _savePending() async {
    if (_isSaving || _pending.isEmpty) return;
    setState(() => _isSaving = true);

    int savedCount = 0;
    final failures = <String>[];
    final queue = List<Contact>.from(_pending);

    for (final contact in queue) {
      final phone = contact.phones.isNotEmpty
          ? contact.phones.first.number.trim()
          : '';
      if (phone.isEmpty) {
        failures.add(contact.displayName);
        continue;
      }
      try {
        final response = await _repository.postApiCall(
          url: NetworkUrl.emergencyContacts,
          body: {
            'name': contact.displayName.trim(),
            'phone': phone,
            // FIX: real relationship instead of duplicating the name.
            'relationship': _relationships[contact.id] ?? 'Family',
          },
        );
        final ok =
            response != null &&
            EmergencyContactCreateResponse.fromJson(response).success == true;
        if (ok) {
          savedCount++;
          _pending.removeWhere((c) => c.id == contact.id);
          _relationships.remove(contact.id);
          if (mounted) setState(() {}); // live progress
        } else {
          failures.add(contact.displayName);
        }
      } catch (e) {
        log('save failed for ${contact.displayName}: $e');
        failures.add(contact.displayName);
      }
    }

    await _loadSaved();
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (failures.isEmpty) {
      _showSnack(
        '$savedCount contact${savedCount == 1 ? '' : 's'} saved successfully',
      );
    } else if (savedCount > 0) {
      _showSnack(
        '$savedCount saved. Failed: ${failures.join(', ')}',
        isError: true,
      );
    } else {
      _showSnack(
        'Could not save. Please check your connection and retry.',
        isError: true,
      );
    }
  }

  Future<void> _deleteSaved(int id) async {
    try {
      final response = await _repository.deleteApiCall(
        url: NetworkUrl.deleteEmergencyContact(id),
      );
      if (!mounted) return;
      if (response != null) {
        final r = EmergencyContactDeleteResponse.fromJson(response);
        if (r.success == true) {
          setState(() => _saved.removeWhere((c) => c.id == id));
          _showSnack(r.message ?? 'Contact removed');
        } else {
          _showSnack(r.message ?? 'Could not delete contact', isError: true);
        }
      }
    } catch (e) {
      log('_deleteSaved failed: $e');
      if (mounted) {
        _showSnack('Failed to delete. Please try again.', isError: true);
      }
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────

  /// Opens the picker and awaits the result — no forward navigation,
  /// no route-stack loops (FIX).
  Future<void> _openPicker() async {
    if (_slotsLeft <= 0) {
      _showSnack(
        'Maximum $kMaxEmergencyContacts emergency contacts allowed.',
        isError: true,
      );
      return;
    }
    final result = await Get.toNamed(
      '/emergency-contacts',
      arguments: {
        'maxSelectable': _slotsLeft,
        'existingPhones': _usedPhones.toList(),
      },
    );
    if (result is List<Contact> && mounted) {
      setState(() {
        for (final c in result) {
          _tryAddPending(c);
        }
      });
    }
  }

  void _leaveScreen() {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
  }

  void _onPopAttempt() {
    if (_pending.isEmpty) {
      _leaveScreen();
      return;
    }
    // FIX: unsaved selections are no longer silently discarded.
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _C.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.w)),
        title: Text(
          'Discard unsaved contacts?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s13,
            fontWeight: FontWeight.w700,
            color: _C.ink,
          ),
        ),
        content: Text(
          'You have ${_pending.length} contact${_pending.length == 1 ? '' : 's'} that '
          'haven\'t been saved yet. Leaving now will discard them.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s10,
            color: _C.inkMid,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep editing',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                fontWeight: FontWeight.w600,
                color: _C.teal,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _leaveScreen();
            },
            child: Text(
              'Discard',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                fontWeight: FontWeight.w600,
                color: _C.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Relationship picker ───────────────────────────────────────────────

  void _pickRelationship(Contact contact) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _C.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 10.w,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: _C.fieldBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                'Relationship with ${contact.displayName}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w700,
                  color: _C.ink,
                ),
              ),
              SizedBox(height: 2.h),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kRelationships.map((rel) {
                  final selected = _relationships[contact.id] == rel;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _relationships[contact.id] = rel);
                      Navigator.pop(ctx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? _C.teal : _C.fieldBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? _C.teal : _C.fieldBorder,
                        ),
                      ),
                      child: Text(
                        rel,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s10,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : _C.inkMid,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
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

  // ── Delete confirmation ───────────────────────────────────────────────

  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
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
              Row(
                children: [
                  Container(
                    width: 11.w,
                    height: 11.w,
                    decoration: BoxDecoration(
                      color: _C.danger.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: _C.danger,
                      size: FontSize.s14,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Delete Contact',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s13,
                        fontWeight: FontWeight.w700,
                        color: _C.ink,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),
              Text(
                '"$name" will be permanently removed from your emergency '
                'contacts and cannot be recovered.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s9,
                  color: _C.inkMid,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 2.5.h),
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
                        _deleteSaved(id);
                      },
                      child: Container(
                        height: 5.5.h,
                        decoration: BoxDecoration(
                          color: _C.danger,
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        child: Center(
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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

  // ── UI helpers ────────────────────────────────────────────────────────

  Widget _avatar(String name) {
    return Container(
      width: 11.w,
      height: 11.w,
      decoration: const BoxDecoration(
        color: _C.tealSoft,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
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

  Widget _removeButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 9.w,
        height: 9.w,
        decoration: BoxDecoration(
          color: _C.danger.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close_rounded, color: _C.danger, size: FontSize.s12),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h, top: 0.5.h),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s8,
          fontWeight: FontWeight.w700,
          color: _C.inkLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _savedCard(EmergencyContact contact) {
    final name = contact.name ?? 'Unknown';
    return Container(
      key: ValueKey('saved-${contact.id}'),
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
          _avatar(name),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                if (contact.relationship?.isNotEmpty == true) ...[
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
          _removeButton(() {
            if (contact.id != null) {
              _confirmDelete(contact.id!, name);
            }
          }),
        ],
      ),
    );
  }

  Widget _pendingCard(Contact contact) {
    final phone = contact.phones.isNotEmpty
        ? contact.phones.first.number
        : 'No number';
    final relationship = _relationships[contact.id] ?? 'Family';

    return Container(
      key: ValueKey('pending-${contact.id}'),
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: _C.teal.withValues(alpha: 0.25), width: 1.2),
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
          _avatar(contact.displayName),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                        color: _C.warnBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Pending',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s7,
                          fontWeight: FontWeight.w600,
                          color: _C.warn,
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
                SizedBox(height: 0.6.h),
                // Tappable relationship chip
                GestureDetector(
                  onTap: () => _pickRelationship(contact),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.5.w,
                      vertical: 0.4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _C.tealSoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _C.teal.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          relationship,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s8,
                            fontWeight: FontWeight.w600,
                            color: _C.teal,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Icon(
                          Icons.edit_outlined,
                          size: FontSize.s8,
                          color: _C.teal,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          _removeButton(
            () => setState(() {
              _pending.removeWhere((c) => c.id == contact.id);
              _relationships.remove(contact.id);
            }),
          ),
        ],
      ),
    );
  }

  Widget _addContactCard() {
    return GestureDetector(
      onTap: _isSaving ? null : _openPicker,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(color: _C.teal.withValues(alpha: 0.3), width: 1.5),
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
                    '$_slotsLeft slot${_slotsLeft == 1 ? '' : 's'} remaining',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s8,
                      color: _C.inkLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: _C.teal, size: 4.w),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      children: [
        SizedBox(height: 6.h),
        Center(
          child: Column(
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
                'Add up to $kMaxEmergencyContacts trusted contacts who\nwill be notified in an emergency.',
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
        SizedBox(height: 3.h),
        _addContactCard(),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onPopAttempt();
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
            onPressed: _onPopAttempt,
          ),
          title: Text(
            'Emergency Contacts',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s14,
              fontWeight: FontWeight.w700,
              color: _C.ink,
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
            // ── Counter header ─────────────────────────────────────
            Padding(
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
                      color: _total >= kMaxEmergencyContacts
                          ? _C.warnBg
                          : _C.tealSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _total >= kMaxEmergencyContacts
                              ? Icons.lock_outline_rounded
                              : Icons.person_outline_rounded,
                          size: FontSize.s10,
                          color: _total >= kMaxEmergencyContacts
                              ? _C.warn
                              : _C.teal,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '$_total / $kMaxEmergencyContacts',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s10,
                            fontWeight: FontWeight.w700,
                            color: _total >= kMaxEmergencyContacts
                                ? _C.warn
                                : _C.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Animated progress bar ──────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _total / kMaxEmergencyContacts),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: _C.fieldBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _total >= kMaxEmergencyContacts
                          ? const Color(0xFFFAB005)
                          : _C.teal,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 1.5.h),

            // ── Content ────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: _C.teal,
                        strokeWidth: 2,
                      ),
                    )
                  : RefreshIndicator(
                      color: _C.teal,
                      onRefresh: _loadSaved,
                      child: (_saved.isEmpty && _pending.isEmpty)
                          ? _emptyState()
                          : ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.only(
                                left: 5.w,
                                right: 5.w,
                                top: 1.h,
                                bottom: _pending.isNotEmpty ? 16.h : 3.h,
                              ),
                              children: [
                                if (_saved.isNotEmpty) ...[
                                  _sectionLabel('SAVED CONTACTS'),
                                  ..._saved.map(_savedCard),
                                ],
                                if (_pending.isNotEmpty) ...[
                                  _sectionLabel('TO BE SAVED'),
                                  ..._pending.map(_pendingCard),
                                ],
                                if (_slotsLeft > 0) _addContactCard(),
                              ],
                            ),
                    ),
            ),
          ],
        ),

        // ── Save bar (only when there is something to save) ────────
        bottomNavigationBar: _pending.isNotEmpty
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
                      Text(
                        '${_pending.length} contact${_pending.length == 1 ? '' : 's'} ready to save',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s9,
                          color: _C.inkMid,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      CommonButton(
                        text: _isSaving ? 'Saving…' : 'Save Emergency Contacts',
                        onPressed: _savePending, // guarded internally
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
