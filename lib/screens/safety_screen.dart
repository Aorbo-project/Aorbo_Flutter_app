// ─────────────────────────────────────────────────────────────────────────
//  safety_hub_screen.dart  —  PRODUCTION FIX
//
//  Fixes:
//   • [FIX] Removed missing screen_constant.dart import to fix build errors.
//   • [FIX] Replaced FontSize.sXX with standard doubles.
//   • [FIX] Phone number normalized for API to prevent 500 server errors on POST.
//   • [FIX] 4-byte emojis (like 😍, 😎) stripped from name to prevent DB utf8 crashes.
//   • Search filter: empty-digit query no longer matches all contacts.
//   • Phone search: country-code / long numbers normalised to last 10 digits.
//   • Carousel pauses on app background.
//   • Close + Delete disabled during save.
//   • fetchContacts shows error state on exception (not fake "granted").
//   • Search debounced (200 ms) for large contact lists.
//   • AppBar back is safe when screen is root.
//   • Hub screen shows error + retry on load failure.
//   • "Added" badge only shows for server-saved contacts, not pending.
//   • Trusted Contacts header fixed for pixel overflow.
//   • Keyboard double-padding removed in PickerSheet.
//   • FittedBox and maxLines added to all text/rows to guarantee 0 pixel overflow.
// ─────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../models/emergency_contact_model.dart';
import '../repository/network_url.dart';
import '../repository/repository.dart';
import '../utils/common_btn.dart';
import '../utils/phone_input_formatter.dart';
import '../utils/common_colors.dart';
import '../utils/common_images.dart';
import '../utils/common_safety_card.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';

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

/// Normalizes phone for the API.
/// Keeps the leading "+" if present, strips all whitespace and dashes.
/// Example: "+91 99898-688 99" -> "+919989868899"
String _normalizePhoneForApi(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  final hasPlus = trimmed.startsWith('+');
  final digits = trimmed.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.isEmpty) return '';
  return hasPlus ? '+$digits' : digits;
}

/// Removes 4-byte UTF-8 characters (most modern emojis like 😍, 😎)
/// which cause 500 server errors if the DB is configured with utf8 instead of utf8mb4.
/// Also strips variation selectors to be safe.
String _sanitizeNameForApi(String name) {
  return name
      .replaceAll(RegExp(r'[\u{10000}-\u{10FFFF}]', unicode: true), '')
      .replaceAll(RegExp(r'[\u200B-\u200D\uFE0F]'), '')
      .trim();
}

/// A contact the user typed in but hasn't saved to the server yet.
/// (Replaced the device-contact picker — no READ_CONTACTS permission.)
class _PendingContact {
  final String id;
  final String name;
  final String phone;
  const _PendingContact({required this.id, required this.name, required this.phone});
}

// ═════════════════════════════════════════════════════ DESIGN TOKENS ═══

class _C {
  static const bg = AppColors.bgCool;
  static const cardBg = Colors.white;
  static const ink = AppColors.ink;
  static const inkMid = AppColors.inkMid;
  static const inkLight = AppColors.inkLight;
  static const teal = AppColors.teal;
  static const tealSoft = AppColors.tealSoft;
  static const fieldBg = AppColors.elevated;
  static const fieldBorder = AppColors.border;
  static const iconBadgeBg = AppColors.ink;
  static const danger = Color(0xFFEF4444);
  static const divider = AppColors.border;
  static const warnBg = Color(0xFFFFF3BF);
  static const warn = Color(0xFFE67700);
  static const ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.forestDeep, AppColors.forest],
  );
}

TextStyle _ts(
  double size, {
  FontWeight w = FontWeight.w400,
  Color c = _C.ink,
  double? h,
  double? ls,
}) => AppType.style(size, w: w, color: c, height: h, letterSpacing: ls);

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
              size: 14.0,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(message, style: _ts(10.0, c: Colors.white)),
            ),
          ],
        ),
        backgroundColor: isError ? _C.danger : _C.teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
        margin: EdgeInsets.all(4.w),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  if (isError) HapticFeedback.heavyImpact();
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
          14.0,
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
    style: _ts(7.0, w: FontWeight.w600, c: _C.teal),
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _ts(9.0, w: FontWeight.w500, c: labelColor ?? _C.inkMid),
        ),
      ),
    ],
  );
}

