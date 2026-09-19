// Coverage for DashboardController's Featured Destinations surface (added
// alongside the aorbotreks.com integration): the pure JSON->TopTreksData
// mapper, and the three network methods (list fetch, search, detail fetch
// + its in-memory cache) with the real Dio call intercepted — same
// interception style as trek_controller_test.dart's installFakeBackend,
// just attached to featuredDestinationsDioForTesting instead of
// Repository().dio, since this feature deliberately uses its own client
// (see the field comment in dashboard_controller.dart on why).
//
// DashboardController() is constructed bare (no Get.put), so onInit()'s
// unrelated side effects (city/trek/state list fetches, Firebase, etc.)
// never run — onInit is only invoked by GetX's own Get.put lifecycle, not
// by the plain constructor, and every method under test here only touches
// the Featured Destinations fields (_featuredDestinationsDio,
// _featuredDetailCache), which are initialized at field-declaration time.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/models/top_treks_data.dart';

void installFakeFeaturedDestinationsBackend(
  DashboardController controller,
  dynamic Function(RequestOptions) respond,
) {
  controller.featuredDestinationsDioForTesting.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final result = respond(options);
        if (result is Map && result['__error__'] == true) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
            ),
          );
        } else {
          handler.resolve(Response(requestOptions: options, statusCode: 200, data: result));
        }
      },
    ),
  );
}

