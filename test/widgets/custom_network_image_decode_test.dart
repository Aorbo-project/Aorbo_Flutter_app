// Scan D6 (widget level): CustomNetworkImage must hand CachedNetworkImage a
// decode WIDTH in physical px and never a decode height — both together made
// ResizeImage force the box's shape onto the photo (squashed, soft).

import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<CachedNetworkImage> _pumpAndFind(
  WidgetTester tester,
  CustomNetworkImage image, {
  double dpr = 3.0,
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = dpr;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: image))),
  );
  final widgets = tester
      .widgetList<CachedNetworkImage>(find.byType(CachedNetworkImage))
      .toList();
  expect(widgets, isNotEmpty);
  for (final w in widgets) {
    expect(w.memCacheHeight, isNull, reason: 'a decode height distorts the photo');
  }
  // Unmount before the (failing) network load can leave work behind.
  await tester.pumpWidget(const SizedBox());
  return widgets.last;
}

void main() {
  testWidgets('Top Treks card (245 x 306, cover) on a 3x phone: width-only, sharp', (tester) async {
    final w = await _pumpAndFind(
      tester,
      const CustomNetworkImage(
        imageUrl: 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        width: 245,
        height: 306,
        fit: BoxFit.cover,
      ),
    );
    expect(w.memCacheWidth, greaterThanOrEqualTo(245 * 3));
    expect(w.memCacheWidth, greaterThanOrEqualTo((306 * 1.5 * 3).floor()),
        reason: 'a 3:2 photo cropped to the box must not be upscaled');
  });

  testWidgets('shadow and transparent variants follow the same rule', (tester) async {
    await _pumpAndFind(
      tester,
      const CustomNetworkImage(
        imageUrl: 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        width: 100,
        height: 100,
        showShadow: true,
      ),
    );
    final t = await _pumpAndFind(
      tester,
      const CustomNetworkImage(
        imageUrl: 'https://res.cloudinary.com/demo/image/upload/logo.png',
        width: 60,
        height: 60,
        hasTransparentBackground: true,
      ),
      dpr: 2.0,
    );
    expect(t.memCacheWidth, 120);
  });

  testWidgets('full-screen zoomable viewer decodes at twice the normal cap', (tester) async {
    final w = await _pumpAndFind(
      tester,
      const CustomNetworkImage(
        imageUrl: 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        width: 360,
        height: 780,
        fit: BoxFit.contain,
        zoomable: true,
      ),
    );
    expect(w.memCacheWidth, 2160);
  });
}
