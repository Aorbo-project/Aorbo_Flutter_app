import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../utils/screen_constants.dart';

/// "28 Oct 2026" from an ISO timestamp (local time).
String formatDeletionDate(String? iso) {
  final d = DateTime.tryParse(iso ?? '')?.toLocal();
  if (d == null) return '';
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

/// Shown right after sign-in when the account is in its 30-day deletion grace
/// period. Returns true = keep the account, false = continue with deletion.
Future<bool> showPendingDeletionDialog(String scheduledForIso) async {
  final date = formatDeletionDate(scheduledForIso);
  final keep = await Get.dialog<bool>(
    PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.w)),
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: const BoxDecoration(color: AppColors.dangerSoft, shape: BoxShape.circle),
                child: const Icon(Icons.schedule_rounded, color: AppColors.danger, size: 28),
              ),
              SizedBox(height: 1.6.h),
              Text(
                'Your account is set to be deleted',
                textAlign: TextAlign.center,
                style: AppType.style(FontSize.s13, w: FontWeight.w700),
              ),
              SizedBox(height: 0.8.h),
              Text(
                date.isEmpty
                    ? 'You asked us to delete this account. Do you want to keep it?'
                    : 'You asked us to delete this account on $date. Do you want to keep it?',
                textAlign: TextAlign.center,
                style: AppType.style(FontSize.s9, color: AppColors.inkMid, height: 1.5),
              ),
              SizedBox(height: 2.4.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(5.5.h),
                    backgroundColor: AppColors.ink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
                  ),
                  child: Text(
                    'Keep my account',
                    style: AppType.style(FontSize.s10, w: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(
                  'Continue with deletion',
                  style: AppType.style(FontSize.s9, w: FontWeight.w600, color: AppColors.danger),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
  return keep ?? true;
}
