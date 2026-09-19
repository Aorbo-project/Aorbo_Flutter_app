// Coverage for extractFeaturedDestinationSlug() — the URL-parsing piece
// openFeaturedDestination() relies on to route a Featured Destination card
// tap to the native detail screen. A wrong result here doesn't crash
// anything (openFeaturedDestination falls back to onMissingSlug), but it
// silently sends the user to a fallback screen instead of the trek they
// tapped — worth locking down exactly which URL shapes work.

import 'package:flutter_test/flutter_test.dart';
import 'package:arobo_app/utils/featured_destination_nav.dart';

void main() {
  group('extractFeaturedDestinationSlug', () {
    test('extracts the slug from a normal detail URL', () {
      expect(
        extractFeaturedDestinationSlug('https://www.aorbotreks.com/treks/kedarkantha-trek'),
        'kedarkantha-trek',
      );
    });

    test('extracts a numeric-id-style slug too', () {
      expect(
        extractFeaturedDestinationSlug('https://www.aorbotreks.com/treks/42'),
        '42',
      );
    });

    test('a trailing slash does not leave an empty last segment', () {
      expect(
        extractFeaturedDestinationSlug('https://www.aorbotreks.com/treks/kedarkantha-trek/'),
        'kedarkantha-trek',
      );
    });

    test('null detailUrl returns null', () {
      expect(extractFeaturedDestinationSlug(null), isNull);
    });

    test('empty string detailUrl returns null', () {
      expect(extractFeaturedDestinationSlug(''), isNull);
    });

    test('a URL with no path segments at all returns null, not throws', () {
      expect(extractFeaturedDestinationSlug('https://www.aorbotreks.com'), isNull);
      expect(extractFeaturedDestinationSlug('https://www.aorbotreks.com/'), isNull);
    });

    test('a malformed, unparseable URL returns null, not throws', () {
      expect(extractFeaturedDestinationSlug('not a url at all ::: %%%'), isNull);
    });

    test('a query string on the URL does not leak into the slug', () {
      expect(
        extractFeaturedDestinationSlug('https://www.aorbotreks.com/treks/kedarkantha-trek?ref=app'),
        'kedarkantha-trek',
      );
    });
  });
}
