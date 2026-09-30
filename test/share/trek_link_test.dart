import 'package:arobo_app/giveaway/referral_links.dart';
import 'package:arobo_app/share/trek_link.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('TrekLink.fromUri', () {
    test('reads trek, batch and city from a link on either host', () {
      expect(TrekLink.fromUri(Uri.parse('https://aorbotreks.co.in/t/439?b=12&c=3')),
          const TrekLink(trekId: 439, batchId: 12, cityId: 3));
      expect(TrekLink.fromUri(Uri.parse('https://api.aorbotreks.co.in/t/439/')),
          const TrekLink(trekId: 439));
    });

    test('drops malformed batch/city but keeps the trek', () {
      expect(TrekLink.fromUri(Uri.parse('https://aorbotreks.co.in/t/439?b=0&c=abc')),
          const TrekLink(trekId: 439));
    });

    test('rejects anything that is not an Aorbo https /t/<id> link', () {
      for (final url in [
        'http://aorbotreks.co.in/t/439',
        'https://evil.example/t/439',
        'https://aorbotreks.co.in:8443/t/439',
        'https://aorbotreks.co.in/t/0',
        'https://aorbotreks.co.in/t/-4',
        'https://aorbotreks.co.in/t/12ab',
        'https://aorbotreks.co.in/t/439/extra',
        'https://aorbotreks.co.in/r/AORBOX7K2P',
      ]) {
        expect(TrekLink.fromUri(Uri.parse(url)), isNull, reason: url);
      }
    });

    test('a trek link is never mistaken for a referral code', () {
      expect(ReferralLinkParser.fromUri(Uri.parse('https://aorbotreks.co.in/t/439')), isNull);
    });
  });

  group('TrekLink.fromInstallReferrer', () {
    test('reads the ids the backend puts in the Play Store referrer', () {
      expect(TrekLink.fromInstallReferrer('trek=439&batch=12&city=3&utm_source=trek_share'),
          const TrekLink(trekId: 439, batchId: 12, cityId: 3));
    });

    test('a referral-only or junk referrer has no trek', () {
      expect(TrekLink.fromInstallReferrer('ref=AORBOX7K2P&utm_source=referral_link'), isNull);
      expect(TrekLink.fromInstallReferrer('utm_source=google-play&utm_medium=organic'), isNull);
      expect(TrekLink.fromInstallReferrer('trek=%%%'), isNull);
      expect(TrekLink.fromInstallReferrer(null), isNull);
    });
  });

  group('sharing', () {
    test('forShare leaves out unknown ids and needs a real trek', () {
      expect(TrekLink.forShare(trekId: 439, batchId: 12, cityId: 0)!.toUri().toString(),
          'https://aorbotreks.co.in/t/439?b=12');
      expect(TrekLink.forShare(trekId: 439)!.toUri().toString(), 'https://aorbotreks.co.in/t/439');
      expect(TrekLink.forShare(trekId: null), isNull);
      expect(TrekLink.forShare(trekId: 0), isNull);
    });

    test('a shared link reads back as the same trek', () {
      const link = TrekLink(trekId: 439, batchId: 12, cityId: 3);
      expect(TrekLink.fromUri(link.toUri()), link);
    });

    test('the message names the trek and its IST date, then the link', () {
      final text = TrekShareText.build(
        title: 'Gokarna Beach Trek',
        startDate: '2026-10-02',
        link: Uri.parse('https://aorbotreks.co.in/t/439?b=12&c=3'),
      );
      expect(text,
          "Who's in? 🏔️\nGokarna Beach Trek · Fri, 2 Oct 2026\nFound it on Aorbo Treks 👇\nhttps://aorbotreks.co.in/t/439?b=12&c=3");
      expect(TrekShareText.build(title: ' ', link: Uri.parse('https://aorbotreks.co.in/t/1')),
          startsWith("Who's in? 🏔️\nThis trek\n"));
    });
  });

  test('isPastDate compares IST calendar days', () {
    // 30 Sep 2026, 11:00 PM IST = 17:30 UTC.
    final now = DateTime.utc(2026, 9, 30, 17, 30);
    expect(TrekLink.isPastDate('2026-09-29', now: now), isTrue);
    expect(TrekLink.isPastDate('2026-09-30', now: now), isFalse);
    expect(TrekLink.isPastDate('2026-10-01', now: now), isFalse);
    expect(TrekLink.isPastDate(null, now: now), isFalse);
  });

  group('PendingTrekLink', () {
    // SpUtil keeps one SharedPreferences instance for the whole run, so the
    // store is mocked once and each test writes through SpUtil itself.
    setUpAll(() => SharedPreferences.setMockInitialValues({}));
    setUp(PendingTrekLink.clear);

    test('keeps a link until it is cleared', () async {
      const link = TrekLink(trekId: 439, batchId: 12, cityId: 3);
      await PendingTrekLink.save(link);
      expect(await PendingTrekLink.read(), link);
      await PendingTrekLink.clear();
      expect(await PendingTrekLink.read(), isNull);
    });

    test('forgets a link older than 7 days', () async {
      await PendingTrekLink.save(const TrekLink(trekId: 439));
      final sp = await SpUtil.getInstance();
      final old = DateTime.now().subtract(const Duration(days: 8)).millisecondsSinceEpoch;
      await sp.putInt('pending_trek_link_saved_at', old);
      expect(await PendingTrekLink.read(), isNull);
      expect(sp.getString('pending_trek_link'), isNull);
    });

    test('ignores a stored value that is not a valid link', () async {
      await PendingTrekLink.save(const TrekLink(trekId: 439));
      final sp = await SpUtil.getInstance();
      await sp.putString('pending_trek_link', '{"trek":"<script>"}');
      expect(await PendingTrekLink.read(), isNull);
    });
  });
}
