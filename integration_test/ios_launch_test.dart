// First check on the iPhone simulator (Codemagic, scripts/ios_sim_test.sh): the
// app opens and the login screen lays out, on each iPhone size. Any Flutter
// error (exception, layout overflow) fails it. Asks for no code, so no SMS.
//
// A "SHOT:<name>" line makes the script save a screenshot of the simulator.

import 'package:arobo_app/main.dart' as app;
import 'package:arobo_app/services/telemetry_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

late WidgetTester _t;

/// Pumps for [d] of real time (animations, network).
Future<void> settle([Duration d = const Duration(seconds: 2)]) async {
  final end = DateTime.now().add(d);
  while (DateTime.now().isBefore(end)) {
    await _t.pump(const Duration(milliseconds: 200));
  }
}

Future<void> shot(String name) async {
  // ignore: avoid_print
  print('SHOT:$name');
  await settle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app opens on the iPhone simulator', (tester) async {
    _t = tester;
    // A test run must never report to the live server as customer activity.
    TelemetryGate.enabled = false;
    final testErrorHandler = FlutterError.onError;
    app.main();

    final phoneField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == 'Mobile number',
      description: 'Mobile number field',
    );

    final end = DateTime.now().add(const Duration(seconds: 90));
    var seen = false;
    var splashSaved = false;
    while (DateTime.now().isBefore(end) && !seen) {
      await tester.pump(const Duration(milliseconds: 250));
      seen = phoneField.evaluate().isNotEmpty;
      if (!splashSaved) {
        splashSaved = true;
        // ignore: avoid_print
        print('SHOT:1-opening');
      }
    }
    expect(seen, isTrue, reason: 'login screen did not appear within 90 s');

    // The app sets its handler once Firebase is up (main.dart _bootstrap).
    await app.appBootstrapFuture;
    FlutterError.onError = testErrorHandler;

    await settle(const Duration(seconds: 3));
    await shot('2-login');

    await tester.enterText(phoneField, '9000000000');
    await settle(const Duration(seconds: 1));
    await shot('3-login-keyboard');

    FocusManager.instance.primaryFocus?.unfocus();
    await settle(const Duration(seconds: 1));
    await shot('4-login-number-typed');
  });
}
