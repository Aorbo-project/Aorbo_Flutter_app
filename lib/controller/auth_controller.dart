import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:arobo_app/main.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:dio/dio.dart' show Options, DioException;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/auth/validate_version_model.dart';
import '../models/auth/verify_otp_modal.dart';
import '../repository/api_result.dart';
import '../repository/network_url.dart';
import '../repository/repository.dart';
// RateLimitException is defined in repository.dart — no separate import needed
import '../utils/auth_utils.dart';
import '../utils/custom_snackbar.dart';
import '../widgets/logger.dart';
import '../repository/app_env.dart';

class AuthController extends GetxController {
  Repository repository = Repository();
  Rx<VerifyOtpModal> verifyOtpModal = VerifyOtpModal().obs;
  Rx<TextEditingController> phoneNumberLoginTextField = TextEditingController().obs;
  Rx<TextEditingController> otpTextField = TextEditingController().obs;
  RxBool isLoading = false.obs;
  RxBool isProfileLoading = false.obs;
  RxBool isPhoneValid = false.obs;
  // Populated by resendOtp when server returns 429 with wait_seconds
  RxInt resendWaitSeconds = 0.obs;

  bool get isLocalDev {
    final baseUrlStr = AppEnv().apiBaseUrl;
    return baseUrlStr.contains('127.0.0.1') ||
        baseUrlStr.contains('10.0.2.2') ||
        baseUrlStr.contains('localhost');
  }

  final validaVersionObserver = const ApiResult<ValidateVersionResponseModel>.init().obs;

  Future<ValidateDataModel?> validateVersion() async {
    try {
      validaVersionObserver.value = const ApiResult.loading("");
      final version = await AuthUtils.getAppVersion();
      final platform = AuthUtils.getSource();
      final String? validatorResponse = AuthUtils.validateRequestFields(
          ['version'], {"version": version, "platform": platform});
      if (validatorResponse != null) throw validatorResponse;
      final body = await repository.getApiCall(
          url: NetworkUrl.validateVersion(version ?? "1.0.0", platform));
      if (body != null) {
        final responseData = ValidateVersionResponseModel.fromJson(body);
        if (responseData.success == true) {
          validaVersionObserver.value = ApiResult.success(responseData);
          return responseData.data;
        }
        throw responseData.message ?? "something went wrong";
      }
      throw "Response Body Null";
    } catch (e) {
      CustomSnackBar.show(Get.context!, message: e.toString());
      return null;
    }
  }

  // Send OTP to phone via backend (Message Central). Returns true on success.
  // Navigation is the caller's responsibility.
  Future<bool> requestOtp(String phone) async {
    isProfileLoading.value = true;
    try {
      final body = json.encode({'phone': phone});
      final res = await repository.postApiCall(url: NetworkUrl.loginPath, body: body);
      isProfileLoading.value = false;
      if (res != null && res['success'] == true) {
        return true;
      }
      CustomSnackBar.show(Get.context!,
          message: res?['message'] ?? 'Failed to send OTP. Please try again.');
      return false;
    } catch (e) {
      isProfileLoading.value = false;
      CustomSnackBar.show(Get.context!, message: 'Failed to send OTP. Please try again.');
      return false;
    }
  }

  // Resend OTP to the same phone. Shows a snack bar on success/failure.
  // Returns true on success. On RateLimitException, sets [resendWaitSeconds]
  // so OTPController can sync its countdown timer to the server's value.
  Future<bool> resendOtp(String phone) async {
    resendWaitSeconds.value = 0;
    try {
      final body = json.encode({'phone': phone});
      final res = await repository.postApiCall(url: NetworkUrl.resendOtpPath, body: body);
      if (res != null && res['success'] == true) {
        CustomSnackBar.show(Get.context!, message: res['message'] ?? 'OTP sent');
        return true;
      }
      CustomSnackBar.show(Get.context!,
          message: res?['message'] ?? 'Failed to resend OTP. Please try again.');
      return false;
    } on RateLimitException catch (e) {
      resendWaitSeconds.value = e.waitSeconds;
      CustomSnackBar.show(Get.context!, message: e.message);
      return false;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      CustomSnackBar.show(Get.context!, message: msg.isNotEmpty ? msg : 'Failed to resend OTP. Please try again.');
      return false;
    }
  }

