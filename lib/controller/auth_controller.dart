import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:arobo_app/main.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
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
      final body = json.encode({'phone': phone, 'otp': otp, 'device_id': deviceId, 'platform': platform});
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
          await sp!.putBool(SpUtil.isLoggedIn, true);
          await sp!.putInt(SpUtil.userID, customer?.id ?? 0);
          // Store profile completion state so the app can prompt new/incomplete users
          await sp!.putBool(SpUtil.profileCompleted, customer?.profileCompleted ?? false);
          await sp!.putBool(SpUtil.isNewCustomer, customer?.isNewCustomer ?? false);
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

  // Fire-and-forget: register FCM token with backend after successful auth.
  // Errors are non-fatal — user is already logged in.
  Future<void> registerFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;
      final platform = Platform.isIOS ? 'ios' : 'android';
      await repository.postApiCall(
        url: NetworkUrl.deviceToken,
        body: json.encode({'device_token': fcmToken, 'platform': platform}),
      );
      logger.d('FCM token registered');
    } catch (e) {
      logger.e('FCM token registration failed: $e');
    }
  }
}
