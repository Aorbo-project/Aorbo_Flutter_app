// ─────────────────────────────────────────────────────────────────────────
//  safety_hub_screen.dart
//
//  Safety hub + Emergency-contact manager + Device-contact picker,
//  merged into ONE file using stacked modal bottom sheets:
//
//      SafetyScreen (route)
//        └── _ManagerSheet   (modal sheet, non-dismissible, guards unsaved)
//              └── _PickerSheet (modal sheet, returns List<Contact>)
//                    └── relationship chip sheet (inline)
// ─────────────────────────────────────────────────────────────────────────

import 'dart:async';
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
import '../utils/common_images.dart';
import '../utils/common_safety_card.dart';
import '../utils/screen_constants.dart';

// ═════════════════════════════════════════════════════════════ CONSTANTS ═

const int _kMaxContacts = 3;

const List<String> _kRelationships = [
  'Family',
  'Parent',
  'Sibling',
  'Spouse',
  'Friend',
  'Colleague',
  'Other',
];

/// Strips non-digits, keeps the last 10 digits — used everywhere a phone
/// number is compared, so "+91 98765-43210" == "9876543210".
String _normalizePhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
}

String _firstPhoneOf(Contact c) =>
    c.phones.isNotEmpty ? c.phones.first.number : '';

// ═══════════════════════════════════════════════════════ DESIGN TOKENS ═══

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

/// Compact Poppins TextStyle factory — kills ~400 lines of repetition.
TextStyle _ts(
  double size, {
  FontWeight w = FontWeight.w400,
  Color c = _C.ink,
  double? h,
  double? ls,
}) => TextStyle(
  fontFamily: 'Poppins',
  fontSize: size,
  fontWeight: w,
  color: c,
  height: h,
  letterSpacing: ls,
);

/// Snackbar shown through a *sheet-local* messenger so it renders inside
/// the sheet instead of behind the modal barrier.
void _snack(ScaffoldMessengerState? m, String message, {bool isError = false}) {
  if (m == null) return;
  m
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
              child: Text(message, style: _ts(FontSize.s10, c: Colors.white)),
            ),
          ],
        ),
        backgroundColor: isError ? _C.danger : _C.teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
        margin: EdgeInsets.all(4.w),
      ),
    );
}

// ═════════════════════════════════════════════════════ SHARED WIDGETS ═══

Widget _initialAvatar(String name, {bool selected = false, double? size}) {
  final s = size ?? 11.w;
  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: s,
    height: s,
    decoration: BoxDecoration(
      color: selected ? _C.teal : _C.tealSoft,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: _ts(
          FontSize.s14,
          w: FontWeight.w700,
          c: selected ? Colors.white : _C.teal,
        ),
      ),
    ),
  );
}