  // Persistent per-install id (not a true hardware device id) so the admin's
  // "Logins & Devices" view can tell "same phone logging in again" apart
  // from a new install — same pattern as the vendor/admin web session log.
  Future<String> _getOrCreateDeviceId() async {
    final existing = sp!.getString(SpUtil.deviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final generated =
        'dev-${DateTime.now().millisecondsSinceEpoch}-${(1000 + (DateTime.now().microsecondsSinceEpoch % 9000))}';
    await sp!.putString(SpUtil.deviceId, generated);
    return generated;
  }

  // Verify OTP with backend. Stores JWT and registers FCM on success. Returns true on success.
  Future<bool> verifyOtp(String phone, String otp) async {
    isLoading.value = true;
    try {
      final deviceId = await _getOrCreateDeviceId();
      final source = AuthUtils.getSource();
      final platform = (source == 'android' || source == 'ios') ? 'mobile_$source' : source;
      final deviceModel = await AuthUtils.getDeviceModel();
      final osVersion = await AuthUtils.getOsVersion();
      final appVersion = await AuthUtils.getAppVersion();
      final body = json.encode({
        'phone': phone,
        'otp': otp,
        'device_id': deviceId,
        'platform': platform,
        'device_model': deviceModel,
        'os_version': osVersion,
        'app_version': appVersion,
      });
      final res = await repository.postApiCall(url: NetworkUrl.verifyOtpPath, body: body);
      isLoading.value = false;
      if (res != null && res['success'] == true) {
        try {
          verifyOtpModal.value = VerifyOtpModal.fromJson(res);
          final token = verifyOtpModal.value.data?.token;
          if (token == null || token.isEmpty) {
            CustomSnackBar.show(Get.context!, message: 'Invalid token received');
            return false;
          }
          final customer = verifyOtpModal.value.data?.customer;
          await sp!.putString(SpUtil.accessToken, token);
          final refreshToken = verifyOtpModal.value.data?.refreshToken;
          if (refreshToken != null && refreshToken.isNotEmpty) {
            await sp!.putString(SpUtil.refreshToken, refreshToken);
          } else {
            // backend without refresh support — make sure no stale one lingers
            await sp!.remove(SpUtil.refreshToken);
          }
          await sp!.putBool(SpUtil.isLoggedIn, true);
          await sp!.putInt(SpUtil.userID, customer?.id ?? 0);
          // Store profile completion state so the app can prompt new/incomplete users
          await sp!.putBool(SpUtil.profileCompleted, customer?.profileCompleted ?? false);
          await sp!.putBool(SpUtil.isNewCustomer, customer?.isNewCustomer ?? false);
          FirebaseCrashlytics.instance.setUserIdentifier(
            customer?.id?.toString() ?? '',
          );
          registerFcmToken();
          return true;
        } catch (parseError) {
          logger.e('Error parsing auth response: $parseError');
          CustomSnackBar.show(Get.context!, message: 'Error processing server response');
          return false;
        }
      }
      // Surface backend error message (includes "X attempts remaining" and 429 messages)
      CustomSnackBar.show(Get.context!,
          message: res?['message'] ?? 'OTP verification failed');
      return false;
    } on RateLimitException catch (e) {
      isLoading.value = false;
      CustomSnackBar.show(Get.context!, message: e.message);
      return false;
    } catch (e) {
      isLoading.value = false;
      logger.e('verifyOtp error: $e');
      final msg = e.toString().replaceFirst('Exception: ', '');
      CustomSnackBar.show(Get.context!, message: msg.isNotEmpty ? msg : 'Verification failed. Please try again.');
      return false;
    }
  }

  // Splash-gate check: confirms the cached session is still accepted by the
  // server BEFORE splash_screen.dart routes into the authenticated app.
  // Previously splash trusted the local isLoggedIn flag alone and routed to
  // /dashboard optimistically; a stale/invalidated token only surfaced once
  // the dashboard's own calls (or registerFcmToken below) hit the 401
  // interceptor in repository.dart — which then yanked the user back to
  // login a beat after dashboard had already rendered (the splash→dashboard
  // →login flicker). This makes that check happen first, while still on
  // splash, so dashboard is only ever shown once the session is confirmed.
  //
  // Fails OPEN on anything that isn't an explicit 401/403 rejection — a
  // timeout or dropped connection is not proof the session is dead and must
  // never force a still-valid session to log out.
  Future<bool> validateSession() async {
    try {
      final accessToken = sp!.getString(SpUtil.accessToken);
      final response = await repository.dio
          .get(
            NetworkUrl.getUserProfile,
            options: Options(
              headers: accessToken != null
                  ? {'Authorization': 'Bearer $accessToken'}
                  : {},
            ),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      return statusCode != 401 && statusCode != 403;
    } catch (_) {
      return true;
    }
  }

  // Fire-and-forget: register FCM token with backend after successful auth,
  // whenever Firebase rotates the token (see main.dart's onTokenRefresh
  // listener), and on every app open for an already-logged-in session (see
  // splash_screen.dart's checkUserLogin branch) — a session that never
  // logs in again (the common case once profileCompleted) would otherwise
  // never get a second chance to register a token that failed once.
  //
  // Retries a few times with backoff for transient failures (no internet,
  // timeout, 5xx) since those resolve on their own; does NOT retry on 4xx
  // (bad request/unauthenticated) since retrying the same call won't fix that.
  // If every attempt fails, `fcmTokenSynced` is left stale/absent on purpose
  // so the very next app open or token refresh tries again — nothing is
  // silently given up on forever.
  //
  // Errors are non-fatal — user is already logged in regardless of outcome.
  Future<void> registerFcmToken([String? tokenOverride]) async {
    try {
      final fcmToken = tokenOverride ?? await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      // Already confirmed synced for this exact token — skip the network call.
      if (sp?.getString(SpUtil.fcmTokenSynced) == fcmToken) return;

      final platform = Platform.isIOS ? 'ios' : 'android';
      const backoff = [Duration.zero, Duration(seconds: 3), Duration(seconds: 8)];

      for (var attempt = 0; attempt < backoff.length; attempt++) {
        if (attempt > 0) await Future.delayed(backoff[attempt]);
        try {
          final res = await repository.postApiCall(
            url: NetworkUrl.deviceToken,
            body: json.encode({'device_token': fcmToken, 'platform': platform}),
          );
          if (res != null && res['success'] == true) {
            await sp?.putString(SpUtil.fcmTokenSynced, fcmToken);
            logger.d('FCM token registered (attempt ${attempt + 1})');
            return;
          }
          logger.w('FCM token registration returned non-success response: $res');
        } catch (e) {
          final msg = e.toString();
          // Auth/validation errors won't be fixed by retrying the same request.
          final isRetryable = !msg.contains('401') && !msg.contains('Unauthorized');
          logger.e('FCM token registration attempt ${attempt + 1} failed: $e');
          if (!isRetryable) return;
        }
      }
      logger.e('FCM token registration failed after ${backoff.length} attempts — will retry on next app open or token refresh');
    } catch (e) {
      logger.e('FCM token registration setup failed: $e');
    }
  }

  @override
  void onClose() {
    phoneNumberLoginTextField.value.dispose();
    otpTextField.value.dispose();
    super.onClose();
  }
}
