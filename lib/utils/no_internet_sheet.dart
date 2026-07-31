// lib/utils/no_internet_sheet.dart
//
// Animated no-internet bottom sheet matching the app's forest/teal theme.
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';

class NoInternetSheet {
  NoInternetSheet._();

  static OverlayEntry? _overlayEntry;
  static StreamSubscription<List<ConnectivityResult>>? _subscription;
  static bool _isShowing = false;

  /// Call this from any screen's initState to start monitoring connectivity.
  /// Automatically shows the bottom sheet when offline and dismisses when online.
  static void startMonitoring(BuildContext context) {
    _subscription?.cancel();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final bool isOffline = results.contains(ConnectivityResult.none);
      if (isOffline && !_isShowing) {
        show(context);
      } else if (!isOffline && _isShowing) {
        dismiss();
      }
    });
  }

  static void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
    dismiss();
  }

  static void show(BuildContext context) {
    if (_isShowing) return;
    _isShowing = true;
    _overlayEntry = OverlayEntry(
      builder: (ctx) => _NoInternetAnimatedSheet(
        onRetry: () {
          // Trigger a connectivity check
          Connectivity().checkConnectivity();
        },
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  static void dismiss() {
    if (!_isShowing) return;
    _isShowing = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _NoInternetAnimatedSheet extends StatefulWidget {
  final VoidCallback onRetry;
  const _NoInternetAnimatedSheet({required this.onRetry});

  @override
  State<_NoInternetAnimatedSheet> createState() =>
      _NoInternetAnimatedSheetState();
}

class _NoInternetAnimatedSheetState extends State<_NoInternetAnimatedSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _wifiAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _wifiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Auto-dismiss after checking connectivity
    _checkAndDismiss();
  }

  Future<void> _checkAndDismiss() async {
    await Future.delayed(const Duration(seconds: 3));
    final results = await Connectivity().checkConnectivity();
    if (!results.contains(ConnectivityResult.none) && mounted) {
      _dismiss();
    }
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        NoInternetSheet.dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value * 300),
              child: Opacity(opacity: _fadeAnimation.value, child: child),
            );
          },
          child: _buildSheet(),
        ),
      ),
    );
  }

  Widget _buildSheet() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 3.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 10.w,
            height: 0.5.h,
            margin: EdgeInsets.only(bottom: 2.h),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Animated WiFi icon
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.95 + (0.05 * _wifiAnimation.value),
                child: child,
              );
            },
            child: Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: AppColors.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing ring
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Container(
                        width: 18.w * (0.8 + 0.2 * _wifiAnimation.value),
                        height: 18.w * (0.8 + 0.2 * _wifiAnimation.value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.danger.withValues(
                              alpha: 0.3 * (1 - _wifiAnimation.value),
                            ),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  ),
                  // WiFi off icon
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 9.w,
                    color: AppColors.danger,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.5.h),
          // Title
          Text(
            'No Internet Connection',
            style: AppType.style(
              14,
              w: FontWeight.w800,
              color: AppColors.inkStrong,
            ),
          ),
          SizedBox(height: 1.h),
          // Subtitle
          Text(
            'Please check your network settings\nand try again',
            textAlign: TextAlign.center,
            style: AppType.style(10, color: AppColors.inkMid, height: 1.5),
          ),
          SizedBox(height: 3.h),
          // Retry button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onRetry();
                _checkAndDismiss();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Retry',
                style: AppType.style(
                  12,
                  w: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forest,
                padding: EdgeInsets.symmetric(vertical: 1.6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.w),
                ),
                elevation: 0,
              ),
            ),
          ),
          SizedBox(height: 1.5.h),
          // Dismiss link
          GestureDetector(
            onTap: _dismiss,
            child: Text(
              'Dismiss',
              style: AppType.style(
                10,
                w: FontWeight.w600,
                color: AppColors.inkMid,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.inkMid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
