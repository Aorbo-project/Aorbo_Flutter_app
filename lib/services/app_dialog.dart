// lib/services/app_dialog.dart
//
// Unified dialog + bottom-sheet layer, matching AppFeedback's design
// language (tokens, motion, haptics). One API for confirm dialogs and
// action sheets so new screens stop hand-rolling showDialog/showModalBottomSheet
// with inconsistent styling.
//
// AppDialog.confirm(...)  -> Yes/No style confirmation, returns bool
// AppDialog.alert(...)    -> single-button informational dialog
// AppSheet.show(...)      -> generic bottom sheet wrapper with consistent
//                            handle/padding/rounded-top styling

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';

class AppDialog {
  AppDialog._();

  /// Shows a confirm/cancel dialog. Returns true if confirmed, false/null otherwise.
  static Future<bool?> confirm({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool danger = false,
  }) {
    HapticFeedback.selectionClick();
    final accent = danger ? AppColors.danger : AppColors.forest;
    return Get.dialog<bool>(
      _AppDialogShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppType.style(16, w: FontWeight.w700, color: AppColors.inkStrong),
            ),
            SizedBox(height: 1.2.h),
            Text(
              message,
              style: AppType.style(12.5, color: AppColors.inkMid, height: 1.4),
            ),
            SizedBox(height: 2.4.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(result: false),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.4.h),
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      cancelLabel,
                      style: AppType.style(12.5, w: FontWeight.w600, color: AppColors.inkMid),
                    ),
                  ),
                ),
                SizedBox(width: AppSpace.hMd),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      padding: EdgeInsets.symmetric(vertical: 1.4.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      confirmLabel,
                      style: AppType.style(12.5, w: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Single-button informational dialog (errors, notices).
  static Future<void> alert({
    required String title,
    required String message,
    String buttonLabel = 'OK',
  }) {
    HapticFeedback.selectionClick();
    return Get.dialog<void>(
      _AppDialogShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppType.style(16, w: FontWeight.w700, color: AppColors.inkStrong),
            ),
            SizedBox(height: 1.2.h),
            Text(
              message,
              style: AppType.style(12.5, color: AppColors.inkMid, height: 1.4),
            ),
            SizedBox(height: 2.4.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  padding: EdgeInsets.symmetric(vertical: 1.4.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonLabel,
                  style: AppType.style(12.5, w: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppDialogShell extends StatelessWidget {
  final Widget child;
  const _AppDialogShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSpace.gutter),
      child: Container(
        padding: EdgeInsets.all(AppSpace.hLg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card(),
        ),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  BOTTOM SHEET
// ─────────────────────────────────────────────
class AppSheet {
  AppSheet._();

  /// Generic bottom sheet wrapper: consistent handle, rounded top,
  /// padding, and safe-area handling. Pass your own content builder.
  static Future<T?> show<T>({
    required Widget child,
    bool isScrollControlled = true,
    bool showHandle = true,
  }) {
    HapticFeedback.selectionClick();
    return Get.bottomSheet<T>(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: AppSpace.hLg,
          right: AppSpace.hLg,
          top: 1.5.h,
          bottom: 2.h,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHandle) ...[
                Container(
                  width: 10.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                SizedBox(height: 1.5.h),
              ],
              child,
            ],
          ),
        ),
      ),
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
    );
  }
}
