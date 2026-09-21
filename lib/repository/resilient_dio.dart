import 'package:arobo_app/repository/get_retry_interceptor.dart';
import 'package:arobo_app/repository/hedging_http_client_adapter.dart';
import 'package:dio/dio.dart';

/// Adds the GET-only network resilience stack to [dio] (idempotent):
///  * [GetRetryInterceptor] — 5 s connect / 8 s first-byte, ≤2 retries on
///    transport failures and gateway errors;
///  * [HedgingHttpClientAdapter] — one duplicate GET after 2 s of silence,
///    first answer wins.
/// Never affects POST/PUT/PATCH/DELETE or downloads. Safe to call twice.
Dio makeResilient(Dio dio) {
  if (!dio.interceptors.any((i) => i is GetRetryInterceptor)) {
    dio.interceptors.add(GetRetryInterceptor(dio));
  }
  if (dio.httpClientAdapter is! HedgingHttpClientAdapter) {
    dio.httpClientAdapter = HedgingHttpClientAdapter(dio.httpClientAdapter);
  }
  return dio;
}
