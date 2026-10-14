// End-to-end customer journey on a REAL Android phone against the LIVE
// server (owner, 14 Oct 2026: "make the scan tell us everything works").
//
// It drives the real app the way a customer does and fails on any Flutter
// error (exceptions, layout overflow), a screen that does not open, a web page
// that does not load, or an error toast. It never does anything irreversible:
// no payment, no cancellation, no account deletion, no ticket.
//
// Run (phone connected over adb; the Play Store build must be uninstalled
// first — different signing key):
//   flutter test integration_test/app_journey_test.dart -d <device> \
//     --dart-define=E2E_PHONE=<10-digit test login> --dart-define=E2E_OTP=<code>
//
// The login must be a DEV_OTP_PHONES number (static code, no SMS). A login
// signs every OTHER device of that account out, so use the account that is
// on this phone.

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/main.dart' as app;
import 'package:arobo_app/screens/traveller_information_screen.dart';
import 'package:arobo_app/utils/common_trek_card.dart';
import 'package:arobo_app/screens/trek_details_screen.dart';
import 'package:arobo_app/web/aorbo_web_page_screen.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_touch_ripple/flutter_touch_ripple.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';

const _phone = String.fromEnvironment('E2E_PHONE');
const _otp = String.fromEnvironment('E2E_OTP');
// A route that has upcoming treks on the live server.
const _fromCity = String.fromEnvironment('E2E_FROM', defaultValue: 'Hyderabad');
const _toPlace = String.fromEnvironment('E2E_TO', defaultValue: 'Gokarna');

late WidgetTester _t;
final List<String> _passed = [];

/// One named step; a failure says which step broke.
Future<void> step(String name, Future<void> Function() body) async {
  // ignore: avoid_print
  print('▶ $name');
  try {
    await body();
  } catch (e) {
    // ignore: avoid_print
    print('✗ $name\n  ERROR: ${e.toString().split('\n').take(8).join(' / ')}\n  passed so far: ${_passed.join(' | ')}');
    rethrow;
  }
  _passed.add(name);
  // ignore: avoid_print
  print('✓ $name');
}

/// Pumps until [finder] matches, or fails after [timeout].
Future<void> waitFor(Finder finder, {Duration timeout = const Duration(seconds: 25), String? what}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await _t.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for ${what ?? finder.describeMatch(Plurality.one)}');
}

/// Pumps for [d] of real time (animations, network).
Future<void> settle([Duration d = const Duration(seconds: 2)]) async {
  final end = DateTime.now().add(d);
  while (DateTime.now().isBefore(end)) {
    await _t.pump(const Duration(milliseconds: 200));
  }
}

Finder textFieldWithHint(String hint) => find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == hint,
      description: 'TextField "$hint"',
    );

/// No error toast on screen (AppFeedback's generic error sentence).
void expectNoErrorToast(String where) {
  expect(find.text('Something went wrong. Please try again.'), findsNothing, reason: where);
  expect(find.textContaining('undefined'), findsNothing, reason: where);
}

/// Runs the tap action of the nearest GestureDetector / InkWell above
/// [target] (synthetic taps miss on this app's layered screens).
Future<void> press(Finder target) async {
  expect(target, findsWidgets, reason: 'nothing to press: $target');
  final pressable = find.ancestor(
    of: target.last,
    matching: find.byWidgetPredicate((w) =>
        (w is GestureDetector && (w.onTap != null || w.onTapUp != null)) ||
        (w is InkWell && w.onTap != null) ||
        (w is TouchRipple && w.onTap != null)),
  );
  var elements = pressable.evaluate();
  if (elements.isEmpty) {
    // A label under a transparent tap layer (TouchRipple in the same Stack).
    final layer = find.descendant(
      of: find.ancestor(of: target.last, matching: find.byType(Stack)).first,
      matching: find.byWidgetPredicate((w) => w is TouchRipple && w.onTap != null),
    );
    if (layer.evaluate().isNotEmpty) {
      (_t.widget(layer.first) as TouchRipple).onTap?.call();
      await settle(const Duration(milliseconds: 500));
      return;
    }
  }
  expect(elements, isNotEmpty, reason: 'no button around $target');
  final w = elements.first.widget;
  if (w is GestureDetector) {
    // Finger down, then up (some buttons act on lift-off), then tap.
    final box = elements.first.renderObject as RenderBox?;
    final at = box == null ? Offset.zero : box.localToGlobal(box.size.center(Offset.zero));
    w.onTapDown?.call(TapDownDetails(globalPosition: at, kind: PointerDeviceKind.touch));
    w.onTapUp?.call(TapUpDetails(globalPosition: at, kind: PointerDeviceKind.touch));
    w.onTap?.call();
  } else if (w is InkWell) {
    w.onTap!();
  } else if (w is TouchRipple) {
    w.onTap!();
  }
  await settle(const Duration(milliseconds: 500));
}

