// lib/services/app_feedback.dart
//
// Unified feedback layer: one API for success/error/warning/info toasts,
// overlay-based (no BuildContext, no Get.context! NPEs), queued, deduped,
// swipe-to-dismiss, with haptics baked in.
//
// CustomSnackBar.show(...) delegates here, so all existing call sites keep
// working. New code calls AppFeedback.* directly.

import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';

enum FeedbackKind { success, error, warning, info }

class _FeedbackRequest {
  final String message;
  final FeedbackKind kind;
  final Duration duration;
  const _FeedbackRequest(this.message, this.kind, this.duration);
}

class AppFeedback {
  AppFeedback._();

  static final Queue<_FeedbackRequest> _queue = Queue();
  static OverlayEntry? _entry;
  static bool _busy = false;
  static String? _lastMessage;
  static DateTime _lastAt = DateTime.fromMillisecondsSinceEpoch(0);

  static void success(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) => _enqueue(message, FeedbackKind.success, duration);

  static void error(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) => _enqueue(message, FeedbackKind.error, duration);

  static void warning(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) => _enqueue(message, FeedbackKind.warning, duration);

  static void info(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) => _enqueue(message, FeedbackKind.info, duration);

  /// Clears everything (e.g. on logout).
  static void dismissAll() {
    _queue.clear();
    _entry?.remove();
    _entry = null;
    _busy = false;
  }

  // ── internals ──────────────────────────────
  static void _enqueue(String message, FeedbackKind kind, Duration duration) {
    final msg = message.replaceFirst('Exception: ', '').trim();
    if (msg.isEmpty) return;
    // Collapse rapid duplicates (double-taps, retry loops).
    if (msg == _lastMessage &&
        DateTime.now().difference(_lastAt) < const Duration(seconds: 1)) {
      return;
    }
    _lastMessage = msg;
    _lastAt = DateTime.now();
    _queue.add(_FeedbackRequest(msg, kind, duration));
    _drain();
  }

  static void _drain() {
    if (_busy || _queue.isEmpty) return;
    final ctx = Get.overlayContext;
    final overlay = ctx == null
        ? null
        : Overlay.maybeOf(ctx, rootOverlay: true);
    if (overlay == null) {
      // App not ready — never crash for a toast.
      debugPrint('AppFeedback (no overlay): ${_queue.removeFirst().message}');
      return;
    }
    _busy = true;
    final req = _queue.removeFirst();
    _haptic(req.kind);
    _entry = OverlayEntry(
      builder: (_) => _FeedbackToast(
        request: req,
        onDone: () {
          _entry?.remove();
          _entry = null;
          _busy = false;
          _drain(); // show next queued toast, if any
        },
      ),
    );
    overlay.insert(_entry!);
  }

  static void _haptic(FeedbackKind kind) {
    switch (kind) {
      case FeedbackKind.success:
        HapticFeedback.lightImpact();
      case FeedbackKind.error:
        HapticFeedback.heavyImpact();
      case FeedbackKind.warning:
        HapticFeedback.mediumImpact();
      case FeedbackKind.info:
        HapticFeedback.selectionClick();
    }
  }
}

// ─────────────────────────────────────────────
//  TOAST WIDGET
// ─────────────────────────────────────────────
class _FeedbackToast extends StatefulWidget {
  final _FeedbackRequest request;
  final VoidCallback onDone;
  const _FeedbackToast({required this.request, required this.onDone});

  @override
  State<_FeedbackToast> createState() => _FeedbackToastState();
}

class _FeedbackToastState extends State<_FeedbackToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _timer;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppMotion.medium);
    _slide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: AppMotion.easeOut,
            reverseCurve: AppMotion.easeIn,
          ),
        );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _timer = Timer(widget.request.duration, _exit);
  }

  Future<void> _exit() async {
    if (_finished || !mounted) return;
    await _ctrl.reverse();
    _finish();
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    widget.onDone();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  ({Color accent, Color soft, IconData icon}) get _look {
    switch (widget.request.kind) {
      case FeedbackKind.success:
        return (
          accent: AppColors.success,
          soft: AppColors.successSoft,
          icon: Icons.check_circle_rounded,
        );
      case FeedbackKind.error:
        return (
          accent: AppColors.danger,
          soft: AppColors.dangerSoft,
          icon: Icons.error_rounded,
        );
      case FeedbackKind.warning:
        return (
          accent: AppColors.warning,
          soft: AppColors.warningSoft,
          icon: Icons.warning_amber_rounded,
        );
      case FeedbackKind.info:
        return (
          accent: AppColors.forest,
          soft: AppColors.forestSoft,
          icon: Icons.info_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final look = _look;
    return Positioned(
      left: AppSpace.gutter,
      right: AppSpace.gutter,
      bottom: 3.h,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Material(
              color: Colors.transparent,
              child: Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.horizontal,
                onDismissed: (_) {
                  _timer?.cancel();
                  _finish();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpace.hLg,
                    vertical: 1.4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: look.accent.withValues(alpha: 0.25),
                    ),
                    boxShadow: AppShadows.card(),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: look.soft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(look.icon, color: look.accent, size: 4.5.w),
                      ),
                      SizedBox(width: AppSpace.hMd),
                      Expanded(
                        child: Text(
                          widget.request.message,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.style(
                            FontSizeCompat.s10,
                            w: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Local alias so this file doesn't hard-depend on screen_constants import
/// ordering; forwards to your existing FontSize.
class FontSizeCompat {
  static double get s10 => 10.sp;
}
