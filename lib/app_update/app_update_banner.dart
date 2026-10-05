import 'package:arobo_app/theme/app_typography.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'app_update_gate.dart';
import 'app_updater.dart';

/// Small card on the dashboard when a newer build exists (optional), or when
/// a minimum version is announced for a date ("Please update by …"). Closing
/// it hides the optional one until the next build, the announced one for
/// the rest of today. Shows nothing otherwise.
class AppUpdateBanner extends StatelessWidget {
  const AppUpdateBanner({super.key, this.gate, this.updater});

  /// Defaults to [AppUpdateGate.instance].
  final AppUpdateGate? gate;

  /// Defaults to [PlayAppUpdater].
  final AppUpdater? updater;

  @override
  Widget build(BuildContext context) {
    final g = gate ?? AppUpdateGate.instance;
    return Obx(() {
      final banner = g.currentBanner();
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: banner == null
            ? const SizedBox.shrink()
            : _UpdateCard(
                key: ValueKey(banner.kind),
                banner: banner,
                onUpdate: () => (updater ?? PlayAppUpdater()).update(
                  storeUrl: banner.policy.storeUrl,
                ),
                onClose: g.dismissBanner,
              ),
      );
    });
  }
}

class _UpdateCard extends StatelessWidget {
  const _UpdateCard({
    super.key,
    required this.banner,
    required this.onUpdate,
    required this.onClose,
  });

  final UpdateBannerInfo banner;
  final VoidCallback onUpdate;
  final VoidCallback onClose;

  String get _title {
    if (banner.kind == UpdateBannerKind.available) {
      return 'A new version of Aorbo is available';
    }
    final date = banner.deadlineLabel;
    return date == null ? 'Please update Aorbo soon' : 'Please update by $date';
  }

  String get _body {
    final message = banner.policy.updateMessage;
    if (message != null) return message;
    return banner.kind == UpdateBannerKind.available
        ? 'Update for the latest fixes and features.'
        : 'This version will stop working after that.';
  }

  @override
  Widget build(BuildContext context) {
    final urgent = banner.kind == UpdateBannerKind.announced;
    return Material(
      color: CommonColors.whiteColor,
      elevation: 6,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(4.w),
      child: Padding(
        padding: EdgeInsets.fromLTRB(3.5.w, 1.4.h, 1.w, 1.4.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: urgent
                    ? CommonColors.materialOrange.withValues(alpha: 0.15)
                    : CommonColors.appYellowColor.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: Icon(
                urgent ? Icons.event_rounded : Icons.system_update_rounded,
                size: 5.w,
                color: CommonColors.blackColor,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    style: AppType.style(
                      FontSize.s10,
                      w: FontWeight.w700,
                      color: CommonColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    _body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.style(
                      FontSize.s8,
                      color: CommonColors.textColor2,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            TextButton(
              onPressed: onUpdate,
              style: TextButton.styleFrom(
                backgroundColor: CommonColors.blackColor,
                padding: EdgeInsets.symmetric(horizontal: 3.5.w),
                minimumSize: Size(0, 4.h),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.w),
                ),
              ),
              child: Text(
                'Update',
                style: AppType.style(
                  FontSize.s9,
                  w: FontWeight.w700,
                  color: CommonColors.whiteColor,
                ),
              ),
            ),
            IconButton(
              onPressed: onClose,
              tooltip: urgent ? 'Hide for today' : 'Dismiss',
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.close_rounded,
                size: 5.w,
                color: CommonColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
