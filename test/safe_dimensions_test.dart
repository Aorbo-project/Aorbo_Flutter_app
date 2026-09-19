// Regression coverage for the 2026-09-18 crash: CustomNetworkImage passed
// width/height straight into .toInt() for CachedNetworkImage's
// memCacheWidth/memCacheHeight. width/height are commonly double.infinity
// (a widget filling unbounded space) or occasionally NaN — .toInt() on
// either throws "Unsupported operation: Infinity or NaN toInt", which
// crashed one real device 1168 times in a single day, since every rebuild
// re-hit the same throw.

import 'package:flutter_test/flutter_test.dart';
import 'package:arobo_app/utils/safe_dimensions.dart';

void main() {
  group('safeCacheDim', () {
    test('double.infinity returns null instead of throwing', () {
      expect(safeCacheDim(double.infinity), isNull);
      expect(safeCacheDim(double.negativeInfinity), isNull);
    });

    test('NaN returns null instead of throwing', () {
      expect(safeCacheDim(double.nan), isNull);
    });

    test('null passes through as null', () {
      expect(safeCacheDim(null), isNull);
    });

    test('a normal finite value converts to int, same as the old .toInt() call', () {
      expect(safeCacheDim(120.0), 120);
      expect(safeCacheDim(0.0), 0);
      expect(safeCacheDim(99.9), 99); // truncates, matching double.toInt() semantics
    });
  });
}
