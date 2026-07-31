// lib/widgets/app_shimmer.dart
//
// Shimmer/skeleton loaders that mimic real layouts so content "pops in"
// instead of jumping from spinner -> content. No external shimmer package
// dependency - built on AnimationController + AppMotion tokens so it's
// consistent with the rest of the motion system.

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../theme/app_tokens.dart';

/// Core shimmer effect - wraps any child, animates a light sweep across it.
/// Use ShimmerBox for simple placeholder blocks, or wrap custom content.
class AppShimmer extends StatefulWidget {
  final Widget child;
  const AppShimmer({super.key, required this.child});

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final dx = _ctrl.value;
            return LinearGradient(
              begin: Alignment(-1.0 - dx * 2, 0),
              end: Alignment(1.0 - dx * 2, 0),
              colors: [
                AppColors.elevated,
                Colors.white.withValues(alpha: 0.9),
                AppColors.elevated,
              ],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Simple rectangular/rounded placeholder block.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Skeleton shaped like a trek card (image + title + subtitle + price row).
/// Use in place of CommonTrekCard while the real list is loading.
class TrekCardSkeleton extends StatelessWidget {
  const TrekCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: double.infinity, height: 18.h, radius: AppRadius.md),
            SizedBox(height: 1.5.h),
            ShimmerBox(width: 60.w, height: 1.8.h),
            SizedBox(height: 1.h),
            ShimmerBox(width: 40.w, height: 1.4.h),
            SizedBox(height: 1.5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 25.w, height: 2.h),
                ShimmerBox(width: 20.w, height: 3.5.h, radius: AppRadius.pill),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A vertical list of trek card skeletons - drop-in replacement for a
/// CircularProgressIndicator while a trek list loads.
class TrekListSkeleton extends StatelessWidget {
  final int count;
  const TrekListSkeleton({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (_) => const TrekCardSkeleton()),
    );
  }
}

/// Skeleton for a simple text line - use inside detail screens where only
/// a label/value pair needs a placeholder (booking summary rows, etc.)
class LineSkeleton extends StatelessWidget {
  final double widthFactor;
  final double height;
  const LineSkeleton({super.key, this.widthFactor = 0.5, this.height = 1.6});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ShimmerBox(width: widthFactor * 100.w, height: height.h),
    );
  }
}
