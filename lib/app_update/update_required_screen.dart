import 'package:arobo_app/theme/app_typography.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'app_updater.dart';

/// Shown when the server says this build can no longer be used. There is no
/// way back into the app from here: back does nothing, and the only actions
/// are updating or closing the app. Opened by AppUpdateGate, never directly.
class UpdateRequiredScreen extends StatefulWidget {
  const UpdateRequiredScreen({
    super.key,
    this.message,
    this.storeUrl,
    this.updater,
  });

  static const String routeName = '/update-required';

  static const String fallbackMessage =
      'This version of Aorbo is no longer supported. Please update to the '
      'latest version to keep using the app.';

  /// The server's message; [fallbackMessage] when null or blank.
  final String? message;
  final String? storeUrl;

  /// Defaults to [PlayAppUpdater].
  final AppUpdater? updater;

  @override
  State<UpdateRequiredScreen> createState() => _UpdateRequiredScreenState();
}

class _UpdateRequiredScreenState extends State<UpdateRequiredScreen> {
  late final AppUpdater _updater = widget.updater ?? PlayAppUpdater();
  bool _busy = false;
  String? _error;

  String get _message {
    final m = widget.message?.trim();
    return (m == null || m.isEmpty) ? UpdateRequiredScreen.fallbackMessage : m;
  }

  Future<void> _update() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final outcome = await _updater.update(storeUrl: widget.storeUrl);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (outcome == AppUpdateOutcome.failed) {
        _error =
            "Couldn't open the Play Store. Please open it and update "
            'Aorbo from there.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: CommonColors.whiteColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: CommonColors.appYellowColor.withValues(
                        alpha: 0.35,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.system_update_rounded,
                      color: CommonColors.blackColor,
                      size: 12.w,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Update required',
                    textAlign: TextAlign.center,
                    style: AppType.style(
                      FontSize.s18,
                      w: FontWeight.w700,
                      color: CommonColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: AppType.style(
                      FontSize.s11,
                      color: CommonColors.textColor2,
                      height: 1.5,
                    ),
                  ),
                  if (_error != null) ...[
                    SizedBox(height: 1.5.h),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: AppType.style(
                        FontSize.s9,
                        w: FontWeight.w500,
                        color: CommonColors.materialRed,
                        height: 1.4,
                      ),
                    ),
                  ],
                  SizedBox(height: 4.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _update,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(5.8.h),
                        backgroundColor: CommonColors.blackColor,
                        disabledBackgroundColor: CommonColors.blackColor
                            .withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: CommonColors.whiteColor,
                              ),
                            )
                          : Text(
                              'Update now',
                              style: AppType.style(
                                FontSize.s12,
                                w: FontWeight.w700,
                                color: CommonColors.whiteColor,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: Text(
                      'Close app',
                      style: AppType.style(
                        FontSize.s10,
                        w: FontWeight.w500,
                        color: CommonColors.grey600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
