// Responsive matrix coverage for the shared, high-reuse building blocks.
// These widgets appear on dozens of screens, so an overflow here is an
// overflow everywhere. Pure-widget tests — no GetX / network / Firebase.
//
// Run:  flutter test test/responsive/shared_widgets_responsive_test.dart
//
// A failure prints every (device @scale) combination that overflowed and by
// how much — that list is the fix worklist, not a reason to panic.

import 'package:arobo_app/freezed_models/treks/trek_detail_model.dart'
    show Badge, BatchInfo, CancellationPolicy;
import 'package:arobo_app/freezed_models/treks/treks_model_data.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:arobo_app/utils/common_btn.dart';
import 'package:arobo_app/utils/common_trek_card.dart';
import 'package:flutter_test/flutter_test.dart';

import 'responsive_harness.dart';

void main() {
  group('CommonButton', () {
    testWidgets('short label — full width', (tester) async {
      final failures = await collectResponsiveOverflows(
        tester,
        build: () => CommonButton(text: 'Continue', onPressed: () {}),
      );
      expectNoResponsiveOverflow(failures);
    });

    testWidgets('long label — realistic worst case', (tester) async {
      final failures = await collectResponsiveOverflows(
        tester,
        build: () => CommonButton(
          text: 'Proceed to payment confirmation',
          onPressed: () {},
          prefixIcon: const Icon(Icons.lock, size: 16),
        ),
      );
      expectNoResponsiveOverflow(failures);
    });

    testWidgets('non-full-width with icons', (tester) async {
      final failures = await collectResponsiveOverflows(
        tester,
        build: () => Align(
          alignment: Alignment.center,
          child: CommonButton(
            text: 'Download invoice',
            onPressed: () {},
            isFullWidth: false,
            suffixIcon: const Icon(Icons.download, size: 16),
          ),
        ),
      );
      expectNoResponsiveOverflow(failures);
    });
  });

  group('CommonTrekCard', () {
    TrekData trek({
      String? name,
      String? destination,
      String? company,
      String? badge,
      String? duration,
      String? discountText,
      bool discount = false,
      int available = 4,
      int capacity = 20,
    }) {
      return TrekData(
        id: 1,
        name: name ?? 'Hampta Pass',
        destination: destination ?? 'Manali',
        companyName: company ?? 'Aorbo Adventures',
        vendor: company ?? 'Aorbo Adventures',
        vendorLogo: null,
        // triggers the initials-avatar path, no network image in tests
        rating: 4.6,
        price: '12,499',
        duration: duration ?? '5D / 4N',
        hasDiscount: discount,
        discountText: discountText,
        badge: Badge(name: badge ?? 'Best Seller'),
        batchInfo: BatchInfo(
          startDate: '12 Oct',
          startTime: '6:00 AM',
          availableSlots: available,
          capacity: capacity,
        ),
        cancellationPolicy: const CancellationPolicy(
          title: 'Flexible Cancellation Policy',
        ),
      );
    }

    testWidgets('typical trek', (tester) async {
      final failures = await collectResponsiveOverflows(
        tester,
        build: () => CommonTrekCard(trek: trek(), onTap: () {}),
      );
      expectNoResponsiveOverflow(failures);
    });

    testWidgets('long names + discount + low slots (worst case)', (tester) async {
      final failures = await collectResponsiveOverflows(
        tester,
        build: () => CommonTrekCard(
          trek: trek(
            name: 'Kedarkantha Winter Summit Expedition via Sankri',
            destination: 'Sankri, Uttarkashi, Uttarakhand',
            company: 'Himalayan High Altitude Trekking Company Pvt Ltd',
            badge: 'Limited Seats — Filling Fast',
            duration: '6 Days / 5 Nights',
            discount: true,
            discountText: '25% OFF',
            available: 2,
            capacity: 20,
          ),
          showShare: true,
          onTap: () {},
        ),
      );
      expectNoResponsiveOverflow(failures);
    });

    testWidgets('new vendor (no rating) + minimal data', (tester) async {
      final failures = await collectResponsiveOverflows(
        tester,
        build: () => CommonTrekCard(
          trek: TrekData(
            id: 2,
            name: 'Weekend Trek',
            destination: 'Kunti Betta',
            companyName: 'New Trails',
            rating: 0,
            price: '1,999',
            duration: '1D',
            badge: const Badge(name: ''),
            batchInfo: BatchInfo(
              startDate: '20 Oct',
              startTime: '5:30 AM',
              availableSlots: 0,
              capacity: 0,
            ),
          ),
          onTap: () {},
        ),
      );
      expectNoResponsiveOverflow(failures);
    });
  });
}
