import 'package:arobo_app/legal/legal_service.dart';
import 'package:arobo_app/legal/legal_web_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('decideLegalNavigation', () {
    LegalNavAction decide(String url, {String? home}) =>
        decideLegalNavigation(Uri.parse(url), home: home == null ? null : Uri.parse(home));

    test("Aorbo's website opens in the app", () {
      expect(decide('https://aorbotreks.com/terms'), LegalNavAction.allow);
      expect(decide('https://www.aorbotreks.com/privacy-policy'), LegalNavAction.allow);
      expect(decide('https://AORBOTREKS.com/refund-policy'), LegalNavAction.allow);
    });

    test('the host the server gave for the document opens in the app too', () {
      expect(
        decide('https://legal.example.in/terms', home: 'https://legal.example.in/terms'),
        LegalNavAction.allow,
      );
    });

    test('other sites, e-mail and phone links open outside the app', () {
      expect(decide('https://www.google.com/'), LegalNavAction.openExternally);
      expect(decide('http://aorbotreks.com/terms'), LegalNavAction.openExternally);
      expect(decide('mailto:care@aorbotreks.com'), LegalNavAction.openExternally);
      expect(decide('tel:112'), LegalNavAction.openExternally);
    });

    test('everything else is dropped', () {
      expect(decide('intent://scan/#Intent;scheme=zxing;end'), LegalNavAction.block);
      expect(decide('file:///data/data/com.aorbotreks.app/x'), LegalNavAction.block);
      expect(decide('javascript:alert(1)'), LegalNavAction.block);
    });
  });

  test("the hide script hides only the site's menu, footer, cookie banner and loading bar", () {
    for (final selector in ['.site-nav', '.site-footer', '#cookie-banner', '.route-progress']) {
      expect(kLegalHideSiteChromeScript, contains(selector));
    }
    expect(kLegalHideSiteChromeScript, isNot(contains('.legal')));
  });

  test('legalTitleFor finds the built-in titles by key or URL', () {
    expect(legalTitleFor(key: 'refund'), 'Refund & Cancellation Policy');
    expect(legalTitleFor(url: 'https://aorbotreks.com/privacy-policy'), 'Privacy Policy');
    expect(legalTitleFor(key: 'nope'), 'Legal');
  });
}
