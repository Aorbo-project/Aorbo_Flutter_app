import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:sizer/sizer.dart';


// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _TC {
  static const bg         = Color(0xFFF4F7FF);
  static const cardBg     = Color(0xFFFFFFFF);
  static const ink        = Color(0xFF0F172A);
  static const inkMid     = Color(0xFF64748B);
  static const inkLight   = Color(0xFF94A3B8);
  static const accent     = Color(0xFF111827);
  static const brand      = Color(0xFF4271FF);
  static const brandLight = Color(0xFFEEF2FF);
  static const teal       = Color(0xFF0F7B6C);
  static const tealLight  = Color(0xFFE6F5F3);
  static const divider    = Color(0xFFE2E8F0);
  static const shadow     = Color(0x0A000000);
}

// ─────────────────────────────────────────────
//  TICKET CLIPPER
// ─────────────────────────────────────────────
class TicketClipper extends CustomClipper<Path> {
  final double cutoutOffset;
  TicketClipper(this.cutoutOffset);

  @override
  Path getClip(Size size) {
    double radius       = 2.w;
    double circleRadius = 5.w;
    double vertPos      = cutoutOffset;

    Path base = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    Path cutouts = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, vertPos), radius: circleRadius))
      ..addOval(Rect.fromCircle(center: Offset(size.width, vertPos), radius: circleRadius));

    return Path.combine(PathOperation.difference, base, cutouts);
  }

  @override
  bool shouldReclip(TicketClipper old) => old.cutoutOffset != cutoutOffset;
}

// ─────────────────────────────────────────────
//  CONFETTI
// ─────────────────────────────────────────────
class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
        Paint()..color = p.color.withValues(alpha: p.opacity),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

class _Particle {
  double x, y, size, rotation, opacity, vx, vy;
  Color color;
  _Particle({
    required this.x, required this.y, required this.size,
    required this.rotation, required this.opacity,
    required this.vx, required this.vy, required this.color,
  });
}

// ─────────────────────────────────────────────
//  TREKKING ICON BANNER
// ─────────────────────────────────────────────
class _TrekkingIconBanner extends StatefulWidget {
  final bool visible;
  const _TrekkingIconBanner({required this.visible});

  @override
  State<_TrekkingIconBanner> createState() => _TrekkingIconBannerState();
}

