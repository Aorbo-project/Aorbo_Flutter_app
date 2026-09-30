import 'package:arobo_app/giveaway/referral_links.dart';
import 'package:arobo_app/share/trek_link.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('TrekLink.fromUri', () {
    test('reads the code from a trek link on either host', () {
      expect(TrekLink.fromUri(Uri.parse('https://aorbotreks.co.in/t/Kp4mQ7xZ')), const TrekLink('Kp4mQ7xZ'));
      expect(TrekLink.fromUri(Uri.parse('https://api.aorbotreks.co.in/t/Kp4mQ7xZ/')), const TrekLink('Kp4mQ7xZ'));
    });

    test('rejects anything that is not an Aorbo https /t/<code> link', () {
      for (final url in [
        'http://aorbotreks.co.in/t/Kp4mQ7xZ',
        'https://evil.example/t/Kp4mQ7xZ',
        'https://aorbotreks.co.in:8443/t/Kp4mQ7xZ',
        'https://aorbotreks.co.in/t/269',
        'https://aorbotreks.co.in/t/Kp4mQ7xZ9',
        'https://aorbotreks.co.in/t/Kp4m-7xZ',
        'https://aorbotreks.co.in/t/Kp4mQ7xZ/extra',
        'https://aorbotreks.co.in/r/AORBOX7K2P',
      ]) {
        expect(TrekLink.fromUri(Uri.parse(url)), isNull, reason: url);
      }
    });

    test('a trek link is never mistaken for a referral code', () {
      expect(ReferralLinkParser.fromUri(Uri.parse('https://aorbotreks.co.in/t/Kp4mQ7xZ')), isNull);
    });

    test('the shared link carries only the code', () {
      expect(const TrekLink('Kp4mQ7xZ').toUri().toString(), 'https://aorbotreks.co.in/t/Kp4mQ7xZ');
      expect(TrekLink.fromUri(const TrekLink('Kp4mQ7xZ').toUri()), const TrekLink('Kp4mQ7xZ'));
    });
  });

  group('TrekLink.fromInstallReferrer', () {
    test('reads the code the backend puts in the Play Store referrer', () {
      expect(TrekLink.fromInstallReferrer('share=Kp4mQ7xZ&utm_source=trek_share'), const TrekLink('Kp4mQ7xZ'));
    });

    test('a referral-only or junk referrer has no trek', () {
      expect(TrekLink.fromInstallReferrer('ref=AORBOX7K2P&utm_source=referral_link'), isNull);
      expect(TrekLink.fromInstallReferrer('utm_source=google-play&utm_medium=organic'), isNull);
      expect(TrekLink.fromInstallReferrer('share=%%%'), isNull);
      expect(TrekLink.fromInstallReferrer('share=<script>'), isNull);
      expect(TrekLink.fromInstallReferrer(null), isNull);
    });
  });

  group('TrekTarget.fromJson', () {
    test('reads the ids the server resolves a code to', () {
      expect(TrekTarget.fromJson({'trekId': 269, 'batchId': 3940, 'cityId': null}),
          const TrekTarget(trekId: 269, batchId: 3940));
    });

    test('needs a real trek id; junk batch/city are dropped', () {
      expect(TrekTarget.fromJson({'trekId': 0}), isNull);
      expect(TrekTarget.fromJson({'trekId': '269'}), isNull);
      expect(TrekTarget.fromJson(null), isNull);
      expect(TrekTarget.fromJson({'trekId': 269, 'batchId': -1, 'cityId': 'x'}), const TrekTarget(trekId: 269));
    });
  });

  test('the message names the trek and its IST date, then the link', () {
    final text = TrekShareText.build(
      title: 'Gokarna Beach Trek',
      startDate: '2026-10-02',
      link: Uri.parse('https://aorbotreks.co.in/t/Kp4mQ7xZ'),
    );
    expect(text,
        "Who's in? 🏔️\nGokarna Beach Trek · Fri, 2 Oct 2026\nFound it on Aorbo Treks 👇\nhttps://aorbotreks.co.in/t/Kp4mQ7xZ");
    expect(TrekShareText.build(title: ' ', link: Uri.parse('https://aorbotreks.co.in/t/Kp4mQ7xZ')),
        startsWith("Who's in? 🏔️\nThis trek\n"));
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
      await PendingTrekLink.save(const TrekLink('Kp4mQ7xZ'));
      expect(await PendingTrekLink.read(), const TrekLink('Kp4mQ7xZ'));
      await PendingTrekLink.clear();
      expect(await PendingTrekLink.read(), isNull);
    });

    test('forgets a link older than 7 days', () async {
      await PendingTrekLink.save(const TrekLink('Kp4mQ7xZ'));
      final sp = await SpUtil.getInstance();
      final old = DateTime.now().subtract(const Duration(days: 8)).millisecondsSinceEpoch;
      await sp.putInt('pending_trek_link_saved_at', old);
      expect(await PendingTrekLink.read(), isNull);
      expect(sp.getString('pending_trek_link_code'), isNull);
    });

    test('ignores a stored value that is not a valid code', () async {
      await PendingTrekLink.save(const TrekLink('Kp4mQ7xZ'));
      final sp = await SpUtil.getInstance();
      await sp.putString('pending_trek_link_code', '<script>');
      expect(await PendingTrekLink.read(), isNull);
      expect(sp.getInt('pending_trek_link_saved_at'), isNull);
    });
  });
}
