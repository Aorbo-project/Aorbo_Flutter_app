import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arobo_app/layout/app_viewport.dart';

void main() {
  group('planViewport', () {
    test('phones held upright are drawn exactly as before', () {
      for (final s in const [Size(360, 640), Size(411, 891), Size(393, 852), Size(430, 932), Size(320, 568), Size(480, 1000)]) {
        final p = planViewport(s);
        expect(p.passThrough, isTrue, reason: '$s');
        expect(p.width, s.width);
        expect(p.height, s.height);
        expect(p.scale, 1);
      }
    });

    test('tablets / foldables / landscape: a phone-width column, full height', () {
      final tablet = planViewport(const Size(1280, 800));
      expect(tablet.passThrough, isFalse);
      expect(tablet.width, 500);
      expect(tablet.height, 800);
      expect(tablet.scale, 1);
      final portraitTablet = planViewport(const Size(800, 1280));
      expect([portraitTablet.width, portraitTablet.height, portraitTablet.scale], [500, 1280, 1]);
      final foldable = planViewport(const Size(673, 841));
      expect([foldable.width, foldable.scale], [500, 1]);
    });

    test('short windows (split-screen, small tablet landscape) scale a phone canvas down', () {
      final half = planViewport(const Size(411, 420)); // phone, top half of split-screen
      expect(half.width, 411);
      expect(half.height, 560);
      expect(half.scale, closeTo(420 / 560, 1e-9));
      expect(half.height * half.scale, closeTo(420, 1e-9)); // fills the height
      expect(half.width * half.scale, lessThanOrEqualTo(411));
      final tab7 = planViewport(const Size(1024, 600));
      expect([tab7.width, tab7.height], [500, 600]); // tall enough: full height
      expect(tab7.scale, 1); // actual size
      final landscapePhone = planViewport(const Size(891, 411));
      expect(landscapePhone.width, 500);
      expect(landscapePhone.height * landscapePhone.scale, closeTo(411, 1e-9));
    });

    test('very narrow windows draw at phone width and scale down', () {
      final narrow = planViewport(const Size(250, 800));
      expect(narrow.width, 320);
      expect(narrow.scale, closeTo(250 / 320, 1e-9));
      expect(narrow.width * narrow.scale, closeTo(250, 1e-9));
      expect(narrow.height * narrow.scale, lessThanOrEqualTo(800 + 1e-9));
    });

    test('never larger than the window; degenerate sizes pass through', () {
      for (final s in const [Size(2000, 300), Size(200, 200), Size(330, 559), Size(501, 559), Size(5000, 5000)]) {
        final p = planViewport(s);
        expect(p.width * p.scale, lessThanOrEqualTo(s.width + 1e-9), reason: '$s');
        expect(p.height * p.scale, lessThanOrEqualTo(s.height + 1e-9), reason: '$s');
      }
      expect(planViewport(Size.zero).passThrough, isTrue);
    });
  });

  test('portrait lock on phones only', () {
    expect(orientationsFor(const Size(411, 891)), [DeviceOrientation.portraitUp]);
    expect(orientationsFor(const Size(1280, 800)), isEmpty);
    expect(isLargeScreen(const Size(600, 960)), isTrue);
    expect(isLargeScreen(const Size(599, 960)), isFalse);
  });

  group('AppViewport', () {
    Future<Size> canvasSizeIn(WidgetTester tester, Size window) async {
      tester.view.physicalSize = window;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      late Size seen;
      late double mqWidth;
      await tester.pumpWidget(AppViewport(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: LayoutBuilder(builder: (context, c) {
            seen = Size(c.maxWidth, c.maxHeight);
            mqWidth = MediaQuery.of(context).size.width;
            return const SizedBox.expand();
          }),
        ),
      ));
      expect(mqWidth, seen.width, reason: 'MediaQuery and layout agree');
      return seen;
    }

    testWidgets('a phone window reaches the app unchanged', (tester) async {
      expect(await canvasSizeIn(tester, const Size(411, 891)), const Size(411, 891));
    });

    testWidgets('a tablet window gives the app a phone-width canvas', (tester) async {
      expect(await canvasSizeIn(tester, const Size(1280, 800)), const Size(500, 800));
    });

    testWidgets('a half-height split-screen gives the app a full phone canvas (scaled)', (tester) async {
      expect(await canvasSizeIn(tester, const Size(411, 420)), const Size(411, 560));
    });
  });
}
