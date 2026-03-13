import 'dart:async';
import 'package:arobo_app/controller/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/custom_snackbar.dart';

class OTPController extends GetxController {
  RxString phoneNumber = "".obs;

  var otpController = TextEditingController().obs;
  var verificationId = ''.obs;
  // RxInt resendToken = 0.obs;
  final AuthController _authC = Get.find<AuthController>();

  RxInt secondsRemaining = 60.obs;
  Timer? timer;
  RxBool enableResend = false.obs;
  bool isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    otpController.value.clear();
    // getArgument();
    // startTimer();
  }

  // getArgument() async {
  //   dynamic argumentData = Get.arguments;
  //   if (argumentData != null) {
  //     phoneNumber.value = argumentData['phoneNumber'];
  //     verificationId.value = argumentData['verificationId'];
  //     resendToken.value = argumentData['resendTokenData'];
  //   }
  // }

  resendOTP() async {
    if (isDisposed) return;
    await sendOTP();
    if (!isDisposed) {
      secondsRemaining.value = 60;
      enableResend.value = false;
      startTimer();
      otpController.value.clear();
    }
  }

  void startTimer() {
    timer?.cancel(); // Cancel any existing timer
    if (isDisposed) return;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isDisposed) {
        timer.cancel();
        return;
      }

      try {
        if (secondsRemaining.value > 0) {
          secondsRemaining.value--;
        } else {
          timer.cancel();
          enableResend.value = true;
        }
      } catch (e) {
        timer.cancel();
      }
    });
  }

  Future<bool> sendOTP() async {
    if (isDisposed) return false;

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber.value,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          if (!isDisposed) {
            CustomSnackBar.show(Get.context!,
                message: e.message ?? "Verification failed");
          }
        },
        codeSent: (String verificationId0, int? resendToken0) async {
          if (!isDisposed) {
            verificationId.value = verificationId0;
            _authC.resendTokenData.value = resendToken0!;
            CustomSnackBar.show(Get.context!, message: "OTP sent");
          }
        },
        timeout: const Duration(seconds: 45),
        forceResendingToken: _authC.resendTokenData.value,
        codeAutoRetrievalTimeout: (String verificationId0) {
          if (!isDisposed) {
            verificationId.value = verificationId0;
          }
        },
      );
      return true;
    } catch (e) {
      if (!isDisposed) {
        CustomSnackBar.show(Get.context!,
            message: "Failed to send OTP. Please try again.");
      }
      return false;
    }
  }

  @override
  void onClose() {
    isDisposed = true;
    timer?.cancel();
    try {
      otpController.value.dispose();
    } catch (e) {
      // Ignore if already disposed
    }
    super.onClose();
  }

  String formatTime() {
    try {
      final minutes = secondsRemaining.value ~/ 60;
      final remainingSeconds = secondsRemaining.value % 60;
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    } catch (e) {
      return '0:00';
    }
  }

  @override
  void onReady() {
    super.onReady();
    ever(secondsRemaining, (_) {
      if (!isDisposed) {
        update();
      }
    });
  }
}
