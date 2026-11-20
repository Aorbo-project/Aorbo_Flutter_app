import 'package:arobo_app/services/app_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

/// Every toast in the app was silently dropped: Overlay.maybeOf can only find
/// an overlay from inside one, and the lookup started from the navigator's
/// overlay itself (phone test, 2 Nov 2026).
void main() {
  testWidgets('a toast actually appears on screen', (tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) =>
            const GetMaterialApp(home: Scaffold(body: SizedBox())),
      ),
    );
    await tester.pump();

    AppFeedback.warning("This trek isn't available any more.");
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text("This trek isn't available any more."), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    AppFeedback.dismissAll();
  });
}