Future<void> pressButton(String label) => press(find.text(label));

Future<void> tapText(String text) async {
  final f = find.text(text).last;
  await _t.ensureVisible(f);
  await settle(const Duration(milliseconds: 400));
  await press(f);
}

Future<void> scrollTo(String text) async {
  final scrollable = find.byType(Scrollable).first;
  await _t.scrollUntilVisible(find.text(text).last, 250, scrollable: scrollable, maxScrolls: 40);
}

/// Dismisses things that may pop up over the dashboard at any time.
Future<void> dismissOverlays() async {
  for (final label in ['I agree', 'Maybe later', 'Not now', 'Later', 'Skip']) {
    final f = find.text(label);
    if (f.evaluate().isNotEmpty) {
      await press(f.first);
      await settle(const Duration(seconds: 1));
    }
  }
}

Future<void> back() async {
  Get.back();
  await settle(const Duration(milliseconds: 900));
}

/// An in-app website page (legal / blog) loaded: the screen is up, its
/// spinner went away, and it is not the "Couldn't open" state.
Future<void> expectWebPageLoaded(String title) async {
  await waitFor(find.byType(AorboWebPageScreen), what: '$title screen');
  final page = find.byType(AorboWebPageScreen);
  final end = DateTime.now().add(const Duration(seconds: 30));
  while (DateTime.now().isBefore(end)) {
    await _t.pump(const Duration(milliseconds: 300));
    final spinning = find.descendant(of: page, matching: find.byType(CircularProgressIndicator)).evaluate().isNotEmpty;
    if (!spinning) break;
  }
  expect(find.descendant(of: page, matching: find.byType(CircularProgressIndicator)), findsNothing,
      reason: '$title still loading after 30 s');
  expect(find.textContaining("Couldn't open"), findsNothing, reason: '$title failed to load');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('customer journey on a real phone', (tester) async {
    _t = tester;
    expect(_phone.length, 10, reason: 'pass --dart-define=E2E_PHONE=<10-digit test login>');
    expect(_otp.isNotEmpty, isTrue, reason: 'pass --dart-define=E2E_OTP=<code>');

    // The app installs its own FlutterError handler (Crashlytics); give the
    // test's back as soon as the app is up, so app errors fail the test.
    final testErrorHandler = FlutterError.onError;
    app.main();

    await step('launch → login or home', () async {
      await waitFor(
        find.byWidgetPredicate((w) =>
            (w is TextField && w.decoration?.hintText == 'Mobile number') ||
            (w is Icon && w.icon == Icons.home_rounded)),
        timeout: const Duration(seconds: 60),
        what: 'login screen or home',
      );
      // The app sets its handler once Firebase is up (main.dart _bootstrap).
      await app.appBootstrapFuture;
      FlutterError.onError = testErrorHandler;
    });

    if (textFieldWithHint('Mobile number').evaluate().isNotEmpty) {
      await step('log in with phone + code', () async {
        await tester.enterText(textFieldWithHint('Mobile number'), _phone);
        await settle(const Duration(milliseconds: 600));
        // Close the keyboard (it covers the button), then tap the button.
        FocusManager.instance.primaryFocus?.unfocus();
        await settle(const Duration(seconds: 1));
        // A synthetic tap lands on the login screen's animated wrapper, not the
        // button (a real finger works — checked on the phone, code in 2 s), so
        // run the button's own action.
        await pressButton('Continue');
        final asked = DateTime.now();
        await waitFor(find.text('Verify your number'), timeout: const Duration(seconds: 70), what: 'OTP step');
        // ignore: avoid_print
        print('  code step after ${DateTime.now().difference(asked).inSeconds} s');
        final pin = find.descendant(of: find.byType(EditableText).last, matching: find.byType(EditableText));
        await tester.enterText(pin.evaluate().isNotEmpty ? pin : find.byType(EditableText).last, _otp);
        await waitFor(find.byIcon(Icons.home_rounded), timeout: const Duration(seconds: 40), what: 'home after login');
      });
    }

    await step('home screen settles (pop-ups dismissed)', () async {
      await settle(const Duration(seconds: 4));
      await dismissOverlays();
      expectNoErrorToast('home');
    });

    // ── Account menu: every screen opens and closes ──────────────────────
    await step('Account tab', () async {
      await press(find.byIcon(Icons.person_rounded));
      await waitFor(find.text('Become Partner'), what: 'Account menu');
    });

    for (final item in ['Safety', 'Help', 'My Tickets', 'Notifications', 'Refer & Earn']) {
      await step('Account → $item', () async {
        await scrollTo(item);
        await tapText(item);
        await settle(const Duration(seconds: 3));
        expect(find.text('Become Partner'), findsNothing, reason: '$item did not open');
        expectNoErrorToast(item);
        await back();
        await waitFor(find.text('Become Partner'), what: 'back on Account');
      });
    }

    await step('Account → About → Blogs (in-app)', () async {
      await scrollTo('About Aorbo Treks');
      await tapText('About Aorbo Treks');
      await waitFor(find.text('ESTABLISHED  2025'), what: 'About Us');
      expect(find.text('Call to Action'), findsNothing);
      expect(find.text('Terms and Conditions'), findsNothing, reason: 'legal links live only in Account');
      await scrollTo('Blogs');
      await tapText('Blogs');
      await expectWebPageLoaded('Blogs');
      await back();
      await back();
      await waitFor(find.text('Become Partner'), what: 'back on Account');
    });

    for (final doc in ['Terms & Conditions', 'Privacy Policy', 'User Agreement', 'Refund & Cancellation Policy']) {
      await step('Account → $doc (in-app)', () async {
        await scrollTo(doc);
        await tapText(doc);
        await expectWebPageLoaded(doc);
        await back();
        await waitFor(find.text('Become Partner'), what: 'back on Account');
      });
    }

    // ── Bookings tab ─────────────────────────────────────────────────────
    await step('Bookings tab opens', () async {
      await press(find.byIcon(Icons.event_available_rounded));
      await settle(const Duration(seconds: 4));
      expectNoErrorToast('Bookings');
    });

    // ── Search → trek → checkout (stops before paying) ───────────────────
    await step('search $_fromCity → $_toPlace', () async {
      await press(find.byIcon(Icons.home_rounded));
      await settle(const Duration(seconds: 2));
      await dismissOverlays();
      await press(find.text('From'));
      await waitFor(textFieldWithHint('e.g. Delhi, Mumbai'), what: 'location picker');
      await tester.enterText(textFieldWithHint('e.g. Delhi, Mumbai'), _fromCity);
      await waitFor(find.text(_fromCity), what: '$_fromCity in results');
      await press(find.text(_fromCity));
      await waitFor(textFieldWithHint('e.g. Kedarkantha, Roopkund'), what: 'destination field');
      await tester.enterText(textFieldWithHint('e.g. Kedarkantha, Roopkund'), _toPlace);
      await waitFor(find.text(_toPlace), what: '$_toPlace in results');
      await press(find.text(_toPlace));
      await settle(const Duration(seconds: 4));

      // The calendar sheet opens by itself; pick the first available date
      // through the controller (the sheet's day cells are not unique text).
      final dash = Get.find<DashboardController>();
      expect(dash.availableDates.isNotEmpty, isTrue, reason: 'no dates on $_fromCity → $_toPlace');
      final first = (dash.availableDates.keys.map(DateTime.tryParse).whereType<DateTime>().toList()..sort()).first;
      if (find.byType(BottomSheet).evaluate().isNotEmpty) await back();
      dash.selectedDate.value = first;
      dash.dateController.value.text = DateFormat('dd/MM/yyyy').format(first);
      await settle(const Duration(seconds: 1));

      await scrollTo('Search');
      await tapText('Search');
      await settle(const Duration(seconds: 5));
      expectNoErrorToast('search results');
    });

    await step('open a trek', () async {
      await waitFor(find.byType(CommonTrekCard), what: 'a trek card in results');
      (tester.widget(find.byType(CommonTrekCard).first) as CommonTrekCard).onTap?.call();
      await waitFor(find.byType(TrekDetailsScreen), what: 'trek details');
      await settle(const Duration(seconds: 4));
      expectNoErrorToast('trek details');
    });

    await step('trek → Continue → checkout (no timer)', () async {
      final chips = find.byType(ChoiceChip);
      if (chips.evaluate().isNotEmpty) {
        await tester.ensureVisible(chips.first);
        (tester.widget(chips.first) as ChoiceChip).onSelected?.call(true);
        await settle(const Duration(seconds: 1));
      }
      await tapText('Continue');
      await waitFor(find.byType(TravellerInformationScreen), what: 'checkout');
      await waitFor(find.text('Total Payable'), what: 'fare on checkout');
      expect(find.byIcon(Icons.timer_outlined), findsNothing, reason: 'checkout timer must be gone');
      expectNoErrorToast('checkout');
    });

    await step('leave checkout and trek', () async {
      await back();
      await back();
      await back();
      expect(tester.takeException(), isNull);
    });

    // ignore: avoid_print
    print('ALL STEPS PASSED (${_passed.length}): ${_passed.join(' | ')}');
  }, timeout: const Timeout(Duration(minutes: 20)));
}
