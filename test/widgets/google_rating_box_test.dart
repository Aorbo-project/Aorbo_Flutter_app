import 'package:arobo_app/widgets/google_rating_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

void main() {
  group('GoogleRating.fromJson', () {
    test('reads the rating, count and link', () {
      final r = GoogleRating.fromJson({'rating': 4.6, 'count': 230, 'url': 'https://maps.google.com/?cid=1'})!;
      expect(r.rating, 4.6);
      expect(r.count, 230);
      expect(r.url.host, 'maps.google.com');
    });

    test('a whole-number rating still reads', () {
      expect(GoogleRating.fromJson({'rating': 5, 'count': 1, 'url': 'https://g.co/x'})!.rating, 5.0);
    });

    test('nothing to show, or anything malformed, means no box', () {
      for (final bad in <Object?>[
        null,
        'x',
        {'rating': null, 'count': 1, 'url': 'https://g.co/x'},
        {'rating': 4.6, 'count': '1', 'url': 'https://g.co/x'},
        {'rating': 4.6, 'count': 1},
        {'rating': 4.6, 'count': 1, 'url': 'http://g.co/x'},
        {'rating': 4.6, 'count': 1, 'url': 'javascript:alert(1)'},
      ]) {
        expect(GoogleRating.fromJson(bad), isNull, reason: '$bad');
      }
    });
  });

  testWidgets('the box names Google and shows the rating', (tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) => MaterialApp(
          home: Scaffold(
            body: GoogleRatingBox(
              data: GoogleRating(rating: 4.6, count: 230, url: Uri.parse('https://maps.google.com/?cid=1')),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Google Maps'), findsOneWidget);
    expect(find.text('4.6 (230)'), findsOneWidget);
    expect(find.text('See reviews on Google  >'), findsOneWidget);
  });
}
