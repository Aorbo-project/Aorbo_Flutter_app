import 'dart:async';
import 'dart:convert';

import 'package:arobo_app/app_update/app_update_gate.dart';
import 'package:arobo_app/app_update/app_update_policy.dart';
import 'package:arobo_app/app_update/app_version_info.dart';
import 'package:arobo_app/main.dart';
import 'package:arobo_app/widgets/logger.dart';
import 'package:arobo_app/repository/friendly_error.dart';
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
import 'package:arobo_app/services/session_teardown.dart';

export 'package:arobo_app/repository/friendly_error.dart'
    show ApiException, FriendlyText, friendlyError, isFriendlyText;

class RateLimitException implements Exception {
  final String message;
  final int waitSeconds;
  /// OTP endpoints: the code already sent to this number is still valid.
  final bool otpActive;
  const RateLimitException(this.message, this.waitSeconds, {this.otpActive = false});
  @override
  String toString() => message;
}

/// What a token refresh came to. Only [sessionOver] may sign the user out:
/// a network drop, timeout or server error while refreshing leaves the
/// refresh token perfectly good, so the next request just tries again.
/// [updateRequired]: the server refuses this build (426 / 403
/// APP_UPDATE_REQUIRED) — the session is fine, the app must be updated.
enum RefreshOutcome { refreshed, sessionOver, transientFailure, updateRequired }

/// A refresh that failed with [error]: "update this app" is never a logout;
/// the server rejecting the refresh token (400/401/403) ends the session;
/// anything else (no connection, timeout, 5xx, 429) is transient.
@visibleForTesting
RefreshOutcome refreshOutcomeForError(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (isAppUpdateRequired(status, error.response?.data)) {
      return RefreshOutcome.updateRequired;
    }
    if (status == 400 || status == 401 || status == 403) return RefreshOutcome.sessionOver;
  }
  return RefreshOutcome.transientFailure;
}

/// The server refused this build: show the "Update required" screen (once).
/// Never a logout, never a retry, never a Crashlytics report.
void _blockForUpdate(dynamic body) {
  final block = AppUpdateBlock.fromBody(body);
  AppUpdateGate.instance.forceBlock(
    message: block.message,
    storeUrl: block.storeUrl,
  );
}

/// After a successful refresh the original request is replayed once. Only a
/// 401 on that replay means the session is over; any other failure (a 409
/// "slot full", a timeout, ...) is that request's own result for the caller.
@visibleForTesting
bool replayFailureEndsSession(Object error) =>
    error is DioException && error.response?.statusCode == 401;

/// A device-bound login must never send an unsigned refresh — the backend
/// treats that as a stolen token and ends the session. When signing fails
/// (e.g. a slow keystore), hold the refresh instead and let the next request
/// try again. [bound] is null for logins made before this was recorded.
@visibleForTesting
bool holdUnsignedRefresh({required bool? bound, required String? signature}) =>
    bound == true && signature == null;

/// Set to true on a failed request's `RequestOptions.extra` by the 401/403
/// handler in [Repository.initRepo] when IT ended the session (the server
/// refused it: a non-renewable 401, a refused refresh token, a 403
/// ACCOUNT_INACTIVE). Scan E8: the splash gate signs the user out only on this
/// verdict — a refresh that timed out / got a 5xx / a 429 keeps the session.
const String sessionEndedExtra = 'aorbo_session_ended';

/// Did the network layer end the session while handling [error]?
bool sessionEndedByServer(DioException error) =>
    error.requestOptions.extra[sessionEndedExtra] == true;

/// Request flag: if the server refuses the session on this request, clear it
/// but do not navigate — the caller (the Logout button) does that itself.
const String noSignOutNavigationExtra = 'aorbo_no_signout_navigation';

/// A server reply kept whole — see [Repository.postForReply].
class ApiReply {
  const ApiReply(this.statusCode, this.data);
  final int statusCode;
  final dynamic data;

