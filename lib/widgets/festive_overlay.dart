import 'dart:math';
import 'package:flutter/material.dart';

/// Purely decorative festive particle overlay — confined to a fixed height,
/// wrapped in IgnorePointer so it never intercepts taps meant for the real
/// UI underneath (search fields, buttons, etc). Swap `type` to preview
/// different festival looks; swap for a real Lottie asset later once the
/// placement/behavior is approved.
enum FestiveOverlayType { none, diwali, christmas }

class FestiveOverlay extends StatefulWidget {
  final FestiveOverlayType type;
  final double height;
  final int particleCount;

  const FestiveOverlay({
    super.key,
    required this.type,
    required this.height,
    this.particleCount = 22,
  });

  @override
  State<FestiveOverlay> createState() => _FestiveOverlayState();
}

class _FestiveOverlayState extends State<FestiveOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_Particle> _particles;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _particles = List.generate(widget.particleCount, (_) => _makeParticle());
  }

  _Particle _makeParticle() {
    final isDiwali = widget.type == FestiveOverlayType.diwali;
    final palette = isDiwali
        ? const [Color(0xFFFFD54A), Color(0xFFFF9E2C), Color(0xFFFF6F3C)]
        : const [Color(0xFFFFFFFF), Color(0xFFE3F2FD), Color(0xFFBBDEFB)];
    return _Particle(
      x: _rand.nextDouble(),
      startDelay: _rand.nextDouble(),
      speed: 0.6 + _rand.nextDouble() * 0.8,
      size: isDiwali ? 4 + _rand.nextDouble() * 4 : 3 + _rand.nextDouble() * 3,
      drift: (_rand.nextDouble() - 0.5) * 0.15,
      color: palette[_rand.nextInt(palette.length)],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == FestiveOverlayType.none) return const SizedBox.shrink();

    return IgnorePointer(
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _FestivePainter(
                  particles: _particles,
                  progress: _controller.value,
                  type: widget.type,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Particle {
  final double x; // 0..1 horizontal position
  final double startDelay; // 0..1 offset into the loop
  final double speed; // relative fall speed
  final double size;
  final double drift; // horizontal sway amount
  final Color color;

  _Particle({
    required this.x,
    required this.startDelay,
    required this.speed,
    required this.size,
    required this.drift,
    required this.color,
  });
}

class _FestivePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final FestiveOverlayType type;

  _FestivePainter({
    required this.particles,
    required this.progress,
    required this.type,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress * p.speed + p.startDelay) % 1.0;
      final dy = t * size.height;
      final sway = sin(t * 2 * pi * 2) * p.drift * size.width;
      final dx = (p.x * size.width) + sway;

      // Fade in near the top, fade out near the bottom of the band.
      final fade = (t < 0.15)
          ? t / 0.15
          : (t > 0.85)
              ? (1.0 - t) / 0.15
              : 1.0;

      final paint = Paint()..color = p.color.withValues(alpha: fade.clamp(0, 1) * 0.85);

      if (type == FestiveOverlayType.diwali) {
        // Small glowing flame-like dot with a soft halo.
        canvas.drawCircle(
          Offset(dx, dy),
          p.size * 1.8,
          Paint()..color = p.color.withValues(alpha: fade.clamp(0, 1) * 0.18),
        );
        canvas.drawCircle(Offset(dx, dy), p.size, paint);
      } else {
        // Simple falling snowflake dot.
        canvas.drawCircle(Offset(dx, dy), p.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FestivePainter oldDelegate) => true;
}
