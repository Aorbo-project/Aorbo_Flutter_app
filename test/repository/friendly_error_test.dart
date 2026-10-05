// Scan D5: one mapper from any failure to text fit for the customer.

import 'dart:async';
import 'dart:io';

import 'package:arobo_app/repository/friendly_error.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _bad(int status, Object? body) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), statusCode: status, data: body),
      type: DioExceptionType.badResponse,
      message: 'This exception was thrown because the response has a status code of $status '
          'and RequestOptions.validateStatus was configured to throw for this status code.',
    );

DioException _net(DioExceptionType t, {Object? error}) =>
    DioException(requestOptions: RequestOptions(path: '/x'), type: t, error: error);

void main() {
  final cases = <String, (Object, String)>{
    '503 with a message': (_bad(503, {'success': false, 'message': 'Coming soon'}), 'Coming soon'),
    '502 HTML page': (_bad(502, '<html><body>Bad gateway</body></html>'), FriendlyText.serverBusy),
    '500 raw server fault': (_bad(500, {'message': "Cannot read properties of undefined (reading 'id')"}), FriendlyText.serverBusy),
    '500 no body': (_bad(500, null), FriendlyText.serverBusy),
    '409 business message': (_bad(409, {'message': 'Only 1 slot left'}), 'Only 1 slot left'),
    '400 list-shaped message': (_bad(400, [{'message': 'Phone is required'}]), 'Phone is required'),
    '400 Sequelize text': (_bad(400, {'message': 'notNull Violation: Sequelize field cannot be null'}), FriendlyText.generic),
    '404 no message': (_bad(404, {'success': false}), FriendlyText.generic),
    'connect timeout': (_net(DioExceptionType.connectionTimeout), FriendlyText.tooSlow),
    'send timeout': (_net(DioExceptionType.sendTimeout), FriendlyText.tooSlow),
    'receive timeout': (_net(DioExceptionType.receiveTimeout), FriendlyText.tooSlow),
    'no connection': (_net(DioExceptionType.connectionError), FriendlyText.noInternet),
    'socket error (unknown type)': (_net(DioExceptionType.unknown, error: const SocketException('Failed host lookup')), FriendlyText.noInternet),
    'TimeoutException': (TimeoutException('x'), FriendlyText.tooSlow),
    'thrown "Response Body Null"': ('Response Body Null', FriendlyText.generic),
    'thrown server sentence': ('Trek ID not found. Please select a trek first.', 'Trek ID not found. Please select a trek first.'),
    'Exception("…") with a sentence': (Exception('Batch is no longer active'), 'Batch is no longer active'),
    'parse error': (TypeError(), FriendlyText.generic),
    'old timeout text': (Exception('Receive Timeout Exception'), FriendlyText.generic),
    'ApiException passes through': (const ApiException('Coupon expired', statusCode: 400), 'Coupon expired'),
    'ApiException with developer text': (const ApiException('Null check operator used on a null value', statusCode: 500), FriendlyText.serverBusy),
  };

  for (final c in cases.entries) {
    test(c.key, () {
      final text = friendlyError(c.value.$1);
      expect(text, c.value.$2);
      for (final banned in ['validateStatus', 'Exception', 'Dio', 'RequestOptions', 'status code of']) {
        expect(text.contains(banned), isFalse, reason: '"$text" contains $banned');
      }
    });
  }

  test('ApiException.fromDio keeps status and code, and prints only the text', () {
    final e = ApiException.fromDio(_bad(409, {'message': 'Only 1 slot left', 'code': 'SLOTS_FULL'}));
    expect(e.statusCode, 409);
    expect(e.code, 'SLOTS_FULL');
    expect(e.toString(), 'Only 1 slot left');
  });

  test('ordinary words are not mistaken for developer text', () {
    for (final ok in ['Studio stay included', 'An exceptional view awaits', 'Audio guide is not available']) {
      expect(isFriendlyText(ok), isTrue, reason: ok);
    }
  });
}
