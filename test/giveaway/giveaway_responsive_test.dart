// Overflow matrix (every test device × text scale) for the giveaway's own
// native UI: the dashboard banner and the Rules screen.
//
// Run:  flutter test test/giveaway/giveaway_responsive_test.dart

import 'package:arobo_app/giveaway/giveaway_banner.dart';
import 'package:arobo_app/giveaway/giveaway_rules_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../responsive/responsive_harness.dart';

void main() {
  testWidgets('GiveawayBanner — Round 1 copy', (tester) async {
    final failures = await collectResponsiveOverflows(
      tester,
      build: () => const GiveawayBanner(),
    );
    expectNoResponsiveOverflow(failures);
  });

  testWidgets('GiveawayBanner — long draw label', (tester) async {
    final failures = await collectResponsiveOverflows(
      tester,
      build: () => const GiveawayBanner(
        roundLabel: 'ROUND 12',
        drawLabel: 'Draw on 30 September 2027 at 7:00 PM IST',
      ),
    );
    expectNoResponsiveOverflow(failures);
  });

  testWidgets('GiveawayRulesScreen', (tester) async {
    final failures = await collectResponsiveOverflows(
      tester,
      build: () => const GiveawayRulesScreen(),
    );
    expectNoResponsiveOverflow(failures);
  });
}
