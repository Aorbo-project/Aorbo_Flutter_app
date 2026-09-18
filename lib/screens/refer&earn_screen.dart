import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
// BRAND ICONS  — inline SVG (simple-icons paths), so no asset files or
// pubspec changes are needed. Glyphs are white: they sit on brand-colored
// circles in the share sheet.
// ─────────────────────────────────────────────────────────────────────────────

const String _kWhatsappSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#FFFFFF"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>''';

const String _kGmailSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#FFFFFF"><path d="M24 5.457v13.909c0 .904-.732 1.636-1.636 1.636h-3.819V11.73L12 16.64l-6.545-4.91v9.273H1.636A1.636 1.636 0 010 19.366V5.457c0-2.023 2.309-3.178 3.927-1.964L5.455 4.64 12 9.548l6.545-4.91 1.528-1.145C21.69 2.28 24 3.434 24 5.457z"/></svg>''';

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTERS
// ─────────────────────────────────────────────────────────────────────────────

/// Boarding-pass ticket: rounded corners, side notches at the perforation
/// line, a two-tone fill (gradient header / white stub) and the dashed
/// tear-line. The perforation's Y position is passed in so the painter and
/// the widget layout can never drift apart.
class TicketPainter extends CustomPainter {
  final double perforationY;
  const TicketPainter({required this.perforationY});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = 5.w;
    final double notch = 3.2.w;
    final double py = perforationY.clamp(0.0, size.height);

