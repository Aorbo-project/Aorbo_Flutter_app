// Regression coverage for the 2026-09-18 crash: CustomNetworkImage passed
// width/height straight into .toInt() for CachedNetworkImage's
// memCacheWidth/memCacheHeight. width/height are commonly double.infinity
// (a widget filling unbounded space) or occasionally NaN — .toInt() on
// either throws "Unsupported operation: Infinity or NaN toInt", which
// crashed one real device 1168 times in a single day, since every rebuild
// re-hit the same throw.

import 'package:flutter/material.dart';
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

  // Scan D6: photos were decoded in logical px with BOTH dimensions, which
  // forced the box's shape onto the photo (squashed) at 1x (soft).
  group('decodeWidthFor', () {
    test('cover: wide enough for a 3:2 photo cropped to the box, in physical px', () {
      // Top Treks card 245 x 306 dp on a 3x phone: cover needs 306*1.5*3.
      expect(decodeWidthFor(width: 245, height: 306, devicePixelRatio: 3, fit: BoxFit.cover), 1377);
    });

    test('contain: the box width times the device pixel ratio', () {
      expect(decodeWidthFor(width: 120, height: 80, devicePixelRatio: 2.75, fit: BoxFit.contain), 330);
    });

    test('never above the cap; zoomable viewers get twice the cap', () {
      expect(decodeWidthFor(width: 360, height: 800, devicePixelRatio: 3, fit: BoxFit.cover), kMaxDecodeWidth);
      expect(decodeWidthFor(width: 360, height: 800, devicePixelRatio: 3, zoom: 2), 2160);
    });

    test('height only: wide enough for a 3:2 photo at that height', () {
      expect(decodeWidthFor(height: 40, devicePixelRatio: 3), 180);
    });

    test('no usable size -> no resize hint (never throws on infinity / NaN)', () {
      expect(decodeWidthFor(devicePixelRatio: 3), isNull);
      expect(decodeWidthFor(width: double.infinity, height: double.nan, devicePixelRatio: 3), isNull);
      expect(decodeWidthFor(width: double.infinity, height: 100, devicePixelRatio: 2), 300);
      expect(decodeWidthFor(width: 100, devicePixelRatio: double.nan), 100);
    });
  });
}
