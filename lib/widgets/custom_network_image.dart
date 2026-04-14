import 'package:arobo_app/utils/common_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_ai/shimmer_ai.dart';

import '../utils/common_images.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color? color;
  final double? borderRadius;
  final bool showProgress;
  const CustomNetworkImage(
      {super.key,
        required this.imageUrl,
        this.fit = BoxFit.contain,
        this.width,
        this.height,
        this.color,
        this.borderRadius,
        this.showProgress = true,
      });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        cacheKey: imageUrl,
        width: width,
        height: height,
        color: color,
        progressIndicatorBuilder: (context, url, loadingProgress) => Center(
            child: Visibility(
              visible: showProgress,
              child: width == null || height == null ? CircularProgressIndicator(
                color: CommonColors.primaryColor,
                backgroundColor: CommonColors.primaryColor,
                value: loadingProgress.progress,
              ) :
              Container(
                height: height ?? 10,
                width: width ?? 10,
                decoration: BoxDecoration(
                  color: CommonColors.greyColorEBEBEB,
                  borderRadius: BorderRadius.circular(borderRadius ?? 0),
                ),
              ).withShimmerAi(loading: true)
            )),
        errorWidget: (context, url, error) =>  Image.asset(
          CommonImages.logo4,
          height: height ?? 10,
          width: width ?? 10,
        ),
      ),
    );
  }
}