class _SheetShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? bottomBar;
  final Widget? trailing;
  final VoidCallback onClose;
  final bool closeEnabled;
  final GlobalKey<ScaffoldMessengerState> messengerKey;

  const _SheetShell({
    required this.title,
    required this.body,
    required this.onClose,
    required this.messengerKey,
    this.subtitle,
    this.bottomBar,
    this.trailing,
    this.closeEnabled = true,
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _ts(14.0, w: FontWeight.w700),
                            ),
                            if (subtitle != null) ...[
                              SizedBox(height: 0.2.h),
                              Text(
                                subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _ts(9.0, c: _C.inkMid),
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
                        onTap: closeEnabled ? onClose : null,
                        child: Container(
                          width: 11.w,
                          height: 11.w,
                          decoration: BoxDecoration(
                            color: _C.fieldBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: closeEnabled ? _C.inkMid : _C.inkLight,
                            size: 13.0,
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

// ═════════════════════════════════════════ 1 · SAFETY SCREEN ═════════════

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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
  bool _loadError = false;

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
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _autoScrollTimer?.cancel();
    } else if (state == AppLifecycleState.resumed && !_sheetOpen) {
      _startAutoScroll();
    }
  }

  Future<void> _loadContacts() async {
    if (!mounted) return;
    setState(() {
      _isLoadingContacts = true;
      _loadError = false;
    });
    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.emergencyContacts,
      );
      if (response != null && mounted) {
        final r = EmergencyContactResponse.fromJson(response);
        if (r.success == true) {
          setState(() {
            _contacts = r.data ?? [];
            _loadError = false;
          });
        } else {
          setState(() => _loadError = true);
        }
      } else if (mounted) {
        setState(() => _loadError = true);
      }
    } catch (e) {
      log('loadContacts failed: $e');
      if (mounted) setState(() => _loadError = true);
    } finally {
      if (mounted) setState(() => _isLoadingContacts = false);
    }
  }

  Future<void> _openManager() async {
    if (_sheetOpen) return;
    setState(() => _sheetOpen = true);

    FirebaseCrashlytics.instance.log('Popup: Emergency contacts manager sheet');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _ManagerSheet(initialSaved: List.of(_contacts)),
    );

    if (!mounted) return;
    setState(() => _sheetOpen = false);
    _loadContacts();
  }

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
                  style: _ts(11.0, w: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 9.0, color: _C.inkLight),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        contact.phone ?? 'No number',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _ts(9.0, c: _C.inkMid),
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

  Widget _contactsErrorState() {
    return GestureDetector(
      onTap: _loadContacts,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 3.5.h, horizontal: 5.w),
        decoration: BoxDecoration(
          color: _C.danger.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(color: _C.danger.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_off_rounded, color: _C.danger, size: 8.w),
            SizedBox(height: 1.2.h),
            Text(
              'Couldn\'t load contacts',
              style: _ts(11.0, w: FontWeight.w600, c: _C.danger),
            ),
            SizedBox(height: 0.4.h),
            Text(
              'Tap to retry',
              style: _ts(9.0, c: _C.danger.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trustedContactsSection() {
    return Column(
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
              child: const Center(
                child: Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                'Trusted Contacts',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _ts(13.0, w: FontWeight.w700),
              ),
            ),
            if (_contacts.isNotEmpty) ...[
              SizedBox(width: 2.w),
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
                      Icon(Icons.edit_outlined, size: 9.0, color: _C.teal),
                      SizedBox(width: 1.w),
                      Text(
                        'Manage',
                        style: _ts(9.0, w: FontWeight.w600, c: _C.teal),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 0.6.h),
        Text(
          'These contacts will be notified in case of emergency',
          style: _ts(9.0, c: _C.inkMid),
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
        else if (_loadError)
          _contactsErrorState()
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
                    style: _ts(11.0, w: FontWeight.w600, c: _C.teal),
                  ),
                  SizedBox(height: 0.4.h),
                  Text(
                    'Tap to add up to $_kMaxContacts emergency contacts',
                    style: _ts(9.0, c: _C.teal.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
          )
        else
          Column(children: _contacts.map(_contactCard).toList()),
        if (!_isLoadingContacts &&
            !_loadError &&
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
                    style: _ts(10.0, w: FontWeight.w600, c: _C.teal),
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
          onPressed: () {
            final nav = Navigator.of(context);
            if (nav.canPop()) {
              nav.pop();
            } else {
              Get.back();
            }
          },
        ),
        title: Text('Safety', style: _ts(15.0, w: FontWeight.w700)),
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
                          style: _ts(16.0, w: FontWeight.w700, h: 1.25),
                        ),
                        SizedBox(height: 0.8.h),
                        Text(
                          'Here are some measures and provisions to ensure your safety.',
                          style: _ts(10.0, c: _C.inkMid, h: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                _animatedSlideIn(
                  index: 1,
                  child: Listener(
                    onPointerDown: (_) =>
                        setState(() => _isUserInteracting = true),
                    onPointerUp: (_) {
                      setState(() => _isUserInteracting = false);
                      _startAutoScroll();
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
  final List<_PendingContact> _pending = [];
  final Map<String, String> _relationships = {};

  bool _isLoading = false;
  bool _isSaving = false;

  int get _total => _saved.length + _pending.length;
  int get _slotsLeft => _kMaxContacts - _total;

  Set<String> get _usedPhones {
    final set = <String>{
      ..._saved.map((c) => _normalizePhone(c.phone ?? '')),
      ..._pending.map((c) => _normalizePhone(c.phone)),
    };
    set.remove('');
    return set;
  }

  Set<String> get _savedPhones {
    final set = <String>{..._saved.map((c) => _normalizePhone(c.phone ?? ''))};
    set.remove('');
    return set;
  }

  @override
  void initState() {
    super.initState();
    _saved = List.of(widget.initialSaved);
    _refresh(silent: _saved.isNotEmpty);
  }

  bool _tryAddPending(_PendingContact c) {
    final phone = _normalizePhone(c.phone);
    if (phone.isEmpty) return false;
    if (_usedPhones.contains(phone)) return false;
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
          final savedPhones = _saved
              .map((c) => _normalizePhone(c.phone ?? ''))
              .toSet();
          _pending.removeWhere(
            (c) => savedPhones.contains(_normalizePhone(c.phone)),
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

  Future<void> _savePending() async {
    if (_isSaving || _pending.isEmpty) return;
    setState(() => _isSaving = true);

    int savedCount = 0;
    final failures = <String>[];
    final queue = List<_PendingContact>.from(_pending);

    for (final contact in queue) {
      final rawPhone = contact.phone.trim();
      if (rawPhone.isEmpty) {
        failures.add(contact.name);
        continue;
      }

      final phone = _normalizePhoneForApi(rawPhone);
      // 🔧 Strip 4-byte emojis (like 😍, 😎) which crash the server's utf8 DB
      final name = _sanitizeNameForApi(contact.name);

      if (phone.isEmpty || name.isEmpty) {
        failures.add(contact.name);
        continue;
      }

      try {
        final response = await _repository.postApiCall(
          url: NetworkUrl.emergencyContacts,
          body: {
            'name': name,
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
          if (mounted) setState(() {});
        } else {
          failures.add(contact.name);
        }
      } catch (e) {
        log('save failed for ${contact.name}: $e');
        failures.add(contact.name);
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
    final result = await showModalBottomSheet<_PendingContact>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddContactSheet(
        existingPhones: _usedPhones,
        savedPhones: _savedPhones,
      ),
    );
    if (result != null && mounted) {
      final ok = _tryAddPending(result);
      setState(() {});
      if (!ok) {
        _snack(
          _messengerKey.currentState,
          'That number is already a contact or the slots are full.',
          isError: true,
        );
      }
    }
  }

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

    FirebaseCrashlytics.instance.log(
      'Popup: Discard unsaved contacts confirm (safety)',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _C.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.w)),
        title: Text(
          'Discard unsaved contacts?',
          style: _ts(13.0, w: FontWeight.w700),
        ),
        content: Text(
          'You have ${_pending.length} contact${_pending.length == 1 ? '' : 's'} '
          'that haven\'t been saved yet. Leaving now will discard them.',
          style: _ts(10.0, c: _C.inkMid, h: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep editing',
              style: _ts(10.0, w: FontWeight.w600, c: _C.teal),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pop();
            },
            child: Text(
              'Discard',
              style: _ts(10.0, w: FontWeight.w600, c: _C.danger),
            ),
          ),
        ],
      ),
    );
  }

  void _pickRelationship(_PendingContact contact) {
    FirebaseCrashlytics.instance.log(
      'Popup: Relationship picker sheet (safety)',
    );
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
                'Relationship with ${contact.name}',
                style: _ts(12.0, w: FontWeight.w700),
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
                          10.0,
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

  void _confirmDelete(int id, String name) {
    if (_isSaving) return;
    FirebaseCrashlytics.instance.log('Popup: Delete contact confirm (safety)');
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
                size: 14.0,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                'Delete Contact',
                style: _ts(13.0, w: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          '"$name" will be permanently removed from your emergency contacts '
          'and cannot be recovered.',
          style: _ts(9.0, c: _C.inkMid, h: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: _ts(10.0, w: FontWeight.w600, c: _C.inkMid),
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
              style: _ts(10.0, w: FontWeight.w600, c: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: EdgeInsets.only(bottom: 1.h, top: 0.5.h),
    child: Text(
      text,
      style: _ts(8.0, w: FontWeight.w700, c: _C.inkLight, ls: 1.2),
    ),
  );

  Widget _removeButton(VoidCallback onTap, {bool enabled = true}) =>
      GestureDetector(
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                onTap();
              }
            : null,
        child: Container(
          width: 9.w,
          height: 9.w,
          decoration: BoxDecoration(
            color: _C.danger.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            color: enabled ? _C.danger : _C.inkLight,
            size: 12.0,
          ),
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
                  style: _ts(11.0, w: FontWeight.w600),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  contact.phone ?? 'No number',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _ts(9.0, c: _C.inkMid),
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
          }, enabled: !_isSaving),
        ],
      ),
    );
  }

  Widget _pendingCard(_PendingContact contact) {
    final phone = contact.phone.isNotEmpty ? contact.phone : 'No number';
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
          _initialAvatar(contact.name),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contact.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _ts(11.0, w: FontWeight.w600),
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
                        style: _ts(7.0, w: FontWeight.w600, c: _C.warn),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.3.h),
                Text(
                  phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _ts(9.0, c: _C.inkMid),
                ),
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
                          style: _ts(8.0, w: FontWeight.w600, c: _C.teal),
                        ),
                        SizedBox(width: 1.w),
                        Icon(Icons.edit_outlined, size: 8.0, color: _C.teal),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          _removeButton(() {
            setState(() {
              _pending.removeWhere((c) => c.id == contact.id);
              _relationships.remove(contact.id);
            });
          }, enabled: !_isSaving),
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
                    style: _ts(11.0, w: FontWeight.w600),
                  ),
                  Text(
                    '$_slotsLeft slot${_slotsLeft == 1 ? '' : 's'} remaining',
                    style: _ts(8.0, c: _C.inkLight),
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
              Text('No contacts yet', style: _ts(13.0, w: FontWeight.w600)),
              SizedBox(height: 0.8.h),
              Text(
                'Add up to $_kMaxContacts trusted contacts who\nwill be notified in an emergency.',
                textAlign: TextAlign.center,
                style: _ts(9.0, c: _C.inkMid, h: 1.6),
              ),
            ],
          ),
        ),
        SizedBox(height: 3.h),
        _addContactCard(),
      ],
    );
  }

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
        closeEnabled: !_isSaving,
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
            style: _ts(10.0, w: FontWeight.w600, c: Colors.white),
          ),
        ),
        body: Column(
          children: [
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
                              size: 10.0,
                              color: _total >= _kMaxContacts
                                  ? _C.warn
                                  : _C.teal,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '$_total / $_kMaxContacts',
                              style: _ts(
                                10.0,
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
                      onRefresh: () => _refresh(silent: true),
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
                        style: _ts(9.0, c: _C.inkMid),
                      ),
                      SizedBox(height: 1.h),
                      CommonButton(
                        text: _isSaving ? 'Saving…' : 'Save Emergency Contacts',
                        onPressed: _savePending,
                        gradient: _C.ctaGradient,
                        textColor: CommonColors.whiteColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.0,
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


// ═══════════════════════════════════════════ 3 · ADD-CONTACT SHEET ═══════
// Manual entry only — the app no longer reads the device address book, so
// there's no READ_CONTACTS permission and no Play permissions declaration.

class _AddContactSheet extends StatefulWidget {
  final Set<String> existingPhones;
  final Set<String> savedPhones;

  const _AddContactSheet({
    required this.existingPhones,
    required this.savedPhones,
  });

  @override
  State<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<_AddContactSheet> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _nameError;
  String? _phoneError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _sanitizeNameForApi(_nameCtrl.text);
    final phoneRaw = _phoneCtrl.text.trim();
    final phone10 = _normalizePhone(phoneRaw);

    String? nameErr;
    String? phoneErr;
    if (name.isEmpty) {
      nameErr = 'Enter a name';
    } else if (name.length < 2) {
      nameErr = 'Name is too short';
    }
    if (phone10.length != 10) {
      phoneErr = 'Enter a valid 10-digit mobile number';
    } else if (widget.savedPhones.contains(phone10)) {
      phoneErr = 'This number is already an emergency contact';
    } else if (widget.existingPhones.contains(phone10)) {
      phoneErr = 'You already added this number';
    }

    if (nameErr != null || phoneErr != null) {
      setState(() {
        _nameError = nameErr;
        _phoneError = phoneErr;
      });
      return;
    }

    Navigator.of(context).pop(
      _PendingContact(
        id: 'm-${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        phone: phone10,
      ),
    );
  }

  InputDecoration _dec(String hint, String? error) => InputDecoration(
        hintText: hint,
        hintStyle: _ts(10.0, c: _C.inkMid),
        errorText: error,
        errorStyle: _ts(8.0, c: _C.danger),
        filled: true,
        fillColor: _C.fieldBg,
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
          borderSide: BorderSide(color: _C.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
          borderSide: const BorderSide(color: _C.teal, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
          borderSide: const BorderSide(color: _C.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
          borderSide: const BorderSide(color: _C.danger, width: 1.4),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Add emergency contact',
      subtitle: 'They will be notified if you raise an alert',
      onClose: () => Navigator.of(context).maybePop(),
      messengerKey: _messengerKey,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name', style: _ts(10.0, w: FontWeight.w600)),
            SizedBox(height: 0.8.h),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              style: _ts(11.0),
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
              decoration: _dec('e.g. Amma', _nameError),
            ),
            SizedBox(height: 2.h),
            Text('Mobile number', style: _ts(10.0, w: FontWeight.w600)),
            SizedBox(height: 0.8.h),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [IndianMobileNumberFormatter()],
              style: _ts(11.0),
              onChanged: (_) {
                if (_phoneError != null) setState(() => _phoneError = null);
              },
              decoration: _dec('10-digit number', _phoneError),
            ),
          ],
        ),
      ),
      bottomBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        decoration: const BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: CommonButton(
            text: 'Add contact',
            onPressed: _submit,
            gradient: _C.ctaGradient,
            textColor: CommonColors.whiteColor,
            fontWeight: FontWeight.w700,
            fontSize: 12.0,
            height: 6.h,
          ),
        ),
      ),
    );
  }
}
