import 'package:arobo_app/app_update/app_version_info.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Headers a request carried after [interceptor] ran (nothing hits the network).
Future<Map<String, dynamic>> _sentHeaders(Interceptor interceptor) async {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1/'));
  late Map<String, dynamic> sent;
  dio.interceptors
    ..add(interceptor)
    ..add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          sent = Map.of(options.headers);
          handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: const {}),
          );
        },
      ),
    );
  await dio.get('ping');
  return sent;
}

void main() {
  tearDown(() => AppVersionInfo.current = null);

  group('AppVersionInfo', () {
    test('keeps the build digits-only and the name header-safe', () {
      final info = AppVersionInfo.from(
        version: '1.1.0 beta\r\n',
        buildNumber: ' 24\n',
        platform: 'android',
      );
      expect(info.version, '1.1.0beta');
      expect(info.build, '24');
      expect(info.buildNumber, 24);
      expect(info.headers, {
        'X-App-Version': '1.1.0beta',
        'X-App-Build': '24',
        'X-App-Platform': 'android',
      });
    });

    test('empty values are left out of the headers', () {
      final info = AppVersionInfo.from(
        version: '',
        buildNumber: '',
        platform: 'ios',
      );
      expect(info.headers, {'X-App-Platform': 'ios'});
      expect(info.buildNumber, isNull);
    });

    test('platform defaults to android (the shipped platform)', () {
      expect(
        AppVersionInfo.from(version: '1.0.0', buildNumber: '23').platform,
        'android',
      );
    });

    test(
      'load() never throws; a failed PackageInfo leaves it unknown',
      () async {
        final info = await AppVersionInfo.load(
          source: () async => throw StateError('no plugin'),
        );
        expect(info, isNull);
        expect(AppVersionInfo.current, isNull);
        expect(AppVersionInfo.currentHeaders, isEmpty);
      },
    );
  });

  group('AppVersionHeadersInterceptor', () {
    test('adds X-App-Version, X-App-Build and X-App-Platform', () async {
      final headers = await _sentHeaders(
        AppVersionHeadersInterceptor(
          info: () => AppVersionInfo.from(
            version: '1.1.0',
            buildNumber: '24',
            platform: 'android',
          ),
        ),
      );
      expect(headers['X-App-Version'], '1.1.0');
      expect(headers['X-App-Build'], '24');
      expect(headers['X-App-Platform'], 'android');
    });

    test('uses the loaded info by default', () async {
      AppVersionInfo.current = AppVersionInfo.from(
        version: '1.2.0',
        buildNumber: '26',
        platform: 'android',
      );
      final headers = await _sentHeaders(AppVersionHeadersInterceptor());
      expect(headers['X-App-Build'], '26');
      expect(AppVersionInfo.currentHeaders['X-App-Version'], '1.2.0');
    });

    test(
      'before the version is known: no headers, request still goes out',
      () async {
        final headers = await _sentHeaders(AppVersionHeadersInterceptor());
        expect(headers.keys, isNot(contains('X-App-Version')));
        expect(headers.keys, isNot(contains('X-App-Build')));
        expect(headers.keys, isNot(contains('X-App-Platform')));
      },
    );

    test('a failing info source never fails the request', () async {
      final headers = await _sentHeaders(
        AppVersionHeadersInterceptor(info: () => throw StateError('boom')),
      );
      expect(headers.keys, isNot(contains('X-App-Build')));
    });

    test('the main API client carries it', () {
      expect(
        Repository().dio.interceptors.whereType<AppVersionHeadersInterceptor>(),
        isNotEmpty,
      );
    });
  });
}
