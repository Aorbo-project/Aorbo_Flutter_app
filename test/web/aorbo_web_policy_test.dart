import 'package:arobo_app/legal/legal_service.dart';
import 'package:arobo_app/web/aorbo_web_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('decideWebNavigation', () {
    WebNavDecision decide(String url, {String? home}) =>
        decideWebNavigation(Uri.parse(url), home: home == null ? null : Uri.parse(home));

    test("Aorbo's website opens in the app", () {
      expect(decide('https://aorbotreks.com/terms'), WebNavDecision.allow);
      expect(decide('https://www.aorbotreks.com/privacy-policy'), WebNavDecision.allow);
      expect(decide('https://AORBOTREKS.com/refund-policy'), WebNavDecision.allow);
    });

    test('the host the server gave for the document opens in the app too', () {
      expect(
        decide('https://legal.example.in/terms', home: 'https://legal.example.in/terms'),
        WebNavDecision.allow,
      );
    });

    test('other sites, e-mail and phone links open outside the app', () {
      expect(decide('https://www.google.com/'), WebNavDecision.openExternally);
      expect(decide('http://aorbotreks.com/terms'), WebNavDecision.openExternally);
      expect(decide('mailto:care@aorbotreks.com'), WebNavDecision.openExternally);
      expect(decide('tel:112'), WebNavDecision.openExternally);
    });

    test('everything else is dropped', () {
      expect(decide('intent://scan/#Intent;scheme=zxing;end'), WebNavDecision.block);
      expect(decide('file:///data/data/com.aorbotreks.app/x'), WebNavDecision.block);
      expect(decide('javascript:alert(1)'), WebNavDecision.block);
    });
  });

  test("the hide script hides only the site's menu, footer, cookie banner and loading bar", () {
    for (final selector in ['.site-nav', '.site-footer', '#cookie-banner', '.route-progress']) {
      expect(kHideSiteChromeScript, contains(selector));
    }
    expect(kHideSiteChromeScript, isNot(contains('.legal')));
  });

  test('legalTitleFor finds the built-in titles by key or URL', () {
    expect(legalTitleFor(key: 'refund'), 'Refund & Cancellation Policy');
    expect(legalTitleFor(url: 'https://aorbotreks.com/privacy-policy'), 'Privacy Policy');
    expect(legalTitleFor(key: 'nope'), 'Legal');
  });
}
