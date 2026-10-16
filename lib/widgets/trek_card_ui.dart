import 'package:flutter/material.dart';
import 'package:arobo_app/utils/common_trek_card.dart';
import 'package:arobo_app/freezed_models/treks/treks_model_data.dart';
import 'package:arobo_app/freezed_models/treks/trek_detail_model.dart'
    show CancellationPolicy, BatchInfo;
import 'package:arobo_app/freezed_models/treks/trek_detail_model.dart'
    as trek_model
    show Badge;
import 'package:arobo_app/utils/trek_discount.dart';

// ─────────────────────────────────────────────
// REUSABLE TREK CARD UI
//
// This used to be a second, hand-rolled card layout living alongside
// CommonTrekCard (the one used on the search/listing screens). That meant
// two separate implementations to keep visually in sync. This widget is
// now a thin adapter: it keeps the exact same public API that
// TravellerInformationScreen and BookingDraftService's resume sheet
// already call, but internally builds a TrekData and renders the real
// CommonTrekCard - so every call site automatically gets the same card.
// ─────────────────────────────────────────────
class TrekCardUI extends StatelessWidget {
  final String title;
  final String vendorName;
  final bool isFlexible;
  final String badgeText;
  final String durationText;
  final double? rating;
  final String departure;
  final int availableSlots;
  final int totalCapacity;
  final String price;
  final VoidCallback? onContinue;
  final String? imageUrl;
  final String? vendorLogo;

  /// The vendor discount (trekDiscountedPrice). When given, the card shows
  /// the discounted price with the base struck through — the same as the
  /// search card. [price] is then ignored.
  final TrekDiscountedPrice? discount;

  const TrekCardUI({
    super.key,
    required this.title,
    required this.vendorName,
    required this.isFlexible,
    required this.badgeText,
    required this.durationText,
    this.rating,
    required this.departure,
    required this.availableSlots,
    required this.totalCapacity,
    required this.price,
    this.onContinue,
    this.imageUrl,
    this.vendorLogo,
    this.discount,
  });

  @override
  Widget build(BuildContext context) {
    final trek = TrekData(
      name: title,
      destination: title,
      vendor: vendorName,
      vendorName: vendorName,
      companyName: vendorName,
      rating: rating,
      // CommonTrekCard re-formats price itself (AuthUtils.formatPrice),
      // so strip any currency symbol/commas the caller already applied
      // (e.g. "₹12,345") before handing it over - otherwise the ₹ /
      // separators get applied twice.
      price: discount != null ? _plain(discount!.price) : price.replaceAll(RegExp(r'[^\d.]'), ''),
      duration: durationText,
      hasDiscount: discount?.hasDiscount == true,
      discountText: discount?.hasDiscount == true ? discount!.label : null,
      imageUrl: imageUrl,
      vendorLogo: vendorLogo,
      badge: badgeText.isEmpty ? null : trek_model.Badge(name: badgeText),
      cancellationPolicy: CancellationPolicy(
        // CommonTrekCard/TravellerInformationScreen both key off
        // policy.id == 5 to mean "flexible" - match that convention here.
        id: isFlexible ? 5 : 1,
        title: isFlexible
            ? 'Flexible Cancellation Policy'
            : 'Standard Cancellation Policy',
      ),
      batchInfo: BatchInfo(
        startDate: departure,
        // No separate start-time value is passed into this widget by
        // either call site - CommonTrekCard degrades gracefully to just
        // the date when startTime is null.
        startTime: null,
        availableSlots: availableSlots,
        capacity: totalCapacity,
      ),
    );

    return CommonTrekCard(
      trek: trek,
      onTap: onContinue,
      onViewItineraryTap: onContinue,
    );
  }

  /// 7101.0 -> "7101", 7101.5 -> "7101.50" (CommonTrekCard formats it).
  static String _plain(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}
