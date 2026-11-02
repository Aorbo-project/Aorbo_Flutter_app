import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';

/// The organiser's Google rating, read live by the server
/// (GET treks/:id/google-rating). Never saved, and never mixed with Aorbo's.
class GoogleRating {
  const GoogleRating({required this.rating, required this.count, required this.url});

  final double rating;
  final int count;
  final Uri url;

  /// Anything malformed means no box. Only an https link is ever opened.
  static GoogleRating? fromJson(Object? json) {
    if (json is! Map) return null;
    final rating = json['rating'];
    final count = json['count'];
    final url = Uri.tryParse('${json['url'] ?? ''}');
    if (rating is! num || count is! int || url == null || url.scheme != 'https') return null;
    return GoogleRating(rating: rating.toDouble(), count: count, url: url);
  }
}

class GoogleRatingBox extends StatelessWidget {
  const GoogleRatingBox({super.key, required this.data});

  final GoogleRating data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(3.w),
      onTap: () => launchUrl(data.url, mode: LaunchMode.externalApplication),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(3.5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(color: const Color(0xFF6B7280).withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Google Maps',
                  textScaler: const TextScaler.linear(1.0),
                  style: AppType.style(10.0.sp, w: FontWeight.w700, color: Colors.black),
                ),
                const Spacer(),
                Icon(Icons.star_rounded, color: Colors.amber, size: 4.5.w),
                SizedBox(width: 1.w),
                Text(
                  '${data.rating} (${data.count})',
                  textScaler: const TextScaler.linear(1.0),
                  style: AppType.style(10.0.sp, w: FontWeight.w700, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              'See reviews on Google  >',
              textScaler: const TextScaler.linear(1.0),
              style: AppType.style(9.0.sp, w: FontWeight.w600, color: AppColors.forest),
            ),
          ],
        ),
      ),
    );
  }
}
