import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

Color _hex(dynamic v, Color fallback) {
  if (v == null) return fallback;
  var h = v.toString().replaceAll('#', '');
  if (h.length == 6) h = 'FF$h';
  final n = int.tryParse(h, radix: 16);
  return n == null ? fallback : Color(n);
}

List<Color> _hexList(dynamic v, List<Color> fallback) {
  if (v is! List || v.isEmpty) return fallback;
  return v.map((e) => _hex(e, Colors.white)).toList();
}

double _d(dynamic v, double fallback) => v is num ? v.toDouble() : fallback;

/// One visual layer. Order in the list = paint order (first is furthest back).
class SceneLayer {
  final String type; // sky | celestial | mountains | clouds | fog |
  // particles | fireworks | lightning | birds |
  // aurora | scrim
  final String variant; // celestial: sun|moon
  // particles: snow|rain|leaves|petals|sparkle|embers
  final List<Color> colors;
  final List<Color> colorsB; // sky only: second gradient to breathe toward
  final double opacity;
  final double speed; // generic multiplier, 1.0 = default
  final int count;
  final double x, y, size; // fractional placement (celestial)
  final double
  interval; // seconds (fireworks cadence, lightning windows, sky cycle)
  final int seed;

  const SceneLayer({
    required this.type,
    this.variant = '',
    this.colors = const [Colors.white],
    this.colorsB = const [],
    this.opacity = 1.0,
    this.speed = 1.0,
    this.count = 20,
    this.x = 0.8,
    this.y = 0.2,
    this.size = 0.12,
    this.interval = 6,
    this.seed = 7,
  });

  factory SceneLayer.fromJson(Map<String, dynamic> j) => SceneLayer(
    type: j['type']?.toString() ?? 'particles',
    variant: j['variant']?.toString() ?? '',
    colors: _hexList(j['colors'], const [Colors.white]),
    colorsB: _hexList(j['colorsB'], const []),
    opacity: _d(j['opacity'], 1.0).clamp(0.0, 1.0),
    speed: _d(j['speed'], 1.0).clamp(0.0, 5.0),
    count: _d(j['count'], 20).toInt().clamp(0, 60), // hard perf cap
    x: _d(j['x'], 0.8),
    y: _d(j['y'], 0.2),
    size: _d(j['size'], 0.12),
    interval: _d(j['interval'], 6).clamp(1.0, 60.0),
    seed: _d(j['seed'], 7).toInt(),
  );
}

class HeaderSceneSpec {
  final List<SceneLayer> layers;
  const HeaderSceneSpec(this.layers);

  factory HeaderSceneSpec.fromJson(dynamic list) {
    if (list is! List) return const HeaderSceneSpec([]);
    try {
      return HeaderSceneSpec(
        list
            .whereType<Map<String, dynamic>>()
            .map(SceneLayer.fromJson)
            .toList(),
      );
    } catch (_) {
      return const HeaderSceneSpec([]); // malformed payload → static header
    }
  }
}

/// The full animated background. One controller, one painter, seamless
/// 60-second loop. Renders a static frame when the OS asks for reduced
/// motion. Put the header content in a Stack on top of this.
class HeaderSceneBackground extends StatefulWidget {
  final HeaderSceneSpec scene;
  const HeaderSceneBackground({super.key, required this.scene});

  @override
  State<HeaderSceneBackground> createState() => _HeaderSceneBackgroundState();
}

