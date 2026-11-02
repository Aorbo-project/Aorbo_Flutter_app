import 'package:arobo_app/freezed_models/treks/treks_model_data.dart';
import 'package:arobo_app/utils/common_trek_card.dart';
import 'package:arobo_app/widgets/google_rating_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

Widget _app(Widget child) => Sizer(
      builder: (context, orientation, deviceType) => MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  tearDown(GoogleCardRatings.instance.clear);

  group('GoogleRating.fromJson', () {
    test('reads the rating and count', () {
      final r = GoogleRating.fromJson({'rating': 4.6, 'count': 230})!;
      expect(r.rating, 4.6);
      expect(r.count, 230);
    });

    test('a whole-number rating still reads', () {
      expect(GoogleRating.fromJson({'rating': 5, 'count': 1})!.rating, 5.0);
    });

    test('nothing to show, or anything malformed, means nothing shown', () {
      for (final bad in <Object?>[
        null,
        'x',
        {'rating': null, 'count': 1},
        {'rating': 4.6, 'count': '1'},
        {'rating': 4.6},
      ]) {
        expect(GoogleRating.fromJson(bad), isNull, reason: '$bad');
      }
    });
  });

  testWidgets('the trek page box carries Google Maps, the rating and count, and no reviews link', (tester) async {
    await tester.pumpWidget(_app(const GoogleRatingBox(data: GoogleRating(rating: 4.6, count: 230))));
    expect(find.text('Google Maps'), findsOneWidget);
    expect(find.text('4.6 (230)'), findsOneWidget);
    expect(find.textContaining('reviews'), findsNothing);
  });

  group('CommonTrekCard', () {
    TrekData trek({double rating = 0}) => TrekData(id: 7, name: 'Kedarkantha', companyName: 'Adventure Treks', rating: rating, price: '5000');

    testWidgets('a new vendor with a Google rating shows it in place of NEW', (tester) async {
      GoogleCardRatings.instance.seed(7, const GoogleRating(rating: 4.6, count: 230));
      await tester.pumpWidget(_app(CommonTrekCard(trek: trek(), onTap: () {})));
      await tester.pump();
      expect(find.text('NEW'), findsNothing);
      expect(find.text('4.6'), findsOneWidget);
      expect(find.text('Google Maps'), findsOneWidget);
    });

    testWidgets('a new vendor with no Google rating stays NEW', (tester) async {
      GoogleCardRatings.instance.seed(7, null);
      await tester.pumpWidget(_app(CommonTrekCard(trek: trek(), onTap: () {})));
      await tester.pump();
      expect(find.text('NEW'), findsOneWidget);
      expect(find.text('Google Maps'), findsNothing);
    });

    testWidgets('a vendor with an Aorbo rating never shows Google', (tester) async {
      GoogleCardRatings.instance.seed(7, const GoogleRating(rating: 4.6, count: 230));
      await tester.pumpWidget(_app(CommonTrekCard(trek: trek(rating: 4.2), onTap: () {})));
      await tester.pump();
      expect(find.text('4.2'), findsOneWidget);
      expect(find.text('Google Maps'), findsNothing);
    });
  });
}
