// The checkout card showed ₹7,890 while the search card (and the charge) was
// ₹7,101 (17 Oct 2026). Same rule as the server's utils/trekDiscount.js.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:arobo_app/utils/trek_discount.dart';

void main() {
  test('10% off ₹7,890 = ₹7,101, labelled like the search card', () {
    final p = trekDiscountedPrice(basePrice: '7890.00', hasDiscount: true, discountType: 'percentage', discountValue: '10.00');
    expect(p.off, closeTo(789, 1e-9));
    expect(p.price, closeTo(7101, 1e-9));
    expect(p.label, '10.00% OFF');
    expect(p.hasDiscount, isTrue);
  });

  test('fixed amount off', () {
    final p = trekDiscountedPrice(basePrice: 5000, hasDiscount: 1, discountType: 'fixed', discountValue: '500');
    expect([p.price, p.label], [4500, '₹500 OFF']);
  });

  test('no discount: off, unknown type, zero / negative value, or no price', () {
    for (final args in [
      {'has': false, 'type': 'percentage', 'value': '10'},
      {'has': true, 'type': null, 'value': '10'},
      {'has': true, 'type': 'percentage', 'value': '0'},
      {'has': true, 'type': 'fixed', 'value': '-50'},
    ]) {
      final p = trekDiscountedPrice(basePrice: '7890', hasDiscount: args['has'], discountType: args['type'] as String?, discountValue: args['value']);
      expect(p.hasDiscount, isFalse, reason: '$args');
      expect(p.price, 7890);
      expect(p.label, isNull);
    }
    expect(trekDiscountedPrice(basePrice: null, hasDiscount: true, discountType: 'fixed', discountValue: '100').price, 0);
  });

  test('never more than the price', () {
    final p = trekDiscountedPrice(basePrice: '300', hasDiscount: 'true', discountType: 'fixed', discountValue: '500');
    expect(p.price, 0);
  });

  test('checkout and the resume-booking card pass the discount to the shared card', () {
    for (final f in ['lib/screens/traveller_information_screen.dart', 'lib/services/booking_draft_service.dart']) {
      expect(File(f).readAsStringSync(), contains('discount: trekDiscountedPrice('), reason: f);
    }
    expect(File('lib/widgets/trek_card_ui.dart').readAsStringSync(), contains('hasDiscount: discount?.hasDiscount == true'));
  });
}
