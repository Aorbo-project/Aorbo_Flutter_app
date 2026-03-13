import 'package:arobo_app/repository/network_url.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CommonImageCard extends StatelessWidget {
  final List<String> images; // Can be network URLs, asset paths, or file paths
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsets? padding;
  final BoxFit? fit;

  const CommonImageCard({
    super.key,
    required this.images,
    this.width = 180,
    this.height = 150,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.only(left: 16),
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius!),
              child: _buildImage(images[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(String image) {
    final url =
        '${NetworkUrl.imageUrl}${image.startsWith('/') ? image.substring(1) : image}';
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildLoadingPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius!),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius!),
      ),
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}
