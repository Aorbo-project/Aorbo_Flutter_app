import 'package:arobo_app/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';
import '../utils/common_images.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
//
//  Instead of writing CommonColors.cFF111827 everywhere,
//  we store all colors in one place as _C.ink etc.
//  If you ever want to change a color, you change it
//  here once and it updates everywhere automatically.
// ─────────────────────────────────────────────
class _C {
  static const bg        = CommonColors.materialLightBlue; // light blue-grey page background (matches CommonColors.materialLightBlueColor)
  static const cardBg    = CommonColors.whiteColor; // white card background
  static const ink       = CommonColors.cFF111827; // near-black for main text
  static const inkMid    = CommonColors.cFF6B7280; // grey for secondary text
  static const blue      = CommonColors.lightBlueColor3; // primary brand blue (matches CommonColors.materialLightBlueColor3)
  static const orange    = CommonColors.cFFEA580C; // orange for badges
  static const redText   = CommonColors.cFFDC2626; // red for logout button text
  static const redBorder = CommonColors.cFFFFE4E4; // light red for logout border
  static const divider   = CommonColors.cFFF3F4F6; // very light grey divider line
  static const shadow    = CommonColors.c0A000000; // subtle 4% black shadow
}

// ─────────────────────────────────────────────
//  SCREEN WIDGET
//
//  StatefulWidget because:
//   • We run a fade-in animation on load (_fadeCtrl)
//   • We use GetX (Obx) to reactively show user data
// ─────────────────────────────────────────────
class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen>
    with SingleTickerProviderStateMixin {

  // Get.put() creates the controller if it doesn't exist,
  // or finds the existing one if it's already in memory.
  final UserController _userC = Get.find<UserController>();

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  // ─── LIFECYCLE ─────────────────────────────

  @override
  void initState() {
    super.initState();

    // Fade the whole body in over 500ms when screen opens
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward(); // ..forward() starts it immediately

    // CurvedAnimation applies an easing curve so it
    // starts fast then slows down gently (easeOut)
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    // Always dispose AnimationControllers to free memory
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ─── BUILD ─────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),

      // FadeTransition makes the whole body fade in
      // using the _fade animation we set up above
      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          // BouncingScrollPhysics gives the iOS rubber-band
          // bounce effect when you reach the top or bottom
          physics: const BouncingScrollPhysics(),
          child: Padding(
            // 4.w = 4% of screen width on each side
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(height: 2.h),

                // ── User name + subtitle ──
                _buildUserHeader(),

                SizedBox(height: 3.h),

                // ── GROUP 1: Travel Management ──
                _buildSectionLabel('TRAVEL MANAGEMENT'),
                SizedBox(height: 1.h),
                _buildCard(children: [
                  _buildMenuItem(
                    icon: CommonImages.account,
                    title: 'Traveller Information',
                    onTap: () async {
                      // Fetch fresh user data before navigating
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
                ]),

                SizedBox(height: 2.5.h),

                // ── GROUP 2: Security & Help ──
                _buildSectionLabel('SECURITY & HELP'),
                SizedBox(height: 1.h),
                _buildCard(children: [
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
                ]),

                SizedBox(height: 2.5.h),

                // ── GROUP 3: Earnings & Claims ──
                _buildSectionLabel('EARNINGS & CLAIMS'),
                SizedBox(height: 1.h),
                _buildCard(children: [
                  _buildMenuItem(
                    icon: CommonImages.claims,
                    title: 'Claims',
                    onTap: () => Get.toNamed('/claim'),
                    // trailingWidget replaces the default chevron
                    trailingWidget: const _PendingBadge(amount: '₹4,250 Pending'),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: CommonImages.refer,
                    title: 'Refer & Earn',
                    onTap: () => Get.toNamed('/refers'),
                    trailingWidget: const _GetBadge(label: 'GET ₹500'),
                  ),
                ]),

                SizedBox(height: 2.5.h),

                // ── GROUP 4: More ──
                _buildSectionLabel('MORE'),
                SizedBox(height: 1.h),
                _buildCard(children: [
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
                ]),

                SizedBox(height: 3.h),

                // ── Logout (standalone, outside any card) ──
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
  //
  //  No default back button (automaticallyImplyLeading: false)
  //  We build our own back arrow + "Profile" title in blue
  //  + language chip on the right
  // ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: CommonColors.lightBlueColor3.withValues(alpha: 0.2), // matches help/notifications screens
      elevation: 0,
      scrolledUnderElevation: 0,        // no shadow when scrolled under
      surfaceTintColor: CommonColors.transparent,
      automaticallyImplyLeading: false, // we add our own back button below
      titleSpacing: 4.w,
      title: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: _C.ink,
            ),
          ),
          SizedBox(width: 2.w),
          // "Profile" title in brand blue
          Text(
            'Profile',
            style: GoogleFonts.poppins(
              fontSize: FontSize.s15,
              fontWeight: FontWeight.w600,
              color: _C.blue,
            ),
          ),
        ],
      ),
      actions: [
        // Language chip on the right side of appbar
        _LanguageChip(),
        SizedBox(width: 4.w),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  USER HEADER
  //
  //  Obx() is GetX's reactive builder.
  //  It watches _userC.userProfileData — any time
  //  that value changes (e.g. after getUserProfile()
  //  fetches from the server), this widget rebuilds
  //  automatically with the latest data.
  // ─────────────────────────────────────────────
  Widget _buildUserHeader() {
    return Obx(() {
      // Safely read nested data with null checks (?.)
      final customer = _userC.userProfileData.value.customer;

      // If name is empty or null, show a fallback
      final name = (customer?.name?.isNotEmpty == true)
          ? customer!.name!
          : 'Hey there';

      // Show phone number, stripping +91 prefix for cleaner display
      final subtitle = (customer?.phone?.isNotEmpty == true)
          ? customer!.phone!.replaceFirst('+91', '+91 ')
          : 'Manage your account & preferences';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large bold name
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: FontSize.s24,
              fontWeight: FontWeight.w700,
              color: _C.ink,
              height: 1.1,
            ),
          ),
          SizedBox(height: 0.5.h),
          // Smaller grey subtitle
          Text(
            subtitle,
            style: GoogleFonts.poppins(
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
  //
  //  The small spaced-caps label above each card group
  //  e.g. "TRAVEL MANAGEMENT", "SECURITY & HELP"
  //  letterSpacing: 1.2 gives it that spaced-out look
  // ─────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: FontSize.s8,
        fontWeight: FontWeight.w600,
        color: _C.inkMid,
        letterSpacing: 1.2,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  CARD
  //
  //  White rounded container with a soft shadow.
  //  Takes a list of children (menu items + dividers)
  //  and stacks them vertically inside.
  //
  //  Why Column with MainAxisSize.min?
  //  Without .min, Column tries to fill all available
  //  height — making the card stretch to the screen.
  //  .min makes it only as tall as its children need.
  // ─────────────────────────────────────────────
  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: const [
          BoxShadow(
            color: _C.shadow,   // 4% black — very subtle
            blurRadius: 12,
            spreadRadius: 0,
            offset: Offset(0, 2), // shadow goes 2px downward
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // only as tall as children
        children: children,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  MENU ITEM
  //
  //  Each row inside a card. Has:
  //   • Icon in a soft rounded square badge
  //   • Title text
  //   • Trailing: custom badge | coming soon | chevron
  //
  //  isComingSoon: true  → greyed out, non-tappable,
  //                        shows "Soon" pill + lock icon
  //  trailingWidget      → replaces the chevron with
  //                        a custom badge (e.g. ₹4,250)
  // ─────────────────────────────────────────────
  Widget _buildMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isComingSoon = false,
    Widget? trailingWidget,
  }) {
    return InkWell(
      // If coming soon, disable tap entirely
      onTap: isComingSoon ? null : onTap,
      borderRadius: BorderRadius.circular(4.w),
      // splashColor = the ripple color when tapped
      splashColor: _C.blue.withValues(alpha: 0.05),
      highlightColor: _C.blue.withValues(alpha: 0.03),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.8.h),
        child: Row(
          children: [

            // ── Icon badge ──
            // Blue-tinted square for active items,
            // grey for coming-soon items
            Container(
              width: 9.w,
              height: 9.w,
              decoration: BoxDecoration(
                color: isComingSoon
                    ?   CommonColors.cFFF3F4F6 // grey bg
                    :   CommonColors.cFFEFF6FF, // blue-tinted bg
                borderRadius: BorderRadius.circular(2.5.w),
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: 5.w,
                  height: 5.w,
                  // ColorFilter recolors the SVG icon
                  colorFilter: ColorFilter.mode(
                    isComingSoon ? _C.inkMid : _C.blue,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            SizedBox(width: 4.w),

            // ── Title ──
            // Expanded takes all remaining width
            // so the trailing widget stays on the right
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s11,
                  fontWeight: FontWeight.w500,
                  color: isComingSoon ? _C.inkMid : _C.ink,
                ),
              ),
            ),

            // ── Trailing widget ──
            // Three possible states:
            if (trailingWidget != null) ...[
              // 1. Custom badge (₹4,250 / GET ₹500)
              trailingWidget,
              SizedBox(width: 2.w),
              const Icon(Icons.chevron_right, size: 18, color: _C.inkMid),

            ] else if (isComingSoon) ...[
              // 2. "Soon" pill + lock icon
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.5.w,
                  vertical: 0.4.h,
                ),
                decoration: BoxDecoration(
                  color:   CommonColors.cFFF3F4F6,
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Text(
                  'Soon',
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s7,
                    fontWeight: FontWeight.w500,
                    color: _C.inkMid,
                  ),
                ),
              ),
              SizedBox(width: 1.w),
              const Icon(
                Icons.lock_outline_rounded,
                size: 15,
                color: _C.inkMid,
              ),

            ] else
              // 3. Default chevron arrow
              const Icon(Icons.chevron_right, size: 18, color: _C.inkMid),

          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  DIVIDER
  //
  //  A thin 0.5px line between menu items.
  //  margin: EdgeInsets.only(left: 18.w) indents it
  //  so it starts after the icon, not from the edge.
  //  This matches the Figma design exactly.
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
  //
  //  Standalone button — NOT inside a card.
  //  White background + red border + red text.
  //  Sits at the bottom of the screen on its own.
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
          // red border makes it look like a danger action
          border: Border.all(color: _C.redBorder, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: _C.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: _C.redText, size: 18),
            SizedBox(width: 2.w),
            Text(
              'Logout Account',
              style: GoogleFonts.poppins(
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
//
//  Sits in the AppBar actions (top right).
//  A small white rounded pill showing the current
//  language with a dropdown arrow.
//  Wire up onTap to your language picker later.
// ─────────────────────────────────────────────
class _LanguageChip extends StatelessWidget {
  const _LanguageChip();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // TODO: wire up language picker
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
        decoration: BoxDecoration(
          color: CommonColors.whiteColor,
          borderRadius: BorderRadius.circular(2.5.w),
          border: Border.all(
            color:   CommonColors.cFFE5E7EB,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Globe icon
            const Icon(Icons.language_rounded, size: 14, color: _C.inkMid),
            SizedBox(width: 1.w),
            // Language text
            Text(
              'ENG',
              style: GoogleFonts.poppins(
                fontSize: FontSize.s9,
                fontWeight: FontWeight.w500,
                color: _C.ink,
              ),
            ),
            SizedBox(width: 0.5.w),
            // Dropdown arrow
            const Icon(
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
//
//  Orange outlined pill shown on the Claims row.
//  Orange text on a warm cream background
//  with an orange border.
// ─────────────────────────────────────────────
class _PendingBadge extends StatelessWidget {
  final String amount;
  const _PendingBadge({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color:   CommonColors.cFFFFF7ED,       // warm cream bg
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color:   CommonColors.cFFFED7AA,     // soft orange border
          width: 1,
        ),
      ),
      child: Text(
        amount,
        style: GoogleFonts.poppins(
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
//
//  Solid orange filled pill shown on Refer & Earn.
//  White bold text on orange background.
//  More attention-grabbing than the outlined badge.
// ─────────────────────────────────────────────
class _GetBadge extends StatelessWidget {
  final String label;
  const _GetBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: _C.orange,                     // solid orange fill
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: FontSize.s8,
          fontWeight: FontWeight.w700,
          color: CommonColors.whiteColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
