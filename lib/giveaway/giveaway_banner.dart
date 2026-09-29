import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../utils/screen_constants.dart';
import 'giveaway_api.dart';

/// Dashboard slot for the giveaway: loads the featured round from the backend
/// and shows [GiveawayBanner] for it — nothing when no round is running.
/// Mounted only while GiveawayConfig.enabled.
class GiveawayBannerSlot extends StatefulWidget {
  const GiveawayBannerSlot({super.key});

  // One fetch shared across dashboard rebuilds, refreshed after 5 minutes.
  static Future<GiveawayRoundSummary?>? _cached;
  static DateTime? _cachedAt;

  static Future<GiveawayRoundSummary?> _load() {
    final fresh = _cachedAt != null && DateTime.now().difference(_cachedAt!) < const Duration(minutes: 5);
    if (_cached == null || !fresh) {
      _cachedAt = DateTime.now();
      _cached = GiveawayApi.instance.currentRound().catchError((Object _) {
        _cachedAt = null; // retry on the next build
        return null;
      });
    }
    return _cached!;
  }

  @override
  State<GiveawayBannerSlot> createState() => _GiveawayBannerSlotState();
}

class _GiveawayBannerSlotState extends State<GiveawayBannerSlot> {
  late final Future<GiveawayRoundSummary?> _round = GiveawayBannerSlot._load();

  static const _visiblePhases = {'upcoming', 'open', 'closed', 'drawing', 'drawn'};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GiveawayRoundSummary?>(
      future: _round,
      builder: (context, snap) {
        final round = snap.data;
        if (round == null || !_visiblePhases.contains(round.phase)) return const SizedBox.shrink();
        return GiveawayBanner(
          roundLabel: round.label.toUpperCase(),
          drawLabel: round.drawLabel,
          ctaLabel: round.phase == 'drawn' ? 'See the result' : 'Take part',
        );
      },
    );
  }
}

/// Dashboard entry point to the Aorbo Trek Giveaway. One wording for
/// everyone, since new users enter and existing users invite (the page itself
/// shows the right view).
class GiveawayBanner extends StatelessWidget {
  const GiveawayBanner({
    super.key,
    this.roundLabel = 'ROUND 1',
    this.drawLabel = 'Draw on 31 Mar, 7 PM',
    this.ctaLabel = 'Take part',
  });

  final String roundLabel;
  final String drawLabel;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: ScreenConstant.size17,
        right: ScreenConstant.size17,
        top: ScreenConstant.size10,
      ),
      child: Semantics(
        button: true,
        label: 'Aorbo Trek Giveaway. Win a trek worth up to 10,000 rupees. $drawLabel.',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Get.toNamed('/giveaway'),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Ink(
              decoration: BoxDecoration(
                gradient: AppGradients.cta,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.card(),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      bottom: 0,
                      width: 46.w,
                      height: 9.h,
                      child: const CustomPaint(painter: _RidgePainter()),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _copy()),
                          SizedBox(width: 3.w),
                          _badge(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _copy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            'GIVEAWAY · $roundLabel',
            textScaler: const TextScaler.linear(1.0),
            style: AppType.style(
              FontSize.s8,
              w: FontWeight.w700,
              color: AppColors.brandYellow,
              letterSpacing: 0.8,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Win a trek worth up to ₹10,000',
          textScaler: const TextScaler.linear(1.0),
          style: AppType.style(FontSize.s14, w: FontWeight.w700, color: Colors.white, height: 1.25),
        ),
        SizedBox(height: 0.6.h),
        Text(
          'New to Aorbo? Enter free. Already here? Invite friends to win.',
          textScaler: const TextScaler.linear(1.0),
          style: AppType.style(
            FontSize.s9,
            color: Colors.white.withValues(alpha: 0.82),
            height: 1.45,
          ),
        ),
        SizedBox(height: 1.6.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.9.h),
              decoration: BoxDecoration(
                color: AppColors.brandYellow,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ctaLabel,
                    textScaler: const TextScaler.linear(1.0),
                    style: AppType.style(FontSize.s10, w: FontWeight.w700, color: AppColors.inkStrong),
                  ),
                  SizedBox(width: 1.w),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.inkStrong),
                ],
              ),
            ),
            SizedBox(width: 3.w),
            Flexible(
              child: Text(
                drawLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: const TextScaler.linear(1.0),
                style: AppType.style(
                  FontSize.s8,
                  w: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _badge() {
    return Container(
      width: 14.w,
      height: 14.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.brandYellow.withValues(alpha: 0.55), width: 1.2),
      ),
      child: Icon(Icons.landscape_rounded, color: AppColors.brandYellow, size: 7.w),
    );
  }
}

/// Faint mountain ridge along the bottom-right of the banner.
class _RidgePainter extends CustomPainter {
  const _RidgePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final back = Path()
      ..moveTo(0, h)
      ..lineTo(w * 0.18, h * 0.55)
      ..lineTo(w * 0.30, h * 0.72)
      ..lineTo(w * 0.52, h * 0.18)
      ..lineTo(w * 0.66, h * 0.46)
      ..lineTo(w * 0.80, h * 0.30)
      ..lineTo(w, h * 0.62)
      ..lineTo(w, h)
      ..close();
    final front = Path()
      ..moveTo(w * 0.22, h)
      ..lineTo(w * 0.44, h * 0.62)
      ..lineTo(w * 0.58, h * 0.80)
      ..lineTo(w * 0.78, h * 0.50)
      ..lineTo(w, h * 0.82)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(back, Paint()..color = Colors.white.withValues(alpha: 0.06));
    canvas.drawPath(front, Paint()..color = Colors.white.withValues(alpha: 0.08));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