  bool get ok => statusCode >= 200 && statusCode < 300 && data is Map && data['success'] == true;
  Map<String, dynamic> get json => data is Map ? Map<String, dynamic>.from(data as Map) : const {};
}

/// A conditional GET's reply — see [Repository.getIfChanged].
class ConditionalReply {
  const ConditionalReply({required this.notModified, this.data, this.etag});

  /// 304: the copy whose ETag was sent is still current; [data] is null.
  final bool notModified;

  /// The decoded body of a 2xx reply.
  final dynamic data;

  /// The reply's ETag header; null when the server sent none.
  final String? etag;
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

  // X-App-Version / X-App-Build / X-App-Platform go on every request of
  // both clients (header-only, so it never disturbs the Play Integrity body).
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: NetworkUrl.baseUrl,
      connectTimeout: _defaultTimeout,
      receiveTimeout: _defaultTimeout,
      headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
    ),
  )..interceptors.add(AppVersionHeadersInterceptor());

  // A second Dio with no error handling — used to call /auth/refresh and to
  // replay the original request after a refresh, so neither can recurse back
  // into the 401 handler below. Its only interceptor adds the version headers.
  final Dio _bareDio = Dio(
    BaseOptions(
      baseUrl: NetworkUrl.baseUrl,
      connectTimeout: _defaultTimeout,
      receiveTimeout: _defaultTimeout,
      headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
    ),
  )..interceptors.add(AppVersionHeadersInterceptor());

  // Single-flight guard: many requests can 401 at once; only one /refresh call
  // should fire and the rest await its result.
  Completer<RefreshOutcome>? _refreshInFlight;

  /// Exchange the stored refresh token for a fresh access+refresh pair.
  Future<RefreshOutcome> _refreshAccessToken() async {
    if (_refreshInFlight != null) return _refreshInFlight!.future;
    final completer = Completer<RefreshOutcome>();
    _refreshInFlight = completer;
    var outcome = RefreshOutcome.transientFailure;
    try {
      final refresh = await sp!.getString(SpUtil.refreshToken);
      if (refresh == null || refresh.isEmpty) {
        outcome = RefreshOutcome.sessionOver;
        return outcome;
      }
      // Device-bound session: prove this is the phone the session belongs to
      // (Backend services/deviceBinding.js). Unbound sessions ignore it.
      final bound = sp!.getBool(SpUtil.sessionDeviceBound);
      var signature = await DeviceKeyService.instance.signRefresh(refresh);
      if (holdUnsignedRefresh(bound: bound, signature: signature)) {
        signature = await DeviceKeyService.instance.signRefresh(refresh);
        if (holdUnsignedRefresh(bound: bound, signature: signature)) {
          logger.w('Refresh held: device signature unavailable');
          return outcome; // transient — never send an unsigned bound refresh
        }
      }
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
        return outcome; // unexpected reply shape — transient, keep the session
      }
      await sp!.putString(SpUtil.accessToken, newAccess);
      token = newAccess;
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await sp!.putString(SpUtil.refreshToken, newRefresh);
      }
      outcome = RefreshOutcome.refreshed;
      return outcome;
    } catch (e) {
      logger.w('Token refresh failed: $e');
      outcome = refreshOutcomeForError(e);
      if (outcome == RefreshOutcome.updateRequired && e is DioException) {
        _blockForUpdate(e.response?.data);
      }
      return outcome;
    } finally {
      completer.complete(outcome);
      _refreshInFlight = null;
    }
  }

  /// (Re)build both clients' TLS layer — at start-up, and again if the
  /// remote pinning switch changes (SecurityConfig).
  void resetHttpClients() {
    PinnedHttp.apply(dio);
    PinnedHttp.apply(_bareDio);
  }

  /// Tests: send both clients (incl. the refresh/replay one) through a fake
  /// transport.
  @visibleForTesting
  set httpClientAdapterForTesting(HttpClientAdapter adapter) {
    dio.httpClientAdapter = adapter;
    _bareDio.httpClientAdapter = adapter;
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
            _debugLog(() => "Data is FormData");
          } else {
            _debugLog(() => "Body ->> ${_clip(options.data)}");
          }

          return handler.next(options);
        },
        onResponse: (response, handler) async {
          _debugLog(() => "✅ onResponse: ${response.realUri} "
              "(${response.statusCode}) Data ->> ${_clip(response.data)}");
          FirebaseCrashlytics.instance.log(
            'API ← ${response.statusCode} ${response.requestOptions.path}',
          );
          // Callers with their own validateStatus (postForReply) receive a
          // 426 / 403 as a response rather than an error.
          if (isAppUpdateRequired(response.statusCode, response.data)) {
            _blockForUpdate(response.data);
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          _debugLog(() => "❌ onError: ${error.error} "
              "Response ->> ${_clip(error.response)}");

          final statusCode = error.response?.statusCode;

          // ── This build is too old (426, or 403 APP_UPDATE_REQUIRED) ──────
          // Not a session problem and not a crash: show the update screen,
          // and skip the Crashlytics report, the refresh and the logout.
          if (isAppUpdateRequired(statusCode, error.response?.data)) {
            _blockForUpdate(error.response?.data);
            return handler.next(error);
          }

          FirebaseCrashlytics.instance.log(
            'API ✕ ${error.response?.statusCode} ${error.requestOptions.path}',
          );

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
            final outcome = await _refreshAccessToken();
            if (outcome == RefreshOutcome.transientFailure ||
                outcome == RefreshOutcome.updateRequired) {
              // Couldn't renew right now (no connection, timeout, server
              // error, keystore busy). The session itself is fine: keep the
              // user signed in — this request fails, the next one renews.
              // updateRequired: /refresh refused this build — the update
              // screen is already up, and it is never a logout.
              return handler.next(error);
            }
            if (outcome == RefreshOutcome.refreshed) {
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
                if (e is DioException &&
                    isAppUpdateRequired(
                        e.response?.statusCode, e.response?.data)) {
                  _blockForUpdate(e.response?.data);
                  return handler.next(e);
                }
                if (!replayFailureEndsSession(e)) {
                  // That request's own failure (a 409, a timeout, ...) — the
                  // session was just renewed, so give the caller that error.
                  return handler.next(e is DioException ? e : error);
                }
              }
            }
            error.requestOptions.extra[sessionEndedExtra] = true;
            // Scan E2/E3: the same teardown as the Logout button (stored
            // session, push token, device key); the previous person's
            // controllers are dropped at the next sign-in.
            await SessionTeardown.clearLocalSession();
            // forcedLogout: true tells SplashWithLoginScreen this is a
            // mid-session kick-out, not a cold app start — it skips the
            // logo entrance/breathing choreography (which is only
            // meaningful for a real launch) and drops straight into the
            // login form instead of replaying ~1s+ of animation the user
            // just sat through moments ago. Never away from the update
            // screen, though.
            _goToSignIn(error.requestOptions);
            return handler.next(error);
          }

          final isSessionInvalid =
              statusCode == 401 ||
              (statusCode == 403 &&
                  (errorCode == 'ACCOUNT_INACTIVE' ||
                      errorCode == 'INVALID_TOKEN_TYPE'));
          if (isSessionInvalid) {
            error.requestOptions.extra[sessionEndedExtra] = true;
            await SessionTeardown.clearLocalSession();
            _goToSignIn(error.requestOptions);
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// Scan D10: these lines used to interpolate every response body (the
  /// 346 KB city list included) into a String on EVERY call, in release too
  /// — the logger drops the line in release, but only after the String was
  /// built. Now debug-only, built lazily and cut to 2 KB.
  static void _debugLog(String Function() message) {
    if (kDebugMode) logger.d(message());
  }

  static String _clip(Object? value) {
    final s = '$value';
    return s.length <= 2048 ? s : '${s.substring(0, 2048)}… (${s.length} chars)';
  }

  /// After the server ended the session: back to the sign-in form — never
  /// away from the update screen, and not when the caller navigates itself.
  void _goToSignIn(RequestOptions request) {
    if (AppUpdateGate.instance.isBlocked) return;
    if (request.extra[noSignOutNavigationExtra] == true) return;
    Get.offAllNamed('/', arguments: {'forcedLogout': true});
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
      throw const ApiException(FriendlyText.tooSlow);
    } on DioException catch (e) {
      throw _failure(e);
    }
  }

  /// The error every call throws for a failed request: text fit for the
  /// customer (the server's own message when it is one, never Dio's
  /// developer paragraph — scan D5), with the status kept for callers.
  ApiException _failure(DioException e) {
    _debugLog(() => "Dio Exception Message -> ${e.message}");
    _debugLog(() => "Dio Exception Data -> ${_clip(e.response?.data)}");
    return ApiException.fromDio(e);
  }

  /// A conditional GET: sends `If-None-Match: [etag]` when one is given, and
  /// returns a 304 as [ConditionalReply.notModified] instead of an error
  /// (Dio throws on a 304 by default — only this call accepts it). Otherwise
  /// the same as [getApiCall]: null when offline, the same exceptions.
  Future<ConditionalReply?> getIfChanged({
    required String url,
    String? etag,
  }) async {
    bool internetAvailable = await isInternetAvailable();
    try {
      if (!internetAvailable) {
        showToastMessage(msg: "Please check your internet connection and try.");
        return null;
      }
      final opts = await _authOptions();
      if (etag != null && etag.isNotEmpty) {
        opts.headers = {...?opts.headers, 'If-None-Match': etag};
      }
      opts.validateStatus = (s) => s != null && (s < 300 || s == 304);
      final Response response = await dio
          .get(url, options: opts)
          .timeout(_defaultTimeout);
      final notModified = response.statusCode == 304;
      return ConditionalReply(
        notModified: notModified,
        data: notModified ? null : response.data,
        etag: response.headers.value('etag'),
      );
    } on TimeoutException {
      throw const ApiException(FriendlyText.tooSlow);
    } on DioException catch (e) {
      throw _failure(e);
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
      throw const ApiException(FriendlyText.tooSlow);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429 && e.response?.data is Map) {
        final data = e.response!.data as Map;
        final waitSecs = data['wait_seconds'] is int
            ? data['wait_seconds'] as int
            : -1;
        final msg = data['message'] is String
            ? data['message'] as String
            : 'Too many requests. Please wait.';
        throw RateLimitException(msg, waitSecs, otpActive: data['otp_active'] == true);
      }
      throw _failure(e);
    }
  }

  /// POST that returns the server's status + JSON body for 2xx AND 4xx
  /// replies instead of throwing, so the caller can act on the reply's
  /// `code` (e.g. the giveaway's `rules_changed`). 401 still throws, so the
  /// silent session refresh runs as usual; 5xx / network / timeout throw.
  Future<ApiReply> postForReply({
    required String url,
    Object? body,
    Map<String, String>? headers,
  }) async {
    if (!await isInternetAvailable()) {
      throw const ApiException(FriendlyText.noInternet);
    }
    final opts = await _authOptions();
    opts.headers = {...?opts.headers, ...?headers};
    opts.validateStatus = (s) => s != null && s < 500 && s != 401;
    try {
      final response = await dio
          .post(url, data: body, options: opts)
          .timeout(_defaultTimeout);
      return ApiReply(response.statusCode ?? 0, response.data);
    } on TimeoutException {
      throw const ApiException(FriendlyText.tooSlow);
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
      throw const ApiException(FriendlyText.tooSlow);
    } on DioException catch (e) {
      throw _failure(e);
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
      throw const ApiException(FriendlyText.tooSlow);
    } on DioException catch (e) {
      throw _failure(e);
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
      throw const ApiException(FriendlyText.tooSlow);
    } on DioException catch (e) {
      throw _failure(e);
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