class _TrekkingIconBannerState extends State<_TrekkingIconBanner>
    with TickerProviderStateMixin {

  // Staggered entrance controllers (one per icon)
  final List<AnimationController> _entranceCtls = [];
  final List<Animation<double>> _fadeAnims = [];
  final List<Animation<Offset>> _slideAnims = [];

  // Shared float loop
  late AnimationController _floatCtl;
  final List<Animation<double>> _floatAnims = [];

  static const _icons = [
    (icon: Icons.hiking_rounded,          label: 'Trekking',    color: Color(0xFF0F7B6C)),
    (icon: Icons.landscape_rounded,       label: 'Mountains',   color: Color(0xFF4271FF)),
    (icon: Icons.wb_sunny_rounded,        label: 'Sunrise',     color: Color(0xFFF59E0B)),
    (icon: Icons.forest_rounded,          label: 'Forest',      color: Color(0xFF22C55E)),
    (icon: Icons.air_rounded,             label: 'Fresh Air',   color: Color(0xFF06B6D4)),
  ];

  @override
  void initState() {
    super.initState();

    // Float loop — different phase offset per icon
    _floatCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    for (int i = 0; i < _icons.length; i++) {
      // Staggered entrance
      final ctl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 550),
      );
      _entranceCtls.add(ctl);

      _fadeAnims.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: ctl, curve: Curves.easeOut),
        ),
      );
      _slideAnims.add(
        Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).animate(
          CurvedAnimation(parent: ctl, curve: Curves.easeOutBack),
        ),
      );

      // Float — each icon gets a slightly different phase
      final phaseOffset = i / _icons.length;
      _floatAnims.add(
        Tween<double>(begin: -3.0, end: 3.0).animate(
          CurvedAnimation(
            parent: _floatCtl,
            curve: Interval(
              phaseOffset * 0.4,
              (phaseOffset * 0.4 + 1.0).clamp(0.0, 1.0),
              curve: Curves.easeInOut,
            ),
          ),
        ),
      );
    }
  }

  @override
  void didUpdateWidget(_TrekkingIconBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _startStaggeredEntrance();
    }
  }

  void _startStaggeredEntrance() async {
    for (int i = 0; i < _entranceCtls.length; i++) {
      await Future.delayed(Duration(milliseconds: i * 90));
      if (mounted) _entranceCtls[i].forward();
    }
  }

  @override
  void dispose() {
    for (final c in _entranceCtls) { c.dispose(); }
    _floatCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Heading row ──────────────────────────────────────
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F7B6C), Color(0xFF0D9488)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 3.5.w),
                    SizedBox(width: 1.5.w),
                    Text(
                      'Your Ticket Is Ready',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 1.5.h),

          // ── Trek-themed tagline ──────────────────────────────
          Text(
            'Your adventure starts here 🏔️',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s13,
              fontWeight: FontWeight.w800,
              color: _TC.ink,
              height: 1.3,
            ),
          ),
          SizedBox(height: 0.4.h),
          Text(
            'Pack your bags and embrace the trail.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s9,
              color: _TC.inkMid,
            ),
          ),

          SizedBox(height: 2.h),

          // ── Animated icon row ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_icons.length, (i) {
              final item = _icons[i];
              return FadeTransition(
                opacity: _fadeAnims[i],
                child: SlideTransition(
                  position: _slideAnims[i],
                  child: AnimatedBuilder(
                    animation: _floatCtl,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnims[i].value),
                        child: child,
                      );
                    },
                    child: _IconPill(
                      icon: item.icon,
                      label: item.label,
                      color: item.color,
                    ),
                  ),
                ),
              );
            }),
          ),

          SizedBox(height: 2.h),

          // ── Thin decorative separator ────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, _TC.divider, Colors.transparent],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Icon(Icons.terrain_rounded, size: 4.w, color: _TC.inkLight),
              ),
              Expanded(
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, _TC.divider, Colors.transparent],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // ── "Your Booking Ticket" label ──────────────────────
          Text(
            'Your Booking Ticket',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s11,
              fontWeight: FontWeight.w700,
              color: _TC.inkMid,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ICON PILL WIDGET
// ─────────────────────────────────────────────
class _IconPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _IconPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 13.w,
          height: 13.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 6.w),
        ),
        SizedBox(height: 0.8.h),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s7,
            fontWeight: FontWeight.w600,
            color: _TC.inkMid,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────
class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({super.key});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with TickerProviderStateMixin {
  final TrekController _trekC = Get.find<TrekController>();
  final DashboardController _dashboardC = Get.find<DashboardController>();

  // ── Success overlay state ──
  bool _showOverlay = true;
  double _overlayOpacity = 1.0;

  // ── Ticket card state ──
  Set<int> openSections = {0};
  final GlobalKey _dottedKey = GlobalKey();
  final GlobalKey _cardKey   = GlobalKey();
  double cutoutOffset = 0;
  late AnimationController _cardAnimCtrl;
  bool _showTicket = false;

  // ── Confetti ──
  late AnimationController _confettiCtrl;
  List<_Particle> _particles = [];
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();

