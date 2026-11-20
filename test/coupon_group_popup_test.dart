// Group coupons (owner, 6 Nov 2026): a customer tried a 6+ group coupon 9 times with
// fewer travellers. The card now says "For 6+ travellers", says how many the booking
// has, and Apply explains in a popup instead of sending a call the server refuses.
import 'dart:io';

import 'package:arobo_app/models/coupon_code/coupon_code_model.dart';
import 'package:arobo_app/utils/coupon_not_applied_dialog.dart';
import 'package:arobo_app/utils/vendor_coupon_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

const _group = CouponCardData(
  id: 42,
  code: 'LAYAAAAA',
  discountType: 'group',
  discountValue: '18.00',
  minAmount: '4500.00',
  minParticipants: 6,
  isActive: true,
  isExpired: false,
  isUsed: false,
);

void main() {
  group('couponRefusalText', () {
    test('the server group refusal in plain words, with what to do', () {
      expect(
        couponRefusalText('Minimum 6 participants required for this group discount', travellers: 2),
        'This group offer needs at least 6 travellers in one booking. Your booking has 2. Add 4 more travellers to use it.',
      );
      expect(
        couponRefusalText('Minimum 6 participants required for this group discount', travellers: 5),
        endsWith('Add 1 more traveller to use it.'),
      );
      expect(
        couponRefusalText('Minimum 6 participants required for this group discount'),
        'This group offer needs at least 6 travellers in one booking.',
      );
    });

    test('other refusals pass through as the server words them', () {
      expect(couponRefusalText('Coupon already used by this user for this TBR', travellers: 2),
          'Coupon already used by this user for this TBR');
    });
  });

  Future<void> pumpCard(WidgetTester tester, {required int travellers, required VoidCallback onApply}) async {
    tester.view.physicalSize = const Size(360 * 3, 780 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) => GetMaterialApp(
          home: Scaffold(
            body: VendorCouponCard(coupon: _group, onApply: onApply, travelerCount: travellers),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('too few travellers: the card says so and Apply opens the popup, no call', (tester) async {
    var applied = 0;
    await pumpCard(tester, travellers: 2, onApply: () => applied++);
    expect(find.textContaining('For 6+ travellers'), findsOneWidget);
    expect(find.text('Your booking has 2 travellers'), findsOneWidget);

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(applied, 0);
    expect(find.text('LAYAAAAA not applied'), findsOneWidget);
    expect(find.textContaining('needs at least 6 travellers'), findsOneWidget);
    expect(find.textContaining('Add 4 more travellers'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('LAYAAAAA not applied'), findsNothing);
  });

  testWidgets('enough travellers: no warning, Apply goes through', (tester) async {
    var applied = 0;
    await pumpCard(tester, travellers: 6, onApply: () => applied++);
    expect(find.textContaining('For 6+ travellers'), findsOneWidget);
    expect(find.byKey(const Key('coupon-group-short')), findsNothing);
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(applied, 1);
    expect(find.textContaining('not applied'), findsNothing);
  });

  test('guard: a refused coupon is a popup in plain words, not a snackbar', () {
    final src = File('lib/controller/trek_controller.dart').readAsStringSync();
    final start = src.indexOf('Future<void> validateCoupon(');
    final body = src.substring(start, src.indexOf('static String convertDateYYYYMMDD', start));
    expect(body, contains('showCouponNotAppliedDialog('));
    expect(body, contains('couponRefusalText('));
    expect(body, isNot(contains('CustomSnackBar.show')));
  });
}
