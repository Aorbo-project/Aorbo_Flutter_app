import 'package:arobo_app/utils/common_colors.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_ai/shimmer_ai.dart';
import 'dart:ui';

import '../utils/common_images.dart';

class CustomNetworkImage extends StatelessWidget {
  final String? accessToken;
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color? color;
  final double? borderRadius;
  final bool showProgress;
  final bool hasTransparentBackground;
  final bool showShadow;
  final double? shadowOffset;
  final double? shadowBlurSigma;
  final Color? shadowColor;

  const CustomNetworkImage({
    super.key,
    this.accessToken,
    required this.imageUrl,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.color,
    this.borderRadius,
    this.showProgress = true,
    this.hasTransparentBackground = false, // Default to false
    this.showShadow = false,
    this.shadowOffset,
    this.shadowBlurSigma,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    // For transparent background images, return without shadow
    if (hasTransparentBackground) {
      return _buildImageWithTransparency();
    }

    // For images with background and optional shadow
    if (showShadow) {
      return _buildImageWithShadow();
    }

    // Default: simple image without shadow
    return _buildBaseImage();
  }

  Widget _buildBaseImage() {

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 8),
      child: CachedNetworkImage(
        httpHeaders: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Authorization' :'Bearer $accessToken'
        },
        imageUrl: imageUrl,
        fit: fit,
        cacheKey: imageUrl,
        width: width,
        height: height,
        color: color,
        // // Memory optimization
        // memCacheHeight: height?.toInt(),
        // memCacheWidth: width?.toInt(),
        // Smooth animations
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 200),
        progressIndicatorBuilder: (context, url, loadingProgress) => Center(
          child: Visibility(
            visible: showProgress,
            child: (width == null || height == null)
                ? CircularProgressIndicator(
              color: CommonColors.primaryColor,
              backgroundColor: CommonColors.primaryColor,
              value: loadingProgress.progress,
            )
                : Container(
              height: height ?? 10,
              width: width ?? 10,
              decoration: BoxDecoration(
                color: CommonColors.greyColorEBEBEB,
                borderRadius: BorderRadius.circular(borderRadius ?? 0),
              ),
            ).withShimmerAi(loading: true),
          ),
        ),
        errorWidget: (context, url, error) => Image.asset(
          CommonImages.logo4,
          height: height ?? 10,
          width: width ?? 10,
          fit: fit,
        ),
      ),
    );
  }

  Widget _buildImageWithTransparency() {
    // For transparent images - no background, clean rendering
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        cacheKey: imageUrl,
        width: width,
        height: height,
        color: color,
        // Critical for transparent images - use contain to preserve alpha channel
        // memCacheHeight: height?.toInt(),
        // memCacheWidth: width?.toInt(),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 200),
        // Don't apply any background color to transparent images
        progressIndicatorBuilder: (context, url, loadingProgress) => Center(
          child: Visibility(
            visible: showProgress,
            child: (width == null || height == null)
                ? CircularProgressIndicator(
              color: CommonColors.primaryColor,
              backgroundColor: CommonColors.primaryColor,
              value: loadingProgress.progress,
            )
                : Container(
              height: height ?? 10,
              width: width ?? 10,
              decoration: BoxDecoration(
                color: CommonColors.greyColorEBEBEB,
                borderRadius: BorderRadius.circular(borderRadius ?? 0),
              ),
            ).withShimmerAi(loading: true),
          ),
        ),
        errorWidget: (context, url, error) => Image.asset(
          CommonImages.logo4,
          height: height ?? 10,
          width: width ?? 10,
          fit: fit,
        ),
      ),
    );
  }

  Widget _buildImageWithShadow() {
    // For images that need a shadow effect (like your original KnowMoreCard)
    final shadowOffsetValue = shadowOffset ?? 4.0;
    final blurSigmaValue = shadowBlurSigma ?? 4.0;
    final shadowColorValue = shadowColor ?? Colors.black.withValues(alpha: 0.45);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Shadow layer with blur
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(0, shadowOffsetValue),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: blurSigmaValue, sigmaY: blurSigmaValue),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    shadowColorValue,
                    BlendMode.srcATop,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: fit,
                    cacheKey: '${imageUrl}_shadow',
                    width: width,
                    height: height,
                    memCacheHeight: height?.toInt(),
                    memCacheWidth: width?.toInt(),
                    // Don't show progress for shadow to avoid flicker
                    progressIndicatorBuilder: (context, url, progress) => const SizedBox.shrink(),
                    errorWidget: (context, url, error) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Main image
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: fit,
            cacheKey: imageUrl,
            width: width,
            height: height,
            color: color,
            memCacheHeight: height?.toInt(),
            memCacheWidth: width?.toInt(),
            fadeInDuration: const Duration(milliseconds: 300),
            fadeOutDuration: const Duration(milliseconds: 200),
            progressIndicatorBuilder: (context, url, loadingProgress) => Center(
              child: Visibility(
                visible: showProgress,
                child: (width == null || height == null)
                    ? CircularProgressIndicator(
                  color: CommonColors.primaryColor,
                  backgroundColor: CommonColors.primaryColor,
                  value: loadingProgress.progress,
                )
                    : Container(
                  height: height ?? 10,
                  width: width ?? 10,
                  decoration: BoxDecoration(
                    color: CommonColors.greyColorEBEBEB,
                    borderRadius: BorderRadius.circular(borderRadius ?? 0),
                  ),
                ).withShimmerAi(loading: true),
              ),
            ),
            errorWidget: (context, url, error) => Image.asset(
              CommonImages.logo4,
              height: height ?? 10,
              width: width ?? 10,
              fit: fit,
            ),
          ),
        ),
      ],
    );
  }
}