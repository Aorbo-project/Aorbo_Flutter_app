import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_images.dart';
import '../utils/common_safety_card.dart';
import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';
import '../models/emergency_contact_model.dart';
import '../repository/repository.dart';
import '../repository/network_url.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS — aligned with TravellerInfoScreen
// ─────────────────────────────────────────────
class _C {
  static const bg           = Color(0xFFF5F8FF);
  static const cardBg       = Color(0xFFFFFFFF);
  static const ink          = Color(0xFF111827);
  static const inkMid       = Color(0xFF6B7280);
  static const inkLight     = Color(0xFF9CA3AF);
  static const teal         = Color(0xFF0F7B6C);
  static const tealLight    = Color(0xFF1AA090);
  static const tealSoft     = Color(0xFFE6F5F3);
  static const fieldBg      = Color(0xFFF9FAFB);
  static const fieldBorder  = Color(0xFFE5E7EB);
  static const iconBadgeBg  = Color(0xFF111827);
  static const danger       = Color(0xFFEF4444);
  static const divider      = Color(0xFFE5E7EB);
  // accent kept for slot progress visual only
  static const accent       = Color(0xFF0F7B6C);
  static const accentLight  = Color(0xFFE6F5F3);
}

class _NInk {
  static const ink = Color(0xFF0F172A);
}

