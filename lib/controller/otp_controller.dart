import 'dart:async';
import 'package:arobo_app/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/custom_snackbar.dart';

class OTPController extends GetxController {
  var otpController = TextEditingController().obs;
  final AuthController _authC = Get.find<AuthController>();

  RxInt secondsRemaining = 60.obs;
  Timer? timer;
  RxBool enableResend = false.obs;
  bool isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    otpController.value.clear();
    startTimer();
  }

  Future<void> resendOTP() async {
    if (isDisposed) return;
    final success = await sendOTP();
    if (!isDisposed && success) {
      startTimer(); // resets secondsRemaining and enableResend internally
      otpController.value.clear();
    }
  }

  void startTimer() {
    timer?.cancel();
    if (isDisposed) return;
    secondsRemaining.value = 60;
    enableResend.value = false;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (isDisposed) {
        t.cancel();
        return;
      }
      try {
        if (secondsRemaining.value > 0) {
          secondsRemaining.value--;
        } else {
          t.cancel();
          enableResend.value = true;
        }
      } catch (e) {
        t.cancel();
      }
    });
  }

  Future<bool> sendOTP() async {
    if (isDisposed) return false;
    try {
      final phone = _authC.phoneNumberLoginTextField.value.text;
      return await _authC.resendOtp(phone);
    } catch (e) {
      if (!isDisposed) {
        CustomSnackBar.show(Get.context!, message: 'Failed to send OTP. Please try again.');
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
      // already disposed
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
      if (!isDisposed) update();
    });
  }
}
