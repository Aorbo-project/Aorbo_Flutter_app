// Review C L13: the cities list and its ETag must always belong together,
// and a reply with two ETag headers must still load.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:arobo_app/app_update/app_version_info.dart';
import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/models/dashboard/cities_model.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/services/location_cache_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

import '../trek_controller_test.dart' show setUpController;

class _TwoEtags implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? s, Future<void>? c) async =>
      ResponseBody.fromString(
        jsonEncode({
          'success': true,
          'data': [
            {'id': 1, 'cityName': 'Pune', 'isPopular': false},
          ],
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          'etag': ['"a"', '"b"'],
        },
      );

  @override
  void close({bool force = false}) {}
}

GetCities _list(List<String> names) => GetCities.fromJson({
      'success': true,
      'data': [
        for (var i = 0; i < names.length; i++) {'id': i + 1, 'cityName': names[i], 'isPopular': false},
      ],
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final cache = LocationCacheService.instance;

  setUp(() async {
    await setUpController();
    await cache.ensureReady();
    AppVersionInfo.current = AppVersionInfo.from(version: '1.1.0', buildNumber: '24', platform: 'android');
  });

  tearDown(() {
    AppVersionInfo.current = null;
    Get.reset();
  });

  test('a reply with two ETag headers still loads (the first ETag is kept)', () async {
    Repository().httpClientAdapterForTesting = _TwoEtags();
    final d = DashboardController();
    await d.fetchCitiesList();
    await d.pendingCitiesSaveForTesting;
    expect(d.citiesData.value.data?.single.cityName, 'Pune');
    expect(await cache.citiesEtag(), '"a"');
  });

  test('two overlapping saves: the newest list wins, with its own ETag', () async {
    // The older reply is the big one (its encode takes longer), the newer
    // one is small: unserialised, the older list landed last.
    final names = File('test/fixtures/city_names.txt').readAsLinesSync().where((l) => l.isNotEmpty).toList();
    for (var round = 0; round < 3; round++) {
      final older = cache.saveCities(_list(names), etag: '"old-$round"');
      final newer = cache.saveCities(_list(['Leh', 'Kasol']), etag: '"new-$round"');
      await Future.wait([older, newer]);

      final stored = await cache.loadCities();
      expect(stored?.data?.map((c) => c.cityName).toList(), ['Leh', 'Kasol'], reason: 'round $round');
      expect(await cache.citiesEtag(), '"new-$round"', reason: 'round $round');
    }
  });
}
