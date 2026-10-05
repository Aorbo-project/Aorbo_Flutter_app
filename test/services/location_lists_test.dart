// Scan D12 + D10: the location lists.
// D12: on a slow first launch the From/To picker started a SECOND 346 KB
// city download, because the shared isLoadingCities flag had already been
// cleared by the 1 KB states reply; errors were told apart by matching
// words in one shared message.
// D10: the cached list is decoded off the UI isolate, and response bodies
// are no longer turned into log strings on every call.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/models/dashboard/cities_model.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/services/location_cache_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

import '../trek_controller_test.dart' show setUpController;

/// Answers by path with an optional delay; counts requests per path.
class _SlowTransport implements HttpClientAdapter {
  _SlowTransport(this.replies);
  final Map<String, ({int status, Object body, int delayMs})> replies;
  final Map<String, int> hits = {};

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? s, Future<void>? c) async {
    for (final e in replies.entries) {
      if (o.path == e.key) {
        hits[e.key] = (hits[e.key] ?? 0) + 1;
        await Future<void>.delayed(Duration(milliseconds: e.value.delayMs));
        return ResponseBody.fromString(jsonEncode(e.value.body), e.value.status, headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        });
      }
    }
    return ResponseBody.fromString('{"success":false}', 404, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _list(String key, List<String> names) => {
      'success': true,
      'data': [
        for (var i = 0; i < names.length; i++) {'id': i + 1, key: names[i], 'isPopular': false},
      ],
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setUpController();
    await LocationCacheService.instance.ensureReady();
  });
  tearDown(Get.reset);

  test('D12: a picker that opens mid-download joins it (one cities request), and the loading flag waits for the cities', () async {
    final t = _SlowTransport({
      'cities': (status: 200, body: _list('cityName', ['Pune', 'Delhi']), delayMs: 400),
      'destinations': (status: 200, body: {'success': true, 'data': []}, delayMs: 0),
      'states': (status: 200, body: {'success': true, 'data': []}, delayMs: 0),
    });
    Repository().httpClientAdapterForTesting = t;
    final d = DashboardController();

    final launch = Future.wait([d.fetchCitiesList(), d.fetchTrekList(), d.fetchStateList()]);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(d.isLoadingCities.value, isTrue, reason: 'cities still downloading');

    final picker = d.fetchCitiesList(); // what the picker does when the list is still empty
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(d.isLoadingCities.value, isTrue);

    await Future.wait([launch, picker]);
    expect(t.hits['cities'], 1);
    expect(d.citiesData.value.data?.length, 2);
    expect(d.isLoadingCities.value, isFalse);
  });

  test('D12: each list has its own error text', () async {
    Repository().httpClientAdapterForTesting = _SlowTransport({
      'cities': (status: 503, body: {'success': false}, delayMs: 0),
      'destinations': (status: 200, body: {'success': true, 'data': []}, delayMs: 0),
    });
    final d = DashboardController();
    await Future.wait([d.fetchCitiesList(), d.fetchTrekList()]);
    expect(d.citiesError.value, 'Our servers are busy. Please try again in a minute.');
    expect(d.treksError.value, isEmpty);
  });

  test('D10: the cached real-size list (6,500+ cities) round-trips through the background isolate', () async {
    final names = File('test/fixtures/city_names.txt').readAsLinesSync().where((l) => l.isNotEmpty).toList();
    final model = GetCities.fromJson(_list('cityName', names));
    await LocationCacheService.instance.saveCities(model);
    final loaded = await LocationCacheService.instance.loadCities();
    expect(loaded?.data?.length, names.length);
    expect(loaded!.data!.map((c) => c.cityName).toList(), names);
  });

  test('D10: response bodies reach the log only in debug builds, built lazily and cut to 2 KB', () {
    final src = File('lib/repository/repository.dart').readAsStringSync();
    for (final raw in [r'${response.data}', r'${options.data}', r'${error.response}', r'${e.response?.data}']) {
      expect(src.contains(raw), isFalse, reason: '$raw is interpolated eagerly');
    }
    final lines = src.split('\n');
    for (var i = 0; i < lines.length; i++) {
      if (!lines[i].contains('_clip(') || lines[i].contains('static String _clip(')) continue;
      final window = lines.sublist((i - 2).clamp(0, lines.length), i + 1).join('\n');
      expect(window.contains('_debugLog(() =>'), isTrue, reason: 'line ${i + 1}: ${lines[i].trim()}');
    }
  });
}