class _HeaderSceneBackgroundState extends State<HeaderSceneBackground>
    with SingleTickerProviderStateMixin {
  static const double _loopSeconds = 60;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 60),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) {
      _c.stop();
      _c.value = 0;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scene.layers.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => CustomPaint(
            painter: _ScenePainter(
              layers: widget.scene.layers,
              time: _c.value * _loopSeconds, // absolute seconds within loop
              t01: _c.value, // 0..1, for seamless cycles
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  final List<SceneLayer> layers;
  final double time; // seconds, 0..60
  final double t01; // 0..1

  _ScenePainter({required this.layers, required this.time, required this.t01});

  @override
  void paint(Canvas canvas, Size s) {
    canvas.clipRect(Offset.zero & s);
    for (final l in layers) {
      switch (l.type) {
        case 'sky':
          _sky(canvas, s, l);
          break;
        case 'celestial':
          _celestial(canvas, s, l);
          break;
        case 'mountains':
          _mountains(canvas, s, l);
          break;
        case 'clouds':
          _clouds(canvas, s, l);
          break;
        case 'fog':
          _fog(canvas, s, l);
          break;
        case 'particles':
          _particles(canvas, s, l);
          break;
        case 'fireworks':
          _fireworks(canvas, s, l);
          break;
        case 'lightning':
          _lightning(canvas, s, l);
          break;
        case 'birds':
          _birds(canvas, s, l);
          break;
        case 'aurora':
          _aurora(canvas, s, l);
          break;
        case 'scrim':
          _scrim(canvas, s, l);
          break;
        // Unknown types are skipped → old clients degrade gracefully.
      }
    }
  }

  // ── Sky: gradient that slowly breathes between two palettes ─────────────
  void _sky(Canvas c, Size s, SceneLayer l) {
    final b = l.colorsB.isEmpty ? l.colors : l.colorsB;
    // Integer number of breath cycles per loop → seamless wrap.
    final cycles = (60 / l.interval).round().clamp(1, 30);
    final k = 0.5 - 0.5 * math.cos(t01 * 2 * math.pi * cycles);
    final cols = List<Color>.generate(
      l.colors.length,
      (i) => Color.lerp(l.colors[i], b[i % b.length], k)!,
    );

    if (cols.length == 1) {
      c.drawRect(Offset.zero & s, Paint()..color = cols.first);
      return;
    }

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(s.width / 2, 0),
        Offset(s.width / 2, s.height),
        cols,
        List.generate(cols.length, (i) => i / (cols.length - 1)),
      );
    c.drawRect(Offset.zero & s, paint);
  }

  // ── Sun / moon with pulsing glow ─────────────────────────────────────────
  void _celestial(Canvas c, Size s, SceneLayer l) {
    final center = Offset(l.x * s.width, l.y * s.height);
    final r = l.size * s.width;
    final pulse = 1 + 0.05 * math.sin(t01 * 2 * math.pi * 6);
    final col = l.colors.first;

    final glow = Paint()
      ..shader = ui.Gradient.radial(center, r * 2.8 * pulse, [
        col.withValues(alpha: 0.45 * l.opacity),
        col.withValues(alpha: 0.0),
      ]);
    c.drawCircle(center, r * 2.8 * pulse, glow);

    if (l.variant == 'moon') {
      c.saveLayer(Offset.zero & s, Paint());
      c.drawCircle(
        center,
        r,
        Paint()..color = col.withValues(alpha: l.opacity),
      );
      c.drawCircle(
        center.translate(r * 0.42, -r * 0.18),
        r * 0.92,
        Paint()..blendMode = BlendMode.clear,
      );
      c.restore();
    } else {
      c.drawCircle(
        center,
        r * pulse,
        Paint()..color = col.withValues(alpha: l.opacity),
      );
    }
  }

  // ── Parallax mountain ridges (one ridge per color, back → front) ────────
  void _mountains(Canvas c, Size s, SceneLayer l) {
    for (var r = 0; r < l.colors.length; r++) {
      final amp = s.height * (0.06 + 0.045 * r);
      final base = s.height * (0.58 + 0.13 * r);
      // Nearer ridges drift more; integer cycles keep the loop seamless.
      final phase = t01 * (r + 1) * l.speed;
      final f1 = 2.0 + r, f2 = 5.0 + r;

      final path = Path()..moveTo(0, s.height);
      const steps = 28;
      for (var i = 0; i <= steps; i++) {
        final xf = i / steps;
        final y =
            base -
            amp *
                (0.62 * math.sin(2 * math.pi * (xf * f1 + phase)) +
                    0.38 * math.sin(2 * math.pi * (xf * f2 + phase * 1.7 + r)));
        path.lineTo(xf * s.width, y);
      }
      path
        ..lineTo(s.width, s.height)
        ..close();

      final depth = l.colors.length == 1
          ? 1.0
          : 0.5 + 0.5 * r / (l.colors.length - 1);
      c.drawPath(
        path,
        Paint()..color = l.colors[r].withValues(alpha: l.opacity * depth),
      );
    }
  }

  // ── Drifting clouds ──────────────────────────────────────────────────────
  void _clouds(Canvas c, Size s, SceneLayer l) {
    final rnd = math.Random(l.seed);
    for (var i = 0; i < l.count; i++) {
      final bx = rnd.nextDouble();
      final yy = (0.06 + rnd.nextDouble() * 0.30) * s.height;
      final scale = 0.5 + rnd.nextDouble() * 0.9;
      final cycles = 1 + rnd.nextInt(2); // integer → seamless
      final xf = (bx + t01 * cycles * l.speed) % 1.0;
      final xx = xf * (s.width * 1.3) - s.width * 0.15;
      final p = Paint()
        ..color = l.colors.first.withValues(
          alpha: l.opacity * (0.35 + 0.35 * rnd.nextDouble()),
        );
      final w = 60.0 * scale, h = 18.0 * scale;
      c.drawOval(
        Rect.fromCenter(center: Offset(xx, yy), width: w, height: h),
        p,
      );
      c.drawOval(
        Rect.fromCenter(
          center: Offset(xx - w * 0.3, yy + h * 0.2),
          width: w * 0.7,
          height: h * 0.8,
        ),
        p,
      );
      c.drawOval(
        Rect.fromCenter(
          center: Offset(xx + w * 0.3, yy + h * 0.15),
          width: w * 0.6,
          height: h * 0.75,
        ),
        p,
      );
    }
  }

  // ── Low fog / mist near the bottom ──────────────────────────────────────
  void _fog(Canvas c, Size s, SceneLayer l) {
    final rnd = math.Random(l.seed + 3);
    final blur = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    for (var i = 0; i < math.max(3, l.count ~/ 4); i++) {
      final bx = rnd.nextDouble();
      final cycles = 1 + rnd.nextInt(2);
      final dir = rnd.nextBool() ? 1 : -1;
      final xf = (bx + dir * t01 * cycles * l.speed * 0.4) % 1.0;
      final xx = ((xf + 1) % 1.0) * s.width;
      final yy = s.height * (0.82 + rnd.nextDouble() * 0.12);
      blur.color = l.colors.first.withValues(
        alpha: l.opacity * (0.10 + 0.10 * rnd.nextDouble()),
      );
      c.drawOval(
        Rect.fromCenter(
          center: Offset(xx, yy),
          width: s.width * 0.5,
          height: 34,
        ),
        blur,
      );
    }
  }

  // ── Weather / ambient particles ──────────────────────────────────────────
  void _particles(Canvas c, Size s, SceneLayer l) {
    final rnd = math.Random(l.seed + 11);
    final p = Paint();
    for (var i = 0; i < l.count; i++) {
      final bx = rnd.nextDouble(), by = rnd.nextDouble();
      final sz = 1.5 + rnd.nextDouble() * 3.0;
      final phase = rnd.nextDouble() * 2 * math.pi;
      final cycles = 1 + rnd.nextInt(3); // integer → seamless loop
      final col = l.colors[i % l.colors.length];

      switch (l.variant) {
        case 'snow':
          final yf = (by + t01 * cycles * l.speed) % 1.0;
          final xf =
              (bx + 0.03 * math.sin(t01 * 2 * math.pi * 2 + phase)) % 1.0;
          p.color = col.withValues(alpha: 0.55 * l.opacity);
          c.drawCircle(Offset(xf * s.width, yf * s.height), sz, p);
          break;

        case 'rain':
          final yf = (by + t01 * cycles * 4 * l.speed) % 1.0;
          p
            ..color = col.withValues(alpha: 0.35 * l.opacity)
            ..strokeWidth = 1.3
            ..strokeCap = StrokeCap.round;
          final o = Offset(bx * s.width, yf * s.height);
          c.drawLine(o, o.translate(-2.5, sz * 3.2), p);
          break;

        case 'leaves':
        case 'petals':
          final yf = (by + t01 * cycles * l.speed * 0.8) % 1.0;
          final xf =
              (bx + 0.06 * math.sin(t01 * 2 * math.pi * 2 + phase)) % 1.0;
          p.color = col.withValues(alpha: 0.45 * l.opacity);
          c.save();
          c.translate(xf * s.width, yf * s.height);
          c.rotate(t01 * 2 * math.pi * cycles + phase);
          c.drawOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: sz * 2.6,
              height: sz * 1.3,
            ),
            p,
          );
          c.restore();
          break;

        case 'embers': // rise from the bottom — great for Diwali
          final yf = 1.0 - ((by + t01 * cycles * l.speed) % 1.0);
          final fade = yf; // brighter near the bottom
          p.color = col.withValues(alpha: (0.15 + 0.5 * fade) * l.opacity);
          final xf =
              (bx + 0.02 * math.sin(t01 * 2 * math.pi * 3 + phase)) % 1.0;
          c.drawCircle(
            Offset(xf * s.width, yf * s.height),
            sz * (0.5 + 0.5 * fade),
            p,
          );
          break;

        default: // sparkle
          final tw =
              0.5 + 0.5 * math.sin(t01 * 2 * math.pi * (3 + i % 3) + phase);
          p.color = col.withValues(alpha: (0.12 + 0.5 * tw) * l.opacity);
          c.drawCircle(
            Offset(bx * s.width, by * s.height * 0.9),
            sz * (0.5 + 0.5 * tw),
            p,
          );
      }
    }
  }

  // ── Fireworks: seeded bursts on a fixed cadence ──────────────────────────
  void _fireworks(Canvas c, Size s, SceneLayer l) {
    const life = 1.6; // seconds per burst
    final idxNow = (time / l.interval).floor();
    for (final idx in [idxNow - 1, idxNow]) {
      if (idx < 0) continue;
      final prog = (time - idx * l.interval) / life;
      if (prog < 0 || prog > 1) continue;

      final rnd = math.Random(l.seed + idx * 131);
      final center = Offset(
        (0.15 + 0.7 * rnd.nextDouble()) * s.width,
        (0.10 + 0.30 * rnd.nextDouble()) * s.height,
      );
      final col = l.colors[rnd.nextInt(l.colors.length)];
      final maxR = s.width * (0.08 + 0.06 * rnd.nextDouble());
      final ease = 1 - math.pow(1 - prog, 3).toDouble();
      final alpha = (1 - prog) * l.opacity;
      final p = Paint()..color = col.withValues(alpha: alpha);

      for (var k = 0; k < 18; k++) {
        final a = k / 18 * 2 * math.pi + rnd.nextDouble() * 0.2;
        final dist = maxR * ease;
        final droop = 14 * prog * prog; // gravity
        c.drawCircle(
          center.translate(math.cos(a) * dist, math.sin(a) * dist + droop),
          1.8 * (1 - prog * 0.6),
          p,
        );
      }
      if (prog < 0.25) {
        c.drawCircle(
          center,
          5 * (1 - prog / 0.25),
          Paint()
            ..color = Colors.white.withValues(
              alpha: 0.8 * (1 - prog / 0.25) * l.opacity,
            ),
        );
      }
    }
  }

  // ── Lightning: rare flash + jagged bolt (monsoon) ────────────────────────
  void _lightning(Canvas c, Size s, SceneLayer l) {
    final wIdx = (time / l.interval).floor();
    final rnd = math.Random(l.seed + wIdx * 977);
    if (rnd.nextDouble() > 0.55) return; // not every window flashes
    final flashAt = wIdx * l.interval + rnd.nextDouble() * (l.interval - 0.6);
    final dt = time - flashAt;
    if (dt < 0 || dt > 0.4) return;
    final k = math.pow(1 - dt / 0.4, 2).toDouble();

    c.drawRect(
      Offset.zero & s,
      Paint()..color = Colors.white.withValues(alpha: 0.14 * k * l.opacity),
    );
    if (dt < 0.18) {
      final bolt = Path();
      var x = (0.2 + 0.6 * rnd.nextDouble()) * s.width;
      var y = 0.0;
      bolt.moveTo(x, y);
      while (y < s.height * 0.55) {
        x += (rnd.nextDouble() - 0.5) * 26;
        y += 14 + rnd.nextDouble() * 16;
        bolt.lineTo(x, y);
      }
      c.drawPath(
        bolt,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = l.colors.first.withValues(alpha: 0.85 * k * l.opacity),
      );
    }
  }

  // ── Birds gliding across ─────────────────────────────────────────────────
  void _birds(Canvas c, Size s, SceneLayer l) {
    final rnd = math.Random(l.seed + 29);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = l.colors.first.withValues(alpha: 0.55 * l.opacity);
    final n = l.count.clamp(1, 6);
    for (var i = 0; i < n; i++) {
      final off = rnd.nextDouble();
      final prog = (t01 * l.speed + off) % 1.0;
      final x = prog * (s.width + 60) - 30;
      final y =
          (0.12 + rnd.nextDouble() * 0.22) * s.height +
          5 * math.sin(t01 * 2 * math.pi * 3 + off * 9);
      final flap = math.sin(t01 * 2 * math.pi * (14 + i * 2)) * 3.5;
      c.drawLine(Offset(x, y), Offset(x - 7, y - 3 + flap), p);
      c.drawLine(Offset(x, y), Offset(x + 7, y - 3 + flap), p);
    }
  }

  // ── Aurora bands (winter) ────────────────────────────────────────────────
  void _aurora(Canvas c, Size s, SceneLayer l) {
    final bands = l.colors.length.clamp(1, 3);
    for (var b = 0; b < bands; b++) {
      final top = s.height * (0.04 + 0.10 * b);
      final band = Path()..moveTo(0, top);
      const steps = 20;
      for (var i = 0; i <= steps; i++) {
        final xf = i / steps;
        final wig =
            14 * math.sin(2 * math.pi * (xf * 2 + t01 * (b + 1) + b * 0.4));
        band.lineTo(xf * s.width, top + wig);
      }
      for (var i = steps; i >= 0; i--) {
        final xf = i / steps;
        final wig =
            14 * math.sin(2 * math.pi * (xf * 2 + t01 * (b + 1) + b * 0.7));
        band.lineTo(xf * s.width, top + s.height * 0.16 + wig);
      }
      band.close();
      c.drawPath(
        band,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
          ..shader = ui.Gradient.linear(
            Offset(0, top),
            Offset(0, top + s.height * 0.2),
            [
              l.colors[b].withValues(alpha: 0.22 * l.opacity),
              l.colors[b].withValues(alpha: 0.0),
            ],
          ),
      );
    }
  }

  // ── Readability scrim: keeps cards/text legible over busy scenes ────────
  void _scrim(Canvas c, Size s, SceneLayer l) {
    c.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(s.width / 2, 0),
          Offset(s.width / 2, s.height),
          [
            l.colors.first.withValues(alpha: 0.0),
            l.colors.first.withValues(alpha: l.opacity),
          ],
          [0.35, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(_ScenePainter old) => true;
}
