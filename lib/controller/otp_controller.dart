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
    if (!isDisposed) {
      if (success) {
        startTimer(); // success — restart at default 60s
      } else if (_authC.resendWaitSeconds.value > 0) {
        // Server said "wait X seconds" — sync the countdown to server's value
        startTimer(seconds: _authC.resendWaitSeconds.value);
        _authC.resendWaitSeconds.value = 0;
      } else if (_authC.resendWaitSeconds.value < 0) {
        // Daily cap hit (backend sent no wait_seconds) — disable resend until page exit
        enableResend.value = false;
        _authC.resendWaitSeconds.value = 0;
      }
      if (success) otpController.value.clear();
    }
  }

  /// Starts (or restarts) the countdown. [seconds] defaults to 60 but can be
  /// overridden with the server-provided [wait_seconds] from a 429 response.
  void startTimer({int seconds = 60}) {
    timer?.cancel();
    if (isDisposed) return;
    secondsRemaining.value = seconds;
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
