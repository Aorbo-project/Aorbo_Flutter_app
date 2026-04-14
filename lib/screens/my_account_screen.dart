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
  // FIX: bg changed from materialLightBlue → whiteColor (#FEFEFE)
  // so the page background matches all other white screens
  static const bg = CommonColors.whiteColor;
  static const cardBg = CommonColors.whiteColor;
  static final ink = CommonColors.cFF111827;
  static final inkMid = CommonColors.cFF6B7280;
  static final blue = CommonColors.lightBlueColor3;
  static final orange = CommonColors.cFFEA580C;
  static final redText = CommonColors.cFFDC2626;
  static final redBorder = CommonColors.cFFFFE4E4;
  static final divider = CommonColors.cFFF3F4F6;
  static final shadow = CommonColors.c0A000000;
}

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen>
    with SingleTickerProviderStateMixin {
  final UserController _userC = Get.find<UserController>();

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
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
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                _buildUserHeader(),
                SizedBox(height: 3.h),

                // ── GROUP 1: Travel Management ──
                _buildSectionLabel('TRAVEL MANAGEMENT'),
                SizedBox(height: 1.h),
                _buildCard(
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

                SizedBox(height: 2.5.h),

                // ── GROUP 2: Security & Help ──
                _buildSectionLabel('SECURITY & HELP'),
                SizedBox(height: 1.h),
                _buildCard(
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

                SizedBox(height: 2.5.h),

                // ── GROUP 3: Earnings & Claims ──
                _buildSectionLabel('EARNINGS & CLAIMS'),
                SizedBox(height: 1.h),
                _buildCard(
                  children: [
                    _buildMenuItem(
                      icon: CommonImages.claims,
                      title: 'Claims',
                      onTap: () => Get.toNamed('/claim'),
                      // trailingWidget: const _PendingBadge(
                      //   amount: '₹4,250 Pending',
                      // ),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: CommonImages.refer,
                      title: 'Refer & Earn',
                      onTap: () => Get.toNamed('/refers'),
                      trailingWidget: const _GetBadge(label: 'GET ₹500'),
                    ),
                  ],
                ),

                SizedBox(height: 2.5.h),

                // ── GROUP 4: More ──
                _buildSectionLabel('MORE'),
                SizedBox(height: 1.h),
                _buildCard(
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

                SizedBox(height: 3.h),
                _buildLogoutButton(),
                SizedBox(height: 5.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  APP BAR
  //  FIX: backgroundColor changed to whiteColor
  //  to match the new white page background
  // ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      // FIX: white appbar — no blue tint, matches page bg
      backgroundColor: CommonColors.whiteColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: CommonColors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 4.w,
      title: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: _C.ink,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            'Profile',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s15,
              fontWeight: FontWeight.w600,
              color: CommonColors.cFF111827,
            ),
          ),
        ],
      ),
      actions: [
        _LanguageChip(),
        SizedBox(width: 4.w),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  USER HEADER
  // ─────────────────────────────────────────────
  Widget _buildUserHeader() {
    return Obx(() {
      final customer = _userC.userProfileData.value.customer;
      final name = (customer?.name?.isNotEmpty == true)
          ? customer!.name!
          : 'Hey there';
      final subtitle = (customer?.phone?.isNotEmpty == true)
          ? customer!.phone!.replaceFirst('+91', '+91 ')
          : 'Manage your account & preferences';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s24,
              fontWeight: FontWeight.w700,
              color: _C.ink,
              height: 1.1,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s9,
              color: _C.inkMid,
            ),
          ),
        ],
      );
    });
  }

  // ─────────────────────────────────────────────
  //  SECTION LABEL
  // ─────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: FontSize.s8,
        fontWeight: FontWeight.w600,
        color: _C.inkMid,
        letterSpacing: 1.2,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  CARD
  // ─────────────────────────────────────────────
  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 12,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  // ─────────────────────────────────────────────
  //  MENU ITEM
  // ─────────────────────────────────────────────
  Widget _buildMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isComingSoon = false,
    Widget? trailingWidget,
  }) {
    return InkWell(
      onTap: isComingSoon ? null : onTap,
      borderRadius: BorderRadius.circular(4.w),
      splashColor: _C.blue.withValues(alpha: 0.05),
      highlightColor: _C.blue.withValues(alpha: 0.03),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.8.h),
        child: Row(
          children: [
            Container(
              width: 9.w,
              height: 9.w,
              decoration: BoxDecoration(
                // FIX: dark near-black badge background for active items
                color: isComingSoon
                    ? CommonColors.cFFF3F4F6
                    : CommonColors.cFF111827,
                borderRadius: BorderRadius.circular(2.5.w),
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: 5.w,
                  height: 5.w,
                  // FIX: white icon on dark badge (bold, high contrast)
                  colorFilter: ColorFilter.mode(
                    isComingSoon ? _C.inkMid : CommonColors.whiteColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: FontSize.s11,
                  fontWeight: FontWeight.w500,
                  color: isComingSoon ? _C.inkMid : _C.ink,
                ),
              ),
            ),
            if (trailingWidget != null) ...[
              trailingWidget,
              SizedBox(width: 2.w),
              Icon(Icons.chevron_right, size: 18, color: _C.inkMid),
            ] else if (isComingSoon) ...[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.5.w,
                  vertical: 0.4.h,
                ),
                decoration: BoxDecoration(
                  color: CommonColors.cFFF3F4F6,
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
              Icon(
                Icons.lock_outline_rounded,
                size: 15,
                color: _C.inkMid,
              ),
            ] else
              Icon(Icons.chevron_right, size: 18, color: _C.inkMid),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  DIVIDER
  // ─────────────────────────────────────────────
  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.only(left: 18.w),
      height: 0.5,
      color: _C.divider,
    );
  }

  // ─────────────────────────────────────────────
  //  LOGOUT BUTTON
  // ─────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => Get.toNamed('/logout'),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 1.8.h),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(color: _C.redBorder, width: 1.5),
          boxShadow: [
            BoxShadow(color: _C.shadow, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
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
//  LANGUAGE CHIP  (🌐 ENG ▾)
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
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: _C.inkMid,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PENDING BADGE  (₹4,250 Pending)
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

// ─────────────────────────────────────────────
//  GET BADGE  (GET ₹500)
// ─────────────────────────────────────────────
class _GetBadge extends StatelessWidget {
  final String label;
  const _GetBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: _C.orange,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s8,
          fontWeight: FontWeight.w700,
          color: CommonColors.whiteColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
