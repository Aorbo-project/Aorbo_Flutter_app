// lib/utils/custom_snackbar.dart
//
// COMPATIBILITY SHIM — the real implementation now lives in
// services/app_feedback.dart. Kept so ~40 existing call sites keep
// compiling unchanged. New code should call AppFeedback.* directly.
//
// The BuildContext parameter is intentionally ignored: the feedback layer
// is overlay-based, which also removes every Get.context! crash risk as
// call sites migrate.

import 'package:flutter/material.dart';
import '../services/app_feedback.dart';

class CustomSnackBar {
  CustomSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    AppFeedback.info(message, duration: duration);
  }

  static void success(String message) => AppFeedback.success(message);
  static void error(String message) => AppFeedback.error(message);
}
