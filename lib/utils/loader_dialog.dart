import 'package:arobo_app/utils/common_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showLoaderDialog() {
  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) {
      // canPop: false — barrierDismissible only blocks tap-outside; without
      // this, the hardware/gesture back button still pops this dialog route
      // while the underlying network call keeps running, leaving the user
      // staring at a screen with no spinner but a request still in flight.
      return PopScope(
        canPop: false,
        child: Container(
          color: CommonColors.whiteColor.withValues(alpha: 0.5),
          child: const Center(
            child: CircularProgressIndicator(
              color: CommonColors.appColor,
            ),
          ),
        ),
      );
    },
  );
}

void hideLoaderDialog() {
  // Future.delayed(Duration.zero, () {
  try {
    Navigator.of(Get.context!).pop(true);
  } catch (e) {
    // Ignore pop errors (dialog may already be dismissed)
  }
  // });
}
