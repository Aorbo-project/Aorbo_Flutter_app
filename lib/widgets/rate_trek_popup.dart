import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../freezed_models/booking/booking_history_model.dart';
import '../utils/ist_date_utils.dart';
import '../utils/shared_preferences.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';

class RateTrekPopup {
  RateTrekPopup._();

  static const String _prefPrefix = 'rate_popup_shown_';

  // ── MANUAL TESTING SWITCH ──────────────────────────────────────────────
  // Set true to force the popup to show on every fresh app launch, ignoring
  // both the "already shown this session" and the 24-hour re-nag guard.
  // Flip back to false before shipping - this is a testing convenience
  // only, the real guards below are untouched and still fully implemented.
  static const bool debugAlwaysShow = false; // ← FIXED: was true

  static bool _visibleThisSession = false;
  static OverlayEntry? _overlayEntry;

  static bool isRated(BookingHistoryData? b) {
    if (b == null) return false;
    return b.ratingGiven == true || (b.ratingValue ?? 0.0) > 0.0;
  }

  static double ratingValueOf(BookingHistoryData? b) {
    return (b?.ratingValue ?? 0.0).toDouble();
  }

  static Future<void> debugClearShownFlag(dynamic bookingId) async {
    if (bookingId == null) return;
    final pref = await SpUtil.getInstance();
    await pref.remove('$_prefPrefix$bookingId');
  }

  /// Public dismiss — call from DashboardMain.dispose() to prevent
  /// the OverlayEntry from leaking when the widget tree is torn down.
  static void dismiss() {
    // ← FIXED: new public method
    _removeOverlay();
  }

  static BookingHistoryData? findEligibleBooking(
    List<BookingHistoryData> bookings, {
    int recentWindowDays = 90,
  }) {
    final now = DateTime.now();
    BookingHistoryData? best;
    DateTime? bestEnd;

    for (final b in bookings) {
      final status = (b.status ?? '').toLowerCase();
      final trekStatus = (b.trekStatus ?? '').toLowerCase();
      if (status == 'cancelled') continue;

      final bool isRated =
          b.ratingGiven == true || (b.ratingValue ?? 0.0) > 0.0;
      if (isRated) continue;

      final end = ISTDateUtils.toIST(b.batch?.endDate);

      final bool isCompletedStatus =
          trekStatus == 'completed' || status == 'completed';
      final bool isCompletedByDate = end != null && now.isAfter(end);

      if (!isCompletedStatus && !isCompletedByDate) continue;

      if (!isCompletedStatus && end != null) {
        if (now.difference(end).inDays > recentWindowDays) continue;
      }

      if (bestEnd == null || (end != null && end.isAfter(bestEnd))) {
        best = b;
        bestEnd = end;
      }
    }
    return best;
  }

  static Future<void> maybeShow(
    BuildContext context,
    List<BookingHistoryData> bookings,
  ) async {
    if (_visibleThisSession && !debugAlwaysShow) {
      debugPrint('[RateTrekPopup] skipped — already visible this session');
      return;
    }

    final booking = findEligibleBooking(bookings);
    if (booking == null || booking.id == null) {
      debugPrint('[RateTrekPopup] skipped — no eligible booking found');
      return;
    }

    final pref = await SpUtil.getInstance();
    final key = '$_prefPrefix${booking.id}';

    if (!debugAlwaysShow) {
      final lastShownStr = pref.getString(key) ?? '';
      if (lastShownStr.isNotEmpty) {
        final lastShown = DateTime.tryParse(lastShownStr);
        if (lastShown != null &&
            DateTime.now().difference(lastShown) < const Duration(hours: 24)) {
          return; // shown recently — don't nag again this soon
        }
      }
    }

    if (!context.mounted) return;
    _visibleThisSession = true;

    // Persist BEFORE showing so a crash mid-dialog can't cause a re-nag loop.
    await pref.putString(key, DateTime.now().toIso8601String());

    if (!context.mounted) {
      _visibleThisSession = false;
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (ctx) =>
          _RateTrekSidePopup(booking: booking, onClose: _removeOverlay),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  static void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _visibleThisSession = false;
  }
}

class _RateTrekSidePopup extends StatefulWidget {
  final BookingHistoryData booking;
  final VoidCallback onClose;

  const _RateTrekSidePopup({required this.booking, required this.onClose});

  @override
  State<_RateTrekSidePopup> createState() => _RateTrekSidePopupState();
}

class _RateTrekSidePopupState extends State<_RateTrekSidePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    _controller.reverse().then((_) {
      if (mounted) widget.onClose();
    });
  }

  void _goRate([double? preSelected]) {
    HapticFeedback.mediumImpact();
    _close();
    Get.toNamed(
      '/rate-review',
      arguments: {
        'booking': widget.booking,
        if (preSelected != null) 'preSelectedRating': preSelected,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.booking.trek?.title ?? 'Your trek';

    return Positioned(
      right: 3.w,
      bottom: 11.h,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              color: Colors.transparent,
              child: _buildCard(title),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title) {
    return Container(
      width: 82.w,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestDeep.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(-4, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: -25,
            right: -15,
            child: Icon(
              Icons.terrain_rounded,
              size: 110,
              color: AppColors.forestDeep.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.forestDeep, AppColors.forest],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.hiking_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trek Completed! 🎉',
                          style: AppType.style(
                            12.sp,
                            w: FontWeight.w800,
                            color: AppColors.inkStrong,
                          ),
                        ),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.style(
                            9.sp,
                            w: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _close,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF64748B),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 16),
              Text(
                'How was your experience?',
                style: AppType.style(
                  9.sp,
                  w: FontWeight.w600,
                  color: AppColors.inkStrong,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => _goRate((i + 1).toDouble()),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Icon(
                            Icons.star_rounded,
                            color: const Color(
                              0xFFFFB800,
                            ).withValues(alpha: 0.4),
                            size: 26,
                          ),
                        ),
                      );
                    }),
                  ),
                  GestureDetector(
                    onTap: () => _goRate(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.inkStrong,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Rate Now',
                            style: AppType.style(
                              9.sp,
                              w: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
