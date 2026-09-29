import 'package:arobo_app/giveaway/giveaway_config.dart';
import 'package:arobo_app/giveaway/giveaway_web_policy.dart';
import 'package:arobo_app/giveaway/referral_links.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ReferralLinkParser.fromUri', () {
    test('reads the code from a referral link on either host', () {
      expect(ReferralLinkParser.fromUri(Uri.parse('https://aorbotreks.co.in/r/AORBOX7K2P')), 'AORBOX7K2P');
      expect(ReferralLinkParser.fromUri(Uri.parse('https://api.aorbotreks.co.in/r/aorbox7k2p/')), 'AORBOX7K2P');
      expect(ReferralLinkParser.fromUri(Uri.parse('https://AORBOTREKS.CO.IN/r/AORBOX7K2P?utm_source=wa')), 'AORBOX7K2P');
    });

    test('ignores anything that is not exactly a referral link', () {
      for (final u in [
        'http://aorbotreks.co.in/r/AORBOX7K2P',
        'https://evil.example/r/AORBOX7K2P',
        'https://aorbotreks.co.in.evil.example/r/AORBOX7K2P',
        'https://aorbotreks.co.in:8443/r/AORBOX7K2P',
        'https://aorbotreks.co.in/r/',
        'https://aorbotreks.co.in/r/AORBOX7K2P/extra',
        'https://aorbotreks.co.in/x/AORBOX7K2P',
        'https://aorbotreks.co.in/r/AOR',
        'https://aorbotreks.co.in/r/AORBO%3Cscript%3E',
        'https://aorbotreks.co.in/r/${'A' * 17}',
      ]) {
        expect(ReferralLinkParser.fromUri(Uri.parse(u)), isNull, reason: u);
      }
    });
  });

  group('ReferralLinkParser.fromInstallReferrer', () {
    test('reads only the ref value', () {
      expect(ReferralLinkParser.fromInstallReferrer('ref=AORBOX7K2P&utm_source=instagram'), 'AORBOX7K2P');
      expect(ReferralLinkParser.fromInstallReferrer('utm_source=google-play&utm_medium=organic'), isNull);
      expect(ReferralLinkParser.fromInstallReferrer('ref=<script>'), isNull);
      expect(ReferralLinkParser.fromInstallReferrer(null), isNull);
      expect(ReferralLinkParser.fromInstallReferrer('ref=${'A' * 2000}'), isNull);
    });
  });

  group('PendingReferralCode', () {
    // SpUtil keeps one SharedPreferences instance for the whole run, so the
    // store is mocked once and each test writes through SpUtil itself.
    setUpAll(() => SharedPreferences.setMockInitialValues({}));
    setUp(PendingReferralCode.clear);

    test('keeps a code until cleared', () async {
      await PendingReferralCode.save('AORBOX7K2P');
      expect(await PendingReferralCode.read(), 'AORBOX7K2P');
      await PendingReferralCode.clear();
      expect(await PendingReferralCode.read(), isNull);
    });

    test('forgets a code older than 30 days', () async {
      await PendingReferralCode.save('AORBOX7K2P');
      final sp = await SpUtil.getInstance();
      final old = DateTime.now().subtract(const Duration(days: 31)).millisecondsSinceEpoch;
      await sp.putInt('giveaway_pending_referral_saved_at', old);
      expect(await PendingReferralCode.read(), isNull);
      expect(sp.getString('giveaway_pending_referral_code'), isNull);
    });

    test('ignores a stored value that is not a valid code', () async {
      await PendingReferralCode.save('AORBOX7K2P');
      final sp = await SpUtil.getInstance();
      await sp.putString('giveaway_pending_referral_code', '<script>');
      expect(await PendingReferralCode.read(), isNull);
    });
  });

  group('GiveawayWebPolicy', () {
    test('only the campaign pages load in the app', () {
      final origin = 'https://${GiveawayConfig.webHost}';
      for (final u in ['$origin/giveaway', '$origin/giveaway/', '$origin/giveaway/?c=abc', '$origin/giveaway/live']) {
        expect(GiveawayWebPolicy.decide(Uri.parse(u)), WebNavAction.allow, reason: u);
      }
      for (final u in [
        '$origin/api/v1/customer/profile',
        '$origin/giveawayx',
        '$origin:8443/giveaway/',
        'https://user@${GiveawayConfig.webHost}/giveaway/',
        'http://${GiveawayConfig.webHost}/giveaway/',
      ]) {
        expect(GiveawayWebPolicy.decide(Uri.parse(u)), isNot(WebNavAction.allow), reason: u);
      }
    });

    test('ordinary links leave for the phone browser; other schemes are dropped', () {
      expect(GiveawayWebPolicy.decide(Uri.parse('https://www.instagram.com/aorbotreks')), WebNavAction.openExternally);
      expect(GiveawayWebPolicy.decide(Uri.parse('mailto:care@aorbotreks.com')), WebNavAction.openExternally);
      for (final u in [
        'http://example.com',
        'javascript:alert(1)',
        'intent://scan/#Intent;scheme=zxing;end',
        'file:///data/data/com.aorbotreks.app/shared_prefs/x.xml',
        'data:text/html,<h1>x</h1>',
        'about:blank',
      ]) {
        expect(GiveawayWebPolicy.decide(Uri.parse(u)), WebNavAction.block, reason: u);
      }
    });

    test('the one-time code rides in the fragment, never the query (not sent to servers)', () {
      expect(GiveawayConfig.pageUri().toString(), 'https://${GiveawayConfig.webHost}/giveaway/');
      final withCode = GiveawayConfig.pageUri(code: 'abc');
      expect(withCode.fragment, 'c=abc');
      expect(withCode.queryParameters, isEmpty);
      expect(GiveawayWebPolicy.decide(withCode), WebNavAction.allow);
    });
  });
}
