// Overflow matrix (every test device × text scale) for the giveaway's own
// native UI: the dashboard banner and the Rules screen.
//
// Run:  flutter test test/giveaway/giveaway_responsive_test.dart

import 'package:arobo_app/giveaway/giveaway_api.dart';
import 'package:arobo_app/giveaway/giveaway_banner.dart';
import 'package:arobo_app/giveaway/giveaway_rules_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../responsive/responsive_harness.dart';

/// Rules as long as the real Round 1 set (12 sections, long paragraphs).
class _LongRulesApi extends PreviewGiveawayApi {
  @override
  Future<GiveawayRules?> rules({String? round}) async => GiveawayRules(
        label: 'Round 1',
        version: 'R1-v1',
        sections: List.generate(
          12,
          (i) => GiveawayRulesSection('${i + 1}. A section title long enough to wrap onto a second line', [
            'One trek of the winner\'s choice listed on Aorbo, for one person, with a listed price (including taxes) '
                'of up to ₹10,000, starting within 10 days of the winner being confirmed.',
            '• A bullet point that also wraps across more than one line on a small phone.',
          ]),
        ),
      );
}

void main() {
  testWidgets('GiveawayBanner — Round 1 copy', (tester) async {
    final failures = await collectResponsiveOverflows(
      tester,
      build: () => const GiveawayBanner(),
    );
    expectNoResponsiveOverflow(failures);
  });

  testWidgets('GiveawayBanner — long labels', (tester) async {
    final failures = await collectResponsiveOverflows(
      tester,
      build: () => const GiveawayBanner(
        roundLabel: 'ROUND 12',
        drawLabel: 'Draw on 30 September 2027 at 7:00 PM IST',
        ctaLabel: 'See the result',
      ),
    );
    expectNoResponsiveOverflow(failures);
  });

  testWidgets('GiveawayRulesScreen — full rules', (tester) async {
    final failures = await collectResponsiveOverflows(
      tester,
      build: () => GiveawayRulesScreen(api: _LongRulesApi()),
    );
    expectNoResponsiveOverflow(failures);
  });
}
