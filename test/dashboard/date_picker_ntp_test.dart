// Scan D3 (widget level): on a network that drops NTP replies, tapping the
// Home "Departure Date" field must still open the date picker at once.

import 'dart:async';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/repository/api_result.dart';
import 'package:arobo_app/screens/dashboard_widget.dart';
import 'package:arobo_app/services/trusted_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../responsive/screen_responsive_harness.dart';

void main() {
  setUp(() async {
    await installScreenTestEnv();
    // NTP never answers (UDP/123 dropped).
    TrustedClock.instance = TrustedClock(
      fetchOffset: (_) => Completer<Duration>().future,
    );
  });

  tearDown(() {
    TrustedClock.instance = TrustedClock();
    teardownScreenTestEnv();
  });

  testWidgets(
    'NTP never answers -> tapping "Departure Date" still opens the picker',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      // The test font is wider than real fonts; layout overflow is covered by
      // test/responsive, not here.
      final previousOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        previousOnError?.call(details);
      };
      try {
        await _run(tester);
      } finally {
        FlutterError.onError = previousOnError;
      }
    },
  );
}

Future<void> _run(WidgetTester tester) async {
  final dash = Get.find<DashboardController>();
  dash.selectedCityId.value = 1;
  dash.selectedTrekId.value = 2;
  dash.fromController.value.text = 'Hyderabad';
  dash.toController.value.text = 'Kedarkantha';
  // Dates still loading -> the date field (not the "no treks" card) shows.
  dash.calenderTrekDatesObserver.value = const ApiResult.loading('');

  await tester.pumpWidget(
    Sizer(
      builder: (context, orientation, deviceType) =>
          const GetMaterialApp(home: Scaffold(body: Dashboard())),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));

  final dateField = find.text('Departure Date');
  expect(dateField, findsOneWidget);
  await tester.ensureVisible(dateField);
  await tester.pump();
  await tester.tap(dateField, warnIfMissed: false);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));

  expect(find.text('Select Departure Date'), findsOneWidget);

  // Leave no pending timers: close the sheet and unmount.
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 5));
}
