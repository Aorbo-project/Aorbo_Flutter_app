// Scan D1 (widget level): in the From/To picker's empty state, "Did you
// mean…?" used to be computed inside build — and every keystroke rebuilds
// the sheet — so a 6.5k-name fuzzy pass ran per keystroke. It must now run
// once per settled (debounced) query.

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/models/dashboard/cities_model.dart';
import 'package:arobo_app/screens/source_location_screen.dart';
import 'package:arobo_app/utils/location_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../responsive/screen_responsive_harness.dart';

void main() {
  setUp(installScreenTestEnv);
  tearDown(teardownScreenTestEnv);

  testWidgets('typing a name that matches nothing: one "Did you mean" pass per settled query, not per keystroke', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final previous = FlutterError.onError;
    FlutterError.onError = (d) {
      if (d.exceptionAsString().contains('overflowed')) return;
      previous?.call(d);
    };
    try {
      final dash = Get.find<DashboardController>();
      dash.citiesData.value = GetCities(success: true, data: [
        for (final (i, n) in const ['Hyderabad', 'Bengaluru', 'Mumbai', 'Delhi', 'Pune', 'Chennai'].indexed)
          Data(id: i + 1, cityName: n, isPopular: false),
      ]);

      await tester.pumpWidget(Sizer(
        builder: (context, orientation, deviceType) => const GetMaterialApp(
          home: Scaffold(body: SourceLocationSheet()),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      final field = find.byType(TextField).first;
      debugDidYouMeanCalls = 0;
      // 8 keystrokes, 40 ms apart (inside the 180 ms debounce), then settle.
      var typed = '';
      for (final ch in 'qqqqzzzz'.split('')) {
        typed += ch;
        await tester.enterText(field, typed);
        await tester.pump(const Duration(milliseconds: 40));
      }
      await tester.pump(const Duration(milliseconds: 400));
      // At most one pass per distinct settled query: the first letter (set
      // at once when the field takes focus) and the final text.
      expect(debugDidYouMeanCalls, lessThanOrEqualTo(2));
      expect(find.textContaining('Did you mean'), findsNothing,
          reason: 'nothing close to "qqqqzzzz" in this list');

      // Rebuilds with the query unchanged (each keystroke handler rebuilds
      // the sheet) must not run it again.
      final settled = debugDidYouMeanCalls;
      for (var i = 0; i < 5; i++) {
        await tester.enterText(field, typed);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pump(const Duration(milliseconds: 400));
      expect(debugDidYouMeanCalls, settled);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    } finally {
      FlutterError.onError = previous;
    }
  });
}
