import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/common_colors.dart';
import '../utils/common_images.dart';
import '../utils/screen_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────

enum ReferralStatus { pending, completed, expired }

class ReferralEntry {
  final String name;
  final String initials;
  final String date;
  final double reward;
  final ReferralStatus status;

  const ReferralEntry({
    required this.name,
    required this.initials,
    required this.date,
    required this.reward,
    required this.status,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTERS
// ─────────────────────────────────────────────────────────────────────────────

class TicketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final mainPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double radius = 5.w;
    final double circleRadius = 4.w;

    Path buildPath() {
      final path = Path();
      path.moveTo(radius, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, (size.height / 2) - circleRadius);
      path.arcToPoint(
        Offset(size.width, (size.height / 2) + circleRadius),
        radius: Radius.circular(circleRadius),
        clockwise: false,
      );
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(
          size.width, size.height, size.width - radius, size.height);
      path.lineTo(radius, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - radius);
      path.lineTo(0, (size.height / 2) + circleRadius);
      path.arcToPoint(
        Offset(0, (size.height / 2) - circleRadius),
        radius: Radius.circular(circleRadius),
        clockwise: false,
      );
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
      path.close();
      return path;
    }

    canvas.drawPath(buildPath().shift(const Offset(0, 3)), shadowPaint);
    canvas.drawPath(buildPath(), mainPaint);

    // Dashed centre divider
    final dashedPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const double dashW = 5.0;
    const double dashGap = 4.0;
    double startX = 6.w.toDouble();
    final double midY = size.height / 2;
    while (startX < size.width - 6.w) {
      canvas.drawLine(
          Offset(startX, midY), Offset(startX + dashW, midY), dashedPaint);
      startX += dashW + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class MilestonePainter extends CustomPainter {
  final double progress;

  const MilestonePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final track = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.fill;
    final fill = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF7ECBA1), Color(0xFF4BB7DE)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final r = Radius.circular(size.height / 2);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height), r),
        track);
    if (progress > 0) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(
                  0, 0, size.width * progress.clamp(0.0, 1.0), size.height),
              r),
          fill);
    }
  }

  @override
  bool shouldRepaint(MilestonePainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN  ← class name kept as `refer` to match existing routes
// ─────────────────────────────────────────────────────────────────────────────

class refer extends StatefulWidget {
  const refer({super.key});

  @override
  State<refer> createState() => _ReferState();
}

class _ReferState extends State<refer> with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  bool _copied = false;

  // ── Config ────────────────────────────────────────────────────────────────
  static const String _referralCode = "AO12345";
  static const String _downloadLink =
      "https://adventureoutdoors.app/download";
  static const int _totalMilestone = 20;

  String get _shareMessage => '''🏔️ Join thousands of trekkers on AdventureOutdoors!

🎁 Get ₹50 off on your FIRST trek booking — no conditions!
Use my referral code *$_referralCode* & get cashback when you complete your first trek TODAY.

Experience breathtaking trails, expert guides & unforgettable Himalayan adventures anytime!

📲 Download the app here: $_downloadLink''';

  // ── Animations ────────────────────────────────────────────────────────────
  late final AnimationController _heroCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  late final Animation<double> _heroFade =
      CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
  late final Animation<Offset> _heroSlide = Tween<Offset>(
    begin: const Offset(0, 0.12),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));
  late final Animation<double> _pulse =
      Tween<double>(begin: 0.97, end: 1.03).animate(
    CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
  );

  // ── Mock referral data ────────────────────────────────────────────────────
  final List<ReferralEntry> _referrals = const [
    ReferralEntry(
      name: "Priya Sharma",
      initials: "PS",
      date: "14 Apr 2025",
      reward: 50,
      status: ReferralStatus.completed,
    ),
    ReferralEntry(
      name: "Rahul Verma",
      initials: "RV",
      date: "10 Apr 2025",
      reward: 50,
      status: ReferralStatus.completed,
    ),
    ReferralEntry(
      name: "Ananya Singh",
      initials: "AS",
      date: "7 Apr 2025",
      reward: 50,
      status: ReferralStatus.pending,
    ),
    ReferralEntry(
      name: "Kiran Patel",
      initials: "KP",
      date: "2 Apr 2025",
      reward: 50,
      status: ReferralStatus.expired,
    ),
  ];

  int get _completedCount =>
      _referrals.where((r) => r.status == ReferralStatus.completed).length;

  double get _totalRewards => _referrals
      .where((r) => r.status == ReferralStatus.completed)
      .fold(0.0, (s, r) => s + r.reward);

  @override
  void dispose() {
    _heroCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHARE  — uses url_launcher deep links; falls back to clipboard
  // ─────────────────────────────────────────────────────────────────────────

  void _openShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareBottomSheet(
        message: _shareMessage,
        referralCode: _referralCode,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _heroFade,
        child: SlideTransition(
          position: _heroSlide,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.5.w),
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  _buildHeroBanner(),
                  SizedBox(height: 3.h),
                  _buildMilestoneTracker(),
                  SizedBox(height: 3.h),
                  _buildReferralCodeTicket(),
                  SizedBox(height: 3.h),
                  _buildTabBar(),
                  SizedBox(height: 2.h),
                  _selectedTabIndex == 0
                      ? _buildHowItWorksTab()
                      : _buildHistoryTab(),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF7F9FC),
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: true,
      centerTitle: false,
      iconTheme: IconThemeData(color: CommonColors.blackColor),
      title: Text(
        'Refer & Earn',
        style: GoogleFonts.poppins(
          fontSize: FontSize.s16,
          fontWeight: FontWeight.w600,
          color: CommonColors.blackColor,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: GestureDetector(
            onTap: _openShareSheet,
            child: Container(
              padding: EdgeInsets.all(2.2.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.ios_share_rounded,
                color: const Color(0xFF4BB7DE),
                size: 5.5.w,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HERO BANNER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF52C4A0), Color(0xFF38A8D8), Color(0xFF2D86D4)],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38A8D8).withValues(alpha: 0.40),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -4.w,
            right: -4.w,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -5.w,
            right: 18.w,
            child: Container(
              width: 13.w,
              height: 13.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Text(
                  '🎁  Limited Offer',
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s9,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Refer & Earn',
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        Text(
                          'Up to ₹1,000!',
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        _benefitRow('💰', 'You earn ₹50 per referral'),
                        SizedBox(height: 1.h),
                        _benefitRow('🤝', 'Friend gets ₹50 off first trek'),
                        SizedBox(height: 1.h),
                        _benefitRow('🏆', '₹1,000 bonus after 20 referrals'),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Image.asset(
                    CommonImages.referandearn,
                    width: 26.w,
                    height: 14.h,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _benefitRow(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: TextStyle(fontSize: FontSize.s10)),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: FontSize.s9,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MILESTONE TRACKER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMilestoneTracker() {
    final double progress = _completedCount / _totalMilestone;
    final int remaining = _totalMilestone - _completedCount;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹1,000 Milestone',
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s12,
                      fontWeight: FontWeight.w600,
                      color: CommonColors.blackColor,
                    ),
                  ),
                  Text(
                    remaining > 0
                        ? '$remaining more referrals to go!'
                        : '🎉 Milestone reached!',
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s9,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7ECBA1), Color(0xFF4BB7DE)],
                  ),
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Text(
                  '$_completedCount / $_totalMilestone',
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          CustomPaint(
            size: Size(double.infinity, 1.2.h),
            painter: MilestonePainter(progress: progress),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0',
                  style: GoogleFonts.poppins(
                      fontSize: FontSize.s8, color: Colors.grey.shade500)),
              Text('20',
                  style: GoogleFonts.poppins(
                      fontSize: FontSize.s8, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REFERRAL CODE TICKET
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildReferralCodeTicket() {
    return SizedBox(
      height: 14.h,
      child: CustomPaint(
        painter: TicketPainter(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(Icons.confirmation_number_outlined,
                      color: const Color(0xFF4BB7DE), size: 5.w),
                  SizedBox(width: 2.w),
                  Text(
                    'Your Referral Code',
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Code pill
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 5.w, vertical: 0.8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0004FF).withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(2.5.w),
                      border: Border.all(
                        color: const Color(0xFF0004FF).withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      _referralCode,
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: const Color(0xFF2D2D8E),
                      ),
                    ),
                  ),

                  // Copy button
                  GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(
                          const ClipboardData(text: _referralCode));
                      HapticFeedback.lightImpact();
                      setState(() => _copied = true);
                      await Future.delayed(
                          const Duration(milliseconds: 1500));
                      if (mounted) setState(() => _copied = false);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _copied
                              ? [
                                  const Color(0xFF52C4A0),
                                  const Color(0xFF3DAD8A)
                                ]
                              : [
                                  const Color(0xFF9CB0FF),
                                  const Color(0xFF6B8EFF)
                                ],
                        ),
                        borderRadius: BorderRadius.circular(8.w),
                        boxShadow: [
                          BoxShadow(
                            color: (_copied
                                    ? const Color(0xFF52C4A0)
                                    : const Color(0xFF6B8EFF))
                                .withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _copied
                            ? Row(
                                key: const ValueKey('check'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_rounded,
                                      color: Colors.white, size: 4.w),
                                  SizedBox(width: 1.5.w),
                                  Text('Copied!',
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      )),
                                ],
                              )
                            : Row(
                                key: const ValueKey('copy'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.copy_rounded,
                                      color: Colors.white, size: 4.w),
                                  SizedBox(width: 1.5.w),
                                  Text('Copy',
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      )),
                                ],
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

  // ─────────────────────────────────────────────────────────────────────────
  // TAB BAR
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      height: 6.h,
      padding: EdgeInsets.all(0.8.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Row(
        children: [
          _tabPill('How it Works', 0),
          _tabPill('Referral History', 1),
        ],
      ),
    );
  }

  Widget _tabPill(String title, int index) {
    final bool sel = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: sel ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(2.5.w),
            boxShadow: sel
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: FontSize.s10,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                color: sel ? CommonColors.blackColor : Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HOW IT WORKS TAB
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHowItWorksTab() {
    return Column(
      children: [
        _stepCard(
          stepNum: 1,
          icon: Icons.share_rounded,
          title: 'Share Your Code',
          description:
              'Share your referral link via WhatsApp, SMS, email, or any platform you love.',
          gradientColors: [const Color(0xFF7ECBA1), const Color(0xFF52C4A0)],
        ),
        SizedBox(height: 2.h),
        _stepCard(
          stepNum: 2,
          icon: Icons.person_add_rounded,
          title: 'Friend Signs Up',
          description:
              'Your friend downloads the app, registers, and books their first trek.',
          gradientColors: [const Color(0xFF5FC3E4), const Color(0xFF38A8D8)],
        ),
        SizedBox(height: 2.h),
        _stepCard(
          stepNum: 3,
          icon: Icons.currency_rupee_rounded,
          title: 'Both Earn Rewards',
          description:
              'You get ₹50 cashback and your friend gets ₹50 off — everyone wins!',
          gradientColors: [const Color(0xFF7B8EFF), const Color(0xFF5B6BFF)],
        ),
        SizedBox(height: 4.h),
        _referNowButton(),
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _stepCard({
    required int stepNum,
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon tile with step badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 13.w,
                height: 13.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(3.5.w),
                ),
                child: Center(
                  child: Icon(icon, color: Colors.white, size: 6.w),
                ),
              ),
              Positioned(
                top: -1.w,
                right: -1.w,
                child: Container(
                  width: 4.5.w,
                  height: 4.5.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$stepNum',
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s8,
                        fontWeight: FontWeight.w700,
                        color: gradientColors.last,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s12,
                    fontWeight: FontWeight.w600,
                    color: CommonColors.blackColor,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s9,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REFER NOW BUTTON  ← single button, opens share bottom sheet
  // ─────────────────────────────────────────────────────────────────────────

  Widget _referNowButton() {
    return ScaleTransition(
      scale: _pulse,
      child: GestureDetector(
        onTap: _openShareSheet,
        child: Container(
          width: double.infinity,
          height: 7.5.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF52C4A0),
                Color(0xFF38A8D8),
                Color(0xFF2D86D4)
              ],
              stops: [0.0, 0.55, 1.0],
            ),
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38A8D8).withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.ios_share_rounded,
                  color: Colors.white, size: 5.5.w),
              SizedBox(width: 3.w),
              Text(
                'Refer Now & Earn ₹50',
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REFERRAL HISTORY TAB
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHistoryTab() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                label: 'Total Earned',
                value: '₹${_totalRewards.toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet_rounded,
                colors: [const Color(0xFF52C4A0), const Color(0xFF38A8D8)],
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _summaryCard(
                label: 'Successful',
                value: '$_completedCount',
                icon: Icons.people_alt_rounded,
                colors: [const Color(0xFF7B8EFF), const Color(0xFF5B6BFF)],
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        if (_referrals.isEmpty)
          _emptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _referrals.length,
            separatorBuilder: (_, __) => SizedBox(height: 2.h),
            itemBuilder: (_, i) => _referralTile(_referrals[i]),
          ),
        SizedBox(height: 3.h),
        _referNowButton(),
      ],
    );
  }

  Widget _summaryCard({
    required String label,
    required String value,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 6.w),
          SizedBox(height: 1.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: FontSize.s18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
          ),
          SizedBox(height: 0.3.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: FontSize.s9,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _referralTile(ReferralEntry entry) {
    final cfg = _statusConfig(entry.status);
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 11.w,
            height: 11.w,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7ECBA1), Color(0xFF4BB7DE)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                entry.initials,
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name,
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w600,
                      color: CommonColors.blackColor,
                    )),
                Text(entry.date,
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s9,
                      color: Colors.grey.shade500,
                    )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.status == ReferralStatus.completed
                    ? '+₹${entry.reward.toStringAsFixed(0)}'
                    : '₹${entry.reward.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w700,
                  color: entry.status == ReferralStatus.completed
                      ? const Color(0xFF2EAF7D)
                      : Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 0.4.h),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
                decoration: BoxDecoration(
                  color: cfg['bg'] as Color,
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Text(
                  cfg['label'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s8,
                    fontWeight: FontWeight.w600,
                    color: cfg['text'] as Color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _statusConfig(ReferralStatus s) {
    switch (s) {
      case ReferralStatus.completed:
        return {
          'label': 'Completed',
          'bg': const Color(0xFF2EAF7D).withValues(alpha: 0.12),
          'text': const Color(0xFF1E7D57),
        };
      case ReferralStatus.pending:
        return {
          'label': 'Pending',
          'bg': const Color(0xFFF59E0B).withValues(alpha: 0.12),
          'text': const Color(0xFFB45309),
        };
      case ReferralStatus.expired:
        return {
          'label': 'Expired',
          'bg': Colors.grey.shade200,
          'text': Colors.grey.shade600,
        };
    }
  }

  Widget _emptyState() {
    return Column(
      children: [
        SizedBox(height: 6.h),
        Icon(Icons.group_add_rounded, size: 18.w, color: Colors.grey.shade300),
        SizedBox(height: 2.h),
        Text('No referrals yet',
            style: GoogleFonts.poppins(
              fontSize: FontSize.s14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            )),
        SizedBox(height: 0.5.h),
        Text('Invite your friends and start earning!',
            style: GoogleFonts.poppins(
              fontSize: FontSize.s10,
              color: Colors.grey.shade400,
            )),
        SizedBox(height: 6.h),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARE BOTTOM SHEET
// Uses url_launcher deep links — no share_plus needed.
// Add to pubspec if not present:  url_launcher: ^6.3.0
// ─────────────────────────────────────────────────────────────────────────────

class _ShareBottomSheet extends StatelessWidget {
  final String message;
  final String referralCode;

  const _ShareBottomSheet({
    required this.message,
    required this.referralCode,
  });

  Future<void> _launchWhatsApp() async {
    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse('whatsapp://send?text=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchSMS() async {
    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse('sms:?body=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail() async {
    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse(
        'mailto:?subject=${Uri.encodeComponent("Join AdventureOutdoors & get ₹50 off!")}&body=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: message));
    HapticFeedback.lightImpact();
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Referral message copied!',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          backgroundColor: const Color(0xFF52C4A0),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 2.5.h),

          Text(
            'Share via',
            style: GoogleFonts.poppins(
              fontSize: FontSize.s14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Invite friends using your favourite app',
            style: GoogleFonts.poppins(
              fontSize: FontSize.s9,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 3.h),

          // Share options grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareOption(
                label: 'WhatsApp',
                icon: Icons.chat_rounded,
                color: const Color(0xFF25D366),
                onTap: _launchWhatsApp,
              ),
              _ShareOption(
                label: 'SMS',
                icon: Icons.sms_rounded,
                color: const Color(0xFF3B82F6),
                onTap: _launchSMS,
              ),
              _ShareOption(
                label: 'Email',
                icon: Icons.email_rounded,
                color: const Color(0xFFEA4335),
                onTap: _launchEmail,
              ),
              _ShareOption(
                label: 'Copy Link',
                icon: Icons.copy_rounded,
                color: const Color(0xFF6B7280),
                onTap: () => _copyLink(context),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Preview of share message
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Message Preview',
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s9,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s9,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 6.5.w),
          ),
          SizedBox(height: 0.8.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: FontSize.s8,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}