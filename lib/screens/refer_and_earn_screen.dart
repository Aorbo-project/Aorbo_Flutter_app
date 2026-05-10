import 'package:arobo_app/utils/app_dimensions.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

// ── Ticket Painter (logic unchanged) ─────────────────────────────────────────
class TicketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint shadowPaint = Paint()
      ..color = CommonColors.blackColor.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final Paint mainPaint = Paint()
      ..color = CommonColors.whiteColor
      ..style = PaintingStyle.fill;

    final double radius = 5.5.w;
    final double circleRadius = 4.5.w;

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
      size.width,
      size.height,
      size.width - radius,
      size.height,
    );
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

    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawPath(path, mainPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Screen ────────────────────────────────────────────────────────────────────
class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen>
    with TickerProviderStateMixin {
  // ── All original state & logic untouched ────────────────────────────────
  int _selectedTabIndex = 0;
  final String referralCode = 'AO12345';
  bool _copied = false;

  late final AnimationController _entryCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: referralCode));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _copied = false);
  }

  void _onTabSelected(int index) => setState(() => _selectedTabIndex = index);

  // ── Design tokens ────────────────────────────────────────────────────────
  static const _ink = Color(0xFF0F172A);
  static const _inkMid = Color(0xFF64748B);
  static const _inkLight = Color(0xFF94A3B8);
  static const _divider = Color(0xFFE2E8F0);
  static const _cardBg = Color(0xFFFFFFFF);
  static const _pageBg = Color(0xFFF1F5F9);
  static const _teal1 = Color(0xFF7ECBA1);
  static const _teal2 = Color(0xFF4BB7DE);
  static const _accent = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _cardBg,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: false,
        iconTheme: const IconThemeData(color: _ink),
        title: Text(
          'Refer & Earn',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s15,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _divider),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ── Hero banner ───────────────────────────────────────────
                _buildHeroBanner(),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    children: [
                      SizedBox(height: 2.h),

                      // ── Referral code ─────────────────────────────────
                      _buildReferralCode(),
                      SizedBox(height: 2.5.h),

                      // ── Tab switcher ──────────────────────────────────
                      _buildTabBar(),
                      SizedBox(height: 2.5.h),

                      // ── Tab content ───────────────────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _selectedTabIndex == 0
                            ? _buildReferAndEarnContent()
                            : _buildReferralHistoryContent(),
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Hero banner ───────────────────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_teal1, _teal2],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -4.h,
            right: -6.w,
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CommonColors.whiteColor.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -2.h,
            left: -4.w,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CommonColors.whiteColor.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pill badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.4.h,
                        ),
                        decoration: BoxDecoration(
                          color: CommonColors.whiteColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: CommonColors.whiteColor.withValues(
                              alpha: 0.35,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '🎉  Limited Offer',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s8,
                            fontWeight: FontWeight.w600,
                            color: CommonColors.whiteColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.2.h),

                      Text(
                        'Refer Friends,\nEarn Rewards',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s20,
                          fontWeight: FontWeight.w800,
                          color: CommonColors.whiteColor,
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: 1.h),

                      // Reward chips row
                      Wrap(
                        spacing: 2.w,
                        runSpacing: 0.8.h,
                        children: [
                          _rewardChip('You get ₹50'),
                          _rewardChip('Friend gets ₹50'),
                          _rewardChip('Up to ₹1,000'),
                        ],
                      ),

                      SizedBox(height: 2.h),

                      // Bullets
                      _buildBullet(
                        '₹50 cashback when friend completes first trek.',
                      ),
                      _buildBullet(
                        '₹50 discount for your friend on first booking.',
                      ),
                      _buildBullet(
                        '₹1,000 bonus for first 20 referrals.',
                        hasConnector: false,
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),

                // Illustration
                Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset(
                    CommonImages.referandearn,
                    width: 28.w,
                    height: 18.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: CommonColors.whiteColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s8,
          fontWeight: FontWeight.w600,
          color: CommonColors.whiteColor,
        ),
      ),
    );
  }

  Widget _buildBullet(String text, {bool hasConnector = true}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: CommonColors.whiteColor,
              ),
            ),
            if (hasConnector)
              Container(
                width: 1,
                height: 3.h,
                color: CommonColors.whiteColor.withValues(alpha: 0.35),
              ),
          ],
        ),
        SizedBox(width: 2.5.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s8,
              color: CommonColors.whiteColor.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ── Referral code ticket ────────────────────────────────────────────────
  Widget _buildReferralCode() {
    return SizedBox(
      height: 13.h,
      child: CustomPaint(
        painter: TicketPainter(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Row(
            children: [
              // Left section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'YOUR REFERRAL CODE',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s7,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: _inkLight,
                      ),
                    ),
                    SizedBox(height: 0.6.h),
                    Text(
                      referralCode,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        color: _ink,
                      ),
                    ),
                  ],
                ),
              ),

              // Dashed separator (visual only)
              Column(
                children: List.generate(
                  6,
                  (i) => Container(
                    width: 1,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: _divider,
                  ),
                ),
              ),

              SizedBox(width: 4.w),

              // Copy button
              GestureDetector(
                onTap: _copyToClipboard,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.2.h,
                  ),
                  decoration: BoxDecoration(
                    color: _copied ? const Color(0xFFD1FAE5) : _accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _copied
                        ? Row(
                            key: const ValueKey('copied'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                size: 4.w,
                                color: const Color(0xFF065F46),
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Copied!',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: FontSize.s9,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF065F46),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            key: const ValueKey('copy'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.copy_rounded,
                                size: 4.w,
                                color: CommonColors.whiteColor,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Copy',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: FontSize.s10,
                                  fontWeight: FontWeight.w700,
                                  color: CommonColors.whiteColor,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab bar ─────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabItem('Refer & Earn', 0),
          _buildTabItem('Referral History', 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: 1.3.h),
          decoration: BoxDecoration(
            color: isSelected ? _accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? CommonColors.whiteColor : _inkLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Refer & Earn tab content ────────────────────────────────────────────
  Widget _buildReferAndEarnContent() {
    return Column(
      key: const ValueKey('refer'),
      children: [
        _buildStepsCard(),
        SizedBox(height: 2.h),
        _buildButton(
          text: 'Get Friends to Refer',
          isOutlined: true,
          onPressed: () {},
        ),
        SizedBox(height: 1.2.h),
        _buildButton(text: 'Refer Now', isOutlined: false, onPressed: () {}),
      ],
    );
  }

  Widget _buildStepsCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Container(
                  width: 9.w,
                  height: 9.w,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.route_rounded,
                    color: CommonColors.whiteColor,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'How it works',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: const Color(0xFFF1F5F9)),

          _buildReferStep(
            number: '1',
            title: 'Share your link',
            text:
                'Send your referral link via WhatsApp, SMS, email, or any platform.',
            imagePath: 'assets/images/cover/womanspeak.png',
          ),
          Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
            margin: EdgeInsets.symmetric(horizontal: 4.w),
          ),
          _buildReferStep(
            number: '2',
            title: 'Friend registers',
            text:
                'Your friend clicks the link and creates an account on Aorbo.',
            imagePath: 'assets/images/cover/mobilephone.png',
            flip: true,
          ),
          Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
            margin: EdgeInsets.symmetric(horizontal: 4.w),
          ),
          _buildReferStep(
            number: '3',
            title: 'Both earn rewards',
            text: 'Get cashback when your friend completes their first trek.',
            imagePath: 'assets/images/img/approval.png',
          ),
        ],
      ),
    );
  }

  Widget _buildReferStep({
    required String number,
    required String title,
    required String text,
    required String imagePath,
    bool flip = false,
  }) {
    final content = Expanded(
      child: Column(
        crossAxisAlignment: flip
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Step number badge
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(
              color: flip ? const Color(0xFFF1F5F9) : _accent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s11,
                  fontWeight: FontWeight.w700,
                  color: flip ? _inkMid : CommonColors.whiteColor,
                ),
              ),
            ),
          ),
          SizedBox(height: 0.6.h),
          Text(
            title,
            textAlign: flip ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s11,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          SizedBox(height: 0.3.h),
          Text(
            text,
            textAlign: flip ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s9,
              height: 1.5,
              color: _inkMid,
            ),
          ),
        ],
      ),
    );

    final illustration = Image.asset(
      imagePath,
      width: 18.w,
      height: 18.w,
      fit: BoxFit.contain,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: flip
            ? [content, SizedBox(width: 4.w), illustration]
            : [illustration, SizedBox(width: 4.w), content],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required bool isOutlined,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 6.5.h,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              gradient: !isOutlined ? CommonColors.btnGradient : null,
              color: isOutlined ? _cardBg : null,
              border: isOutlined
                  ? Border.all(color: _divider, width: 1.5)
                  : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: isOutlined
                      ? CommonColors.blackColor.withValues(alpha: 0.04)
                      : CommonColors.blueColor.withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w700,
                  color: isOutlined ? _ink : CommonColors.whiteColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Referral History tab content ────────────────────────────────────────
  Widget _buildReferralHistoryContent() {
    return Column(
      key: const ValueKey('history'),
      children: [
        // Stats card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: CommonColors.blackColor.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header row
              Padding(
                padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 0),
                child: Row(
                  children: [
                    Container(
                      width: 9.w,
                      height: 9.w,
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: CommonColors.whiteColor,
                        size: 5.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Total Rewards',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s13,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const Spacer(),
                    Image.asset(
                      'assets/images/cover/moneytransfer.png',
                      width: 15.w,
                      height: 7.h,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹0',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s30,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 0.4.h),
                      child: Text(
                        '.00 earned',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s11,
                          color: _inkMid,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(height: 1, color: const Color(0xFFF1F5F9)),

              // Stats row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                child: Row(
                  children: [
                    _statItem('0', 'Referrals'),
                    Container(width: 1, height: 4.h, color: _divider),
                    _statItem('0', 'Completed'),
                    Container(width: 1, height: 4.h, color: _divider),
                    _statItem('₹0', 'Pending'),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 5.h),

        // Empty state
        Container(
          width: 18.w,
          height: 18.w,
          decoration: const BoxDecoration(
            color: Color(0xFFEEF2FF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.people_outline_rounded,
            size: 9.w,
            color: const Color(0xFF4F46E5),
          ),
        ),
        SizedBox(height: 1.5.h),
        Text(
          'No referrals yet',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s13,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Start referring friends to earn exciting rewards!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: FontSize.s10,
            color: _inkLight,
            height: 1.5,
          ),
        ),
        SizedBox(height: 3.h),
        _buildButton(text: 'Refer Now', isOutlined: false, onPressed: () {}),
      ],
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s14,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          SizedBox(height: 0.2.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s8,
              color: _inkLight,
            ),
          ),
        ],
      ),
    );
  }
}
