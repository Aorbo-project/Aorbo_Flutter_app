import 'dart:async';
import 'dart:convert';

import 'package:arobo_app/main.dart';
import 'package:arobo_app/widgets/logger.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/utils/custom_alert_dialog.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' hide FormData, Response;

class RateLimitException implements Exception {
  final String message;
  final int waitSeconds;
  const RateLimitException(this.message, this.waitSeconds);
  @override
  String toString() => message;
}

class Repository {
  static final Repository _service = Repository._internal();

  static String token = "";

  Repository._internal();

  factory Repository() {
    return _service;
  }

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: NetworkUrl.baseUrl,
      connectTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(seconds: 40),
      headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
    ),
  );

  // A second Dio with NO interceptors — used to call /auth/refresh and to
  // replay the original request after a refresh, so neither can recurse back
  // into the 401 handler below.
  final Dio _bareDio = Dio(
    BaseOptions(
      baseUrl: NetworkUrl.baseUrl,
      connectTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(seconds: 40),
      headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
    ),
  );

  // Single-flight guard: many requests can 401 at once; only one /refresh call
  // should fire and the rest await its result.
  Completer<bool>? _refreshInFlight;

  /// Exchange the stored refresh token for a fresh access+refresh pair.
  /// Returns true on success (new tokens persisted), false otherwise.
  Future<bool> _refreshAccessToken() async {
    if (_refreshInFlight != null) return _refreshInFlight!.future;
    final completer = Completer<bool>();
    _refreshInFlight = completer;
    try {
      final refresh = await sp!.getString(SpUtil.refreshToken);
      if (refresh == null || refresh.isEmpty) {
        completer.complete(false);
        return false;
      }
      final resp = await _bareDio.post(
        NetworkUrl.refreshTokenPath,
        data: {'refreshToken': refresh},
      );
      final data = resp.data is Map ? (resp.data as Map)['data'] ?? resp.data : null;
      final newAccess = data is Map ? data['token'] as String? : null;
      final newRefresh = data is Map
          ? (data['refreshToken'] ?? data['refresh_token']) as String?
          : null;
      if (newAccess == null || newAccess.isEmpty) {
        completer.complete(false);
        return false;
      }
      await sp!.putString(SpUtil.accessToken, newAccess);
      token = newAccess;
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await sp!.putString(SpUtil.refreshToken, newRefresh);
      }
      completer.complete(true);
      return true;
    } catch (e) {
      logger.w('Token refresh failed: $e');
      completer.complete(false);
      return false;
    } finally {
      _refreshInFlight = null;
    }
  }

  initRepo() async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final curl = _toCurl(options);
          debugPrint("📡 CURL: $curl");
          FirebaseCrashlytics.instance.log(
            'API → ${options.method} ${options.path}',
          );

          if (options.data is FormData) {
            logger.w("Data is FormData");
          } else {
            logger.d("Body ->> ${options.data}");
          }

          return handler.next(options);
        },
        onResponse: (response, handler) async {
          logger.i("✅ onResponse: RealUri ->> ${response.realUri}");
          logger.i("StatusCode ->> ${response.statusCode}");
          logger.d("Data ->> ${response.data}");
          FirebaseCrashlytics.instance.log(
            'API ← ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) async {
          logger.e("❌ onError: Error ->> ${error.error}");
          logger.e("Response ->> ${error.response}");
          FirebaseCrashlytics.instance.log(
            'API ✕ ${error.response?.statusCode} ${error.requestOptions.path}',
          );

          final statusCode = error.response?.statusCode;

          // ✅ Prevent business logic errors (400, 409) from spamming Crashlytics
          final isBusinessError = statusCode == 400 || statusCode == 409;

          if (!isBusinessError) {
            FirebaseCrashlytics.instance.recordError(
              error,
              error.stackTrace,
              reason:
                  'API error: ${error.requestOptions.method} ${error.requestOptions.path}',
              fatal: false,
            );
          }

          final errorCode = (error.response?.data is Map)
              ? (error.response?.data as Map)['code']
              : null;

          // ── Access token expired → try a silent refresh, then replay ──────
          // Only for a genuine expiry (code TOKEN_EXPIRED). Any other 401
          // (revoked, session superseded, bad token) is a real logout.
          final alreadyRetried = error.requestOptions.extra['__retried'] == true;
          final isRefreshCall =
              error.requestOptions.path.contains(NetworkUrl.refreshTokenPath);
          if (statusCode == 401 &&
              errorCode == 'TOKEN_EXPIRED' &&
              !alreadyRetried &&
              !isRefreshCall) {
            final refreshed = await _refreshAccessToken();
            if (refreshed) {
              final ro = error.requestOptions;
              // A FormData body is a single-use stream — it cannot be replayed.
              // The refresh still succeeded, so surface the original error
              // (no logout) and let the caller retry with a fresh body; the
              // stored token is now valid for that retry.
              if (ro.data is FormData) {
                logger.w('Refreshed on TOKEN_EXPIRED; not replaying a FormData '
                    'upload — caller should retry.');
                return handler.next(error);
              }
              ro.extra['__retried'] = true;
              ro.headers['Authorization'] = 'Bearer $token';
              try {
                final replay = await _bareDio.fetch(ro);
                return handler.resolve(replay);
              } catch (e) {
                logger.w('Replay after refresh failed: $e');
                // fall through to logout
              }
            }
            await sp!.clear();
            Get.offAllNamed('/');
            return handler.next(error);
          }

          final isSessionInvalid =
              statusCode == 401 ||
              (statusCode == 403 &&
                  (errorCode == 'ACCOUNT_INACTIVE' ||
                      errorCode == 'INVALID_TOKEN_TYPE'));
          if (isSessionInvalid) {
            await sp!.clear();
            Get.offAllNamed('/');
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> isInternetAvailable() async {
    final List<ConnectivityResult> connectivityResult = await (Connectivity()
        .checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    } else {
      return false;
    }
  }

  Future<Options> _authOptions({Map<String, dynamic>? extra}) async {
    final String? accessToken = await sp!.getString(SpUtil.accessToken);
    token = accessToken ?? "";
    return Options(
      headers: accessToken != null
          ? {'Authorization': 'Bearer $accessToken'}
          : {},
      extra: extra,
    );
  }

  String _toCurl(RequestOptions options) {
    final method = options.method;
    final headers = options.headers.entries
        .map((e) => "-H '${e.key}: ${e.value}'")
        .join(" ");

    String data = "";
    if (options.data != null) {
      if (options.data is Map || options.data is List) {
        data = "-d '${jsonEncode(options.data)}'";
      } else {
        data = "-d '${options.data}'";
      }
    }

    return "curl -X $method $headers $data '${options.uri}'";
  }

  Future<dynamic> getApiCall({required String url}) async {
    bool internetAvailable = await isInternetAvailable();
    try {
      if (internetAvailable) {
        final opts = await _authOptions();
        Response response = await dio
            .get(url, options: opts)
            .timeout(const Duration(seconds: 45));
        return response.data;
      } else {
        showToastMessage(msg: "Please check your internet connection and try.");
        return null;
      }
    } on TimeoutException {
      throw Exception(
        "Request timed out. Please check your connection and try again.",
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection Timeout Exception");
      }
      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Receive Timeout Exception");
      }
      logger.w("Dio Exception Message -> ${e.message.toString()}");
      logger.w("Dio Exception Data -> ${e.response?.data?.toString()}");
      throw Exception(e.message.toString());
    }
  }

  Future<dynamic> postApiCall({required String url, required body}) async {
    bool internetAvailable = await isInternetAvailable();
    try {
      if (internetAvailable) {
        final opts = await _authOptions();
        Response response = await dio
            .post(url, data: body, options: opts)
            .timeout(const Duration(seconds: 45));
        return response.data;
      } else {
        showToastMessage(msg: "Please check your internet connection and try.");
        return null;
      }
    } on TimeoutException {
      throw Exception(
        "Request timed out. Please check your connection and try again.",
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection Timeout Exception");
      }
      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Receive Timeout Exception");
      }
      logger.w("Dio Exception Message ->> ${e.message.toString()}");
      logger.w("Dio Exception Data ->> ${e.response?.data?.toString()}");

      if (e.response?.statusCode == 429 && e.response?.data is Map) {
        final data = e.response!.data as Map;
        final waitSecs = data['wait_seconds'] is int
            ? data['wait_seconds'] as int
            : -1;
        final msg = data['message'] is String
            ? data['message'] as String
            : 'Too many requests. Please wait.';
        throw RateLimitException(msg, waitSecs);
      }

      throw Exception(
        e.response?.data is List &&
                (e.response?.data as List).isNotEmpty &&
                e.response?.data[0] is Map &&
                e.response?.data[0]['message'] is String
            ? e.response?.data[0]['message']
            : e.response?.data is Map && e.response?.data['message'] is String
            ? e.response?.data['message']
            : e.message,
      );
    }
  }

  Future<dynamic> putApiCall({required String url, required body}) async {
    bool internetAvailable = await isInternetAvailable();
    try {
      if (internetAvailable) {
        final opts = await _authOptions();
        Response response = await dio
            .put(url, data: body, options: opts)
            .timeout(const Duration(seconds: 45));
        return response.data;
      } else {
        showToastMessage(msg: "Please check your internet connection and try.");
        return null;
      }
    } on TimeoutException {
      throw Exception(
        "Request timed out. Please check your connection and try again.",
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection Timeout Exception");
      }
      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Receive Timeout Exception");
      }
      logger.w("Dio Exception Message ->> ${e.message.toString()}");
      logger.w("Dio Exception Data ->> ${e.response?.data?.toString()}");
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<dynamic> patchApiCall({required String url, required body}) async {
    bool internetAvailable = await isInternetAvailable();
    try {
      if (internetAvailable) {
        final opts = await _authOptions();
        Response response = await dio
            .patch(url, data: body, options: opts)
            .timeout(const Duration(seconds: 45));
        return response.data;
      } else {
        showToastMessage(msg: "Please check your internet connection and try.");
        return null;
      }
    } on TimeoutException {
      throw Exception(
        "Request timed out. Please check your connection and try again.",
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection Timeout Exception");
      }
      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Receive Timeout Exception");
      }
      logger.w("Dio Exception Message ->> ${e.message.toString()}");
      logger.w("Dio Exception Data ->> ${e.response?.data?.toString()}");
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<dynamic> deleteApiCall({required String url}) async {
    bool internetAvailable = await isInternetAvailable();
    try {
      if (internetAvailable) {
        final opts = await _authOptions();
        Response response = await dio
            .delete(url, options: opts)
            .timeout(const Duration(seconds: 45));
        return response.data;
      } else {
        showToastMessage(msg: "Please check your internet connection and try.");
        return null;
      }
    } on TimeoutException {
      throw Exception(
        "Request timed out. Please check your connection and try again.",
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection Timeout Exception");
      }
      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Receive Timeout Exception");
      }
      logger.w("Dio Exception Message ->> ${e.message.toString()}");
      logger.w("Dio Exception Data ->> ${e.response?.data?.toString()}");
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  // Notify Me: Check Subscription Status
  Future<Map<String, dynamic>?> checkNotifyStatus({
    required int fromCityId,
    required int toTrekId,
  }) async {
    try {
      final response = await getApiCall(
        url: NetworkUrl.notifyStatus(fromCityId, toTrekId),
      );
      return response;
    } catch (e) {
      return null;
    }
  }

  // Notify Me: Subscribe to Route
  Future<Map<String, dynamic>?> subscribeToRoute({
    required int fromCityId,
    required int toTrekId,
  }) async {
    try {
      final String body = json.encode({
        "from_city_id": fromCityId,
        "to_trek_id": toTrekId,
      });
      final response = await postApiCall(
        url: NetworkUrl.notifySubscription,
        body: body,
      );
      return response;
    } catch (e) {
      return null;
    }
  }
}