    Path buildPath() {
      final path = Path();
      path.moveTo(radius, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, py - notch);
      path.arcToPoint(
        Offset(size.width, py + notch),
        radius: Radius.circular(notch),
        clockwise: false,
      );
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      );
      path.lineTo(radius, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - radius);
      path.lineTo(0, py + notch);
      path.arcToPoint(
        Offset(0, py - notch),
        radius: Radius.circular(notch),
        clockwise: false,
      );
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
      path.close();
      return path;
    }

    // Drop shadow beneath the whole ticket.
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(buildPath().shift(const Offset(0, 4)), shadowPaint);

    // White base (the bottom stub).
    canvas.drawPath(buildPath(), Paint()..color = Colors.white);

    // Gradient header, clipped to the ticket shape.
    final headerPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2D86D4), Color(0xFF38A8D8), Color(0xFF45B49B)],
        stops: [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, py));
    canvas.save();
    canvas.clipPath(buildPath());
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, py), headerPaint);
    // Soft translucent circles for depth on the header.
    final deco = Paint()..color = Colors.white.withValues(alpha: 0.07);
    canvas.drawCircle(
      Offset(size.width * 0.88, -size.height * 0.04),
      size.width * 0.22,
      deco,
    );
    canvas.drawCircle(
      Offset(size.width * 0.03, py * 0.96),
      size.width * 0.16,
      deco,
    );
    canvas.restore();

    // Dashed perforation between the notches.
    final dashedPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    const double dashW = 6.0;
    const double dashGap = 4.0;
    double x = notch + 3.w;
    final double endX = size.width - notch - 3.w;
    while (x < endX) {
      canvas.drawLine(Offset(x, py), Offset(x + dashW, py), dashedPaint);
      x += dashW + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant TicketPainter old) =>
      old is TicketPainter && old.perforationY != perforationY;
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
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), r),
      track,
    );
    if (progress > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            0,
            0,
            size.width * progress.clamp(0.0, 1.0),
            size.height,
          ),
          r,
        ),
        fill,
      );
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

  // Set the default tab ONCE per data load (referred → History, not → How
  // it Works) without ever stomping a manual switch on later rebuilds.
  bool _defaultTabApplied = false;

  // Created eagerly in initState (NOT lazy `late` initialisers) — the screen
  // can unmount from the loading/error branch before build ever touches an
  // animation, and a lazy field would then be force-created inside dispose().
  late final AnimationController _heroCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _pulse;

  // Ticket geometry — single source shared by painter + layout so the
  // perforation always lands exactly between header and stub.
  double get _ticketHeight => 20.h;
  double get _ticketPerforationY => _ticketHeight * 0.60;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));
    _pulse = Tween<double>(
      begin: 0.97,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
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
      builder: (_) =>
          _ShareBottomSheet(message: info.shareMessage!, code: info.code ?? ''),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// How many people this user has referred. Prefers the history list;
  /// falls back to the stats counters when the list is empty server-side.
  int _invitedCount(ReferralInfo info) {
    final history = info.history ?? const <ReferralEntry>[];
    if (history.isNotEmpty) return history.length;
    final stats = info.stats;
    if (stats == null) return 0;
    return stats.rewarded + stats.pending;
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

        // Smart default tab — applied once, when data first arrives.
        if (!_defaultTabApplied) {
          _defaultTabApplied = true;
          _selectedTabIndex = _invitedCount(info) > 0 ? 1 : 0;
        }

        return RefreshIndicator(
          onRefresh: c.reload,
          child: FadeTransition(
            opacity: _heroFade,
            child: SlideTransition(
              position: _heroSlide,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
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
                      _buildReferralCodeTicket(info),
                      SizedBox(height: 3.h),
                      _buildTabBar(_invitedCount(info)),
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
          Icon(Icons.wifi_off_rounded, size: 16.w, color: Colors.grey.shade300),
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
          Icon(
            Icons.pause_circle_outline_rounded,
            size: 16.w,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 2.h),
          Text(
            'Referrals are paused right now',
            style: AppType.style(
              FontSize.s14,
              w: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Check back soon — we’ll bring this back.',
            textAlign: TextAlign.center,
            style: AppType.style(FontSize.s10, color: Colors.grey.shade400),
          ),
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
      title: Text(
        'Refer & Earn',
        style: AppType.style(
          FontSize.s16,
          w: FontWeight.w600,
          color: CommonColors.blackColor,
        ),
      ),
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
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.ios_share_rounded,
                  color: ready ? const Color(0xFF4BB7DE) : Colors.grey.shade300,
                  size: 5.5.w,
                ),
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
            blurRadius: 20,
          ),
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
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Text(
                  '🎁  Invite & Earn',
                  style: AppType.style(
                    FontSize.s9,
                    w: FontWeight.w500,
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
                          'Refer a friend to AORBO Treks',
                          style: AppType.style(
                            FontSize.s13,
                            w: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
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
        Text(
          emoji,
          style: TextStyle(fontSize: AppType.clampFontSize(FontSize.s10)),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: AppType.style(
              FontSize.s9,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.3,
            ),
          ),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (m.bonusText ?? 'Bonus milestone'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.style(
                        FontSize.s12,
                        w: FontWeight.w600,
                        color: CommonColors.blackColor,
                      ),
                    ),
                    Text(
                      remaining > 0
                          ? '$remaining more to go!'
                          : '🎉 Milestone reached!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.style(
                        FontSize.s9,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7ECBA1), Color(0xFF4BB7DE)],
                  ),
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Text(
                  '${m.current} / $target',
                  style: AppType.style(
                    FontSize.s10,
                    w: FontWeight.w600,
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
        ],
      ),
    );
  }

  // ── Referral code ticket (boarding-pass redesign) ─────────────────────────

  Widget _buildReferralCodeTicket(ReferralInfo info) {
    final code = info.code;
    final hasCode = (code ?? '').isNotEmpty;
    final int invitedCount = _invitedCount(info);
    final double perfY = _ticketPerforationY;

    return SizedBox(
      height: _ticketHeight,
      child: CustomPaint(
        painter: TicketPainter(perforationY: perfY),
        child: Column(
          children: [
            // ── Header (gradient): label, code tiles, social proof ──
            SizedBox(
              height: perfY,
              child: Padding(
                padding: EdgeInsets.fromLTRB(5.w, 1.6.h, 5.w, 0.9.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number_rounded,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 4.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'YOUR REFERRAL CODE',
                          style: AppType.style(
                            FontSize.s9,
                            w: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.85),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 4.w,
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: hasCode ? _codeTiles(code!) : _codePending(),
                        ),
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.group_rounded,
                          size: 3.2.w,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                        SizedBox(width: 1.5.w),
                        Expanded(
                          child: Text(
                            invitedCount > 0
                                ? '$invitedCount friend${invitedCount == 1 ? '' : 's'} invited — keep sharing!'
                                : 'Share this code to earn your reward',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppType.style(
                              FontSize.s8,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // ── Stub (white): actions ──
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(5.w, 1.4.h, 5.w, 1.4.h),
                child: Row(
                  children: [
                    Expanded(
                      child: _ticketCopyButton(hasCode: hasCode, code: code),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(child: _ticketShareButton()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The code rendered as one frosted tile per character — reads instantly
  /// as "a code to type in", and the outer FittedBox shrinks long codes.
  Widget _codeTiles(String code) {
    final chars = code.trim().toUpperCase().replaceAll(' ', '').split('');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < chars.length; i++) ...[
          if (i > 0) SizedBox(width: 1.5.w),
          Container(
            width: 8.5.w,
            height: 5.2.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(1.8.w),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            alignment: Alignment.center,
            child: Text(
              chars[i],
              style: AppType.style(
                15,
                w: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _codePending() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Text(
        'Setting up…',
        style: AppType.style(
          FontSize.s12,
          w: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _ticketCopyButton({required bool hasCode, required String? code}) {
    return GestureDetector(
      onTap: hasCode
          ? () async {
              await Clipboard.setData(ClipboardData(text: code!));
              HapticFeedback.lightImpact();
              setState(() => _copied = true);
              await Future.delayed(const Duration(milliseconds: 1500));
              if (mounted) setState(() => _copied = false);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 5.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: !hasCode
                ? [Colors.grey.shade300, Colors.grey.shade300]
                : _copied
                ? [const Color(0xFF52C4A0), const Color(0xFF3DAD8A)]
                : [const Color(0xFF9CB0FF), const Color(0xFF6B8EFF)],
          ),
          borderRadius: BorderRadius.circular(2.5.w),
          boxShadow: [
            BoxShadow(
              color:
                  (_copied ? const Color(0xFF52C4A0) : const Color(0xFF6B8EFF))
                      .withValues(alpha: hasCode ? 0.35 : 0.0),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Row(
            key: ValueKey(_copied),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _copied ? Icons.check_rounded : Icons.copy_rounded,
                color: Colors.white,
                size: 4.w,
              ),
              SizedBox(width: 1.5.w),
              Flexible(
                child: Text(
                  _copied ? 'Copied!' : 'Copy Code',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppType.style(
                    FontSize.s10,
                    w: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ticketShareButton() {
    return GestureDetector(
      onTap: _openShareSheet,
      child: Container(
        height: 5.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2.5.w),
          border: Border.all(
            color: const Color(0xFF38A8D8).withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.ios_share_rounded,
              color: const Color(0xFF2D86D4),
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Flexible(
              child: Text(
                'Share',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.style(
                  FontSize.s10,
                  w: FontWeight.w700,
                  color: const Color(0xFF2D86D4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab bar ───────────────────────────────────────────────────────────────

  Widget _buildTabBar(int invitedCount) {
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
          _tabPill('History', 1, badge: invitedCount),
        ],
      ),
    );
  }

  Widget _tabPill(String title, int index, {int? badge}) {
    final bool sel = _selectedTabIndex == index;
    final bool showBadge = badge != null && badge > 0;
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
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppType.style(
                    FontSize.s10,
                    w: sel ? FontWeight.w600 : FontWeight.w500,
                    color: sel ? CommonColors.blackColor : Colors.grey.shade500,
                  ),
                ),
                if (showBadge) ...[
                  SizedBox(width: 1.2.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 1.6.w,
                      vertical: 0.15.h,
                    ),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFF38A8D8)
                          : const Color(0xFF38A8D8).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.w),
                    ),
                    child: Text(
                      '$badge',
                      style: AppType.style(
                        FontSize.s8,
                        w: FontWeight.w700,
                        color: sel ? Colors.white : const Color(0xFF2D86D4),
                      ),
                    ),
                  ),
                ],
              ],
            ),
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
            onTap: () => launchUrl(
              Uri.parse(info.program!.termsUrl!),
              mode: LaunchMode.externalApplication,
            ),
            child: Text(
              'Terms & conditions apply',
              style: AppType.style(
                FontSize.s9,
                color: const Color(0xFF4BB7DE),
                w: FontWeight.w500,
              ),
            ),
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
            offset: const Offset(0, 3),
          ),
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
                      style: AppType.style(
                        FontSize.s8,
                        w: FontWeight.w700,
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
                  style: AppType.style(
                    FontSize.s12,
                    w: FontWeight.w600,
                    color: CommonColors.blackColor,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  description,
                  style: AppType.style(
                    FontSize.s9,
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
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.ios_share_rounded, color: Colors.white, size: 5.5.w),
              SizedBox(width: 3.w),
              Flexible(
                child: Text(
                  'Invite a Friend',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppType.style(
                    FontSize.s13,
                    w: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
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
              style: AppType.style(
                FontSize.s9,
                color: const Color(0xFFB45309),
                height: 1.3,
              ),
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
            style: AppType.style(
              FontSize.s18,
              w: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
          ),
          SizedBox(height: 0.3.h),
          Text(
            label,
            style: AppType.style(
              FontSize.s9,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _referralTile(ReferralEntry entry) {
    final cfg = _statusConfig(entry.parsedStatus);
    final name = (entry.friendName ?? '').isNotEmpty
        ? entry.friendName!
        : 'A friend';
    final initials = name.trim().isNotEmpty
        ? name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((w) => w[0])
              .join()
              .toUpperCase()
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
                initials,
                style: AppType.style(
                  FontSize.s11,
                  w: FontWeight.w700,
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
                Text(
                  name,
                  style: AppType.style(
                    FontSize.s11,
                    w: FontWeight.w600,
                    color: CommonColors.blackColor,
                  ),
                ),
                if (dateStr.isNotEmpty)
                  Text(
                    dateStr,
                    style: AppType.style(
                      FontSize.s9,
                      color: Colors.grey.shade500,
                    ),
                  ),
                if ((entry.note ?? '').isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 0.3.h),
                    child: Text(
                      entry.note!,
                      style: AppType.style(
                        FontSize.s8,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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
                style: AppType.style(
                  FontSize.s12,
                  w: FontWeight.w700,
                  color: entry.parsedStatus == ReferralStatus.rewarded
                      ? const Color(0xFF2EAF7D)
                      : Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 0.4.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.5.w,
                  vertical: 0.4.h,
                ),
                decoration: BoxDecoration(
                  color: cfg['bg'] as Color,
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Text(
                  (entry.statusLabel ?? cfg['label'] as String),
                  style: AppType.style(
                    FontSize.s8,
                    w: FontWeight.w600,
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
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][(m - 1).clamp(0, 11)];

  Widget _emptyState() {
    return Column(
      children: [
        SizedBox(height: 6.h),
        Icon(Icons.group_add_rounded, size: 18.w, color: Colors.grey.shade300),
        SizedBox(height: 2.h),
        Text(
          'No referrals yet',
          style: AppType.style(
            FontSize.s14,
            w: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Invite a friend and start earning!',
          style: AppType.style(FontSize.s10, color: Colors.grey.shade400),
        ),
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
        'mailto:?subject=${Uri.encodeComponent("Join me on AORBO Treks")}&body=$encoded',
      ),
      _ => Uri.parse('https://wa.me/?text=$encoded'),
    };
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    // WhatsApp app not installed → WhatsApp Web still works via wa.me.
    if (scheme == 'whatsapp') {
      final Uri web = Uri.parse('https://wa.me/?text=$encoded');
      if (await canLaunchUrl(web)) {
        await launchUrl(web, mode: LaunchMode.externalApplication);
      }
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
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 2.5.h),
          Text(
            'Share via',
            style: AppType.style(FontSize.s14, w: FontWeight.w600),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Invite a friend using your favourite app',
            style: AppType.style(FontSize.s9, color: Colors.grey.shade500),
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareOption(
                label: 'WhatsApp',
                svg: _kWhatsappSvg,
                color: const Color(0xFF25D366),
                onTap: () => _launch('whatsapp'),
              ),
              _ShareOption(
                label: 'SMS',
                icon: Icons.sms_rounded,
                color: const Color(0xFF3B82F6),
                onTap: () => _launch('sms'),
              ),
              _ShareOption(
                label: 'Email',
                svg: _kGmailSvg,
                color: const Color(0xFFEA4335),
                onTap: () => _launch('email'),
              ),
              _ShareOption(
                label: 'Copy',
                icon: Icons.copy_rounded,
                color: AppColors.inkMid,
                onTap: () => _copy(context),
              ),
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
                Text(
                  'Message Preview',
                  style: AppType.style(
                    FontSize.s9,
                    w: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Text(
                  message,
                  style: AppType.style(
                    FontSize.s9,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  maxLines: 6,
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

/// A share target styled as a real button: filled brand-colored circle with
/// a white glyph, drop shadow, and a press-scale + shadow-collapse animation
/// so it unmistakably reads as tappable.
class _ShareOption extends StatefulWidget {
  final String label;
  final IconData? icon; // Material icon (SMS, Copy)
  final String? svg; // inline brand SVG (WhatsApp, Gmail)
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.label,
    this.icon,
    this.svg,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ShareOption> createState() => _ShareOptionState();
}

class _ShareOptionState extends State<_ShareOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(
                      alpha: _pressed ? 0.15 : 0.35,
                    ),
                    blurRadius: _pressed ? 4 : 12,
                    spreadRadius: _pressed ? 0 : 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: widget.svg != null
                    ? SvgPicture.string(widget.svg!, width: 7.w, height: 7.w)
                    : Icon(widget.icon, color: Colors.white, size: 7.w),
              ),
            ),
            SizedBox(height: 1.2.h),
            Text(
              widget.label,
              style: AppType.style(
                FontSize.s8,
                w: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
