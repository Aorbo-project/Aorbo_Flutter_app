import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/referral_controller.dart';
import '../models/referral/referral_models.dart';
import '../utils/common_colors.dart';
import '../utils/common_images.dart';
import '../utils/screen_constants.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTERS  (unchanged — pure visuals)
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
// MAIN SCREEN  — class name kept `refer` to match route '/refers'
// Fully dynamic: every number, label, reward line and the share message
// come from ReferralController.info (the backend's live config). Nothing
// about the economics is hardcoded here.
// ─────────────────────────────────────────────────────────────────────────────

class refer extends StatefulWidget {
  const refer({super.key});

  @override
  State<refer> createState() => _ReferState();
}

class _ReferState extends State<refer> with TickerProviderStateMixin {
  final ReferralController c = Get.put(ReferralController());

  int _selectedTabIndex = 0;
  bool _copied = false;

  // Created eagerly in initState (NOT lazy `late` initialisers) — the screen
  // can unmount from the loading/error branch before build ever touches an
  // animation, and a lazy field would then be force-created inside dispose().
  late final AnimationController _heroCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));
    _pulse = Tween<double>(begin: 0.97, end: 1.03).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Share ─────────────────────────────────────────────────────────────────

  void _openShareSheet() {
    final info = c.info;
    if (info == null || (info.shareMessage ?? '').isEmpty) return;
    FirebaseCrashlytics.instance.log('Popup: Refer & earn share sheet');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareBottomSheet(
        message: info.shareMessage!,
        code: info.code ?? '',
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: _buildAppBar(),
      body: Obx(() {
        if (c.isLoading) return _loadingState();
        if (c.hasError) return _errorState(c.errorMessage);
        if (!c.programEnabled) return _programPausedState();

        final info = c.info;
        if (info == null) return _errorState(null);

        return RefreshIndicator(
          onRefresh: c.reload,
          child: FadeTransition(
            opacity: _heroFade,
            child: SlideTransition(
              position: _heroSlide,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                  child: Column(
                    children: [
                      SizedBox(height: 2.h),
                      _buildHeroBanner(info),
                      SizedBox(height: 3.h),
                      // A friend's referral code is entered on the login
                      // screen only — not here.
                      if (info.milestone?.enabled == true) ...[
                        _buildMilestoneTracker(info.milestone!),
                        SizedBox(height: 3.h),
                      ],
                      _buildReferralCodeTicket(info.code),
                      SizedBox(height: 3.h),
                      _buildTabBar(),
                      SizedBox(height: 2.h),
                      _selectedTabIndex == 0
                          ? _buildHowItWorksTab(info)
                          : _buildHistoryTab(info),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Non-data states ───────────────────────────────────────────────────────

  Widget _loadingState() => const Center(child: CircularProgressIndicator());

  Widget _errorState(String? message) => Center(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded,
                  size: 16.w, color: Colors.grey.shade300),
              SizedBox(height: 2.h),
              Text(
                message?.isNotEmpty == true
                    ? message!
                    : "Couldn't load Refer & Earn",
                textAlign: TextAlign.center,
                style: AppType.style(FontSize.s12, color: Colors.grey.shade600),
              ),
              SizedBox(height: 2.5.h),
              OutlinedButton.icon(
                onPressed: c.load,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('Retry', style: AppType.style(FontSize.s11)),
              ),
            ],
          ),
        ),
      );

  Widget _programPausedState() => Center(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pause_circle_outline_rounded,
                  size: 16.w, color: Colors.grey.shade300),
              SizedBox(height: 2.h),
              Text('Referrals are paused right now',
                  style: AppType.style(FontSize.s14,
                      w: FontWeight.w600, color: Colors.grey.shade600)),
              SizedBox(height: 0.5.h),
              Text('Check back soon — we’ll bring this back.',
                  textAlign: TextAlign.center,
                  style: AppType.style(FontSize.s10, color: Colors.grey.shade400)),
            ],
          ),
        ),
      );

  // ── App bar ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF7F9FC),
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: CommonColors.blackColor),
      title: Text('Refer & Earn',
          style: AppType.style(FontSize.s16,
              w: FontWeight.w600, color: CommonColors.blackColor)),
      actions: [
        Obx(() {
          final ready = c.info?.shareMessage?.isNotEmpty == true;
          return Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: GestureDetector(
              onTap: ready ? _openShareSheet : null,
              child: Container(
                padding: EdgeInsets.all(2.2.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Icon(Icons.ios_share_rounded,
                    color: ready
                        ? const Color(0xFF4BB7DE)
                        : Colors.grey.shade300,
                    size: 5.5.w),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Hero banner ───────────────────────────────────────────────────────────

  Widget _buildHeroBanner(ReferralInfo info) {
    final reward = info.reward;
    final referrerLine = (reward?.referrerText ?? '').isNotEmpty
        ? reward!.referrerText!
        : 'Earn a reward for every friend who treks';
    final refereeLine = (reward?.refereeText ?? '').isNotEmpty
        ? reward!.refereeText!
        : 'Your friend gets a discount on their first trek';

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
              blurRadius: 20),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -4.w,
            right: -4.w,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Text('🎁  Invite & Earn',
                    style: AppType.style(FontSize.s9,
                        w: FontWeight.w500, color: Colors.white)),
              ),
              SizedBox(height: 1.5.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Refer a friend to AORBO Treks',
                            style: AppType.style(FontSize.s13,
                                w: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.9))),
                        SizedBox(height: 1.5.h),
                        _benefitRow('💰', referrerLine),
                        SizedBox(height: 1.h),
                        _benefitRow('🤝', refereeLine),
                        if (info.milestone?.enabled == true &&
                            (info.milestone?.bonusText ?? '').isNotEmpty) ...[
                          SizedBox(height: 1.h),
                          _benefitRow('🏆', info.milestone!.bonusText!),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Image.asset(CommonImages.referandearn,
                      width: 26.w, height: 14.h, fit: BoxFit.contain),
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
        Text(emoji,
            style: TextStyle(fontSize: AppType.clampFontSize(FontSize.s10))),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(text,
              style: AppType.style(FontSize.s9,
                  color: Colors.white.withValues(alpha: 0.9), height: 1.3)),
        ),
      ],
    );
  }

  // ── Milestone tracker ─────────────────────────────────────────────────────

  Widget _buildMilestoneTracker(ReferralMilestone m) {
    final int target = m.target <= 0 ? 1 : m.target;
    final double progress = (m.current / target).clamp(0.0, 1.0);
    final int remaining = (target - m.current).clamp(0, target);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (m.bonusText ?? 'Bonus milestone'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.style(FontSize.s12,
                          w: FontWeight.w600, color: CommonColors.blackColor),
                    ),
                    Text(
                      remaining > 0
                          ? '$remaining more to go!'
                          : '🎉 Milestone reached!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.style(FontSize.s9,
                          color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF7ECBA1), Color(0xFF4BB7DE)]),
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Text('${m.current} / $target',
                    style: AppType.style(FontSize.s10,
                        w: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          CustomPaint(
            size: Size(double.infinity, 1.2.h),
            painter: MilestonePainter(progress: progress),
          ),
        ],
      ),
    );
  }

  // ── Referral code ticket ──────────────────────────────────────────────────

  Widget _buildReferralCodeTicket(String? code) {
    final hasCode = (code ?? '').isNotEmpty;
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
                  Text('Your Referral Code',
                      style: AppType.style(FontSize.s10,
                          color: Colors.grey.shade600)),
                ],
              ),
              SizedBox(height: 1.2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 5.w, vertical: 0.8.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0004FF).withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(2.5.w),
                        border: Border.all(
                            color:
                                const Color(0xFF0004FF).withValues(alpha: 0.15)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          hasCode ? code! : 'Setting up…',
                          style: AppType.style(FontSize.s14,
                              w: FontWeight.w700,
                              color: const Color(0xFF2D2D8E),
                              letterSpacing: hasCode ? 3 : 0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: hasCode
                        ? () async {
                            await Clipboard.setData(
                                ClipboardData(text: code!));
                            HapticFeedback.lightImpact();
                            setState(() => _copied = true);
                            await Future.delayed(
                                const Duration(milliseconds: 1500));
                            if (mounted) setState(() => _copied = false);
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: !hasCode
                              ? [Colors.grey.shade300, Colors.grey.shade300]
                              : _copied
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
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Row(
                          key: ValueKey(_copied),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                                _copied
                                    ? Icons.check_rounded
                                    : Icons.copy_rounded,
                                color: Colors.white,
                                size: 4.w),
                            SizedBox(width: 1.5.w),
                            Text(_copied ? 'Copied!' : 'Copy',
                                style: AppType.style(FontSize.s10,
                                    w: FontWeight.w600, color: Colors.white)),
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

  // ── Tab bar ───────────────────────────────────────────────────────────────

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
          _tabPill('History', 1),
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
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Center(
            child: Text(title,
                style: AppType.style(FontSize.s10,
                    w: sel ? FontWeight.w600 : FontWeight.w500,
                    color:
                        sel ? CommonColors.blackColor : Colors.grey.shade500)),
          ),
        ),
      ),
    );
  }

  // ── How it works ──────────────────────────────────────────────────────────

  Widget _buildHowItWorksTab(ReferralInfo info) {
    final r = info.reward;
    return Column(
      children: [
        _stepCard(
          stepNum: 1,
          icon: Icons.share_rounded,
          title: 'Share Your Code',
          description:
              'Send your code to a friend over WhatsApp, SMS or anywhere.',
          gradientColors: [const Color(0xFF7ECBA1), const Color(0xFF52C4A0)],
        ),
        SizedBox(height: 2.h),
        _stepCard(
          stepNum: 2,
          icon: Icons.person_add_rounded,
          title: 'Friend Signs Up & Treks',
          description: (r?.refereeText ?? '').isNotEmpty
              ? '${r!.refereeText!} when they enter your code, then they book and complete their first trek.'
              : 'They enter your code, book, and complete their first trek.',
          gradientColors: [const Color(0xFF5FC3E4), const Color(0xFF38A8D8)],
        ),
        SizedBox(height: 2.h),
        _stepCard(
          stepNum: 3,
          icon: Icons.card_giftcard_rounded,
          title: 'You Get Rewarded',
          description: (r?.referrerText ?? '').isNotEmpty
              ? r!.referrerText!
              : 'Your reward coupon lands once their trek is done.',
          gradientColors: [const Color(0xFF7B8EFF), const Color(0xFF5B6BFF)],
        ),
        SizedBox(height: 3.h),
        if ((info.program?.termsUrl ?? '').isNotEmpty)
          GestureDetector(
            onTap: () => launchUrl(Uri.parse(info.program!.termsUrl!),
                mode: LaunchMode.externalApplication),
            child: Text('Terms & conditions apply',
                style: AppType.style(FontSize.s9,
                    color: const Color(0xFF4BB7DE),
                    w: FontWeight.w500)),
          ),
        SizedBox(height: 3.h),
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
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
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
                    child: Icon(icon, color: Colors.white, size: 6.w)),
              ),
              Positioned(
                top: -1.w,
                right: -1.w,
                child: Container(
                  width: 4.5.w,
                  height: 4.5.w,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Center(
                    child: Text('$stepNum',
                        style: AppType.style(FontSize.s8,
                            w: FontWeight.w700, color: gradientColors.last)),
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
                Text(title,
                    style: AppType.style(FontSize.s12,
                        w: FontWeight.w600, color: CommonColors.blackColor)),
                SizedBox(height: 0.4.h),
                Text(description,
                    style: AppType.style(FontSize.s9,
                        color: Colors.grey.shade600, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
              colors: [Color(0xFF52C4A0), Color(0xFF38A8D8), Color(0xFF2D86D4)],
              stops: [0.0, 0.55, 1.0],
            ),
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF38A8D8).withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.ios_share_rounded, color: Colors.white, size: 5.5.w),
              SizedBox(width: 3.w),
              Flexible(
                child: Text('Invite a Friend',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.style(FontSize.s13,
                        w: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── History ───────────────────────────────────────────────────────────────

  Widget _buildHistoryTab(ReferralInfo info) {
    final stats = info.stats ?? const ReferralStats();
    final history = info.history ?? const <ReferralEntry>[];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                label: 'Total Earned',
                value: '₹${stats.totalEarned.toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet_rounded,
                colors: [const Color(0xFF52C4A0), const Color(0xFF38A8D8)],
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _summaryCard(
                label: 'Successful',
                value: '${stats.rewarded}',
                icon: Icons.people_alt_rounded,
                colors: [const Color(0xFF7B8EFF), const Color(0xFF5B6BFF)],
              ),
            ),
          ],
        ),
        if (stats.pending > 0) ...[
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Text(
              '${stats.pending} friend${stats.pending == 1 ? '' : 's'} yet to complete a trek — your reward unlocks when they do.',
              style: AppType.style(FontSize.s9,
                  color: const Color(0xFFB45309), height: 1.3),
            ),
          ),
        ],
        SizedBox(height: 3.h),
        if (history.isEmpty)
          _emptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            separatorBuilder: (_, __) => SizedBox(height: 2.h),
            itemBuilder: (_, i) => _referralTile(history[i]),
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
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 6.w),
          SizedBox(height: 1.h),
          Text(value,
              style: AppType.style(FontSize.s18,
                  w: FontWeight.w700, color: Colors.white, height: 1)),
          SizedBox(height: 0.3.h),
          Text(label,
              style: AppType.style(FontSize.s9,
                  color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  Widget _referralTile(ReferralEntry entry) {
    final cfg = _statusConfig(entry.parsedStatus);
    final name = (entry.friendName ?? '').isNotEmpty ? entry.friendName! : 'A friend';
    final initials = name.trim().isNotEmpty
        ? name.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0]).join().toUpperCase()
        : '•';
    final d = entry.parsedDate;
    final dateStr = d == null
        ? ''
        : '${d.day.toString().padLeft(2, '0')} ${_month(d.month)} ${d.year}';
    final rewardVal = (entry.rewardValue ?? 0);
    final rewardStr = (entry.rewardIsPercent ?? false)
        ? '${rewardVal.toStringAsFixed(0)}%'
        : '₹${rewardVal.toStringAsFixed(0)}';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 11.w,
            height: 11.w,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF7ECBA1), Color(0xFF4BB7DE)]),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(initials,
                    style: AppType.style(FontSize.s11,
                        w: FontWeight.w700, color: Colors.white))),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppType.style(FontSize.s11,
                        w: FontWeight.w600, color: CommonColors.blackColor)),
                if (dateStr.isNotEmpty)
                  Text(dateStr,
                      style: AppType.style(FontSize.s9,
                          color: Colors.grey.shade500)),
                if ((entry.note ?? '').isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 0.3.h),
                    child: Text(entry.note!,
                        style: AppType.style(FontSize.s8,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic)),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.parsedStatus == ReferralStatus.rewarded
                    ? '+$rewardStr'
                    : rewardStr,
                style: AppType.style(FontSize.s12,
                    w: FontWeight.w700,
                    color: entry.parsedStatus == ReferralStatus.rewarded
                        ? const Color(0xFF2EAF7D)
                        : Colors.grey.shade500),
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
                  (entry.statusLabel ?? cfg['label'] as String),
                  style: AppType.style(FontSize.s8,
                      w: FontWeight.w600, color: cfg['text'] as Color),
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
      case ReferralStatus.rewarded:
        return {
          'label': 'Completed',
          'bg': const Color(0xFF2EAF7D).withValues(alpha: 0.12),
          'text': const Color(0xFF1E7D57),
        };
      case ReferralStatus.pending:
        return {
          'label': 'Pending',
          'bg': AppColors.warning.withValues(alpha: 0.12),
          'text': const Color(0xFFB45309),
        };
      case ReferralStatus.reversed:
        return {
          'label': 'Reversed',
          'bg': const Color(0xFFEF4444).withValues(alpha: 0.12),
          'text': const Color(0xFFB91C1C),
        };
      case ReferralStatus.rejected:
        return {
          'label': 'Not eligible',
          'bg': Colors.grey.shade200,
          'text': Colors.grey.shade600,
        };
      case ReferralStatus.expired:
        return {
          'label': 'Expired',
          'bg': Colors.grey.shade200,
          'text': Colors.grey.shade600,
        };
    }
  }

  String _month(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][(m - 1).clamp(0, 11)];

  Widget _emptyState() {
    return Column(
      children: [
        SizedBox(height: 6.h),
        Icon(Icons.group_add_rounded, size: 18.w, color: Colors.grey.shade300),
        SizedBox(height: 2.h),
        Text('No referrals yet',
            style: AppType.style(FontSize.s14,
                w: FontWeight.w600, color: Colors.grey.shade500)),
        SizedBox(height: 0.5.h),
        Text('Invite a friend and start earning!',
            style: AppType.style(FontSize.s10, color: Colors.grey.shade400)),
        SizedBox(height: 6.h),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARE BOTTOM SHEET  — message is fully backend-composed; the sheet only routes
// ─────────────────────────────────────────────────────────────────────────────

class _ShareBottomSheet extends StatelessWidget {
  final String message;
  final String code;

  const _ShareBottomSheet({required this.message, required this.code});

  Future<void> _launch(String scheme) async {
    final encoded = Uri.encodeComponent(message);
    final Uri uri = switch (scheme) {
      'whatsapp' => Uri.parse('whatsapp://send?text=$encoded'),
      'sms' => Uri.parse('sms:?body=$encoded'),
      'email' => Uri.parse(
          'mailto:?subject=${Uri.encodeComponent("Join me on AORBO Treks")}&body=$encoded'),
      _ => Uri.parse('https://wa.me/?text=$encoded'),
    };
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: message));
    HapticFeedback.lightImpact();
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invite message copied!', style: AppType.style(12)),
          backgroundColor: const Color(0xFF52C4A0),
          behavior: SnackBarBehavior.floating,
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
          Container(
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10)),
          ),
          SizedBox(height: 2.5.h),
          Text('Share via', style: AppType.style(FontSize.s14, w: FontWeight.w600)),
          SizedBox(height: 0.5.h),
          Text('Invite a friend using your favourite app',
              style: AppType.style(FontSize.s9, color: Colors.grey.shade500)),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareOption(
                  label: 'WhatsApp',
                  icon: Icons.chat_rounded,
                  color: const Color(0xFF25D366),
                  onTap: () => _launch('whatsapp')),
              _ShareOption(
                  label: 'SMS',
                  icon: Icons.sms_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: () => _launch('sms')),
              _ShareOption(
                  label: 'Email',
                  icon: Icons.email_rounded,
                  color: const Color(0xFFEA4335),
                  onTap: () => _launch('email')),
              _ShareOption(
                  label: 'Copy',
                  icon: Icons.copy_rounded,
                  color: AppColors.inkMid,
                  onTap: () => _copy(context)),
            ],
          ),
          SizedBox(height: 3.h),
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
                Text('Message Preview',
                    style: AppType.style(FontSize.s9,
                        w: FontWeight.w600, color: Colors.grey.shade500)),
                SizedBox(height: 0.8.h),
                Text(message,
                    style: AppType.style(FontSize.s9,
                        color: Colors.grey.shade700, height: 1.5),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis),
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
                color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 6.5.w),
          ),
          SizedBox(height: 0.8.h),
          Text(label,
              style: AppType.style(FontSize.s8,
                  w: FontWeight.w500, color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
