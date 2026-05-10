import 'package:arobo_app/utils/common_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showLoaderDialog() {
  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) {
      return Container(
        color: CommonColors.whiteColor.withValues(alpha: 0.5),
        child: const Center(
          child: CircularProgressIndicator(
            color: CommonColors.appColor,
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
