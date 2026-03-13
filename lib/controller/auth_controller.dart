import 'dart:async';
import 'dart:convert';

import 'package:arobo_app/main.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/auth/verify_otp_modal.dart';
import '../repository/network_url.dart';
import '../repository/repository.dart';
import '../utils/custom_snackbar.dart';
import '../widgets/logger.dart';

class AuthController extends GetxController {
  Repository repository = Repository();
  Rx<VerifyOtpModal> verifyOtpModal = VerifyOtpModal().obs;
  Rx<TextEditingController> phoneNumberLoginTextField =
      TextEditingController().obs;
  Rx<TextEditingController> otpTextField = TextEditingController().obs;
  RxBool isLoading = false.obs;
  RxBool isProfileLoading = false.obs;
  RxBool isPhoneValid = false.obs;
  var resendTokenData = 0.obs;
  RxString idToken = ''.obs;
  RxString verificationIdData = ''.obs;

  String formattedPhoneNumber({required String phoneNumber}) {
    final number = phoneNumber.trim();
    if (number.startsWith('+91')) return number;
    return '+91$number';
  }

  Future<void> getIdToken() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? token = await user.getIdToken();
        if (token != null) {
          idToken.value = token;
        }
      }
    } catch (e) {
      logger.e("Error getting ID token: $e");
    }
  }

  sendCode({required String phoneNumber}) async {
    try {
      isProfileLoading.value = true;
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber(phoneNumber: phoneNumber),
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          isProfileLoading.value = false;
          if (e.code == 'invalid-phone-number') {
            CustomSnackBar.show(
              Get.context!,
              message: "The provided phone number is not valid.",
            );
          } else {
            CustomSnackBar.show(
              Get.context!,
              message: e.message ?? "Verification failed",
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          isLoading.value = false;
          isProfileLoading.value = false;
          resendTokenData.value = resendToken ?? 0;
          verificationIdData.value = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        forceResendingToken: resendTokenData.value,
      );
    } catch (error) {
      isLoading.value = false;
      CustomSnackBar.show(
        Get.context!,
        message: "You have tried many times. Please try again after some time.",
      );
    }
  }

  Future<bool> verifyFirebaseToken(String firebaseToken) async {
    isLoading.value = true;

    String body = json.encode({
      'firebaseIdToken': firebaseToken,
    });

    try {
      var res = await repository.postApiCall(
          url: NetworkUrl.firebaseVerify, body: body);

      isLoading.value = false;

      if (res != null && res['success'] == true) {
        try {
          verifyOtpModal.value = VerifyOtpModal.fromJson(res);

          final token = verifyOtpModal.value.data?.token;
          if (token == null || token.isEmpty) {
            CustomSnackBar.show(Get.context!,
                message: "Invalid token received");
            return false;
          }

          await sp!.putString(SpUtil.accessToken, token);
          await sp!.putBool(SpUtil.isLoggedIn, true);
          await sp!.putInt(SpUtil.userID, verifyOtpModal.value.data?.customer?.id ?? 0);

          return true;
        } catch (parseError) {
          logger.e('Error parsing auth response: $parseError');
          CustomSnackBar.show(Get.context!,
              message: "Error processing server response");
          return false;
        }
      } else {
        CustomSnackBar.show(Get.context!,
            message: res != null && res['message'] != null
                ? res['message']
                : "Server verification failed");
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      logger.e("Firebase verification error: $e");
      CustomSnackBar.show(Get.context!,
          message: "Network error: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneNumberLoginTextField.value.dispose();
    otpTextField.value.dispose();
    super.onClose();
  }
}
