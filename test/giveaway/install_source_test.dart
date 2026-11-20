import 'package:arobo_app/giveaway/install_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InstallSource.parse (Play install referrer -> where the install came from)', () {
    test('website link: source, search engine and page kind', () {
      expect(
        InstallSource.parse('utm_source=aorbotreks.com&utm_medium=google&utm_campaign=compare'),
        {'source': 'aorbotreks.com', 'medium': 'google', 'campaign': 'compare'},
      );
    });

    test('plain Play Store install and shared links keep their own source', () {
      expect(InstallSource.parse('utm_source=google-play&utm_medium=organic'), {'source': 'google-play', 'medium': 'organic'});
      expect(InstallSource.parse('share=AbCd1234&utm_source=trek_share'), {'source': 'trek_share'});
      expect(InstallSource.parse('ref=AORBOX1Y2Z&utm_source=referral_link'), {'source': 'referral_link'});
    });

    test('nothing personal or malformed is kept', () {
      expect(InstallSource.parse(null), isNull);
      expect(InstallSource.parse(''), isNull);
      expect(InstallSource.parse('utm_medium=google'), isNull);
      expect(InstallSource.parse('utm_source=${'a' * 41}'), isNull);
      expect(InstallSource.parse('utm_source=ok&utm_medium=has%20space&utm_campaign=<x>'), {'source': 'ok'});
      expect(InstallSource.parse('utm_source=${'a' * 2000}'), isNull);
    });
  });
}
