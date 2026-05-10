import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_images.dart';
import '../utils/common_safety_card.dart';
import '../utils/common_colors.dart';
import '../utils/common_bottom_nav.dart';
import '../utils/screen_constants.dart';
import '../models/emergency_contact_model.dart';
import '../repository/repository.dart';
import '../repository/network_url.dart';
import 'package:get/get.dart';

// FIX: renamed _C → _SafetyColors to avoid class name collision
// with _C in the other emergency contact files.
class _SafetyColors {
  static const teal = Color(0xFF0F7B6C);
  static const tealSoft = Color(0xFFE6F5F3);
  static const ink = Color(0xFF0F172A);
  static const inkMid = Color(0xFF64748B);
  static const inkLight = Color(0xFF94A3B8);
  static const iconBadgeBg = Color(0xFF111827);
  static const cardBg = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE2E8F0);
  static const accent = Color(0xFF4F46E5);
  static const accentLight = Color(0xFFEEF2FF);
  static const border = Color(0xFFE9ECEF);
}

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _NC {
  static const ink = Color(0xFF0F172A);
}

class _SafetyScreenState extends State<SafetyScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  int selectedIndex = 0;
  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<EmergencyContact> _emergencyContacts = [];
  bool _isLoadingContacts = false;
  final Repository _repository = Repository();

  final List<Map<String, dynamic>> safetyCards = [
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
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
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
      // Silently fail
    } finally {
      if (mounted) setState(() => _isLoadingContacts = false);
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isUserInteracting && mounted) {
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
    _fadeController.dispose();
    super.dispose();
  }

  // ── Navigate to manage screen and ALWAYS reload on return ─────────────────
  // FIX: Use Get.toNamed and await so we reload contacts regardless of
  // whether contacts were deleted or added. This fixes the issue where
  // deleting a contact on the manage screen didn't reflect on Safety.
  Future<void> _navigateToManage() async {
    await Get.toNamed('/selected-emergency-contacts');
    // Always reload — covers delete, add, or no change
    _loadEmergencyContacts();
  }

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
            color: isActive ? _SafetyColors.accent : _SafetyColors.divider,
          ),
        );
      }),
    );
  }

  // ── Single contact card ────────────────────────────────────────────────────
  Widget _buildContactCard(EmergencyContact contact, int index) {
    final colors = [
      _SafetyColors.accent,
      _SafetyColors.teal,
      const Color(0xFFE67700),
    ];
    final lightColors = [
      _SafetyColors.accentLight,
      _SafetyColors.tealSoft,
      const Color(0xFFFFF3BF),
    ];
    final chipColor = colors[index % colors.length];
    final chipLight = lightColors[index % lightColors.length];
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _SafetyColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: chipColor.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: chipColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: chipLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w700,
                    color: chipColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                      color: _SafetyColors.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 11,
                        color: _SafetyColors.inkLight,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          contact.phone ?? 'No number',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s9,
                            color: _SafetyColors.inkMid,
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
            const SizedBox(width: 8),
            // Trusted badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: _SafetyColors.tealSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 10,
                    color: _SafetyColors.teal,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Trusted',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s7,
                      fontWeight: FontWeight.w600,
                      color: _SafetyColors.teal,
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
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _SafetyColors.iconBadgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Trusted Contacts',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w700,
                    color: _SafetyColors.ink,
                  ),
                ),
              ],
            ),
            // FIX: Manage only shows when there are existing contacts,
            // and navigates to the management screen then reloads.
            if (_emergencyContacts.isNotEmpty)
              GestureDetector(
                onTap: _navigateToManage,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _SafetyColors.accentLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 12,
                        color: _SafetyColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Manage',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s9,
                          fontWeight: FontWeight.w600,
                          color: _SafetyColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'These contacts will be notified in case of emergency',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s9,
            color: _SafetyColors.inkMid,
          ),
        ),
        const SizedBox(height: 12),

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
                  color: filled ? _SafetyColors.accent : _SafetyColors.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
            const SizedBox(width: 8),
            Text(
              '${_emergencyContacts.length} / 3 slots filled',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                fontWeight: FontWeight.w500,
                color: _emergencyContacts.length >= 3
                    ? const Color(0xFFE67700)
                    : _SafetyColors.inkMid,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Loading
        if (_isLoadingContacts)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(
                color: _SafetyColors.accent,
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
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: _SafetyColors.accentLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _SafetyColors.accent.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    color: _SafetyColors.accent,
                    size: 8.w,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No trusted contacts yet',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w600,
                      color: _SafetyColors.accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to add up to 3 emergency contacts',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s9,
                      color: _SafetyColors.accent.withValues(alpha: 0.7),
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

        // Add another (if slots remain and have existing contacts)
        if (!_isLoadingContacts &&
            _emergencyContacts.isNotEmpty &&
            _emergencyContacts.length < 3) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: _navigateToAdd,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: _SafetyColors.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _SafetyColors.accent.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _SafetyColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add another contact',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s10,
                      fontWeight: FontWeight.w600,
                      color: _SafetyColors.accent,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _SafetyColors.ink),
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
            color: _NC.ink,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _SafetyColors.divider),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero header
              Container(
                color: Colors.white,
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
                        color: _SafetyColors.ink,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    Text(
                      'Here are some measures and provisions to ensure your safety.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s10,
                        color: _SafetyColors.inkMid,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    // GestureDetector(
                    //   onTap: () {},
                    //   child: Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       Text(
                    //         'Know more',
                    //         style: TextStyle(
                    //           fontFamily: 'Poppins',
                    //           fontSize: FontSize.s10,
                    //           fontWeight: FontWeight.w600,
                    //           color: _SafetyColors.accent,
                    //         ),
                    //       ),
                    //       SizedBox(width: 1.w),
                    //       const Icon(
                    //         Icons.arrow_forward_rounded,
                    //         size: 14,
                    //         color: _SafetyColors.accent,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),

              // Auto-sliding cards
              GestureDetector(
                onPanDown: (_) => setState(() => _isUserInteracting = true),
                onPanCancel: () => setState(() => _isUserInteracting = false),
                onPanEnd: (_) => setState(() => _isUserInteracting = false),
                child: SizedBox(
                  height: 24.h,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (p) => setState(() => _currentPage = p),
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
                          gradientColors: safetyCards[index]['gradientColors'],
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
              _buildDotIndicator(),
              SizedBox(height: 3.h),

              // Settings section
              Padding(
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
                        color: _SafetyColors.ink,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    _buildTrustedContactsSection(),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CommonBottomNav(
        selectedIndex: selectedIndex,
        onIndexChanged: (index) => setState(() => selectedIndex = index),
        selectedIconColor: CommonColors.appYellowColor,
        unselectedIconColor: CommonColors.blackColor,
      ),
    );
  }
}
