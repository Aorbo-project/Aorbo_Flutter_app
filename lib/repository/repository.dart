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
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart' hide FormData, Response;
import 'package:arobo_app/integrity/integrity_interceptor.dart';
import 'package:arobo_app/security/device_key_service.dart';
import 'package:arobo_app/security/pinned_http_client.dart';

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

  // Reported directly (2026-09-23): the app "feels stuck" mid-flow —
  // login, booking success, cancellation, refund — a few seconds at a time.
  // Traced to this client: every one of getApiCall/postApiCall/putApiCall/
  // patchApiCall/deleteApiCall shared a 40s Dio connect/receive timeout
  // PLUS a separate outer .timeout(45s) wrapper — so on any real-world
  // network hiccup (very plausible for a trekking app's users, often on
  // weak signal), a plain login/booking/cancel/refund call — none of which
  // should ever legitimately take more than a few seconds — could leave the
  // screen looking frozen for up to 45 seconds before failing. 20s is
  // already generous for a small JSON payload; uploads (the one FormData
  // caller today: DashboardController.generateAndUploadInvoice) get their
  // own longer override below instead of sharing this tightened default.
  static const Duration _defaultTimeout = Duration(seconds: 20);
  static const Duration _uploadTimeout = Duration(seconds: 60);

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: NetworkUrl.baseUrl,
      connectTimeout: _defaultTimeout,
      receiveTimeout: _defaultTimeout,
      headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
    ),
  );

  // A second Dio with NO interceptors — used to call /auth/refresh and to
  // replay the original request after a refresh, so neither can recurse back
  // into the 401 handler below.
  final Dio _bareDio = Dio(
    BaseOptions(
      baseUrl: NetworkUrl.baseUrl,
      connectTimeout: _defaultTimeout,
      receiveTimeout: _defaultTimeout,
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
      // Device-bound session: prove this is the phone the session belongs to
      // (Backend services/deviceBinding.js). Unbound sessions ignore it.
      final signature = await DeviceKeyService.instance.signRefresh(refresh);
      final resp = await _bareDio.post(
        NetworkUrl.refreshTokenPath,
        data: {'refreshToken': refresh},
        options: Options(headers: {
          if (signature != null) DeviceKeyService.signatureHeader: signature,
        }),
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

  /// (Re)build both clients' TLS layer — at start-up, and again if the
  /// remote pinning switch changes (SecurityConfig).
  void resetHttpClients() {
    PinnedHttp.apply(dio);
    PinnedHttp.apply(_bareDio);
  }

  initRepo() async {
    resetHttpClients();
    // Play Integrity first: it fixes the exact request body it hashes, so it
    // must see options.data before anything else touches it.
    dio.interceptors.add(IntegrityInterceptor());
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (kDebugMode) debugPrint("📡 CURL: ${_toCurl(options)}");
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
            // forcedLogout: true tells SplashWithLoginScreen this is a
            // mid-session kick-out, not a cold app start — it skips the
            // logo entrance/breathing choreography (which is only
            // meaningful for a real launch) and drops straight into the
            // login form instead of replaying ~1s+ of animation the user
            // just sat through moments ago.
            Get.offAllNamed('/', arguments: {'forcedLogout': true});
            return handler.next(error);
          }

          final isSessionInvalid =
              statusCode == 401 ||
              (statusCode == 403 &&
                  (errorCode == 'ACCOUNT_INACTIVE' ||
                      errorCode == 'INVALID_TOKEN_TYPE'));
          if (isSessionInvalid) {
            await sp!.clear();
            Get.offAllNamed('/', arguments: {'forcedLogout': true});
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

  // Never log credentials, even in debug builds: screenshots / shared logs
  // travel further than the developer's own terminal.
  static const Set<String> _secretHeaders = {
    'authorization',
    'x-play-integrity',
    'x-device-signature',
    'cookie',
  };
  static const Set<String> _secretBodyKeys = {
    'token',
    'accessToken',
    'refreshToken',
    'refresh_token',
    'otp',
    'code',
    'fareToken',
    'fare_token',
    'devicePublicKey',
  };

  static Object? _redact(Object? value) {
    if (value is Map) {
      return value.map((k, v) => MapEntry(
            k,
            _secretBodyKeys.contains(k.toString()) ? '[REDACTED]' : _redact(v),
          ));
    }
    if (value is List) return value.map(_redact).toList();
    return value;
  }

  String _toCurl(RequestOptions options) {
    final method = options.method;
    final headers = options.headers.entries
        .map((e) => _secretHeaders.contains(e.key.toLowerCase())
            ? "-H '${e.key}: [REDACTED]'"
            : "-H '${e.key}: ${e.value}'")
        .join(" ");

    String data = "";
    Object? body = options.data;
    if (body is String) {
      try {
        body = jsonDecode(body);
      } catch (_) {}
    }
    if (body != null) {
      data = (body is Map || body is List)
          ? "-d '${jsonEncode(_redact(body))}'"
          : "-d '$body'";
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
            .timeout(_defaultTimeout);
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
        // FormData (file uploads — KYC docs, the generated invoice PDF)
        // legitimately needs more time than a plain JSON call; everything
        // else gets the tightened default so a real hiccup fails fast
        // instead of leaving the screen looking frozen.
        final isUpload = body is FormData;
        final opts = await _authOptions();
        if (isUpload) {
          opts.sendTimeout = _uploadTimeout;
          opts.receiveTimeout = _uploadTimeout;
        }
        Response response = await dio
            .post(url, data: body, options: opts)
            .timeout(isUpload ? _uploadTimeout : _defaultTimeout);
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
            .timeout(_defaultTimeout);
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
            .timeout(_defaultTimeout);
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
            .timeout(_defaultTimeout);
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