Widget _relationshipChip(String text) => Container(
  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
  decoration: BoxDecoration(
    color: _C.tealSoft,
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(
    text,
    style: _ts(FontSize.s7, w: FontWeight.w600, c: _C.teal),
  ),
);

Widget _slotProgressRow(
  int filledCount,
  int totalSlots,
  String label, {
  Color? labelColor,
}) {
  return Row(
    children: [
      ...List.generate(totalSlots, (i) {
        final filled = i < filledCount;
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
          label,
          style: _ts(
            FontSize.s9,
            w: FontWeight.w500,
            c: labelColor ?? _C.inkMid,
          ),
        ),
      ),
    ],
  );
}

/// Rounded sheet chrome with drag-handle, title, optional trailing action
/// and a close button. Every sheet in this file uses it.
class _SheetShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? bottomBar;
  final Widget? trailing;
  final VoidCallback onClose;
  final GlobalKey<ScaffoldMessengerState> messengerKey;

  const _SheetShell({
    required this.title,
    required this.body,
    required this.onClose,
    required this.messengerKey,
    this.subtitle,
    this.bottomBar,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 7.h),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: ScaffoldMessenger(
          key: messengerKey,
          child: Scaffold(
            backgroundColor: _C.bg,
            body: Column(
              children: [
                // Drag handle
                Padding(
                  padding: EdgeInsets.only(top: 1.2.h, bottom: 0.6.h),
                  child: Container(
                    width: 12.w,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _C.fieldBorder,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.w,
                    vertical: 0.6.h,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: _ts(FontSize.s14, w: FontWeight.w700),
                            ),
                            if (subtitle != null) ...[
                              SizedBox(height: 0.2.h),
                              Text(
                                subtitle!,
                                style: _ts(FontSize.s9, c: _C.inkMid),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (trailing != null) ...[
                        trailing!,
                        SizedBox(width: 2.w),
                      ],
                      GestureDetector(
                        onTap: onClose,
                        child: Container(
                          width: 9.w,
                          height: 9.w,
                          decoration: const BoxDecoration(
                            color: _C.fieldBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: _C.inkMid,
                            size: FontSize.s13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: _C.divider),
                Expanded(child: body),
              ],
            ),
            bottomNavigationBar: bottomBar,
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════ 1 · SAFETY SCREEN ═════

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final Repository _repository = Repository();

  int _currentPage = 0;
  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;
  bool _sheetOpen = false;

  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;

  List<EmergencyContact> _contacts = [];
  bool _isLoadingContacts = true;

  static final List<Map<String, dynamic>> _safetyCards = [
    {
      'title': "Explore The Wild With Confidence.",
      'subtitle':
          "AoRbo connects you with trusted trekking partners, experienced guides & safety equipment.",
      'gradientColors': [
        const Color(0xFF6C3DE0).withValues(alpha: 0.75),
        const Color(0xFFE0409A).withValues(alpha: 0.75),
      ],
      'backgroundImage': CommonImages.safety1,
    },
    {
      'title': "Safety First\nAdventure Second.",
      'subtitle':
          "Our certified guides and well-maintained equipment ensure your safety throughout the journey.",
      'gradientColors': [
        const Color(0xFF0D47A1).withValues(alpha: 0.78),
        const Color(0xFF00897B).withValues(alpha: 0.78),
      ],
      'backgroundImage': CommonImages.safety2,
    },
    {
      'title': "24/7 Support\nAt Your Service.",
      'subtitle':
          "Round-the-clock assistance and emergency support available throughout your trek.",
      'gradientColors': [
        const Color(0xFFBF360C).withValues(alpha: 0.78),
        const Color(0xFFF9A825).withValues(alpha: 0.78),
      ],
      'backgroundImage': CommonImages.safety3,
    },
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _startAutoScroll();
    _loadContacts();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────────────────

  Future<void> _loadContacts() async {
    if (!mounted) return;
    setState(() => _isLoadingContacts = true);
    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.emergencyContacts,
      );
      if (response != null && mounted) {
        final r = EmergencyContactResponse.fromJson(response);
        if (r.success == true) {
          setState(() => _contacts = r.data ?? []);
        }
      }
    } catch (e) {
      log('loadContacts failed: $e'); // silent — UI keeps last known state
    } finally {
      if (mounted) setState(() => _isLoadingContacts = false);
    }
  }

  // ── Manager sheet — single entry point, always refresh on close ──────

  Future<void> _openManager() async {
    if (_sheetOpen) return; // double-tap guard
    setState(() => _sheetOpen = true); // pauses carousel

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false, // unsaved-work guard owns dismissal
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _ManagerSheet(initialSaved: List.of(_contacts)),
    );

    if (!mounted) return;
    setState(() => _sheetOpen = false);
    _loadContacts();
  }

  // ── Carousel ──────────────────────────────────────────────────────────

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_isUserInteracting || _sheetOpen || !_pageController.hasClients) {
        return;
      }
      final nextPage = (_currentPage + 1) % _safetyCards.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  Widget _dotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_safetyCards.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 0.8.w),
          width: isActive ? 6.w : 2.w,
          height: 1.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: isActive ? _C.teal : _C.fieldBorder,
          ),
        );
      }),
    );
  }

  // ── Contact card (read-only, hub view) ────────────────────────────────

  Widget _contactCard(EmergencyContact contact) {
    final name = contact.name ?? 'Unknown';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: _C.teal.withValues(alpha: 0.18)),
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
          _initialAvatar(name, size: 10.w),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _ts(FontSize.s11, w: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: FontSize.s9,
                      color: _C.inkLight,
                    ),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        contact.phone ?? 'No number',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _ts(FontSize.s9, c: _C.inkMid),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          if (contact.relationship?.isNotEmpty == true)
            _relationshipChip(contact.relationship!),
        ],
      ),
    );
  }

  // ── Trusted contacts section ──────────────────────────────────────────

  Widget _trustedContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  child: const Center(
                    child: Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Trusted Contacts',
                  style: _ts(FontSize.s13, w: FontWeight.w700),
                ),
              ],
            ),
            if (_contacts.isNotEmpty)
              GestureDetector(
                onTap: _openManager,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.6.h,
                  ),
                  decoration: BoxDecoration(
                    color: _C.tealSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: FontSize.s9,
                        color: _C.teal,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Manage',
                        style: _ts(FontSize.s9, w: FontWeight.w600, c: _C.teal),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 0.6.h),
        Text(
          'These contacts will be notified in case of emergency',
          style: _ts(FontSize.s9, c: _C.inkMid),
        ),
        SizedBox(height: 1.5.h),
        _slotProgressRow(
          _contacts.length,
          _kMaxContacts,
          '${_contacts.length} / $_kMaxContacts slots filled',
          labelColor: _contacts.length >= _kMaxContacts ? _C.warn : _C.inkMid,
        ),
        SizedBox(height: 1.5.h),
        if (_isLoadingContacts)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: const CircularProgressIndicator(
                color: _C.teal,
                strokeWidth: 2,
              ),
            ),
          )
        else if (_contacts.isEmpty)
          GestureDetector(
            onTap: _openManager,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 3.5.h),
              decoration: BoxDecoration(
                color: _C.tealSoft,
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                  color: _C.teal.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.people_outline_rounded, color: _C.teal, size: 8.w),
                  SizedBox(height: 1.2.h),
                  Text(
                    'No trusted contacts yet',
                    style: _ts(FontSize.s11, w: FontWeight.w600, c: _C.teal),
                  ),
                  SizedBox(height: 0.4.h),
                  Text(
                    'Tap to add up to $_kMaxContacts emergency contacts',
                    style: _ts(FontSize.s9, c: _C.teal.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
          )
        else
          Column(children: _contacts.map(_contactCard).toList()),
        if (!_isLoadingContacts &&
            _contacts.isNotEmpty &&
            _contacts.length < _kMaxContacts) ...[
          SizedBox(height: 0.5.h),
          GestureDetector(
            onTap: _openManager,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              decoration: BoxDecoration(
                color: _C.cardBg,
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                  color: _C.teal.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 5.5.w,
                    height: 5.5.w,
                    decoration: const BoxDecoration(
                      color: _C.teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Add another contact',
                    style: _ts(FontSize.s10, w: FontWeight.w600, c: _C.teal),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
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
      builder: (_, __) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, (1 - anim.value) * 18),
          child: child,
        ),
      ),
    );
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
        iconTheme: const IconThemeData(color: _C.ink),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: Get.back,
        ),
        title: Text('Safety', style: _ts(FontSize.s15, w: FontWeight.w700)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.divider),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          color: _C.teal,
          onRefresh: _loadContacts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero header ─────────────────────────────────────
                _animatedSlideIn(
                  index: 0,
                  child: Container(
                    width: double.infinity,
                    color: _C.cardBg,
                    padding: EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 2.5.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'At Aorbo, your safety comes first.',
                          style: _ts(FontSize.s16, w: FontWeight.w700, h: 1.25),
                        ),
                        SizedBox(height: 0.8.h),
                        Text(
                          'Here are some measures and provisions to ensure your safety.',
                          style: _ts(FontSize.s10, c: _C.inkMid, h: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                // ── Auto-sliding cards ──────────────────────────────
                _animatedSlideIn(
                  index: 1,
                  child: Listener(
                    onPointerDown: (_) =>
                        setState(() => _isUserInteracting = true),
                    onPointerUp: (_) {
                      setState(() => _isUserInteracting = false);
                      _startAutoScroll(); // full 4s grace after interaction
                    },
                    onPointerCancel: (_) {
                      setState(() => _isUserInteracting = false);
                      _startAutoScroll();
                    },
                    child: SizedBox(
                      height: 24.h,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (p) => setState(() => _currentPage = p),
                        itemCount: _safetyCards.length,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: CommonSafetyCard(
                            title: _safetyCards[index]['title'],
                            subtitle: _safetyCards[index]['subtitle'],
                            backgroundImage:
                                _safetyCards[index]['backgroundImage'],
                            logoPath: CommonImages.logo2,
                            height: 23.h,
                            width: double.infinity,
                            margin: EdgeInsets.zero,
                            borderRadius: BorderRadius.circular(20),
                            gradientColors:
                                _safetyCards[index]['gradientColors'],
                            onTap: () {},
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 1.5.h),
                _animatedSlideIn(index: 2, child: _dotIndicator()),
                SizedBox(height: 3.h),

                // ── Trusted contacts ────────────────────────────────
                _animatedSlideIn(
                  index: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        color: _C.cardBg,
                        borderRadius: BorderRadius.circular(5.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _trustedContactsSection(),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════ 2 · MANAGER SHEET ═════════

class _ManagerSheet extends StatefulWidget {
  final List<EmergencyContact> initialSaved;
  const _ManagerSheet({required this.initialSaved});

  @override
  State<_ManagerSheet> createState() => _ManagerSheetState();
}

class _ManagerSheetState extends State<_ManagerSheet> {
  final Repository _repository = Repository();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  late List<EmergencyContact> _saved;
  final List<Contact> _pending = [];
  final Map<String, String> _relationships = {}; // contact.id → relationship

  bool _isLoading = false;
  bool _isSaving = false;

  int get _total => _saved.length + _pending.length;
  int get _slotsLeft => _kMaxContacts - _total;

  Set<String> get _usedPhones {
    final set = <String>{
      ..._saved.map((c) => _normalizePhone(c.phone ?? '')),
      ..._pending.map((c) => _normalizePhone(_firstPhoneOf(c))),
    };
    set.remove('');
    return set;
  }

  @override
  void initState() {
    super.initState();
    _saved = List.of(widget.initialSaved); // no loading flash
    _refresh(silent: _saved.isNotEmpty);
  }

  // ── Data ──────────────────────────────────────────────────────────────

  bool _tryAddPending(Contact c) {
    final phone = _normalizePhone(_firstPhoneOf(c));
    if (phone.isEmpty) return false; // no usable number
    if (_usedPhones.contains(phone)) return false; // duplicate
    if (_total >= _kMaxContacts) return false;
    _pending.add(c);
    _relationships.putIfAbsent(c.id, () => 'Family');
    return true;
  }

  Future<void> _refresh({bool silent = false}) async {
    if (!mounted) return;
    if (!silent) setState(() => _isLoading = true);
    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.emergencyContacts,
      );
      if (response != null && mounted) {
        final r = EmergencyContactResponse.fromJson(response);
        if (r.success == true) {
          _saved = r.data ?? [];
          // Race + duplicate guard: once the server list arrives, drop
          // pending items whose number is already saved, and trim overflow.
          final savedPhones = _saved
              .map((c) => _normalizePhone(c.phone ?? ''))
              .toSet();
          _pending.removeWhere(
            (c) => savedPhones.contains(_normalizePhone(_firstPhoneOf(c))),
          );
          while (_total > _kMaxContacts && _pending.isNotEmpty) {
            final removed = _pending.removeLast();
            _relationships.remove(removed.id);
          }
        }
      }
    } catch (e) {
      log('manager refresh failed: $e');
      if (mounted && !silent) {
        _snack(
          _messengerKey.currentState,
          'Could not load saved contacts. Pull down to retry.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Saves pending contacts one by one. Each success is removed from the
  /// pending list immediately — a partial failure never desyncs UI/server.
  Future<void> _savePending() async {
    if (_isSaving || _pending.isEmpty) return;
    setState(() => _isSaving = true);

    int savedCount = 0;
    final failures = <String>[];
    final queue = List<Contact>.from(_pending);

    for (final contact in queue) {
      final phone = _firstPhoneOf(contact).trim();
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

    await _refresh(silent: true);
    if (!mounted) return;
    setState(() => _isSaving = false);

    final m = _messengerKey.currentState;
    if (failures.isEmpty) {
      _snack(
        m,
        '$savedCount contact${savedCount == 1 ? '' : 's'} saved successfully',
      );
    } else if (savedCount > 0) {
      _snack(
        m,
        '$savedCount saved. Failed: ${failures.join(', ')}',
        isError: true,
      );
    } else {
      _snack(
        m,
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
      if (response == null) {
        _snack(
          _messengerKey.currentState,
          'Failed to delete. Please try again.',
          isError: true,
        );
        return;
      }
      final r = EmergencyContactDeleteResponse.fromJson(response);
      if (r.success == true) {
        setState(() => _saved.removeWhere((c) => c.id == id));
        _snack(_messengerKey.currentState, r.message ?? 'Contact removed');
      } else {
        _snack(
          _messengerKey.currentState,
          r.message ?? 'Could not delete contact',
          isError: true,
        );
      }
    } catch (e) {
      log('deleteSaved failed: $e');
      if (mounted) {
        _snack(
          _messengerKey.currentState,
          'Failed to delete. Please try again.',
          isError: true,
        );
      }
    }
  }

  // ── Picker sheet ──────────────────────────────────────────────────────

  Future<void> _openPicker() async {
    if (_isSaving) return;
    if (_slotsLeft <= 0) {
      _snack(
        _messengerKey.currentState,
        'Maximum $_kMaxContacts emergency contacts allowed.',
        isError: true,
      );
      return;
    }
    final result = await showModalBottomSheet<List<Contact>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _PickerSheet(maxSelectable: _slotsLeft, existingPhones: _usedPhones),
    );
    if (result != null && mounted) {
      setState(() {
        for (final c in result) {
          _tryAddPending(c);
        }
      });
    }
  }

  // ── Close guard ───────────────────────────────────────────────────────

  void _onCloseAttempt() {
    if (_isSaving) {
      _snack(
        _messengerKey.currentState,
        'Please wait — contacts are being saved.',
        isError: true,
      );
      return;
    }
    if (_pending.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _C.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.w)),
        title: Text(
          'Discard unsaved contacts?',
          style: _ts(FontSize.s13, w: FontWeight.w700),
        ),
        content: Text(
          'You have ${_pending.length} contact${_pending.length == 1 ? '' : 's'} '
          'that haven\'t been saved yet. Leaving now will discard them.',
          style: _ts(FontSize.s10, c: _C.inkMid, h: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep editing',
              style: _ts(FontSize.s10, w: FontWeight.w600, c: _C.teal),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // dialog
              Navigator.of(context).pop(); // sheet
            },
            child: Text(
              'Discard',
              style: _ts(FontSize.s10, w: FontWeight.w600, c: _C.danger),
            ),
          ),
        ],
      ),
    );
  }

  // ── Relationship picker (nested sheet) ────────────────────────────────

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
                style: _ts(FontSize.s12, w: FontWeight.w700),
              ),
              SizedBox(height: 2.h),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kRelationships.map((rel) {
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
                        style: _ts(
                          FontSize.s10,
                          w: FontWeight.w600,
                          c: selected ? Colors.white : _C.inkMid,
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

  // ── Delete confirmation ───────────────────────────────────────────────

  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => AlertDialog(
        backgroundColor: _C.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.w)),
        title: Row(
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
                style: _ts(FontSize.s13, w: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          '"$name" will be permanently removed from your emergency contacts '
          'and cannot be recovered.',
          style: _ts(FontSize.s9, c: _C.inkMid, h: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: _ts(FontSize.s10, w: FontWeight.w600, c: _C.inkMid),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: _C.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteSaved(id);
            },
            child: Text(
              'Delete',
              style: _ts(FontSize.s10, w: FontWeight.w600, c: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Cards ─────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Padding(
    padding: EdgeInsets.only(bottom: 1.h, top: 0.5.h),
    child: Text(
      text,
      style: _ts(FontSize.s8, w: FontWeight.w700, c: _C.inkLight, ls: 1.2),
    ),
  );

  Widget _removeButton(VoidCallback onTap) => GestureDetector(
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
          _initialAvatar(name),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _ts(FontSize.s11, w: FontWeight.w600),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  contact.phone ?? 'No number',
                  style: _ts(FontSize.s9, c: _C.inkMid),
                ),
                if (contact.relationship?.isNotEmpty == true) ...[
                  SizedBox(height: 0.5.h),
                  _relationshipChip(contact.relationship!),
                ],
              ],
            ),
          ),
          _removeButton(() {
            if (contact.id != null) _confirmDelete(contact.id!, name);
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
          _initialAvatar(contact.displayName),
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
                        style: _ts(FontSize.s11, w: FontWeight.w600),
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
                        style: _ts(FontSize.s7, w: FontWeight.w600, c: _C.warn),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.3.h),
                Text(phone, style: _ts(FontSize.s9, c: _C.inkMid)),
                SizedBox(height: 0.6.h),
                GestureDetector(
                  onTap: _isSaving ? null : () => _pickRelationship(contact),
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
                          style: _ts(
                            FontSize.s8,
                            w: FontWeight.w600,
                            c: _C.teal,
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
          _removeButton(() {
            if (_isSaving) return;
            setState(() {
              _pending.removeWhere((c) => c.id == contact.id);
              _relationships.remove(contact.id);
            });
          }),
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
                    style: _ts(FontSize.s11, w: FontWeight.w600),
                  ),
                  Text(
                    '$_slotsLeft slot${_slotsLeft == 1 ? '' : 's'} remaining',
                    style: _ts(FontSize.s8, c: _C.inkLight),
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
        SizedBox(height: 5.h),
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
                style: _ts(FontSize.s13, w: FontWeight.w600),
              ),
              SizedBox(height: 0.8.h),
              Text(
                'Add up to $_kMaxContacts trusted contacts who\nwill be notified in an emergency.',
                textAlign: TextAlign.center,
                style: _ts(FontSize.s9, c: _C.inkMid, h: 1.6),
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
      canPop: _pending.isEmpty && !_isSaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onCloseAttempt();
      },
      child: _SheetShell(
        messengerKey: _messengerKey,
        title: 'Emergency Contacts',
        subtitle: 'They will be notified in case of emergency',
        onClose: _onCloseAttempt,
        trailing: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: _C.iconBadgeBg,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () => Get.toNamed('/help'),
          child: Text(
            'FAQ',
            style: _ts(FontSize.s10, w: FontWeight.w600, c: Colors.white),
          ),
        ),
        body: Column(
          children: [
            // ── Counter + progress ─────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _slotProgressRow(
                          _total,
                          _kMaxContacts,
                          _slotsLeft > 0
                              ? '$_total / $_kMaxContacts slots filled'
                              : 'All slots filled',
                          labelColor: _total >= _kMaxContacts
                              ? _C.warn
                              : _C.inkMid,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.6.h,
                        ),
                        decoration: BoxDecoration(
                          color: _total >= _kMaxContacts
                              ? _C.warnBg
                              : _C.tealSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _total >= _kMaxContacts
                                  ? Icons.lock_outline_rounded
                                  : Icons.person_outline_rounded,
                              size: FontSize.s10,
                              color: _total >= _kMaxContacts
                                  ? _C.warn
                                  : _C.teal,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '$_total / $_kMaxContacts',
                              style: _ts(
                                FontSize.s10,
                                w: FontWeight.w700,
                                c: _total >= _kMaxContacts ? _C.warn : _C.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.2.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: _total / _kMaxContacts),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      builder: (_, value, __) => LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        backgroundColor: _C.fieldBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _total >= _kMaxContacts
                              ? const Color(0xFFFAB005)
                              : _C.teal,
                        ),
                      ),
                    ),
                  ),
                ],
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
                      onRefresh: _refresh,
                      child: (_saved.isEmpty && _pending.isEmpty)
                          ? _emptyState()
                          : ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 3.h),
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

        // ── Save bar ───────────────────────────────────────────────
        bottomBar: _pending.isEmpty
            ? null
            : Container(
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
                        style: _ts(FontSize.s9, c: _C.inkMid),
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
              ),
      ),
    );
  }
}

// ══════════════════════════════════════════════ 3 · PICKER SHEET ═════════

enum _PermState { checking, granted, denied, permanentlyDenied }

class _PickerSheet extends StatefulWidget {
  final int maxSelectable;
  final Set<String> existingPhones;

  const _PickerSheet({
    required this.maxSelectable,
    required this.existingPhones,
  });

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  List<Contact> _allContacts = [];
  List<Contact> _filtered = [];
  final List<Contact> _selected = [];
  final Set<String> _selectedIds = {};

  _PermState _permState = _PermState.checking;
  bool _isLoading = true;
  bool _wentToSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_filterContacts);
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
      log('fetchContacts failed: $e');
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
    final phone = _normalizePhone(_firstPhoneOf(contact));
    return phone.isNotEmpty && widget.existingPhones.contains(phone);
  }

  void _toggleSelection(Contact contact) {
    if (_isAlreadySaved(contact)) {
      _snack(
        _messengerKey.currentState,
        'This number is already an emergency contact.',
        isError: true,
      );
      return;
    }
    setState(() {
      if (_selectedIds.contains(contact.id)) {
        _selectedIds.remove(contact.id);
        _selected.removeWhere((c) => c.id == contact.id);
        return;
      }
      if (_selected.length >= widget.maxSelectable) {
        _snack(
          _messengerKey.currentState,
          'You can add ${widget.maxSelectable} more contact${widget.maxSelectable == 1 ? '' : 's'} only.',
          isError: true,
        );
        return;
      }
      // Block duplicate numbers within the current selection too.
      final phone = _normalizePhone(_firstPhoneOf(contact));
      final alreadyPicked = _selected.any(
        (c) => _normalizePhone(_firstPhoneOf(c)) == phone,
      );
      if (alreadyPicked) {
        _snack(
          _messengerKey.currentState,
          'A contact with this number is already selected.',
          isError: true,
        );
        return;
      }
      _selectedIds.add(contact.id);
      _selected.add(contact);
    });
  }

  void _confirmSelection() =>
      Navigator.of(context).pop(List<Contact>.from(_selected));

  // ── UI pieces ─────────────────────────────────────────────────────────

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
                _initialAvatar(contact.displayName, selected: isSelected),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _ts(
                          FontSize.s11,
                          w: FontWeight.w600,
                          c: isSelected ? _C.teal : _C.ink,
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
                              style: _ts(
                                FontSize.s9,
                                c: isSelected
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
                      style: _ts(FontSize.s8, w: FontWeight.w700, c: _C.teal),
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
            style: _ts(FontSize.s13, w: FontWeight.w600),
          ),
          SizedBox(height: 0.8.h),
          Text(
            _allContacts.isEmpty
                ? 'No contacts with phone numbers on this device'
                : 'Try a different name or number',
            style: _ts(FontSize.s9, c: _C.inkMid),
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
              style: _ts(FontSize.s13, w: FontWeight.w600),
            ),
            SizedBox(height: 0.8.h),
            Text(
              isPermanent
                  ? 'Permission was denied permanently.\nEnable Contacts access in app settings.'
                  : 'Please allow access to your contacts\nto add emergency contacts.',
              textAlign: TextAlign.center,
              style: _ts(FontSize.s9, c: _C.inkMid, h: 1.6),
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
                  style: _ts(FontSize.s10, w: FontWeight.w600, c: Colors.white),
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
    final slotsLeft = widget.maxSelectable - _selected.length;

    return Padding(
      // Keep search field + Done bar above the keyboard.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _SheetShell(
        messengerKey: _messengerKey,
        title: 'Select Contacts',
        subtitle: 'Dismiss to cancel · Done confirms selection',
        onClose: () => Navigator.of(context).pop(), // cancel
        body: Column(
          children: [
            // ── Search + slot info ─────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
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
                      style: _ts(FontSize.s11),
                      decoration: InputDecoration(
                        hintText: 'Search by name or number…',
                        hintStyle: _ts(FontSize.s10, c: _C.inkLight),
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
                      Expanded(
                        child: _slotProgressRow(
                          _selected.length,
                          widget.maxSelectable.clamp(0, _kMaxContacts),
                          slotsLeft > 0
                              ? '$slotsLeft slot${slotsLeft == 1 ? '' : 's'} remaining'
                              : 'All slots filled',
                          labelColor: slotsLeft == 0 ? _C.warn : _C.inkMid,
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
                            style: _ts(
                              FontSize.s8,
                              w: FontWeight.w700,
                              c: _C.teal,
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
                      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 3.h),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) =>
                          _contactTile(_filtered[index]),
                    ),
            ),
          ],
        ),

        // ── Done bar ───────────────────────────────────────────────
        bottomBar: _selected.isEmpty
            ? null
            : Container(
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
                            style: _ts(FontSize.s9, c: _C.inkMid),
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
              ),
      ),
    );
  }
}
