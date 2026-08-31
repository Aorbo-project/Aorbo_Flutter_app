import 'package:flutter_test/flutter_test.dart';
import 'package:arobo_app/models/sponsored_slot_data.dart';
import 'package:arobo_app/utils/sponsored_injection.dart';

SponsoredSlot _slot(int id, int position) => SponsoredSlot(
      id: id,
      row: 'whats_new',
      slotType: 'brand_video',
      position: position,
      advertiser: 'Ad $id',
      videoUrl: 'https://example.com/$id.mp4',
    );

/// A stand-in organic card.
class _Card {
  final int n;
  const _Card(this.n);
}

List<Object> _cards(int count) =>
    List<Object>.generate(count, (i) => _Card(i));

void main() {
  group('injectSponsoredSlots', () {
    test('no slots → list unchanged', () {
      final out = injectSponsoredSlots(organic: _cards(5), slots: []);
      expect(out.whereType<SponsoredSlot>(), isEmpty);
      expect(out.length, 5);
    });

    test('too few organic cards → no ad at all', () {
      final out = injectSponsoredSlots(
        organic: _cards(1),
        slots: [_slot(1, 2)],
      );
      expect(out.whereType<SponsoredSlot>(), isEmpty);
    });

    test('one slot drops in at its position, never first', () {
      final out = injectSponsoredSlots(
        organic: _cards(4),
        slots: [_slot(1, 2)],
      );
      final ads = out.whereType<SponsoredSlot>().toList();
      expect(ads.length, 1);
      expect(out.indexOf(ads.first), 2);
      expect(out.first, isA<_Card>()); // first card is organic
    });

    test('2nd slot is auto-gated on a short carousel (4 organic → 1 ad)', () {
      final out = injectSponsoredSlots(
        organic: _cards(4),
        slots: [_slot(1, 2), _slot(2, 5)],
      );
      expect(out.whereType<SponsoredSlot>().length, 1);
    });

    test('2nd slot appears once the carousel is long enough (8 organic → 2 ads)',
        () {
      final out = injectSponsoredSlots(
        organic: _cards(8),
        slots: [_slot(1, 2), _slot(2, 6)],
      );
      final adIdx = [
        for (var i = 0; i < out.length; i++)
          if (out[i] is SponsoredSlot) i,
      ];
      expect(adIdx.length, 2);
      // at least `minGap` apart, and neither first nor last
      expect(adIdx.first, greaterThanOrEqualTo(1));
      expect(adIdx.last, lessThan(out.length - 1));
      expect(adIdx[1] - adIdx[0], greaterThanOrEqualTo(3));
    });

    test('never more than maxAds even with more slots', () {
      final out = injectSponsoredSlots(
        organic: _cards(20),
        slots: [_slot(1, 2), _slot(2, 6), _slot(3, 10)],
      );
      expect(out.whereType<SponsoredSlot>().length, 2);
    });

    test('slots are placed in ascending position order', () {
      final out = injectSponsoredSlots(
        organic: _cards(12),
        slots: [_slot(1, 9), _slot(2, 3)],
      );
      final ads = out.whereType<SponsoredSlot>().toList();
      expect(ads.map((a) => a.id), [2, 1]);
    });
  });
}
