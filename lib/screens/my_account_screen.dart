import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';
import '../utils/common_images.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _C {
  static const bg = CommonColors.offWhiteColor;
  static const cardBg = CommonColors.whiteColor;
  static const ink = CommonColors.blackColor;
  static const inkMid = CommonColors.cFF6B7280;
  static const inkLight = CommonColors.grey_AEAEAE;
  static const brand = CommonColors.trek_route_color;
  static const teal = CommonColors.cFF0F7B6C;
  static const tealSoft = CommonColors.cFFE6F5F3;
  static const iconBadge = CommonColors.cFF111827;
  static const divider = CommonColors.trekroutecolorlight;
  static const shadow = CommonColors.c0A000000;

  static final orange = CommonColors.cFFEA580C;
  static final redText = CommonColors.cFFDC2626;
  static final redBorder = CommonColors.cFFFFE4E4;
}

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen>
    with TickerProviderStateMixin {
  final UserController _userC = Get.find<UserController>();
  final DashboardController _dashboardC = Get.find<DashboardController>();

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  late final AnimationController _headerSlideCtrl;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _headerFade;

  late final List<AnimationController> _cardCtrls;
  late final List<Animation<Offset>> _cardSlides;
  late final List<Animation<double>> _cardFades;

  late final AnimationController _logoutCtrl;
  late final Animation<Offset> _logoutSlide;
  late final Animation<double> _logoutFade;

  static const int _cardCount = 5;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _headerSlideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _headerSlideCtrl, curve: Curves.easeOutCubic),
        );

    _headerFade = CurvedAnimation(
      parent: _headerSlideCtrl,
      curve: Curves.easeOut,
    );

    _cardCtrls = List.generate(
      _cardCount,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _cardSlides = _cardCtrls
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.25),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)),
        )
        .toList();

    _cardFades = _cardCtrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();

    _logoutCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _logoutSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoutCtrl, curve: Curves.easeOutCubic));

    _logoutFade = CurvedAnimation(parent: _logoutCtrl, curve: Curves.easeOut);

    _runStaggeredEntrance();
  }

  Future<void> _runStaggeredEntrance() async {
    await Future.delayed(const Duration(milliseconds: 80));

    if (!mounted) return;
    _headerSlideCtrl.forward();

    for (int i = 0; i < _cardCount; i++) {
      await Future.delayed(const Duration(milliseconds: 90));
      if (!mounted) return;
      _cardCtrls[i].forward();
    }

    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    _logoutCtrl.forward();
  }

  void _goToDashboard() {
    _dashboardC.selectedScreen.value = 0;
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _headerSlideCtrl.dispose();

    for (final c in _cardCtrls) {
      c.dispose();
    }

    _logoutCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SlideTransition(
                  position: _headerSlide,
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: _buildUserHeader(),
                  ),
                ),

                SizedBox(height: 2.5.h),

                _buildAnimatedSection(
                  index: 0,
                  label: 'TRAVEL MANAGEMENT',
                  child: _buildCard(
                    children: [
                      _buildMenuItem(
                        icon: CommonImages.account,
                        title: 'Traveller Information',
                        onTap: () async {
                          await _userC.getUserProfile();
                          Get.toNamed('/traveller-information');
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: CommonImages.appointment,
                        title: 'My Bookings',
                        onTap: () => Get.toNamed('/my-bookings'),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2.h),

                _buildAnimatedSection(
                  index: 1,
                  label: 'SECURITY & HELP',
                  child: _buildCard(
                    children: [
                      _buildMenuItem(
                        icon: CommonImages.safety,
                        title: 'Safety',
                        onTap: () => Get.toNamed('/safety'),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: CommonImages.help,
                        title: 'Help',
                        onTap: () => Get.toNamed('/help'),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: CommonImages.notification,
                        title: 'Notifications',
                        onTap: () => Get.toNamed('/notifications'),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2.h),

                _buildAnimatedSection(
                  index: 2,
                  label: 'EARNINGS & CLAIMS',
                  child: _buildCard(
                    children: [
                      _buildMenuItem(
                        icon: CommonImages.claims,
                        title: 'Claims',
                        onTap: () {},
                        isComingSoon: true,
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: CommonImages.refer,
                        title: 'Refer & Earn',
                        onTap: () => Get.toNamed('/refers'),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2.h),

                _buildAnimatedSection(
                  index: 3,
                  label: 'MORE',
                  child: _buildCard(
                    children: [
                      _buildMenuItem(
                        icon: CommonImages.partner,
                        title: 'Become Partner',
                        onTap: () {},
                        isComingSoon: true,
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: CommonImages.rate,
                        title: 'Rate us',
                        onTap: () {},
                        isComingSoon: true,
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: CommonImages.info,
                        title: 'About Aorbo Treks',
                        onTap: () => Get.toNamed('/about-us'),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                SlideTransition(
                  position: _logoutSlide,
                  child: FadeTransition(
                    opacity: _logoutFade,
                    child: _buildLogoutButton(),
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

  Widget _buildAnimatedSection({
    required int index,
    required String label,
    required Widget child,
  }) {
    return SlideTransition(
      position: _cardSlides[index],
      child: FadeTransition(
        opacity: _cardFades[index],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(label),
            SizedBox(height: 1.2.h),
            child,
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _C.cardBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: CommonColors.transparent,
      automaticallyImplyLeading: false,
      iconTheme: const IconThemeData(color: _C.ink),
      titleSpacing: 4.w,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _C.divider),
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: _goToDashboard,
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: _C.ink,
            ),
          ),
          SizedBox(width: 2.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s13,
                  fontWeight: FontWeight.w700,
                  color: _C.ink,
                ),
              ),
              Text(
                'Manage account & preferences',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s9,
                  color: _C.inkMid,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        const _LanguageChip(),
        SizedBox(width: 4.w),
      ],
    );
  }

  Widget _buildUserHeader() {
    return Obx(() {
      final customer = _userC.userProfileData.value.customer;

      final name = customer?.name?.isNotEmpty == true
          ? customer!.name!
          : 'Hey there';

      final subtitle = customer?.phone?.isNotEmpty == true
          ? customer!.phone!.replaceFirst('+91', '+91 ')
          : 'Manage your account & preferences';

      final initial = customer?.name?.isNotEmpty == true
          ? customer!.name![0].toUpperCase()
          : '?';

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(4.w),
          boxShadow: [
            BoxShadow(
              color: CommonColors.blackColor.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 14.w,
              height: 14.w,
              decoration: BoxDecoration(
                color: _C.brand.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: _C.brand.withValues(alpha: 0.25)),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s18,
                    fontWeight: FontWeight.w700,
                    color: _C.brand,
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s16,
                      fontWeight: FontWeight.w700,
                      color: _C.ink,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 0.4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s9,
                      color: _C.inkMid,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 1.w),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s12,
          fontWeight: FontWeight.w700,
          color: _C.ink,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isComingSoon = false,
    Widget? trailingWidget,
  }) {
    return _AnimatedMenuTile(
      icon: icon,
      title: title,
      onTap: isComingSoon ? null : onTap,
      isComingSoon: isComingSoon,
      trailingWidget: trailingWidget,
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.only(left: 18.w),
      height: 0.5,
      color: _C.divider,
    );
  }

  Widget _buildLogoutButton() {
    return _AnimatedLogoutButton(onTap: () => Get.toNamed('/logout'));
  }
}

// ─────────────────────────────────────────────
//  ANIMATED MENU TILE
// ─────────────────────────────────────────────
class _AnimatedMenuTile extends StatefulWidget {
  final String icon;
  final String title;
  final VoidCallback? onTap;
  final bool isComingSoon;
  final Widget? trailingWidget;

  const _AnimatedMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isComingSoon,
    this.trailingWidget,
  });

  @override
  State<_AnimatedMenuTile> createState() => _AnimatedMenuTileState();
}

class _AnimatedMenuTileState extends State<_AnimatedMenuTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isComingSoon) return;
    _pressCtrl.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isComingSoon) return;
    _pressCtrl.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (widget.isComingSoon) return;
    _pressCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.isComingSoon ? null : _handleTapDown,
      onTapUp: widget.isComingSoon ? null : _handleTapUp,
      onTapCancel: widget.isComingSoon ? null : _handleTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.8.h),
          child: Row(
            children: [
              Container(
                width: 9.w,
                height: 9.w,
                decoration: BoxDecoration(
                  color: widget.isComingSoon
                      ? const Color(0xFFF1F5F9)
                      : _C.iconBadge,
                  borderRadius: BorderRadius.circular(2.5.w),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    widget.icon,
                    width: 5.w,
                    height: 5.w,
                    colorFilter: ColorFilter.mode(
                      widget.isComingSoon
                          ? _C.inkMid
                          : CommonColors.primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s11,
                    fontWeight: FontWeight.w500,
                    color: widget.isComingSoon ? _C.inkMid : _C.ink,
                  ),
                ),
              ),
              if (widget.trailingWidget != null) ...[
                widget.trailingWidget!,
                SizedBox(width: 2.w),
                Icon(Icons.chevron_right, size: 18, color: _C.inkMid),
              ] else if (widget.isComingSoon) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.5.w,
                    vertical: 0.4.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Text(
                    'Soon',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s7,
                      fontWeight: FontWeight.w500,
                      color: _C.inkMid,
                    ),
                  ),
                ),
                SizedBox(width: 1.w),
                Icon(Icons.lock_outline_rounded, size: 15, color: _C.inkMid),
              ] else
                Icon(Icons.chevron_right, size: 18, color: _C.inkMid),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ANIMATED LOGOUT BUTTON
// ─────────────────────────────────────────────
class _AnimatedLogoutButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedLogoutButton({required this.onTap});

  @override
  State<_AnimatedLogoutButton> createState() => _AnimatedLogoutButtonState();
}

class _AnimatedLogoutButtonState extends State<_AnimatedLogoutButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<Color?> _bgColor;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 220),
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _bgColor = ColorTween(
      begin: CommonColors.whiteColor,
      end: CommonColors.cFFFFE4E4,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _ctrl.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _ctrl.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 1.8.h),
              decoration: BoxDecoration(
                color: _bgColor.value,
                borderRadius: BorderRadius.circular(4.w),
                border: Border.all(color: _C.redBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: CommonColors.blackColor.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: _C.redText, size: 18),
            SizedBox(width: 2.w),
            Text(
              'Logout Account',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s11,
                fontWeight: FontWeight.w600,
                color: _C.redText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  LANGUAGE CHIP
// ─────────────────────────────────────────────
class _LanguageChip extends StatelessWidget {
  const _LanguageChip();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
        decoration: BoxDecoration(
          color: CommonColors.whiteColor,
          borderRadius: BorderRadius.circular(2.5.w),
          border: Border.all(color: CommonColors.cFFE5E7EB, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language_rounded, size: 14, color: _C.inkMid),
            SizedBox(width: 1.w),
            Text(
              'ENG',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                fontWeight: FontWeight.w500,
                color: _C.ink,
              ),
            ),
            SizedBox(width: 0.5.w),
            Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: _C.inkMid),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PENDING BADGE
// ─────────────────────────────────────────────
class _PendingBadge extends StatelessWidget {
  final String amount;

  const _PendingBadge({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: CommonColors.cFFFFF7ED,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: CommonColors.cFFFED7AA, width: 1),
      ),
      child: Text(
        amount,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s8,
          fontWeight: FontWeight.w600,
          color: _C.orange,
        ),
      ),
    );
  }
}