const _kAnimDur   = Duration(milliseconds: 280);
const _kAnimCurve = Curves.easeOutCubic;

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;

  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;

  List<EmergencyContact> _emergencyContacts = [];
  bool _isLoadingContacts = false;
  final Repository _repository = Repository();

  final List<Map<String, dynamic>> safetyCards = [
    {
      'title': "Explore The Wild With Confidence.",
      'subtitle':
          "AoRbo connects you with trusted trekking partners, experienced guides & safety equipment.",
      'gradientColors': [
        const Color(0xFF6C3DE0).withOpacity(0.75),
        const Color(0xFFE0409A).withOpacity(0.75),
      ],
      'backgroundImage': CommonImages.safety1,
    },
    {
      'title': "Safety First\nAdventure Second.",
      'subtitle':
          "Our certified guides and well-maintained equipment ensure your safety throughout the journey.",
      'gradientColors': [
        const Color(0xFF0D47A1).withOpacity(0.78),
        const Color(0xFF00897B).withOpacity(0.78),
      ],
      'backgroundImage': CommonImages.safety2,
    },
    {
      'title': "24/7 Support\nAt Your Service.",
      'subtitle':
          "Round-the-clock assistance and emergency support available throughout your trek.",
      'gradientColors': [
        const Color(0xFFBF360C).withOpacity(0.78),
        const Color(0xFFF9A825).withOpacity(0.78),
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
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _entranceController.forward();

    _startAutoScroll();
    _loadEmergencyContacts();
  }

  Future<void> _loadEmergencyContacts() async {
    if (!mounted) return;
    setState(() => _isLoadingContacts = true);
    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.emergencyContacts,
      );
      if (response != null && mounted) {
        final r = EmergencyContactResponse.fromJson(response);
        if (r.success == true) {
          setState(() => _emergencyContacts = r.data ?? []);
        }
      }
    } catch (_) {
      // Silently fail — no connectivity or server error
    } finally {
      if (mounted) setState(() => _isLoadingContacts = false);
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (!_isUserInteracting) {
        final nextPage = (_currentPage + 1) % safetyCards.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  /// Navigate to manage screen and always reload on return.
  Future<void> _navigateToManage() async {
    await Get.toNamed('/selected-emergency-contacts');
    _loadEmergencyContacts();
  }

  /// Navigate to add screen and reload on return.
  Future<void> _navigateToAdd() async {
    await Get.toNamed('/emergency-contacts');
    _loadEmergencyContacts();
  }

  // ── Dot indicator ──────────────────────────────────────────────────────────
  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(safetyCards.length, (index) {
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

  // ── Single contact card ────────────────────────────────────────────────────
  Widget _buildContactCard(EmergencyContact contact, int index) {
    final initial = (contact.name?.isNotEmpty == true)
        ? contact.name![0].toUpperCase()
        : '?';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 250 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (ctx, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(color: _C.teal.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: _C.teal.withOpacity(0.06),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 10.w,
              height: 10.w,
              decoration: const BoxDecoration(
                color: _C.tealSoft,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s13,
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
                    contact.name ?? 'Unknown',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w600,
                      color: _C.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s9,
                            color: _C.inkMid,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            // Trusted badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: _C.tealSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: FontSize.s9,
                    color: _C.teal,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Trusted',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s7,
                      fontWeight: FontWeight.w600,
                      color: _C.teal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Trusted contacts section ───────────────────────────────────────────────
  Widget _buildTrustedContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
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
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w700,
                    color: _C.ink,
                  ),
                ),
              ],
            ),
            if (_emergencyContacts.isNotEmpty)
              GestureDetector(
                onTap: _navigateToManage,
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
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s9,
                          fontWeight: FontWeight.w600,
                          color: _C.teal,
                        ),
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
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s9,
            color: _C.inkMid,
          ),
        ),
        SizedBox(height: 1.5.h),

        // Slot progress
        Row(
          children: [
            ...List.generate(3, (i) {
              final filled = i < _emergencyContacts.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
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
            Text(
              '${_emergencyContacts.length} / 3 slots filled',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                fontWeight: FontWeight.w500,
                color: _emergencyContacts.length >= 3
                    ? const Color(0xFFE67700)
                    : _C.inkMid,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),

        // Loading state
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

        // Empty state
        else if (_emergencyContacts.isEmpty)
          GestureDetector(
            onTap: _navigateToAdd,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 3.5.h),
              decoration: BoxDecoration(
                color: _C.tealSoft,
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                  color: _C.teal.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    color: _C.teal,
                    size: 8.w,
                  ),
                  SizedBox(height: 1.2.h),
                  Text(
                    'No trusted contacts yet',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w600,
                      color: _C.teal,
                    ),
                  ),
                  SizedBox(height: 0.4.h),
                  Text(
                    'Tap to add up to 3 emergency contacts',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s9,
                      color: _C.teal.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          )

        // Contact cards
        else
          Column(
            children: _emergencyContacts
                .asMap()
                .entries
                .map((e) => _buildContactCard(e.value, e.key))
                .toList(),
          ),

        // Add another slot button
        if (!_isLoadingContacts &&
            _emergencyContacts.isNotEmpty &&
            _emergencyContacts.length < 3) ...[
          SizedBox(height: 0.5.h),
          GestureDetector(
            onTap: _navigateToAdd,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              decoration: BoxDecoration(
                color: _C.cardBg,
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                  color: _C.teal.withOpacity(0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _C.teal.withOpacity(0.06),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s10,
                      fontWeight: FontWeight.w600,
                      color: _C.teal,
                    ),
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
    final end   = (start + 0.6).clamp(0.0, 1.0);
    final anim  = CurvedAnimation(
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
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: _C.ink),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Safety',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s15,
            fontWeight: FontWeight.w700,
            color: _NInk.ink,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.divider),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero header ────────────────────────────────────────────
              _animatedSlideIn(
                index: 0,
                child: Container(
                  color: _C.cardBg,
                  padding: EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 2.5.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'At Aorbo, Your Safety comes first.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s16,
                          fontWeight: FontWeight.w700,
                          color: _C.ink,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Text(
                        'Here are some measures and provisions to ensure your safety.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s10,
                          color: _C.inkMid,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              // ── Auto-sliding cards ─────────────────────────────────────
              _animatedSlideIn(
                index: 1,
                child: Listener(
                  onPointerDown: (_) =>
                      setState(() => _isUserInteracting = true),
                  onPointerUp: (_) =>
                      setState(() => _isUserInteracting = false),
                  onPointerCancel: (_) =>
                      setState(() => _isUserInteracting = false),
                  child: SizedBox(
                    height: 24.h,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (p) =>
                          setState(() => _currentPage = p),
                      itemCount: safetyCards.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: CommonSafetyCard(
                            title: safetyCards[index]['title'],
                            subtitle: safetyCards[index]['subtitle'],
                            backgroundImage:
                                safetyCards[index]['backgroundImage'],
                            logoPath: CommonImages.logo2,
                            height: 23.h,
                            width: double.infinity,
                            margin: EdgeInsets.zero,
                            borderRadius: BorderRadius.circular(20),
                            gradientColors:
                                safetyCards[index]['gradientColors'],
                            onTap: () {},
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 1.5.h),
              _animatedSlideIn(index: 2, child: _buildDotIndicator()),
              SizedBox(height: 3.h),

              // ── Trusted contacts ───────────────────────────────────────
              _animatedSlideIn(
                index: 3,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s14,
                          fontWeight: FontWeight.w700,
                          color: _C.ink,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          color: _C.cardBg,
                          borderRadius: BorderRadius.circular(5.w),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildTrustedContactsSection(),
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
