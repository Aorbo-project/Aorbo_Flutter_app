// Payment audit gap 6 (owner, 23 Nov 2026): the app carries no Razorpay key.
// The key comes from the server with each order (create-order
// next_action_params.key), so switching to live keys is one change in admin,
// and no build can ever open checkout with a built-in test key. This fails if
// any rzp_test_ / rzp_live_ key is written into the app's code again.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no Razorpay key in lib/', () {
    final key = RegExp(r'rzp_(test|live)_[A-Za-z0-9]{6,}');
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (key.hasMatch(f.readAsStringSync())) offenders.add(f.path);
    }
    expect(offenders, isEmpty, reason: 'Razorpay key found in: $offenders');
  });

  test('checkout takes its key only from the server reply', () {
    final src = File('lib/screens/payment_processing_screen.dart').readAsStringSync();
    expect(src, contains("orderNextActionParams['key']"));
    expect(src, isNot(contains('BookingConstants.razorpayKey')));
  });
}
