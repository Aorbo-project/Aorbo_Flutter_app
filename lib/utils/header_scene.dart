import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Premium trekking / seasonal scene layer.
class SceneLayer {
  final String type;
  final String variant;
  final List<Color> colors;
  final List<Color> colorsB;
  final double opacity;
  final double speed;
  final int count;
  final double x, y, size;
  final double interval;
  final int seed;
  final double intensity;
  final double elevation;
  final String edge;

  const SceneLayer({
    required this.type,
    this.variant = '',
    this.colors = const [Colors.white],
    this.colorsB = const [],
    this.opacity = 1.0,
    this.speed = 1.0,
    this.count = 16,
    this.x = 0.8,
    this.y = 0.2,
    this.size = 0.12,
    this.interval = 6,
    this.seed = 7,
    this.intensity = 1.0,
    this.elevation = 1.0,
    this.edge = '',
  });

  factory SceneLayer.fromJson(Map<String, dynamic> j) => SceneLayer(
    type: j['type']?.toString() ?? 'particles',
    variant: j['variant']?.toString() ?? '',
    colors: _hexList(j['colors'], const [Colors.white]),
    colorsB: _hexList(j['colorsB'], const []),
    opacity: _d(j['opacity'], 1.0).clamp(0.0, 1.0),
    speed: _d(j['speed'], 1.0).clamp(0.0, 5.0),
    count: _d(j['count'], 16).toInt().clamp(0, 150),
    x: _d(j['x'], 0.8),
    y: _d(j['y'], 0.2),
    size: _d(j['size'], 0.12),
    interval: _d(j['interval'], 6).clamp(1.0, 60.0),
    seed: _d(j['seed'], 7).toInt(),
    intensity: _d(j['intensity'], 1.0).clamp(0.0, 2.0),
    elevation: _d(j['elevation'], 1.0).clamp(0.0, 3.0),
    edge: j['edge']?.toString() ?? '',
  );
}

double _d(dynamic v, double fallback) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? fallback;
}

List<Color> _hexList(dynamic v, List<Color> fallback) {
  if (v is! List || v.isEmpty) return fallback;
  return v.map((e) {
    var h = e.toString().replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.tryParse(h, radix: 16) ?? 0xFFFFFFFF);
  }).toList();
}

class HeaderSceneSpec {
  final List<SceneLayer> layers;
  const HeaderSceneSpec(this.layers);
  const HeaderSceneSpec.empty() : layers = const [];

  factory HeaderSceneSpec.fromJson(dynamic j) {
    try {
      if (j is List) {
        return HeaderSceneSpec(
          j
              .whereType<Map>()
              .map((m) => SceneLayer.fromJson(Map<String, dynamic>.from(m)))
              .toList(),
        );
      }
    } catch (_) {}
    return const HeaderSceneSpec([]);
  }
}

class HeaderSceneBackground extends StatefulWidget {
  final HeaderSceneSpec scene;
  const HeaderSceneBackground({super.key, required this.scene});

  @override
  State<HeaderSceneBackground> createState() => _HeaderSceneBackgroundState();
}

