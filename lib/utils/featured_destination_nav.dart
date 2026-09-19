import 'package:arobo_app/models/top_treks_data.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// A Featured Destination card opens the native detail screen instead of
/// the full website (that page-load was slow/laggy) — the trek's numeric
/// id is the last path segment of detailUrl ("`.../treks/<id>`"), extracted
/// here rather than stored on TopTreksData to avoid a freezed-model regen.
///
/// Shared by every screen that renders TopTreksCard from Featured
/// Destinations data (dashboard carousel, Popular Treks grid) so the slug
/// extraction only lives in one place. [onMissingSlug] runs if a card
/// somehow has no usable detailUrl — callers pick their own fallback since
/// "go to Popular Treks" doesn't make sense from Popular Treks itself.
void openFeaturedDestination(TopTreksData trekData, {VoidCallback? onMissingSlug}) {
  final url = trekData.detailUrl ?? '';
  final slug = url.isEmpty
      ? null
      : Uri.tryParse(url)?.pathSegments.lastWhere(
          (s) => s.isNotEmpty,
          orElse: () => '',
        );
  if (slug != null && slug.isNotEmpty) {
    Get.toNamed(
      '/featured-destination',
      arguments: {
        'slug': slug,
        'title': trekData.title,
        'imagePath': trekData.imagePath,
      },
    );
  } else {
    onMissingSlug?.call();
  }
}
