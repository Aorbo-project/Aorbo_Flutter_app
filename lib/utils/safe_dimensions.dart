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
