import 'dart:convert';

import 'package:arobo_app/main.dart';
import 'package:arobo_app/widgets/logger.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/utils/custom_alert_dialog.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart' hide FormData, Response;

class Repository {
  static final Repository _service = Repository._internal();

  Repository._internal();

  factory Repository() {
    return _service;
  }

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: NetworkUrl.baseUrl,
      connectTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(seconds: 40),
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
      },
    ),
  );

  initRepo() async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          logger.i("➡️ onRequest: URI ->> ${options.uri}");
          logger.d("Headers ->> ${options.headers}");

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
          return handler.next(response);
        },
        onError: (error, handler) async {
          logger.e("❌ onError: Error ->> ${error.error}");
          logger.e("Response ->> ${error.response}");

          // JWT token refresh on 401 — only attempt once per request
          if (error.response?.statusCode == 401 &&
              !(error.requestOptions.extra['_retry'] ?? false)) {
            error.requestOptions.extra['_retry'] = true;
            try {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                // Force-refresh the Firebase ID token
                final newFirebaseToken = await user.getIdToken(true);

                // Exchange for a new backend access token
                final refreshResponse = await dio.post(
                  NetworkUrl.firebaseVerify,
                  data: json.encode({'firebaseIdToken': newFirebaseToken}),
                  options: Options(
                    headers: {'Content-Type': 'application/json'},
                    extra: {'_retry': true},
                  ),
                );

                if (refreshResponse.statusCode == 200 &&
                    refreshResponse.data['success'] == true) {
                  final newToken =
                      refreshResponse.data['data']?['token'] as String?;
                  if (newToken != null && newToken.isNotEmpty) {
                    await sp!.putString(SpUtil.accessToken, newToken);

                    // Retry the original request with the new token
                    error.requestOptions.headers['Authorization'] =
                        'Bearer $newToken';
                    final retryResponse =
                        await dio.fetch(error.requestOptions);
                    return handler.resolve(retryResponse);
                  }
                }
              }
            } catch (refreshError) {
              logger.e("Token refresh failed: $refreshError");
            }

            // Refresh failed — clear session and navigate to login
            await sp!.clear();
            Get.offAllNamed('/');
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> isInternetAvailable() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    } else {
      return false;
    }
  }

  /// Returns per-request [Options] with the current auth token,
  /// avoiding race conditions from mutating shared Dio headers.
  Future<Options> _authOptions({Map<String, dynamic>? extra}) async {
    final String? accessToken = await sp!.getString(SpUtil.accessToken);
    return Options(
      headers: accessToken != null
          ? {'Authorization': 'Bearer $accessToken'}
          : {},
      extra: extra,
    );
  }

  Future<dynamic> getApiCall({required String url}) async {
    bool internetAvailable = await isInternetAvailable();
    try {
      if (internetAvailable) {
        final opts = await _authOptions();
        Response response = await dio.get(url, options: opts);
        return response.data;
      } else {
        showToastMessage(msg: "Please check your internet connection and try.");
        return null;
      }
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
        Response response = await dio.post(url, data: body, options: opts);
        return response.data;
      } else {
        noInternetDialog(onRetry: () {
          postApiCall(url: url, body: body);
        });
        return null;
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection Timeout Exception");
      }
      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Receive Timeout Exception");
      }
      logger.w("Dio Exception Message ->> ${e.message.toString()}");
      logger.w("Dio Exception Data ->> ${e.response?.data?.toString()}");
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
        Response response = await dio.put(url, data: body, options: opts);
        return response.data;
      } else {
        noInternetDialog(onRetry: () {
          putApiCall(url: url, body: body);
        });
        return null;
      }
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
        Response response = await dio.patch(url, data: body, options: opts);
        return response.data;
      } else {
        noInternetDialog(onRetry: () {
          patchApiCall(url: url, body: body);
        });
        return null;
      }
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
        Response response = await dio.delete(url, options: opts);
        return response.data;
      } else {
        noInternetDialog(onRetry: () {
          deleteApiCall(url: url);
        });
        return null;
      }
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
}
