// Scan D7: on the booking path several controls only reacted inside an
// 18-32 dp glyph (trek details back arrow ~22 dp, traveller -/+ ~32 dp,
// sheet close "x" ~29 dp, delete-account back 18 dp). Their touch area must
// be at least 48 x 48 dp, with the drawing unchanged.

import 'package:arobo_app/screens/delete_account_screen.dart';
import 'package:arobo_app/screens/traveller_information_screen.dart';
import 'package:arobo_app/screens/trek_details_screen.dart';
import 'package:arobo_app/services/analytics_service.dart';
import 'package:arobo_app/widgets/tap_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'screen_responsive_harness.dart';

/// The touch box of the control drawn with [icon]: the nearest
/// GestureDetector above the icon (old code: the bare glyph's own box).
Size _touchBox(WidgetTester tester, IconData icon, {int index = 0}) {
  final detector = find.ancestor(of: find.byIcon(icon).at(index), matching: find.byType(GestureDetector)).first;
  return tester.getSize(detector);
}

Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(1080, 2340); // 360 x 780 dp
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(Sizer(
    builder: (context, orientation, deviceType) => GetMaterialApp(home: screen),
  ));
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _quietOverflow(Future<void> Function() body) async {
  final previous = FlutterError.onError;
  FlutterError.onError = (d) {
    if (d.exceptionAsString().contains('overflowed')) return;
    previous?.call(d);
  };
  try {
    await body();
  } finally {
    FlutterError.onError = previous;
  }
}

void main() {
  setUp(installScreenTestEnv);
  tearDown(teardownScreenTestEnv);

  testWidgets('trek details back arrow: 48 dp touch box', (tester) async {
    await _quietOverflow(() async {
      await _pump(tester, TrekDetailsScreen(trek: null));
      final box = _touchBox(tester, Icons.arrow_back_rounded);
      expect(box.width, greaterThanOrEqualTo(kMinInteractiveDimension));
      expect(box.height, greaterThanOrEqualTo(kMinInteractiveDimension));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
      // The screen logs a view event; drop its pending flush timer.
      AnalyticsService.instance.resetForTest();
    });
  });

  testWidgets('traveller count - / + : 48 dp touch boxes', (tester) async {
    await _quietOverflow(() async {
      await _pump(tester, TravellerInformationScreen());
      for (final icon in [Icons.remove, Icons.add]) {
        final box = _touchBox(tester, icon);
        expect(box.width, greaterThanOrEqualTo(kMinInteractiveDimension), reason: '$icon');
        expect(box.height, greaterThanOrEqualTo(kMinInteractiveDimension), reason: '$icon');
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });
  });

  testWidgets('delete account back arrow: 48 dp touch box', (tester) async {
    await _quietOverflow(() async {
      await _pump(tester, const DeleteAccountScreen());
      final box = _touchBox(tester, Icons.arrow_back_ios_new_rounded);
      expect(box.width, greaterThanOrEqualTo(kMinInteractiveDimension));
      expect(box.height, greaterThanOrEqualTo(kMinInteractiveDimension));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });
  });

  testWidgets('TapTarget: the drawing keeps its size; a tap anywhere in the 48 dp box counts', (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: TapTarget(
            onTap: () => taps++,
            child: const SizedBox(key: Key('glyph'), width: 22, height: 22),
          ),
        ),
      ),
    ));
    expect(tester.getSize(find.byKey(const Key('glyph'))), const Size(22, 22));
    expect(tester.getSize(find.byType(TapTarget)), const Size(48, 48));
    final center = tester.getCenter(find.byType(TapTarget));
    await tester.tapAt(center + const Offset(20, 20)); // outside the glyph
    expect(taps, 1);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });
}
