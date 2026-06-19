import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/otp_screen.dart';
import 'auth_controller.dart';

class PhoneNumberController extends GetxController {
  var phoneNumber = TextEditingController().obs;
  var isLoading = false.obs;

  final AuthController _authC = Get.find<AuthController>();

  Future<void> sendCode({required String phoneNumber}) async {
    isLoading.value = true;
    try {
      final success = await _authC.requestOtp(phoneNumber);
      if (success) {
        Get.to(const OTPScreen());
      }
    } finally {
      isLoading.value = false;
    }
  }
}
