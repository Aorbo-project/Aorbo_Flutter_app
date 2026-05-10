import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/otp_screen.dart';
import '../utils/custom_snackbar.dart';

class PhoneNumberController extends GetxController {
  var phoneNumber = TextEditingController().obs;
  var resendTokenData = 0.obs;
  var isLoading = false.obs;
  RxString idToken = ''.obs;

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
      log("Error getting ID token: $e");
    }
  }

  sendCode({required String phoneNumber}) async {
    try {
      isLoading.value = true;
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber(phoneNumber: phoneNumber),
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
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
          resendTokenData.value = resendToken ?? 0;
          Get.to(
            const OTPScreen(),
            arguments: {
              'phoneNumber': formattedPhoneNumber(phoneNumber: phoneNumber),
              'verificationId': verificationId,
              'resendTokenData': resendTokenData.value,
            },
          );
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
}
