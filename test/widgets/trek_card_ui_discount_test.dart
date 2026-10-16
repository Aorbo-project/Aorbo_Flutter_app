// Checkout card = search card price (17 Oct 2026): ₹7,890 struck, ₹7,101 shown.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

import 'package:arobo_app/utils/trek_discount.dart';
import 'package:arobo_app/widgets/trek_card_ui.dart';

Widget _card({TrekDiscountedPrice? discount}) => Sizer(
      builder: (context, orientation, deviceType) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TrekCardUI(
              title: 'goa trip', vendorName: 'Malik travels', isFlexible: false, badgeText: '',
              durationText: '3D | 2N', departure: '2026-10-17', availableSlots: 30, totalCapacity: 30,
              price: '₹7890.00', discount: discount,
            ),
          ),
        ),
      ),
    );

String _allText(WidgetTester t) => t.widgetList<Text>(find.byType(Text)).map((w) => w.data ?? w.textSpan?.toPlainText() ?? '').join(' | ');

void main() {
  testWidgets('with the vendor discount: the discounted price and the struck base, like the search card', (t) async {
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 2.6;
    addTearDown(t.view.reset);
    await t.pumpWidget(_card(discount: trekDiscountedPrice(basePrice: '7890.00', hasDiscount: true, discountType: 'percentage', discountValue: '10.00')));
    await t.pump();
    final text = _allText(t);
    expect(text, contains('7 101'));
    expect(text, contains('7 890'));
    expect(text, contains('10.00% OFF'));
  });

  testWidgets('no discount: just the base price', (t) async {
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 2.6;
    addTearDown(t.view.reset);
    await t.pumpWidget(_card(discount: trekDiscountedPrice(basePrice: '7890.00', hasDiscount: false)));
    await t.pump();
    final text = _allText(t);
    expect(text, contains('7 890'));
    expect(text, isNot(contains('OFF')));
  });
}
