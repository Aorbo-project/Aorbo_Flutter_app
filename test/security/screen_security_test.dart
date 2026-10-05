// Scan E10: FLAG_SECURE (no screenshots / recording / screen sharing, blank
// recents thumbnail) on the OTP step and the payment screen only — set on
// enter, cleared on leave.

import 'package:arobo_app/security/screen_security.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<bool> calls;

  setUp(() {
    ScreenSecurity.resetForTest();
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ScreenSecurity.channel, (call) async {
      if (call.method == 'setSecure') calls.add((call.arguments as Map)['secure'] as bool);
      return true;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ScreenSecurity.channel, null);
  });

  test('on when the first screen asks, off only when the last one leaves', () async {
    await ScreenSecurity.enter();
    await ScreenSecurity.enter();
    expect(ScreenSecurity.isSecure, isTrue);
    await ScreenSecurity.leave();
    expect(ScreenSecurity.isSecure, isTrue, reason: 'one screen still needs it');
    await ScreenSecurity.leave();
    expect(ScreenSecurity.isSecure, isFalse);
    await ScreenSecurity.leave(); // extra leave is harmless
    expect(calls, [true, false]);
  });

  test('the OTP-step hold follows the step and releases on dispose', () async {
    final hold = ScreenSecurityHold();
    hold.sync(false); // phone-number step
    hold.sync(true); // OTP step shown
    hold.sync(true); // rebuilds
    await Future<void>.delayed(Duration.zero);
    expect(ScreenSecurity.isSecure, isTrue);
    hold.sync(false); // "change number" -> phone step
    await Future<void>.delayed(Duration.zero);
    expect(ScreenSecurity.isSecure, isFalse);
    hold.sync(true);
    hold.release(); // screen disposed
    await Future<void>.delayed(Duration.zero);
    expect(ScreenSecurity.isSecure, isFalse);
    expect(calls, [true, false, true, false]);
  });

  test('without the native side (iOS / tests) it never throws', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ScreenSecurity.channel, null);
    await ScreenSecurity.enter();
    await ScreenSecurity.leave();
  });
}
