import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../controller/notification_controller.dart';
import '../utils/common_colors.dart';
import '../utils/common_bottom_nav.dart';
import '../utils/screen_constants.dart';

String _relativeTime(DateTime? dt) {
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  return '${(diff.inDays / 7).floor()} week(s) ago';
}

bool _isToday(DateTime? dt) {
  if (dt == null) return false;
  final now = DateTime.now();
  return dt.year == now.year && dt.month == now.month && dt.day == now.day;
}

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _NC {
  static const bg = Color(0xFFF8FAFC);
  static const cardBg = Color(0xFFFFFFFF);
  static const ink = Color(0xFF0F172A);
  static const inkMid = Color(0xFF64748B);
  static const inkLight = Color(0xFF94A3B8);
  static const accent = Color(0xFF4F46E5);
  static const accentLight = Color(0xFFEEF2FF);
  static const iconBadgeBg = Color(0xFF111827);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x0A000000);
}

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  String _selectedFilter = 'All';

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;
  final NotificationController _controller = Get.put(NotificationController());

  final List<String> _filters = ['All', 'Unread'];

  List<NotificationItem> get _filtered {
    if (_selectedFilter == 'Unread') {
      return _controller.notifications.where((n) => !n.isRead).toList();
    }
    return _controller.notifications;
  }

  int get _unreadCount => _controller.unreadCount.value;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _controller.fetchNotifications();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Notification card ─────────────────────────────────────────────────────
  Widget _buildNotificationCard(NotificationItem item, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + index * 55),
      curve: Curves.easeOutCubic,
      builder: (ctx, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: () => _controller.markAsRead(item),
        child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: item.isRead ? _NC.cardBg : _NC.accent.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead
                ? _NC.divider
                : _NC.accent.withValues(alpha: 0.2),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _NC.shadow,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 11.w,
                height: 11.w,
                decoration: BoxDecoration(
                  color: item.isRead
                      ? const Color(0xFFF1F5F9)
                      : _NC.accentLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '🔔',
                    style: TextStyle(fontSize: FontSize.s20),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: FontSize.s11,
                              fontWeight: item.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: _NC.ink,
                            ),
                          ),
                        ),
                        if (!item.isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                              color: _NC.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s9,
                        color: _NC.inkMid,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 10,
                          color: _NC.inkLight,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _relativeTime(item.createdAt),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s8,
                            color: _NC.inkLight,
                          ),
                        ),
                      ],
                    ),
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

  // ── Filter chip ───────────────────────────────────────────────────────────
  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    final showBadge = label == 'Unread' && _unreadCount > 0;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(
          horizontal: showBadge ? 10 : 14,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _NC.iconBadgeBg : _NC.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _NC.iconBadgeBg : _NC.divider),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _NC.iconBadgeBg.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s9,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : _NC.inkMid,
              ),
            ),
            if (showBadge) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : _NC.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_unreadCount',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s7,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s8,
              fontWeight: FontWeight.w600,
              color: _NC.inkMid,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 0.5, color: _NC.divider)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _NC.bg,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        // automaticallyImplyLeading: false,
        titleSpacing: 20.w,
        title: Row(
          children: [
            // GestureDetector(
            //   onTap: () => Get.back(),
            //   child: const Icon(
            //     Icons.arrow_back_ios_new_rounded,
            //     size: 18,
            //     color: _NC.ink,
            //   ),
            // ),
            // SizedBox(width: 2.w),
            Text(
              'Notifications',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s15,
                fontWeight: FontWeight.w700,
                color: _NC.ink,
              ),
            ),
          ],
        ),
        // actions: [
        //   if (_unreadCount > 0)
        //     Container(
        //       margin: EdgeInsets.only(right: 4.w),
        //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        //       decoration: BoxDecoration(
        //         color: _NC.accentLight,
        //         borderRadius: BorderRadius.circular(20),
        //       ),
        //       child: Row(
        //         children: [
        //           Container(
        //             width: 6,
        //             height: 6,
        //             decoration: const BoxDecoration(
        //               color: _NC.accent,
        //               shape: BoxShape.circle,
        //             ),
        //           ),
        //           const SizedBox(width: 5),
        //           Text(
        //             '$_unreadCount new',
        //             style: TextStyle(
        //               fontFamily: 'Poppins',
        //               fontSize: FontSize.s9,
        //               fontWeight: FontWeight.w600,
        //               color: _NC.accent,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        // ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _NC.divider),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 1.5.h),
              child: Obx(() => Row(children: _filters.map(_buildFilterChip).toList())),
            ),
            Container(height: 1, color: _NC.divider),

            // List
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value && _controller.notifications.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final filtered = _filtered;
                final todayItems = filtered.where((n) => _isToday(n.createdAt)).toList();
                final earlierItems = filtered.where((n) => !_isToday(n.createdAt)).toList();

                if (filtered.isEmpty) return _buildEmptyState();

                return RefreshIndicator(
                  onRefresh: _controller.fetchNotifications,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 4.h),
                    children: [
                      if (todayItems.isNotEmpty) ...[
                        _buildSectionLabel('TODAY'),
                        ...todayItems.asMap().entries.map(
                          (e) => _buildNotificationCard(e.value, e.key),
                        ),
                      ],
                      if (earlierItems.isNotEmpty) ...[
                        _buildSectionLabel('EARLIER'),
                        ...earlierItems.asMap().entries.map(
                          (e) => _buildNotificationCard(
                            e.value,
                            todayItems.length + e.key,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ),
          ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: const BoxDecoration(
              color: _NC.accentLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('🔔', style: TextStyle(fontSize: FontSize.s24)),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'No notifications here',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s13,
              fontWeight: FontWeight.w600,
              color: _NC.ink,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Check back later for updates',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: FontSize.s10,
              color: _NC.inkMid,
            ),
          ),
        ],
      ),
    );
  }
}