    _cardAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          setState(() => _showConfetti = false);
        }
      });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      _fireConfetti();
      setState(() => _overlayOpacity = 0.0);
    });

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      setState(() {
        _showOverlay = false;
        _showTicket = true;
      });
      _cardAnimCtrl.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateCutoutOffset();
      });
    });
  }

  @override
  void dispose() {
    _cardAnimCtrl.dispose();
    _confettiCtrl.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trekC.clearBookingData();
      _dashboardC.clearSearchAndBookingData();
    });
    super.dispose();
  }

  void _fireConfetti() {
    final palette = [
      _TC.brand, _TC.teal, const Color(0xFF6366F1),
      const Color(0xFFFBBF24), const Color(0xFFF472B6), const Color(0xFFFB923C),
    ];
    _particles = List.generate(55, (i) {
      return _Particle(
        x: 50.w + (i.isEven ? 1 : -1) * (i % 7) * 4.w,
        y: -10.h - (i * 1.5),
        size: 4 + (i % 4) * 2.0,
        rotation: (i * 37.0) % 360,
        opacity: 1.0,
        vx: (i.isEven ? 1 : -1) * (1 + (i % 3) * 0.8),
        vy: 2 + (i % 5) * 1.2,
        color: palette[i % palette.length],
      );
    });
    _showConfetti = true;
    _confettiCtrl.forward(from: 0);
  }

  void _updateCutoutOffset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? box = _dottedKey.currentContext?.findRenderObject() as RenderBox?;
      final RenderBox? cardBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && cardBox != null && mounted) {
        final position = box.localToGlobal(Offset.zero);
        final cardTop = cardBox.localToGlobal(Offset.zero).dy;
        final localOffset = position.dy - cardTop;
        setState(() => cutoutOffset = localOffset + box.size.height / 2);
      }
    });
  }

  void _toggleSection(int index) {
    setState(() {
      if (openSections.contains(index)) {
        openSections.remove(index);
      } else {
        openSections.add(index);
      }
    });
    Future.delayed(const Duration(milliseconds: 100), _updateCutoutOffset);
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _TC.bg,
      body: Stack(
        children: [
          // ═══════════════════════════════════════
          //  MAIN SCROLLABLE CONTENT
          // ═══════════════════════════════════════
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Trekking icon banner (shown with ticket) ──
                  _TrekkingIconBanner(visible: _showTicket),

                  // ── Ticket Card ───────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: _showTicket
                        ? _buildTicketCard()
                        : const SizedBox.shrink(),
                  ),

                  if (_showTicket) ...[
                    SizedBox(height: 2.5.h),
                    _buildContactBlock(),
                    SizedBox(height: 2.5.h),
                    _buildActionButtons(),
                    SizedBox(height: 2.5.h),
                    _buildFAQCard(),
                    SizedBox(height: 2.h),
                    _buildFooter(),
                  ],
                ],
              ),
            ),
          ),

          // ═══════════════════════════════════════
          //  SUCCESS OVERLAY
          // ═══════════════════════════════════════
          if (_showOverlay)
            AnimatedOpacity(
              opacity: _overlayOpacity,
              duration: const Duration(milliseconds: 700),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F7B6C), Color(0xFF0D9488), Color(0xFF0A5C52)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 25.w,
                      height: 25.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Booking Confirmed!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Your adventure awaits',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.sp,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ═══════════════════════════════════════
          //  CONFETTI OVERLAY
          // ═══════════════════════════════════════
          if (_showConfetti)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _confettiCtrl,
                builder: (context, _) {
                  final t = _confettiCtrl.value;
                  for (var p in _particles) {
                    p.x += p.vx * 0.3;
                    p.y += p.vy * (1 + t * 2);
                    p.rotation += 3;
                    p.opacity = (1 - t).clamp(0.0, 1.0);
                  }
                  return CustomPaint(
                    painter: _ConfettiPainter(_particles),
                    size: Size.infinite,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  TICKET CARD
  // ─────────────────────────────────────────────
  Widget _buildTicketCard() {
    final data = _trekC.verifyOrderModal.value.data;
    if (data == null) return const SizedBox.shrink();

    final trek        = data.trek;
    final batch       = data.batch;
    final startDate   = DateTime.tryParse(batch?.startDate ?? '');
    final endDate     = DateTime.tryParse(batch?.endDate ?? '');
    final bookingDate = data.bookingDate != null
        ? DateTime.parse(data.bookingDate!)
        : null;
    final payment     = _trekC.verifyOrderModal.value.payment;
    final paymentDet  = _trekC.verifyOrderModal.value.paymentDetails;

    final cardContent = Container(
      key: _cardKey,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── HEADER ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 2.5.h),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F7B6C), Color(0xFF0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    trek?.title ?? 'Trek Details',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 1.5.w),
                      Text(
                        'CONFIRMED',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── DATE ROW ────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 0),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DEPARTURE', style: _labelStyle()),
                      SizedBox(height: 0.3.h),
                      Text(
                        startDate != null ? DateFormat('E, dd MMM').format(startDate) : '-',
                        style: TextStyle(
                          fontFamily: 'Poppins', fontSize: FontSize.s13,
                          fontWeight: FontWeight.w700, color: _TC.ink,
                        ),
                      ),
                      SizedBox(height: 0.2.h),
                      Text(
                        data.city?.cityName ?? '-',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s8, color: _TC.inkMid),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Icon(Icons.hiking_rounded, size: 5.w, color: _TC.ink),
                      SizedBox(height: 0.5.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          trek?.duration?.replaceAll('Days', 'D').replaceAll('Nights', 'N') ?? '-',
                          style: TextStyle(
                            fontFamily: 'Poppins', fontSize: FontSize.s8,
                            fontWeight: FontWeight.w600, color: _TC.inkMid,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('ARRIVAL', style: _labelStyle()),
                      SizedBox(height: 0.3.h),
                      Text(
                        endDate != null ? DateFormat('E, dd MMM').format(endDate) : '-',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Poppins', fontSize: FontSize.s13,
                          fontWeight: FontWeight.w700, color: _TC.ink,
                        ),
                      ),
                      SizedBox(height: 0.2.h),
                      Text(
                        trek?.destinationData?.name ?? 'Destination',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s8, color: _TC.inkMid),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // ── DOTTED SEPARATOR ────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: DottedLine(
              key: _dottedKey,
              dashColor: _TC.divider,
              dashLength: 3.5.w,
              dashGapLength: 4.w,
              lineThickness: 1.5,
            ),
          ),

          SizedBox(height: 2.h),

          // ── EXPANDABLE SECTIONS ──────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              children: [

                // Booking Details
                _sectionHeader('Booking Details', 0),
                if (openSections.contains(0)) ...[
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _ticketRow('TBR ID', batch?.tbrId ?? 'N/A', isHighlight: true),
                        _dividerLine(),
                        _ticketRow(
                          'Booking ID',
                          _trekC.verifyOrderModal.value.data?.bookingNumber ??
                              _trekC.orderData.value.bookingNumber ??
                              'N/A',
                        ),
                        _dividerLine(),
                        _ticketRow('Booking Date',
                          bookingDate != null ? DateFormat('E, d MMM yyyy').format(bookingDate) : 'N/A'),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.5.h),

                  if (data.travelers?.isNotEmpty == true) ...[
                    Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Row(
                        children: [
                          Icon(Icons.people_outline_rounded, size: 4.w, color: _TC.inkMid),
                          SizedBox(width: 2.w),
                          Text('Traveller Details', style: TextStyle(
                            fontFamily: 'Poppins', fontSize: FontSize.s10,
                            fontWeight: FontWeight.w700, color: _TC.ink,
                          )),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _TC.divider),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: _TC.accent.withValues(alpha: 0.04),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12), topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 5, child: Text('Name', style: _tableHeaderStyle())),
                                Expanded(flex: 2, child: Text('Age', style: _tableHeaderStyle())),
                                Expanded(flex: 3, child: Text('Gender', style: _tableHeaderStyle())),
                              ],
                            ),
                          ),
                          ...data.travelers!.asMap().entries.map((e) {
                            final t = e.value;
                            final isLast = e.key == (data.travelers!.length - 1);
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 3.w,
                                          backgroundColor: _avatarColor(e.key),
                                          child: Text(
                                            (t.traveler?.name ?? '-').substring(0, 1).toUpperCase(),
                                            style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        SizedBox(width: 2.w),
                                        Expanded(
                                          child: Text(t.traveler?.name ?? '-', style: TextStyle(
                                            fontFamily: 'Poppins', fontSize: FontSize.s9,
                                            fontWeight: FontWeight.w600, color: _TC.ink,
                                          )),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(flex: 2, child: Text(
                                    t.traveler?.age?.toString() ?? '-',
                                    style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s9, color: _TC.inkMid),
                                  )),
                                  Expanded(flex: 3, child: _genderPill(t.traveler?.gender ?? '-')),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                  ],
                ],

                Container(height: 1, color: _TC.divider),

                // Trek Details
                _sectionHeader('Trek Details', 1),
                if (openSections.contains(1)) ...[
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _ticketRow('Trek Operator',
                            data.vendor?.companyInfo?.companyName ??
                            data.vendor?.businessName ??
                            'N/A'),
                        _dividerLine(),
                        _ticketRow('Boarding Point',
                            data.trek?.boardingPoint ??
                            data.city?.cityName ??
                            'To be announced'),
                        _dividerLine(),
                        _ticketRow('Trek Captain',
                            data.trek?.captainName ??
                            data.vendor?.companyInfo?.contactPerson ??
                            'To be announced'),
                        _dividerLine(),
                        _ticketRowWithCall('Captain Contact',
                            data.trek?.captainPhone ??
                            data.vendor?.companyInfo?.phone ??
                            'Not available'),
                        _dividerLine(),
                        _ticketRow('Difficulty', 'Moderate'),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                ],

                Container(height: 1, color: _TC.divider),

                // Payment Details
                _sectionHeader('Payment Details', 2),
                if (openSections.contains(2)) ...[
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _ticketRow('Base Fare', '₹${trek?.basePrice ?? 0}'),
                        if (paymentDet?.isPartialPayment == true) ...[
                          _dividerLine(),
                          _ticketRow('Remaining Amount', '₹${paymentDet?.remainingAmount ?? 0}', isHighlight: true),
                        ],
                        _dividerLine(),
                        _ticketRow('Total Paid', '₹${payment?.amount ?? 0}', isHighlight: true),
                        _dividerLine(),
                        _ticketRow('Payment Status', 'Fully Paid', isHighlight: true),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.5.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_TC.tealLight, _TC.teal.withValues(alpha: 0.05)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _TC.teal.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 9.w, height: 9.w,
                          decoration: BoxDecoration(
                            color: _TC.teal.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.check_circle_rounded, color: _TC.teal, size: 5.w),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Payment Successful', style: TextStyle(
                                fontFamily: 'Poppins', fontSize: FontSize.s9, color: _TC.inkMid,
                              )),
                              Text('₹${payment?.amount ?? 0}', style: TextStyle(
                                fontFamily: 'Poppins', fontSize: FontSize.s15,
                                fontWeight: FontWeight.w800, color: _TC.teal,
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                ],
              ],
            ),
          ),

          SizedBox(height: 1.5.h),

          // ── TEAR DOTTED LINE ────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: DottedLine(
              dashColor: _TC.divider,
              dashLength: 3.5.w,
              dashGapLength: 4.w,
              lineThickness: 1.5,
            ),
          ),

          SizedBox(height: 2.5.h),

          // ── CARD FOOTER ──────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 3.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    '"Not Insta-perfect.\nBut soul-perfect...!!"',
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: FontSize.s10,
                      fontWeight: FontWeight.w500, fontStyle: FontStyle.italic,
                      color: _TC.inkLight, height: 1.5,
                    ),
                  ),
                ),
                Image.asset(
                  CommonImages.logo1,
                  width: 22.w, height: 4.h, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return AnimatedBuilder(
      animation: _cardAnimCtrl,
      builder: (context, child) => FadeTransition(
        opacity: _cardAnimCtrl,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
              .animate(CurvedAnimation(parent: _cardAnimCtrl, curve: Curves.easeOutCubic)),
          child: PhysicalShape(
            clipper: TicketClipper(cutoutOffset),
            elevation: 15,
            color: Colors.transparent,
            shadowColor: Colors.black.withValues(alpha: 0.15),
            child: ClipPath(
              clipper: TicketClipper(cutoutOffset),
              child: cardContent,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BOTTOM SECTIONS
  // ─────────────────────────────────────────────
  Widget _buildContactBlock() {
    final data = _trekC.verifyOrderModal.value.data;
    // Prefer resolved captain fields; fall back to vendor company_info contact
    final captainName  = data?.trek?.captainName  ?? data?.vendor?.companyInfo?.contactPerson;
    final captainPhone = data?.trek?.captainPhone ?? data?.vendor?.companyInfo?.phone;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 10.w, height: 10.w,
              decoration: BoxDecoration(color: _TC.tealLight, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.phone_outlined, size: 5.w, color: _TC.teal),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trek details via contact', style: TextStyle(
                    fontFamily: 'Poppins', fontSize: FontSize.s8, color: _TC.inkMid,
                  )),
                  SizedBox(height: 0.2.h),
                  if (captainName != null)
                    Text(captainName, style: TextStyle(
                      fontFamily: 'Poppins', fontSize: FontSize.s11,
                      fontWeight: FontWeight.w600, color: _TC.ink,
                    )),
                  if (captainPhone != null)
                    Text(captainPhone, style: TextStyle(
                      fontFamily: 'Poppins', fontSize: FontSize.s12,
                      fontWeight: FontWeight.w700, color: _TC.brand,
                    ))
                  else
                    Text('Contact number not available', style: TextStyle(
                      fontFamily: 'Poppins', fontSize: FontSize.s9, color: _TC.inkMid,
                    )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Expanded(child: _buildActionButton(Icons.confirmation_num_outlined, 'Ticket', onTap: () {})),
          SizedBox(width: 3.w),
          Expanded(child: _buildActionButton(Icons.cancel_outlined, 'Cancel', onTap: () {})),
          SizedBox(width: 3.w),
          Expanded(child: _buildActionButton(Icons.share_outlined, 'Share', onTap: () {})),
        ],
      ),
    );
  }

  Widget _buildFAQCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _TC.divider),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 10.w, height: 10.w,
                decoration: BoxDecoration(color: _TC.brandLight, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.help_outline_rounded, size: 5.w, color: _TC.brand),
              ),
              SizedBox(width: 3.w),
              Expanded(child: Text('Frequently Asked Questions', style: TextStyle(
                fontFamily: 'Poppins', fontSize: FontSize.s11,
                fontWeight: FontWeight.w600, color: _TC.ink,
              ))),
              Icon(Icons.arrow_forward_ios_rounded, size: 4.w, color: _TC.inkLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Go Beyond,\nExplore More!',
            style: GoogleFonts.sourceSerif4(
              fontSize: FontSize.s28, fontWeight: FontWeight.bold,
              color: const Color(0xFFE2E8F0), height: 1.2,
            ),
          ),
          SizedBox(height: 1.h),
          RichText(
            text: TextSpan(
              style: TextStyle(fontFamily: 'Poppins', fontSize: FontSize.s10, color: _TC.inkLight),
              children: [
                const TextSpan(text: 'Crafted with passion '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(Icons.favorite, color: CommonColors.red_B52424, size: FontSize.s10),
                ),
                const TextSpan(text: '\nrooted in Hyderabad.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────
  Widget _sectionHeader(String title, int index) {
    final bool isOpen = openSections.contains(index);
    return InkWell(
      onTap: () => _toggleSection(index),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.6.h),
        child: Row(
          children: [
            Container(
              width: 7.w, height: 7.w,
              decoration: BoxDecoration(color: _TC.accent, borderRadius: BorderRadius.circular(8)),
              child: Icon(_sectionIcon(index), color: Colors.white, size: 3.8.w),
            ),
            SizedBox(width: 3.w),
            Expanded(child: Text(title, style: TextStyle(
              fontFamily: 'Poppins', fontSize: FontSize.s12,
              fontWeight: FontWeight.w700, color: _TC.ink,
            ))),
            AnimatedRotation(
              turns: isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                width: 7.w, height: 7.w,
                decoration: BoxDecoration(
                  color: isOpen ? _TC.accent : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.keyboard_arrow_down_rounded, size: 4.5.w,
                    color: isOpen ? Colors.white : _TC.inkMid),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _sectionIcon(int index) {
    switch (index) {
      case 0: return Icons.confirmation_number_outlined;
      case 1: return Icons.terrain_rounded;
      case 2: return Icons.account_balance_wallet_outlined;
      default: return Icons.info_outline;
    }
  }

  Widget _ticketRow(String title, String value, {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.9.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 5, child: Text(title, style: TextStyle(
            fontFamily: 'Poppins', fontSize: FontSize.s9, color: _TC.inkMid,
          ))),
          Expanded(flex: 5, child: Text(value, textAlign: TextAlign.end, style: TextStyle(
            fontFamily: 'Poppins', fontSize: FontSize.s9,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
            color: isHighlight ? _TC.brand : _TC.ink,
          ))),
        ],
      ),
    );
  }

  Widget _ticketRowWithCall(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.9.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 5, child: Text(title, style: TextStyle(
            fontFamily: 'Poppins', fontSize: FontSize.s9, color: _TC.inkMid,
          ))),
          Expanded(flex: 4, child: Text(value, textAlign: TextAlign.end, style: TextStyle(
            fontFamily: 'Poppins', fontSize: FontSize.s9,
            fontWeight: FontWeight.w500, color: _TC.ink,
          ))),
          SizedBox(width: 1.w),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 7.w, height: 7.w,
              decoration: BoxDecoration(color: _TC.tealLight, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.call_rounded, size: 3.8.w, color: _TC.teal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _TC.divider),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w, height: 10.w,
              decoration: BoxDecoration(color: _TC.accent, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 5.w, color: Colors.white),
            ),
            SizedBox(height: 0.8.h),
            Text(label, style: TextStyle(
              fontFamily: 'Poppins', fontSize: FontSize.s9,
              fontWeight: FontWeight.w600, color: _TC.ink,
            )),
          ],
        ),
      ),
    );
  }

  Widget _dividerLine() => Container(
    height: 1, margin: EdgeInsets.symmetric(vertical: 0.3.h), color: _TC.divider,
  );

  TextStyle _labelStyle() => TextStyle(
    fontFamily: 'Poppins', fontSize: FontSize.s7,
    fontWeight: FontWeight.w600, color: _TC.inkLight, letterSpacing: 0.8,
  );

  TextStyle _tableHeaderStyle() => TextStyle(
    fontFamily: 'Poppins', fontSize: FontSize.s8,
    fontWeight: FontWeight.w600, color: _TC.inkMid, letterSpacing: 0.4,
  );

  Color _avatarColor(int index) {
    final colors = [_TC.brand, const Color(0xFF8B5CF6), const Color(0xFFEC4899),
      _TC.teal, const Color(0xFFF59E0B), const Color(0xFFEF4444)];
    return colors[index % colors.length];
  }

  Widget _genderPill(String gender) {
    final isFemale = gender.toUpperCase().contains('F');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: (isFemale ? const Color(0xFFEC4899) : _TC.brand).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(gender, textAlign: TextAlign.center, style: TextStyle(
        fontFamily: 'Poppins', fontSize: FontSize.s8, fontWeight: FontWeight.w600,
        color: isFemale ? const Color(0xFFEC4899) : _TC.brand,
      )),
    );
  }
}
