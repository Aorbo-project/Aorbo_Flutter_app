import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../freezed_models/booking/booking_history_model.dart';
import '../utils/ist_date_utils.dart';
import '../utils/shared_preferences.dart';

class RateTrekPopup {
  RateTrekPopup._();

  static const String _prefPrefix = 'rate_popup_shown_';

  /// Prevents two triggers in the same session racing each other and
  /// stacking two popups.
  static bool _visibleThisSession = false;
  static OverlayEntry? _overlayEntry;

  /// Bulletproof check: sometimes freezed parsing of `ratingGiven`
  /// (which comes as `true` or `"true"`) fails. We check both flag and value.
  static bool isRated(BookingHistoryData? b) {
    if (b == null) return false;
    return b.ratingGiven == true || (b.ratingValue ?? 0.0) > 0.0;
  }

  /// Safely extracts the numeric rating value.
  static double ratingValueOf(BookingHistoryData? b) {
    return (b?.ratingValue ?? 0.0).toDouble();
  }

  /// Clears the 24h persistence flag for a booking so the popup can be
  /// tested again immediately. Call this temporarily from anywhere in debug.
  static Future<void> debugClearShownFlag(dynamic bookingId) async {
    if (bookingId == null) return;
    final pref = await SpUtil.getInstance();
    await pref.remove('$_prefPrefix$bookingId');
  }

  /// Most recently completed, UNRATED, non-cancelled booking.
  /// Returns null if nothing qualifies.
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

      // Bulletproof check: if either flag is true, it's rated.
      final bool isRated =
          b.ratingGiven == true || (b.ratingValue ?? 0.0) > 0.0;
      if (isRated) continue; // already rated → never show

      final end = ISTDateUtils.toIST(b.batch?.endDate);

      final bool isCompletedStatus =
          trekStatus == 'completed' || status == 'completed';
      final bool isCompletedByDate = end != null && now.isAfter(end);

      if (!isCompletedStatus && !isCompletedByDate) continue;

      // If the backend explicitly says it's completed, we trust it and
      // bypass the date window check (fixes issues where backend dates
      // are in the future relative to the device clock).
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

  /// Checks eligibility + 24h persistence, then shows the side popup.
  /// Safe to call on every app open — it self-guards.
  static Future<void> maybeShow(
    BuildContext context,
    List<BookingHistoryData> bookings,
  ) async {
    if (_visibleThisSession) {
      debugPrint('[RateTrekPopup] skipped — already visible this session');
      return;
    }

    final booking = findEligibleBooking(bookings);
    if (booking == null || booking.id == null) {
      debugPrint('[RateTrekPopup] skipped — no eligible booking found');
      return;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ⚠️ TESTING MODE: 24h guard disabled. Re-enable this block later!
    // ─────────────────────────────────────────────────────────────────────────
    // final pref = await SpUtil.getInstance();
    // final key = '$_prefPrefix${booking.id}';
    // final lastShownStr = pref.getString(key) ?? '';
    // if (lastShownStr.isNotEmpty) {
    //   final lastShown = DateTime.tryParse(lastShownStr);
    //   if (lastShown != null &&
    //       DateTime.now().difference(lastShown) < const Duration(hours: 24)) {
    //     debugPrint('[RateTrekPopup] skipped — shown recently (24h guard)');
    //     return; // shown recently — don't nag again this soon
    //   }
    // }

    if (!context.mounted) return;

    _visibleThisSession = true;

    // Persist BEFORE showing so a crash/kill mid-dialog can't cause an
    // instant re-nag loop. (Also disabled for testing)
    // await pref.putString(key, DateTime.now().toIso8601String());

    if (!context.mounted) {
      _visibleThisSession = false;
      return;
    }

    // Show the non-blocking overlay
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

// ─────────────────────────────────────────────────────────────────────────
//  SIDE POPUP WIDGET (Non-blocking overlay)
// ─────────────────────────────────────────────────────────────────────────
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

    // Slides in from the right side
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
      top: 520,
      right: 12,
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
      width: 82.w, // Side popup width
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4332).withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(-4, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Background Trek Graphic ──
          Positioned(
            bottom: -25,
            right: -15,
            child: Icon(
              Icons.terrain_rounded,
              size: 110,
              color: const Color(0xFF1B4332).withValues(alpha: 0.05),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header Row ──
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
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
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
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
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),

              // ── Rating Row ──
              Text(
                'How was your experience?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
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
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Rate Now',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
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
