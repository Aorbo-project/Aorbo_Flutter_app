// Smooth UI on slow phones (20 Nov 2026, measured on a 2.5 GB Galaxy A03):
// - the 13-layer home header took ~55 ms a frame -> home ran at 18 fps untouched and felt stuck;
// - the header + Search glow kept redrawing the screen 60x a second after scrolling away;
// - a Google video ad kept playing under other screens (30 redraws a second on the trek page).
// The header now measures the phone and steps full -> lite -> still (a cached picture), stops when
// off screen, and the ad view is dropped while its card is off screen or covered.
import 'dart:io';

import 'package:arobo_app/utils/header_scene.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _scene = HeaderSceneSpec([
  SceneLayer(type: 'sky', colors: [Colors.blue, Colors.white]),
  SceneLayer(type: 'fog'),
  SceneLayer(type: 'shimmer'),
  SceneLayer(type: 'particles', variant: 'leaves', count: 45),
  SceneLayer(type: 'clouds', count: 5),
]);

Widget _host({required bool active}) => MaterialApp(
  home: SizedBox(
    width: 360,
    height: 400,
    child: HeaderSceneBackground(scene: _scene, active: active),
  ),
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Aorbo',
      packageName: 'com.aorbotreks.app',
      version: '1.0.0',
      buildNumber: '47',
      buildSignature: '',
    );
    HeaderSceneQuality.current.value = SceneQuality.full;
  });

  test('lite scene drops the blurred layers and halves the moving items', () {
    final lite = HeaderSceneQuality.lighten(_scene.layers);
    expect(lite.map((l) => l.type), ['sky', 'particles', 'clouds']);
    expect(lite[1].count, 23);
    expect(lite[2].count, 3);
  });

  testWidgets('full level animates while on screen, draws nothing while off screen', (tester) async {
    await tester.pumpWidget(_host(active: true));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.binding.hasScheduledFrame, isTrue, reason: 'on screen at full level the scene animates');

    await tester.pumpWidget(_host(active: false));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.binding.hasScheduledFrame, isFalse, reason: 'scrolled away: no frames at all');
  });

  testWidgets('still level is one cached picture: no frames, no CustomPaint redraws', (tester) async {
    HeaderSceneQuality.current.value = SceneQuality.still;
    await tester.pumpWidget(_host(active: true));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(find.byType(RawImage), findsOneWidget);
  });

  test('home glow follows the header; ad view only while its card is on screen', () {
    final home = File('lib/screens/dashboard_widget.dart').readAsStringSync();
    expect(home, isNot(contains(')..repeat(reverse: true);\n\n    // Kept and disposed')), reason: 'the glow must not loop from initState');
    expect(home, contains('_syncGlow'));
    expect(home, contains('active: onScreen'));
    final ad = File('lib/utils/native_feed_ad_card.dart').readAsStringSync();
    expect(ad, contains('_onScreen && TickerMode.valuesOf(context).enabled'));
  });
}
