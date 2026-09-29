import 'dart:convert';

import 'package:arobo_app/giveaway/giveaway_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

String msg(Map<String, Object?> m) => jsonEncode({'v': 1, 'id': 'req-12345678', ...m});

Map<String, Object?> entryPayload({Map<String, Object?>? answers, Map<String, Object?> extra = const {}}) => {
      'rulesAccepted': true,
      'declaredAdult': true,
      'rulesVersion': 'R1-v1',
      'publicityConsent': false,
      'answers': answers ??
          {
            'q1': ['cost', 'no_group'],
            'q2': '3000_5000',
            'q3': ['instagram'],
            'q4': '0',
            'q5': 'The mountains.',
          },
      ...extra,
    };

void main() {
  group('GiveawayBridge.parse — envelope', () {
    test('accepts each known request type', () {
      for (final t in ['ready', 'openRules', 'share', 'close']) {
        final r = GiveawayBridge.parse(msg({'type': t}));
        expect(r, isNotNull, reason: t);
        expect(r!.type.wire, t);
        expect(r.id, 'req-12345678');
      }
    });

    test('drops malformed messages', () {
      expect(GiveawayBridge.parse(''), isNull);
      expect(GiveawayBridge.parse('not json'), isNull);
      expect(GiveawayBridge.parse('[1,2]'), isNull);
      expect(GiveawayBridge.parse(jsonEncode({'v': 2, 'id': 'req-12345678', 'type': 'ready'})), isNull);
      expect(GiveawayBridge.parse(jsonEncode({'v': 1, 'type': 'ready'})), isNull);
      expect(GiveawayBridge.parse(jsonEncode({'v': 1, 'id': 'short', 'type': 'ready'})), isNull);
      expect(GiveawayBridge.parse(jsonEncode({'v': 1, 'id': 'bad id with spaces', 'type': 'ready'})), isNull);
      expect(GiveawayBridge.parse(msg({'type': 'deleteAccount'})), isNull);
      expect(GiveawayBridge.parse(msg({'type': 'ready', 'payload': 'x'})), isNull);
    });

    test('drops oversized messages', () {
      final big = msg({'type': 'ready', 'payload': {'pad': 'x' * GiveawayBridge.maxMessageLength}});
      expect(GiveawayBridge.parse(big), isNull);
    });
  });

  group('GiveawayBridge.parse — submitEntry', () {
    test('accepts a well-formed entry and keeps the answers as sent', () {
      final r = GiveawayBridge.parse(msg({'type': 'submitEntry', 'payload': entryPayload()}));
      expect(r, isNotNull);
      final e = r!.entry!;
      expect(e.rulesVersion, 'R1-v1');
      expect(e.publicityConsent, isFalse);
      expect(e.answers['q1'], ['cost', 'no_group']);
      expect(e.answers['q5'], 'The mountains.');
      expect(e.toJson()['rulesAccepted'], isTrue);
    });

    test('requires both ticks and a rules version', () {
      for (final bad in [
        {'rulesAccepted': false},
        {'rulesAccepted': 'true'},
        {'declaredAdult': false},
        {'rulesVersion': ''},
        {'rulesVersion': 'R1 v1'},
        {'publicityConsent': 'yes'},
      ]) {
        final r = GiveawayBridge.parse(msg({'type': 'submitEntry', 'payload': entryPayload(extra: bad)}));
        expect(r, isNull, reason: '$bad');
      }
    });

    test('rejects bad answer shapes', () {
      final cases = <Map<String, Object?>>[
        {},
        {'Q1': 'x'},
        {'q1': 3},
        {'q1': <String>[]},
        {'q1': List.filled(EntrySubmission.maxChoices + 1, 'a')},
        {'q1': ['x' * (EntrySubmission.maxChoiceLength + 1)]},
        {'q5': 'x' * (EntrySubmission.maxTextLength + 1)},
        {'q5': 'bell\u0007'},
        {for (var i = 0; i < EntrySubmission.maxAnswers + 1; i++) 'q$i': 'a'},
      ];
      for (final answers in cases) {
        final r = GiveawayBridge.parse(msg({'type': 'submitEntry', 'payload': entryPayload(answers: answers)}));
        expect(r, isNull, reason: '$answers');
      }
    });

    test('passes an optional positive state id through; rejects anything else', () {
      final ok = GiveawayBridge.parse(msg({'type': 'submitEntry', 'payload': entryPayload(extra: {'stateId': 12})}));
      expect(ok!.entry!.stateId, 12);
      expect(ok.entry!.toJson()['stateId'], 12);
      final none = GiveawayBridge.parse(msg({'type': 'submitEntry', 'payload': entryPayload()}));
      expect(none!.entry!.toJson().containsKey('stateId'), isFalse);
      for (final bad in [0, -1, '12', 1.5, 2000000]) {
        expect(GiveawayBridge.parse(msg({'type': 'submitEntry', 'payload': entryPayload(extra: {'stateId': bad})})), isNull,
            reason: '$bad');
      }
    });

    test('allows newlines in free text and trims it', () {
      final r = GiveawayBridge.parse(msg({
        'type': 'submitEntry',
        'payload': entryPayload(answers: {'q5': '  line one\nline two  '}),
      }));
      expect(r!.entry!.answers['q5'], 'line one\nline two');
    });
  });

  test('replyScript passes JSON as an inert string literal', () {
    final script = GiveawayBridge.replyScript({
      'replyTo': 'req-12345678',
      'type': 'entryResult',
      'ok': false,
      'error': {'message': "</script><script>alert('x')</script>\"); evil();//"},
    });
    expect(script, startsWith('window.AorboGiveawayHost && window.AorboGiveawayHost.receive("'));
    expect(script, endsWith('");'));
    // The argument is one JSON string literal; decoding it twice gives the reply back.
    final literal = script.substring(script.indexOf('receive(') + 8, script.length - 2);
    final reply = jsonDecode(jsonDecode(literal) as String) as Map<String, dynamic>;
    expect(reply['v'], 1);
    expect(reply['error']['message'], contains('evil()'));
  });
}
