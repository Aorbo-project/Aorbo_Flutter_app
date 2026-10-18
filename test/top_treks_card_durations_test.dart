import 'package:arobo_app/utils/top_treks_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

// Every duration in full on the Popular Treks card (18 Oct 2026): the longest real
// one (Chopta, 4 options) on a small-phone card must lay out without overflowing.
void main() {
  testWidgets('four durations in full fit a small card', (tester) async {
    tester.view.physicalSize = const Size(360 * 3, 740 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(Sizer(builder: (context, orientation, deviceType) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: TopTreksCard(
                imagePath: 'assets/images/img/aorbologo.webp',
                title: 'Chopta Trek',
                kicker: '₹8,000 onwards',
                meta: 'Uttarakhand · Fri, Sat, Sun',
                description: '2 Days / 1 Night, 3 Days / 2 Nights, 4 Days / 3 Nights, 5 Days / 4 Nights',
                width: 160,
                height: 220,
              ),
            ),
          ),
        )));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    expect(find.textContaining('5 Days / 4 Nights'), findsOneWidget);
  });
}
