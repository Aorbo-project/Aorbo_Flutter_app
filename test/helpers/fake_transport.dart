// A fake HTTP transport for the real Repository Dio clients (install with
// `Repository().httpClientAdapterForTesting = transport`): answers by path
// suffix, one scripted step per call (the last step repeats), and records
// every request.

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// One scripted answer: an HTTP reply, or a transport failure ([fail]).
class Step {
  const Step.reply(this.status, this.body) : fail = null;
  const Step.fail(this.fail)
      : status = 0,
        body = null;
  final int status;
  final Object? body;
  final DioExceptionType? fail;
}

class FakeTransport implements HttpClientAdapter {
  final Map<String, List<Step>> steps = {};
  final List<RequestOptions> requests = [];

  List<String> get paths => requests.map((r) => r.path).toList();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    for (final entry in steps.entries) {
      if (options.path.endsWith(entry.key) && entry.value.isNotEmpty) {
        final s = entry.value.length > 1 ? entry.value.removeAt(0) : entry.value.first;
        if (s.fail != null) {
          throw DioException(requestOptions: options, type: s.fail!);
        }
        final isJson = s.body is! String;
        return ResponseBody.fromString(
          isJson ? jsonEncode(s.body) : s.body as String,
          s.status,
          headers: {
            Headers.contentTypeHeader: [
              isJson ? Headers.jsonContentType : 'text/html',
            ],
          },
        );
      }
    }
    return ResponseBody.fromString('{"success":false}', 404, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}