void main() {
  group('mapFeaturedDestinationJson', () {
    test('maps a full item onto TopTreksData with the expected field reuse', () {
      final data = mapFeaturedDestinationJson({
        'id': 'kedarkantha-trek',
        'slug': 'kedarkantha-trek',
        'name': 'Kedarkantha Trek',
        'state': 'Himachal Pradesh',
        'price_start': 15000,
        'duration_days': '3D/2N,4D/3N',
        'operating_days': 'THU, FRI, SAT',
        'images': [
          {'image_url': 'https://example.com/img.jpg'},
        ],
      });

      expect(data.title, 'Kedarkantha Trek');
      expect(data.kicker, '₹15000 ONWARDS');
      expect(data.meta, 'Himachal Pradesh');
      expect(data.description, '3D/2N,4D/3N · THU, FRI, SAT');
      expect(data.imagePath, 'https://example.com/img.jpg');
      // Deliberately null — these ids belong to aorbotreks.com's own DB,
      // never the app's favorite-toggle API (see the function's doc comment).
      expect(data.trekId, isNull);
      expect(data.detailUrl, 'https://www.aorbotreks.com/treks/kedarkantha-trek');
    });

    test('price_start "N/A" falls back to state in the kicker slot, not a garbage price string', () {
      final data = mapFeaturedDestinationJson({
        'name': 'Some Trek',
        'state': 'Kerala',
        'price_start': 'N/A',
      });
      expect(data.kicker, 'Kerala');
    });

    test('missing price_start also falls back to state', () {
      final data = mapFeaturedDestinationJson({'name': 'Some Trek', 'state': 'Kerala'});
      expect(data.kicker, 'Kerala');
    });

    test('missing duration/operating days fall back to sensible defaults', () {
      final data = mapFeaturedDestinationJson({'name': 'Some Trek'});
      expect(data.description, '3D/2N · THU, FRI, SAT');
    });

    test('no images list -> empty imagePath, not a crash', () {
      final data = mapFeaturedDestinationJson({'name': 'Some Trek'});
      expect(data.imagePath, '');
    });

    test('an empty images list -> empty imagePath, not an index-out-of-range crash', () {
      final data = mapFeaturedDestinationJson({'name': 'Some Trek', 'images': []});
      expect(data.imagePath, '');
    });

    test('detailUrl building prefers slug over id, and is null when both are absent', () {
      final withSlug = mapFeaturedDestinationJson({'name': 'X', 'slug': 'x-trek', 'id': 99});
      expect(withSlug.detailUrl, 'https://www.aorbotreks.com/treks/x-trek');

      final idOnly = mapFeaturedDestinationJson({'name': 'X', 'id': 99});
      expect(idOnly.detailUrl, 'https://www.aorbotreks.com/treks/99');

      final neither = mapFeaturedDestinationJson({'name': 'X'});
      expect(neither.detailUrl, isNull);
    });
  });

  group('DashboardController.fetchTopTreks', () {
    test('success response populates topTreksObserver with mapped data', () async {
      final controller = DashboardController();
      installFakeFeaturedDestinationsBackend(controller, (options) {
        return {
          'results': [
            {'name': 'Kedarkantha Trek', 'state': 'Himachal Pradesh'},
            {'name': 'Chopta Trek', 'state': 'Uttarakhand'},
          ],
          'total_pages': 1,
        };
      });

      await controller.fetchTopTreks();

      final data = controller.topTreksObserver.value.maybeWhen(
        success: (r) => r.data,
        orElse: () => null,
      );
      expect(data, isNotNull);
      expect(data!.map((d) => d.title), ['Kedarkantha Trek', 'Chopta Trek']);
    });

    test('a network failure moves the observer to its error state, not an uncaught exception', () async {
      final controller = DashboardController();
      installFakeFeaturedDestinationsBackend(controller, (options) => {'__error__': true});

      await controller.fetchTopTreks();

      final isError = controller.topTreksObserver.value.maybeWhen(
        error: (_) => true,
        orElse: () => false,
      );
      expect(isError, isTrue);
    });

    test('a malformed body (no "results" key) also lands in the error state, not a crash', () async {
      final controller = DashboardController();
      installFakeFeaturedDestinationsBackend(controller, (options) => {'unexpected': 'shape'});

      await controller.fetchTopTreks();

      final isError = controller.topTreksObserver.value.maybeWhen(
        error: (_) => true,
        orElse: () => false,
      );
      expect(isError, isTrue);
    });
  });

  group('DashboardController.searchFeaturedDestinations', () {
    test('returns mapped results for a query', () async {
      final controller = DashboardController();
      installFakeFeaturedDestinationsBackend(controller, (options) {
        expect(options.queryParameters['q'], 'kedar');
        return {
          'results': [
            {'name': 'Kedarkantha Trek', 'state': 'Himachal Pradesh'},
          ],
        };
      });

      final results = await controller.searchFeaturedDestinations('kedar');
      expect(results, hasLength(1));
      expect(results.first.title, 'Kedarkantha Trek');
    });

    test('a query with zero matches returns an empty list, not null or an error', () async {
      final controller = DashboardController();
      installFakeFeaturedDestinationsBackend(
        controller,
        (options) => {'results': [], 'total_pages': 1},
      );

      final results = await controller.searchFeaturedDestinations('xyz123nonexistent');
      expect(results, isEmpty);
    });

    test('a network failure degrades to an empty list — a search box should never crash its screen', () async {
      final controller = DashboardController();
      installFakeFeaturedDestinationsBackend(controller, (options) => {'__error__': true});

      final results = await controller.searchFeaturedDestinations('kedar');
      expect(results, isEmpty);
    });
  });

  group('DashboardController.fetchFeaturedDestinationDetail', () {
    test('fetches and caches a detail by slug', () async {
      final controller = DashboardController();
      var requestCount = 0;
      installFakeFeaturedDestinationsBackend(controller, (options) {
        requestCount++;
        return {
          'id': 1,
          'name': 'Kedarkantha Trek',
          'state': 'Himachal Pradesh',
          'duration_days': '3D/2N',
          'operating_days': 'THU, FRI, SAT',
        };
      });

      final first = await controller.fetchFeaturedDestinationDetail('kedarkantha-trek');
      expect(first?.name, 'Kedarkantha Trek');
      expect(requestCount, 1);

      // Second call for the SAME slug must be served from
      // featuredDetailCacheForTesting — zero additional network calls.
      final second = await controller.fetchFeaturedDestinationDetail('kedarkantha-trek');
      expect(second?.name, 'Kedarkantha Trek');
      expect(requestCount, 1, reason: 'a repeat fetch for an already-cached slug must not hit the network');
    });

    test('a different slug is not served from another slug\'s cache entry', () async {
      final controller = DashboardController();
      installFakeFeaturedDestinationsBackend(controller, (options) {
        final slug = options.path.split('/').where((s) => s.isNotEmpty).last;
        return {'id': 1, 'name': 'Trek for $slug'};
      });

      final a = await controller.fetchFeaturedDestinationDetail('trek-a');
      final b = await controller.fetchFeaturedDestinationDetail('trek-b');
      expect(a?.name, 'Trek for trek-a');
      expect(b?.name, 'Trek for trek-b');
    });

    test('a network failure returns null instead of throwing', () async {
      final controller = DashboardController();
      installFakeFeaturedDestinationsBackend(controller, (options) => {'__error__': true});

      final result = await controller.fetchFeaturedDestinationDetail('kedarkantha-trek');
      expect(result, isNull);
    });

    test('a 404-shaped body ({"error": ...}, no usable fields) still parses to a detail, not a crash', () async {
      final controller = DashboardController();
      installFakeFeaturedDestinationsBackend(controller, (options) => {'error': 'Trek not found'});

      final result = await controller.fetchFeaturedDestinationDetail('does-not-exist');
      // The response IS a Map, so fromJson runs and falls back to defaults
      // for every field it doesn't recognize — this documents that actual
      // behavior rather than assuming a null/error result.
      expect(result, isNotNull);
      expect(result!.name, '');
    });
  });
}
