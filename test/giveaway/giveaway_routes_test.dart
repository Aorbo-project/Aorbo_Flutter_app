// The app's real route table sends /giveaway-rules to the Rules screen —
// not to /giveaway, whose name it starts with.
//
// Run:  flutter test test/giveaway/giveaway_routes_test.dart

import 'package:arobo_app/giveaway/giveaway_rules_screen.dart';
import 'package:arobo_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

void main() {
  testWidgets('/giveaway-rules opens the Rules screen', (tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) => GetMaterialApp(
          home: const SizedBox.shrink(),
          getPages: routes,
        ),
      ),
    );
    Get.toNamed('/giveaway-rules');
    await tester.pumpAndSettle();
    expect(find.byType(GiveawayRulesScreen), findsOneWidget);
    expect(find.text('Giveaway Rules'), findsOneWidget);
    expect(Get.currentRoute, '/giveaway-rules');
  });
}
