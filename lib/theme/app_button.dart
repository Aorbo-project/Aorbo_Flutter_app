// lib/theme/app_button.dart
//
// Centralized button family for new/refactored screens. Built entirely on
// AppColors / AppType / AppRadius / AppGradients so a theme change (e.g.
// dark mode) only touches app_tokens.dart, never this file.
//
// This is additive: it does NOT replace existing CommonButton call sites.
// Migrating a screen means swapping CommonButton(...) for one of these.

import 'package:flutter/material.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

enum AppButtonVariant { primary, secondary, text, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height = 48,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height = 48,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height = 48,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.text({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height = 44,
  }) : variant = AppButtonVariant.text;

  const AppButton.danger({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height = 48,
  }) : variant = AppButtonVariant.danger;

  bool get _disabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.md);
    final content = _Content(
      text: text,
      variant: variant,
      isLoading: isLoading,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = _GradientSurface(
          gradient: AppGradients.cta,
          radius: radius,
          disabled: _disabled,
          shadowColor: AppColors.forest,
          onTap: _disabled ? null : onPressed,
          child: content,
        );
        break;
      case AppButtonVariant.danger:
        button = _GradientSurface(
          gradient: AppGradients.dangerHold,
          radius: radius,
          disabled: _disabled,
          shadowColor: AppColors.danger,
          onTap: _disabled ? null : onPressed,
          child: content,
        );
        break;
      case AppButtonVariant.secondary:
        button = _OutlinedSurface(
          radius: radius,
          disabled: _disabled,
          onTap: _disabled ? null : onPressed,
          child: content,
        );
        break;
      case AppButtonVariant.text:
        button = _TextSurface(
          radius: radius,
          disabled: _disabled,
          onTap: _disabled ? null : onPressed,
          child: content,
        );
        break;
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: AnimatedOpacity(
        duration: AppMotion.fast,
        opacity: _disabled && !isLoading ? 0.55 : 1.0,
        child: button,
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final String text;
  final AppButtonVariant variant;
  final bool isLoading;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const _Content({
    required this.text,
    required this.variant,
    required this.isLoading,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isFilled =
        variant == AppButtonVariant.primary || variant == AppButtonVariant.danger;
    final textColor = isFilled
        ? Colors.white
        : (variant == AppButtonVariant.text ? AppColors.forest : AppColors.ink);

    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefixIcon != null) ...[prefixIcon!, const SizedBox(width: 8)],
        Text(
          text,
          textScaler: const TextScaler.linear(1.0),
          style: AppType.style(13, w: FontWeight.w700, color: textColor),
        ),
        if (suffixIcon != null) ...[const SizedBox(width: 8), suffixIcon!],
      ],
    );
  }
}

class _GradientSurface extends StatelessWidget {
  final LinearGradient gradient;
  final BorderRadius radius;
  final bool disabled;
  final Color shadowColor;
  final VoidCallback? onTap;
  final Widget child;

  const _GradientSurface({
    required this.gradient,
    required this.radius,
    required this.disabled,
    required this.shadowColor,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: disabled ? null : AppShadows.cta(shadowColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(gradient: gradient, borderRadius: radius),
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            splashColor: Colors.white.withValues(alpha: 0.15),
            highlightColor: Colors.transparent,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _OutlinedSurface extends StatelessWidget {
  final BorderRadius radius;
  final bool disabled;
  final VoidCallback? onTap;
  final Widget child;

  const _OutlinedSurface({
    required this.radius,
    required this.disabled,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.forest, width: 1.4),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _TextSurface extends StatelessWidget {
  final BorderRadius radius;
  final bool disabled;
  final VoidCallback? onTap;
  final Widget child;

  const _TextSurface({
    required this.radius,
    required this.disabled,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Center(child: child),
      ),
    );
  }
}
