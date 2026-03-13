import 'dart:math' as math;
import 'package:arobo_app/models/about_us_data.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _C {
  static const teal      = Color(0xFF0F7B6C);
  static const tealLight = Color(0xFF1AA090);
  static const tealSoft  = Color(0xFFE6F5F3);
  static const ink       = Color(0xFF121212);
  static const inkMid    = Color(0xFF444444);
  static const inkLight  = Color(0xFF888888);
  static const divider   = Color(0xFFEEEEEE);
  static const cardBg    = Color(0xFFF9F9F7);
  static const white     = Color(0xFFFFFFFF);
  static const footerText= Color(0xFFD8D8D8);
  static const red       = Color(0xFFB52424);
}

// ─────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────
class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>
    with TickerProviderStateMixin {

  late final ScrollController _scroll;
  late final AnimationController _heroAnim;
  late final AnimationController _fadeAnim;
  late final AnimationController _pulseAnim;

  double _heroParallax = 0;
  bool _appBarSolid    = false;

  // ─── LIFECYCLE ─────────────────────────────

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);

    // Hero elements slide in on load
    _heroAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    // Body content fades in
    _fadeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    // Decorative circles pulse slowly
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  // Called every time the user scrolls
  void _onScroll() {
    final offset = _scroll.offset;
    setState(() {
      _heroParallax = offset * 0.35; // image moves slower than scroll = parallax
      _appBarSolid  = offset > 260;  // appbar becomes solid after scrolling ~260px
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _heroAnim.dispose();
    _fadeAnim.dispose();
    _pulseAnim.dispose();
    super.dispose();
  }

  // ─── BUILD ─────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.white,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: CustomScrollView(
        controller: _scroll,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHero()),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeStrip(),
                  _buildSectionsDynamic(),
                  _buildDivider(),
                  _buildExpandableLinks(),
                  _buildFooter(),
                  SizedBox(height: 6.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  APP BAR
  //  • Transparent over hero image
  //  • Fades to solid white as user scrolls down
  // ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: AnimatedBuilder(
        animation: _heroAnim,
        builder: (_, __) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            color: _appBarSolid
                ? _C.white.withValues(alpha: 0.96)
                : Colors.transparent,
            child: SafeArea(
              child: Row(
                children: [
                  SizedBox(width: 1.w),
                  _AppBarBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).pop(),
                    filled: _appBarSolid,
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: _appBarSolid ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      'About Us',
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s13,
                        fontWeight: FontWeight.w600,
                        color: _C.ink,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 13.w),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HERO
  // ─────────────────────────────────────────────
  Widget _buildHero() {
    return SizedBox(
      height: 40.h,
      child: Stack(
        fit: StackFit.expand,
        children: [

          // ── Layer 1: Parallax image ──
          Transform.translate(
            offset: Offset(0, -_heroParallax),
            child: Image.asset(
              aboutUsData.imagePath,
              fit: BoxFit.cover,
            ),
          ),

          // ── Layer 2: Multi-stop gradient ──
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x1A000000),
                  Color(0x00000000),
                  Color(0x4D000000),
                  Color(0xB8000000),
                ],
                stops: [0.0, 0.35, 0.65, 1.0],
              ),
            ),
          ),

          // ── Layer 3: Decorative pulsing circles ──
          Positioned(
            top: 7.5.h,
            right: -6.5.w,
            child: _AnimatedCircle(
              controller: _pulseAnim,
              size: 28.w,
              color: _C.teal,
            ),
          ),
          Positioned(
            top: 13.h,
            right: 13.w,
            child: _AnimatedCircle(
              controller: _pulseAnim,
              size: 14.w,
              color: _C.tealLight,
              phase: 0.5,
            ),
          ),

          // ── Layer 4: ESTABLISHED badge (slides in from left) ──
          Positioned(
            top: 12.h,
            left: 5.5.w,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-0.6, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _heroAnim,
                curve: Curves.easeOutCubic,
              )),
              child: const _EstablishedBadge(),
            ),
          ),

          // ── Layer 5: Title block (slides up from bottom) ──
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _heroAnim,
                curve: Curves.easeOutCubic,
              )),
              child: Padding(
                padding: EdgeInsets.fromLTRB(5.5.w, 0, 5.5.w, 3.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 11.w,
                      height: 3,
                      decoration: BoxDecoration(
                        color: _C.tealLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      aboutUsData.title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: FontSize.s22,
                        fontWeight: FontWeight.w700,
                        color: _C.white,
                        height: 1.25,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  WELCOME STRIP
  // ─────────────────────────────────────────────
  Widget _buildWelcomeStrip() {
    return Container(
      margin: EdgeInsets.fromLTRB(4.5.w, 3.h, 4.5.w, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.tealSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _C.teal.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 6.5.h,
            decoration: BoxDecoration(
              color: _C.teal,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              aboutUsData.welcomeText,
              style: GoogleFonts.poppins(
                fontSize: FontSize.s12,
                height: 1.75,
                color: _C.inkMid,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  DYNAMIC SECTIONS
  // ─────────────────────────────────────────────
  Widget _buildSectionsDynamic() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.5.w),
      child: Column(
        children: aboutUsData.sections.asMap().entries.map((entry) {
          return _AnimatedSectionCard(
            section: entry.value,
            index: entry.key,
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  DIVIDER
  // ─────────────────────────────────────────────
  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 1.h),
      child: Row(
        children: [
          const Expanded(
            child: Divider(color: _C.divider, thickness: 1),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: const Icon(
              Icons.more_horiz,
              color: _C.inkLight,
              size: 18,
            ),
          ),
          const Expanded(
            child: Divider(color: _C.divider, thickness: 1),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  EXPANDABLE LINKS
  // ─────────────────────────────────────────────
  Widget _buildExpandableLinks() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.5.w),
      child: Column(
        children: aboutUsData.links
            .map((link) => _ExpandableLinkTile(link: link))
            .toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  FOOTER
  // ─────────────────────────────────────────────
  Widget _buildFooter() {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _DotGridPainter()),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(5.5.w, 5.h, 5.5.w, 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Go Beyond,\nExplore More!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: FontSize.s26,
                  fontWeight: FontWeight.w700,
                  color: _C.footerText,
                  height: 1.25,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _C.tealSoft,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: _C.red,
                      size: 13,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s11,
                        color: _C.inkLight,
                        letterSpacing: 0.5,
                      ),
                      children: const [
                        TextSpan(text: 'Crafted with passion  ·  '),
                        TextSpan(
                          text: 'Rooted in Hyderabad',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _C.inkMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: 2.h,
                  horizontal: 4.5.w,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_C.teal, _C.tealLight],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _C.teal.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start your adventure',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s13,
                              fontWeight: FontWeight.w600,
                              color: _C.white,
                            ),
                          ),
                          Text(
                            'Discover trusted trekking partners',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s11,
                              color: const Color(0xBFFFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0x33FFFFFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: _C.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  ANIMATED SECTION CARD
// ─────────────────────────────────────────────
class _AnimatedSectionCard extends StatefulWidget {
  final AboutUsSection section;
  final int index;

  const _AnimatedSectionCard({
    required this.section,
    required this.index,
  });

  @override
  State<_AnimatedSectionCard> createState() => _AnimatedSectionCardState();
}

class _AnimatedSectionCardState extends State<_AnimatedSectionCard>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ctrl;
  late final Animation<double> _slide;
  bool _isCallToAction = false;

  @override
  void initState() {
    super.initState();
    _isCallToAction = widget.section.title == 'Call to Action';

    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500 + widget.index * 120),
    );

    _slide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );

    Future.delayed(Duration(milliseconds: 200 + widget.index * 120), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _slide.value),
        child: Opacity(opacity: _ctrl.value, child: child),
      ),
      child: _isCallToAction ? _buildCtaCard() : _buildNormalSection(),
    );
  }

  // Maps section title to a relevant icon
  IconData _iconForSection(String title) {
    switch (title) {
      case 'Our Mission':   return Icons.flag_outlined;
      case 'Our Story':     return Icons.auto_stories_outlined;
      case 'Join Our Journey': return Icons.hiking;
      default:              return Icons.info_outline;
    }
  }

  Widget _buildNormalSection() {
    return Padding(
      padding: EdgeInsets.only(top: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_C.teal, _C.tealLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _C.teal.withValues(alpha: 0.30),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _iconForSection(widget.section.title),
                  size: 18,
                  color: _C.white,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                widget.section.title,
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s13,
                  fontWeight: FontWeight.w600,
                  color: _C.ink,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _C.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _C.divider, width: 1),
            ),
            child: Text(
              widget.section.content,
              style: GoogleFonts.poppins(
                fontSize: FontSize.s12,
                height: 1.7,
                color: _C.inkMid,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaCard() {
    return Container(
      margin: EdgeInsets.only(top: 3.h),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.tealSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _C.teal.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_outlined, color: _C.teal, size: 16),
              SizedBox(width: 2.w),
              Text(
                widget.section.title,
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s13,
                  fontWeight: FontWeight.w600,
                  color: _C.teal,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            widget.section.content,
            style: GoogleFonts.poppins(
              fontSize: FontSize.s12,
              height: 1.6,
              color: _C.inkMid,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  EXPANDABLE LINK TILE
// ─────────────────────────────────────────────
class _ExpandableLinkTile extends StatefulWidget {
  final ExpandableLink link;
  const _ExpandableLinkTile({required this.link});

  @override
  State<_ExpandableLinkTile> createState() => _ExpandableLinkTileState();
}

class _ExpandableLinkTileState extends State<_ExpandableLinkTile>
    with SingleTickerProviderStateMixin {

  bool _open = false;
  late final AnimationController _ctrl;
  late final Animation<double> _rotate;
  late final Animation<double> _expand;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _rotate = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _expand = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.link.title,
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.w500,
                      color: _C.ink,
                    ),
                  ),
                ),
                RotationTransition(
                  turns: _rotate,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _open ? _C.tealSoft : _C.cardBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: _open ? _C.teal : _C.inkLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expand,
          child: Container(
            margin: EdgeInsets.only(bottom: 2.h),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _C.cardBg,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: const Border(
                left: BorderSide(color: _C.teal, width: 3),
              ),
            ),
            child: Text(
              widget.link.content,
              style: GoogleFonts.poppins(
                fontSize: FontSize.s12,
                height: 1.65,
                color: _C.inkMid,
              ),
            ),
          ),
        ),
        const Divider(color: _C.divider, thickness: 1, height: 1),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  APP BAR BUTTON
// ─────────────────────────────────────────────
class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _AppBarBtn({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(8),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: filled ? _C.cardBg : const Color(0x40000000),
          shape: BoxShape.circle,
          border: Border.all(
            color: filled ? _C.divider : const Color(0x4DFFFFFF),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: filled ? _C.ink : _C.white,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ESTABLISHED BADGE
// ─────────────────────────────────────────────
class _EstablishedBadge extends StatelessWidget {
  const _EstablishedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: const Color(0x73000000),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0x4DFFFFFF),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_outlined, color: _C.tealLight, size: 11),
          SizedBox(width: 1.w),
          Text(
            'ESTABLISHED  2021',
            style: GoogleFonts.poppins(
              fontSize: FontSize.s9,
              fontWeight: FontWeight.w600,
              color: _C.white,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ANIMATED CIRCLE
// ─────────────────────────────────────────────
class _AnimatedCircle extends StatelessWidget {
  final AnimationController controller;
  final double size;
  final Color color;
  final double phase;

  const _AnimatedCircle({
    required this.controller,
    required this.size,
    required this.color,
    this.phase = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final v = math.sin((controller.value + phase) * math.pi);
        return Opacity(
          opacity: 0.06 + v * 0.06,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  DOT GRID PAINTER
// ─────────────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..style = PaintingStyle.fill;

    const spacing = 18.0;
    const radius  = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => false;
}