class _HeaderSceneBackgroundState extends State<HeaderSceneBackground>
    with SingleTickerProviderStateMixin {
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
            painter: _ScenePainter(layers: widget.scene.layers, t01: _c.value),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _Noise {
  static double _fade(double t) => t * t * t * (t * (t * 6 - 15) + 10);
  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  static double _grad(int h, double x, double y) {
    switch (h & 3) {
      case 0:
        return x + y;
      case 1:
        return -x + y;
      case 2:
        return x - y;
      default:
        return -x - y;
    }
  }

  static double v(double x, double y, int seed) {
    final X = x.floor() & 255;
    final Y = y.floor() & 255;
    final xf = x - x.floor();
    final yf = y - y.floor();
    final u = _fade(xf);
    final vv = _fade(yf);

    int h(int a, int b) =>
        ((a * 374761393 + b * 668265263 + seed * 1013) ^ (a * 1274126177)) &
        255;

    final aa = h(X, Y);
    final ab = h(X, Y + 1);
    final ba = h(X + 1, Y);
    final bb = h(X + 1, Y + 1);

    final x1 = _lerp(_grad(aa, xf, yf), _grad(ba, xf - 1, yf), u);
    final x2 = _lerp(_grad(ab, xf, yf - 1), _grad(bb, xf - 1, yf - 1), u);
    return _lerp(x1, x2, vv);
  }

  static double fbm(double x, double y, int seed, {int octaves = 3}) {
    var total = 0.0;
    var freq = 1.0;
    var amp = 1.0;
    var max = 0.0;
    for (var i = 0; i < octaves; i++) {
      total += v(x * freq, y * freq, seed + i * 31) * amp;
      max += amp;
      amp *= 0.5;
      freq *= 2.0;
    }
    return total / max;
  }
}

class _ScenePainter extends CustomPainter {
  final List<SceneLayer> layers;
  final double t01;

  _ScenePainter({required this.layers, required this.t01});

  int _cycles(double speed, double multiplier, int min, int max) {
    return (speed * multiplier).round().clamp(min, max).toInt();
  }

  @override
  void paint(Canvas canvas, Size s) {
    canvas.clipRect(Offset.zero & s);

    for (final l in layers) {
      try {
        switch (l.type) {
          case 'sky':
            _sky(canvas, s, l);
            break;
          case 'celestial':
            _celestial(canvas, s, l);
            break;
          case 'aurora':
            _aurora(canvas, s, l);
            break;
          case 'clouds':
            _clouds(canvas, s, l);
            break;
          case 'mountains':
          case 'hills':
            _mountains(canvas, s, l);
            break;
          case 'sea':
            _sea(canvas, s, l);
            break;
          case 'waterfall':
            _waterfall(canvas, s, l);
            break;
          case 'particles':
            _particles(canvas, s, l);
            break;
          case 'fog':
            _fog(canvas, s, l);
            break;
          case 'trees':
            _trees(canvas, s, l);
            break;
          case 'igloo':
            _igloo(canvas, s, l);
            break;
          case 'campfire':
            _campfire(canvas, s, l);
            break;
          case 'ground':
          case 'foreground':
            _ground(canvas, s, l);
            break;
          case 'birds':
            _birds(canvas, s, l);
            break;
          case 'frame':
            _frame(canvas, s, l);
            break;
          case 'shimmer':
            _shimmer(canvas, s, l);
            break;
          case 'scrim':
            _scrim(canvas, s, l);
            break;
          case 'lightning':
            _lightning(canvas, s, l);
            break;
          case 'rays':
            _rays(canvas, s, l);
            break;
          case 'boat':
            _boat(canvas, s, l);
            break;
        }
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('HeaderScene: layer "${l.type}" failed to paint: $e');
          debugPrintStack(stackTrace: st);
        }
      }
    }
  }

  void _sky(Canvas c, Size s, SceneLayer l) {
    final phase = (l.seed * 0.137) % 1.0;
    final t = (t01 + phase) % 1.0;

    final b = l.colorsB.isEmpty ? l.colors : l.colorsB;
    final cycles = (60 / l.interval).round().clamp(1, 30).toInt();
    final k = 0.5 - 0.5 * math.cos(t * 2 * math.pi * cycles);
    final cols = List<Color>.generate(
      l.colors.length,
      (i) => Color.lerp(l.colors[i], b[i % b.length], k)!,
    );

    if (cols.isEmpty) return;
    if (cols.length == 1) {
      c.drawRect(Offset.zero & s, Paint()..color = cols.first);
      return;
    }

    final stops = List.generate(cols.length, (i) => i / (cols.length - 1));
    c.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(s.width / 2, 0),
          Offset(s.width / 2, s.height),
          cols,
          stops,
        ),
    );

    c.drawRect(
      Rect.fromLTWH(0, s.height * 0.55, s.width, s.height * 0.45),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(s.width / 2, s.height * 0.55),
          Offset(s.width / 2, s.height),
          [Colors.transparent, Colors.white.withValues(alpha: 0.18)],
        ),
    );
  }

  void _celestial(Canvas c, Size s, SceneLayer l) {
    final center = Offset(l.x * s.width, l.y * s.height);
    final r = l.size * s.width;
    final pulse = 1 + 0.03 * math.sin(t01 * 2 * math.pi * 4);
    final col = l.colors.first;

    if (l.variant == 'sun' && l.intensity > 0.4) {
      final rayPaint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          r * 6,
          [
            col.withValues(alpha: 0.0),
            col.withValues(alpha: 0.10 * l.intensity),
            col.withValues(alpha: 0.0),
          ],
          [0.3, 0.6, 1.0],
        );

      c.save();
      c.translate(center.dx, center.dy);
      c.rotate(t01 * 0.3);
      for (var i = 0; i < 14; i++) {
        c.save();
        c.rotate(i / 14 * 2 * math.pi);
        c.drawRect(Rect.fromLTWH(-r * 0.2, 0, r * 0.4, r * 6), rayPaint);
        c.restore();
      }
      c.restore();
    }

    for (var i = 4; i >= 0; i--) {
      final haloR = r * (2.0 + i * 0.7) * pulse;
      c.drawCircle(
        center,
        haloR,
        Paint()
          ..shader = ui.Gradient.radial(center, haloR, [
            col.withValues(alpha: (0.18 - i * 0.03) * l.opacity),
            col.withValues(alpha: 0.0),
          ]),
      );
    }

    if (l.variant == 'moon') {
      c.saveLayer(Offset.zero & s, Paint());
      c.drawCircle(
        center,
        r,
        Paint()..color = col.withValues(alpha: l.opacity),
      );
      c.drawCircle(
        center.translate(r * 0.4, -r * 0.18),
        r * 0.9,
        Paint()..blendMode = BlendMode.clear,
      );
      c.restore();
    } else {
      c.drawCircle(
        center,
        r,
        Paint()..color = col.withValues(alpha: l.opacity),
      );
    }
  }

  void _aurora(Canvas c, Size s, SceneLayer l) {
    final cycles = _cycles(l.speed, 2, 1, 6);
    final time = t01 * 2 * math.pi * cycles;

    for (var layer = 0; layer < l.colors.length; layer++) {
      final path = Path();
      final baseY = s.height * (0.08 + layer * 0.08);
      final amp = s.height * 0.07 * (1 + 0.3 * math.sin(time + layer));

      path.moveTo(-10, baseY);
      for (var x = 0.0; x <= 1.0; x += 0.015) {
        final n = _Noise.fbm(x * 2 + layer * 0.3, layer.toDouble(), l.seed);
        final y =
            baseY +
            amp * (math.sin(x * 4 * math.pi + time * 0.5) * 0.7 + n * 0.5);
        path.lineTo(x * s.width, y);
      }
      path.lineTo(s.width + 10, baseY + amp * 2);
      path.lineTo(-10, baseY + amp * 2);
      path.close();

      c.drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, baseY - amp),
            Offset(0, baseY + amp * 2),
            [
              l.colors[layer].withValues(alpha: 0.0),
              l.colors[layer].withValues(alpha: 0.55 * l.opacity),
              l.colors[layer].withValues(alpha: 0.0),
            ],
            const [0.0, 0.5, 1.0],
          )
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 22),
      );
    }
  }

  void _clouds(Canvas c, Size s, SceneLayer l) {
    final rnd = math.Random(l.seed);
    final cycles = _cycles(l.speed, 2.5, 1, 10);

    for (var i = 0; i < l.count; i++) {
      final sx = rnd.nextDouble();
      final sy = rnd.nextDouble();
      final ss = rnd.nextDouble();
      final puffs = 4 + rnd.nextInt(3);

      final prog = (t01 * cycles + sx) % 1.0;
      final x = prog * (s.width * 1.4) - s.width * 0.2;
      final y = (0.05 + sy * 0.32) * s.height;
      final size = s.width * (0.05 + 0.09 * ss);
      final alpha = l.opacity * (0.45 + 0.4 * ss);

      for (var j = 0; j < puffs; j++) {
        final dx = (j - puffs / 2) * size * 0.32;
        final dy = (j.isEven ? 1 : -1) * size * 0.08;
        c.drawCircle(
          Offset(x + dx + 6, y + dy + 8),
          size * (0.22 + 0.12 * math.sin(j + sx * 5)).abs(),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.06 * l.opacity)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8),
        );
      }

      for (var j = 0; j < puffs; j++) {
        final dx = (j - puffs / 2) * size * 0.32;
        final dy = (j.isEven ? 1 : -1) * size * 0.08;
        final r = size * (0.22 + 0.14 * math.sin(j + sx * 5)).abs();
        c.drawCircle(
          Offset(x + dx, y + dy),
          r,
          Paint()
            ..shader = ui.Gradient.radial(Offset(x + dx, y + dy - r * 0.2), r, [
              l.colors.first.withValues(alpha: alpha),
              l.colors.first.withValues(alpha: alpha * 0.55),
            ])
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5),
        );
      }

      c.drawCircle(
        Offset(x - size * 0.15, y - size * 0.08),
        size * 0.18,
        Paint()
          ..color = Colors.white.withValues(alpha: alpha * 0.5)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  void _mountains(Canvas c, Size s, SceneLayer l) {
    final ridges = l.colors.length.clamp(1, 4);

    for (var r = 0; r < ridges; r++) {
      final depth = ridges == 1 ? 1.0 : 0.35 + 0.65 * (r / (ridges - 1));
      final amp = s.height * (0.055 + 0.05 * r) * depth;
      final base = s.height * (0.50 + 0.12 * r);
      final cycles = _cycles(l.speed * (r + 1), 1.5, 1, 8);
      final phase = t01 * cycles;
      final f1 = 1.35 + r * 0.35;
      final f2 = 2.8 + r * 0.6;
      final f3 = 5.1 + r * 0.9;

      final path = Path()..moveTo(-20, s.height + 20);
      const steps = 90;
      final ys = <double>[];

      for (var i = 0; i <= steps; i++) {
        final xf = i / steps;
        double y;
        if (l.variant == 'sharp') {
          y =
              base -
              amp *
                  (math.sin(2 * math.pi * (xf * f1 + phase)).abs() * 1.2 +
                      math.sin(2 * math.pi * (xf * f2 + phase * 1.4)) * 0.2);
        } else {
          y =
              base -
              amp *
                  (math.sin(2 * math.pi * (xf * f1 + phase)) * 0.62 +
                      math.sin(2 * math.pi * (xf * f2 + phase * 1.4)) * 0.24 +
                      math.sin(2 * math.pi * (xf * f3 + phase * 2.2)) * 0.10);
        }
        ys.add(y);
        path.lineTo(xf * s.width, y);
      }

      path
        ..lineTo(s.width + 20, s.height + 20)
        ..close();

      c.drawPath(
        path,
        Paint()
          ..shader =
              ui.Gradient.linear(Offset(0, base - amp), Offset(0, base + amp), [
                l.colors[r].withValues(alpha: l.opacity * depth),
                l.colors[r].withValues(alpha: l.opacity * depth * 0.62),
              ]),
      );

      if (l.variant == 'stratified') {
        final linePaint = Paint()
          ..color = l.colors[(r + 1) % l.colors.length].withValues(
            alpha: 0.4 * l.opacity,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;
        for (var j = 1; j < 6; j++) {
          final lineY = base - (j * (amp * 1.2 / 6));
          c.drawLine(
            Offset(-10, lineY),
            Offset(s.width + 10, lineY - j * 4),
            linePaint,
          );
        }
      }

      if (l.variant == 'snow' || l.variant == 'snowmountains') {
        final snowLine = base - amp * (0.22 + r * 0.08);

        // Collect each continuous stretch of ridge that pokes above the snow
        // line as its own polyline. Enter/exit points are interpolated to the
        // exact x where the ridge crosses `snowLine`, and each stretch stays a
        // separate sub-path — so the cap never draws a straight streak across
        // the valley between two peaks (old bug: `started` was never reset, so
        // every gap got bridged), and its ends sit cleanly on the line instead
        // of snapping to whichever 1/steps sample happened to be above.
        double crossX(int i) {
          final y0 = ys[i - 1];
          final y1 = ys[i];
          final d = y1 - y0;
          final f =
              d.abs() < 1e-6 ? 0.5 : ((snowLine - y0) / d).clamp(0.0, 1.0);
          return ((i - 1) + f) / steps * s.width;
        }

        final runs = <List<Offset>>[];
        List<Offset>? run;
        for (var i = 0; i <= steps; i++) {
          if (ys[i] < snowLine) {
            if (run == null) {
              run = <Offset>[];
              runs.add(run);
              if (i != 0) run.add(Offset(crossX(i), snowLine));
            }
            run.add(Offset(i / steps * s.width, ys[i]));
          } else if (run != null) {
            run.add(Offset(crossX(i), snowLine));
            run = null;
          }
        }
        if (run != null) run.add(Offset(s.width, ys[steps]));

        // Stitch the runs into one Path, smoothing each with quadratic béziers
        // through segment midpoints so the cap curves along the ridge instead
        // of showing straight facets between samples.
        final snow = Path();
        var hasLine = false;
        for (final pts in runs) {
          if (pts.length < 2) continue;
          hasLine = true;
          snow.moveTo(pts.first.dx, pts.first.dy);
          if (pts.length == 2) {
            snow.lineTo(pts[1].dx, pts[1].dy);
            continue;
          }
          for (var k = 1; k < pts.length - 1; k++) {
            final mx = (pts[k].dx + pts[k + 1].dx) / 2;
            final my = (pts[k].dy + pts[k + 1].dy) / 2;
            snow.quadraticBezierTo(pts[k].dx, pts[k].dy, mx, my);
          }
          snow.lineTo(pts.last.dx, pts.last.dy);
        }

        if (hasLine) {
          c.drawPath(
            snow,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.82 * l.opacity)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.8
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round,
          );

          c.drawPath(
            snow,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.22 * l.opacity)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 7
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5),
          );
        }
      }
    }
  }

  void _sea(Canvas c, Size s, SceneLayer l) {
    final topY = l.y * s.height;
    final seaH = s.height - topY;
    if (seaH <= 0) return;

    final colA = l.colors.first;
    final colB = l.colors.length > 1 ? l.colors[1] : colA;
    final foam = l.colors.length > 2 ? l.colors[2] : Colors.white;

    c.drawRect(
      Rect.fromLTWH(0, topY, s.width, seaH),
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, topY), Offset(0, s.height), [
          colA.withValues(alpha: l.opacity),
          colB.withValues(alpha: l.opacity),
        ]),
    );

    final cycles = _cycles(l.speed, 4, 2, 14);
    final waveCount = l.count.clamp(10, 26).toInt();

    for (var i = 0; i < waveCount; i++) {
      final t = i / waveCount;
      final y = topY + seaH * (0.08 + t * 0.82);
      final amp = 2.0 + t * 5.0;
      final alpha = (0.05 + t * 0.14) * l.opacity;

      final path = Path()..moveTo(-10, y);
      for (var x = 0.0; x <= 1.0; x += 0.015) {
        final wave =
            math.sin(
              2 *
                  math.pi *
                  (x * (2.5 + t * 2) +
                      t01 * cycles * (1 + t * 0.35) +
                      i * 0.13),
            ) *
            amp;
        path.lineTo(x * s.width, y + wave);
      }

      c.drawPath(
        path,
        Paint()
          ..color = foam.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0 + t * 1.8
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.5 + t * 2),
      );
    }

    final glint = 0.18 + 0.18 * math.sin(t01 * 2 * math.pi * cycles);
    c.drawRect(
      Rect.fromLTWH(0, topY, s.width, seaH * 0.35),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, topY),
          Offset(0, topY + seaH * 0.35),
          [
            Colors.white.withValues(alpha: glint * l.opacity),
            Colors.transparent,
          ],
        )
        ..blendMode = BlendMode.screen,
    );
  }

  void _waterfall(Canvas c, Size s, SceneLayer l) {
    final x = l.x * s.width;
    final topY = l.y * s.height;
    final h = l.size * s.height;
    final w = l.size * s.width * 0.65;
    final cycles = _cycles(l.speed, 8, 4, 18);
    final phase = t01 * cycles;
    final rnd = math.Random(l.seed);
    final strands = l.count.clamp(8, 24).toInt();

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(x, topY),
        Offset(x, topY + h),
        [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.55 * l.opacity),
          Colors.cyan.withValues(alpha: 0.18 * l.opacity),
        ],
        const [0.0, 0.6, 1.0],
      )
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.2);

    for (var i = 0; i < strands; i++) {
      final sx = rnd.nextDouble();
      final x0 = x + (sx - 0.5) * w;
      final path = Path()..moveTo(x0, topY);
      const segs = 14;

      for (var seg = 1; seg <= segs; seg++) {
        final t = seg / segs;
        final y = topY + t * h;
        final wiggle =
            math.sin(2 * math.pi * (t * 2 - phase) + sx * 8) * w * 0.08;
        path.lineTo(x0 + wiggle, y);
      }

      paint.strokeWidth = 1.2 + sx * 2.2;
      c.drawPath(path, paint);
    }

    for (var i = 0; i < 5; i++) {
      final mx = x + (rnd.nextDouble() - 0.5) * w * 1.4;
      final my = topY + h + rnd.nextDouble() * 12;
      final mr = w * (0.12 + rnd.nextDouble() * 0.16);
      c.drawCircle(
        Offset(mx, my),
        mr,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.18 * l.opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12),
      );
    }
  }

  void _particles(Canvas c, Size s, SceneLayer l) {
    final rnd = math.Random(l.seed);
    final paint = Paint();

    for (var i = 0; i < l.count; i++) {
      final sx = rnd.nextDouble();
      final sp = rnd.nextDouble();
      final ss = rnd.nextDouble();
      final depth = 0.35 + rnd.nextDouble() * 0.65;
      final col = l.colors[i % l.colors.length];

      switch (l.variant) {
        case 'snow':
          final cycles = _cycles(l.speed, 2.0, 1, 6);
          final prog = (t01 * cycles + sp) % 1.0;
          final wind =
              math.sin(t01 * 2 * math.pi * cycles + sp * 4) * 14 * depth;
          final turb =
              _Noise.fbm(prog * 2.2 + sp, sx * 2.0, l.seed) * 36 * depth;
          final x = sx * s.width + wind + turb;
          final y = prog * (s.height + 30) - 15;
          final size = (0.9 + 2.8 * ss) * depth;
          final alpha =
              l.opacity *
              (0.35 + 0.65 * depth) *
              (0.75 + 0.25 * math.sin(sp * 9 + t01 * 12));

          if (size > 2.1) {
            c.drawCircle(
              Offset(x, y),
              size * 1.9,
              Paint()
                ..shader = ui.Gradient.radial(Offset(x, y), size * 1.9, [
                  col.withValues(alpha: alpha * 0.85),
                  col.withValues(alpha: 0.0),
                ]),
            );

            paint
              ..shader = null
              ..maskFilter = null
              ..color = col.withValues(alpha: alpha);
            c.drawCircle(Offset(x, y), size * 0.72, paint);
          } else {
            paint
              ..shader = null
              ..maskFilter = null
              ..color = col.withValues(alpha: alpha);
            c.drawCircle(Offset(x, y), size, paint);
          }

          if (ss > 0.82) {
            paint
              ..color = col.withValues(alpha: alpha * 0.7)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.7;
            c.save();
            c.translate(x, y);
            c.rotate(prog * math.pi * 2 + sp * 6);
            for (var j = 0; j < 6; j++) {
              final a = j * math.pi / 3;
              c.drawLine(
                Offset.zero,
                Offset(math.cos(a) * size * 1.8, math.sin(a) * size * 1.8),
                paint,
              );
            }
            c.restore();
            paint.style = PaintingStyle.fill;
          }
          break;

        case 'rain':
          final cycles = _cycles(l.speed, 6.0, 4, 18);
          final prog = (t01 * cycles + sp) % 1.0;
          final gust = 0.6 + 0.4 * math.sin(t01 * 2 * math.pi * 0.6 + sp);
          final windDrift = _Noise.fbm(prog * 2, sx, l.seed) * 10;
          final x = sx * s.width + windDrift;
          final y = prog * (s.height + 30) - 15;
          final len = (10 + 22 * ss * gust) * depth;
          final slant = (-2.5 - 8 * gust) * depth;

          paint
            ..shader = null
            ..maskFilter = null
            ..color = col.withValues(
              alpha: l.opacity * (0.4 + 0.4 * gust) * depth,
            )
            ..strokeWidth = (0.8 + ss) * depth
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;
          c.drawLine(Offset(x, y), Offset(x + slant, y + len), paint);
          paint.style = PaintingStyle.fill;

          if (prog > 0.92) {
            final rp = (prog - 0.92) / 0.08;
            final rr = 2 + rp * 8 * depth;
            c.drawOval(
              Rect.fromCenter(
                center: Offset(x, s.height - 3),
                width: rr * 2,
                height: rr,
              ),
              Paint()
                ..color = col.withValues(alpha: (1 - rp) * 0.35 * l.opacity)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 0.8,
            );
          }
          break;

        case 'leaves':
        case 'petals':
          final cycles = _cycles(l.speed, 1.0, 1, 4);
          final prog = (t01 * cycles + sp) % 1.0;
          final gust = math.max(0, math.sin(t01 * 2 * math.pi * 0.4 + sp * 2));
          final gustStrength = gust * gust;
          final drift =
              _Noise.fbm(prog * 2 + sp, sx * 2, l.seed) * 80 * depth +
              gustStrength * 120 * (sp - 0.5) * depth;
          final lift = gustStrength * 30 * depth;
          final x = sx * s.width + drift;
          final y = prog * s.height - lift;
          final rot = prog * 2 * math.pi * 3 + sp * 6 + gustStrength * 4;
          final scale = (0.85 + 1.2 * ss) * depth;

          paint
            ..shader = null
            ..maskFilter = null
            ..color = col.withValues(
              alpha:
                  l.opacity *
                  depth *
                  (0.62 + 0.38 * (1 - (prog - 0.5).abs() * 2)),
            );

          c.save();
          c.translate(x, y);
          c.rotate(rot);
          c.scale(scale, scale);

          final leaf = Path()
            ..moveTo(-7, 0)
            ..quadraticBezierTo(0, -4, 7, 0)
            ..quadraticBezierTo(0, 4, -7, 0)
            ..close();
          c.drawPath(leaf, paint);

          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.45
            ..color = paint.color.withValues(alpha: paint.color.a * 0.5);
          c.drawLine(const Offset(-5, 0), const Offset(5, 0), paint);
          paint.style = PaintingStyle.fill;
          c.restore();
          break;

        case 'embers':
          final cycles = _cycles(l.speed, 1.5, 1, 5);
          final prog = (t01 * cycles + sp) % 1.0;
          final turb = _Noise.fbm(prog * 3 + sp, sx, l.seed) * 30;
          final x = sx * s.width + turb;
          final y = s.height * (1 - prog);
          final size = (1 + 2 * (1 - prog)) * depth;

          paint
            ..shader = null
            ..color = col.withValues(alpha: l.opacity * (1 - prog) * depth);
          c.drawCircle(
            Offset(x, y),
            size * 2.5,
            paint..maskFilter = MaskFilter.blur(BlurStyle.normal, 4),
          );
          paint.maskFilter = null;
          paint.color = Colors.orange.withValues(alpha: l.opacity * (1 - prog));
          c.drawCircle(Offset(x, y), size, paint);
          break;

        case 'dust':
        case 'pollen':
          final cycles = _cycles(l.speed, 1.0, 1, 4);
          final prog = (t01 * cycles + sp) % 1.0;
          final n = _Noise.fbm(prog * 2 + sp, sx * 2, l.seed);
          final x = sx * s.width + n * 85 * depth;
          final y =
              sp * s.height +
              math.sin(prog * 2 * math.pi) * s.height * 0.08 +
              _Noise.fbm(sp, prog * 2, l.seed) * 45;

          paint
            ..shader = null
            ..maskFilter = null
            ..color = col.withValues(
              alpha:
                  l.opacity * depth * (0.25 + 0.45 * math.sin(prog * math.pi)),
            );
          c.drawCircle(Offset(x, y), (0.7 + 1.4 * ss) * depth, paint);
          break;

        case 'firefly':
          final cycles = _cycles(l.speed, 1.2, 1, 4);
          final prog = (t01 * cycles + sp) % 1.0;
          final n = _Noise.fbm(prog * 2 + sp * 3, sx * 3, l.seed);
          final x = sx * s.width + n * 120;
          final y =
              (0.3 + sp * 0.5) * s.height +
              _Noise.fbm(sp * 2, prog * 2, l.seed) * 60;
          final blink =
              0.25 +
              0.75 *
                  math.pow(
                    math.max(0, math.sin(prog * 2 * math.pi * 3 + sp * 8)),
                    2,
                  );

          paint
            ..shader = null
            ..color = col.withValues(alpha: l.opacity * blink);
          c.drawCircle(
            Offset(x, y),
            4,
            paint..maskFilter = MaskFilter.blur(BlurStyle.normal, 5),
          );
          paint.maskFilter = null;
          c.drawCircle(Offset(x, y), 1.2, paint);
          break;

        case 'butterfly':
          final cycles = _cycles(l.speed, 1.0, 1, 3);
          final prog = (t01 * cycles + sp) % 1.0;
          final x =
              sx * s.width +
              _Noise.fbm(prog * 2 + sp, sx, l.seed) * s.width * 0.18;
          final y =
              (0.52 + sp * 0.32) * s.height +
              _Noise.fbm(sp, prog * 2, l.seed) * 35;
          final wing = math.sin(t01 * 2 * math.pi * 12 + sp * 8);
          final wingScale = 0.35 + 0.65 * wing.abs();
          final size = (2.8 + 3.2 * ss) * depth;

          c.save();
          c.translate(x, y);
          c.rotate(_Noise.fbm(prog, sp, l.seed) * 0.25);
          paint
            ..shader = null
            ..maskFilter = null
            ..color = col.withValues(alpha: l.opacity * depth);

          c.save();
          c.scale(-wingScale, 1.0);
          c.drawOval(
            Rect.fromCenter(
              center: Offset(size * 0.65, 0),
              width: size * 1.8,
              height: size,
            ),
            paint,
          );
          c.restore();

          c.save();
          c.scale(wingScale, 1.0);
          c.drawOval(
            Rect.fromCenter(
              center: Offset(size * 0.65, 0),
              width: size * 1.8,
              height: size,
            ),
            paint,
          );
          c.restore();

          paint
            ..color = Colors.black.withValues(alpha: l.opacity * depth * 0.75)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke;
          c.drawLine(Offset(0, -size * 0.5), Offset(0, size * 0.5), paint);
          paint.style = PaintingStyle.fill;
          c.restore();
          break;

        case 'stars':
          final tw =
              0.4 +
              0.6 *
                  math
                      .pow(
                        math.max(0, math.sin(t01 * 2 * math.pi * 1.5 + sp * 9)),
                        2,
                      )
                      .toDouble();
          paint
            ..color = col.withValues(alpha: l.opacity * tw)
            ..maskFilter = null;
          final cx = sx * s.width;
          final cy = sp * s.height * 0.45;
          c.drawCircle(Offset(cx, cy), (0.4 + 0.9 * ss) * depth, paint);
          if (ss > 0.85) {
            paint
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5;
            c.drawLine(Offset(cx - 2, cy), Offset(cx + 2, cy), paint);
            c.drawLine(Offset(cx, cy - 2), Offset(cx, cy + 2), paint);
            paint.style = PaintingStyle.fill;
          }
          break;

        case 'breath':
          final cycles = _cycles(l.speed, 1.5, 1, 4);
          final prog = (t01 * cycles + sp) % 1.0;
          final cx = l.x * s.width + math.sin(prog * 3 + sp) * 6;
          final cy = l.y * s.height - prog * 20;
          final r = 2 + prog * 6;
          c.drawCircle(
            Offset(cx, cy),
            r,
            Paint()
              ..color = Colors.white.withValues(
                alpha: (1 - prog) * 0.4 * l.opacity,
              )
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.5),
          );
          break;

        case 'sparkle':
        default:
          final tw =
              0.2 +
              0.8 *
                  math.pow(
                    math.max(0, math.sin(t01 * 2 * math.pi * 3 + sp * 8)),
                    3,
                  );
          paint
            ..shader = null
            ..maskFilter = null
            ..color = col.withValues(alpha: l.opacity * tw);
          final size = (0.8 + 1.6 * tw) * depth;
          final cx = sx * s.width;
          final cy = (sp * 0.85 + 0.05) * s.height;

          c.save();
          c.translate(cx, cy);
          c.rotate(t01 * math.pi);
          paint
            ..strokeWidth = 0.65
            ..style = PaintingStyle.stroke;
          c.drawLine(Offset(-size, 0), Offset(size, 0), paint);
          c.drawLine(Offset(0, -size), Offset(0, size), paint);
          c.drawLine(
            Offset(-size * 0.6, -size * 0.6),
            Offset(size * 0.6, size * 0.6),
            paint,
          );
          c.drawLine(
            Offset(-size * 0.6, size * 0.6),
            Offset(size * 0.6, -size * 0.6),
            paint,
          );
          paint.style = PaintingStyle.fill;
          c.restore();
          break;
      }
    }
  }

  void _fog(Canvas c, Size s, SceneLayer l) {
    for (var layer = 0; layer < 4; layer++) {
      final density = 0.14 + layer * 0.12;
      final rollOffset =
          _Noise.fbm(t01 * 2 + layer, layer.toDouble(), l.seed) * 60;
      final topY = s.height * (0.55 + layer * 0.1) + rollOffset;
      final rectH = (s.height - topY + 30).clamp(0.0, s.height).toDouble();
      if (rectH <= 0) continue;

      c.drawRect(
        Rect.fromLTWH(0, topY, s.width, rectH),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(s.width / 2, topY),
            Offset(s.width / 2, topY + rectH),
            [
              l.colors.first.withValues(alpha: 0.0),
              l.colors.first.withValues(alpha: density * l.opacity),
              l.colors.first.withValues(alpha: density * l.opacity * 0.9),
            ],
            const [0.0, 0.5, 1.0],
          )
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 25),
      );
    }
  }

  void _trees(Canvas c, Size s, SceneLayer l) {
    final rnd = math.Random(l.seed);
    final windCycles = _cycles(l.speed, 3, 1, 6);

    for (var i = 0; i < l.count; i++) {
      final xr = rnd.nextDouble();
      final yr = rnd.nextDouble();
      final sr = rnd.nextDouble();

      double x;
      if (l.edge == 'left') {
        x = xr * 0.18 * s.width;
      } else if (l.edge == 'right') {
        x = s.width - xr * 0.18 * s.width;
      } else {
        x = xr * s.width;
      }

      final y = (l.y + yr * 0.08) * s.height;
      final h = l.size * s.height * (0.55 + sr * 0.85);
      final sway = math.sin(t01 * 2 * math.pi * windCycles + i * 0.7) * 0.03;
      final foliage = l.colors.first;
      final trunkColor = l.colors.length > 1
          ? l.colors[1]
          : const Color(0xFF5D4037);
      final accent = l.colors.length > 2 ? l.colors[2] : Colors.white;

      c.save();
      c.translate(x, y);
      c.rotate(sway);

      c.drawOval(
        Rect.fromCenter(
          center: Offset(0, h * 0.03),
          width: h * 0.5,
          height: h * 0.1,
        ),
        Paint()..color = Colors.black.withValues(alpha: 0.10 * l.opacity),
      );

      if (l.variant == 'palm') {
        final top = Offset(math.sin(sway) * h * 0.12, -h * 0.78);
        final trunk = Path()
          ..moveTo(0, h * 0.02)
          ..quadraticBezierTo(h * 0.10, -h * 0.35, top.dx, top.dy);

        c.drawPath(
          trunk,
          Paint()
            ..color = trunkColor.withValues(alpha: l.opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = h * 0.055
            ..strokeCap = StrokeCap.round,
        );

        for (var f = 0; f < 7; f++) {
          final angle =
              -math.pi / 2 + (f / 6 - 0.5) * math.pi * 1.25 + sway * 0.4;
          final len = h * (0.38 + 0.12 * math.sin(f + sr * 5)).abs();
          final end = Offset(
            top.dx + math.cos(angle) * len,
            top.dy + math.sin(angle) * len * 0.55 + h * 0.06,
          );
          final mid = Offset(
            top.dx + math.cos(angle) * len * 0.5,
            top.dy + math.sin(angle) * len * 0.25 - h * 0.08,
          );

          final frond = Path()
            ..moveTo(top.dx, top.dy)
            ..quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);

          c.drawPath(
            frond,
            Paint()
              ..color = foliage.withValues(alpha: l.opacity)
              ..style = PaintingStyle.stroke
              ..strokeWidth = h * 0.03
              ..strokeCap = StrokeCap.round,
          );
        }

        c.drawCircle(
          Offset(top.dx - h * 0.03, top.dy + h * 0.03),
          h * 0.03,
          Paint()..color = trunkColor.withValues(alpha: l.opacity),
        );
        c.drawCircle(
          Offset(top.dx + h * 0.03, top.dy + h * 0.04),
          h * 0.025,
          Paint()..color = trunkColor.withValues(alpha: l.opacity),
        );
      } else if (l.variant == 'round' || l.variant == 'summer') {
        c.drawRect(
          Rect.fromCenter(
            center: Offset(0, -h * 0.18),
            width: h * 0.08,
            height: h * 0.36,
          ),
          Paint()..color = trunkColor.withValues(alpha: l.opacity),
        );

        for (var j = 0; j < 4; j++) {
          final dx = math.sin(j * 2.1) * h * 0.12;
          final dy = -h * (0.32 + j * 0.08);
          final r = h * (0.18 + 0.08 * math.sin(j + sr * 4)).abs();
          c.drawCircle(
            Offset(dx, dy),
            r,
            Paint()
              ..shader =
                  ui.Gradient.radial(Offset(dx - r * 0.2, dy - r * 0.2), r, [
                    foliage.withValues(alpha: l.opacity),
                    foliage.withValues(alpha: l.opacity * 0.72),
                  ]),
          );
        }
      } else if (l.variant == 'blossom') {
        c.drawRect(
          Rect.fromCenter(
            center: Offset(0, -h * 0.2),
            width: h * 0.07,
            height: h * 0.4,
          ),
          Paint()..color = trunkColor.withValues(alpha: l.opacity),
        );

        for (var j = 0; j < 5; j++) {
          final dx = math.sin(j * 2.3 + sr * 3) * h * 0.14;
          final dy = -h * (0.34 + j * 0.06);
          final r = h * (0.14 + 0.06 * math.sin(j + sr * 5)).abs();
          c.drawCircle(
            Offset(dx, dy),
            r,
            Paint()..color = foliage.withValues(alpha: l.opacity * 0.92),
          );
          c.drawCircle(
            Offset(dx + r * 0.2, dy - r * 0.1),
            r * 0.45,
            Paint()..color = accent.withValues(alpha: l.opacity * 0.8),
          );
        }
      } else if (l.variant == 'bare') {
        c.drawRect(
          Rect.fromCenter(
            center: Offset(0, -h * 0.15),
            width: h * 0.06,
            height: h * 0.3,
          ),
          Paint()..color = trunkColor.withValues(alpha: l.opacity),
        );
        void branch(Offset start, double len, double angle, int depth) {
          if (depth == 0 || len < 4) return;
          final end = Offset(
            start.dx + math.cos(angle) * len,
            start.dy + math.sin(angle) * len,
          );
          c.drawLine(
            start,
            end,
            Paint()
              ..color = trunkColor.withValues(alpha: l.opacity)
              ..strokeWidth = len * 0.08
              ..strokeCap = StrokeCap.round,
          );
          branch(end, len * 0.7, angle - 0.4 + sway, depth - 1);
          branch(end, len * 0.7, angle + 0.4 + sway, depth - 1);
        }

        branch(Offset(0, -h * 0.3), h * 0.22, -math.pi / 2, 4);
      } else {
        c.drawRect(
          Rect.fromCenter(
            center: Offset(0, -h * 0.1),
            width: h * 0.07,
            height: h * 0.22,
          ),
          Paint()..color = trunkColor.withValues(alpha: l.opacity),
        );

        for (var tier = 0; tier < 3; tier++) {
          final topY = -h * (0.30 + tier * 0.22);
          final halfW = h * (0.26 - tier * 0.05);
          final tierH = h * 0.26;

          final tri = Path()
            ..moveTo(0, topY - tierH)
            ..lineTo(-halfW, topY)
            ..lineTo(halfW, topY)
            ..close();

          c.drawPath(
            tri,
            Paint()..color = foliage.withValues(alpha: l.opacity),
          );

          if (l.variant == 'snow' || l.variant == 'snowpine') {
            final snowTri = Path()
              ..moveTo(0, topY - tierH)
              ..lineTo(-halfW * 0.7, topY + tierH * 0.05)
              ..lineTo(halfW * 0.7, topY + tierH * 0.05)
              ..close();
            c.drawPath(
              snowTri,
              Paint()..color = accent.withValues(alpha: 0.95 * l.opacity),
            );
          }
        }
      }

      c.restore();
    }
  }

  void _igloo(Canvas c, Size s, SceneLayer l) {
    final center = Offset(l.x * s.width, l.y * s.height);
    final r = l.size * s.width;
    final col = l.colors.first;
    final shade = l.colors.length > 1 ? l.colors[1] : const Color(0xFFBFD8EA);

    c.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + r * 0.18),
        width: r * 2.7,
        height: r * 0.65,
      ),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(center.dx, center.dy - r),
          Offset(center.dx, center.dy + r * 0.5),
          [
            Colors.white.withValues(alpha: l.opacity),
            col.withValues(alpha: l.opacity * 0.8),
          ],
        ),
    );

    final dome = Path()
      ..addArc(
        Rect.fromCenter(center: center, width: r * 2, height: r * 2),
        math.pi,
        math.pi,
      )
      ..close();

    c.drawPath(
      dome,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(center.dx, center.dy - r),
          Offset(center.dx, center.dy),
          [
            Colors.white.withValues(alpha: l.opacity),
            col.withValues(alpha: l.opacity * 0.9),
          ],
        ),
    );

    final linePaint = Paint()
      ..color = shade.withValues(alpha: 0.35 * l.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    for (var i = 1; i <= 3; i++) {
      final arcR = r * (1 - i * 0.22);
      final arc = Path()
        ..addArc(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + r * 0.03),
            width: arcR * 2,
            height: arcR * 2,
          ),
          math.pi * 1.05,
          math.pi * 0.9,
        );
      c.drawPath(arc, linePaint);
    }

    c.drawLine(
      Offset(center.dx - r * 0.55, center.dy - r * 0.25),
      Offset(center.dx + r * 0.55, center.dy - r * 0.25),
      linePaint,
    );
    c.drawLine(
      Offset(center.dx - r * 0.38, center.dy - r * 0.55),
      Offset(center.dx + r * 0.38, center.dy - r * 0.55),
      linePaint,
    );

    final entrance = Path()
      ..addArc(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + r * 0.08),
          width: r * 0.75,
          height: r * 0.75,
        ),
        math.pi,
        math.pi,
      )
      ..close();

    c.drawPath(
      entrance,
      Paint()
        ..color = const Color(0xFF1E2A38).withValues(alpha: l.opacity * 0.85),
    );
    c.drawPath(
      entrance,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(center.dx, center.dy + r * 0.05),
          r * 0.4,
          [Colors.white.withValues(alpha: 0.12), Colors.transparent],
        ),
    );

    final sparkle = 0.35 + 0.35 * math.sin(t01 * 2 * math.pi * 3);
    c.drawCircle(
      Offset(center.dx - r * 0.35, center.dy - r * 0.45),
      2.2,
      Paint()..color = Colors.white.withValues(alpha: sparkle * l.opacity),
    );
  }

  void _campfire(Canvas c, Size s, SceneLayer l) {
    final center = Offset(l.x * s.width, l.y * s.height);
    final size = l.size * s.width;
    final flameCol = l.colors.isNotEmpty ? l.colors.first : Colors.orange;
    final deepCol = l.colors.length > 1 ? l.colors[1] : Colors.deepOrange;

    c.save();
    c.translate(center.dx, center.dy);

    final pulse = 0.85 + 0.15 * math.sin(t01 * 2 * math.pi * 6);
    c.drawCircle(
      Offset(0, -size * 0.3),
      size * 3.2 * pulse,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(0, -size * 0.3),
          size * 3.2 * pulse,
          [
            flameCol.withValues(alpha: 0.24 * l.opacity),
            flameCol.withValues(alpha: 0.08 * l.opacity),
            Colors.transparent,
          ],
          const [0.0, 0.5, 1.0],
        ),
    );

    for (var i = 0; i < 5; i++) {
      final prog = (t01 * 2 + i * 0.18) % 1.0;
      final smokeY = -size * (0.8 + prog * 2.4);
      final smokeX = math.sin(prog * 6 + i) * size * 0.25;
      c.drawCircle(
        Offset(smokeX, smokeY),
        size * (0.12 + prog * 0.22),
        Paint()
          ..color = Colors.grey.withValues(alpha: (1 - prog) * 0.12 * l.opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    final logPaint = Paint()
      ..color = const Color(0xFF4E342E).withValues(alpha: l.opacity)
      ..strokeWidth = size * 0.16
      ..strokeCap = StrokeCap.round;

    c.drawLine(
      Offset(-size * 0.65, size * 0.12),
      Offset(size * 0.65, size * 0.02),
      logPaint,
    );
    c.drawLine(
      Offset(-size * 0.55, size * 0.02),
      Offset(size * 0.55, size * 0.14),
      logPaint,
    );

    for (var f = 0; f < 3; f++) {
      final flick = math.sin(t01 * 2 * math.pi * 8 + f * 1.7) * 0.18;
      final h = size * (1.15 + f * 0.18 + flick);
      final w = size * (0.28 - f * 0.05);
      final dx = math.sin(t01 * 2 * math.pi * 5 + f * 2.2) * size * 0.06;

      final flame = Path()
        ..moveTo(dx, 0)
        ..cubicTo(dx - w, -h * 0.35, dx - w * 0.35, -h * 0.72, dx, -h)
        ..cubicTo(dx + w * 0.35, -h * 0.72, dx + w, -h * 0.35, dx, 0)
        ..close();

      c.drawPath(
        flame,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(dx, 0),
            Offset(dx, -h),
            [
              deepCol.withValues(alpha: l.opacity * 0.95),
              flameCol.withValues(alpha: l.opacity),
              Colors.yellow.withValues(alpha: l.opacity * 0.95),
            ],
            const [0.0, 0.5, 1.0],
          )
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, f == 0 ? 4.0 : 1.0),
      );
    }

    final rnd = math.Random(l.seed);
    for (var i = 0; i < 12; i++) {
      final sp = rnd.nextDouble();
      final prog = (t01 * 3 + sp) % 1.0;
      final x = math.sin(prog * 8 + sp * 12) * size * 0.35;
      final y = -prog * size * 2.4;
      c.drawCircle(
        Offset(x, y),
        1.0 + (1 - prog) * 1.2,
        Paint()..color = flameCol.withValues(alpha: (1 - prog) * l.opacity),
      );
    }

    c.restore();
  }

  void _ground(Canvas c, Size s, SceneLayer l) {
    final edge = l.edge.isEmpty ? 'bottom' : l.edge;
    final h = s.height * l.size.clamp(0.08, 0.45).toDouble();
    final colA = l.colors.first;
    final colB = l.colors.length > 1 ? l.colors[1] : colA;
    final accents = l.colorsB.isEmpty
        ? const [Color(0xFFFFD54F), Color(0xFFFF8A80), Color(0xFFFFFFFF)]
        : l.colorsB;
    final rnd = math.Random(l.seed);
    final windCycles = _cycles(l.speed, 3, 1, 6);
    final wind = t01 * 2 * math.pi * windCycles;
    final phase = t01 * _cycles(l.speed, 1.5, 1, 4);

    if (edge.contains('bottom') || edge == 'all') {
      final baseTop = s.height - h;
      final path = Path()..moveTo(-10, s.height + 10);
      final topPoints = <Offset>[];
      const steps = 90;

      for (var i = 0; i <= steps; i++) {
        final xf = i / steps;
        final staticN = _Noise.fbm(xf * 3, 0.0, l.seed) * h * 0.18;
        final move = math.sin(2 * math.pi * (xf * 2 + phase)) * h * 0.05;
        final y = baseTop + staticN + move;
        final p = Offset(xf * s.width, y);
        topPoints.add(p);
        path.lineTo(p.dx, p.dy);
      }

      path
        ..lineTo(s.width + 10, s.height + 10)
        ..close();

      c.drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, baseTop),
            Offset(0, s.height),
            [
              colA.withValues(alpha: l.opacity),
              colB.withValues(alpha: l.opacity * 0.9),
            ],
          ),
      );

      if (l.variant == 'sand' || l.variant == 'beach') {
        final foamCycles = _cycles(l.speed, 3, 1, 8);

        for (var pass = 0; pass < 2; pass++) {
          final foamPath = Path();
          for (var i = 0; i < topPoints.length; i++) {
            final p = topPoints[i];
            final y =
                p.dy +
                math.sin(
                      2 *
                          math.pi *
                          (p.dx / s.width * 3 + t01 * foamCycles + pass * 0.35),
                    ) *
                    3.5 +
                pass * 4.0;

            if (i == 0) {
              foamPath.moveTo(p.dx, y);
            } else {
              foamPath.lineTo(p.dx, y);
            }
          }

          c.drawPath(
            foamPath,
            Paint()
              ..color = Colors.white.withValues(
                alpha: (0.48 - pass * 0.18) * l.opacity,
              )
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.5 - pass * 1.2
              ..strokeCap = StrokeCap.round
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3),
          );
        }

        for (var i = 0; i < 90; i++) {
          final x = rnd.nextDouble() * s.width;
          final y = baseTop + h * 0.25 + rnd.nextDouble() * h * 0.72;
          final r = 0.4 + rnd.nextDouble() * 1.2;
          final dark = rnd.nextBool();
          c.drawCircle(
            Offset(x, y),
            r,
            Paint()
              ..color = (dark ? const Color(0xFFB99B6B) : Colors.white)
                  .withValues(
                    alpha: (0.12 + rnd.nextDouble() * 0.18) * l.opacity,
                  ),
          );
        }

        for (var i = 0; i < 7; i++) {
          final x = rnd.nextDouble() * s.width;
          final y = baseTop + h * 0.45 + rnd.nextDouble() * h * 0.42;
          final shellCol = accents[i % accents.length];
          final w = 5 + rnd.nextDouble() * 5;
          c.drawOval(
            Rect.fromCenter(center: Offset(x, y), width: w, height: w * 0.55),
            Paint()..color = shellCol.withValues(alpha: l.opacity * 0.68),
          );
        }
      } else if (l.variant == 'snow') {
        for (var i = 0; i < 7; i++) {
          final x = rnd.nextDouble() * s.width;
          final y = baseTop + rnd.nextDouble() * h * 0.5;
          final w = s.width * (0.06 + rnd.nextDouble() * 0.12);
          c.drawOval(
            Rect.fromCenter(center: Offset(x, y), width: w, height: w * 0.22),
            Paint()..color = Colors.white.withValues(alpha: 0.35 * l.opacity),
          );
        }

        for (var i = 0; i < 24; i++) {
          final x = rnd.nextDouble() * s.width;
          final y = baseTop + rnd.nextDouble() * h * 0.8;
          final tw =
              0.2 + 0.8 * math.sin(t01 * 2 * math.pi * 4 + i * 1.7).abs();
          c.drawCircle(
            Offset(x, y),
            0.8 + tw,
            Paint()..color = Colors.white.withValues(alpha: tw * l.opacity),
          );
        }
      } else if (l.variant == 'forest') {
        for (var i = 0; i < 90; i++) {
          final x = rnd.nextDouble() * s.width;
          final y =
              baseTop + h * 0.25 + _Noise.fbm(i * 0.12, 0.0, l.seed) * h * 0.35;
          final bladeH = h * (0.18 + rnd.nextDouble() * 0.28);
          final sway = math.sin(wind + i * 0.35) * 0.24;
          final fernCol = accents[i % accents.length];

          final blade = Path()
            ..moveTo(x, y)
            ..quadraticBezierTo(
              x + math.sin(sway) * bladeH * 0.35,
              y - bladeH * 0.55,
              x + math.sin(sway) * bladeH * 0.65,
              y - bladeH,
            )
            ..quadraticBezierTo(
              x + math.sin(sway) * bladeH * 0.35,
              y - bladeH * 0.55,
              x + 1.8,
              y,
            )
            ..close();

          c.drawPath(
            blade,
            Paint()
              ..color = (i.isEven ? colB : fernCol).withValues(
                alpha: l.opacity * 0.88,
              ),
          );
        }
      } else if (l.variant == 'terrain') {
        for (var i = 0; i < 12; i++) {
          final x = rnd.nextDouble() * s.width;
          final y = baseTop + h * 0.35 + rnd.nextDouble() * h * 0.5;
          final sz = 6 + rnd.nextDouble() * 14;
          final rock = Path();

          for (var j = 0; j < 8; j++) {
            final a = j / 8 * 2 * math.pi;
            final r = sz * (0.7 + _Noise.fbm(a, i.toDouble(), l.seed) * 0.4);
            final px = x + math.cos(a) * r;
            final py = y + math.sin(a) * r * 0.7;
            if (j == 0) {
              rock.moveTo(px, py);
            } else {
              rock.lineTo(px, py);
            }
          }
          rock.close();

          c.drawPath(
            rock,
            Paint()
              ..shader =
                  ui.Gradient.radial(Offset(x - sz * 0.2, y - sz * 0.3), sz, [
                    colB.withValues(alpha: l.opacity * 0.9),
                    colA.withValues(alpha: l.opacity * 0.55),
                  ]),
          );
        }

        for (var i = 0; i < 42; i++) {
          final x = rnd.nextDouble() * s.width;
          final y = baseTop + h * 0.22 + rnd.nextDouble() * h * 0.55;
          final bladeH = h * (0.12 + rnd.nextDouble() * 0.2);
          final sway = math.sin(wind + i * 0.4) * 0.2;

          final blade = Path()
            ..moveTo(x, y)
            ..quadraticBezierTo(
              x + math.sin(sway) * bladeH * 0.35,
              y - bladeH * 0.55,
              x + math.sin(sway) * bladeH * 0.6,
              y - bladeH,
            )
            ..quadraticBezierTo(
              x + math.sin(sway) * bladeH * 0.35,
              y - bladeH * 0.55,
              x + 1.4,
              y,
            )
            ..close();

          c.drawPath(
            blade,
            Paint()..color = colB.withValues(alpha: l.opacity * 0.82),
          );
        }

        for (var i = 0; i < 30; i++) {
          final x = rnd.nextDouble() * s.width;
          final y = baseTop + h * 0.3 + rnd.nextDouble() * h * 0.6;
          final rot = rnd.nextDouble() * math.pi;
          final leafCol = accents[i % accents.length];

          c.save();
          c.translate(x, y);
          c.rotate(rot + math.sin(wind + i) * 0.08);
          final leaf = Path()
            ..moveTo(-4, 0)
            ..quadraticBezierTo(0, -2.5, 4, 0)
            ..quadraticBezierTo(0, 2.5, -4, 0)
            ..close();
          c.drawPath(
            leaf,
            Paint()..color = leafCol.withValues(alpha: l.opacity * 0.85),
          );
          c.restore();
        }
      } else if (l.variant == 'boulders') {
        for (var i = 0; i < 6; i++) {
          final x = (i / 6) * s.width + rnd.nextDouble() * s.width * 0.1;
          final y = baseTop + h * 0.2 + rnd.nextDouble() * h * 0.3;
          final w = s.width * (0.15 + rnd.nextDouble() * 0.15);
          final rock = Path();
          rock.moveTo(x - w / 2, y + w * 0.4);
          rock.quadraticBezierTo(x - w / 2, y - w * 0.3, x, y - w * 0.4);
          rock.quadraticBezierTo(
            x + w / 2,
            y - w * 0.3,
            x + w / 2,
            y + w * 0.4,
          );
          rock.close();
          c.drawPath(
            rock,
            Paint()
              ..shader = ui.Gradient.linear(
                Offset(x, y - w * 0.4),
                Offset(x, y + w * 0.4),
                [
                  colA.withValues(alpha: l.opacity),
                  colB.withValues(alpha: l.opacity * 0.6),
                ],
              ),
          );
          c.drawPath(
            rock,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.15 * l.opacity)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2),
          );
        }
      } else if (l.variant == 'frozenLake') {
        c.drawRect(
          Rect.fromLTWH(0, baseTop, s.width, h),
          Paint()
            ..shader =
                ui.Gradient.linear(Offset(0, baseTop), Offset(0, s.height), [
                  colA.withValues(alpha: l.opacity),
                  colB.withValues(alpha: l.opacity * 0.8),
                ]),
        );
        final crackPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.4 * l.opacity)
          ..strokeWidth = 1.2;
        for (var i = 0; i < 15; i++) {
          final x = rnd.nextDouble() * s.width;
          final y = baseTop + rnd.nextDouble() * h;
          final len = 10 + rnd.nextDouble() * 40;
          final a = rnd.nextDouble() * math.pi;
          c.drawLine(
            Offset(x, y),
            Offset(x + math.cos(a) * len, y + math.sin(a) * len),
            crackPaint,
          );
        }
        c.drawRect(
          Rect.fromLTWH(s.width * 0.6, baseTop, s.width * 0.4, h * 0.3),
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(s.width * 0.6, baseTop),
              Offset(s.width, baseTop + h * 0.3),
              [
                Colors.white.withValues(alpha: 0.1 * l.opacity),
                Colors.transparent,
              ],
            )
            ..blendMode = BlendMode.screen,
        );
      } else if (l.variant == 'scrub') {
        for (var i = 0; i < 40; i++) {
          final x = rnd.nextDouble() * s.width;
          final y = baseTop + h * 0.4 + rnd.nextDouble() * h * 0.5;
          final bushR = 4.0 + rnd.nextDouble() * 8.0;
          c.drawCircle(
            Offset(x, y),
            bushR,
            Paint()..color = colA.withValues(alpha: l.opacity),
          );
          c.drawCircle(
            Offset(x + 2, y - 2),
            bushR * 0.6,
            Paint()..color = colB.withValues(alpha: l.opacity * 0.8),
          );
          c.drawLine(
            Offset(x, y + bushR),
            Offset(x, y + bushR + 6),
            Paint()
              ..color = const Color(0xFF5D4037).withValues(alpha: l.opacity)
              ..strokeWidth = 1.2,
          );
        }
      } else if (l.variant == 'flowers' ||
          l.variant == 'summer' ||
          l.variant == 'spring') {
        for (var i = 0; i < 75; i++) {
          final t = i / 75;
          final x = t * s.width + rnd.nextDouble() * 8;
          final y =
              baseTop +
              h * 0.25 +
              _Noise.fbm(t * 3, i.toDouble(), l.seed) * h * 0.3;
          final bladeH = h * (0.2 + rnd.nextDouble() * 0.3);
          final sway = math.sin(wind + i * 0.35) * 0.22;

          final blade = Path()
            ..moveTo(x, y)
            ..quadraticBezierTo(
              x + math.sin(sway) * bladeH * 0.35,
              y - bladeH * 0.55,
              x + math.sin(sway) * bladeH * 0.6,
              y - bladeH,
            )
            ..quadraticBezierTo(
              x + math.sin(sway) * bladeH * 0.35,
              y - bladeH * 0.55,
              x + 1.6,
              y,
            )
            ..close();

          c.drawPath(
            blade,
            Paint()..color = colB.withValues(alpha: l.opacity * 0.9),
          );

          if (i.isEven) {
            final flowerCol = accents[i % accents.length];
            final fx = x + math.sin(sway) * bladeH * 0.6;
            final fy = y - bladeH;
            for (var p = 0; p < 5; p++) {
              final a = p / 5 * 2 * math.pi;
              c.drawCircle(
                Offset(fx + math.cos(a) * 2.2, fy + math.sin(a) * 2.2),
                1.6,
                Paint()..color = flowerCol.withValues(alpha: l.opacity),
              );
            }
            c.drawCircle(
              Offset(fx, fy),
              1.2,
              Paint()..color = Colors.white.withValues(alpha: l.opacity),
            );
          }
        }
      } else {
        for (var i = 0; i < 55; i++) {
          final t = i / 55;
          final x = t * s.width;
          final y =
              baseTop +
              h * 0.3 +
              _Noise.fbm(t * 3, i.toDouble(), l.seed) * h * 0.25;
          final bladeH = h * (0.18 + rnd.nextDouble() * 0.24);
          final sway = math.sin(wind + i * 0.4) * 0.2;

          final blade = Path()
            ..moveTo(x, y)
            ..quadraticBezierTo(
              x + math.sin(sway) * bladeH * 0.35,
              y - bladeH * 0.55,
              x + math.sin(sway) * bladeH * 0.6,
              y - bladeH,
            )
            ..quadraticBezierTo(
              x + math.sin(sway) * bladeH * 0.35,
              y - bladeH * 0.55,
              x + 1.4,
              y,
            )
            ..close();

          c.drawPath(
            blade,
            Paint()..color = colB.withValues(alpha: l.opacity * 0.85),
          );
        }
      }
    }

    if (edge.contains('top') || edge == 'all') {
      final topH = h * 0.35;
      c.drawRect(
        Rect.fromLTWH(0, 0, s.width, topH),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(s.width / 2, 0),
            Offset(s.width / 2, topH),
            [
              colA.withValues(alpha: l.opacity * 0.95),
              colA.withValues(alpha: 0.0),
            ],
          ),
      );

      if (l.variant == 'snow') {
        for (var i = 0; i < 14; i++) {
          final x = (i / 14) * s.width + rnd.nextDouble() * 12;
          final len = topH * (0.25 + rnd.nextDouble() * 0.4);
          final ice = Path()
            ..moveTo(x - 3, 0)
            ..lineTo(x + 3, 0)
            ..lineTo(x, len)
            ..close();
          c.drawPath(
            ice,
            Paint()
              ..shader = ui.Gradient.linear(Offset(x, 0), Offset(x, len), [
                Colors.white.withValues(alpha: l.opacity * 0.9),
                Colors.blue.withValues(alpha: l.opacity * 0.25),
              ]),
          );
        }
      }
    }

    if (edge.contains('left') || edge == 'all') {
      c.drawRect(
        Rect.fromLTWH(0, 0, h * 0.35, s.height),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, s.height / 2),
            Offset(h * 0.35, s.height / 2),
            [
              colA.withValues(alpha: l.opacity * 0.8),
              colA.withValues(alpha: 0.0),
            ],
          ),
      );
    }

    if (edge.contains('right') || edge == 'all') {
      c.drawRect(
        Rect.fromLTWH(s.width - h * 0.35, 0, h * 0.35, s.height),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(s.width - h * 0.35, s.height / 2),
            Offset(s.width, s.height / 2),
            [
              colA.withValues(alpha: 0.0),
              colA.withValues(alpha: l.opacity * 0.8),
            ],
          ),
      );
    }
  }

  void _birds(Canvas c, Size s, SceneLayer l) {
    final rnd = math.Random(l.seed);
    final moveCycles = _cycles(l.speed, 2, 1, 8);
    final flapCycles = _cycles(l.speed, 18, 10, 26);

    final paint = Paint()
      ..color = l.colors.first.withValues(alpha: l.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < l.count; i++) {
      final sx = rnd.nextDouble();
      final sy = rnd.nextDouble();
      final prog = (t01 * moveCycles + sx) % 1.0;
      final x = prog * (s.width * 1.2) - s.width * 0.1;
      final y =
          (0.12 + sy * 0.25) * s.height +
          math.sin(prog * 2 * math.pi + sx * 5) * 12;
      final size = 4.0 + sy * 4.0;
      final flap = math.sin(t01 * 2 * math.pi * flapCycles + i * 1.3);

      final path = Path()
        ..moveTo(x - size, y - flap * size * 0.35)
        ..quadraticBezierTo(x - size * 0.35, y + flap * size * 0.25, x, y)
        ..quadraticBezierTo(
          x + size * 0.35,
          y + flap * size * 0.25,
          x + size,
          y - flap * size * 0.35,
        );

      c.drawPath(path, paint);
    }
  }

  void _frame(Canvas c, Size s, SceneLayer l) {
    final col = l.colors.first;
    final colB = l.colors.length > 1 ? l.colors[1] : col;
    final thickness = s.width * 0.018;
    final pulse = 0.5 + 0.5 * math.sin(t01 * 2 * math.pi * 2);

    c.drawRect(
      Rect.fromLTWH(0, 0, s.width, thickness * 3),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(s.width / 2, 0),
          Offset(s.width / 2, thickness * 3),
          [col.withValues(alpha: l.opacity * 0.22), col.withValues(alpha: 0.0)],
        ),
    );

    c.drawRect(
      Rect.fromLTWH(0, s.height - thickness * 3, s.width, thickness * 3),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(s.width / 2, s.height - thickness * 3),
          Offset(s.width / 2, s.height),
          [col.withValues(alpha: 0.0), col.withValues(alpha: l.opacity * 0.22)],
        ),
    );

    c.drawRect(
      Rect.fromLTWH(0, 0, thickness * 3, s.height),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, s.height / 2),
          Offset(thickness * 3, s.height / 2),
          [col.withValues(alpha: l.opacity * 0.22), col.withValues(alpha: 0.0)],
        ),
    );

    c.drawRect(
      Rect.fromLTWH(s.width - thickness * 3, 0, thickness * 3, s.height),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(s.width - thickness * 3, s.height / 2),
          Offset(s.width, s.height / 2),
          [col.withValues(alpha: 0.0), col.withValues(alpha: l.opacity * 0.22)],
        ),
    );

    final off = thickness * 2;
    final corners = [
      Offset(off, off),
      Offset(s.width - off, off),
      Offset(s.width - off, s.height - off),
      Offset(off, s.height - off),
    ];

    for (var i = 0; i < corners.length; i++) {
      final p = corners[i];
      c.drawCircle(
        p,
        s.width * 0.045,
        Paint()
          ..shader = ui.Gradient.radial(p, s.width * 0.045, [
            colB.withValues(alpha: l.opacity * 0.20),
            Colors.transparent,
          ]),
      );

      c.drawCircle(
        p,
        2.2 + pulse * 1.8,
        Paint()..color = col.withValues(alpha: l.opacity * 0.8),
      );
    }
  }

  void _shimmer(Canvas c, Size s, SceneLayer l) {
    final phase = (l.seed * 0.137) % 1.0;
    final t = (t01 + phase) % 1.0;
    final cycles = (60 / l.interval).round().clamp(1, 30).toInt();
    final k = 0.5 + 0.5 * math.sin(t * 2 * math.pi * cycles);

    if (l.variant == 'frost') {
      for (var corner = 0; corner < 4; corner++) {
        c.save();
        final ox = (corner % 2 == 0) ? 0.0 : s.width;
        final oy = (corner < 2) ? 0.0 : s.height;
        c.translate(ox, oy);
        c.rotate((corner * math.pi / 2) + math.pi);
        final grow = 0.5 + 0.5 * math.sin(t * 2 * math.pi * cycles);
        final frostPath = Path()..moveTo(0, 0);
        for (var i = 0; i < 6; i++) {
          final a = i / 6 * math.pi / 2;
          final len = s.width * 0.12 * grow * (0.6 + 0.4 * math.sin(i * 3.7));
          frostPath
            ..moveTo(0, 0)
            ..lineTo(math.cos(a) * len, math.sin(a) * len);
          final mx = math.cos(a) * len * 0.5;
          final my = math.sin(a) * len * 0.5;
          frostPath
            ..moveTo(mx, my)
            ..lineTo(
              mx + math.cos(a + 0.5) * len * 0.25,
              my + math.sin(a + 0.5) * len * 0.25,
            );
        }
        c.drawPath(
          frostPath,
          Paint()
            ..color = l.colors.first.withValues(alpha: l.opacity * 0.45)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.7
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.6),
        );
        c.restore();
      }
      return;
    }

    if (l.variant == 'wet') {
      c.drawRect(
        Offset.zero & s,
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, 0), Offset(0, s.height), [
            Colors.transparent,
            l.colors.first.withValues(alpha: l.opacity * k * 0.08),
            Colors.transparent,
          ])
          ..blendMode = BlendMode.screen,
      );
      return;
    }

    if (l.variant == 'heat') {
      for (var i = 0; i < 4; i++) {
        final y = s.height * (0.55 + i * 0.12);
        final wave = math.sin(t01 * 2 * math.pi * cycles + i) * 8;
        c.drawRect(
          Rect.fromLTWH(0, y + wave, s.width, s.height * 0.12),
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(0, y + wave),
              Offset(0, y + wave + s.height * 0.12),
              [
                Colors.transparent,
                l.colors.first.withValues(alpha: l.opacity * k * 0.08),
                Colors.transparent,
              ],
              const [0.0, 0.5, 1.0],
            )
            ..blendMode = BlendMode.screen,
        );
      }
    } else {
      c.drawRect(
        Offset.zero & s,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, 0),
            Offset(s.width, s.height),
            [
              Colors.transparent,
              l.colors.first.withValues(alpha: l.opacity * k * 0.12),
              Colors.transparent,
            ],
            [0.3, 0.5, 0.7],
          )
          ..blendMode = BlendMode.screen,
      );
    }
  }

  void _scrim(Canvas c, Size s, SceneLayer l) {
    if (l.variant == 'top') {
      c.drawRect(
        Offset.zero & s,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(s.width / 2, 0),
            Offset(s.width / 2, s.height),
            [
              l.colors.first.withValues(alpha: l.opacity),
              l.colors.first.withValues(alpha: 0.0),
            ],
            [0.0, 0.5],
          ),
      );
      return;
    }
    c.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(s.width / 2, 0),
          Offset(s.width / 2, s.height),
          [
            l.colors.first.withValues(alpha: 0.0),
            l.colors.first.withValues(alpha: 0.0),
            l.colors.first.withValues(alpha: l.opacity * 0.4),
            l.colors.first.withValues(alpha: l.opacity),
          ],
          [0.0, 0.5, 0.8, 1.0],
        ),
    );
  }

  void _lightning(Canvas c, Size s, SceneLayer l) {
    final period = 12.0;
    final t = (t01 * 60) % period;
    final flash = (t < 0.18)
        ? (1.0 - t / 0.18)
        : (t > 0.25 && t < 0.40 ? 0.6 * (1 - (t - 0.25) / 0.15) : 0.0);

    if (flash <= 0) return;

    c.drawRect(
      Offset.zero & s,
      Paint()
        ..color = l.colors.first.withValues(alpha: flash * 0.5 * l.opacity)
        ..blendMode = BlendMode.screen,
    );

    final rnd = math.Random(l.seed);
    final bolt = Path();
    var x = l.x * s.width;
    var y = 0.0;
    bolt.moveTo(x, y);
    for (var i = 0; i < 8; i++) {
      x += (rnd.nextDouble() - 0.5) * s.width * 0.08;
      y += s.height * 0.08;
      bolt.lineTo(x, y);
      if (rnd.nextDouble() > 0.6) {
        final bx = x + (rnd.nextDouble() - 0.5) * s.width * 0.06;
        final by = y + s.height * 0.05;
        bolt.moveTo(x, y);
        bolt.lineTo(bx, by);
        bolt.moveTo(x, y);
      }
    }
    c.drawPath(
      bolt,
      Paint()
        ..color = Colors.white.withValues(alpha: flash * l.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.5),
    );
  }

  void _rays(Canvas c, Size s, SceneLayer l) {
    final sun = Offset(l.x * s.width, l.y * s.height);
    final drift = math.sin(t01 * 2 * math.pi * 0.3) * 0.1;
    c.save();
    c.translate(sun.dx, sun.dy);
    for (var i = 0; i < 9; i++) {
      final a = (i / 9 + drift) * math.pi * 0.8 - math.pi * 0.4;
      final len = s.width * 0.9;
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(math.cos(a - 0.05) * len, math.sin(a - 0.05) * len)
        ..lineTo(math.cos(a + 0.05) * len, math.sin(a + 0.05) * len)
        ..close();
      c.drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.linear(
            sun,
            Offset(sun.dx + math.cos(a) * len, sun.dy + math.sin(a) * len),
            [
              l.colors.first.withValues(alpha: 0.18 * l.opacity),
              Colors.transparent,
            ],
          )
          ..blendMode = BlendMode.screen,
      );
    }
    c.restore();
  }

  void _boat(Canvas c, Size s, SceneLayer l) {
    final cx = l.x * s.width;
    final cy = l.y * s.height;
    final w = l.size * s.width;
    final h = w * 0.35; // boat hull height

    // Gentle bobbing and tilting
    final bob = math.sin(t01 * 2 * math.pi * 1.2) * 1.5;
    final tilt = math.sin(t01 * 2 * math.pi * 1.2 + 1.5) * 0.04;

    c.save();
    c.translate(cx, cy + bob);
    c.rotate(tilt);

    // Water ripple around boat
    c.drawOval(
      Rect.fromCenter(
        center: Offset(0, h * 0.5),
        width: w * 1.8,
        height: h * 0.6,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15 * l.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Boat Hull
    final hullColor = l.colors.isNotEmpty ? l.colors.first : Colors.brown;
    final hull = Path()
      ..moveTo(-w / 2, 0)
      ..quadraticBezierTo(-w * 0.4, h * 0.8, 0, h * 0.9)
      ..quadraticBezierTo(w * 0.4, h * 0.8, w / 2, 0)
      ..close();

    c.drawPath(hull, Paint()..color = hullColor.withValues(alpha: l.opacity));
    // Hull outline highlight
    c.drawPath(
      hull,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2 * l.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Umbrella / Canopy
    final umbrellaColor = l.colors.length > 1 ? l.colors[1] : Colors.red;
    final poleTopY = -h * 1.5;
    // Umbrella pole
    c.drawLine(
      Offset(0, 0),
      Offset(0, poleTopY),
      Paint()
        ..color = const Color(0xFF5D4037).withValues(alpha: l.opacity)
        ..strokeWidth = 2.5,
    );

    // Canopy fabric
    final canopy = Path()
      ..moveTo(0, poleTopY - h * 0.3)
      ..quadraticBezierTo(
        -w * 0.45,
        poleTopY + h * 0.3,
        -w * 0.35,
        poleTopY + h * 0.4,
      )
      ..lineTo(w * 0.35, poleTopY + h * 0.4)
      ..quadraticBezierTo(w * 0.45, poleTopY + h * 0.3, 0, poleTopY - h * 0.3)
      ..close();

    c.drawPath(
      canopy,
      Paint()..color = umbrellaColor.withValues(alpha: l.opacity),
    );

    // Umbrella details (ribs)
    c.drawPath(
      canopy,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2 * l.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    c.restore();
  }

  @override
  bool shouldRepaint(_ScenePainter old) =>
      old.t01 != t01 || old.layers != layers;
}
