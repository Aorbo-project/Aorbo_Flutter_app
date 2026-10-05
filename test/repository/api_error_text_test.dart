// Scan D5 (behaviour): what the real Repository calls throw is text fit for
// the customer — never Dio's developer paragraph ("This exception was thrown
// because the response has a status code of 503 and
// RequestOptions.validateStatus ..."), "Receive Timeout Exception", or a
// crash on an HTML error page.

import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:dio/dio.dart' hide Response;
import 'package:dio/dio.dart' as dio show Response;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../trek_controller_test.dart' show setUpController, setUpPumpedController;

const _busy = 'Our servers are busy. Please try again in a minute.';
const _slow = 'The server is taking too long. Please try again.';
const _generic = 'Something went wrong. Please try again.';

/// Answers [path] with an HTTP error, or fails it with [failType].
void _answer(String path, {int? status, Object? body, DioExceptionType? failType}) {
  Repository().dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
    if (!o.path.contains(path)) return h.next(o);
    if (failType != null) {
      return h.reject(DioException(requestOptions: o, type: failType));
    }
    h.reject(DioException(
      requestOptions: o,
      response: dio.Response(requestOptions: o, statusCode: status, data: body),
      type: DioExceptionType.badResponse,
      message: 'This exception was thrown because the response has a status code of $status '
          'and RequestOptions.validateStatus was configured to throw for this status code.',
    ));
  }));
}

Future<String> _thrownText(Future<void> Function() call) async {
  try {
    await call();
  } catch (e) {
    return e.toString();
  }
  fail('expected the call to fail');
}

void _expectFriendly(String text) {
  for (final banned in ['validateStatus', 'Exception', 'Dio', 'status code of', 'NoSuchMethod', 'TypeError']) {
    expect(text.contains(banned), isFalse, reason: '"$text" contains $banned');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setUpController();
  });

  tearDown(() {
    Repository().dio.interceptors.clear();
    Get.reset();
  });

  final repo = Repository();

  test('GET 503 without a message -> "servers are busy", not the Dio paragraph', () async {
    _answer('states', status: 503, body: {'success': false});
    final text = await _thrownText(() => repo.getApiCall(url: NetworkUrl.getStateList));
    expect(text, _busy);
    _expectFriendly(text);
  });

  test("GET 503 with the server's message -> that message", () async {
    _answer('states', status: 503, body: {'success': false, 'message': 'Coming soon'});
    expect(await _thrownText(() => repo.getApiCall(url: NetworkUrl.getStateList)), 'Coming soon');
  });

  test('GET 404 HTML page -> plain generic text', () async {
    _answer('states', status: 404, body: '<!DOCTYPE html><html>Not found</html>');
    final text = await _thrownText(() => repo.getApiCall(url: NetworkUrl.getStateList));
    expect(text, _generic);
  });

  test('GET receive timeout -> plain "taking too long"', () async {
    _answer('states', failType: DioExceptionType.receiveTimeout);
    final text = await _thrownText(() => repo.getApiCall(url: NetworkUrl.getStateList));
    expect(text, _slow);
  });

  test('PUT 502 HTML page -> "servers are busy" (used to crash reading message from a String)', () async {
    _answer('customer/profile', status: 502, body: '<html>Bad gateway</html>');
    final text = await _thrownText(() => repo.putApiCall(url: 'customer/profile', body: '{}'));
    expect(text, _busy);
  });

  test("POST 409 business error keeps the server's sentence (unchanged)", () async {
    _answer(NetworkUrl.addBooking, status: 409, body: {'success': false, 'message': 'Only 1 slot left'});
    final text = await _thrownText(() => repo.postApiCall(url: NetworkUrl.addBooking, body: '{}'));
    expect(text, 'Only 1 slot left');
  });

  testWidgets('calculate-fare 503 HTML: the message shown is plain, not "Failed to calculate fare: Exception: ..."', (tester) async {
    final TrekController c = await setUpPumpedController(tester);
    _answer(NetworkUrl.calculateFare, status: 503, body: '<html>Service Unavailable</html>');
    await tester.runAsync(() => c.calculateFare());
    await tester.pump();
    expect(c.errorMessage.value, _busy);
    await tester.pump(const Duration(seconds: 5));
  });
}
