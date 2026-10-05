// Scan E5: the customer's access token must only travel to our API over the
// pinned TLS client. Analytics and the crash mirror used plain Dio clients
// (the phone's normal trust store - readable by an interception proxy), and
// CustomNetworkImage sent "Authorization: Bearer <token>" with every image,
// including vendor logos on Cloudinary.

// ignore_for_file: deprecated_member_use_from_same_package

import 'package:arobo_app/security/pinned_http_client.dart';
import 'package:arobo_app/services/analytics_service.dart';
import 'package:arobo_app/services/crash_report_service.dart';
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('analytics events go through the pinned TLS client', () {
    final adapter = AnalyticsService.instance.clientForTesting.httpClientAdapter;
    expect(adapter, isA<IOHttpClientAdapter>());
    expect((adapter as IOHttpClientAdapter).createHttpClient, PinnedHttp.createClient);
  });

  test('crash reports go through the pinned TLS client', () {
    final adapter = CrashReportService.instance.clientForTesting.httpClientAdapter;
    expect(adapter, isA<IOHttpClientAdapter>());
    expect((adapter as IOHttpClientAdapter).createHttpClient, PinnedHttp.createClient);
  });

  for (final url in [
    'https://res.cloudinary.com/aorbo/image/upload/v1/logos/vendor.png',
    'https://api.aorbotreks.co.in/storage/documents/logos/vendor.png',
  ]) {
    testWidgets('an image never carries the access token ($url)', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomNetworkImage(imageUrl: url, accessToken: 'secret-token', width: 40, height: 40),
        ),
      ));
      for (final w in tester.widgetList<CachedNetworkImage>(find.byType(CachedNetworkImage))) {
        final headers = w.httpHeaders ?? const {};
        expect(headers.keys.map((k) => k.toLowerCase()), isNot(contains('authorization')));
        expect(headers.values.join(' '), isNot(contains('secret-token')));
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
}
