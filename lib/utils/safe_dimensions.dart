import 'package:flutter/painting.dart' show BoxFit;

/// Converts a layout dimension (often `double.infinity` inside an unbounded
/// Row/Expanded, or occasionally NaN from an upstream layout calculation)
/// into a finite `int` suitable for APIs like `CachedNetworkImage`'s
/// `memCacheWidth`/`memCacheHeight`, which require a finite value.
///
/// `.toInt()` on Infinity or NaN throws `Unsupported operation: Infinity or
/// NaN toInt` in Dart — this crashed CustomNetworkImage on a real device
/// 1168 times in one day (2026-09-18) before this guard existed, since every
/// rebuild attempt re-hit the same throw. Falls back to `null` (the caller
/// skips whatever sizing hint it was going to give) instead of crashing.
int? safeCacheDim(double? value) {
  if (value == null || value.isNaN || value.isInfinite) return null;
  return value.toInt();
}

/// The widest photo shape we expect (3:2 landscape). With `BoxFit.cover` a
/// photo is cropped to its box, so its decoded width must also cover the
/// box's height times this.
const double kWidestPhotoAspect = 1.5;

/// Largest decode width (physical px) for a normal photo: a full-width
/// picture on a 1440-px-wide phone, never the 4000-px original.
const int kMaxDecodeWidth = 1440;

/// The decode WIDTH (physical pixels) for a network photo shown in a
/// [width] x [height] logical box — or null for "no resize hint".
///
/// Scan D6: CustomNetworkImage used to pass both `memCacheWidth` and
/// `memCacheHeight` in logical px. `ResizeImage` (policy `exact`) then forced
/// the photo into the box's shape BEFORE `fit` ran — landscape photos came out
/// squashed (up to 3.3x) and soft (1x on 3x screens). Only a width is ever
/// returned: the decoder keeps the photo's own aspect ratio from it.
///
/// [zoom] > 1 for viewers that allow pinch-zoom (the cap grows with it).
int? decodeWidthFor({
  double? width,
  double? height,
  required double devicePixelRatio,
  BoxFit fit = BoxFit.contain,
  double zoom = 1,
}) {
  double? finite(double? v) =>
      v == null || v.isNaN || v.isInfinite || v <= 0 ? null : v;
  final w = finite(width);
  final h = finite(height);
  if (w == null && h == null) return null;
  final dpr = finite(devicePixelRatio) ?? 1.0;

  // A photo cropped to cover the box (or sized only by its height) must be
  // wide enough for the widest expected photo at the box's height.
  final heightNeeds = h == null ? 0.0 : h * kWidestPhotoAspect;
  final logical = (fit == BoxFit.cover || w == null)
      ? (w == null ? heightNeeds : (w > heightNeeds ? w : heightNeeds))
      : w;
  final physical = (logical * dpr * zoom).ceil();
  final cap = (kMaxDecodeWidth * zoom).round();
  if (physical < 1) return null;
  return physical > cap ? cap : physical;
}
