import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../controller/notification_controller.dart';
import '../utils/screen_constants.dart';

// ─────────────────────────────────────────────
//  TIME HELPERS
// ─────────────────────────────────────────────
String _relativeTime(DateTime? dt) {
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${(diff.inDays / 7).floor()}w ago';
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool _isToday(DateTime? dt) => dt != null && _sameDay(dt, DateTime.now());

bool _isYesterday(DateTime? dt) =>
    dt != null &&
    _sameDay(dt, DateTime.now().subtract(const Duration(days: 1)));

// ─────────────────────────────────────────────
//  MODERN DESIGN TOKENS
// ─────────────────────────────────────────────
class _NT {
  static const bg = Color(0xFFF8F9FA); // Light crisp gray
  static const card = Color(0xFFFFFFFF);
  static const primary = Color(0xFF1A4D2E); // Deep forest green
  static const primaryLight = Color(0xFF2C5F2D);
  static const accent = Color(0xFFF4A261); // Sunrise orange
  static const departure = Color(0xFFE76F51); // Terracotta
  static const reminder = Color(0xFFF4A261); // Amber
  static const booking = Color(0xFF2A9D8F); // Teal
  static const payment = Color(0xFF264653); // Dark Cyan
  static const offer = Color(0xFFE9C46A); // Gold
  static const general = Color(0xFF1A4D2E); // Forest
  static const ink = Color(0xFF1E1E1E);
  static const inkMid = Color(0xFF6B7280);
  static const inkLight = Color(0xFF9CA3AF);
  static const divider = Color(0xFFE5E7EB);
}

// ─────────────────────────────────────────────
//  NOTIFICATION TYPE META
// ─────────────────────────────────────────────
enum _NoticeType { departure, reminder, booking, payment, offer, general }

class _NoticeMeta {
  final IconData icon;
  final Color color;

  const _NoticeMeta(this.icon, this.color);

  static _NoticeMeta of(NotificationItem n) {
    final t = '${n.title} ${n.message}'.toLowerCase();
    if (t.contains('departure') || t.contains('departs')) {
      return const _NoticeMeta(Icons.hiking_rounded, _NT.departure);
    }
    if (t.contains('reminder') || t.contains('starts in')) {
      return const _NoticeMeta(Icons.alarm_rounded, _NT.reminder);
    }
    if (t.contains('booking') || t.contains('confirmed')) {
      return const _NoticeMeta(Icons.verified_rounded, _NT.booking);
    }
    if (t.contains('payment') || t.contains('refund') || t.contains('paid')) {
      return const _NoticeMeta(Icons.payments_rounded, _NT.payment);
    }
    if (t.contains('offer') || t.contains('discount') || t.contains('% off')) {
      return const _NoticeMeta(Icons.local_offer_rounded, _NT.offer);
    }
    return const _NoticeMeta(Icons.terrain_rounded, _NT.general);
  }
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
    with TickerProviderStateMixin {
  String _selectedFilter = 'All';

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;
  late final AnimationController _pulseCtrl;

  final NotificationController _controller = Get.put(NotificationController());

  final List<String> _filters = ['All', 'Unread'];

  List<NotificationItem> get _filtered {
    if (_selectedFilter == 'Unread') {
      return _controller.notifications.where((n) => !n.isRead).toList();
    }
    return _controller.notifications.toList();
  }

  int get _unreadCount => _controller.unreadCount.value;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    // Pulse animation for unread dot
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _controller.fetchNotifications();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────
  //  HEADER — Deep Forest Gradient
  // ───────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_NT.primary, _NT.primaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(4.w, 2.h, 5.w, 3.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Back Button + Title + Mark All Read
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: FontSize.s20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => _unreadCount > 0
                        ? GestureDetector(
                            onTap: _controller.markAllAsRead,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.done_all_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Mark all read',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: FontSize.s9,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),
              Obx(
                () => Text(
                  _unreadCount > 0
                      ? 'You have $_unreadCount unread updates'
                      : 'You\'re all caught up! 🏔️',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: FontSize.s11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              // Filter Chips
              Obx(
                () => Row(
                  children: _filters.map((f) {
                    final isSelected = _selectedFilter == f;
                    final showBadge = f == 'Unread' && _unreadCount > 0;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = f),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              f,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s10,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? _NT.primary : Colors.white,
                              ),
                            ),
                            if (showBadge) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _NT.primary
                                      : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$_unreadCount',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: FontSize.s8,
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
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────
  //  SECTION LABEL
  // ───────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2.w, 2.h, 2.w, 1.h),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: FontSize.s11,
          fontWeight: FontWeight.w800,
          color: _NT.inkMid,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ───────────────────────────────────────────
  //  NOTIFICATION CARD
  // ───────────────────────────────────────────
  Widget _buildNotificationCard(NotificationItem item, int index) {
    final meta = _NoticeMeta.of(item);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index.clamp(0, 6)) * 60),
      curve: Curves.easeOutCubic,
      builder: (ctx, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: () => _controller.markAsRead(item),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _NT.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.isRead ? _NT.divider : meta.color.withOpacity(0.3),
              width: item.isRead ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                // Left Accent Line
                if (!item.isRead)
                  Container(width: 4, color: meta.color)
                else
                  Container(width: 4, color: Colors.transparent),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Container
                        Container(
                          width: 11.w,
                          height: 11.w,
                          decoration: BoxDecoration(
                            color: meta.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(meta.icon, size: 20, color: meta.color),
                        ),
                        const SizedBox(width: 12),

                        // Text Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: FontSize.s12,
                                        fontWeight: item.isRead
                                            ? FontWeight.w600
                                            : FontWeight.w800,
                                        color: _NT.ink,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                  if (!item.isRead)
                                    FadeTransition(
                                      opacity: _pulseCtrl,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: _NT.accent,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: _NT.accent.withOpacity(
                                                0.4,
                                              ),
                                              blurRadius: 5,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: FontSize.s10,
                                  color: _NT.inkMid,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 11,
                                    color: _NT.inkLight,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _relativeTime(item.createdAt),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: FontSize.s9,
                                      fontWeight: FontWeight.w500,
                                      color: _NT.inkLight,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────
  //  LIST BODY
  // ───────────────────────────────────────────
  Widget _buildBody() {
    return Obx(() {
      if (_controller.isLoading.value && _controller.notifications.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: _NT.primary),
        );
      }

      final filtered = _filtered;
      if (filtered.isEmpty) return _buildEmptyState();

      final today = filtered.where((n) => _isToday(n.createdAt)).toList();
      final yesterday = filtered
          .where((n) => _isYesterday(n.createdAt))
          .toList();
      final earlier = filtered
          .where((n) => !_isToday(n.createdAt) && !_isYesterday(n.createdAt))
          .toList();

      final children = <Widget>[];
      var runningIndex = 0;

      void addSection(String label, List<NotificationItem> items) {
        if (items.isEmpty) return;
        children.add(_buildSectionLabel(label));
        for (var i = 0; i < items.length; i++) {
          children.add(_buildNotificationCard(items[i], runningIndex++));
        }
      }

      addSection('TODAY', today);
      addSection('YESTERDAY', yesterday);
      addSection('EARLIER', earlier);

      return RefreshIndicator(
        color: _NT.primary,
        onRefresh: _controller.fetchNotifications,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 6.h),
          children: children,
        ),
      );
    });
  }

  // ───────────────────────────────────────────
  //  EMPTY STATE
  // ───────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 25.w,
              height: 25.w,
              decoration: BoxDecoration(
                color: _NT.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 40.sp,
                color: _NT.primary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              _selectedFilter == 'Unread'
                  ? 'No Unread Notifications'
                  : 'You\'re all caught up!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s14,
                fontWeight: FontWeight.w700,
                color: _NT.ink,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Trek alerts and reminders will land here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: FontSize.s10,
                color: _NT.inkMid,
              ),
            ),
            SizedBox(height: 3.h),
            GestureDetector(
              onTap: _controller.fetchNotifications,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _NT.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _NT.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Refresh',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────
  //  BUILD
  // ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _NT.bg,
      body: FadeTransition(
        opacity: _fade,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }
}
