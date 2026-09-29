import 'package:arobo_app/giveaway/giveaway_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GiveawayRoundSummary', () {
    test('reads the featured round from GET giveaway/current', () {
      final r = GiveawayRoundSummary.fromJson({
        'code': 'R1',
        'label': 'Round 1',
        'phase': 'open',
        'drawAt': '2027-03-31T13:30:00.000Z',
      })!;
      expect(r.code, 'R1');
      expect(r.phase, 'open');
      // 13:30 UTC = 7 PM India time, whatever the phone's time zone.
      expect(r.drawLabel, 'Draw on 31 Mar, 7 PM');
    });

    test('shows minutes when there are any, and a past tense once drawn', () {
      final r = GiveawayRoundSummary.fromJson({
        'code': 'R2', 'label': 'Round 2', 'phase': 'drawn', 'drawAt': '2027-06-30T14:15:00Z',
      })!;
      expect(r.drawLabel, 'Drawn on 30 Jun');
      final open = GiveawayRoundSummary.fromJson({
        'code': 'R2', 'label': 'Round 2', 'phase': 'open', 'drawAt': '2027-06-30T14:15:00Z',
      })!;
      expect(open.drawLabel, 'Draw on 30 Jun, 7:45 PM');
    });

    test('no round / malformed → null (the banner hides)', () {
      expect(GiveawayRoundSummary.fromJson(null), isNull);
      expect(GiveawayRoundSummary.fromJson({'code': 'R1'}), isNull);
      expect(GiveawayRoundSummary.fromJson({'code': 1, 'label': 'x', 'drawAt': '2027-01-01'}), isNull);
    });
  });

  group('GiveawayRules', () {
    test('reads sections from GET giveaway/rules, skipping malformed ones', () {
      final rules = GiveawayRules.fromJson({
        'label': 'Round 1',
        'version': 'R1-v1',
        'sections': [
          {'title': '1. The giveaway', 'paragraphs': ['One winner.', 42]},
          {'title': 'broken'},
          'nope',
        ],
      })!;
      expect(rules.version, 'R1-v1');
      expect(rules.sections, hasLength(1));
      expect(rules.sections.first.paragraphs, ['One winner.']);
    });

    test('nothing usable → null (the screen shows retry)', () {
      expect(GiveawayRules.fromJson({'sections': []}), isNull);
      expect(GiveawayRules.fromJson(null), isNull);
    });
  });
}
