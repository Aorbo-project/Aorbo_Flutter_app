// Responsive matrix coverage for the remaining shared card/nav widgets that
// appear across the dashboard, search, discount, safety and trek-detail
// screens. Same harness as shared_widgets_responsive_test.dart.
//
// Run:  flutter test test/responsive/more_widgets_responsive_test.dart

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/freezed_models/treks/trek_detail_model.dart'
    show CancellationPolicy;
import 'package:arobo_app/utils/common_bottom_nav.dart';
import 'package:arobo_app/utils/common_safety_card.dart';
import 'package:arobo_app/utils/coupon_gradient_card.dart';
import 'package:arobo_app/utils/know_more_card.dart';
import 'package:arobo_app/utils/seasonal_forecast_mock_data.dart' show TrekSeason;
import 'package:arobo_app/utils/seasonal_gradient_card.dart';
import 'package:arobo_app/utils/top_treks_card.dart';
import 'package:arobo_app/widgets/cancellation_policy_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'responsive_harness.dart';

class _StubDashboardController extends DashboardController {
  // Skip the real onInit (fires unrelated Future.wait network calls) — same
  // pattern as the stubs in trek_controller_test.dart / the cancellation
  // suite, which carry the same must_call_super lint by design.
  @override
  void onInit() {}
}

void main() {
  group('TopTreksCard (dashboard carousel — 68%w x 1.25)', () {
    testWidgets('typical', (tester) async {
      final failures = await collectResponsiveOverflows(
        tester,
        build: () => TopTreksCard(
          imagePath: '',
          title: 'Hampta Pass',
          description: 'A classic crossover trek from lush Kullu to the '
              'stark moonscape of Lahaul.',
          kicker: 'HIMACHAL',
          meta: '5D / 4N · Moderate',
          width: 68.w,
          height: 68.w * 1.25,
        ),
      );
      expectNoResponsiveOverflow(failures);
    });

    testWidgets('long strings', (tester) async {
      final failures = await collectResponsiveOverflows(
        tester,
        build: () => TopTreksCard(
          imagePath: '',
          title: 'Kedarkantha Winter Summit Expedition via Sankri Base',
          description: 'One of the most popular snow treks in the country, '
              'best attempted between late December and early April when the '
              'ridge holds deep powder.',
          badgeText: 'Editor’s Choice — Limited Departures',
          kicker: 'UTTARAKHAND HIMALAYA',
          meta: '6 Days / 5 Nights · Moderate to Difficult',
          width: 68.w,
          height: 68.w * 1.25,
        ),
      );
      expectNoResponsiveOverflow(failures);
    });
  });

  group('SeasonalGradientCard (70%w x 24%h)', () {
    testWidgets('avoid card, long reason', (tester) async {
      final failures = await collectResponsiveOverflows(
        tester,
        build: () => SeasonalGradientCard(
          trekName: 'Valley of Flowers National Park',
          reason: 'Peak monsoon brings landslides on the Govindghat road and '
              'leeches on the trail — the blooms are past their best by then '
              'anyway.',
          imagePath: '',
          isAvoid: true,
          season: TrekSeason.monsoon,
          width: 70.w,
          height: 24.h,
        ),
      );
      expectNoResponsiveOverflow(failures);
    });
  });

  group('KnowMoreCard', () {
    testWidgets('default width fraction', (tester) async {
      final failures = await collectResponsiveOverflows(
        tester,
        build: () => const KnowMoreCard(
          gradientColors: ['#FFE066', '#FFC300'],
          imagePath: '',
          title: 'How Aorbo verifies every organiser',
          subtitle: 'Background checks, insurance proof and a physical safety '
              'audit before a single slot goes live.',
        ),
      );
      expectNoResponsiveOverflow(failures);
    });
  });

  group('CouponGradientCard', () {
    testWidgets('typical + long condition line', (tester) async {
      final failures = await collectResponsiveOverflows(
        tester,
        build: () => const CouponGradientCard(
          gradientColors: ['#0F7B6C', '#1AA090'],
          badgeLabel: 'FIRST BOOKING',
          headline: 'FLAT ₹500 OFF',
          conditionText:
              'Upto ₹500 · On orders above ₹4,500 · New users only',
          code: 'AORBOWELCOME500',
        ),
      );
      expectNoResponsiveOverflow(failures);
    });
  });

  group('CommonSafetyCard (default 35%h x 100%w)', () {
    testWidgets('with footer', (tester) async {
      final failures = await collectResponsiveOverflows(
        tester,
        build: () => const CommonSafetyCard(
          title: 'Women’s Safety on Aorbo Treks',
          subtitle: 'Verified organisers, female trip leaders on request, and '
              '24x7 SOS support throughout the trek.',
          backgroundImage: '',
          footerText: 'Tap to read our full safety charter',
        ),
      );
      expectNoResponsiveOverflow(failures);
    });
  });

  group('CancellationPolicyWidget', () {
    testWidgets('standard policy, 4 slabs', (tester) async {
      final failures = await collectResponsiveOverflows(
        tester,
        scrollable: true, // real parent is trek_details_screen's scroll view
        build: () => const CancellationPolicyWidget(
          departureDate: '2026-10-12T06:00:00',
          basePrice: '12499',
          policy: CancellationPolicy(
            title: 'Standard Cancellation Policy',
            policyType: 'standard',
            descriptionPoints: [
              'All timings are calculated against the trek departure time '
                  'shown on your ticket.',
              'Refunds are processed to the original payment method within '
                  '5–7 business days.',
            ],
            settings: {
              'slab72hPlusPct': 20,
              'slab48to72hPct': 50,
              'slab24to48hPct': 70,
              'slabUnder24hPct': 100,
            },
          ),
        ),
      );
      expectNoResponsiveOverflow(failures);
    });

    testWidgets('flexible policy', (tester) async {
      final failures = await collectResponsiveOverflows(
        tester,
        scrollable: true, // real parent is trek_details_screen's scroll view
        build: () => const CancellationPolicyWidget(
          departureDate: '2026-10-12T06:00:00',
          basePrice: '7999',
          policy: CancellationPolicy(
            title: 'Flexible Cancellation Policy',
            policyType: 'flexible',
            settings: {
              'advanceAmount': 999,
              'advanceNonRefundable': true,
              'fullPayment24hDeductionPct': 100,
            },
          ),
        ),
      );
      expectNoResponsiveOverflow(failures);
    });
  });

  group('CommonBottomNav', () {
    setUp(() {
      Get.testMode = true;
      Get.put<DashboardController>(_StubDashboardController());
    });
    tearDown(Get.reset);

    testWidgets('index 0 selected', (tester) async {
      final failures = await collectResponsiveOverflows(
        tester,
        build: () => const CommonBottomNav(selectedIndex: 0),
      );
      expectNoResponsiveOverflow(failures);
    });

    testWidgets('index 1 selected (longest label "Bookings")', (tester) async {
      Get.find<DashboardController>().selectedScreen.value = 1;
      final failures = await collectResponsiveOverflows(
        tester,
        build: () => const CommonBottomNav(selectedIndex: 1),
      );
      expectNoResponsiveOverflow(failures);
    });
  });
}
