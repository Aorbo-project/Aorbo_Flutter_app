// Scan A3: the cities list (~350 KB, fetched on every launch) is asked for
// with the cached copy's ETag; a 304 keeps that copy (no parse, no rewrite).
// Runs DashboardController.fetchCitiesList over the real Repository client
// with a fake transport.

import 'dart:convert';
import 'dart:typed_data';

import 'package:arobo_app/app_update/app_version_info.dart';
import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/services/location_cache_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../trek_controller_test.dart' show setUpController;

typedef _Reply = ({int status, Object? body, String? etag});

/// Answers `cities` requests from a queue; records every request.
class _FakeTransport implements HttpClientAdapter {
  final List<_Reply> replies = [];
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final r = replies.removeAt(0);
    return ResponseBody.fromString(
      r.body == null ? '' : jsonEncode(r.body),
      r.status,
      headers: {
        if (r.body != null) Headers.contentTypeHeader: [Headers.jsonContentType],
        if (r.etag != null) 'etag': [r.etag!],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _cities(List<String> names) => {
      'success': true,
      'data': [
        for (var i = 0; i < names.length; i++)
          {'id': i + 1, 'cityName': names[i], 'isPopular': false},
      ],
    };

const _listKey = 'loc_cache.cities.json.v1';
const _etagKey = 'loc_cache.cities.etag.v1';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeTransport transport;
  final cache = LocationCacheService.instance;

  setUp(() async {
    await setUpController(); // connectivity fake, shared prefs, `sp`
    await cache.ensureReady();
    cache.lastLoadedCityCache = null;
    transport = _FakeTransport();
    Repository().httpClientAdapterForTesting = transport;
    AppVersionInfo.current = AppVersionInfo.from(
      version: '1.1.0',
      buildNumber: '24',
      platform: 'android',
    );
  });

  tearDown(() {
    AppVersionInfo.current = null;
    Get.reset();
  });

  String? ifNoneMatch(RequestOptions r) {
    for (final e in r.headers.entries) {
      if (e.key.toLowerCase() == 'if-none-match') return e.value?.toString();
    }
    return null;
  }

  Future<DashboardController> fetch() async {
    final d = DashboardController();
    await d.hydrateLocationCache();
    await d.fetchCitiesList();
    await d.pendingCitiesSaveForTesting;
    return d;
  }

  test('first fetch (no cache): no If-None-Match; list and ETag stored', () async {
    transport.replies.add((status: 200, body: _cities(['Pune', 'Delhi']), etag: '"v1"'));

    final d = await fetch();

    expect(ifNoneMatch(transport.requests.single), isNull);
    expect(d.citiesData.value.data!.map((c) => c.cityName), ['Pune', 'Delhi']);
    expect(await cache.citiesEtag(), '"v1"');
  });

  test('second fetch sends If-None-Match; a 304 keeps the cached list untouched', () async {
    transport.replies.add((status: 200, body: _cities(['Pune', 'Delhi']), etag: '"v1"'));
    await fetch();
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getString(_listKey);

    // Next launch: hydrated from disk, then revalidated.
    transport.replies.add((status: 304, body: null, etag: '"v1"'));
    final d = DashboardController();
    await d.hydrateLocationCache();
    final hydrated = d.citiesData.value;
    expect(cache.lastLoadedCityCache, same(hydrated));
    await d.fetchCitiesList();

    expect(ifNoneMatch(transport.requests.last), '"v1"');
    expect(d.citiesData.value, same(hydrated), reason: 'no parse, no new list');
    expect(d.pendingCitiesSaveForTesting, isNull, reason: 'no rewrite');
    expect(prefs.getString(_listKey), savedList);
    expect(await cache.citiesEtag(), '"v1"');
    expect(cache.lastLoadedCityCache, isNull, reason: 'verified current — not an offline copy');
    expect(d.errorMessage.value, isEmpty);
  });

  test('a 304 with nothing in memory loads the list from the cache', () async {
    transport.replies.add((status: 200, body: _cities(['Pune']), etag: '"v1"'));
    await fetch();

    transport.replies.add((status: 304, body: null, etag: '"v1"'));
    final d = DashboardController(); // no hydrate
    await d.fetchCitiesList();
    expect(ifNoneMatch(transport.requests.last), '"v1"');
    expect(d.citiesData.value.data!.single.cityName, 'Pune');
  });

  test('a 200 (list changed) replaces the cached list and its ETag', () async {
    transport.replies.add((status: 200, body: _cities(['Pune']), etag: '"v1"'));
    await fetch();

    transport.replies.add((status: 200, body: _cities(['Pune', 'Leh']), etag: '"v2"'));
    final d = await fetch();
    expect(ifNoneMatch(transport.requests.last), '"v1"');
    expect(d.citiesData.value.data!.map((c) => c.cityName), ['Pune', 'Leh']);
    expect(await cache.citiesEtag(), '"v2"');
    final reloaded = await cache.loadCities();
    expect(reloaded!.data!.map((c) => c.cityName), ['Pune', 'Leh']);
  });

  test('a 200 without an ETag clears the stored one', () async {
    transport.replies.add((status: 200, body: _cities(['Pune']), etag: '"v1"'));
    await fetch();
    transport.replies.add((status: 200, body: _cities(['Pune']), etag: null));
    await fetch();
    expect(await cache.citiesEtag(), isNull);

    transport.replies.add((status: 200, body: _cities(['Pune']), etag: null));
    await fetch();
    expect(ifNoneMatch(transport.requests.last), isNull);
  });

  test('no cached list → never sends If-None-Match, even with a stray ETag', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_etagKey, jsonEncode({'etag': '"stray"', 'build': '24'}));
    transport.replies.add((status: 200, body: _cities(['Pune']), etag: '"v1"'));
    await fetch();
    expect(ifNoneMatch(transport.requests.single), isNull);
  });

  test('an ETag saved by another app build is not sent', () async {
    transport.replies.add((status: 200, body: _cities(['Pune']), etag: '"v1"'));
    await fetch();
    AppVersionInfo.current = AppVersionInfo.from(
      version: '1.1.1',
      buildNumber: '25',
      platform: 'android',
    );
    transport.replies.add((status: 200, body: _cities(['Pune']), etag: '"v1"'));
    await fetch();
    expect(ifNoneMatch(transport.requests.last), isNull);
  });

  test('304 but the cached list is unreadable: ETag dropped, full list fetched', () async {
    transport.replies.add((status: 200, body: _cities(['Pune']), etag: '"v1"'));
    await fetch();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_listKey, '{not json');

    transport.replies
      ..add((status: 304, body: null, etag: '"v1"'))
      ..add((status: 200, body: _cities(['Pune', 'Goa']), etag: '"v3"'));
    final d = DashboardController();
    await d.fetchCitiesList();
    await d.pendingCitiesSaveForTesting;

    expect(ifNoneMatch(transport.requests[transport.requests.length - 2]), '"v1"');
    expect(ifNoneMatch(transport.requests.last), isNull);
    expect(d.citiesData.value.data!.map((c) => c.cityName), ['Pune', 'Goa']);
    expect(await cache.citiesEtag(), '"v3"');
  });
}
